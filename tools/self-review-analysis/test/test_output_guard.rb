require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'open3'
require_relative '../lib/output_guard'

class TestOutputGuard < Minitest::Test
  def setup
    @dir = Dir.mktmpdir('guard-test')
    @repo = File.join(@dir, 'repo')
    FileUtils.mkdir_p(@repo)
    Open3.capture2e('git', 'init', '-q', @repo)
  end

  def teardown = FileUtils.remove_entry(@dir)

  def reason(path) = OutputGuard.refusal(path)

  def test_allows_a_directory_outside_any_repository
    assert_nil reason(File.join(@dir, 'outside'))
    assert_nil reason(File.join(@dir, 'outside', 'deeper', 'still'))
  end

  def test_refuses_a_directory_inside_a_repository
    assert_match(/git 管理下/, reason(File.join(@repo, 'out')))
  end

  # 1 階層しか遡らないと、途中のディレクトリが無いときに git が起動エラーになり、
  # 「リポジトリではない」と誤判定して書き込みが通ってしまう
  def test_refuses_a_directory_inside_a_repository_when_several_levels_are_missing
    assert_match(/git 管理下/, reason(File.join(@repo, 'a', 'b', 'c')))
  end

  def test_refuses_a_directory_inside_the_git_directory
    assert_match(/git 管理下/, reason(File.join(@repo, '.git', 'stash')))
  end

  def test_refuses_a_path_that_escapes_through_a_symlink
    link = File.join(@dir, 'link')
    File.symlink(@repo, link)
    assert_match(/git 管理下/, reason(File.join(link, 'out')))
  end

  def test_rejects_a_machine_name_that_walks_out_of_the_output_directory
    assert_nil OutputGuard.invalid_machine('g-gear')
    assert_nil OutputGuard.invalid_machine('box_1.local')
    assert_match(/マシン名/, OutputGuard.invalid_machine('../../repo/via-machine'))
    assert_match(/マシン名/, OutputGuard.invalid_machine('has space'))
    assert_match(/マシン名/, OutputGuard.invalid_machine(''))
  end

  # `.gitignore` は指定された出力先の中に置く。親に置くと、`--out ~/report` のような指定で
  # ユーザーが触っていないディレクトリ (この例では ~/) に `*` を書いてしまう
  def test_prepares_a_directory_that_git_add_will_not_pick_up
    target = File.join(@dir, 'outside', 'collected')
    OutputGuard.prepare!(target)

    assert_equal '040700', format('%06o', File.stat(target).mode)
    assert_equal "*\n", File.read(File.join(target, '.gitignore'))
    assert_equal '100600', format('%06o', File.stat(File.join(target, '.gitignore')).mode)
    refute_path_exists File.join(File.dirname(target), '.gitignore')
  end

  def test_writes_files_only_for_the_owner
    target = File.join(@dir, 'outside')
    OutputGuard.prepare!(target)
    OutputGuard.write(File.join(target, 'a.md'), 'body')

    assert_equal '100600', format('%06o', File.stat(File.join(target, 'a.md')).mode)
    assert_equal 'body', File.read(File.join(target, 'a.md'))
  end
end
