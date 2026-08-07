# Claude Code skills

`~/.claude/skills` からシンボリックリンクされている (itamae/roles/main.rb)。

## 自作のスキル

`refine` / `self-review` / `wip` はここで直接書いている。更新も直接編集する。

## 外部から入れたスキル

`gh skill install` で入れたものは、SKILL.md の frontmatter に `metadata.github-repo` /
`github-ref` / `github-tree-sha` / `version` が埋め込まれる。`gh skill update` はこれを見て
差分を検出するので、どこ由来かは frontmatter を見れば分かる。frontmatter に残らないのは
「どの agent / scope で入れたか」だけなので、それをここに書いておく。

### gh-stack

stacked PR (`gh stack`) の操作方法。GitHub 公式。

```sh
gh skill install github/gh-stack gh-stack --agent claude-code --scope user
gh skill update   # 更新
```

スキル本体とは別に、`gh` 拡張のインストールが必要 (dotfiles では管理していない)。

```sh
gh extension install github/gh-stack
```
