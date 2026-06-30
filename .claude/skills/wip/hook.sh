f="$dir/.claude/artifacts/$branch/wip.md"
if [ -f "$f" ]; then
  printf '<wip-doc branch="%s" path=".claude/artifacts/%s/wip.md">\n' "$branch" "$branch"
  cat "$f"
  printf '\n</wip-doc>\n'
  printf 'これはこのブランチの作業メモ。節目（要件確定/変更・作成物の進展・残アクション消化・セッション終了前）で .claude/artifacts/%s/wip.md を「現在状態のスナップショット」として上書き更新すること（追記でログ化しない）。手続き・テンプレは /wip。\n' "$branch"
else
  printf 'このブランチ（%s）の作業メモ .claude/artifacts/%s/wip.md は未作成。腰を据えた作業なら /wip でゴール・要件をヒアリングしつつ作成してよい。\n' "$branch" "$branch"
fi
