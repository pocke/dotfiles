#!/usr/bin/env ruby
# frozen_string_literal: true

# reviewer agent がうっかり Edit/Write/NotebookEdit で git の作業ツリー (.git 配下を含む) に
# 書き込むのを止める PreToolUse hook。悪意ある入力は想定していない

require 'json'
require 'open3'

def deny(message)
  warn message
  exit 2
end

def allow
  exit 0
end

def resolve_check_dir(file_path, cwd)
  # ".." を残したまま dirname で遡ると、実際の書き込み先とは別の祖先を見てしまう。
  # File.expand_path は "." ".." "~" を解決してくれるので、遡る前に呼んでおく
  target = File.expand_path(file_path, cwd)

  node = target
  node = File.dirname(node) until File.exist?(node) || File.symlink?(node) || node == '/'

  resolved = File.realpath(node)
  File.directory?(resolved) ? resolved : File.dirname(resolved)
end

begin
  input = JSON.parse($stdin.read)
  tool_input = input['tool_input'] || {}
  file_path = tool_input['file_path'] || tool_input['notebook_path']

  allow if file_path.nil?
  deny 'file_path/notebook_path が文字列でない' unless file_path.is_a?(String)

  cwd = input['cwd']
  cwd = Dir.pwd unless cwd.is_a?(String) && !cwd.empty?

  check_dir = resolve_check_dir(file_path, cwd)

  # GIT_DIR/GIT_WORK_TREE が環境に残っていると check_dir と無関係なリポジトリを見てしまう。
  # git のメッセージも LC_ALL 次第で翻訳され、下の文字列一致に届かなくなる
  git_env = ENV.keys.grep(/\AGIT_/).to_h { |k| [k, nil] }.merge('LC_ALL' => 'C')
  stdout, stderr, status = Open3.capture3(
    git_env, 'git', '-C', check_dir, 'rev-parse', '--is-inside-work-tree', '--is-inside-git-dir'
  )

  if status.success?
    is_work_tree, is_git_dir = stdout.split("\n")
    if is_work_tree == 'true' || is_git_dir == 'true'
      deny "reviewer agent は git の作業ツリーの中に書き込めない (解決後のパス: #{check_dir})"
    end
    allow
  elsif stderr.include?('not a git repository (or any of the parent directories)')
    allow
  else
    deny "git の状態を確認できない (#{check_dir}): #{stderr.strip}"
  end
rescue StandardError => e
  deny "#{e.class}: #{e.message}"
end
