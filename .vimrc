augroup MyVimrc
  autocmd!
augroup END

" neobundle {{{
set nocompatible               " Be iMproved
filetype off                   " Required!

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#rc(expand('~/.vim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'


NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'
" ぬるぬるスクロール
NeoBundleLazy 'yonchu/accelerated-smooth-scroll', {
\   'autoload': {
\     'mappings': [
\       '<Plug>(ac-smooth-scroll-c-d)',
\       '<Plug>(ac-smooth-scroll-c-u)',
\       '<Plug>(ac-smooth-scroll-c-f)',
\       '<Plug>(ac-smooth-scroll-c-b)'
\     ]
\   }
\ }

NeoBundle 'sudo.vim'
" colorscheme
NeoBundleLazy 'vim-scripts/rdark'
NeoBundle 'pocke/funyapoyo.vim'
NeoBundleLazy 'itchyny/landscape.vim'

" ruby のブロックとかがハイライト
NeoBundle 'vimtaku/hl_matchit.vim.git'
" ゆないと
NeoBundleLazy 'Shougo/unite.vim', {
\   'autoload' : {
\     'commands' : [ "Unite", "UniteWithBufferDir" ]
\   }
\ }
NeoBundleLazy 'rhysd/unite-ruby-require.vim', {
\   'autoload' : {
\     'unite_sources' : ['ruby/require']
\   }
\ }
NeoBundleLazy 'Shougo/unite-outline', {
\   'autoload': {
\     'unite_sources': ['outline']
\   }
\ }
" 非同期処理
NeoBundle 'Shougo/vimproc', {
  \ 'build' : {
    \ 'windows' : 'make -f make_mingw32.mak',
    \ 'cygwin' : 'make -f make_cygwin.mak',
    \ 'mac' : 'make -f make_mac.mak',
    \ 'unix' : 'make -f make_unix.mak',
  \ },
\ }
" 整形、桁揃え
NeoBundle 'Align'
" 構文チェック
NeoBundle 'osyo-manga/vim-watchdogs', {
\   'depends': [
\     'thinca/vim-quickrun',
\     'Shougo/vimproc',
\     'osyo-manga/shabadou.vim',
\     'jceb/vim-hier'
\   ]
\ }
" text object
NeoBundle 'tpope/vim-surround'
NeoBundle 'gcmt/wildfire.vim'
NeoBundleLazy 'rhysd/vim-textobj-ruby', {
\   'depends': 'kana/vim-textobj-user',
\   'autoload': {
\     'filetypes': 'ruby'
\   }
\ }
NeoBundleLazy 'deris/vim-textobj-enclosedsyntax', {
\   'depends': 'kana/vim-textobj-user',
\   'autoload': {
\     'filetypes': 'ruby'
\   }
\ }
NeoBundle 'kana/vim-textobj-syntax', {
\   'depends': 'kana/vim-textobj-user'
\ }
" true/false とかを簡単に切り替える
NeoBundleLazy 'AndrewRadev/switch.vim', {
\   'autoload': {
\     'commands': 'Switch'
\   }
\ }
" インデントに線を表示
NeoBundle 'Yggdroot/indentLine'
" はてなブログ
NeoBundleLazy 'moznion/hateblo.vim', {
\   'depends': ['mattn/webapi-vim', 'Shougo/unite.vim']
\ }
NeoBundleLazy 'mattn/gist-vim', {
\   'depends': ['mattn/webapi-vim'],
\   'autoload': {
\     'commands': 'Gist'
\   }
\ }
" ファイラ
NeoBundleLazy 'Shougo/vimfiler', {
\   'autoload': {
\     'commands': ['VimFilerBufferDir', 'VimFiler']
\   },
\   'depends': 'Shougo/unite.vim'
\ }
" コマンド実行
NeoBundleLazy 'thinca/vim-quickrun', {
\   'autoload': {
\     'mappings': [['nxo', '<Plug>(quickrun)']],
\     'commands': 'QuickRun'
\   }
\ }
" markdown
NeoBundleLazy 'superbrothers/vim-quickrun-markdown-gfm', {
\   'depends': ['mattn/webapi-vim', 'thinca/vim-quickrun', 'tyru/open-browser.vim'],
\   'autoload': {
\     'filetypes': 'markdown'
\   }
\ }
" 移動
NeoBundleLazy 'rhysd/clever-f.vim', {
\   'autoload': {
\     'mappings': 'f'
\   }
\ }
" Visual Mode でも * で検索
NeoBundleLazy 'thinca/vim-visualstar', {
\   'autoload': {
\     'mappings': [
\       ['xv', '*'], ['xv', '#'], ['xv', 'g'], ['xv', 'g*']
\     ]
\   }
\ }

