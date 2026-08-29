# frozen_string_literal: true

require 'json'
require 'time'
require_relative 'transcript'
require_relative 'model_pricing'

# collect.rb が吐いた JSONL を読み、run とトランスクリプトを突き合わせる。
#
# 突き合わせの手がかりは時刻しかない。self-review.md にはセッション ID が残らないので、
# 「同じマシンの、同じリポジトリの、run の時間帯に動いていたセッション」を候補にする。
# 当たらなかった run は捨てずに match_kind を付けて残し、レポートで突合率として出す。
class Dataset
  # ラウンド見出しの時刻は分単位のことがあり、sub agent の起動はその直後になる。
  # 見出しより少し前に起動した sub agent を前のラウンドに落とさないための許容幅。
  ROUND_TOLERANCE = 120
  # run の開始前に始まったセッション (先に作業していて、途中で self-review に入った) を拾う幅。
  SESSION_SLACK = 30 * 60
  # 最後のラウンドの見出しから、この時間までに起動した sub agent をその run のものとする。
  # セッションは self-review の後も続くので、上限を置かないと後続の作業の sub agent まで数える。
  RUN_TAIL = 60 * 60
  # ラウンド見出しに時刻が無い run の打ち切り幅。
  RUN_MAX_SPAN = 12 * 60 * 60

  # self-review が起動する sub agent の description は英語と日本語が混ざる。
  REVIEW_DESCRIPTION = /review|レビュー|verif|検証|round\s*\d|ラウンド\s*\d|\bR\s?\d/i
  # 突合の確からしさの順。同一マシン・同一ブランチが一番強い
  MATCH_ORDER = %w[branch time-only cross-machine cross-machine-time-only].freeze
  MODEL_SHORT_NAMES = %w[fable opus sonnet haiku].freeze

  attr_reader :runs, :findings, :sessions, :agents, :warnings, :usage_events, :machines, :meta

  def initialize(collected_dir)
    @collected_dir = collected_dir
    @machines = Dir.children(collected_dir).select { |name| File.directory?(File.join(collected_dir, name)) }.sort
    @runs = load_all('runs.jsonl')
    @findings = load_all('findings.jsonl')
    @sessions = load_all('sessions.jsonl')
    @agents = load_all('agents.jsonl')
    @warnings = load_all('warnings.jsonl')
    @usage_events = load_all('usage_events.jsonl')
    @meta = @machines.to_h { |machine| [machine, load_json(File.join(collected_dir, machine, 'meta.json'))] }
    link!
  end

  def load_all(basename)
    @machines.flat_map do |machine|
      path = File.join(@collected_dir, machine, basename)
      next [] unless File.exist?(path)

      File.readlines(path).filter_map { |line| JSON.parse(line) unless line.strip.empty? }
    end
  end

  def load_json(path) = File.exist?(path) ? JSON.parse(File.read(path)) : {}

  def self.time(value)
    return nil if value.nil?

    Time.parse(value)
  rescue ArgumentError
    nil
  end

  def findings_for(run_id) = @findings.select { |finding| finding['run_id'] == run_id }

  # sub agent の起動で model を省くと meta.json に model が残らないので、実際に動いたモデルで補う
  def self.short_model(name)
    return nil if name.nil?

    MODEL_SHORT_NAMES.find { |short| name.include?(short) }
  end

  def self.effective_model(agent)
    short_model(agent['model_requested']) || short_model(agent['models_observed']&.first)
  end

  def self.review_agent?(agent) = REVIEW_DESCRIPTION.match?(agent['description'].to_s)

  # 同じログを 2 台で集めると、run が 2 本に見えて指摘もラウンドも倍になる。
  # 落とすと片方のマシンにしか無い情報まで消えるので、残したうえで警告に出す。
  def duplicate_logs
    @runs
      .group_by { |run| [run['log_path'], run['run_index']] }
      .select { |_, runs| runs.map { |run| run['machine'] }.uniq.size > 1 }
      .map { |(log_path, run_index), runs| { 'log_path' => log_path, 'run_index' => run_index, 'machines' => runs.map { |run| run['machine'] } } }
  end

  # 1 体の sub agent は 1 つの run にしか入れない。時間帯が重なる run が隣り合うと、
  # 同じ agent を両方が数えてトークンとコストが二重になる。
  def link!
    agents_by_session = @agents.group_by { |agent| [agent['machine'], agent['session_id']] }
    claimed = {}
    claimed_events = {}

    @runs.each do |run|
      run['started_time'] = self.class.time(run['started_at'])
      run['rounds'].each { |round| round['started_time'] = self.class.time(round['started_at']) }
      run['end_time'] = run_end_time(run)
      run['sessions'] = []
      run['agents'] = []
      run['match_kind'] = 'none'
    end

    @runs.sort_by { |run| run['started_time'] || Time.at(0) }.each do |run|
      next if run['started_time'].nil?

      matched = matching_sessions(run)
      run['sessions'] = matched.map { |session, _| session['session_id'] }
      run['match_kind'] = matched.map(&:last).min_by { |kind| MATCH_ORDER.index(kind) || 9 } || 'none'

      matched.each do |session, _kind|
        agents_by_session.fetch([session['machine'], session['session_id']], []).each do |agent|
          key = [agent['machine'], agent['agent_id']]
          next if claimed.key?(key)

          started = self.class.time(agent['started_at'])
          next if started.nil?
          next if started < run['started_time'] - ROUND_TOLERANCE
          next if run['end_time'] && started >= run['end_time']

          claimed[key] = run['run_id']
          run['agents'] << agent.merge(
            'round' => round_for(run, started),
            'started_time' => started,
            'effective_model' => self.class.effective_model(agent),
            'review' => self.class.review_agent?(agent)
          )
        end
      end
      run['agents'].sort_by! { |agent| agent['started_time'] }
      assign_parent_usage!(run, claimed_events)
    end
  end

  # run の終わり。同じログの次の run が始まるまで、無ければ最後のラウンドの見出し + RUN_TAIL。
  # ラウンドに時刻が無い旧書式のログでは run の開始 + RUN_MAX_SPAN で打ち切る。
  def run_end_time(run)
    successor = @runs
      .select { |other| other['log_path'] == run['log_path'] && other['machine'] == run['machine'] && other['run_index'] > run['run_index'] }
      .filter_map { |other| self.class.time(other['started_at']) }
      .min
    return successor if successor
    return nil if run['started_time'].nil?

    last_round = run['rounds'].filter_map { |round| round['started_time'] }.max
    last_round ? last_round + RUN_TAIL : run['started_time'] + RUN_MAX_SPAN
  end

  # 確度の高い順に候補を採る。同じマシンで当たらなかったときだけ、他のマシンまで広げる。
  # ログとトランスクリプトが別のマシンにあるのは 2 台構成では普通に起きるので、
  # 同一マシンを必須にすると、その run のコストと待ち時間が丸ごと欠ける。
  def matching_sessions(run)
    candidates = overlapping_sessions(run)
    MATCH_ORDER.each do |kind|
      hit = candidates.select { |_, candidate_kind| candidate_kind == kind }
      return hit unless hit.empty?
    end
    []
  end

  def overlapping_sessions(run)
    @sessions.filter_map do |session|
      next unless session['repo_group'] == run['repo_group']

      started = self.class.time(session['started_at'])
      ended = self.class.time(session['ended_at'])
      next if started.nil? || ended.nil?
      next if ended < run['started_time'] - SESSION_SLACK
      next if run['end_time'] && started > run['end_time']

      same_machine = session['machine'] == run['machine']
      branch = session['branches'].include?(run['branch'])
      kind = if same_machine
               branch ? 'branch' : 'time-only'
             else
               branch ? 'cross-machine' : 'cross-machine-time-only'
             end
      [session, kind]
    end
  end

  def round_for(run, time)
    candidates = run['rounds'].select { |round| round['started_time'] && round['started_time'] <= time + ROUND_TOLERANCE }
    candidates.empty? ? nil : candidates.max_by { |round| round['started_time'] }['number']
  end

  # ラウンドの経過時間。次のラウンドの開始まで、最後のラウンドは所属 sub agent の終わりまで。
  def round_span(run, round)
    return nil if round['started_time'].nil?

    following = run['rounds'].filter_map { |other| other['started_time'] if other['number'] > round['number'] }.min
    return following - round['started_time'] if following

    last_agent_end = run['agents']
      .select { |agent| agent['round'] == round['number'] }
      .filter_map { |agent| self.class.time(agent['ended_at']) }
      .max
    last_agent_end ? last_agent_end - round['started_time'] : nil
  end

  # run の時間帯に依頼元セッションが使ったトークン。sub agent 側は agents.jsonl から数える。
  def parent_usage(run) = run['parent_usage'] || {}

  # 依頼元の推論 (agent_id の無いイベント) を run へ割り当てる。
  # sub agent と同じく 1 イベントは 1 run にしか入れない。時間帯の重なる run が並ぶと二重に数える。
  def assign_parent_usage!(run, claimed)
    run['parent_usage'] = Hash.new { |hash, key| hash[key] = Transcript.blank_usage }

    @usage_events.each_with_index do |event, index|
      next if event['agent_id'] || claimed.key?(index)
      next unless run['sessions'].include?(event['session_id'])

      timestamp = self.class.time(event['ts'])
      next if timestamp.nil? || timestamp < run['started_time']
      next if run['end_time'] && timestamp > run['end_time']

      claimed[index] = run['run_id']
      Transcript.add_usage!(run['parent_usage'][event['model']], event)
    end
  end

  def usage_sum(records)
    total = Hash.new { |hash, key| hash[key] = Transcript.blank_usage }
    records.each do |record|
      (record['usage_by_model'] || {}).each { |model, usage| Transcript.add_usage!(total[model], usage) }
    end
    total
  end

  def cost_of(records) = ModelPricing.total_cost(usage_sum(records))

  def tokens_of(records)
    usage_sum(records).values.sum { |usage| Transcript::USAGE_KEYS.sum { |key| usage[key] } }
  end
end
