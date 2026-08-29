# frozen_string_literal: true

require 'fileutils'
require 'open3'

# 収集物と分析結果の置き場を守る。
#
# 集めたログはレビュー対象リポジトリの本文をそのまま含む。pocke/dotfiles は public なので、
# git 管理下に 1 度でも書けると公開の経路ができる。collect.rb と analyze.rb の両方から使う。
module OutputGuard
  # `..` や空白でパスを抜けられないようにする。hostname に使える文字はこれで足りる
  MACHINE_NAME = /\A[A-Za-z0-9._-]+\z/

  # git 管理下なら止める理由を返す。判定できなかったときも止める (nil は「安全と確かめられた」の意味)。
  def self.refusal(dir)
    target = File.expand_path(dir)
    existing = target
    existing = File.dirname(existing) until File.exist?(existing) || existing == File.dirname(existing)
    real = File.realpath(existing)

    toplevel, status = Open3.capture2e('git', '-C', real, 'rev-parse', '--show-toplevel')
    inside_git_dir, = Open3.capture2e('git', '-C', real, 'rev-parse', '--is-inside-git-dir')

    # `.git` の中では --show-toplevel が失敗する。git の失敗を「管理外」と読むと、そこが素通りになる
    return "出力先 #{target} は git 管理下 (#{real} は .git の中) にある。" if inside_git_dir.strip == 'true'
    return nil unless status.success?

    "出力先 #{target} は git 管理下 (#{toplevel.strip}) にある。"
  end

  def self.invalid_machine(name)
    return nil if name.to_s.match?(MACHINE_NAME)

    "マシン名にパス区切りや空白を含められない: #{name.inspect}"
  end

  # 出力先を 0700 で作り、その中に `*` だけの .gitignore を置く。
  # ガードをすり抜けたり --force を使ったりしたときでも `git add -A` で拾われないようにする。
  # `*` は .gitignore 自身にも当たるので、このディレクトリの中身はまとめて無視される。
  def self.prepare!(dir)
    FileUtils.mkdir_p(dir, mode: 0o700)
    File.chmod(0o700, dir)
    gitignore = File.join(dir, '.gitignore')
    write(gitignore, "*\n") unless File.exist?(gitignore)
    dir
  end

  def self.write(path, content)
    File.open(path, 'w', 0o600) { |file| file.write(content) }
  end

  def self.open(path, &block)
    File.open(path, 'w', 0o600, &block)
  end
end
