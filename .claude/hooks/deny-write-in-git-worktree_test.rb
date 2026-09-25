#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require 'json'
require 'open3'
require 'tmpdir'
require 'fileutils'

HOOK = File.expand_path('deny-write-in-git-worktree.rb', __dir__)

class DenyWriteInGitWorktreeTest < Minitest::Test
  def setup
    @tmp = Dir.mktmpdir
  end

  def teardown
    FileUtils.remove_entry(@tmp)
  end

  def repo
    @repo ||= begin
      dir = File.join(@tmp, 'repo')
      FileUtils.mkdir_p(dir)
      system('git', 'init', '-q', dir, exception: true)
      dir
    end
  end

  def run_hook(input, env = {})
    _out, err, status = Open3.capture3(env, 'ruby', HOOK, stdin_data: JSON.generate(input))
    [status.exitstatus, err]
  end

  def assert_denied(input, env = {})
    code, err = run_hook(input, env)
    assert_equal 2, code, "expected deny (exit 2), got #{code}: #{err}"
  end

  def assert_allowed(input, env = {})
    code, err = run_hook(input, env)
    assert_equal 0, code, "expected allow (exit 0), got #{code}: #{err}"
  end

  def test_denies_existing_file_in_repo
    path = File.join(repo, 'file.txt')
    File.write(path, 'x')
    assert_denied({ 'tool_input' => { 'file_path' => path } })
  end

  def test_denies_new_file_under_nonexistent_dir_in_repo
    path = File.join(repo, 'new', 'deep', 'file.txt')
    assert_denied({ 'tool_input' => { 'file_path' => path } })
  end

  def test_denies_dot_git_dir_itself
    path = File.join(repo, '.git', 'newfile')
    assert_denied({ 'tool_input' => { 'file_path' => path } })
  end

  def test_denies_notebook_path_in_repo
    path = File.join(repo, 'nb.ipynb')
    assert_denied({ 'tool_input' => { 'notebook_path' => path } })
  end

  def test_allows_outside_repo
    path = File.join(@tmp, 'outside.txt')
    assert_allowed({ 'tool_input' => { 'file_path' => path } })
  end

  def test_allows_when_no_path_given
    assert_allowed({ 'tool_input' => {} })
  end

  def test_denies_non_string_file_path
    assert_denied({ 'tool_input' => { 'file_path' => 123 } })
  end

  def test_denies_malformed_json
    _out, err, status = Open3.capture3('ruby', HOOK, stdin_data: 'not json')
    assert_equal 2, status.exitstatus, err
  end

  def test_denies_dotdot_traversal_into_repo
    # ラウンド1で見つかったすり抜け: ".." を字句正規化せずに祖先を遡ると、
    # 存在しない祖先を挟んだだけで判定対象がリポジトリの外にずれる
    repo
    path = "#{@tmp}/nonexist/../repo/newfile"
    assert_denied({ 'tool_input' => { 'file_path' => path } })
  end

  def test_dotdot_that_lexically_resolves_outside_repo_is_allowed
    # 上のケースの逆: ".." を正しく畳んだ結果が実際にはリポジトリを指さないなら許可する
    repo
    path = "#{@tmp}/nonexist/../../outside-after-normalize"
    refute_includes File.expand_path(path), repo
    assert_allowed({ 'tool_input' => { 'file_path' => path } })
  end

  def test_denies_embedded_newline_before_dotdot
    # ラウンド2で見つかったすり抜け: 文字列の途中に改行があっても ".." は正規化されるべき
    repo
    path = "#{@tmp}/x\n/../repo/newfile"
    assert_denied({ 'tool_input' => { 'file_path' => path } })
  end

  def test_denies_trailing_newline_dotdot
    # ラウンド3で見つかったすり抜け: 末尾の改行を含む ".." は、コマンド置換で
    # 改行が消えるシェル実装だと素通りしていた
    path = "#{repo}/..\n"
    assert_denied({ 'tool_input' => { 'file_path' => path } })
  end

  def test_denies_relative_path_resolved_against_cwd_inside_repo
    assert_denied({ 'tool_input' => { 'file_path' => 'relfile.txt' }, 'cwd' => repo })
  end

  def test_allows_relative_path_resolved_against_cwd_outside_repo
    assert_allowed({ 'tool_input' => { 'file_path' => 'relfile.txt' }, 'cwd' => @tmp })
  end

  def test_denies_tilde_path_into_repo
    assert_denied({ 'tool_input' => { 'file_path' => "~/#{File.basename(repo)}/newfile" } },
                  { 'HOME' => File.dirname(repo) })
  end

  def test_allows_tilde_path_outside_repo
    assert_allowed({ 'tool_input' => { 'file_path' => '~/outside.txt' } }, { 'HOME' => @tmp })
  end

  def test_denies_symlinked_directory_resolving_into_repo
    link = File.join(@tmp, 'link-to-repo')
    File.symlink(repo, link)
    assert_denied({ 'tool_input' => { 'file_path' => File.join(link, 'newfile') } })
  end

  def test_git_dir_env_vars_do_not_override_check_dir
    other = File.join(@tmp, 'other')
    FileUtils.mkdir_p(other)
    system('git', 'init', '-q', other, exception: true)
    path = File.join(repo, 'file.txt')
    assert_denied({ 'tool_input' => { 'file_path' => path } },
                   { 'GIT_DIR' => File.join(other, '.git'), 'GIT_WORK_TREE' => other })
  end

  def test_translated_git_locale_does_not_cause_false_deny
    path = File.join(@tmp, 'outside.txt')
    assert_allowed({ 'tool_input' => { 'file_path' => path } }, { 'LC_ALL' => 'ja_JP.UTF-8' })
  end

  def test_broken_gitdir_file_denies_rather_than_treating_as_outside_any_repo
    vendor = File.join(repo, 'vendor', 'lib')
    FileUtils.mkdir_p(vendor)
    File.write(File.join(vendor, '.git'), "gitdir: #{repo}/.git/modules/does-not-exist\n")
    path = File.join(vendor, 'file.rb')
    assert_denied({ 'tool_input' => { 'file_path' => path } })
  end

  def test_dangling_symlink_denies
    link = File.join(@tmp, 'dangling')
    File.symlink(File.join(@tmp, 'does-not-exist'), link)
    assert_denied({ 'tool_input' => { 'file_path' => link } })
  end
end
