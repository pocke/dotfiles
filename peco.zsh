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

  local selected_dir="$(ghq list --full-path | sed -e 's!'$HOME'!~!' | peco --query "$LBUFFER")"
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-ghq-move
bindkey '^G' peco-ghq-move

function peco-select-tmux-session()
{
  local pecoed="$(cat <(tmux list-sessions) <(ghq list --full-path | sed -e 's!'$HOME'!~!') | peco)"
  if [ -z "$pecoed" ]; then
    return
  fi

  if echo "$pecoed" | ruby -e 'exit(!!(gets.chomp =~ %r!^.+: \d+ windows \(created!))'; then
    local session="$(echo "$pecoed" | cut -d : -f 1)"
    if [ -n "$TMUX" ]; then
      BUFFER="tmux switch-client -t $session"
    else
      BUFFER="tmux a -t $session"
    fi
  else
    if [ -n "$TMUX" ]; then
      BUFFER="cd $pecoed; tmux switch-client -t \$(t -dP)"
    else
      BUFFER="cd $pecoed; t"
    fi
  fi
  zle accept-line
}
zle -N peco-select-tmux-session
bindkey '^T' peco-select-tmux-session