" git
NeoBundle 'tpope/vim-fugitive'
NeoBundleLazy 'gregsexton/gitv', {
\   'depends': ['tpope/vim-fugitive'],
\   'autoload': {
\     'commands': ['Git', 'Gitv']
\   }
\ }

NeoBundle 'itchyny/lightline.vim'
NeoBundleLazy 'Shougo/vimshell', {
\   'depends': ['Shougo/unite.vim', 'Shougo/neocomplete'],
\   'autoload': {
\     'commands': ['VimShell', 'VimShellTab', 'VimShellCreate', 'VimShellPop']
\   }
\ }

function! s:meet_neocomplete_requirements()
  return has('lua') && (v:version > 703 || (v:version == 703 && has('patch885')))
endfunction

" 補完
" luaが使えるかどうかでどっち使うか決める
if s:meet_neocomplete_requirements()
  NeoBundle 'Shougo/neocomplete', {
\     'depends': ['Shougo/context_filetype.vim']
\   }
  NeoBundleFetch 'Shougo/neocomplcache'
else
  NeoBundleFetch 'Shougo/neocomplete'
  NeoBundle 'Shougo/neocomplcache'
endif

filetype plugin indent on     " Required!
"}}}

" plugins setting {{{
if s:meet_neocomplete_requirements()
  " neocomplete {{{
  " 起動時に有効化
  let g:neocomplete#enable_at_startup = 1
  " 大文字が入力されるまで大文字小文字の区別を無視する
  let g:neocomplete#enable_smart_case = 1
  " _(アンダースコア)区切りの補完を有効化
  let g:neocomplete#enable_underbar_completion = 1
  let g:neocomplete#enable_camel_case_completion  =  1
  " ポップアップメニューで表示される候補の数
  let g:neocomplete#max_list = 20
  " シンタックスをキャッシュするときの最小文字長
  let g:neocomplete#sources#syntax#min_keyword_length = 3
  " 補完を表示する最小文字数
  let g:neocomplete#auto_completion_start_length = 2
  "}}}
else
  " neocomplcache {{{
  " 起動時に有効化
  let g:neocomplcache_enable_at_startup = 1
  " 大文字が入力されるまで大文字小文字の区別を無視する
  let g:neocomplcache_enable_smart_case = 1
  " _(アンダースコア)区切りの補完を有効化
  let g:neocomplcache_enable_underbar_completion = 1
  let g:neocomplcache_enable_camel_case_completion  =  1
  " ポップアップメニューで表示される候補の数
  let g:neocomplcache_max_list = 20
  " シンタックスをキャッシュするときの最小文字長
  let g:neocomplcache_min_syntax_length = 3
  " }}}
endif

" neosnippet {{{
"http://kazuph.hateblo.jp/entry/2013/01/19/193745

" <TAB>: completion.
" inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB>  pumvisible() ? "\<C-p>" : "\<S-TAB>"

" Plugin key-mappings.
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)

" SuperTab like snippets behavior.
"imap <expr><TAB> neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
imap <expr><TAB> pumvisible() ? "\<C-n>" : neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif

" Enable snipMate compatibility feature.
let g:neosnippet#enable_snipmate_compatibility = 1
"}}}

" accelerated-smooth-scroll {{{
let s:bundle = neobundle#get("accelerated-smooth-scroll")
function! s:bundle.hooks.on_source(bundle)
  let g:ac_smooth_scroll_no_default_key_mappings = 1
endfunction
unlet s:bundle

nmap <silent> <C-d> <Plug>(ac-smooth-scroll-c-d)
nmap <silent> <C-u> <Plug>(ac-smooth-scroll-c-u)
nmap <silent> <C-f> <Plug>(ac-smooth-scroll-c-f)
nmap <silent> <C-b> <Plug>(ac-smooth-scroll-c-b)
" }}}

