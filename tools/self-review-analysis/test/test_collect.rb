# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative '../collect'

class TestCollect < Minitest::Test
  def test_reconstructs_the_branch_from_the_artifacts_path
    assert_equal 'claude/foo', Collect.branch_from('/home/u/ghq/x/repo/.claude/artifacts/claude/foo/self-review.md')
    assert_equal '8da8d01', Collect.branch_from('/home/u/ghq/x/repo/.claude/artifacts/8da8d01/self-review.md')
    # worktree の中にも .claude/artifacts がある。後ろの artifacts を採る
    assert_equal 'wt', Collect.branch_from('/home/u/ghq/x/repo/.claude/worktrees/a/.claude/artifacts/wt/self-review.md')
    assert_nil Collect.branch_from('/home/u/ghq/x/repo/self-review.md')
  end

  def test_repo_key_is_relative_to_the_root
    assert_equal 'ghq/github.com/pocke/foo', Collect.repo_key('/home/u/ghq/github.com/pocke/foo', '/home/u/ghq')
    assert_equal 'dotfiles', Collect.repo_key('/home/u/dotfiles', '/home/u/dotfiles')
    assert_equal 'dotfiles', Collect.repo_key(nil, '/home/u/dotfiles')
  end

  def test_numstat_splits_documents_from_code
    output = "10\t2\tREADME.md\n3\t1\tlib/a.rb\n-\t-\timg.png\n"
    summary = Collect.numstat_summary(output)

    assert_equal 3, summary['files']
    assert_equal 12, summary['doc_lines']
    assert_equal 4, summary['code_lines']
    assert_equal 1, summary['binary_files']
  end

  def test_base_commit_comes_from_the_run_header_before_the_preamble
    run = SelfReviewLog::Run.new(header: '- 基準コミット: `abc1234`')
    assert_equal 'abc1234', Collect.base_commit(run, '- 基準コミット: `9999999`')

    empty = SelfReviewLog::Run.new(header: '')
    assert_equal '9999999', Collect.base_commit(empty, '- 基準コミット: `9999999`')
  end

  def test_finds_logs_without_following_a_symlinked_log
    Dir.mktmpdir('collect-test') do |dir|
      artifacts = File.join(dir, 'repo', '.claude', 'artifacts', 'topic')
      FileUtils.mkdir_p(artifacts)
      File.write(File.join(artifacts, 'self-review.md'), "## run: 2026-08-29T10:00:00+09:00\n")

      secret = File.join(dir, 'secret')
      File.write(secret, 'private key')
      linked = File.join(dir, 'repo', '.claude', 'artifacts', 'linked')
      FileUtils.mkdir_p(linked)
      File.symlink(secret, File.join(linked, 'self-review.md'))

      found = Collect.find_logs([dir]).map(&:last)
      assert_equal [File.join(artifacts, 'self-review.md')], found
    end
  end

  # `--root ~/ghq --root ~/ghq2` を並べたとき、~/ghq2 のパスが ~/ghq に属すると判定されると
  # リポジトリキーが衝突する。区切り文字まで見ないと `ghq2` が `ghq` の接頭辞に当たる
  def test_repo_root_stays_inside_the_root_it_was_given
    Dir.mktmpdir('root-test') do |dir|
      inside = File.join(dir, 'ghq', 'a', 'repo')
      sibling = File.join(dir, 'ghq2', 'a', 'repo')
      # root 自身がリポジトリのケース (~/dotfiles を root に指定したときの形)
      repo_root = File.join(dir, 'dotfiles')
      [inside, sibling, repo_root].each { |path| FileUtils.mkdir_p(File.join(path, '.git')) }

      root = File.join(dir, 'ghq')
      assert_equal inside, Collect.repo_root_from(inside, root)
      assert_equal repo_root, Collect.repo_root_from(repo_root, repo_root)
      assert_nil Collect.repo_root_from(sibling, root), '別の root のパスを自分のものと数えない'
    end
  end
end
