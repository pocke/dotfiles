require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../lib/dataset'

class TestDataset < Minitest::Test
  def setup
    @dir = Dir.mktmpdir('dataset-test')
    @machine_dir = File.join(@dir, 'box-a')
    FileUtils.mkdir_p(@machine_dir)

    write('runs.jsonl', [
      run_record('run-1', '2026-08-29T10:00:00+09:00', rounds: ['2026-08-29T10:00:00+09:00', '2026-08-29T10:30:00+09:00']),
      run_record('run-2', '2026-08-29T13:00:00+09:00', rounds: ['2026-08-29T13:00:00+09:00'], run_index: 1),
    ])
    write('sessions.jsonl', [
      session('sess-1', '2026-08-29T09:50:00+09:00', '2026-08-29T12:00:00+09:00', branches: ['topic']),
      session('sess-2', '2026-08-29T12:55:00+09:00', '2026-08-29T14:00:00+09:00', branches: ['other']),
      session('sess-3', '2026-08-29T10:00:00+09:00', '2026-08-29T11:00:00+09:00', branches: ['topic'], repo_group: 'ghq/other/repo'),
    ])
    write('agents.jsonl', [
      agent('sess-1', 'agent-r1a', '2026-08-29T10:00:30+09:00', 300, 'fable'),
      agent('sess-1', 'agent-r1b', '2026-08-29T10:01:00+09:00', 600, 'opus'),
      # ラウンド2の見出し時刻より 30 秒早く起動した sub agent
      agent('sess-1', 'agent-r2', '2026-08-29T10:29:30+09:00', 200, 'opus'),
      agent('sess-2', 'agent-x', '2026-08-29T13:05:00+09:00', 100, 'opus'),
      agent('sess-3', 'agent-other-repo', '2026-08-29T10:05:00+09:00', 100, 'opus'),
    ])
    write('findings.jsonl', [])
    write('warnings.jsonl', [])
    File.write(File.join(@machine_dir, 'meta.json'), JSON.generate({ 'machine' => 'box-a' }))
  end

  def teardown = FileUtils.remove_entry(@dir)

  def write(name, records)
    File.write(File.join(@machine_dir, name), records.map { |r| JSON.generate(r) }.join("\n") + "\n")
  end

  def run_record(id, started_at, rounds:, run_index: 0)
    {
      'run_id' => id, 'machine' => 'box-a', 'repo' => 'ghq/x/repo', 'repo_group' => 'ghq/x/repo',
      'branch' => 'topic', 'log_path' => 'ghq/x/repo/log.md', 'run_index' => run_index,
      'started_at' => started_at,
      'rounds' => rounds.each_with_index.map { |time, i| { 'number' => i + 1, 'started_at' => time } },
    }
  end

  def session(id, started_at, ended_at, branches:, repo_group: 'ghq/x/repo')
    {
      'machine' => 'box-a', 'session_id' => id, 'repo' => repo_group, 'repo_group' => repo_group,
      'branches' => branches, 'started_at' => started_at, 'ended_at' => ended_at,
      'usage_by_model' => { 'claude-opus-5' => Transcript.blank_usage.merge('output' => 10) },
    }
  end

  def agent(session_id, agent_id, started_at, duration, model)
    ended = (Time.parse(started_at) + duration).iso8601
    {
      'machine' => 'box-a', 'session_id' => session_id, 'agent_id' => agent_id, 'model_requested' => model,
      'description' => 'review', 'started_at' => started_at, 'ended_at' => ended, 'duration_s' => duration,
      'usage_by_model' => { "claude-#{model}-5" => Transcript.blank_usage.merge('output' => 100) },
    }
  end

  def dataset = Dataset.new(@dir)

  def test_matches_sessions_by_repo_branch_and_time
    runs = dataset.runs
    assert_equal ['sess-1'], runs[0]['sessions']
    assert_equal 'branch', runs[0]['match_kind']
    assert_equal ['sess-2'], runs[1]['sessions'], '別ブランチでも時間帯が合えば候補に残す'
    assert_equal 'time-only', runs[1]['match_kind']
  end

  def test_assigns_agents_to_rounds
    run = dataset.runs[0]
    assert_equal %w[agent-r1a agent-r1b agent-r2], run['agents'].map { |a| a['agent_id'] }
    assert_equal [1, 1, 2], run['agents'].map { |a| a['round'] }, '見出しの直前に起動した sub agent は次のラウンドに入れる'
  end

  def test_does_not_pull_agents_from_the_next_run
    assert_equal ['agent-x'], dataset.runs[1]['agents'].map { |a| a['agent_id'] }
  end

  def test_round_span_uses_the_next_round_then_the_last_agent
    data = dataset
    run = data.runs[0]
    assert_equal 1800.0, data.round_span(run, run['rounds'][0])
    assert_equal 170.0, data.round_span(run, run['rounds'][1]), '最後のラウンドは見出しから sub agent が終わるまで'
  end

  def test_recognizes_review_agents_by_description
    assert Dataset.review_agent?({ 'description' => 'Round 2 verification review' })
    assert Dataset.review_agent?({ 'description' => '正しさ・影響範囲レビュー' })
    assert Dataset.review_agent?({ 'description' => 'R1 整合性・文体' }), 'R1 のような略記も拾う'
    refute Dataset.review_agent?({ 'description' => 'Implement the parser' })
  end

  def test_falls_back_to_another_machine_when_the_transcript_is_elsewhere
    # ログは box-a、トランスクリプトは box-b という 2 台構成
    FileUtils.mkdir_p(File.join(@dir, 'box-b'))
    %w[runs.jsonl findings.jsonl warnings.jsonl].each { |name| File.write(File.join(@dir, 'box-b', name), '') }
    File.write(File.join(@dir, 'box-b', 'sessions.jsonl'),
               JSON.generate(session('sess-b', '2026-08-30T09:00:00+09:00', '2026-08-30T12:00:00+09:00', branches: ['topic']).merge('machine' => 'box-b')) + "\n")
    File.write(File.join(@dir, 'box-b', 'agents.jsonl'),
               JSON.generate(agent('sess-b', 'agent-b', '2026-08-30T10:00:30+09:00', 300, 'opus').merge('machine' => 'box-b')) + "\n")
    File.write(File.join(@machine_dir, 'runs.jsonl'),
               JSON.generate(run_record('run-b', '2026-08-30T10:00:00+09:00', rounds: ['2026-08-30T10:00:00+09:00'], run_index: 2)) + "\n")

    run = Dataset.new(@dir).runs.find { |r| r['run_id'] == 'run-b' }
    assert_equal ['agent-b'], run['agents'].map { |a| a['agent_id'] }
    assert_equal 'cross-machine', run['match_kind']
  end

  def test_reports_the_same_log_collected_on_two_machines
    FileUtils.mkdir_p(File.join(@dir, 'box-b'))
    %w[findings.jsonl warnings.jsonl sessions.jsonl agents.jsonl].each { |name| File.write(File.join(@dir, 'box-b', name), '') }
    copy = run_record('run-1-copy', '2026-08-29T10:00:00+09:00', rounds: ['2026-08-29T10:00:00+09:00'])
    File.write(File.join(@dir, 'box-b', 'runs.jsonl'), JSON.generate(copy.merge('machine' => 'box-b')) + "\n")

    data = Dataset.new(@dir)
    assert_equal 1, data.duplicate_logs.size
    assert_equal 2, data.runs.count { |run| run['log_path'] == 'ghq/x/repo/log.md' && run['run_index'].zero? },
                 '重複は落とさずに残し、レポートで警告する'
  end

  def test_an_agent_belongs_to_one_run_only
    File.write(File.join(@machine_dir, 'runs.jsonl'), [
      JSON.generate(run_record('run-1', '2026-08-29T10:00:00+09:00', rounds: ['2026-08-29T10:00:00+09:00'])),
      JSON.generate(run_record('run-2', '2026-08-29T10:02:00+09:00', rounds: ['2026-08-29T10:02:00+09:00'], run_index: 1).merge('log_path' => 'ghq/x/repo/other.md', 'branch' => 'topic')),
    ].join("\n") + "\n")

    runs = Dataset.new(@dir).runs
    claimed = runs.flat_map { |run| run['agents'].map { |agent| agent['agent_id'] } }
    assert_equal claimed.uniq, claimed
  end

  def test_sums_tokens_and_cost_over_records
    data = dataset
    agents = data.runs[0]['agents']
    assert_equal 300, data.tokens_of(agents)
    assert_in_delta 100 * 50.0 / 1_000_000 + 200 * 25.0 / 1_000_000, data.cost_of(agents)[:usd]
  end
end
