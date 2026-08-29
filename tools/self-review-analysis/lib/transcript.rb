# frozen_string_literal: true

require 'json'
require 'time'

# Claude Code のトランスクリプト (~/.claude/projects) から、
# セッションと sub agent の所要時間・トークンだけを取り出す。
#
# レイアウト:
#   <projects>/<project>/<session-id>.jsonl                  親セッション
#   <projects>/<project>/<session-id>/subagents/agent-*.jsonl sub agent 1 体につき 1 ファイル
#   <projects>/<project>/<session-id>/subagents/agent-*.meta.json  agentType / description / model
#
# 本文は読まない。取り出すのは時刻・モデル・トークン数と、sub agent の起動理由だけ。
module Transcript
  Agent = Struct.new(
    :agent_id, :agent_type, :description, :model_requested, :spawn_depth, :tool_use_id,
    :started_at, :ended_at, :usage_by_model, :message_count, :cwd, :git_branch,
    keyword_init: true
  )
  Session = Struct.new(
    :project, :session_id, :path, :cwd, :git_branches, :started_at, :ended_at,
    :usage_by_model, :message_count, :total_cost_usd, :agents, :usage_events,
    :inline_sidechain, :version,
    keyword_init: true
  )

  USAGE_KEYS = %w[input output cache_read cache_write_5m cache_write_1h].freeze

  def self.blank_usage = USAGE_KEYS.to_h { |key| [key, 0] }

  def self.add_usage!(target, other)
    USAGE_KEYS.each { |key| target[key] += other[key].to_i }
    target
  end

  # message.usage を USAGE_KEYS の形に直す。
  # cache_creation の内訳 (5m / 1h) は課金レートが違うので分けて持つ。
  def self.usage_from(raw)
    breakdown = raw['cache_creation']
    write_5m = breakdown&.dig('ephemeral_5m_input_tokens')
    write_1h = breakdown&.dig('ephemeral_1h_input_tokens')
    if write_5m.nil? && write_1h.nil?
      write_5m = raw['cache_creation_input_tokens']
      write_1h = 0
    end

    {
      'input' => raw['input_tokens'].to_i,
      'output' => raw['output_tokens'].to_i,
      'cache_read' => raw['cache_read_input_tokens'].to_i,
      'cache_write_5m' => write_5m.to_i,
      'cache_write_1h' => write_1h.to_i,
    }
  end

  def self.parse_time(value)
    return nil if value.nil?

    Time.iso8601(value)
  rescue ArgumentError
    nil
  end

  def self.each_line(path)
    File.foreach(path) do |line|
      next if line.strip.empty?

      begin
        yield JSON.parse(line)
      rescue JSON::ParserError
        next
      end
    end
  end

  # projects ディレクトリ配下のセッションを読む。
  # cwd_filter は cwd を持つ最初のエントリを見て呼ぶ。対象外のセッションは sub agent まで開かずに捨てる。
  def self.each_session(projects_dir, accept: nil, cwd_filter: nil)
    return to_enum(:each_session, projects_dir, accept: accept, cwd_filter: cwd_filter) unless block_given?

    Dir.glob(File.join(projects_dir, '*', '*.jsonl')).sort.each do |path|
      next if cwd_filter && !cwd_filter.call(peek_cwd(path))

      session = read_session(path)
      next if session.nil?
      next if accept && !accept.call(session)

      yield session
    end
  end

  def self.peek_cwd(path)
    each_line(path) { |entry| return entry['cwd'] if entry['cwd'] }
    nil
  end

  def self.read_session(path)
    session_id = File.basename(path, '.jsonl')
    session = Session.new(
      project: File.basename(File.dirname(path)),
      session_id: session_id,
      path: path,
      cwd: nil,
      git_branches: [],
      started_at: nil,
      ended_at: nil,
      usage_by_model: {},
      message_count: 0,
      total_cost_usd: nil,
      agents: [],
      usage_events: [],
      inline_sidechain: false,
      version: nil
    )

    each_line(path) do |entry|
      absorb_entry(session, entry, agent_id: nil)
      session.total_cost_usd = entry['totalCostUSD'] if entry['totalCostUSD']
      session.inline_sidechain = true if entry['isSidechain'] && entry['type'] == 'assistant'
    end
    return nil if session.started_at.nil?

    session.agents = read_agents(File.join(File.dirname(path), session_id, 'subagents'), session)
    session
  end

  def self.absorb_entry(holder, entry, agent_id:)
    timestamp = parse_time(entry['timestamp'])
    if timestamp
      holder.started_at = timestamp if holder.started_at.nil? || timestamp < holder.started_at
      holder.ended_at = timestamp if holder.ended_at.nil? || timestamp > holder.ended_at
    end

    holder.cwd ||= entry['cwd']
    branch = entry['gitBranch']
    if holder.is_a?(Session)
      holder.version = entry['version'] if entry['version']
      holder.git_branches << branch if branch && !branch.empty? && !holder.git_branches.include?(branch)
    elsif branch && !branch.empty?
      holder.git_branch ||= branch
    end

    message = entry['message']
    return unless entry['type'] == 'assistant' && message.is_a?(Hash) && message['usage'].is_a?(Hash)

    model = message['model']
    usage = usage_from(message['usage'])
    holder.message_count += 1
    add_usage!(holder.usage_by_model[model] ||= blank_usage, usage)

    events = holder.is_a?(Session) ? holder.usage_events : nil
    events&.push({ 'ts' => entry['timestamp'], 'model' => model, 'agent_id' => agent_id }.merge(usage))
  end

  def self.read_agents(subagents_dir, session)
    return [] unless Dir.exist?(subagents_dir)

    Dir.glob(File.join(subagents_dir, 'agent-*.jsonl')).sort.filter_map do |path|
      agent_id = File.basename(path, '.jsonl')
      meta = read_meta(path.sub(/\.jsonl\z/, '.meta.json'))
      agent = Agent.new(
        agent_id: agent_id,
        agent_type: meta['agentType'],
        description: meta['description'],
        model_requested: meta['model'],
        spawn_depth: meta['spawnDepth'],
        tool_use_id: meta['toolUseId'],
        started_at: nil,
        ended_at: nil,
        usage_by_model: {},
        message_count: 0,
        cwd: nil,
        git_branch: nil
      )

      each_line(path) do |entry|
        absorb_entry(agent, entry, agent_id: agent_id)
        next unless entry['type'] == 'assistant'

        message = entry['message']
        next unless message.is_a?(Hash) && message['usage'].is_a?(Hash)

        session.usage_events << {
          'ts' => entry['timestamp'],
          'model' => message['model'],
          'agent_id' => agent_id,
        }.merge(usage_from(message['usage']))
      end

      agent.started_at.nil? ? nil : agent
    end
  end

  def self.read_meta(path)
    return {} unless File.exist?(path)

    JSON.parse(File.read(path))
  rescue JSON::ParserError
    {}
  end
end
