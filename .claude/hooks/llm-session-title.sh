#!/usr/bin/env bash
# Claude Code UserPromptSubmit フック: プロンプトの内容からセッションタイトルを生成する
#
# 生成は裏で走らせ、次にフックが発火したときに結果を返す。
# sessionTitle は SessionStart でも受け取れるが、そちらの経路は currentSessionTitle を
# メモリに置くだけで transcript に残らず、さらに agent name まで上書きするので使わない

input=$(cat)

# 生成側は disableAllHooks でフックを止めているが、設定の取りこぼしに備えて二重にする
if [ -n "${TITLE_HOOK_ACTIVE:-}" ]; then
  exit 0
fi

# headless 実行 (claude -p, SDK) では CLAUDE_CODE_ENTRYPOINT が sdk-* / local-agent になる
case "${CLAUDE_CODE_ENTRYPOINT:-}" in
  sdk-* | local-agent)
    exit 0
    ;;
esac

session_id=$(printf '%s' "$input" | jq -r '.session_id // empty')
if [ -z "$session_id" ]; then
  exit 0
fi
# キャッシュのパスに埋めるので、UUID にない文字が来たら触らない
case "$session_id" in
  *[!a-zA-Z0-9_-]*)
    exit 0
    ;;
esac

# session_title は /rename で付けた名前とこのフックが付けた名前で非空になる
session_title=$(printf '%s' "$input" | jq -r '.session_title // empty')
if [ -n "$session_title" ]; then
  exit 0
fi

cache_dir="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/claude-title-hook"
mkdir -p "$cache_dir" || exit 0
# 他人が先に置いていたディレクトリなら使わない (mkdir -p は既存ディレクトリでも成功する)
if [ ! -O "$cache_dir" ] || [ -L "$cache_dir" ]; then
  exit 0
fi
# mkdir -m のモードは作成時にしか効かないので、既存ディレクトリは chmod で締める
chmod 700 "$cache_dir" || exit 0

cache="$cache_dir/$session_id"
pending="$cache.pending"

if [ -s "$cache" ]; then
  jq -n --arg title "$(cat "$cache")" '{
    hookSpecificOutput: {
      hookEventName: "UserPromptSubmit",
      sessionTitle: $title
    }
  }'
  exit 0
fi

# pending があるのは生成中か、直近で生成に失敗したとき。5分が再試行の間隔になる
if [ -n "$(find "$pending" -mmin -5 2>/dev/null)" ]; then
  exit 0
fi

prompt=$(printf '%s' "$input" | jq -r '.prompt // empty | .[0:2000]')
if [ -z "$prompt" ]; then
  exit 0
fi

: > "$pending"

# wip 等のフックが発火して、その出力がタイトルに混ざるのを防ぐ。
# ツールは塞がない。issue の URL だけを貼ったプロンプトでは、本文を読まないとタイトルにならない
generator_settings='{"disableAllHooks": true}'

# 切り離した claude -p がハングしたまま残らないように上限を付ける (timeout が無ければ諦める)
limit=()
for candidate in timeout gtimeout; do
  if command -v "$candidate" > /dev/null 2>&1; then
    limit=("$candidate" -k 10 180)
    break
  fi
done

# --strict-mcp-config: MCP サーバの起動を省く
# 子プロセスが stdout を握ったままだと本体がフックの終了を待つので、fd は全て切り離す
(
  title=$(TITLE_HOOK_ACTIVE=1 "${limit[@]}" claude -p \
    --model sonnet \
    --no-session-persistence \
    --strict-mcp-config \
    --settings "$generator_settings" \
    "以下はコーディングセッションの最初のプロンプトです。このセッションを一覧から見分けるための短いタイトルを1つだけ出力してください。タイトルは必ず日本語で20文字以内。記号や引用符は不要、タイトル以外は一切出力しないでください。

URL や issue 番号だけが書かれている場合は、参照先を読んでタイトルを決めてください。
やってよいのは読み取りだけです。ファイルの作成・編集・削除、git の操作、コメントの投稿など、状態を変える操作はしないでください。

プロンプト:
$prompt" 2> "$cache.err" | grep -m1 '[^[:space:]]')
  # 前置きや拒否文が1行目に来ることがある。指示した20文字の倍を超えたら捨てて次回に回す
  if [ -n "$title" ] && [ "$(printf '%s' "$title" | jq -Rs 'length')" -le 40 ] &&
    printf '%s' "$title" > "$cache.$$.tmp" && mv "$cache.$$.tmp" "$cache"; then
    rm -f "$pending" "$cache.err"
  else
    # pending の mtime は生成開始時なので、失敗時点から5分空けるために打ち直す
    rm -f "$cache.$$.tmp"
    touch "$pending"
  fi
) < /dev/null > /dev/null 2>&1 &
