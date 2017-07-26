# Created by newuser for 5.0.2

#setopt correct             # command not foundな時にお節介する
setopt list_packed          # 補完を詰める
setopt globdots             # ドットファイルを*で選択する
setopt noautoremoveslash    # パスの最後のスラッシュを削除しない
setopt mark_dirs            # ファイル名の展開でディレクトリにマッチした場合 末尾に / を付加
setopt print_eight_bit      # 日本語ファイル名等8ビットを通す
setopt extended_glob        # 強いglob
setopt no_beep
setopt INTERACTIVE_COMMENTS

### export variables
export EDITOR=vim
export GOPATH="$HOME/go"
export PATH=$PATH:$GOPATH/bin
export PATH=$HOME/bin:$PATH
export PATH=$HOME/.rbenv/bin:$PATH
which rbenv > /dev/null 2>&1 && eval "$(rbenv init -)"
# https://wiki.archlinux.org/index.php/Java_Runtime_Environment_Fonts_%28%E6%97%A5%E6%9C%AC%E8%AA%9E%29
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on'
export MANPAGER="/bin/sh -c \"col -b -x | vim -c 'set buftype=nofile' -c 'set ft=man' -\""
export RUBYOPT='-W'

WORDCHARS="${WORDCHARS:s!/!!}"
REPORTTIME=3                # 3秒以上かかったコマンドは実行時間を表示する
TIMEFMT='
total  %E
user   %U
system %S
CPU    %P
cmd    %J'

disable r

### compinit
autoload -U compinit        # 補完が強くなる
compinit -u
setopt auto_param_slash     # ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt magic_equal_subst    # = 以降でも補完
#  補完の際(大|小)文字を区別しない,ドットの直前を*に置き換えて補完
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z} l:|=.'
# 補完メッセージを読みやすくする
zstyle ':completion:*' verbose yes
zstyle ':completion:*' format '%B%d%b'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''

# syntax highlighting
if [ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh ]; then
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
fi

setopt no_complete_aliases

basedir=$(dirname $0)

### alias
source "${basedir}/alias.zsh"

case "${OSTYPE}" in
  darwin*)
    source "${basedir}/mac.zsh"
    ;;
  *)
esac

### cd
setopt auto_cd            # ディレクトリ名だけでcd
setopt auto_pushd         # 勝手にpush
setopt pushd_ignore_dups  # 重複したディレクトリをpushしない
function chpwd() { ls }   # ディレクトリを移動したらls
function name_dir() # dir, name
{
  alias "$2"="cd $1"
}
name_dir ~/dotfiles/ d
name_dir ~/.vim/bundle/ v

### prompt
# git branch
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '*** branch: %b'
zstyle ':vcs_info:*' actionformats '*** branch: %b / %a'
precmd () {
    psvar=()
    LANG=en_US.UTF-8 vcs_info
    [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}
prompt_git='%B%1(v|%F{cyan}%1v
%f|)'

# default
prompt_exit_status="(%(?.%F{green}%?%f.%F{red}%?%f))"
PROMPT="%B${prompt_git}[%F{cyan}INS%f]${prompt_exit_status} %#%b "
RPROMPT='%B( %F{magenta}%~%f )Oo%b'

