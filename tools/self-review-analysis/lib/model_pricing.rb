# frozen_string_literal: true

# モデル別の単価。self-review 1 run のトークン消費を金額に直すために使う。
#
# 出典: claude-api skill の Current Models 表 (キャッシュ日 2026-06-24) と
# shared/prompt-caching.md の "Cache reads cost ~0.1x base input price.
# Cache writes cost 1.25x for 5-minute TTL, 2x for 1-hour TTL"。
# 単価は変わるので、レポートには PRICED_AT を必ず添える。
module ModelPricing
  PRICED_AT = '2026-06-24'.freeze

  # USD / 1M tokens
  PRICES = {
    'claude-fable-5' => { input: 10.0, output: 50.0 },
    'claude-mythos-5' => { input: 10.0, output: 50.0 },
    'claude-opus-5' => { input: 5.0, output: 25.0 },
    'claude-opus-4-8' => { input: 5.0, output: 25.0 },
    'claude-opus-4-7' => { input: 5.0, output: 25.0 },
    'claude-opus-4-6' => { input: 5.0, output: 25.0 },
    'claude-sonnet-5' => { input: 2.0, output: 10.0 },
    'claude-sonnet-4-6' => { input: 3.0, output: 15.0 },
    'claude-haiku-4-5' => { input: 1.0, output: 5.0 },
  }.freeze

  CACHE_READ_RATE = 0.1
  CACHE_WRITE_5M_RATE = 1.25
  CACHE_WRITE_1H_RATE = 2.0

  # `claude-opus-5[1m]` のような context window の注記を落とす
  def self.normalize(model)
    return nil if model.nil?

    model.sub(/\[[^\]]*\]\z/, '')
  end

  def self.known?(model) = PRICES.key?(normalize(model))

  # usage は Transcript.blank_usage と同じ形のハッシュ。単価が分からないモデルは nil を返す。
  def self.cost(model, usage)
    price = PRICES[normalize(model)]
    return nil if price.nil?

    per_token = price[:input] / 1_000_000.0
    out_per_token = price[:output] / 1_000_000.0

    usage['input'].to_i * per_token +
      usage['output'].to_i * out_per_token +
      usage['cache_read'].to_i * per_token * CACHE_READ_RATE +
      usage['cache_write_5m'].to_i * per_token * CACHE_WRITE_5M_RATE +
      usage['cache_write_1h'].to_i * per_token * CACHE_WRITE_1H_RATE
  end

  # モデル別 usage のハッシュ {model => usage} をまとめて金額にする。
  # 単価不明のモデルがあれば unpriced に名前を残す。
  def self.total_cost(usage_by_model)
    total = 0.0
    unpriced = []
    usage_by_model.each do |model, usage|
      # `<synthetic>` のような、推論を伴わないメッセージに付く擬似 ID。金額は欠けていない
      next if usage.values.all? { |value| value.to_i.zero? }

      amount = cost(model, usage)
      if amount.nil?
        unpriced << model
      else
        total += amount
      end
    end
    { usd: total, unpriced: unpriced.uniq }
  end
end
