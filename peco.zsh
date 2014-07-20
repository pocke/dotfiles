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


function peco-kill-process()
{
  local ps_cmd='ps aux'
  local get_pid_cmd='sed -E s/^\S+\s+([0-9]+).+$/\1/'
  local ps_line="$(${=ps_cmd} | peco)"

  if [ -z $ps_line ]; then
    return 1
  fi

  local pid="$(echo "${ps_line}" | ${=get_pid_cmd})"
  kill -9 $pid
  zle clear-screen
}
zle -N peco-kill-process
bindkey '^k' peco-kill-process


function peco-pushd-dirs()
{
  local dir="$(dirs -p | peco)"
  eval cd "${dir}"
  zle reset-prompt
}
zle -N peco-pushd-dirs
bindkey '^A' peco-pushd-dirs
