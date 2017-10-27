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

function peco-open-gh()
{
  local selected_dir="$(ghq list --full-path | sed -e 's!'$HOME'!~!' | peco --query "$LBUFFER")"
  if [ -n "$selected_dir" ]; then
    BUFFER="gh-open ${selected_dir}"
    zle accept-line
  fi
}
zle -N peco-open-gh
bindkey '^o' peco-open-gh


function peco-ghq-move()
{

  local selected_dir="$(ghq list --full-path | sed -e 's!'$HOME'!~!' | peco --query "$LBUFFER")"
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-ghq-move
bindkey '^G' peco-ghq-move

function peco-select-file()
{
  local selected_file="$(git ls-files | peco --initial-filter=Fuzzy)"
  if [ -n "$selected_file" ]; then
    RBUFFER=$selected_file
    CURSOR=$#BUFFER
  fi
  zle clear-screen
}
zle -N peco-select-file
bindkey '^F' peco-select-file

function peco-select-tmux-session()
{
  if [ -n "$TMUX" ]; then
    echo 'Do not use this command in a tmux session.'
    return 1
  fi

  local pecoed="$(cat <(tmux list-sessions) <(ghq list --full-path | sed -e 's!'$HOME'!~!') | peco)"
  if [ -z "$pecoed" ]; then
    return
  fi

  if echo "$pecoed" | ruby -e 'exit(!!(gets.chomp =~ /\[\d+x\d+\](\s\(attached\))?$/))'; then
    local session="$(echo "$pecoed" | cut -d : -f 1)"
    BUFFER="tmux a -t $session"
    zle accept-line
  else
    BUFFER="cd $pecoed; t"
    zle accept-line
  fi
}
zle -N peco-select-tmux-session
bindkey '^T' peco-select-tmux-session
