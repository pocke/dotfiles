require 'minitest/autorun'
require_relative '../lib/self_review_log'

class TestSelfReviewLog < Minitest::Test
  CURRENT = <<~MD
    # self-review: claude/example

    ## run: 2026-08-29T08:24:03+09:00

    - 基準コミット: `abc1234`

    ### ラウンド1 (2026-08-29T08:24:03+09:00)

    スイート: 120件 8.4s 3 failed (基準時点から既存)

    | 観点グループ | モデル | verdict |
    | --- | --- | --- |
    | 正しさ | fable | request-changes |
    | 正しさ | opus | approve |
    | セキュリティ | sonnet | 結果なし (打ち切り) |

    | 重大度 | 区分 | 該当箇所 | 指摘 | 対応 | モデル |
    | --- | --- | --- | --- | --- | --- |
    | must-fix | | a.rb:1 | 落ちる | 修正 (dd6dd5f / 検証: 実行) | fable, opus, sonnet (正しさ) / opus (規約) |
    | should-fix | | a.rb:2 | `a \\| b` が壊れる | 見送り (下記1) | opus |
    | question | | a.rb:3 | 意図は | 回答 | sonnet |

    ### ラウンド2 (2026-08-29T08:54:26+09:00)

    スイート: 121件 9.0s green

    | 重大度 | 区分 | 該当箇所 | 指摘 | 対応 | モデル |
    | --- | --- | --- | --- | --- | --- |
    | should-fix | fresh-surface | a.rb:9 | 新しい面 | 修正 (77b72d5 / 検証: 読み合わせ) | |
    | nit | new | a.rb:10 | 些細 | ゲートで記録のみ (初出: ラウンド2) | |
    | should-fix | carried-over | a.rb:1 | まだ直っていない | 検証のみ (検証: 環境不足) | |

    ## run: 2026-08-30T10:00:00+09:00

    ### ラウンド1 (2026-08-30T10:00:00+09:00)

    | 重大度 | 区分 | 該当箇所 | 指摘 | 対応 | モデル |
    | --- | --- | --- | --- | --- | --- |
    | nit | | b.rb:1 | 表記 | 修正 (aaaaaaa / 検証: 読み合わせ) | opus |
  MD

  LEGACY = <<~MD
    # self-review: 収束性改善

    - 基準コミット: `bbe40ef`

    ## ラウンド1 → 3 の hash 対応

    | 内容 | ラウンド1直後 | 最終 |
    | --- | --- | --- |
    | Fable 化 | f8b867a | 3cbe47a |

    ## ラウンド1

    レビュアー3体を `model: "fable"` で並行起動。

    | 重大度 | 区分 | 該当箇所 | 指摘 | 対応 |
    | --- | --- | --- | --- | --- |
    | must-fix | | SKILL.md:58 | 素通り穴 | 修正 (0062f67) |
    | nit | | SKILL.md:45 | 用語 | 見送り (下記4) |

    ## ラウンド2 (2026-08-18T14:45+09:00 頃)

    | 重大度 | 区分 | 該当箇所 | 指摘 | 対応 |
    | --- | --- | --- | --- | --- |
    | should-fix | regression | SKILL.md:12 | 壊した | 修正 (bd28b57) |
  MD

  def parse(text) = SelfReviewLog.parse(text, source: 'test.md')

  def findings_table(*rows)
    <<~MD
      ## run: 2026-08-29T08:24:03+09:00

      ### ラウンド1 (2026-08-29T08:24:03+09:00)

      | 重大度 | 区分 | 該当箇所 | 指摘 | 対応 | モデル |
      | --- | --- | --- | --- | --- | --- |
    MD
      .+ rows.join("\n") + "\n"
  end

  def test_splits_runs_by_run_heading
    result = parse(CURRENT)
    assert_equal 2, result.runs.size
    assert_equal Time.parse('2026-08-29T08:24:03+09:00'), result.runs[0].started_at
    assert_equal [1, 2], result.runs[0].rounds.map(&:number)
    assert_equal [1], result.runs[1].rounds.map(&:number)
  end

  def test_run_header_holds_the_lines_before_the_first_round
    result = parse(CURRENT)
    assert_equal '- 基準コミット: `abc1234`', result.runs[0].header
    assert_equal '', result.runs[1].header
    assert_equal '# self-review: claude/example', result.preamble
  end

  def test_parses_round_timestamp_and_suite
    round = parse(CURRENT).runs[0].rounds[0]
    assert_equal Time.parse('2026-08-29T08:24:03+09:00'), round.started_at
    assert_equal 120, round.suite[:tests]
    assert_in_delta 8.4, round.suite[:seconds]
    assert_equal '3 failed (基準時点から既存)', round.suite[:status]
  end

  def test_parses_reviewer_table
    reviewers = parse(CURRENT).runs[0].rounds[0].reviewers
    assert_equal 3, reviewers.size
    assert_equal ['正しさ', 'fable', 'request-changes'], [reviewers[0].group, reviewers[0].model, reviewers[0].verdict]
    assert_equal '結果なし (打ち切り)', reviewers[2].verdict
  end

  def test_parses_findings_with_models
    findings = parse(CURRENT).runs[0].rounds[0].findings
    assert_equal 3, findings.size

    first = findings[0]
    assert_equal 'must-fix', first.severity
    assert_nil first.category
    assert_equal 'a.rb:1', first.location
    assert_equal %w[fable opus sonnet], first.models
    assert_equal 'fix', first.action_kind
    assert_equal 'dd6dd5f', first.commit
    assert_equal '実行', first.verification

    assert_equal '`a | b` が壊れる', findings[1].note
    assert_equal 'dropped', findings[1].action_kind
    assert_equal 'answered', findings[2].action_kind
  end

  def test_parses_round2_categories_and_gate
    findings = parse(CURRENT).runs[0].rounds[1].findings
    assert_equal %w[fresh-surface new carried-over], findings.map(&:category)
    assert_equal [[], [], []], findings.map(&:models)

    gated = findings[1]
    assert_equal 'gated', gated.action_kind
    assert_equal 2, gated.gate_first_round

    assert_equal 'verify_only', findings[2].action_kind
    assert_equal '環境不足', findings[2].verification
  end

  def test_legacy_log_without_run_heading
    result = parse(LEGACY)
    assert_equal 1, result.runs.size
    run = result.runs[0]
    assert_equal [1, 2], run.rounds.map(&:number)
    assert_equal 2, run.rounds[0].findings.size
    assert_equal [], run.rounds[0].findings[0].models
    assert_equal '0062f67', run.rounds[0].findings[0].commit
    assert_nil run.rounds[0].findings[0].verification
    assert_equal Time.parse('2026-08-18T14:45+09:00'), run.rounds[1].started_at
    assert_nil run.rounds[0].started_at
  end

  def test_ignores_tables_that_are_not_findings_or_reviewers
    run = parse(LEGACY).runs[0]
    assert_equal 2, run.rounds.size, 'hash 対応表の見出しをラウンドと誤認しない'
  end

  def test_reports_malformed_rows_as_warnings
    text = <<~MD
      ## run: 2026-08-29T08:24:03+09:00

      ### ラウンド1 (2026-08-29T08:24:03+09:00)

      | 重大度 | 区分 | 該当箇所 | 指摘 | 対応 | モデル |
      | --- | --- | --- | --- | --- | --- |
      | must-fix | | a.rb:1 |
    MD
    result = parse(text)
    assert_equal 1, result.warnings.size
    assert_equal 'test.md', result.warnings[0][:source]
    assert_match(/列数/, result.warnings[0][:message])
  end

  def test_normalizes_annotated_category
    text = findings_table(
      '| should-fix | carried-over (ラウンド3で記録のみ) | a.rb:1 | x | 修正 (aaaaaaa) | |',
      '| should-fix | new (実質 carried-over) | a.rb:2 | y | 修正 (bbbbbbb) | |'
    )
    findings = parse(text).runs[0].rounds[0].findings
    assert_equal %w[carried-over new], findings.map(&:category)
    assert_equal ['carried-over (ラウンド3で記録のみ)', 'new (実質 carried-over)'], findings.map(&:raw_category)
    assert_empty parse(text).warnings
  end

  def test_merges_extra_columns_into_the_note
    text = findings_table('| should-fix | | a.rb:1 | `(/|\z)` を外しても落ちない | 修正 (aaaaaaa / 検証: 実行) | opus |')
    result = parse(text)
    finding = result.runs[0].rounds[0].findings[0]

    assert_equal 'should-fix', finding.severity
    assert_equal '`(/|\z)` を外しても落ちない', finding.note
    assert_equal %w[opus], finding.models
    assert_equal '実行', finding.verification
    assert_equal 1, result.warnings.size, 'エスケープ漏れは警告に残す'
  end

  def test_marks_withdrawn_severity
    text = findings_table('| ~~should-fix~~ | fresh-surface | a.rb:1 | 取り消した指摘 | 取り消し (2e0aca6) | |')
    finding = parse(text).runs[0].rounds[0].findings[0]

    assert_equal 'should-fix', finding.severity
    assert_predicate finding, :withdrawn
    assert_equal 'reverted', finding.action_kind
  end

  def test_classifies_remaining_action_kinds
    text = findings_table(
      '| should-fix | | a.rb:1 | x | 6 の整理で対応 | |',
      '| should-fix | | a.rb:2 | y | ループ後の整理で amend (下記) | |',
      '| must-fix | | a.rb:3 | z | 打ち切り (下記1) | |',
      '| nit | | a.rb:4 | w | 記録側は修正 (4595e45)、文言は見送り (下記) | |',
      '| should-fix | | a.rb:5 | v | 検証のやり直し (検証: 実行) | |',
      '| should-fix | | a.rb:6 | u | ステップ6で整理 (705d8a2 を先に置く並べ替え) | |'
    )
    result = parse(text)
    assert_equal %w[cleanup cleanup aborted mixed verify_only cleanup], result.runs[0].rounds[0].findings.map(&:action_kind)
    assert_empty result.warnings
  end

  def test_legacy_log_splits_runs_when_the_round_number_goes_back
    text = <<~MD
      # self-review ログ

      ## ラウンド1

      | 重大度 | 区分 | 該当箇所 | 指摘 | 対応 |
      | --- | --- | --- | --- | --- |
      | must-fix | | a.rb:1 | 1本目 | 修正 (aaaaaaa) |

      ## ラウンド2

      | 重大度 | 区分 | 該当箇所 | 指摘 | 対応 |
      | --- | --- | --- | --- | --- |
      | nit | new | a.rb:2 | 1本目 | 修正 (bbbbbbb) |

      ## ラウンド1

      | 重大度 | 区分 | 該当箇所 | 指摘 | 対応 |
      | --- | --- | --- | --- | --- |
      | must-fix | | b.rb:1 | 2本目 | 修正 (ccccccc) |
    MD
    result = parse(text)
    assert_equal 2, result.runs.size
    assert_equal [[1, 2], [1]], result.runs.map { |run| run.rounds.map(&:number) }
  end

  def test_round_heading_with_a_suffix_reopens_that_round
    text = <<~MD
      ## run: 2026-08-21T16:22:00+09:00

      ### ラウンド5 (2026-08-21T17:00:00+09:00)

      | 重大度 | 区分 | 該当箇所 | 指摘 | 対応 | モデル |
      | --- | --- | --- | --- | --- | --- |
      | nit | new | a.rb:1 | 本体 | 修正 (aaaaaaa) | |

      ### ラウンド6 (2026-08-21T17:31:57+09:00)

      | 重大度 | 区分 | 該当箇所 | 指摘 | 対応 | モデル |
      | --- | --- | --- | --- | --- | --- |
      | nit | new | a.rb:2 | 6の指摘 | 修正 (bbbbbbb) | |

      ### ラウンド5 追加分 (レビュアー再開、2026-08-21T17:34:30+09:00)

      | 重大度 | 区分 | 該当箇所 | 指摘 | 対応 | モデル |
      | --- | --- | --- | --- | --- | --- |
      | must-fix | carried-over | a.rb:3 | 5の追加 | 修正 (ccccccc) | |
    MD
    run = parse(text).runs[0]
    assert_equal [5, 6], run.rounds.map(&:number)
    assert_equal ['本体', '5の追加'], run.rounds[0].findings.map(&:note)
    assert_equal ['6の指摘'], run.rounds[1].findings.map(&:note)
  end

  def test_run_level_heading_closes_the_round
    text = <<~MD
      ## run: 2026-08-21T16:22:00+09:00

      ### ラウンド6 (2026-08-21T17:31:57+09:00)

      | 重大度 | 区分 | 該当箇所 | 指摘 | 対応 | モデル |
      | --- | --- | --- | --- | --- | --- |
      | nit | new | a.rb:2 | ラウンド6の指摘 | 修正 (bbbbbbb) | |

      ## ループ終了 (ラウンド6)

      | 重大度 | 区分 | 該当箇所 | 指摘 | 対応 | モデル |
      | --- | --- | --- | --- | --- | --- |
      | nit | new | a.rb:9 | まとめの再掲 | 見送り | |
    MD
    result = parse(text)
    assert_equal 1, result.runs[0].rounds[0].findings.size, 'ラウンドの外のテーブルを混ぜない'
    assert_equal 1, result.warnings.size
    assert_match(/ラウンドの外/, result.warnings[0][:message])
  end

  def test_numbered_less_heading_that_says_round_opens_an_extra_round
    text = <<~MD
      ## run: 2026-08-18T02:00:00+09:00

      ### ラウンド4 (2026-08-18T03:00:00+09:00)

      | 重大度 | 区分 | 該当箇所 | 指摘 | 対応 | モデル |
      | --- | --- | --- | --- | --- | --- |
      | nit | new | a.rb:2 | ラウンド4の指摘 | 修正 (bbbbbbb) | |

      ## 追加ラウンド: マルチモデル化コミットの検証 (新ルールの初回適用)

      | 重大度 | 区分 | 該当箇所 | 指摘 | 対応 | モデル |
      | --- | --- | --- | --- | --- | --- |
      | must-fix | | a.rb:9 | 追加ラウンドの指摘 | 修正 (ccccccc) | fable |
    MD
    result = parse(text)
    rounds = result.runs[0].rounds

    assert_equal [4, 5], rounds.map(&:number)
    assert_equal ['追加ラウンドの指摘'], rounds[1].findings.map(&:note)
    assert_equal 1, result.warnings.size
    assert_match(/番号の無いラウンド/, result.warnings[0][:message])
  end

  def test_suite_line_that_says_none_is_not_a_warning
    text = <<~MD
      ## run: 2026-08-18T02:00:00+09:00

      ### ラウンド1 (2026-08-18T03:00:00+09:00)

      スイート: なし (このリポジトリにテストスイートは存在しない)
    MD
    result = parse(text)
    assert_nil result.runs[0].rounds[0].suite
    assert_empty result.warnings
  end

  def test_merges_extra_columns_into_the_action_when_the_note_split_fails
    text = findings_table('| should-fix | carried-over | test | pkill が無い | 修正。`|| kill` のフォールバックを足した (検証: 実行) | opus |')
    finding = parse(text).runs[0].rounds[0].findings[0]

    assert_equal 'pkill が無い', finding.note
    assert_equal 'fix', finding.action_kind
    assert_equal '実行', finding.verification
  end

  def test_treats_a_split_action_as_mixed
    text = findings_table(
      '| should-fix | | a.rb:1 | x | 見送り (下記1) + 出典明記のみ修正 (29e3629) | |',
      '| nit | | a.rb:2 | y | 記録とコメントを訂正、閾値はユーザー判断へ (下記) | |'
    )
    result = parse(text)
    assert_equal %w[mixed verify_only], result.runs[0].rounds[0].findings.map(&:action_kind)
    assert_empty result.warnings
  end

  def test_parses_suite_lines_that_name_the_suite
    text = <<~MD
      ## run: 2026-08-22T19:35:00+09:00

      ### ラウンド1 (2026-08-22T19:35:00+09:00)

      スイート (ruby/rbs): 995件 53.8s green

      ### ラウンド2 (2026-08-22T20:00:00+09:00)

      スイート: ruby/rbs 999件 48.6s green / soutaro/steep 1319件 213.4s green

      ### ラウンド3 (2026-08-22T20:30:00+09:00)

      スイート: 377件 green (再測なし)
    MD
    result = parse(text)
    rounds = result.runs[0].rounds

    assert_equal 995, rounds[0].suite[:tests]
    assert_in_delta 53.8, rounds[0].suite[:seconds]

    assert_equal 2318, rounds[1].suite[:tests], '複数スイートの行は合計する'
    assert_in_delta 262.0, rounds[1].suite[:seconds]

    assert_nil rounds[2].suite, '件数と秒数が揃わない行はスイートとして数えない'
    assert_equal 1, result.warnings.size
    assert_match(/スイート行/, result.warnings[0][:message])
  end

  def test_does_not_take_a_bare_number_as_a_commit
    text = findings_table('| nit | | a.rb:1 | x | 見送り (下記1234567) | |')
    assert_nil parse(text).runs[0].rounds[0].findings[0].commit
  end

  def test_finding_keeps_raw_cells
    finding = parse(CURRENT).runs[0].rounds[0].findings[0]
    assert_equal 'fable, opus, sonnet (正しさ) / opus (規約)', finding.raw_models
    assert_equal '修正 (dd6dd5f / 検証: 実行)', finding.action
  end
end
