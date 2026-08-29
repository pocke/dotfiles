#!/usr/bin/env ruby
# frozen_string_literal: true

# self-review の材料を 1 台ぶん集める。
#
#   ruby collect.rb [--root PATH]... [--out DIR] [--machine NAME] [--skip-transcripts]
#
# 集めるもの:
#   1. `.claude/artifacts/**/self-review.md` (指摘・区分・重大度・モデル・verdict)
#   2. `~/.claude/projects` のトランスクリプト (所要時間とトークン。self-review.md には無い)
#
# 出力は <out>/collected/<machine>/ に置く。中身はレビューしたリポジトリの本文を含むので、
# git リポジトリの中には書き込まない (--force で解除できる)。

require 'optparse'
require 'json'
require 'find'
require 'socket'
require 'fileutils'
require 'open3'
require_relative 'lib/output_guard'
require_relative 'lib/self_review_log'
require_relative 'lib/transcript'

module Collect
  # 生成物を単体で開いた読み手にも扱いが分かるように、先頭に置く
  NOTICE = <<~TEXT
    <!-- ローカル限定。private リポジトリのレビュー本文を含むので、リポジトリにも Issue にも貼らない -->
  TEXT

  LOG_BASENAME = 'self-review.md'
  PRUNE_DIRS = %w[.git node_modules vendor tmp .bundle target dist].freeze
  DOC_EXTENSIONS = %w[.md .markdown .txt .rst .adoc].freeze

  Options = Struct.new(:roots, :projects, :out, :machine, :skip_transcripts, :force, keyword_init: true)

  def self.default_options
    Options.new(
      roots: [File.join(Dir.home, 'ghq'), File.join(Dir.home, 'dotfiles')],
      projects: File.join(Dir.home, '.claude', 'projects'),
      out: ENV['SELF_REVIEW_ANALYSIS_HOME'] || File.join(Dir.home, 'self-review-analysis'),
      machine: Socket.gethostname,
      skip_transcripts: false,
      force: false
    )
  end

  def self.parse_options(argv)
    options = default_options
    roots = []

    OptionParser.new do |parser|
      parser.banner = 'Usage: ruby collect.rb [options]'
      parser.on('--root PATH', '探索するディレクトリ (繰り返し指定可、既定: ~/ghq と ~/dotfiles)') { |v| roots << File.expand_path(v) }
      parser.on('--projects PATH', 'トランスクリプトの置き場 (既定: ~/.claude/projects)') { |v| options.projects = File.expand_path(v) }
      parser.on('--out DIR', '出力先 (既定: $SELF_REVIEW_ANALYSIS_HOME か ~/self-review-analysis)') { |v| options.out = File.expand_path(v) }
      parser.on('--machine NAME', 'マシン名 (既定: hostname)') { |v| options.machine = v }
      parser.on('--skip-transcripts', 'トランスクリプトを読まない') { options.skip_transcripts = true }
      parser.on('--force', '出力先が git 管理下でも書き込む') { options.force = true }
      parser.on('-h', '--help') { puts parser; exit 0 }
    end.parse!(argv)

    options.roots = roots unless roots.empty?
    options.roots = options.roots.select { |root| Dir.exist?(root) }
    options
  end

  # root は basename でラベルにする (~/ghq → "ghq")。
  # 絶対パスを記録に残さないので、マシンをまたいでも同じキーで突き合わせられる
  def self.root_label(root) = File.basename(root)

  def self.find_logs(roots)
    logs = []
    roots.each do |root|
      Find.find(root) do |path|
        basename = File.basename(path)
        if File.directory?(path)
          Find.prune if PRUNE_DIRS.include?(basename)
        elsif basename == LOG_BASENAME && File.lstat(path).file?
          logs << [root, path]
        end
      end
    end
    logs.sort_by(&:last)
  end

  def self.repo_root_for(path, root) = repo_root_from(File.dirname(path), root)

  def self.repo_root_from(dir, root)
    while (dir == root || dir.start_with?("#{root}#{File::SEPARATOR}")) && dir != File.dirname(dir)
      return dir if File.exist?(File.join(dir, '.git'))

      dir = File.dirname(dir)
    end
    nil
  end

  # `.claude/artifacts/<branch...>/self-review.md` の <branch...> を復元する。
  def self.branch_from(path)
    parts = path.split(File::SEPARATOR)
    index = parts.each_cons(2).to_a.rindex { |a, b| a == '.claude' && b == 'artifacts' }
    return nil if index.nil?

    parts[(index + 2)..-2].join('/')
  end

  def self.git(repo_root, *args)
    stdout, _stderr, status = Open3.capture3('git', '-C', repo_root, *args)
    status.success? ? stdout : nil
  end

  def self.commit_exists?(repo_root, revision)
    return false if revision.nil? || revision.start_with?('-')

    !git(repo_root, 'cat-file', '-e', "#{revision}^{commit}").nil?
  end

  def self.numstat_summary(output)
    files = 0
    doc_lines = 0
    code_lines = 0
    binary_files = 0

    output.to_s.each_line do |line|
      added, deleted, path = line.chomp.split("\t", 3)
      next if path.nil?

      files += 1
      if added == '-' || deleted == '-'
        binary_files += 1
        next
      end

      lines = added.to_i + deleted.to_i
      if DOC_EXTENSIONS.include?(File.extname(path).downcase) || path.start_with?('docs/')
        doc_lines += lines
      else
        code_lines += lines
      end
    end

    { 'files' => files, 'doc_lines' => doc_lines, 'code_lines' => code_lines, 'binary_files' => binary_files }
  end

  # 変更規模。ブランチが消えている run では 基準コミット..ブランチ を測れないので、
  # ログに残った修正コミットの合計で代用する
  def self.diff_stats(repo_root, base, branch, commits)
    return { 'source' => 'no-repo' } if repo_root.nil?
    return { 'source' => 'no-base-recorded' } if base.nil?
    return { 'source' => 'base-not-in-repo' } unless commit_exists?(repo_root, base)

    [branch, "origin/#{branch}"].compact.each do |ref|
      next unless commit_exists?(repo_root, ref)
      next if git(repo_root, 'merge-base', '--is-ancestor', base, ref).nil?

      output = git(repo_root, 'diff', '--numstat', "#{base}..#{ref}", '--')
      next if output.nil?

      return numstat_summary(output).merge('source' => 'base..branch', 'ref' => ref)
    end

    resolvable = commits.uniq.select { |commit| commit_exists?(repo_root, commit) }
    return { 'source' => 'unresolved' } if resolvable.empty?

    merged = resolvable.map { |commit| git(repo_root, 'show', '--numstat', '--format=', commit).to_s }.join
    numstat_summary(merged).merge('source' => 'fix-commits', 'commits' => resolvable.size)
  end

  def self.round_record(round)
    {
      'number' => round.number,
      'started_at' => round.started_at&.iso8601,
      'started_at_raw' => round.started_at_raw,
      'suite' => round.suite,
      'reviewers' => round.reviewers.map { |r| { 'group' => r.group, 'model' => r.model, 'verdict' => r.verdict } },
      'finding_count' => round.findings.size,
      'severity_counts' => count_by(round.findings, &:severity),
      'category_counts' => count_by(round.findings, &:category),
      'action_counts' => count_by(round.findings, &:action_kind),
    }
  end

  def self.count_by(items, &block)
    items.group_by(&block).transform_values(&:size).transform_keys { |key| key || 'none' }
  end

  def self.collect_logs(options, io)
    runs = []
    findings = []
    warnings = []
    bundle = +''

    find_logs(options.roots).each do |root, path|
      label = root_label(root)
      repo_root = repo_root_for(path, root)
      repo = repo_key(repo_root, root)
      repo_group = repo.sub(%r{/\.claude/worktrees/[^/]+\z}, '')
      branch = branch_from(path)
      log_path = File.join(label, relative(path, root))
      content = File.read(path)
      result = SelfReviewLog.parse(content, source: log_path)

      bundle << "\n\n# === #{options.machine} | #{repo} | branch: #{branch} | #{log_path} ===\n\n"
      bundle << content

      warnings.concat(result.warnings.map { |w| w.merge(machine: options.machine, repo: repo, branch: branch) })

      result.runs.each do |run|
        run_id = "#{options.machine}:#{log_path}##{run.index}"
        base = base_commit(run, result.preamble)
        commits = run.rounds.flat_map { |round| round.findings.filter_map(&:commit) }

        runs << {
          'run_id' => run_id,
          'machine' => options.machine,
          'repo' => repo,
          'repo_group' => repo_group,
          'branch' => branch,
          'log_path' => log_path,
          'run_index' => run.index,
          'started_at' => run.started_at&.iso8601,
          'started_at_raw' => run.started_at_raw,
          'base_commit' => base,
          'round_count' => run.rounds.size,
          'finding_count' => run.rounds.sum { |round| round.findings.size },
          'rounds' => run.rounds.map { |round| round_record(round) },
          'diff' => diff_stats(repo_root, base, branch, commits),
        }

        run.rounds.each do |round|
          round.findings.each do |finding|
            findings << {
              'run_id' => run_id,
              'machine' => options.machine,
              'repo' => repo,
              'repo_group' => repo_group,
              'branch' => branch,
              'round' => round.number,
              'severity' => finding.severity,
              'category' => finding.category,
              'raw_category' => finding.raw_category,
              'location' => finding.location,
              'note' => finding.note,
              'action' => finding.action,
              'action_kind' => finding.action_kind,
              'verification' => finding.verification,
              'commit' => finding.commit,
              'gate_first_round' => finding.gate_first_round,
              'models' => finding.models,
              'raw_models' => finding.raw_models,
              'withdrawn' => finding.withdrawn,
              'line' => finding.line,
            }
          end
        end
      end
    end

    io.puts "ログ: #{runs.size} run / #{findings.size} 指摘 / 警告 #{warnings.size} 件"
    [runs, findings, warnings, bundle]
  end

  # 基準コミットは run の見出し直下に書かれる。そこに無い run では、
  # ファイル冒頭の記述で代用する (run 見出しを持たない旧書式のログがこの経路に来る)。
  def self.base_commit(run, preamble)
    source = run.header.to_s.empty? ? preamble : run.header
    source[/基準コミット[:：]\s*`?([0-9a-f]{7,40})`?/, 1]
  end

  def self.relative(path, root)
    path == root ? '.' : path.delete_prefix("#{root}#{File::SEPARATOR}")
  end

  # ~/ghq/github.com/pocke/foo → "ghq/github.com/pocke/foo"、~/dotfiles → "dotfiles"
  def self.repo_key(dir, root)
    return root_label(root) if dir.nil? || dir == root

    File.join(root_label(root), relative(dir, root))
  end

  def self.collect_transcripts(options, io)
    sessions = []
    agents = []
    events = []

    under_root = ->(cwd) { cwd && options.roots.any? { |root| cwd == root || cwd.start_with?("#{root}#{File::SEPARATOR}") } }

    Transcript.each_session(options.projects, cwd_filter: under_root) do |session|
      root = options.roots.find { |r| session.cwd == r || session.cwd.start_with?("#{r}#{File::SEPARATOR}") }
      # リポジトリのサブディレクトリで起動したセッションは cwd がリポジトリと一致しない。
      # ログ側は .git まで遡ってキーを作るので、こちらも同じ位置まで遡らないと突合しない
      repo = repo_key(repo_root_from(session.cwd, root) || session.cwd, root)
      repo_group = repo.sub(%r{/\.claude/worktrees/[^/]+\z}, '')

      sessions << {
        'machine' => options.machine,
        'session_id' => session.session_id,
        'repo' => repo,
        'repo_group' => repo_group,
        'branches' => session.git_branches,
        'started_at' => session.started_at&.iso8601,
        'ended_at' => session.ended_at&.iso8601,
        'duration_s' => duration(session),
        'message_count' => session.message_count,
        'total_cost_usd' => session.total_cost_usd,
        'usage_by_model' => session.usage_by_model,
        'agent_count' => session.agents.size,
        'inline_sidechain' => session.inline_sidechain,
        'version' => session.version,
      }

      session.agents.each do |agent|
        agents << {
          'machine' => options.machine,
          'session_id' => session.session_id,
          'repo' => repo,
          'repo_group' => repo_group,
          'branch' => agent.git_branch,
          'agent_id' => agent.agent_id,
          'agent_type' => agent.agent_type,
          'description' => agent.description,
          'model_requested' => agent.model_requested,
          'models_observed' => agent.usage_by_model.keys,
          'spawn_depth' => agent.spawn_depth,
          'started_at' => agent.started_at&.iso8601,
          'ended_at' => agent.ended_at&.iso8601,
          'duration_s' => duration(agent),
          'message_count' => agent.message_count,
          'usage_by_model' => agent.usage_by_model,
        }
      end

      session.usage_events.each do |event|
        events << event.merge('machine' => options.machine, 'session_id' => session.session_id)
      end
    end

    io.puts "トランスクリプト: #{sessions.size} セッション / #{agents.size} sub agent"
    [sessions, agents, events]
  end

  def self.duration(holder)
    return nil if holder.started_at.nil? || holder.ended_at.nil?

    (holder.ended_at - holder.started_at).round(1)
  end

  def self.write_jsonl(path, records)
    OutputGuard.open(path) do |file|
      records.each { |record| file.puts(JSON.generate(record)) }
    end
  end

  def self.run(argv, io: $stdout)
    options = parse_options(argv)
    abort '探索するディレクトリが 1 つも無い。--root で指定する。' if options.roots.empty?
    abort OutputGuard.invalid_machine(options.machine) if OutputGuard.invalid_machine(options.machine)

    out_dir = File.join(options.out, 'collected', options.machine)
    if !options.force && (refusal = OutputGuard.refusal(out_dir))
      abort <<~MESSAGE
        #{refusal}
        集めたログはレビュー対象リポジトリの本文をそのまま含むので、コミットできる場所には置かない。
        別の場所を --out で指定する。
      MESSAGE
    end
    OutputGuard.prepare!(out_dir)

    runs, findings, warnings, bundle = collect_logs(options, io)
    sessions, agents, events = options.skip_transcripts ? [[], [], []] : collect_transcripts(options, io)

    write_jsonl(File.join(out_dir, 'runs.jsonl'), runs)
    write_jsonl(File.join(out_dir, 'findings.jsonl'), findings)
    write_jsonl(File.join(out_dir, 'warnings.jsonl'), warnings)
    write_jsonl(File.join(out_dir, 'sessions.jsonl'), sessions)
    write_jsonl(File.join(out_dir, 'agents.jsonl'), agents)
    write_jsonl(File.join(out_dir, 'usage_events.jsonl'), events)
    OutputGuard.write(File.join(out_dir, 'bundle.md'), NOTICE + bundle)
    OutputGuard.write(File.join(out_dir, 'meta.json'), JSON.pretty_generate({
      'machine' => options.machine,
      'collected_at' => Time.now.iso8601,
      'roots' => options.roots.map { |root| root_label(root) },
      'skip_transcripts' => options.skip_transcripts,
      'counts' => {
        'runs' => runs.size, 'findings' => findings.size, 'warnings' => warnings.size,
        'sessions' => sessions.size, 'agents' => agents.size, 'usage_events' => events.size
      },
    }))

    io.puts "出力: #{out_dir}"
    io.puts '別マシンのぶんは同じ <out>/collected/ の下に <machine> ディレクトリごとコピーする。'
  end
end

Collect.run(ARGV) if $PROGRAM_NAME == __FILE__
