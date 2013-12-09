colorscheme desert "カラースキーマ
set number
set ruler
syntax enable
set autoindent "新しい行のインデントを現在行と同じに

set foldmethod=syntax   "折りたたみ-展開
set foldlevel=99

set ttimeoutlen=10  " Shift-oで待たされるのを改善

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
NeoBundle 'scrooloose/snipmate-snippets'


function! s:meet_neocomplete_requirements()
  return has('lua') && (v:version > 703 || (v:version == 703 && has('patch885')))
endfunction

if s:meet_neocomplete_requirements()
  NeoBundle 'Shougo/neocomplete.vim'
  NeoBundleFetch 'Shougo/neocomplacache.vim'
else
  NeoBundleFetch 'Shougo/neocomplete.vim'
  NeoBundle 'Shougo/neocomplcache.vim'
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
  " neocomplacache
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