" hl_matchit {{{
source $VIMRUNTIME/macros/matchit.vim
" vim起動時にhl_matchitを起動するか
let g:hl_matchit_enable_on_vim_startup = 1
" highlightのパターン
" :highlight に一覧がある
let g:hl_matchit_hl_groupname = 'MatchParen'
" 有効にするファイルの種類
let g:hl_matchit_allow_ft = 'html\|xml\|vim\|ruby\|sh'
" }}}

" Unite.vim {{{
let s:bundle = neobundle#get("unite.vim")
function! s:bundle.hooks.on_source(bundle)
  let g:unite_enable_start_insert=1
  let g:unite_source_history_yank_enable=1
  let g:unite_source_file_mru_limit=200
endfunction
unlet s:bundle

nnoremap [unite] <Nop>
nmap <Space>u [unite]
" yank履歴
nnoremap <silent> [unite]y :<C-u>Unite history/yank<CR>
" バッファ一覧
nnoremap <silent> [unite]b :<C-u>Unite buffer<CR>
" ファイル一覧
nnoremap <silent> [unite]f :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
" 色々?
nnoremap <silent> [unite]u :<C-u>Unite file_mru buffer<CR>
nnoremap <silent> [unite]r :<C-u>Unite ruby/require<CR>
nnoremap <silent> [unite]o :<C-u>Unite outline<CR>
" }}}

" watchdogs.vim {{{
let g:watchdogs_check_BufWritePost_enable = 1
" }}}

" switch.vim {{{
let s:bundle = neobundle#get("switch.vim")
function! s:bundle.hooks.on_source(bundle)
  autocmd MyVimrc FileType gitrebase let b:switch_custom_definitions =
\   [
\     ['pick', 'squash', 'edit', 'reword', 'fixup', 'exec']
\   ]
endfunction
unlet s:bundle

nnoremap - :<C-u>Switch<CR>
" }}}

" indentline {{{
let g:indentLine_color_term = 239
" let g:indentLine_color_gui = '#708090'
let g:indentLine_char = '¦' "use ¦, ┆ or │
let g:indentLine_fileTypeExclude = ['gitcommit', 'diff']
" }}}

" vimfiler {{{
nnoremap <Space>ff :<C-u>VimFiler<CR>
nnoremap <Space>fi :<C-u>VimFiler -split -simple -winwidth=35 -no-quit<CR>
" }}}

" quickrun {{{
let s:bundle = neobundle#get("vim-quickrun")
function! s:bundle.hooks.on_source(bundle)
  let g:quickrun_config = {
\     '_': {
\       'runner': 'vimproc',
\       'runner/vimproc/updatetime': 60
\     },
\     'markdown': {
\       'type':      'markdown/gfm',
\       'outputter': 'browser'
\     },
\     'watchdogs_checker/_': {
\     }
\   }
  call watchdogs#setup(g:quickrun_config)
endfunction
unlet s:bundle
" }}}

" clever-f {{{
let s:bundle = neobundle#get("clever-f.vim")
function! s:bundle.hooks.on_source(bundle)
  let g:clever_f_ignore_case           = 1
  let g:clever_f_use_migemo            = 1
  let g:clever_f_fix_key_direction     = 1
  let g:clever_f_chars_match_any_signs = ';'
endfunction
unlet s:bundle
" }}}

" vim-fugitive {{{
nnoremap <silent> <Space>gs :<C-u>Gstatus <CR>
nnoremap <silent> <Space>gc :<C-u>Gcommit <CR>
nnoremap <silent> <Space>gb :<C-u>Gblame  <CR>
nnoremap <silent> <Space>gd :<C-u>Gdiff   <CR>
nnoremap <silent> <Space>ga :<C-u>Gwrite  <CR>

let s:bundle = neobundle#get('vim-fugitive')
function! s:bundle.hooks.on_post_source(bundle)
  doautoall fugitive BufNewFile
endfunction
unlet s:bundle
" }}}

" gitv {{{
nnoremap <Space>gv :<C-u>Gitv<CR>
let s:bundle = neobundle#get('gitv')
function! s:bundle.hooks.on_source(bundle)
  function! g:gitv_get_current_hash()
    return matchstr(getline('.'), '\[\zs.\{7\}\ze\]$')
  endfunction

  autocmd MyVimrc FileType gitv call s:my_gitv_settings()
  function! s:my_gitv_settings()
    setlocal iskeyword+=/,-,.
    nnoremap <buffer> C :<C-u>Git checkout <C-r>=g:gitv_get_current_hash()<CR><CR>
  endfunction
