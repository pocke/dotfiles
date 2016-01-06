### alias
alias ls="ls --color=auto -F"
alias la="ls -A"
alias ll="ls -l"
alias lla='ls -Al'
alias df="df -h"
alias du='du -h'
alias free='free -h'
alias cp='cp -v'
alias mv='mv -v'
alias vi='vim'
alias grep='grep --binary-files=without-match --color=auto'
alias jman='LANG=ja_JP.UTF-8 man'
alias be='bundle exec'
alias b='bundle'
alias tmux='TERM=screen-256color tmux -2'
alias t='tmux'
alias sozshrc='source ~/.zshrc'
alias ghq-open='gh-open $(ghq list -p | peco)'
function -(){cd -} # alias では実現できない?

### global alias
alias -g G='| grep'
alias -g H='| head'
alias -g T='| tail'
if which xsel > /dev/null 2>&1; then
  alias -g C='| xsel --input --clipboard'
fi
alias -g N='> /dev/null 2>&1'
alias -g ALL='**/*~.git/*~*/.git/*(.)'
alias -g J="| ruby -rjson -e 'jj JSON.parse(STDIN.read)'"
alias -g V='| vim -c "set buftype=nofile" - '
alias -g X='| xargs'

### suffix alias
function extract() {
  local tmp_dir="$(mktemp -d --tmpdir=./)"
  local archive_file_name="$(basename "$1")"
  # /dev/null に投げてるのはchpwd対策
  local absolute_path="$(cd $(dirname $1) > /dev/null 2>&1 && pwd)/${archive_file_name}"

  while read line; do
    local s=$(echo -n $line | cut -d' ' -f1)
    if [[ ${archive_file_name} == *${s} ]] then
      local suffix=$s
      local command="$(echo $line | sed -E 's/^[.a-zA-Z0-9]+ +//')"
      break
    fi
  done < <(echo  \
'.tar.gz  tar xzvf
.tgz     tar xzvf
.tar.xz  tar Jxvf
.zip     unzip
.lzh     lha e
.tar.bz2 tar xjvf
.tbz     tar xjvf
.tar.Z   tar zxvf
.gz      gzip -dc
.bz2     bzip2 -dc
.Z       uncompress
.tar     tar xvf')

  # 展開
  ln -s "${absolute_path}" "${tmp_dir}/${archive_file_name}"
  (
    cd "${tmp_dir}" > /dev/null 2>&1
    ${=command} ${archive_file_name} || exit 1
    rm "${archive_file_name}"
  )
  # 展開が失敗していれば、tmp_dirを消して1を返す
  if [[ $? != '0' ]] ; then
    rm -rf "${tmp_dir}"
    return 1
  fi

  local dir_name="$(ls -A "${tmp_dir}")"
  if [[ -d "${tmp_dir}/${dir_name}" ]]; then
    if [[ -d "./${dir_name}" ]]; then
      (
        echo "cannot move directory '${dir_name}': File exists"
        echo "extracted files in ${tmp_dir}/${dir_name}"
      ) 1>&2
      return 1
    else
      'mv' "${tmp_dir}/${dir_name}" ./
      rm -rf "${tmp_dir}"
    fi
  else
    local dir_name="$(basename "${archive_file_name}" "${suffix}")"
    if [[ -d "./${dir_name}" ]]; then
      (
        echo "cannot move directory '${dir_name}': File exists"
        echo "extracted directory as ${tmp_dir}"
      ) 1>&2
    else
      'mv' "${tmp_dir}" "${dir_name}"
    fi
  fi
}
alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,tar,arj,xz}=extract
alias -s rb=ruby