# vim keybind mode
function zle-line-init zle-keymap-select {
  local vim_mode='%F{cyan}INS%f'
  if [ "${KEYMAP}" = 'vicmd' ]; then
    vim_mode='%F{red}NOR%f'
  fi
  PROMPT="%B${prompt_git}[${vim_mode}]${prompt_exit_status} %#%b "
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

### history
HISTFILE=~/.zsh_history       # ヒストリファイル
HISTSIZE=1000000
SAVEHIST=1000000
setopt hist_ignore_dups       # 連続した同じコマンドを記録しない
setopt hist_ignore_space      # スペースからはじまるものをヒストリに登録しない
setopt extended_history       # タイムスタンプを記録
setopt share_history
# 5文字以上のもののみhistoryに登録
zshaddhistory()
{
  local line=${1%%$'\n'}
  [[ ${#line} -ge 5 ]]
}

command_not_found_handler()
{
  case "${OSTYPE}" in
    darwin*)
      local sed='gsed'
      ;;
    *)
      local sed='sed'
      ;;
  esac
  tail -1 $HISTFILE |
    grep -F "$*" > /dev/null 2>&1 &&
      $sed -i '$d' $HISTFILE
  return 127
}

### keybind
# C-s でのサスペンドを無効
stty stop '' -ixoff

bindkey -v

bindkey "[Z" reverse-menu-complete    # Shift-Tabで補完を逆順

autoload history-search-end             # ヒストリを巡る時にカーソルを一番後ろに
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^P' history-beginning-search-backward-end
bindkey '^N' history-beginning-search-forward-end

bindkey 'OH' beginning-of-line        # Homeキーがうまく効かないのを修正
bindkey 'OF' end-of-line              # Endキーがうまく効かないのを修正

zle -A .backward-kill-word vi-backward-kill-word      # viキーバインドで
zle -A .backward-delete-char vi-backward-delete-char  # インサートモードに入る前の文字を消す

# vicmd mode
bindkey -a ';' execute-named-cmd
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line


### color
# 色の設定
export LSCOLORS=Exfxcxdxbxegedabagacad
# 補完時の色の設定
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
# 補完候補に色を付ける
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

#コマンドスタック
show_buffer_stack() {
  POSTDISPLAY="
  stack: $LBUFFER"
  zle push-line-or-edit
}
zle -N show_buffer_stack
setopt noflowcontrol
bindkey '^Q' show_buffer_stack

### functions
# mkdir して cd
function take()
{
  if [[ -d $1 ]]; then
    cd $1 && echo -e "\e[1;35m***\e[m\e[1;34m$1\e[m already exists. cd to it"
  else
    mkdir -p $1 && cd $1 && echo -e "\e[1;35m***\e[mCreated \e[1;34m$1\e[m and cd to it"
  fi
}

# コマンドラインが空の場合、Enterで補完を更新する。
function _rehash()
{
  zle accept-line  # accept-line がデフォルトのEnterに割り当てられている
  if [[ -z "$BUFFER" ]]; then
    rehash
  fi
}
zle -N _rehash
bindkey "\C-m" _rehash


function is_git_dir()
{
  git rev-parse --show-toplevel > /dev/null 2>&1
}

function /()
{
  if is_git_dir; then
    git grep $@
  else
    grep $@
  fi
}

function f/()
{
  git ls-files G $@
}

# s/$1/$2/g
function sub()
{
  is_git_dir
  local g=$?
  if [ $g != 0 ]; then
    echo 'Current directory is not git directory.'
    return 1
  fi

  local from=$1
  local to=$2

  git grep -l $from | xargs sed -i -e "s/${from}/${to}/g"
}

# $1 is a directory path.
function __new_base()
{
  local dir="$1"
  if [ -e $dir ]; then
    echo "\e[31m$dir already exists.\e[m"
    return
  fi
  mkdir $dir
  cd $dir
  git init && git ci --allow-empty -m 'first commit'
}

# $1 is a project name.
function go-new()
{
  __new_base "$HOME/go/src/github.com/pocke/$1"
}

# $1 is a project name.
function ghq-new()
{
  __new_base "$HOME/ghq/github.com/pocke/$1"
}

# $1 is a project name.
function gem-new()
{
  cd "$HOME/ghq/github.com/pocke/"
  bundle gem $1 &&
    cd $1 &&
    git ci -m 'bunlde gem'
}

### peco
if which peco > /dev/null 2>&1 && [ -e "${basedir}/peco.zsh" ]; then
  source "${basedir}/peco.zsh"
fi

function sideci()
{
  ruby -e '
    spawn(%q!sakura -x "ptmux sideci"!)
    spawn(%q!sakura -x "ptmux node"!)
    spawn(%q!sakura -x "ptmux setaria"!)
    spawn(%q!sakura -x "ptmux catpost"!)
  '
}

function t()
{
  tmux new-session -s $(basename $(pwd) | sed -e 's/\./-/g')
}
