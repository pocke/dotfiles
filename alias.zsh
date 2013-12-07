### alias
alias ls="ls --color=auto -F"
alias la="ls -A"
alias ll="ls -l"
alias lla='ls -Al'
alias df="df -h"
alias du='du -h'
alias cp='cp -v'
alias mv='mv -v'
alias vi='vim'
which yaourt > /dev/null 2>&1 && alias yao='yaourt -Syua'

### global alias
alias -g G='| grep'
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g C='| xsel --input --clipboard'
alias -g N='> /dev/null 2>&1'
alias -g ALL='**/*~.git/*~*/.git/*(.)'

### suffix alias
function extract() {
  local tmp_dir="$(mktemp -d)"
  local zip_file_name="$(basename "$1")"
  case $1 in
    (*.tar.gz)
      local command='tar xzvf'
      local suffix='.tar.gz' ;;
    (*.tgz)
      local command='tar xzvf'
      local suffix='.tgz' ;;
    (*.tar.xz)
      local command='tar Jxvf'
      local suffix='.tar.xz' ;;
    (*.zip)
      local command='unzip'
      local suffix='.zip' ;;
    (*.lzh)
      local command='lha e'
      local suffix='.lzh' ;;
    (*.tar.bz2)
      local command='tar xjvf'
      local suffix='.tar.bz2' ;;
    (*.tbz)
      local command='tar xjvf'
      local suffix='.tbz' ;;
    (*.tar.Z)
      local command='tar zxvf'
      local suffix='.tar.Z' ;;
    (*.gz)
      local command='gzip -dc'
      local suffix='.gz' ;;
    (*.bz2)
      local command='bzip2 -dc'
      local suffix='.bz2' ;;
    (*.Z)
      local command='uncompress'
      local suffix='.Z' ;;
    (*.tar)
      local command='tar xvf'
      local suffix='.tar' ;;
    (*.arj)
      local command='unarj'
      local suffix='.arg' ;;
  esac
  'cp' "$1" "${tmp_dir}"
  (
    cd "${tmp_dir}"
    ${=command} ${zip_file_name}
    rm "${zip_file_name}"
  )
  if [[ "$(ls "${tmp_dir}" | wc -l)" == '1' && "$(ls -F "${tmp_dir}" | grep '/' | wc -l)" == '1' ]]; then
    'cp' "${tmp_dir}/"* ./ -R
  else
    local d="$(basename "${zip_file_name}" "${suffix}")"
    mkdir "${d}"
    'cp' "${tmp_dir}/"* "${d}" -R
  fi
  rm -rf "${tmp_dir}"
}
alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,tar,arj,xz}=extract
alias -s rb=ruby
