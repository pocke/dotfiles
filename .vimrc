"--------------------------------------------------------------------------
" neobundle
set nocompatible               " Be iMproved
filetype off                   " Required!

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
  call neobundle#rc(expand('~/.vim/bundle/'))
endif


" Installation check.
if neobundle#exists_not_installed_bundles()
  echomsg 'Not installed bundles : ' .
        \ string(neobundle#get_not_installed_bundle_names())
  echomsg 'Please execute ":NeoBundleInstall" command.'
  "finish
endif

NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'honza/vim-snippets'
" ぬるぬるスクロール
NeoBundle 'yonchu/accelerated-smooth-scroll'

NeoBundle 'sudo.vim'
" colorscheme
NeoBundle 'vim-scripts/rdark'

" ruby のブロックとかがハイライト
NeoBundle 'vimtaku/hl_matchit.vim.git'
" ゆないと
NeoBundle 'Shougo/unite.vim'
" rubyのrequireを補完してくれるunite source
NeoBundle 'rhysd/unite-ruby-require.vim'
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
NeoBundle 'scrooloose/syntastic'
" (){}[]''とかの、囲うやつを編集
NeoBundle 'tpope/vim-surround'
" true/false とかを簡単に切り替える
NeoBundle 'AndrewRadev/switch.vim'
" インデントに線を表示
NeoBundle 'Yggdroot/indentLine'

function! s:meet_neocomplete_requirements()
  return has('lua') && (v:version > 703 || (v:version == 703 && has('patch885')))
endfunction

" 補完
" luaが使えるかどうかでどっち使うか決める
if s:meet_neocomplete_requirements()
  NeoBundle 'Shougo/neocomplete'
  NeoBundleFetch 'Shougo/neocomplcache'
else
  NeoBundleFetch 'Shougo/neocomplete'
  NeoBundle 'Shougo/neocomplcache'
endif

filetype plugin indent on     " Required!

if s:meet_neocomplete_requirements()
  "--------------------------------------------------------------------------
  " neocomplete
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
  let g:neocomplete#min_syntax_length = 3

else
  "--------------------------------------------------------------------------
  " neocomplcache
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

endif

"--------------------------------------------------------------------------
" neosnippet
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
 
" Tell Neosnippet about the other snippets
let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'

"--------------------------------------------------------------------------
" hl_matchit
source $VIMRUNTIME/macros/matchit.vim
" vim起動時にhl_matchitを起動するか
let g:hl_matchit_enable_on_vim_startup = 1
" highlightのパターン
" :highlight に一覧がある
let g:hl_matchit_hl_groupname = 'MatchParen'
" 有効にするファイルの種類
let g:hl_matchit_allow_ft = 'html\|xml\|vim\|ruby\|sh'


"--------------------------------------------------------------------------
" Unite.vim

" インサートモードでスタート
let g:unite_enable_start_insert=1
let g:unite_source_history_yank_enable=1
let g:unite_source_file_mru_limit=200

" yank履歴
nnoremap <silent> ,uy :<C-u>Unite history/yank<CR>
" バッファ一覧
nnoremap <silent> ,ub :<C-u>Unite buffer<CR>
" ファイル一覧
nnoremap <silent> ,uf :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
" 色々?
nnoremap <silent> ,uu :<C-u>Unite file_mru buffer<CR>
" ruby require
nnoremap <silent> ,ur :<C-u>Unite ruby/require<CR>

"--------------------------------------------------------------------------
" switch.vim
autocmd FileType gitrebase let b:switch_custom_definitions =
\ [
\   ['pick', 'squash', 'edit', 'reword', 'fixup', 'exec']
\ ]

" nnoremap + :call switch#Switch(g:variable_style_switch_definitions)<CR>
nnoremap - :Switch<CR>

"--------------------------------------------------------------------------
" indentline

let g:indentLine_color_term = 239
" let g:indentLine_color_gui = '#708090'
let g:indentLine_char = '¦' "use ¦, ┆ or │
let g:indentLine_fileTypeExclude = ['gitcommit', 'diff']

"--------------------------------------------------------------------------
" other
syntax enable

" 256色
if $TERM == 'xterm'
  set t_Co=256
endif
" カラースキーム
colorscheme funya
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
set fileencodings=iso-2022-jp,cp932,sjis,euc-jp,utf-8
" これで保存しようとする
set fileencoding=utf-8

" json syntax highlight
au BufNewFile,BufRead *.json setf javascript

"indent
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set list
set listchars=tab:>-

" タブ移動
nnoremap <C-l> :tabnext<CR>
nnoremap <C-h> :tabprevious<CR>

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
set hlsearch
" Esc 2回で強調を解除
nnoremap <silent> <Esc><Esc> :nohlsearch<CR>

"titleを表示
set title

" 余裕を持ってスクロール
set scrolloff=4

" コマンドラインでの補完を強くする
set wildmenu
set wildmode=longest:full,full
set history=1000000

" ファイルを閉じてもundo
" undodir に指定したディレクトリを手で作成すること。
if has('persistent_undo')
  set undodir=~/.vim/undo
  set undofile
endif

" 前回終了したカーソル行に移動
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

" md as markdown, instead of modula2
autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown

" コマンドラインでのC-n|p と Up, Downの入れ替え
cnoremap <C-n>  <Down>
cnoremap <C-p>  <Up>
cnoremap <Down> <C-n>
cnoremap <Up>   <C-p>
