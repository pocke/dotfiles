require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../lib/transcript'
require_relative '../lib/model_pricing'

class TestTranscript < Minitest::Test
  def setup
    @dir = Dir.mktmpdir('transcript-test')
    @project = File.join(@dir, '-home-user-repo')
    FileUtils.mkdir_p(File.join(@project, 'sess-1', 'subagents'))

    write_jsonl(File.join(@project, 'sess-1.jsonl'), [
      { 'type' => 'user', 'timestamp' => '2026-08-29T00:00:00.000Z', 'cwd' => '/home/user/repo', 'gitBranch' => 'topic', 'version' => '2.1.250' },
      assistant('2026-08-29T00:00:10.000Z', 'claude-opus-5', input: 10, output: 100, cache_read: 1000, write_1h: 500),
      assistant('2026-08-29T00:01:00.000Z', 'claude-opus-5', input: 5, output: 50, cache_read: 2000, write_5m: 200),
      { 'type' => 'cost-state', 'timestamp' => '2026-08-29T00:02:00.000Z', 'totalCostUSD' => 1.5 },
    ])

    write_jsonl(File.join(@project, 'sess-1', 'subagents', 'agent-abc.jsonl'), [
      assistant('2026-08-29T00:00:20.000Z', 'claude-fable-5', input: 1, output: 20, cache_read: 300).merge('agentId' => 'agent-abc', 'cwd' => '/home/user/repo', 'gitBranch' => 'topic'),
      assistant('2026-08-29T00:00:50.000Z', 'claude-fable-5', input: 2, output: 30),
    ])
    File.write(
      File.join(@project, 'sess-1', 'subagents', 'agent-abc.meta.json'),
      JSON.generate({ 'agentType' => 'general-purpose', 'description' => 'Round 1 review', 'model' => 'fable', 'spawnDepth' => 1, 'toolUseId' => 'toolu_1' })
    )
  end

  def teardown = FileUtils.remove_entry(@dir)

  def assistant(timestamp, model, input: 0, output: 0, cache_read: 0, write_5m: 0, write_1h: 0)
    usage = {
      'input_tokens' => input,
      'output_tokens' => output,
      'cache_read_input_tokens' => cache_read,
      'cache_creation_input_tokens' => write_5m + write_1h,
    }
    if write_5m.positive? || write_1h.positive?
      usage['cache_creation'] = { 'ephemeral_5m_input_tokens' => write_5m, 'ephemeral_1h_input_tokens' => write_1h }
    end
    { 'type' => 'assistant', 'timestamp' => timestamp, 'message' => { 'model' => model, 'usage' => usage } }
  end

  def write_jsonl(path, entries) = File.write(path, entries.map { |e| JSON.generate(e) }.join("\n") + "\n")

  def sessions = Transcript.each_session(@dir).to_a

  def test_reads_session_metadata
    session = sessions.fetch(0)
    assert_equal 'sess-1', session.session_id
    assert_equal '/home/user/repo', session.cwd
    assert_equal ['topic'], session.git_branches
    assert_equal Time.iso8601('2026-08-29T00:00:00.000Z'), session.started_at
    assert_equal Time.iso8601('2026-08-29T00:02:00.000Z'), session.ended_at
    assert_in_delta 1.5, session.total_cost_usd
    assert_equal 2, session.message_count
    refute_predicate session, :inline_sidechain
  end

  def test_sums_usage_per_model_and_splits_cache_writes
    usage = sessions.fetch(0).usage_by_model.fetch('claude-opus-5')
    assert_equal 15, usage['input']
    assert_equal 150, usage['output']
    assert_equal 3000, usage['cache_read']
    assert_equal 200, usage['cache_write_5m']
    assert_equal 500, usage['cache_write_1h']
  end

  def test_reads_subagents_with_meta
    agent = sessions.fetch(0).agents.fetch(0)
    assert_equal 'agent-abc', agent.agent_id
    assert_equal 'Round 1 review', agent.description
    assert_equal 'fable', agent.model_requested
    assert_equal 30.0, agent.ended_at - agent.started_at
    assert_equal({ 'input' => 3, 'output' => 50, 'cache_read' => 300, 'cache_write_5m' => 0, 'cache_write_1h' => 0 },
                 agent.usage_by_model.fetch('claude-fable-5'))
  end

  def test_usage_events_carry_the_agent_id
    events = sessions.fetch(0).usage_events
    assert_equal 4, events.size
    assert_equal [nil, nil, 'agent-abc', 'agent-abc'], events.map { |e| e['agent_id'] }
    assert_equal 20, events.find { |e| e['agent_id'] }['output']
  end

  def test_accepts_a_cwd_filter
    assert_equal 1, Transcript.each_session(@dir, accept: ->(s) { s.cwd.start_with?('/home/user') }).to_a.size
    assert_equal 0, Transcript.each_session(@dir, accept: ->(s) { s.cwd.start_with?('/other') }).to_a.size
  end

  # 内訳を持たない古いトランスクリプトでは、cache_creation_input_tokens だけが入っている
  def test_reads_cache_writes_from_the_old_format
    usage = Transcript.usage_from('input_tokens' => 1, 'cache_creation_input_tokens' => 500)

    assert_equal 500, usage['cache_write_5m']
    assert_equal 0, usage['cache_write_1h']
  end

  def test_prices_the_two_cache_write_rates_apart
    write_5m = { 'input' => 0, 'output' => 0, 'cache_read' => 0, 'cache_write_5m' => 1_000_000, 'cache_write_1h' => 0 }
    write_1h = { 'input' => 0, 'output' => 0, 'cache_read' => 0, 'cache_write_5m' => 0, 'cache_write_1h' => 1_000_000 }

    # opus 5 の input は $5。5 分 TTL は 1.25 倍、1 時間 TTL は 2 倍
    assert_in_delta 6.25, ModelPricing.cost('claude-opus-5', write_5m)
    assert_in_delta 10.0, ModelPricing.cost('claude-opus-5', write_1h)
  end

  def test_skips_broken_lines_and_a_missing_meta_file
    path = File.join(@project, 'sess-2.jsonl')
    File.write(path, "{broken\n" + JSON.generate(assistant('2026-08-29T01:00:00.000Z', 'claude-opus-5', output: 7)) + "\n")
    FileUtils.mkdir_p(File.join(@project, 'sess-2', 'subagents'))
    write_jsonl(File.join(@project, 'sess-2', 'subagents', 'agent-zzz.jsonl'),
                [assistant('2026-08-29T01:01:00.000Z', 'claude-opus-5', output: 3)])

    session = Transcript.read_session(path)
    assert_equal 7, session.usage_by_model.fetch('claude-opus-5')['output']
    assert_equal 1, session.agents.size
    assert_nil session.agents[0].model_requested, 'meta.json が無くても agent は数える'
  end

  def test_prices_usage_by_model
    usage = { 'input' => 1_000_000, 'output' => 0, 'cache_read' => 1_000_000, 'cache_write_5m' => 0, 'cache_write_1h' => 1_000_000 }
    # opus 5: input $5 → 5 + 読み 0.1x = 0.5 + 1h 書き 2x = 10
    assert_in_delta 15.5, ModelPricing.cost('claude-opus-5', usage)
    assert_in_delta 15.5, ModelPricing.cost('claude-opus-5[1m]', usage)
    assert_nil ModelPricing.cost('claude-unknown-9', usage)

    total = ModelPricing.total_cost({ 'claude-opus-5' => usage, 'claude-unknown-9' => usage })
    assert_in_delta 15.5, total[:usd]
    assert_equal ['claude-unknown-9'], total[:unpriced]
  end
end