endfunction
unlet s:bundle
" }}}

" lightline.vim {{{
let g:lightline = {
\   'active': {
\     'left': [
\       ['mode'],
\       ['readonly', 'fugitive', 'filename', 'modified']
\     ]
\   },
\   'component': {
\     'fugitive': '%{exists("*fugitive#head")?fugitive#head():""}'
\   },
\   'component_visible_condition': {
\     'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())'
\   }
\ }
" }}}

" vimshell {{{
nnoremap <silent> <Space>ss :<C-u>VimShell<CR>
nnoremap <silent> <Space>sc :<C-u>VimShellCreate<CR>
nnoremap <silent> <Space>sp :<C-u>VimShellPop<CR>
nnoremap <silent> <Space>st :<C-u>VimShellTab<CR>

let s:bundle = neobundle#get('vimshell')
function! s:bundle.hooks.on_source(bundle)
  autocmd MyVimrc FileType vimshell call vimshell#hook#set('chpwd', ['g:my_chpwd'])
  function! g:my_chpwd(args, context)
    call vimshell#execute('ls')
  endfunction
endfunction
unlet s:bundle
" }}}

" }}}

" other {{{
syntax enable

" 256色
if $TERM == 'xterm'
  set t_Co=256
endif
" カラースキーム
colorscheme funyapoyo
" 行番号を表示
set number
" 何行目の何列目にカーソルがいるか表示
set ruler
" 新しい行のインデントを現在行と同じに
set autoindent

" 折りたたみ-展開
set foldmethod=syntax
set foldlevel=99

" Shift-oで待たされるのを改善
set ttimeoutlen=10

" 保存されていないバッファがあっても他のバッファを開ける
set hidden

set encoding=utf-8
" これで開こうとする
set fileencodings=utf-8,cp932,sjis,euc-jp
" これで保存しようとする
set fileencoding=utf-8

"indent
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set list
set listchars=tab:>-

" ノーマルモードでoOで改行した時にコメントを追加しない
autocmd MyVimrc FileType * setlocal formatoptions-=o

" インサートモード時にバックスペースを使う
set backspace=indent,eol,start

" search
" 大文字小文字を区別しない
" 但し、両方が含まれていれば区別する
set ignorecase
set smartcase
" インクリメンタルサーチ
set incsearch
" 検索文字の強調
" http://haya14busa.com/vim_highlight_search/
set hlsearch | nohlsearch

"titleを表示
set title

" 余裕を持ってスクロール
set scrolloff=4

" コマンドラインでの補完を強くする
set wildmenu
set wildmode=longest:full,full
set history=1000

" ファイルを閉じてもundo
" undodir に指定したディレクトリを手で作成すること。
if has('persistent_undo')
  set undodir=~/.vim/undo
  set undofile
endif

" 前回終了したカーソル行に移動
autocmd MyVimrc BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

" md as markdown, instead of modula2
autocmd MyVimrc BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
" json syntax highlight
autocmd MyVimrc BufNewFile,BufRead *.json set filetype=javascript

" statuslineを表示
set laststatus=2
set noshowmode

" ビープ音を鳴らさない
set visualbell t_vb=
set noerrorbells

" 行末の空白をハイライト
autocmd MyVimrc VimEnter,WinEnter * match Error /\s\+$/

" コマンドラインウィンドウの末尾20行を除いて全て削除
autocmd MyVimrc CmdwinEnter * :<C-u>silent! 1,$-20 delete _ | call cursor("$", 1)

" q だけで Window を閉じる
autocmd MyVimrc FileType help,qf nnoremap <buffer> q <C-w>c
" }}}

" keybind {{{
" コマンドラインでのC-n|p と Up, Downの入れ替え
cnoremap <C-n>  <Down>
cnoremap <C-p>  <Up>
cnoremap <Down> <C-n>
cnoremap <Up>   <C-p>

" Esc 2回で強調を解除
nnoremap <silent> <Esc><Esc> :<C-u>nohlsearch<CR>

" タブ移動
nnoremap <silent> <C-l> :<C-u>tabnext<CR>
nnoremap <silent> <C-h> :<C-u>tabprevious<CR>

" TABにて対応ペアにジャンプ
nnoremap <Tab> %
vnoremap <Tab> %
" }}}

" vim:set foldmethod=marker:
