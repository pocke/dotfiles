" encoding
set encoding=utf-8
scriptencoding utf-8
set fileencodings=utf-8,cp932,sjis,euc-jp
set fileencoding=utf-8


nnoremap ' <Nop>
let g:mapleader = "'"


augroup MyVimrc
  autocmd!
augroup END

command! -nargs=* AutoCmd autocmd MyVimrc <args>


" ==========================================================
" minpac
" ==========================================================

function! s:init_minpac() abort
  packadd minpac
  call minpac#init()
  call minpac#add('k-takata/minpac', {'type': 'opt'})

  " Text objects & operators
  call minpac#add('kana/vim-operator-user')
  call minpac#add('rhysd/vim-operator-surround')
  call minpac#add('emonkak/vim-operator-comment')
  call minpac#add('kana/vim-operator-replace')
  call minpac#add('pocke/vim-operator-trailing-space')
  call minpac#add('tyru/operator-camelize.vim')

  call minpac#add('kana/vim-textobj-user')
  call minpac#add('kana/vim-textobj-entire')
  call minpac#add('terryma/vim-expand-region')

  " Navigation
  call minpac#add('rhysd/clever-f.vim')
  call minpac#add('haya14busa/vim-edgemotion')
  call minpac#add('haya14busa/incsearch.vim')
  call minpac#add('haya14busa/vim-asterisk')
  call minpac#add('easymotion/vim-easymotion')

  " UI
  call minpac#add('itchyny/lightline.vim')
  call minpac#add('w0ng/vim-hybrid')
  call minpac#add('yuttie/comfortable-motion.vim')

  " Git
  call minpac#add('rhysd/committia.vim')

  " Input & language
  call minpac#add('mattn/emmet-vim')
  call minpac#add('pocke/rbs.vim')

  " Utility
  call minpac#add('editorconfig/editorconfig-vim', {'type': 'opt'})
  call minpac#add('mopp/autodirmake.vim')
  call minpac#add('vim-jp/vimdoc-ja')
  call minpac#add('tyru/open-browser.vim')
  call minpac#add('tyru/open-browser-github.vim')
endfunction

command! PackUpdate call s:init_minpac() | call minpac#update()
command! PackClean  call s:init_minpac() | call minpac#clean()
command! PackStatus call s:init_minpac() | call minpac#status()

filetype plugin indent on


" ==========================================================
" Plugin settings
" ==========================================================

" --- vim-operator-surround ---
map <silent><Space>sa <Plug>(operator-surround-append)
map <silent><Space>sd <Plug>(operator-surround-delete)
map <silent><Space>sr <Plug>(operator-surround-replace)

" --- vim-operator-comment ---
map <silent><Space>co <Plug>(operator-comment)
map <silent><Space>cu <Plug>(operator-uncomment)
map <silent><Space>CO <Plug>(operator-comment)<Plug>(operator-comment)
map <silent><Space>CU <Plug>(operator-uncomment)<Plug>(operator-uncomment)

" --- operator-camelize ---
map <silent><Space>ca <Plug>(operator-camelize-toggle)

" --- vim-operator-replace ---
map - <Plug>(operator-replace)

" --- vim-operator-trailing-space ---
map <Space><Space> <Plug>(operator-trailing-space)

" --- vim-expand-region ---
map <CR> <Plug>(expand_region_expand)
map <BS> <Plug>(expand_region_shrink)

let g:expand_region_text_objects = {
\   "i'": 0,
\   'i"': 0,
\   "i`": 0,
\   'i)': 0,
\   'i}': 0,
\   'i]': 0,
\   'ae': 1,
\ }
let g:expand_region_text_objects_html = copy(g:expand_region_text_objects)
let g:expand_region_text_objects_html.it = 1

" --- lightline ---
let g:lightline = {
\   'active': {
\     'left': [
\       ['mode'],
\       ['readonly', 'filename', 'modified'],
\     ]
\   },
\   'component': {},
\   'component_visible_condition': {},
\ }

" --- incsearch ---
map / <Plug>(incsearch-forward)
map g/ <Plug>(incsearch-stay)

let g:incsearch#magic = '\v'
let g:incsearch#auto_nohlsearch = 1

nmap n <Plug>(incsearch-nohl-n)zz
xmap n <Plug>(incsearch-nohl-n)zz
omap n <Plug>(incsearch-nohl-n)zz
nmap N <Plug>(incsearch-nohl-N)zz
xmap N <Plug>(incsearch-nohl-N)zz
omap N <Plug>(incsearch-nohl-N)zz

" --- comfortable-motion ---
nnoremap <silent> <C-d> :call comfortable_motion#flick(100)<CR>
nnoremap <silent> <C-u> :call comfortable_motion#flick(-100)<CR>
nnoremap <silent> <C-f> :call comfortable_motion#flick(400)<CR>
nnoremap <silent> <C-b> :call comfortable_motion#flick(-400)<CR>

" --- vim-easymotion ---
let g:EasyMotion_smartcase  = 1
let g:EasyMotion_use_migemo = 1

nmap e <Plug>(easymotion-s2)

" --- vim-edgemotion ---
map <Space>j <Plug>(edgemotion-j)
map <Space>k <Plug>(edgemotion-k)

" --- clever-f ---
let g:clever_f_ignore_case           = 1
let g:clever_f_fix_key_direction     = 1
let g:clever_f_chars_match_any_signs = "\<C-f>"

" --- vim-asterisk ---
map * <Plug>(incsearch-nohl)<Plug>(asterisk-*)
map z* <Plug>(incsearch-nohl)<Plug>(asterisk-z*)

" --- committia ---
let g:committia_hooks = {}
function! g:committia_hooks.edit_open(info)
  setlocal spell

  imap <buffer><C-d> <Plug>(committia-scroll-diff-down-half)
  imap <buffer><C-u> <Plug>(committia-scroll-diff-up-half)
  nmap <buffer><C-d> <Plug>(committia-scroll-diff-down-half)
  nmap <buffer><C-u> <Plug>(committia-scroll-diff-up-half)
endfunction

" --- emmet ---
let g:user_emmet_settings = {
\   'html': {
\     'empty_element_suffix': ' />',
\   },
\   'typescript': {
\     'extends': 'tsx',
\   }
\}

" --- editorconfig ---
function! s:load_editorconfig()
  if findfile('.editorconfig', '.;') != ''
    packadd editorconfig-vim
    EditorConfigReload
  endif
endfunction

AutoCmd VimEnter * call s:load_editorconfig()

" --- open-browser ---
let s:cmd = has('mac') ? 'open' : 'xdg-open'
let g:openbrowser_browser_commands = [{
\   "name": s:cmd,
\   "args": ["{browser}", "{uri}"]
\ }]
unlet s:cmd

let g:openbrowser_github_url_exists_check = 'ignore'


" ==========================================================
" Display
" ==========================================================

syntax enable

if $TERM == 'xterm' || $TERM == 'screen-256color'
  set t_Co=256
endif
colorscheme p
set foldcolumn=1
set ruler
set autoindent

set keywordprg=""

set foldmethod=manual
set nofoldenable
set foldlevel=99
set conceallevel=0

set ttimeoutlen=10

set noswapfile

set helplang=ja,en


" ==========================================================
" Editing
" ==========================================================

set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set list
set listchars=tab:>-
set breakindent

AutoCmd FileType * setlocal formatoptions-=o

set backspace=indent,eol,start

" search
set ignorecase
set smartcase
set incsearch
set hlsearch | nohlsearch

set title
set showcmd
set scrolloff=4

set wildmenu
set wildmode=longest:full,full
set wildignorecase
set history=1000

if has('persistent_undo')
  set undodir=~/.vim/undo
  if ! isdirectory(&undodir)
    call mkdir(&undodir, 'p')
  endif
  set undofile
endif

set laststatus=2
set noshowmode

set display& display+=lastline

set visualbell t_vb=
set noerrorbells

set updatetime=1000
set tabpagemax=1000

set clipboard& clipboard^=unnamedplus
if has('mac')
  set clipboard& clipboard^=unnamed
endif

set mouse=a
set ttymouse=sgr
set spelllang+=cjk

set tildeop
set nomore

set termwinkey=<C-j>
tnoremap <Esc><Esc> <C-j>N

let g:vim_indent_cont = 0


" ==========================================================
" Key mappings
" ==========================================================

nnoremap ; :
vnoremap ; :

cnoremap <C-n>  <Down>
cnoremap <C-p>  <Up>
cnoremap <Down> <C-n>
cnoremap <Up>   <C-p>

inoremap <C-a> <Home>
inoremap <C-e> <End>

cnoremap <C-a> <Home>
cnoremap <C-e> <End>

nnoremap <silent> <Esc><Esc> :<C-u>nohlsearch<CR>

nnoremap <silent> <C-l> :<C-u>tabnext<CR>
nnoremap <silent> <C-h> :<C-u>tabprevious<CR>

nnoremap <F4> :<C-u>%s/<C-r>//
vnoremap <F4> :s/<C-r>//
nnoremap <F3> :silent! !tig blame +<C-r>=line('.')<CR> %<CR>:redraw!<CR>

nnoremap <Space>w :<C-u>w<CR>
nnoremap <Space>q :<C-u>q<CR>

noremap <Space>h ^
noremap <Space>l $

nnoremap <Left>  <C-w>h
nnoremap <Down>  <C-w>j
nnoremap <Up>    <C-w>k
nnoremap <Right> <C-w>l

nnoremap <C-Left>  <C-w><
nnoremap <C-Down>  <C-w>-
nnoremap <C-Up>    <C-w>+
nnoremap <C-Right> <C-w>>

inoremap <C-s> <C-x><C-s>

nnoremap Q @q
nnoremap Y y$

nnoremap <silent><C-s> :<C-u>set spell!<CR>
nnoremap <silent><Tab> :<C-u>set cursorcolumn!<CR>:<C-u>set cursorline!<CR>
vnoremap <silent><Tab> :<C-u>set cursorcolumn!<CR>:<C-u>set cursorline!<CR>

nnoremap x "_x

snoremap <C-w> a<C-h>

iabbrev stirng string
iabbrev Ingeter Integer
iabbrev cosnt const
iabbrev retrun return
iabbrev laod load
iabbrev recieve receive
iabbrev recieved received
iabbrev have_recieved have_received
iabbrev TOOD TODO
iabbrev destory destroy


" ==========================================================
" Autocmd
" ==========================================================

AutoCmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

AutoCmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
AutoCmd BufNewFile,BufRead ISSUE_EDITMSG              set filetype=markdown
AutoCmd BufNewFile,BufRead *.jbuilder                 set filetype=ruby
AutoCmd BufNewFile,BufRead *.jb                       set filetype=ruby
AutoCmd BufNewFile,BufRead *.schema                   set filetype=ruby
AutoCmd BufNewFile,BufRead Guardfile                  set filetype=ruby
AutoCmd BufNewFile,BufRead .pryrc                     set filetype=ruby
AutoCmd BufNewFile,BufRead Steepfile                  set filetype=ruby
AutoCmd BufNewFile,BufRead *_spec.rb                  set filetype=ruby.rspec

AutoCmd FileType eruby exec 'set filetype=' . 'eruby.' . b:eruby_subtype
AutoCmd FileType qf   nnoremap <buffer> <CR> <CR> | setlocal cursorline
AutoCmd CmdwinEnter * nnoremap <buffer> <CR> <CR> | setlocal cursorline

AutoCmd CmdwinEnter *  nnoremap <buffer><silent> q :q<CR>
AutoCmd FileType qf    nnoremap <buffer><silent> q :q<CR>

AutoCmd FileType gitcommit if getline(1) == '' | startinsert | endif
AutoCmd Syntax markdown syntax clear markdownItalic
AutoCmd Syntax markdown syntax sync fromstart
AutoCmd FileType markdown,text,gitcommit setl spell
AutoCmd BufNewFile,BufRead config/locales/*.yml setl spell

AutoCmd FileType js ++nested setlocal ft=javascript
AutoCmd FileType ts ++nested setlocal ft=typescript
AutoCmd FileType md ++nested setlocal ft=markdown

AutoCmd FileType ruby setl iskeyword+=?
let g:ruby_path = ""

AutoCmd FileType help call s:set_help_keymap()
function! s:set_help_keymap()
  if &buftype != 'help'
    return
  endif

  nnoremap <buffer> <CR> <C-]>
  nnoremap <buffer> <BS> <C-t>
endfunction

AutoCmd BufReadCmd *:[0-9]\+ ++nested call s:edit_with_lnum(expand('<afile>'))

function! s:edit_with_lnum(path_with_lnum) abort
  let lnum = matchstr(a:path_with_lnum, '\v[0-9]+$')
  let path = matchstr(a:path_with_lnum, '\v^.+\ze:[0-9]+$')
  exec 'e' path
  exec lnum
endfunction

AutoCmd VimResized * wincmd =

function! s:auto_close_quickfix()
  if winnr('$') == 1 && getbufvar(winbufnr(0), '&buftype') == 'quickfix'
    quit
  endif
endfunction
AutoCmd WinEnter * call s:auto_close_quickfix()


" ==========================================================
" Utility functions
" ==========================================================

function! Define() abort
  let lowers = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
  for ch in lowers
    execute 'inoremap <expr>' . ch . ' K("' . ch . '")'
  endfor
endfunction

function! K(ch) abort
  let whitelist = ['CR', 'JR', 'RS', 'ID']
  let line = getline('.')
  let col_n = col('.')
  if line !~# '\v[A-Z][A-Z]%' . string(col_n) . 'c'
    return a:ch
  endif
  for w in whitelist
    if line =~# '\V' . w . '\v%' . string(col_n) . 'c'
      return a:ch
    endif
  endfor
  return "\<BS>\<BS>" . line[col_n-3] . tolower(line[col_n-2]) . a:ch
endfunction

call Define()

silent mkspell! ~/.vim/spell/en.utf-8.add
