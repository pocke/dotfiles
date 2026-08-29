require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../lib/dataset'
require_relative '../analyze'

# analyze.rb は判断の根拠になる数字を作る。母集団の取り違えは表からは見えないので、
# 母数が違う run を混ぜた状態を作って、節ごとの数字を固定する。
class TestAnalyze < Minitest::Test
  def setup
    @dir = Dir.mktmpdir('analyze-test')
    @machine_dir = File.join(@dir, 'box-a')
    FileUtils.mkdir_p(@machine_dir)

    # run-priced: トランスクリプトが突き合わせられる run。run-logonly: ログしかない run
    write('runs.jsonl', [
      run_record('run-priced', '2026-08-29T10:00:00+09:00', 'log-a.md', %w[fable opus]),
      run_record('run-logonly', '2026-08-29T20:00:00+09:00', 'log-b.md', %w[fable opus]),
    ])
    write('findings.jsonl', [
      finding('run-priced', 1, 'must-fix', models: %w[fable]),
      finding('run-priced', 1, 'nit', models: %w[opus]),
      finding('run-logonly', 1, 'nit', models: %w[fable]),
      finding('run-logonly', 1, 'nit', models: %w[fable]),
      finding('run-priced', 2, 'nit', category: 'new', action_kind: 'gated', location: 'a.rb:1'),
      finding('run-priced', 3, 'nit', category: 'carried-over', location: 'a.rb:1'),
      finding('run-priced', 4, 'nit', category: 'carried-over', location: 'a.rb:1'),
      finding('run-priced', 4, 'should-fix', action_kind: 'dropped', location: 'b.rb:2'),
    ])
    write('sessions.jsonl', [{
      'machine' => 'box-a', 'session_id' => 'sess-1', 'repo' => 'ghq/x/repo', 'repo_group' => 'ghq/x/repo',
      'branches' => ['topic'], 'started_at' => '2026-08-29T09:59:00+09:00', 'ended_at' => '2026-08-29T11:00:00+09:00',
      'total_cost_usd' => 1.0, 'usage_by_model' => { 'claude-opus-5' => Transcript.blank_usage.merge('output' => 40_000) },
    }])
    write('agents.jsonl', [
      agent('agent-fable', '2026-08-29T10:00:10+09:00', 600, 'fable'),
      agent('agent-opus', '2026-08-29T10:00:20+09:00', 300, 'opus'),
    ])
    write('usage_events.jsonl', [
      { 'machine' => 'box-a', 'session_id' => 'sess-1', 'agent_id' => nil, 'ts' => '2026-08-29T10:05:00+09:00', 'model' => 'claude-opus-5' }.merge(Transcript.blank_usage.merge('output' => 20_000)),
      { 'machine' => 'box-a', 'session_id' => 'sess-1', 'agent_id' => 'agent-opus', 'ts' => '2026-08-29T10:06:00+09:00', 'model' => 'claude-opus-5' }.merge(Transcript.blank_usage.merge('output' => 90_000)),
    ])
    write('warnings.jsonl', [])
    File.write(File.join(@machine_dir, 'meta.json'), JSON.generate({ 'machine' => 'box-a', 'collected_at' => '2026-08-29T21:00:00+09:00' }))
  end

  def teardown = FileUtils.remove_entry(@dir)

  def write(name, records)
    File.write(File.join(@machine_dir, name), records.map { |record| JSON.generate(record) }.join("\n") + "\n")
  end

  def run_record(id, started_at, log_path, models, suites: nil)
    rounds = [{
      'number' => 1, 'started_at' => started_at, 'suite' => suites&.first,
      'reviewers' => models.map { |model| { 'group' => '正しさ', 'model' => model, 'verdict' => 'request-changes' } },
    }]
    rounds += (suites || []).drop(1).each_with_index.map do |suite, index|
      { 'number' => index + 2, 'started_at' => nil, 'suite' => suite, 'reviewers' => [] }
    end
    {
      'run_id' => id, 'machine' => 'box-a', 'repo' => 'ghq/x/repo', 'repo_group' => 'ghq/x/repo',
      'branch' => 'topic', 'log_path' => log_path, 'run_index' => 0, 'started_at' => started_at,
      'round_count' => rounds.size, 'finding_count' => 0, 'rounds' => rounds, 'diff' => { 'source' => 'no-base-recorded' },
    }
  end

  def finding(run_id, round, severity, models: [], category: nil, action_kind: 'fix', location: 'x.rb:1')
    {
      'run_id' => run_id, 'machine' => 'box-a', 'repo' => 'ghq/x/repo', 'repo_group' => 'ghq/x/repo',
      'branch' => 'topic', 'round' => round, 'severity' => severity, 'category' => category,
      'location' => location, 'note' => 'note', 'action' => 'action', 'action_kind' => action_kind,
      'models' => models,
    }
  end

  def agent(agent_id, started_at, duration, model)
    {
      'machine' => 'box-a', 'session_id' => 'sess-1', 'agent_id' => agent_id, 'model_requested' => model,
      'description' => 'Round 1 review', 'started_at' => started_at,
      'ended_at' => (Time.parse(started_at) + duration).iso8601, 'duration_s' => duration,
      'usage_by_model' => { "claude-#{model}-5" => Transcript.blank_usage.merge('output' => 100_000) },
    }
  end

  def summarize
    data = Dataset.new(@dir)
    summary = {}
    Analyze.section_models(data, summary)
    Analyze.section_waiting(data, summary)
    Analyze.section_tokens(data, summary)
    Analyze.section_triage(data, summary)
    [data, summary]
  end

  # ユニーク指摘はログのある run 全部から、コストはトランスクリプトのある run からしか出ない。
  # そのまま割ると単価が過小になるので、割り算の分母は突合できた run のユニーク数に揃える
  def test_cost_per_unique_finding_uses_the_same_runs_for_both_sides
    _, summary = summarize
    models = summary['round1_models']

    assert_equal %w[run-priced run-logonly], models['multi_model_runs']
    assert_equal ['run-priced'], models['priced_runs']
    assert_equal 3, models['per_model']['fable']['unique'], 'ログのある run 全部'
    assert_equal 1, models['per_model']['fable']['unique_in_priced_runs'], '突合できた run だけ'
  end

  def test_savings_are_measured_by_dropping_a_model_not_the_slowest_agent
    _, summary = summarize
    savings = summary['waiting']['savings_by_dropping_model_s']

    # fable 600s / opus 300s の並列なので、fable を外すと 300 秒縮み、opus を外しても縮まない
    assert_in_delta 300.0, savings['fable']
    assert_in_delta 0.0, savings['opus']
  end

  def test_counts_the_parent_session_separately_from_sub_agents
    _, summary = summarize
    assert_equal 2, summary['tokens']['round1']['agents']
    assert_operator summary['tokens']['parent_sessions']['cost_usd'], :>, 0
  end

  def test_gate_conflicts_are_counted_once_per_location
    _, summary = summarize
    conflicts = summary['triage']['gate_conflicts']

    assert_equal 1, conflicts.size, '同じ箇所が 2 ラウンドで再提出されても 1 件'
    assert_equal [3, 4], conflicts[0]['reappeared_rounds']
  end

  def test_triage_covers_dropped_findings
    _, summary = summarize
    assert_equal 1, summary['triage']['counts']['dropped']
    assert_equal 1, summary['triage']['counts']['gated']
  end

  # 「前のラウンドの値を再掲した」ラウンドを比較に入れると、同じ 1 回の測定が何度も閾値に当たる
  def test_suite_comparison_skips_rounds_that_only_restate_the_previous_value
    write('runs.jsonl', [
      run_record('run-suite', '2026-08-29T10:00:00+09:00', 'log-c.md', %w[fable opus], suites: [
        { 'tests' => 100, 'seconds' => 2.0, 'status' => 'green' },
        { 'tests' => 100, 'seconds' => 8.0, 'status' => 'green (再測なし)' },
        { 'tests' => 100, 'seconds' => 8.0, 'status' => 'green' },
      ]),
    ])
    write('findings.jsonl', [])

    jumps = Analyze.suite_comparison(Dataset.new(@dir))
    assert_equal [3], jumps.map { |jump| jump['round'] }
    assert_equal 1, jumps.count { |jump| jump['flagged'] }
  end
  # 突合できなかった run は「タダで回った run」ではなく「測れていない run」。
  # 変更行と経過時間は `-` にしているのに、token と金額だけ 0 だと読み手が区別できない
  def test_unmatched_runs_show_a_dash_instead_of_zero_cost
    data = Dataset.new(@dir)
    summary = {}
    rows = Analyze.section_runs(data, summary)

    logonly = summary['runs'].find { |record| record['run_id'] == 'run-logonly' }
    assert_equal 0, logonly['review_agents']
    assert_nil logonly['agent_tokens']
    assert_nil logonly['agent_cost_usd']
    refute_match(/\$0\.00/, rows)
  end

  def test_the_parent_session_is_counted_for_one_run_only
    # 同じセッションの時間帯に 2 本の run が並ぶ状態を作る
    write('runs.jsonl', [
    run_record('run-a', '2026-08-29T10:00:00+09:00', 'log-a.md', %w[fable opus]),
    run_record('run-b', '2026-08-29T10:03:00+09:00', 'log-b.md', %w[fable opus]),
    ])
    data = Dataset.new(@dir)

    counted = data.runs.sum { |run| data.parent_usage(run).values.sum { |usage| usage['output'] } }
    assert_equal 20_000, counted, '親セッションのイベントを 2 本の run で二重に数えない'
  end

  def test_triage_keeps_findings_whose_action_could_not_be_classified
    write('findings.jsonl', [finding('run-priced', 2, 'nit', action_kind: 'other')])
    summary = {}
    Analyze.section_triage(Dataset.new(@dir), summary)

    assert_equal 1, summary['triage']['counts']['other']
  end

  def test_round1_has_no_category_column_and_unknown_diffs_are_not_zero
    data = Dataset.new(@dir)
    summary = {}
    convergence = Analyze.section_convergence(data, summary)
    repos = Analyze.section_repos(data, summary)

    assert_match(/^\| 1 \| \d+ \| - \| - \|/, convergence, 'ラウンド1の区分と new must-fix は - にする')
    assert_match(/測れず/, repos, '変更規模が測れなかった run は 0 と書かない')
  end

  def test_zero_token_models_are_not_reported_as_unpriced
    total = ModelPricing.total_cost({ '<synthetic>' => Transcript.blank_usage })
    assert_empty total[:unpriced]
  end

  # description の正規表現が 1 体も拾えなかった run は、トランスクリプトが無い run とは違う。
  # agent 列に 0/N が出れば、README が読み手に指示している「差が大きい run は疑う」が働く
  def test_a_run_whose_agents_all_fail_the_review_regex_still_shows_them
    write('agents.jsonl', [
      agent('agent-impl-1', '2026-08-29T10:00:10+09:00', 600, 'opus').merge('description' => 'Implement the parser'),
      agent('agent-impl-2', '2026-08-29T10:00:20+09:00', 300, 'opus').merge('description' => 'Write the docs'),
    ])
    summary = {}
    rows = Analyze.section_runs(Dataset.new(@dir), summary)
    record = summary['runs'].find { |run| run['run_id'] == 'run-priced' }

    assert_equal 0, record['review_agents']
    assert_equal 2, record['agents_in_window']
    assert_nil record['agent_cost_usd'], 'レビュー用が 0 体ならコストは測れていない'
    assert_match(%r{\| 0/2 \|}, rows, 'その時間帯の sub agent は表に出す')
  end
  # ログの日時はマシンの時間帯で書かれる。文字列のまま並べると `05:01+00:00` が
  # `12:25+09:00` より前に来て、表示も 9 時間ずれる
  def test_runs_are_ordered_and_shown_in_absolute_time
    write('runs.jsonl', [
      run_record('run-jst', '2026-08-29T12:25:00+09:00', 'log-a.md', %w[fable opus]),
      run_record('run-utc', '2026-08-29T05:01:00+00:00', 'log-b.md', %w[fable opus]),
    ])
    write('findings.jsonl', [])

    rows = Analyze.section_runs(Dataset.new(@dir), {})
    shown = ->(iso) { Time.parse(iso).getlocal.strftime('%Y-%m-%dT%H:%M') }
    earlier = shown.call('2026-08-29T12:25:00+09:00')
    later = shown.call('2026-08-29T05:01:00+00:00')

    assert_includes rows, later, '表示はこのマシンの時間帯に揃える'
    assert_operator rows.index(earlier), :<, rows.index(later), '絶対時刻の順に並べる'
  end
end
