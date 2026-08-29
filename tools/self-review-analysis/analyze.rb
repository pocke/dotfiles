#!/usr/bin/env ruby
# frozen_string_literal: true

# collect.rb が集めたものを 1 か所で集計する。
#
#   ruby analyze.rb [--in DIR] [--out DIR]
#
# 出力 (既定では <in>/analysis/):
#   report.md    ラウンド数・区分・モデル別の指摘・待ち時間・トークンの集計
#   summary.json 同じ数字の機械可読版
#   triage.md    棚卸しの対象 (ゲートで記録のみ / 見送り / 打ち切り / 分類できなかった対応)
#
# 判断はしない。数える。判断は README の手順でエージェントとユーザーが行う。

require 'optparse'
require 'json'
require 'time'
require 'fileutils'
require_relative 'lib/dataset'
require_relative 'lib/self_review_log'
require_relative 'lib/transcript'
require_relative 'lib/model_pricing'
require_relative 'lib/output_guard'

module Analyze
  SEVERITIES = %w[must-fix should-fix nit question].freeze
  TRIAGE_KINDS = %w[gated dropped aborted mixed other].freeze
  NOTICE = "<!-- ローカル限定。private リポジトリのレビュー本文とリポジトリ名を含むので、リポジトリにも Issue にも貼らない -->\n\n"

  module_function

  def parse_options(argv)
    options = {
      in: ENV['SELF_REVIEW_ANALYSIS_HOME'] || File.join(Dir.home, 'self-review-analysis'),
      out: nil,
      force: false,
    }
    OptionParser.new do |parser|
      parser.banner = 'Usage: ruby analyze.rb [options]'
      parser.on('--in DIR', 'collect.rb の出力先 (既定: $SELF_REVIEW_ANALYSIS_HOME か ~/self-review-analysis)') { |v| options[:in] = File.expand_path(v) }
      parser.on('--out DIR', 'レポートの書き出し先 (既定: <in>/analysis)') { |v| options[:out] = File.expand_path(v) }
      parser.on('--force', '出力先が git 管理下でも書き込む') { options[:force] = true }
      parser.on('-h', '--help') { puts parser; exit 0 }
    end.parse!(argv)
    options[:out] ||= File.join(options[:in], 'analysis')
    options
  end

  # --- 出力の小道具 ------------------------------------------------------

  def table(header, rows)
    return "(該当なし)\n" if rows.empty?

    lines = ["| #{header.join(' | ')} |", "| #{header.map { '---' }.join(' | ')} |"]
    rows.each { |row| lines << "| #{row.map { |cell| cell.to_s.gsub('|', '\\|') }.join(' | ')} |" }
    lines.join("\n") + "\n"
  end

  def percent(part, whole) = whole.zero? ? '-' : "#{(100.0 * part / whole).round(1)}%"

  def minutes(seconds) = seconds.nil? ? '-' : (seconds / 60.0).round(1)

  def usd(amount) = amount.nil? ? '-' : format('$%.2f', amount)

  def tokens(count)
    return '-' if count.nil?
    return "#{(count / 1_000_000.0).round(2)}M" if count >= 1_000_000

    "#{(count / 1000.0).round(1)}k"
  end

  def median(values)
    return nil if values.empty?

    sorted = values.sort
    middle = sorted.size / 2
    sorted.size.odd? ? sorted[middle] : (sorted[middle - 1] + sorted[middle]) / 2.0
  end

  def count_by(items, &block) = items.group_by(&block).transform_values(&:size).transform_keys { |key| key || 'none' }

  def sort_counts(counts) = counts.sort_by { |key, value| [-value, key.to_s] }

  # 同じセッションには実装用の sub agent も混ざるので、レビュー用だけを数える。
  def review_agents(run) = run['agents'].select { |agent| agent['review'] }

  def round1_agents(run) = review_agents(run).select { |agent| agent['round'] == 1 }

  def run_label(data, run_id)
    run = data.runs.find { |candidate| candidate['run_id'] == run_id }
    return run_id if run.nil?

    "#{short_repo(run['repo_group'])} #{run['branch']}"
  end

  def short_repo(name) = name.to_s.sub(%r{\Aghq/github\.com/}, '')

  # ログの日時はそれを書いたマシンの時間帯で記録される。report と triage.md で同じ run が
  # 違う時刻に見えないよう、表示はすべてこのマシンの時間帯に直す。
  # `Time#localtime` は Time を書き換えるので、他の節が同じオブジェクトを読むと表示が変わる
  def local_time(time, format = '%Y-%m-%dT%H:%M') = time&.getlocal&.strftime(format)

  # --- 母集団 ------------------------------------------------------------

  # ラウンド1に 2 モデル以上を並べた run。起動したモデルはレビュアー表から読む。
  # 指摘のモデル列から数えると、指摘を 1 件も出さなかったモデルが「参加していない」ことになり、
  # そのモデルのユニーク率の母集団から run が丸ごと落ちる。
  def multi_model_runs(data)
    data.runs.select { |run| round1_models(data, run).size >= 2 }
  end

  def round1_models(data, run)
    round = run['rounds'].find { |candidate| candidate['number'] == 1 }
    from_reviewers = round&.dig('reviewers')&.filter_map { |reviewer| Dataset.short_model(reviewer['model']) }&.uniq
    return from_reviewers if from_reviewers && !from_reviewers.empty?

    data.findings_for(run['run_id']).select { |finding| finding['round'] == 1 }.flat_map { |finding| finding['models'] }.uniq
  end

  # --- 各節 --------------------------------------------------------------

  def section_scope(data, summary)
    runs = data.runs
    with_agents = runs.count { |run| !review_agents(run).empty? }
    duplicates = data.duplicate_logs

    summary['scope'] = {
      'machines' => data.machines,
      'collected_at' => data.meta.transform_values { |meta| meta['collected_at'] },
      'skip_transcripts' => data.meta.transform_values { |meta| meta['skip_transcripts'] },
      'runs' => runs.size,
      'rounds' => runs.sum { |run| run['round_count'] },
      'findings' => data.findings.size,
      'repos' => runs.map { |run| run['repo_group'] }.uniq.size,
      'period' => [runs.filter_map { |run| run['started_time'] }.min&.iso8601, runs.filter_map { |run| run['started_time'] }.max&.iso8601],
      'period_local' => [local_time(runs.filter_map { |run| run['started_time'] }.min, '%Y-%m-%dT%H:%M:%S'), local_time(runs.filter_map { |run| run['started_time'] }.max, '%Y-%m-%dT%H:%M:%S')],
      'runs_with_review_agents' => with_agents,
      'parse_warnings' => data.warnings.size,
      'diff_sources' => count_by(runs) { |run| run.dig('diff', 'source') },
      'match_kinds' => count_by(runs) { |run| run['match_kind'] },
      'duplicate_logs' => duplicates,
    }

    out = +"## 1. 集めたもの\n\n"
    out << "- マシン: #{data.machines.map { |machine| "#{machine} (#{data.meta.dig(machine, 'collected_at')})" }.join(', ')}\n"
    out << "- run #{runs.size} 本 / ラウンド #{summary['scope']['rounds']} / 指摘 #{data.findings.size} 件 / リポジトリ #{summary['scope']['repos']} 個\n"
    out << "- 期間: #{summary['scope']['period_local'].compact.join(' 〜 ')} (このマシンの時間帯)\n"
    out << "- レビュー用 sub agent を取れた run: #{with_agents} / #{runs.size} (#{percent(with_agents, runs.size)})。残りは所要時間とトークンの集計に入らない\n"
    out << "- ログのパース警告: #{data.warnings.size} 件 (report を読む前に warnings.jsonl を見る)\n"
    skipped = data.meta.select { |_, meta| meta['skip_transcripts'] }.keys
    out << "- トランスクリプトを集めていないマシン: #{skipped.join(', ')} (その run はコスト 0 として集計に入る)\n" unless skipped.empty?
    unless duplicates.empty?
      out << "- **同じログを 2 台で集めている: #{duplicates.size} 件**。run も指摘も二重に数えられている。片方の collected を消して集計し直す\n"
      out << table(%w[log_path run machines], duplicates.map { |dup| [dup['log_path'], dup['run_index'], dup['machines'].join(', ')] })
    end

    out << "\n変更規模の求め方の内訳 (`base..branch` 以外は代用値):\n\n"
    out << table(%w[source 件数], sort_counts(summary['scope']['diff_sources']))
    out << "\nセッションの突き合わせ方 (branch: 同一マシン同一ブランチ、cross-machine: 別マシンのトランスクリプト):\n\n"
    out << table(%w[match_kind 件数], sort_counts(summary['scope']['match_kinds']))
    out << "\n"
  end

  def section_runs(data, summary)
    rows = []
    records = []

    data.runs.sort_by { |run| run['started_time'] || Time.at(0) }.each do |run|
      findings = data.findings_for(run['run_id'])
      severities = count_by(findings) { |finding| finding['severity'] }
      agents = review_agents(run)
      # レビュー用の sub agent が 1 体も取れなかった run は、コストが 0 なのではなく測れていない
      measured = !agents.empty?
      cost = measured ? data.cost_of(agents) : { usd: nil, unpriced: [] }
      parent = data.parent_usage(run)
      parent_cost = run['sessions'].empty? ? { usd: nil, unpriced: [] } : ModelPricing.total_cost(parent)

      records << {
        'run_id' => run['run_id'],
        'repo' => run['repo_group'],
        'branch' => run['branch'],
        'started_at' => run['started_at'],
        'rounds' => run['round_count'],
        'findings' => findings.size,
        'severities' => severities,
        'diff' => run['diff'],
        'span_s' => run_span(data, run),
        'round1_models' => round1_models(data, run),
        'match_kind' => run['match_kind'],
        'review_agents' => agents.size,
        'agents_in_window' => run['agents'].size,
        'agent_tokens' => measured ? data.tokens_of(agents) : nil,
        'agent_cost_usd' => cost[:usd],
        'parent_tokens' => run['sessions'].empty? ? nil : usage_tokens(parent),
        'parent_cost_usd' => parent_cost[:usd],
      }

      rows << [
        short_repo(run['repo_group']),
        run['branch'].to_s[0, 28],
        local_time(run['started_time']) || '-',
        run['round_count'],
        findings.size,
        SEVERITIES.map { |severity| severities[severity].to_i }.join('/'),
        diff_cell(run['diff']),
        minutes(records.last['span_s']),
        run['agents'].empty? ? '-' : "#{agents.size}/#{run['agents'].size}",
        tokens(records.last['agent_tokens']),
        usd(cost[:usd]),
        usd(parent_cost[:usd]),
      ]
    end

    summary['runs'] = records
    out = +"## 2. run の一覧\n\n"
    out << "指摘の内訳は must-fix/should-fix/nit/question の順。変更行は doc+code で、`*` は代用値 (1 節)。\n"
    out << "agent 列は レビュー用/その時間帯の全 sub agent。`$agent` は sub agent、`$親` は依頼元セッションの推論ぶん。\n\n"
    out << table(['repo', 'branch', '開始', 'R', '指摘', 'm/s/n/q', '変更行', '経過(分)', 'agent', 'token', '$agent', '$親'], rows)
    out << "\n"
  end

  def usage_tokens(usage_by_model)
    usage_by_model.values.sum { |usage| Transcript::USAGE_KEYS.sum { |key| usage[key].to_i } }
  end

  def diff_cell(diff)
    return '-' if diff.nil? || diff['files'].nil?

    "#{diff['doc_lines']}+#{diff['code_lines']}#{diff['source'] == 'base..branch' ? '' : '*'}"
  end

  def run_span(data, run)
    ends = review_agents(run).filter_map { |agent| Dataset.time(agent['ended_at']) }
    return nil if ends.empty? || run['started_time'].nil?

    (ends.max - run['started_time']).round(1)
  end

  def section_repos(data, summary)
    rows = []
    records = {}

    data.runs.group_by { |run| run['repo_group'] }.sort_by { |name, _| name }.each do |name, runs|
      findings = runs.flat_map { |run| data.findings_for(run['run_id']) }
      measured = runs.select { |run| run.dig('diff', 'files') }
      doc_lines = measured.sum { |run| run.dig('diff', 'doc_lines').to_i }
      code_lines = measured.sum { |run| run.dig('diff', 'code_lines').to_i }
      categories = count_by(findings.select { |finding| finding['category'] }) { |finding| finding['category'] }

      records[name] = {
        'runs' => runs.size,
        'avg_rounds' => (runs.sum { |run| run['round_count'] }.to_f / runs.size).round(2),
        'findings_per_run' => (findings.size.to_f / runs.size).round(1),
        'doc_lines' => doc_lines,
        'code_lines' => code_lines,
        'runs_without_diff' => runs.size - measured.size,
        'categories' => categories,
      }
      rows << [
        short_repo(name),
        runs.size,
        records[name]['avg_rounds'],
        records[name]['findings_per_run'],
        change_cell(records[name]),
        SelfReviewLog::CATEGORIES.map { |category| categories[category].to_i }.join('/'),
      ]
    end

    summary['repos'] = records
    out = +"## 3. リポジトリ別の傾向\n\n"
    out << "区分は #{SelfReviewLog::CATEGORIES.join('/')} の順。変更行は測れた run だけの合計。\n\n"
    out << table(['repo', 'run', '平均ラウンド', '指摘/run', '変更行 doc+code', '区分'], rows)
    out << "\n"
  end

  def change_cell(record)
    unmeasured = record['runs_without_diff'].positive? ? " (#{record['runs_without_diff']} 本は測れず)" : ''
    return "ドキュメントのみ#{unmeasured}" if record['code_lines'].zero? && record['doc_lines'].positive?

    "#{record['doc_lines']}+#{record['code_lines']}#{unmeasured}"
  end

  def section_models(data, summary)
    target_runs = multi_model_runs(data)
    priced_runs = target_runs.reject { |run| round1_agents(run).empty? }
    target_ids = target_runs.map { |run| run['run_id'] }
    priced_ids = priced_runs.map { |run| run['run_id'] }

    round1 = data.findings.select { |finding| finding['round'] == 1 && target_ids.include?(finding['run_id']) }
    attributed = round1.reject { |finding| finding['models'].empty? }
    models = attributed.flat_map { |finding| finding['models'] }.uniq.sort

    per_model = models.to_h do |model|
      mine = attributed.select { |finding| finding['models'].include?(model) }
      unique = mine.select { |finding| finding['models'] == [model] }
      priced = unique.select { |finding| priced_ids.include?(finding['run_id']) }
      [model, {
        'findings' => mine.size,
        'unique' => unique.size,
        'unique_rate' => mine.empty? ? nil : (100.0 * unique.size / mine.size).round(1),
        'unique_in_priced_runs' => priced.size,
        'severities' => count_by(mine) { |finding| finding['severity'] },
        'unique_severities' => count_by(unique) { |finding| finding['severity'] },
      }]
    end

    overlap = count_by(attributed) { |finding| finding['models'].size }
    agents = priced_runs.flat_map { |run| round1_agents(run) }
    per_agent_model = agents.group_by { |agent| agent['effective_model'] }

    agent_rows = per_agent_model.sort_by { |model, _| model.to_s }.map do |model, model_agents|
      durations = model_agents.filter_map { |agent| agent['duration_s'] }
      cost = data.cost_of(model_agents)
      unique = per_model.dig(model, 'unique_in_priced_runs').to_i
      [
        model,
        model_agents.size,
        median(durations)&.round(1),
        durations.max&.round(1),
        tokens(data.tokens_of(model_agents)),
        usd(cost[:usd]),
        unique.positive? ? usd(cost[:usd] / unique) : '-',
      ]
    end

    summary['round1_models'] = {
      'multi_model_runs' => target_ids,
      'priced_runs' => priced_ids,
      'attributed_findings' => attributed.size,
      'unattributed_findings' => round1.size - attributed.size,
      'per_model' => per_model,
      'overlap' => overlap,
      'per_agent_model' => per_agent_model.transform_values do |model_agents|
        { 'agents' => model_agents.size,
          'median_s' => median(model_agents.filter_map { |agent| agent['duration_s'] })&.round(1),
          'max_s' => model_agents.filter_map { |agent| agent['duration_s'] }.max,
          'tokens' => data.tokens_of(model_agents),
          'cost_usd' => data.cost_of(model_agents)[:usd] }
      end,
      'group_by_model' => group_by_model(data, target_runs),
    }

    out = +"## 4. ラウンド1のマルチモデル化\n\n"
    out << "ラウンド1に 2 モデル以上を並べた run #{target_runs.size} 本 / 全 #{data.runs.size} 本が対象。\n"
    out << "そのうちモデルが記録された指摘 #{attributed.size} 件を数える (記録の無い #{round1.size - attributed.size} 件は除外)。\n\n"
    out << table(['モデル', '指摘', 'ユニーク', 'ユニーク率', 'must/should/nit/question', 'ユニークの内訳'],
                 per_model.map do |model, stat|
                   [model, stat['findings'], stat['unique'], "#{stat['unique_rate']}%",
                    SEVERITIES.map { |severity| stat['severities'][severity].to_i }.join('/'),
                    SEVERITIES.map { |severity| stat['unique_severities'][severity].to_i }.join('/')]
                 end)
    out << "\n同じ指摘を何モデルが出したか:\n\n"
    out << table(['モデル数', '件数', '割合'], sort_counts(overlap).map { |count, number| [count, number, percent(number, attributed.size)] })

    out << "\nラウンド1の sub agent。**トランスクリプトを突き合わせられた #{priced_runs.size} 本のみ**が対象で、\n"
    out << "最後の列の分母もこの #{priced_runs.size} 本のユニーク指摘に揃えてある (上の表は #{target_runs.size} 本ぶん)。\n\n"
    out << table(['モデル', '体数', '所要 中央値(s)', '所要 最大(s)', 'token', '概算$', 'ユニーク指摘1件あたり$'], agent_rows)

    out << "\n観点グループごとに何体起動したか (モデルの担当スロット数。ユニーク率はこれで正規化して読む):\n\n"
    groups = summary['round1_models']['group_by_model']
    out << table(['観点グループ'] + models, groups.map { |group, counts| [group[0, 30]] + models.map { |model| counts[model].to_i } })
    out << "\n"
  end

  # ログの指摘テーブルには観点の列が無く、ラウンド1では観点をまたいで指摘を 1 件にまとめる決まりなので、
  # 「どの観点をどのモデルが拾ったか」はログから復元できない。分かるのは起動したスロット数まで。
  #
  # 観点グループの名前は run ごとの自由記述なので、そのまま並べると 40 行を超えて読めない。
  # SKILL.md がモデルの割り当てを変えているセキュリティだけを分けて数える。
  def group_by_model(data, runs)
    counts = Hash.new { |hash, key| hash[key] = Hash.new(0) }
    runs.each do |run|
      round = run['rounds'].find { |candidate| candidate['number'] == 1 }
      round&.dig('reviewers')&.each do |reviewer|
        model = Dataset.short_model(reviewer['model'])
        next if model.nil?

        bucket = reviewer['group'].to_s.include?('セキュリティ') ? 'セキュリティ' : 'それ以外'
        counts[bucket][model] += 1
      end
    end
    counts
  end

  def section_convergence(data, summary)
    multi_ids = multi_model_runs(data).map { |run| run['run_id'] }
    by_round = data.findings.group_by { |finding| finding['round'] }

    cross = by_round.sort.map do |round, items|
      counts = count_by(items.select { |finding| finding['category'] }) { |finding| finding['category'] }
      new_must = items.count { |finding| finding['category'] == 'new' && finding['severity'] == 'must-fix' }
      gated = items.count { |finding| finding['action_kind'] == 'gated' }
      categories = round == 1 ? '-' : SelfReviewLog::CATEGORIES.map { |category| counts[category].to_i }.join('/')
      [round, items.size, categories, round == 1 ? '-' : new_must, gated]
    end

    gated_per_run = data.runs.map { |run| data.findings_for(run['run_id']).count { |finding| finding['action_kind'] == 'gated' } }

    summary['convergence'] = {
      'round_distribution' => count_by(data.runs) { |run| run['round_count'] },
      'gated_total' => gated_per_run.sum,
      'gated_per_run_median' => median(gated_per_run),
      'runs_without_gated' => gated_per_run.count(&:zero?),
      'multi_vs_single' => %w[multi single].to_h do |kind|
        runs = data.runs.select { |run| multi_ids.include?(run['run_id']) == (kind == 'multi') }
        findings = runs.flat_map { |run| data.findings_for(run['run_id']) }
        [kind, {
          'runs' => runs.size,
          'avg_rounds' => runs.empty? ? nil : (runs.sum { |run| run['round_count'] }.to_f / runs.size).round(2),
          'new_must_fix_after_round1' => findings.count { |finding| finding['round'] > 1 && finding['category'] == 'new' && finding['severity'] == 'must-fix' },
          'fresh_surface_share' => share(findings.select { |finding| finding['round'] > 1 }, 'fresh-surface'),
        }]
      end,
      'by_round' => by_round.transform_values do |items|
        {
          'findings' => items.size,
          'categories' => count_by(items.select { |finding| finding['category'] }) { |finding| finding['category'] },
          'severities' => count_by(items) { |finding| finding['severity'] },
          'new_must_fix' => items.count { |finding| finding['category'] == 'new' && finding['severity'] == 'must-fix' },
        }
      end,
    }

    out = +"## 5. 収束性\n\n"
    out << "ラウンドごとの内訳。区分は #{SelfReviewLog::CATEGORIES.join('/')} の順 (ラウンド1には区分が付かない)。\n\n"
    out << table(['ラウンド', '指摘', '区分', 'new の must-fix', 'ゲートで記録のみ'], cross)
    out << "\nrun のラウンド数の分布:\n\n"
    out << table(['ラウンド数', 'run 数'], summary['convergence']['round_distribution'].sort.map { |rounds, count| [rounds, count] })
    out << "\nマルチモデル化の前後 (ラウンド1に 2 モデル以上を並べたかで分ける):\n\n"
    out << table(['ラウンド1', 'run', '平均ラウンド', 'ラウンド2以降の new must-fix', 'fresh-surface の割合'],
                 summary['convergence']['multi_vs_single'].map do |kind, stat|
                   [kind == 'multi' ? '2モデル以上' : '1モデル', stat['runs'], stat['avg_rounds'], stat['new_must_fix_after_round1'], stat['fresh_surface_share']]
                 end)
    out << "\n- ゲートで記録のみにした指摘: 合計 #{gated_per_run.sum} 件 / run あたり中央値 #{median(gated_per_run)} 件 / 0 件の run が #{gated_per_run.count(&:zero?)} 本\n"
    out << "\n"
  end

  def share(findings, category)
    return '-' if findings.empty?

    percent(findings.count { |finding| finding['category'] == category }, findings.size)
  end

  def section_waiting(data, summary)
    per_round = []

    data.runs.each do |run|
      run['rounds'].each do |round|
        agents = review_agents(run).select { |agent| agent['round'] == round['number'] }
        next if agents.empty?

        durations = agents.filter_map { |agent| agent['duration_s'] }.sort
        slowest = agents.max_by { |agent| agent['duration_s'].to_f }
        per_round << {
          'run_id' => run['run_id'], 'round' => round['number'], 'agents' => agents.size,
          'span_s' => data.round_span(run, round), 'max_s' => durations.last, 'median_s' => median(durations),
          'slowest_model' => slowest['effective_model'],
          'without_model' => without_model_max(agents),
        }
      end
    end

    round1 = per_round.select { |entry| entry['round'] == 1 }
    later = per_round.reject { |entry| entry['round'] == 1 }

    # モデルを 1 つ外したときに縮む待ち時間。ラウンド1は並列なので、
    # そのラウンドの待ちは「最遅の 1 体」で決まる。外すモデルの全体を消してから測り直す
    savings = Hash.new(0.0)
    counts = Hash.new(0)
    round1.each do |entry|
      entry['without_model'].each do |model, remaining_max|
        next if remaining_max.nil? || entry['max_s'].nil?

        savings[model] += entry['max_s'] - remaining_max
        counts[model] += 1 if entry['max_s'] > remaining_max
      end
    end

    suite_jumps = suite_comparison(data)
    flagged = suite_jumps.select { |jump| jump['flagged'] }

    summary['waiting'] = {
      'per_round' => per_round,
      'round1_slowest_model' => count_by(round1) { |entry| entry['slowest_model'] },
      'savings_by_dropping_model_s' => savings.transform_values { |value| value.round(1) },
      'rounds_where_model_was_the_tail' => counts,
      'suite' => suite_jumps,
    }

    out = +"## 6. 待ち時間\n\n"
    out << "ラウンドの待ち時間は、そのラウンドで起動した sub agent のうち一番遅いものの所要時間で決まる。\n\n"
    out << table(['ラウンド', '本数', '最遅 中央値(分)', '最遅 最大(分)', '中央値の中央値(分)'], [
      ['ラウンド1 (並列)', round1.size, minutes(median(round1.filter_map { |entry| entry['max_s'] })), minutes(round1.filter_map { |entry| entry['max_s'] }.max), minutes(median(round1.filter_map { |entry| entry['median_s'] }))],
      ['ラウンド2以降', later.size, minutes(median(later.filter_map { |entry| entry['max_s'] })), minutes(later.filter_map { |entry| entry['max_s'] }.max), minutes(median(later.filter_map { |entry| entry['median_s'] }))],
    ])

    out << "\nラウンド1でそのモデルを外したときに縮む待ち時間 (対象 #{round1.size} ラウンド):\n\n"
    out << table(['外すモデル', '縮む合計(分)', '1ラウンドあたり(分)', '最遅だったラウンド数'],
                 savings.sort_by { |_, value| -value }.map do |model, value|
                   [model, minutes(value), minutes(round1.empty? ? nil : value / round1.size), counts[model]]
                 end)

    out << "\nスイートの実行時間。SKILL.md の閾値 (ラウンド1の 2 倍以上、または 60 秒以上の増加) に当たったものだけ挙げる。\n"
    out << "同じ値を再掲した `(再測なし)` のラウンドは比較から除いてある。比較 #{suite_jumps.size} 組のうち #{flagged.size} 組。\n\n"
    out << table(['run', 'ラウンド', 'ラウンド1(s)', 'このラウンド(s)', '倍率', 'テスト数'], flagged.map do |jump|
      [run_label(data, jump['run_id']), jump['round'], jump['base_seconds'], jump['seconds'], jump['ratio'], "#{jump['base_tests']}→#{jump['tests']}"]
    end)
    out << "\n"
  end

  # そのモデルの sub agent を全部外したときの、そのラウンドの最遅所要時間
  def without_model_max(agents)
    models = agents.filter_map { |agent| agent['effective_model'] }.uniq
    models.to_h do |model|
      remaining = agents.reject { |agent| agent['effective_model'] == model }.filter_map { |agent| agent['duration_s'] }
      [model, remaining.max]
    end
  end

  def suite_comparison(data)
    data.runs.flat_map do |run|
      base = run['rounds'].find { |round| round['number'] == 1 }&.dig('suite')
      next [] if base.nil?

      run['rounds'].filter_map do |round|
        suite = round['suite']
        next if suite.nil? || round['number'] == 1
        next if suite['status'].to_s.include?('再測なし')

        ratio = base['seconds'].to_f.zero? ? nil : (suite['seconds'] / base['seconds']).round(2)
        {
          'run_id' => run['run_id'], 'round' => round['number'],
          'base_seconds' => base['seconds'], 'seconds' => suite['seconds'],
          'base_tests' => base['tests'], 'tests' => suite['tests'], 'ratio' => ratio,
          'flagged' => (ratio && ratio >= 2) || (suite['seconds'] - base['seconds'] >= 60),
        }
      end
    end
  end

  def section_tokens(data, summary)
    round1 = data.runs.flat_map { |run| round1_agents(run) }
    later = data.runs.flat_map { |run| review_agents(run).select { |agent| agent['round'].to_i > 1 } }
    unassigned = data.runs.flat_map { |run| review_agents(run).select { |agent| agent['round'].nil? } }
    all_agents = data.runs.flat_map { |run| review_agents(run) }

    parent = Hash.new { |hash, key| hash[key] = Transcript.blank_usage }
    data.runs.each { |run| data.parent_usage(run).each { |model, usage| Transcript.add_usage!(parent[model], usage) } }

    per_model_cost = round1.group_by { |agent| agent['effective_model'] }.transform_values do |agents|
      { 'agents' => agents.size, 'tokens' => data.tokens_of(agents), 'cost_usd' => data.cost_of(agents)[:usd] }
    end

    total = data.cost_of(all_agents)
    parent_cost = ModelPricing.total_cost(parent)

    summary['tokens'] = {
      'round1' => bucket(data, round1),
      'later_rounds' => bucket(data, later),
      'unassigned_rounds' => bucket(data, unassigned),
      'parent_sessions' => { 'tokens' => usage_tokens(parent), 'cost_usd' => parent_cost[:usd] },
      'per_round1_model' => per_model_cost,
      'total_agent_cost_usd' => total[:usd],
      'unpriced_models' => total[:unpriced],
      'priced_at' => ModelPricing::PRICED_AT,
      'price_check' => price_check(data),
    }

    out = +"## 7. トークンとコスト\n\n"
    out << "単価は #{ModelPricing::PRICED_AT} 時点。token はキャッシュ読みも足した総量なので、金額の比とは一致しない。\n\n"
    out << table(['区分', 'agent', 'token', '概算$'], [
      ['ラウンド1', round1.size, tokens(data.tokens_of(round1)), usd(data.cost_of(round1)[:usd])],
      ['ラウンド2以降', later.size, tokens(data.tokens_of(later)), usd(data.cost_of(later)[:usd])],
      ['ラウンド不明', unassigned.size, tokens(data.tokens_of(unassigned)), usd(data.cost_of(unassigned)[:usd])],
      ['sub agent 合計', all_agents.size, tokens(data.tokens_of(all_agents)), usd(total[:usd])],
      ['依頼元セッション', '-', tokens(usage_tokens(parent)), usd(parent_cost[:usd])],
    ])
    out << "\nラウンド1のモデル別:\n\n"
    out << table(['モデル', 'agent', 'token', '概算$'], per_model_cost.sort_by { |model, _| model.to_s }.map do |model, stat|
      [model, stat['agents'], tokens(stat['tokens']), usd(stat['cost_usd'])]
    end)

    check = summary['tokens']['price_check']
    out << "\n単価の検算 (セッションが記録した実費と、この単価表での再計算の差): "
    out << (check['sessions'].zero? ? "比較できるセッションなし\n" : "#{check['sessions']} セッションで #{usd(check['recorded_usd'])} 対 #{usd(check['computed_usd'])} (差 #{check['diff_percent']}%)\n")
    out << "単価が分からないモデル: #{total[:unpriced].join(', ')}\n" unless total[:unpriced].empty?
    out << "\n"
  end

  def bucket(data, agents)
    { 'agents' => agents.size, 'tokens' => data.tokens_of(agents), 'cost_usd' => data.cost_of(agents)[:usd] }
  end

  # セッションが記録した totalCostUSD と単価表の再計算を突き合わせる。
  # 単価が改定されるとここがずれるので、レポートの金額を信じてよいかの目安になる。
  def price_check(data)
    sessions = data.sessions.select { |session| session['total_cost_usd'] }
    recorded = sessions.sum { |session| session['total_cost_usd'] }
    computed = sessions.sum { |session| ModelPricing.total_cost(session['usage_by_model'] || {})[:usd] }
    {
      'sessions' => sessions.size,
      'recorded_usd' => recorded,
      'computed_usd' => computed,
      'diff_percent' => recorded.zero? ? nil : ((computed - recorded) / recorded * 100).round(2),
    }
  end

  def section_triage(data, summary)
    targets = data.findings.select { |finding| TRIAGE_KINDS.include?(finding['action_kind']) }
    conflicts = gate_conflicts(data)
    annotated = data.findings.select { |finding| finding['raw_category'] && finding['category'] && finding['raw_category'] != finding['category'] }

    summary['triage'] = {
      'counts' => count_by(targets) { |finding| finding['action_kind'] },
      'gate_conflicts' => conflicts,
      'annotated_categories' => annotated.map { |finding| { 'run_id' => finding['run_id'], 'round' => finding['round'], 'raw_category' => finding['raw_category'] } },
    }

    out = +"## 8. 棚卸しの対象\n\n"
    out << table(['対応', '件数'], sort_counts(summary['triage']['counts']))
    out << "\n- ゲートで記録のみにした指摘が、後のラウンドで carried-over として再提出された箇所: #{conflicts.size} 箇所"
    out << " (該当箇所ごとに 1 件。SKILL.md が優先順位を決めている must-fix への格上げは除く)\n"
    out << "- 区分に注記が付いた指摘 (`carried-over (ラウンド3で記録のみ)` など): #{annotated.size} 件\n"
    out << "- 全文は triage.md にある。同じ根のものをまとめる作業はそちらで行う\n\n"
    [out, triage_document(data, targets, conflicts)]
  end

  # ゲートの 2 つの規則 (carried-over は戻す / 記録のみは維持) が両方当たった実例を数える。
  # 同じ箇所が何ラウンドも再提出されると組み合わせで増えるので、(run, 該当箇所) で 1 件にする。
  def gate_conflicts(data)
    data.runs.flat_map do |run|
      findings = data.findings_for(run['run_id'])
      gated = findings.select { |finding| finding['action_kind'] == 'gated' && finding['location'] }
      gated.filter_map do |finding|
        reappeared = findings.select do |other|
          other['round'] > finding['round'] && other['location'] == finding['location'] &&
            other['category'] == 'carried-over' && other['severity'] != 'must-fix'
        end
        next if reappeared.empty?

        {
          'run_id' => run['run_id'], 'location' => finding['location'], 'gated_round' => finding['round'],
          'reappeared_rounds' => reappeared.map { |other| other['round'] }.uniq.sort,
        }
      end.uniq { |conflict| [conflict['run_id'], conflict['location']] }
    end
  end

  def triage_document(data, targets, conflicts)
    out = +"#{NOTICE}# 棚卸しワークシート\n\n"
    out << "対応が「ゲートで記録のみ」「見送り」「打ち切り」「扱いが割れたもの」「分類できなかったもの」の指摘を、\n"
    out << "run 横断で並べたもの。同じ根の指摘をまとめ、skill を直すもの / 個別の変更の問題 / 対応不要 に振り分ける。\n\n"

    out << "## ゲートの規則が競合した箇所\n\n"
    out << table(['run', '該当箇所', 'ゲートしたラウンド', '再提出されたラウンド'],
                 conflicts.map { |conflict| [run_label(data, conflict['run_id']), conflict['location'], conflict['gated_round'], conflict['reappeared_rounds'].join(',')] })

    targets.group_by { |finding| finding['run_id'] }.each do |run_id, findings|
      run = data.runs.find { |candidate| candidate['run_id'] == run_id }
      out << "\n## #{short_repo(run['repo_group'])} / #{run['branch']} (#{local_time(run['started_time'])})\n\n"
      out << "ログ: `#{run['log_path']}` run ##{run['run_index']}\n\n"
      findings.sort_by { |finding| [finding['round'], finding['severity'].to_s] }.each do |finding|
        out << "- [ ] R#{finding['round']} #{finding['severity']} #{finding['action_kind']} — #{finding['location']}\n"
        out << "  - 指摘: #{finding['note']}\n"
        out << "  - 対応: #{finding['action']}\n"
      end
    end
    out
  end

  def run(argv, io: $stdout)
    options = parse_options(argv)
    collected = File.join(options[:in], 'collected')
    abort "#{collected} が無い。先に collect.rb を走らせる。" unless Dir.exist?(collected)

    if !options[:force] && (refusal = OutputGuard.refusal(options[:out]))
      abort <<~MESSAGE
        #{refusal}
        レポートには private リポジトリの指摘本文とリポジトリ名が入るので、コミットできる場所には置かない。
        別の場所を --out で指定する。
      MESSAGE
    end
    OutputGuard.prepare!(options[:out])

    data = Dataset.new(collected)
    abort '集めた run が 0 本。collect.rb の --root を確認する。' if data.runs.empty?

    summary = {}
    report = +"#{NOTICE}# self-review ログの集計\n\n"
    report << "生成: #{Time.now.iso8601}\n\n"
    report << section_scope(data, summary)
    report << section_runs(data, summary)
    report << section_repos(data, summary)
    report << section_models(data, summary)
    report << section_convergence(data, summary)
    report << section_waiting(data, summary)
    report << section_tokens(data, summary)
    triage_section, triage = section_triage(data, summary)
    report << triage_section

    OutputGuard.write(File.join(options[:out], 'report.md'), report)
    OutputGuard.write(File.join(options[:out], 'summary.json'), JSON.pretty_generate(summary))
    OutputGuard.write(File.join(options[:out], 'triage.md'), triage)
    io.puts "出力: #{options[:out]}/report.md, summary.json, triage.md"
  end
end

Analyze.run(ARGV) if $PROGRAM_NAME == __FILE__
