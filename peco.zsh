function peco-select-history()
{
  local tac
  if which tac > /dev/null 2>&1; then
    tac="tac"
  else
    tac="tail -r"
  fi

  BUFFER=$(history -n 1 | eval $tac | peco --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history


function peco-ghq-move()
{
  local selected_dir="$(ghq list --full-path | peco --query "$LBUFFER")"
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-ghq-move
bindkey '^G' peco-ghq-move

# http://hotolab.net/blog/peco_select_path/
function peco-find-file()
{
  local filepath="$(find . | grep -v '/\.git/' | peco)"
  [ -z "$filepath" ] && return
  if [ -n "$LBUFFER" ]; then
    BUFFER="$LBUFFER$filepath"
  else
    if [ -d "$filepath" ]; then
      BUFFER="cd $filepath"
    elif [ -f "$filepath" ]; then
      BUFFER="$EDITOR $filepath"
    fi
  fi
  CURSOR=$#BUFFER
}

zle -N peco-find-file
bindkey '^f' peco-find-file
