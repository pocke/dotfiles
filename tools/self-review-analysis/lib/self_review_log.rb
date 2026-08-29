# frozen_string_literal: true

require 'time'

# `.claude/artifacts/<branch>/self-review.md` を構造化する。
#
# 対応する書式は 2 つある。
#
# - 現行: `## run: <日時>` で run を区切り、`### ラウンドN (<日時>)` を run の中に置く
# - 旧: run 見出しが無く、`## ラウンドN` がトップレベルに並ぶ (指摘テーブルにモデル列も無い)
#
# 列の並びはヘッダ行から読む。列が増減しても位置を決め打ちしない。
module SelfReviewLog
  Finding = Struct.new(
    :severity, :category, :location, :note, :action, :models,
    :action_kind, :verification, :commit, :gate_first_round,
    :raw_models, :raw_category, :withdrawn, :line,
    keyword_init: true
  )
  Reviewer = Struct.new(:group, :model, :verdict, :line, keyword_init: true)
  Round = Struct.new(:number, :started_at, :started_at_raw, :suite, :reviewers, :findings, :line, keyword_init: true)
  Run = Struct.new(:index, :started_at, :started_at_raw, :header, :rounds, :line, :implicit, keyword_init: true)
  Result = Struct.new(:runs, :preamble, :warnings, keyword_init: true)

  MODEL_NAMES = %w[fable opus sonnet haiku].freeze
  VERIFICATIONS = %w[実行 読み合わせ 環境不足 検証なし].freeze
  CATEGORIES = %w[carried-over regression fresh-surface new].freeze

  RUN_HEADING = /\A##\s+run:\s*(?<time>.*?)\s*\z/
  # `### ラウンド5 追加分 (レビュアー再開、2026-08-21T17:34:30+09:00)` のように、
  # 番号の後ろに語が続く見出しが実ログにある。番号だけを必須にして、残りは rest で受ける。
  ROUND_HEADING = /\A(?<hashes>\#{2,4})\s+ラウンド\s*(?<number>\d+)\s*(?<rest>.*?)\s*\z/
  HEADING = /\A(?<hashes>\#{1,6})\s+\S/
  TIMESTAMP = /\d{4}-\d{2}-\d{2}T[\d:]+(?:[+-]\d{2}:\d{2}|Z)?/
  SUITE_PREFIX = /\Aスイート/
  # `995件 53.8s` の組。1 行に複数のスイートを並べたログがある
  SUITE_PAIR = /(?<tests>\d+)\s*件\s+(?<seconds>[\d.]+)\s*s/

  # 対応列の語から対応の種別を決める。並び順が優先順位で、先に当たったものを採る。
  ACTION_KINDS = [
    [/\Aゲートで記録のみ/, 'gated'],
    [/\A(?:一部)?修正/, 'fix'],
    [/\A検証のみ|検証のやり直し|記録[とをのも].{0,10}?(?:訂正|追記|補足)/, 'verify_only'],
    [/\A見送り/, 'dropped'],
    [/\A回答/, 'answered'],
    [/\A取り消し/, 'reverted'],
    [/\A打ち切り/, 'aborted'],
    # 「6 の整理で対応」「ループ後の整理で amend」— ループを止めずに終了後の整理へ送ったもの
    [/整理|amend/, 'cleanup'],
  ].freeze

  def self.parse(text, source: nil)
    Parser.new(text, source).parse
  end

  # `\|` はセル内の `|` として扱う (ログの書式規約)
  def self.split_row(line)
    body = line.strip
    body = body[1..] if body.start_with?('|')
    body = body[0..-2] if body.end_with?('|') && !body.end_with?('\\|')

    cells = []
    buf = +''
    i = 0
    while i < body.length
      char = body[i]
      if char == '\\' && body[i + 1] == '|'
        buf << '|'
        i += 2
      elsif char == '|'
        cells << buf.strip
        buf = +''
        i += 1
      else
        buf << char
        i += 1
      end
    end
    cells << buf.strip
    cells
  end

  def self.parse_time(raw)
    return nil if raw.nil?

    cleaned = raw.strip.sub(/\s*頃\z/, '').sub(/\A[(（]|[)）]\z/, '')
    return nil if cleaned.empty?

    Time.parse(cleaned)
  rescue ArgumentError
    nil
  end

  def self.parse_models(cell)
    return [] if cell.nil?

    cell.scan(/\b(#{MODEL_NAMES.join('|')})\b/).flatten.uniq
  end

  # 区分列は `carried-over (ラウンド3で記録のみ)` のように注記が付くことがある。
  def self.parse_category(cell)
    return nil if cell.nil? || cell.empty?

    CATEGORIES.find { |category| cell.start_with?(category) }
  end

  def self.parse_action(cell)
    return { kind: 'none' } if cell.nil? || cell.empty?

    kind = ACTION_KINDS.find { |pattern, _| cell.match?(pattern) }&.last || 'other'
    # 「見送り (下記1) + 出典明記のみ修正 (29e3629)」— 1 件の中で扱いが割れているもの。
    # 先頭語だけで決めると、同じセルに残っている見送りや修正が件数から消える
    kind = 'mixed' if cell.include?('修正') && cell.include?('見送り')
    {
      kind: kind,
      verification: cell[/検証:\s*(#{VERIFICATIONS.join('|')})/, 1],
      commit: cell[/\(([0-9a-f]{7,40})\b/, 1] || cell[/\b([0-9a-f]{7,40})\b/, 1],
      gate_first_round: cell[/初出:\s*ラウンド\s*(\d+)/, 1]&.to_i,
    }
  end

  class Parser
    def initialize(text, source)
      @lines = text.lines.map(&:chomp)
      @source = source
      @runs = []
      @warnings = []
      @preamble = []
      @run = nil
      @round = nil
    end

    def parse
      index = 0
      while index < @lines.length
        line = @lines[index]

        if (match = RUN_HEADING.match(line))
          start_run(match[:time], index)
        elsif (match = ROUND_HEADING.match(line)) && open_round(match, index)
          # open_round が扱った
        elsif (match = HEADING.match(line))
          handle_plain_heading(match, line, index)
          collect_header_line(line)
        elsif line.match?(SUITE_PREFIX)
          record_suite(line, index)
        elsif line.start_with?('|')
          index = consume_table(index)
          next
        elsif !line.strip.empty?
          collect_header_line(line)
        end

        index += 1
      end

      Result.new(runs: @runs, preamble: @preamble.join("\n"), warnings: @warnings)
    end

    private

    # run 見出しからその run の最初のラウンド見出しまでの記述を header に入れる。
    # 基準コミットと依頼の要約はここに書かれる。最初の run より前の記述は preamble に残す。
    def collect_header_line(line)
      return @preamble << line if @run.nil?

      @run.header = [@run.header, line].reject { |part| part.to_s.empty? }.join("\n") if @round.nil?
    end

    def start_run(raw_time, line_index, implicit: false)
      @run = Run.new(
        index: @runs.size,
        started_at: SelfReviewLog.parse_time(raw_time),
        started_at_raw: raw_time,
        header: '',
        rounds: [],
        line: line_index + 1,
        implicit: implicit
      )
      @round = nil
      @runs << @run
    end

    # run 見出しの無い旧書式では、最初のラウンドで run を 1 つ作る。
    def ensure_run(line_index)
      return @run if @run

      start_run(nil, line_index, implicit: true)
      @run
    end

    def close_round = @round = nil

    # `##` の見出しはラウンドを閉じる。ループ終了後の整理やまとめの表を、
    # 直前のラウンドの指摘として数えないため。
    #
    # 例外は `## 追加ラウンド: マルチモデル化コミットの検証` のように、
    # 括弧の外にラウンドと書きながら番号を振っていない見出し。実ログではこれが本物のラウンドで、
    # 閉じると 20 件以上の指摘が行き場を失う。番号を振り直して続きのラウンドとして数える。
    def handle_plain_heading(match, line, line_index)
      return unless match[:hashes].length <= 2

      close_round
      return if ROUND_HEADING.match?(line)
      return unless line.sub(/\([^)]*\)/, '').include?('ラウンド')
      return if @run.nil?

      number = (@run.rounds.map(&:number).max || 0) + 1
      warn(line_index, "番号の無いラウンドの見出しを ラウンド#{number} として数えた")
      @round = Round.new(number: number, started_at: nil, started_at_raw: nil, suite: nil, reviewers: [], findings: [], line: line_index + 1)
      @run.rounds << @round
    end

    # ラウンド見出しの扱いは 4 通りある。ラウンド見出しでなければ false を返して呼び出し元に戻す。
    #
    # - 番号の後ろに語が続き、その番号のラウンドが既にある (`ラウンド5 追加分`) → そのラウンドの続き
    # - run 見出しの無い旧書式で番号が戻った → そこから次の run が始まっている
    # - 番号の後ろに語が続き、日時も無く、その番号のラウンドがまだ無い
    #   (`## ラウンド1 → 3 の hash 対応`) → ラウンド見出しではなく、ただの見出し
    # - それ以外は新しいラウンド
    def open_round(match, line_index)
      number = match[:number].to_i
      rest = match[:rest].to_s
      raw_time = rest[TIMESTAMP]
      suffix = !rest.sub(/\([^)]*\)/, '').strip.empty?
      run = ensure_run(line_index)
      existing = run.rounds.find { |round| round.number == number }

      if existing && suffix
        @round = existing
        return true
      end
      return false if suffix && raw_time.nil?

      if existing && run.implicit
        start_run(nil, line_index, implicit: true)
        run = @run
      elsif existing
        warn(line_index, "同じ番号のラウンドが 2 回出てくる (ラウンド#{number})")
      end

      @round = Round.new(
        number: number,
        started_at: SelfReviewLog.parse_time(raw_time),
        started_at_raw: raw_time,
        suite: nil,
        reviewers: [],
        findings: [],
        line: line_index + 1
      )
      run.rounds << @round
      run.started_at ||= @round.started_at
      true
    end

    # スイート行は `スイート: 120件 8.4s green` が基本形だが、
    # スイート名を添えたり 1 行に 2 つ並べたりする書き方が実ログにある。件数と秒数の組を全部拾って足す。
    def record_suite(line, line_index)
      pairs = line.to_enum(:scan, SUITE_PAIR).map { Regexp.last_match }
      if pairs.empty?
        warn(line_index, 'スイート行から件数と実行時間を読めない') unless line.match?(/\Aスイート[^:：]*[:：]\s*(?:なし|無し)/)
        return
      end
      if @round.nil?
        warn(line_index, 'スイート行がラウンドの外にある')
        return
      end

      @round.suite = {
        tests: pairs.sum { |pair| pair[:tests].to_i },
        seconds: pairs.sum { |pair| pair[:seconds].to_f }.round(2),
        status: line[(pairs.last.end(0))..].to_s.strip,
        suites: pairs.size,
        raw: line,
      }
    end

    # 連続する `|` 始まりの行を 1 つのテーブルとして読み、次の行の位置を返す。
    def consume_table(start_index)
      rows = []
      index = start_index
      while index < @lines.length && @lines[index].lstrip.start_with?('|')
        rows << [index, SelfReviewLog.split_row(@lines[index])]
        index += 1
      end

      header = rows.first[1]
      body = rows.drop(1).reject { |_, cells| separator?(cells) }

      if header.include?('重大度')
        body.each { |line_index, cells| add_finding(header, cells, line_index) }
      elsif header.any? { |cell| cell.casecmp?('verdict') }
        body.each { |line_index, cells| add_reviewer(header, cells, line_index) }
      end

      index
    end

    def separator?(cells)
      cells.all? { |cell| cell.match?(/\A:?-{2,}:?\z/) }
    end

    def add_finding(header, cells, line_index)
      cells = fit_to_header(header, cells, line_index)
      return if cells.nil?

      row = header.zip(cells).to_h
      action = SelfReviewLog.parse_action(row['対応'])
      raw_models = row['モデル']
      raw_severity = presence(row['重大度'])
      raw_category = presence(row['区分'])

      finding = Finding.new(
        severity: raw_severity&.delete('~'),
        category: SelfReviewLog.parse_category(raw_category),
        location: presence(row['該当箇所']),
        note: presence(row['指摘']),
        action: presence(row['対応']),
        models: SelfReviewLog.parse_models(raw_models),
        action_kind: action[:kind],
        verification: action[:verification],
        commit: action[:commit],
        gate_first_round: action[:gate_first_round],
        raw_models: presence(raw_models),
        raw_category: raw_category,
        withdrawn: raw_severity&.start_with?('~~') || false,
        line: line_index + 1
      )

      if @round.nil?
        warn(line_index, '指摘テーブルがラウンドの外にある')
        return
      end
      warn(line_index, "区分が未知の値: #{raw_category}") if raw_category && finding.category.nil?
      warn(line_index, "対応列を分類できない: #{finding.action}") if finding.action_kind == 'other'

      @round.findings << finding
    end

    # セル数がヘッダと合わない行を救う。
    # 多い側の原因は自由記述の列での `|` のエスケープ漏れ (`(/|\z)`、`|| kill` など)。
    # 指摘列と対応列のどちらで漏れたかは、畳んだ結果の対応列が分類できるかで決める。
    # 畳む先を間違えても、両端にある重大度・区分・モデルの値は保てる。
    def fit_to_header(header, cells, line_index)
      return cells if cells.length == header.length

      if cells.length < header.length
        warn(line_index, "指摘テーブルの列数がヘッダより少ない (ヘッダ #{header.length} / 行 #{cells.length})")
        return nil
      end

      candidates = ['指摘', '対応'].filter_map { |name| header.index(name) }
      if candidates.empty?
        warn(line_index, "指摘テーブルの列数がヘッダと違う (ヘッダ #{header.length} / 行 #{cells.length})")
        return nil
      end

      merged = candidates.map { |at| merge_cells(header, cells, at) }
      action_at = header.index('対応')
      best = merged.find { |row| action_at && SelfReviewLog.parse_action(row[action_at])[:kind] != 'other' } || merged.first

      warn(line_index, "指摘テーブルの列数がヘッダより多い (ヘッダ #{header.length} / 行 #{cells.length})。`|` のエスケープ漏れとみなして #{header[candidates[merged.index(best)]]}列に畳んだ")
      best
    end

    def merge_cells(header, cells, merge_at)
      excess = cells.length - header.length
      cells[0, merge_at] + [cells[merge_at, excess + 1].join('|')] + cells[(merge_at + excess + 1)..]
    end

    def add_reviewer(header, cells, line_index)
      unless cells.length == header.length
        warn(line_index, "レビュアーテーブルの列数がヘッダと違う (ヘッダ #{header.length} / 行 #{cells.length})")
        return
      end

      row = header.zip(cells).to_h
      verdict_key = header.find { |cell| cell.casecmp?('verdict') }
      reviewer = Reviewer.new(
        group: presence(row['観点グループ'] || row['観点'] || cells[0]),
        model: presence(row['モデル']),
        verdict: presence(row[verdict_key]),
        line: line_index + 1
      )

      if @round.nil?
        warn(line_index, 'レビュアーテーブルがラウンドの外にある')
        return
      end

      @round.reviewers << reviewer
    end

    def presence(value)
      return nil if value.nil?

      stripped = value.strip
      stripped.empty? ? nil : stripped
    end

    def warn(line_index, message)
      @warnings << { source: @source, line: line_index + 1, message: message, raw: @lines[line_index] }
    end
  end
end
