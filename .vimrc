" encoding
set encoding=utf-8
scriptencoding utf-8
" これで開こうとする
set fileencodings=utf-8,cp932,sjis,euc-jp
" これで保存しようとする
set fileencoding=utf-8


nnoremap ' <Nop>
let g:mapleader = "'"


" https://github.com/rhysd/dotfiles
augroup MyVimrc
  autocmd!
augroup END

command! -nargs=* AutoCmd autocmd MyVimrc <args>

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeget_SID$')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID


" neobundle {{{
function! s:meet_neocomplete_requirements()
  return has('lua') && (v:version > 703 || (v:version == 703 && has('patch885')))
endfunction


if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

let g:neobundle#install_max_processes = 6

"call neobundle#rc(expand('~/.vim/bundle/'))
call neobundle#begin(expand('~/.vim/bundle/'))


function! s:load_bundles()
  NeoBundleFetch 'Shougo/neobundle.vim'

  " 入力系プラグイン {{{

  " 補完
  " luaが使えるかどうかでどっち使うか決める
  if s:meet_neocomplete_requirements()
    NeoBundle 'Shougo/neocomplete'
    NeoBundleFetch 'Shougo/neocomplcache'
  else
    NeoBundleFetch 'Shougo/neocomplete'
    NeoBundle 'Shougo/neocomplcache'
  endif

  NeoBundle 'Shougo/neosnippet'
  NeoBundle 'Shougo/neosnippet-snippets'
  NeoBundle 'pocke/neosnippet-modeline'

  " true/false とかを簡単に切り替える
  NeoBundleLazy 'AndrewRadev/switch.vim'

  NeoBundleLazy 'kana/vim-smartinput'
  NeoBundleLazy 'kana/vim-smartchr'
  NeoBundleLazy 'mattn/emmet-vim'
  NeoBundleLazy 'LeafCage/yankround.vim'

  " text object {{{
  NeoBundleLazy 'terryma/vim-expand-region'
  NeoBundle 'osyo-manga/vim-textobj-blockwise'
  NeoBundleLazy 'kana/vim-textobj-user'
  NeoBundleLazy 'rhysd/vim-textobj-ruby'
  NeoBundleLazy 'deris/vim-textobj-enclosedsyntax'
  NeoBundleLazy 'kana/vim-textobj-syntax'
  NeoBundleLazy 'sgur/vim-textobj-parameter'
  NeoBundleLazy 'kana/vim-textobj-line'
  NeoBundleLazy 'kana/vim-textobj-entire'
  " }}}

  " operator {{{
  NeoBundleLazy 'kana/vim-operator-user'
  NeoBundleLazy 'rhysd/vim-operator-surround'
  NeoBundleLazy 'emonkak/vim-operator-comment'
  NeoBundleLazy 'tyru/operator-camelize.vim'
  NeoBundleLazy 'chikatoike/concealedyank.vim'
  NeoBundleLazy 'kana/vim-operator-replace'
  NeoBundleLazy 'pocke/vim-operator-gitrebase'
  " }}}

  " }}}

  " 表示系プラグイン {{{
  NeoBundle 'thinca/vim-splash'
  NeoBundle 'Yggdroot/indentLine'
  NeoBundleLazy 'vim-scripts/AnsiEsc.vim'
  NeoBundle 'itchyny/lightline.vim'
  NeoBundle 'osyo-manga/vim-spice'
  NeoBundleLazy 'osyo-manga/vim-over'

  " ruby のブロックとかがハイライト
  NeoBundleLazy 'vimtaku/hl_matchit.vim'
  NeoBundleLazy 'todesking/ruby_hl_lvar.vim'

  " colorscheme {{{
  NeoBundleLazy 'vim-scripts/rdark'
  NeoBundleLazy 'itchyny/landscape.vim'
  " }}}
  " }}}

  " 移動系プラグイン {{{
  " ぬるぬるスクロール
  NeoBundleLazy 'pocke/accelerated-smooth-scroll'
  NeoBundleLazy 'Lokaltog/vim-easymotion'
  NeoBundleLazy 'rhysd/clever-f.vim'
  " }}}

  " syntax and filetype plugins {{{
  NeoBundleLazy 'jelera/vim-javascript-syntax'
  NeoBundleLazy 'marijnh/tern_for_vim'
  NeoBundle 'kchmck/vim-coffee-script'
  NeoBundle 'leafgarland/typescript-vim'
  NeoBundleLazy 'clausreinke/typescript-tools'
  NeoBundle 'groenewege/vim-less'
  NeoBundle 'slim-template/vim-slim'
  NeoBundle 'https://vimperator-labs.googlecode.com/hg/', {
  \   'name': 'vimperator-syntax',
  \   'type': 'hg',
  \   'rtp':  'vimperator/contrib/vim/'
  \ }
  " }}}

  " Application Plugins {{{

  " Unite {{{
  NeoBundleLazy 'Shougo/unite.vim'
  NeoBundleLazy 'rhysd/unite-ruby-require.vim'
  NeoBundleLazy 'Shougo/unite-outline'
  " }}}

  NeoBundleLazy 'Shougo/vimfiler'
  NeoBundleLazy 'Shougo/vimshell'
  NeoBundleLazy 'itchyny/calendar.vim'
  NeoBundleLazy 'sjl/gundo.vim'
  NeoBundleLazy 'thinca/vim-ref'
  NeoBundleLazy 'thinca/vim-scouter'

  " Web service {{{
  " はてなブログ
  NeoBundleLazy 'moznion/hateblo.vim'
  NeoBundleLazy 'lambdalisue/vim-gista'
  NeoBundleLazy 'basyura/TweetVim'
  " }}}

  " }}}

  NeoBundle 'sudo.vim'
  NeoBundleLazy 'editorconfig/editorconfig-vim'

  " 非同期処理
  NeoBundle 'Shougo/vimproc'
  NeoBundle 'tyru/open-browser.vim'

  " コマンド実行
  NeoBundleLazy 'thinca/vim-quickrun'
  " markdown quickrun
  NeoBundleLazy 'superbrothers/vim-quickrun-markdown-gfm'
  " 構文チェック
  NeoBundleLazy 'osyo-manga/vim-watchdogs'


  " Visual Mode でも * で検索
  NeoBundleLazy 'thinca/vim-visualstar'

  " git
  NeoBundle 'tpope/vim-fugitive'
  NeoBundleLazy 'gregsexton/gitv'

  " window管理
  NeoBundle 'osyo-manga/vim-automatic'

  " vim {{{
  NeoBundle 'vim-jp/vimdoc-ja'
  NeoBundleLazy 'LeafCage/vimhelpgenerator'
  NeoBundleLazy 'thinca/vim-prettyprint'
  NeoBundleLazy 'tyru/capture.vim'
  "}}}


  " keybind {{{
  NeoBundle 'kana/vim-submode'
  NeoBundle 'kana/vim-arpeggio'
  " }}}
endfunction

if neobundle#has_fresh_cache()
  NeoBundleLoadCache
else
  call s:load_bundles()
  NeoBundleSaveCache
endif

call neobundle#end()
filetype plugin indent on     " Required!
"}}}



" plugins settings {{{
call arpeggio#load()

" 入力系プラグイン {{{
if s:meet_neocomplete_requirements()
  " neocomplete {{{
  if neobundle#tap('neocomplete')
    call neobundle#config({
    \   'depends': ['Shougo/context_filetype.vim']
    \ })

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


    if !exists('g:neocomplete#delimiter_patterns')
      let g:neocomplete#delimiter_patterns= {}
    endif
    let g:neocomplete#delimiter_patterns.ruby = ['::']

    call neobundle#untap()
  endif
  "}}}
else
  " neocomplcache {{{
  if neobundle#tap('neocomplcache')
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


    let g:neocomplcache_delimiter_patterns = {}
    let g:neocomplcache_delimiter_patterns.ruby = ['::']
    call neobundle#untap()
  endif
  " }}}
endif

" neosnippet {{{
if neobundle#tap('neosnippet')
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
  let g:neosnippet#snippets_directory='~/dotfiles/snippets'

  AutoCmd InsertLeave * syntax clear neosnippetConcealExpandSnippets

  call neobundle#untap()
endif
"}}}

" switch.vim {{{
if neobundle#tap('switch.vim')
  call neobundle#config({
  \   'autoload': {
  \     'commands': 'Switch'
  \   }
  \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    AutoCmd FileType gitrebase let b:switch_custom_definitions =
    \ [
    \   ['pick', 'squash', 'edit', 'reword', 'fixup', 'exec']
    \ ]
  endfunction

  nnoremap - :<C-u>Switch<CR>

  call neobundle#untap()
endif
" }}}

" vim-smartinput {{{
if neobundle#tap('vim-smartinput')
  call neobundle#config({
  \   'autoload': {
  \     'insert': '1'
  \   }
  \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    call smartinput#define_rule({
    \   'at':    '\s\+\%#',
    \   'char':  '<CR>',
    \   'input': "<C-o>:call setline('.', substitute(getline('.'), '\\s\\+$', '', ''))<CR><CR>",
    \ })
    call smartinput#map_to_trigger('i', '#', '#', '#')
    call smartinput#define_rule({
    \   'at':       '\%#',
    \   'char':     '#',
    \   'input':    '#{}<Left>',
    \   'filetype': ['ruby', 'ruby.rspec'],
    \   'syntax':   ['Constant', 'Special'],
    \ })

    call smartinput#map_to_trigger('i', '<Bar>', '<Bar>', '<Bar>')
    call smartinput#define_rule({
    \   'at':       '\({\|\<do\>\)\s*\%#',
    \   'char':     '<Bar>',
    \   'input':    '<Bar><Bar><Left>',
    \   'filetype': ['ruby', 'ruby.rspec'],
    \ })

    call smartinput#map_to_trigger('i', '<Plug>(smartinput_CR)', '<Enter>', '<Enter>')
    imap <silent> <CR> <C-g>u<Plug>(smartinput_CR)
  endfunction

  call neobundle#untap()
endif
" }}}

" vim-smartchr {{{
if neobundle#tap('vim-smartchr')
  call neobundle#config({
  \   'autoload': {
  \     'insert': '1'
  \   }
  \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    inoremap <expr> , smartchr#loop(', ', ',')
  endfunction

  call neobundle#untap()
endif
" }}}

" emmet-vim {{{
if neobundle#tap('emmet-vim')
  call neobundle#config({
  \   'autoload': {
  \     'filetypes': [
  \       'html',
  \       'xhtml',
  \       'css',
  \       'sass',
  \       'styl',
  \       'xml',
  \       'xls',
  \       'markdown'
  \     ]
  \   }
  \ })

  call neobundle#untap()
endif
" }}}

" yankround.vim {{{
if neobundle#tap('yankround.vim')
  call neobundle#config({
  \   'autoload': {
  \     'mappings': ['<Plug>(yankround-'],
  \     'functions': 'yankround#is_active'
  \   }
  \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:yankround_dir         = '~/.vim/cache/yankround'
    let g:yankround_max_history = 64
  endfunction

  nmap p <Plug>(yankround-p)
  xmap p <Plug>(yankround-p)
  nmap P <Plug>(yankround-P)

  nmap gp <Plug>(yankround-gp)
  xmap gp <Plug>(yankround-gp)
  nmap gP <Plug>(yankround-gP)

  " 直接nmapするとキーマップが展開されてしまうため、一旦マップを置き換える
  nnoremap <silent> <SID>(bp) :<C-u>bp<CR>
  nnoremap <silent> <SID>(bn) :<C-u>bn<CR>
  nmap <expr><C-p> yankround#is_active() ? "\<Plug>(yankround-prev)" : "\<SID>(bp)"
  nmap <expr><C-n> yankround#is_active() ? "\<Plug>(yankround-next)" : "\<SID>(bn)"

  call neobundle#untap()
endif
" }}}

" text object {{{

" vim-expand-region {{{
if neobundle#tap('vim-expand-region')
  call neobundle#config({
  \   'autoload': {
  \     'mappings': [
  \       '<Plug>(expand_region_expand)',
  \       '<Plug>(expand_region_shrink)'
  \     ]
  \   }
  \ })

  map <CR> <Plug>(expand_region_expand)
  map <BS> <Plug>(expand_region_shrink)

  let g:expand_region_text_objects = {
  \   "i'": 0,
  \   'i"': 0,
  \   'i)': 0,
  \   'i}': 0,
  \   'i]': 0,
  \   'il': 1,
  \   'ae': 1,
  \ }
  let g:expand_region_text_objects_ruby = copy(g:expand_region_text_objects)
  let g:expand_region_text_objects_ruby.ir = 1
  let g:expand_region_text_objects_ruby.ar = 1

  call neobundle#untap()
endif
" }}}

function! s:depend_textobj_user()
  call neobundle#config({'depends': 'kana/vim-textobj-user'})
endfunction

function! s:textobj_config(mappings)
  call neobundle#config({
  \   'depends': 'kana/vim-textobj-user',
  \   'autoload': {
  \     'mappings': map(a:mappings, '["xo", v:val]')
  \   }
  \ })
endfunction

" vim-textobj-ruby {{{
if neobundle#tap('vim-textobj-ruby')
  call neobundle#config({
  \   'autoload': {
  \     'filetypes': 'ruby'
  \   }
  \ })
  call s:depend_textobj_user()

  call neobundle#untap()
endif
" }}}

" vim-textobj-enclosedsyntax {{{
if neobundle#tap('vim-textobj-enclosedsyntax')
  call neobundle#config({
  \   'autoload': {
  \     'filetypes': 'ruby'
  \   }
  \ })
  call s:depend_textobj_user()

  call neobundle#untap()
endif
" }}}

" vim-textobj-syntax {{{
if neobundle#tap('vim-textobj-syntax')
  call s:textobj_config(['ay', 'iy'])

  call neobundle#untap()
endif
" }}}

" vim-textobj-parameter {{{
if neobundle#tap('vim-textobj-parameter')
  call s:textobj_config(['a,', 'i,'])

  call neobundle#untap()
endif
" }}}

"vim-textobj-line {{{
if neobundle#tap('vim-textobj-line')
  call s:textobj_config(['al', 'il'])

  call neobundle#untap()
endif
"}}}

" vim-textobj-entire {{{
if neobundle#tap('vim-textobj-entire')
  call s:textobj_config(['ae', 'ie'])

  call neobundle#untap()
endif
" }}}

" }}}

" operator {{{

function! s:operator_config(mappings)
  call neobundle#config({
  \   'depends': 'kana/vim-operator-user',
  \   'autoload': {
  \     'mappings': a:mappings
  \   }
  \ })
endfunction

" vim-operator-surround {{{
if neobundle#tap('vim-operator-surround')
  Arpeggio map <silent>sa <Plug>(operator-surround-append)
  Arpeggio map <silent>sd <Plug>(operator-surround-delete)
  Arpeggio map <silent>sr <Plug>(operator-surround-replace)

  call s:operator_config('<Plug>(operator-surround-')

  call neobundle#untap()
endif
" }}}

" vim-operator-comment {{{
if neobundle#tap('vim-operator-comment')
  Arpeggio map <silent>co <Plug>(operator-comment)
  Arpeggio map <silent>cu <Plug>(operator-uncomment)

  call s:operator_config(['<Plug>(operator-comment)', '<Plug>(operator-uncomment)'])

  call neobundle#untap()
endif
" }}}

" operator-camelize.vim {{{
if neobundle#tap('operator-camelize.vim')
  Arpeggio map <silent>ca <Plug>(operator-camelize-toggle)

  call s:operator_config('<Plug>(operator-camelize-toggle)')

  call neobundle#untap()
endif
" }}}

" operator concealedyank.vim {{{
if neobundle#tap('concealedyank.vim')
  vmap Y <Plug>(operator-concealedyank)

  call s:operator_config('<Plug>(operator-concealedyank)')

  call neobundle#untap()
endif
" }}}

" operator-replace.vim {{{
if neobundle#tap('vim-operator-replace')
  map _ <Plug>(operator-replace)

  call s:operator_config('<Plug>(operator-replace)')

  call neobundle#untap()
endif
" }}}

" operator-gitrebase {{{
if neobundle#tap('vim-operator-gitrebase')
  call neobundle#config({
  \   'depends': 'kana/vim-operator-user',
  \   'autoload': {
  \     'filetypes': 'gitrebase'
  \   }
  \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    map <buffer> s <Plug>(operator-gitrebase-squash)
    map <buffer> e <Plug>(operator-gitrebase-edit)
    map <buffer> r <Plug>(operator-gitrebase-reword)
    map <buffer> f <Plug>(operator-gitrebase-fixup)
  endfunction

  call neobundle#untap()
endif
" }}}

" }}}

" }}}


" 表示系プラグイン {{{

" vim-splash {{{
if neobundle#tap('vim-splash')
  let g:splash#path = $HOME . '/dotfiles/octocat.txt'
  AutoCmd StdinReadPre * autocmd! plugin-splash

  call neobundle#untap()
endif
" }}}

" indentline {{{
if neobundle#tap('indentLine')
  let g:indentLine_color_term = 239
  " let g:indentLine_color_gui = '#708090'
  let g:indentLine_char = '¦' "use ¦, ┆ or │
  let g:indentLine_fileTypeExclude = ['gitcommit', 'diff']

  call neobundle#untap()
endif
" }}}

" AnsiEsc.vim {{{
if neobundle#tap('AnsiEsc.vim')
  call neobundle#config({
  \   'autoload' : {
  \     'commands' : ['AnsiEsc']
  \   }
  \ })

  call neobundle#untap()
endif
" }}}

" lightline.vim {{{
if neobundle#tap('lightline.vim')
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

  call neobundle#untap()
endif
" }}}

" vim-spice {{{
if neobundle#tap('vim-spice')
  call neobundle#config({"type": "nosync"})

  AutoCmd ColorScheme * hi pluginVimSpice ctermbg=239
  let g:spice_highlight_group = 'pluginVimSpice'
  call neobundle#untap()
endif
" }}}

" vim-over {{{
if neobundle#tap('vim-over')
  call neobundle#config({
  \   'autoload': {
  \     'commands': 'OverCommandLine'
  \   }
  \ })

  cnoreabbrev <silent><expr>s getcmdtype()==':' && getcmdline()=~'^s' ? 'OverCommandLine<CR><C-u>%s/<C-r>=get([], getchar(0), '')<CR>' : 's'

  call neobundle#untap()
endif
"}}}

" hl_matchit {{{
if neobundle#tap('hl_matchit.vim')
  call neobundle#config({
  \   'autoload': {
  \     'filetypes': ['vim', 'ruby', 'sh']
  \   }
  \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    source $VIMRUNTIME/macros/matchit.vim
    " vim起動時にhl_matchitを起動するか
    let g:hl_matchit_enable_on_vim_startup = 1
    " highlightのパターン
    " :highlight に一覧がある
    let g:hl_matchit_hl_groupname = 'MatchParen'
    " 有効にするファイルの種類
    let g:hl_matchit_allow_ft = 'vim\|ruby\|sh'
  endfunction

  call neobundle#untap()
endif
" }}}

" ruby_hl_lvar.vim {{{
if neobundle#tap('ruby_hl_lvar.vim')
  call neobundle#config({
  \   'autoload': {
  \     'filetypes': ['ruby']
  \   }
  \ })

  let g:ruby_hl_lvar_hl_group = 'PreProc'

  function! neobundle#tapped.hooks.on_post_source(bundle)
    function! Ruby_hl_lvar_filetype()
      let groupname = 'vim_hl_lvar_'.bufnr('%')
      execute 'augroup '.groupname
        autocmd!
        if &filetype ==# 'ruby'
          if g:ruby_hl_lvar_auto_enable
            call ruby_hl_lvar#refresh(1)
            "autocmd TextChanged <buffer> call ruby_hl_lvar#refresh(0)
            "autocmd InsertEnter <buffer> call ruby_hl_lvar#disable(0)
            autocmd InsertLeave <buffer> call ruby_hl_lvar#refresh(0)
          else
            call ruby_hl_lvar#disable(1)
          endif
        endif
      augroup END
    endfunction

    silent! execute 'doautocmd FileType' &filetype
  endfunction

  call neobundle#untap()
endif
" }}}


" }}}


" 移動系プラグイン {{{

" accelerated-smooth-scroll {{{
if neobundle#tap('accelerated-smooth-scroll')
  call neobundle#config({
  \   'autoload': {
  \     'mappings': [
  \       '<Plug>(ac-smooth-scroll-c-d)',
  \       '<Plug>(ac-smooth-scroll-c-u)',
  \       '<Plug>(ac-smooth-scroll-c-f)',
  \       '<Plug>(ac-smooth-scroll-c-b)'
  \     ]
  \   }
  \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:ac_smooth_scroll_no_default_key_mappings = 1
  endfunction

  nmap <silent> <C-d> <Plug>(ac-smooth-scroll-c-d)
  nmap <silent> <C-u> <Plug>(ac-smooth-scroll-c-u)
  nmap <silent> <C-f> <Plug>(ac-smooth-scroll-c-f)
  nmap <silent> <C-b> <Plug>(ac-smooth-scroll-c-b)

  call neobundle#untap()
endif

" }}}

" vim-easymotion {{{
if neobundle#tap('vim-easymotion')
  call neobundle#config({
  \   'autoload': {
  \     'mappings': [
  \       '<Plug>(easymotion-s2)',
  \       '<Plug>(easymotion-sn)'
  \     ]
  \   }
  \ })

  let g:EasyMotion_smartcase   = 1

  nmap e <Plug>(easymotion-s2)
  nmap <Space>/ <Plug>(easymotion-sn)

  call neobundle#untap()
endif
" }}}

" clever-f {{{
if neobundle#tap('clever-f.vim')
  call neobundle#config({
  \   'autoload': {
  \     'mappings': 'f'
  \   }
  \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:clever_f_ignore_case           = 1
    let g:clever_f_use_migemo            = 1
    let g:clever_f_fix_key_direction     = 1
    let g:clever_f_chars_match_any_signs = ';'
  endfunction

  call neobundle#untap()
endif
" }}}

" }}}


" syntax plugins {{{

" vim-javascript-syntax {{{
if neobundle#tap('vim-javascript-syntax')
  call neobundle#config({
  \   'autoload':{
  \     'filetypes':['javascript']
  \   }
  \ })

  call neobundle#untap()
endif
" }}}

" tern_for_vim {{{
if neobundle#tap('tern_for_vim')
  call neobundle#config({
  \   'build': {
  \     'others': 'npm install'
  \   },
  \   'autoload': {
  \     'functions': ['tern#Complete', 'tern#Enable'],
  \     'filetypes': ['javascript']
  \   },
  \   'commands': [
  \     'TernDef', 'TernDoc', 'TernType', 'TernRefs', 'TernRename'
  \   ]
  \ })

  call neobundle#untap()
endif
" }}}

" vimperator-syntax {{{
" TODO
" }}}

" typescript-tools {{{
if neobundle#tap('typescript-tools')
  call neobundle#config({
  \   'autoload': {
  \     'filetypes': ['typescript']
  \   }
  \ })
  call neobundle#untap()
endif
" }}}

" }}}


" Application Plugins {{{

" Unite{{{

" unite.vim {{{
if neobundle#tap('unite.vim')
  call neobundle#config({
  \   'autoload' : {
  \     'commands' : [ "Unite", "UniteWithBufferDir" ]
  \   }
  \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:unite_enable_start_insert=1
    let g:unite_source_history_yank_enable=1
    let g:unite_source_file_mru_limit=200
  endfunction

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
  " 行
  nnoremap <silent> [unite]l :<C-u>Unite line<CR>

  call neobundle#untap()
endif
" }}}

" unite-ruby-require.vim {{{
if neobundle#tap('unite-ruby-require.vim')
  call neobundle#config({
  \   'autoload' : {
  \     'unite_sources' : ['ruby/require']
  \   }
  \ })

  nnoremap <silent> [unite]r :<C-u>Unite ruby/require<CR>

  call neobundle#untap()
endif
" }}}

" unite-outline {{{
if neobundle#tap('unite-outline')
  call neobundle#config({
  \   'autoload': {
  \     'unite_sources': ['outline']
  \   }
  \ })

  nnoremap <silent> [unite]o :<C-u>Unite outline<CR>

  call neobundle#untap()
endif
" }}}


" }}}


" vimfiler {{{
if neobundle#tap('vimfiler')
  call neobundle#config({
  \   'autoload': {
  \     'commands': [
  \       'VimFiler',
  \       'VimFilerTab',
  \       'VimFilerBufferDir',
  \       'VimFilerExplorer',
  \       'Edit',
  \       'Write',
  \       'Read',
  \       'Source'
  \     ],
  \     'mappings' : '<Plug>(vimfiler_',
  \     'explorer': 1
  \   },
  \   'depends': 'Shougo/unite.vim'
  \ })

  let g:vimfiler_as_default_explorer = 1
  let g:vimfiler_force_overwrite_statusline = 0
  let g:vimfiler_ignore_pattern = ''

  nnoremap <Space>ff :<C-u>VimFiler<CR>
  nnoremap <Space>ft :<C-u>VimFilerTab<CR>
  nnoremap <Space>tf :<C-u>VimFilerTab<CR>
  nnoremap <Space>fi :<C-u>VimFiler -split -simple -winwidth=35 -no-quit<CR>

  call neobundle#untap()
endif
" }}}

" vimshell {{{
if neobundle#tap('vimshell')
  call neobundle#config({
  \   'autoload': {
  \     'commands': ['VimShell', 'VimShellTab', 'VimShellCreate', 'VimShellPop']
  \   },
  \   'depends': ['Shougo/unite.vim', 'Shougo/neocomplete']
  \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    AutoCmd FileType vimshell call vimshell#hook#set('chpwd', ['MyChpwd'])

    function! MyChpwd(args, context)
      call vimshell#execute('ls')
    endfunction

    let g:vimshell_prompt = '% '
    let g:vimshell_secondary_prompt = '> '
    let g:vimshell_user_prompt = 'getcwd()'
  endfunction

  nnoremap <silent> <Space>ss :<C-u>VimShell<CR>
  nnoremap <silent> <Space>sc :<C-u>VimShellCreate<CR>
  nnoremap <silent> <Space>sp :<C-u>VimShellPop<CR>
  nnoremap <silent> <Space>st :<C-u>VimShellTab<CR>

  call neobundle#untap()
endif
" }}}

" calendar.vim {{{
if neobundle#tap('calendar.vim')
  call neobundle#config({
  \   'autoload': {
  \     'commands': ['Calendar']
  \   }
  \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:calendar_google_calendar = 1
    let g:calendar_google_task = 1
  endfunction

  call neobundle#untap()
endif
" }}}

" gundo.vim {{{
if neobundle#tap('gundo.vim')
  call neobundle#config({
  \   'autoload': {
  \     'commands': [
  \       'GundoToggle',
  \       'GundoShow',
  \       'GundoHide',
  \       'GundoRenderGraph'
  \     ]
  \   }
  \ })

  nnoremap <silent> <F2> :<C-u>GundoToggle<CR>
  call neobundle#untap()
endif
" }}}

" vim-ref {{{
if neobundle#tap('vim-ref')
  call neobundle#config({
  \   'autoload': {
  \     'commands': ['Ref'],
  \     'mappings': ['<Plug>(ref-keyword)']
  \   }
  \ })

  silent! nmap <silent> <unique> K <Plug>(ref-keyword)
  silent! vmap <silent> <unique> K <Plug>(ref-keyword)

  let g:ref_cache_dir = $HOME . '/.vim/cache/vim-ref'

  AutoCmd FileType ref nnoremap <buffer> q <C-w>c

  " refe のインストール方法
  " gem install refe2
  " bitclust setup --versions=2.1.0
  call neobundle#untap()
endif
" }}}

" vim-scouter {{{
if neobundle#tap('vim-scouter')
  call neobundle#config({
  \   'autoload': {
  \     'commands': ['Scouter', 'Scouter!']
  \   }
  \ })

  call neobundle#untap()
endif
" }}}

" }}}


" Web Service {{{
" hateblo.vim {{{
if neobundle#tap('hateblo.vim')
  call neobundle#config({
  \   'autoload': {
  \     'commands': ['HatebloCreate', 'HatebloCreateDraft', 'HatebloList']
  \   },
  \   'depends': ['mattn/webapi-vim', 'Shougo/unite.vim']
  \ })

  call neobundle#untap()
endif
" }}}

" vim-gista {{{
if neobundle#tap('vim-gista')
  call neobundle#config({
  \   'autoload': {
  \     'commands': ['Gista'],
  \     'mappings': '<Plug>(gista-',
  \     'unite_sources': 'gista'
  \   },
  \   'depends': ['unite.vim']
  \ })

  let g:gista#directory = $HOME . '/.vim/cache/gista/'
  let g:gista#update_on_write = 1
  let g:gista#github_user = 'pocke'
  let g:gista#post_private = 1
  call neobundle#untap()
endif
" }}}

"TweetVim {{{
if neobundle#tap('TweetVim')
  call neobundle#config({
  \   'autoload': {
  \     'commands': [
  \       'TweetVimVersioni',
  \       'TweetVimAddAccount',
  \       'TweetVimSwitchAccount',
  \       'TweetVimHomeTimeline',
  \       'TweetVimMentions',
  \       'TweetVimUserTimeline',
  \       'TweetVimListStatuses',
  \       'TweetVimSearch',
  \       'TweetVimSay',
  \       'TweetVimUserStream',
  \       'TweetVimCommandSay',
  \       'TweetVimCurrentLineSay',
  \       'TweetVimClearIcon'
  \     ]
  \   },
  \   'depends': [
  \     'tyru/open-browser.vim',
  \     'basyura/twibill.vim',
  \     'Shougo/unite.vim'
  \   ]
  \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    AutoCmd FileType tweetvim call s:tweetvim_buffer_configure()
    function! s:tweetvim_buffer_configure()
      nnoremap <silent><buffer> s :<C-u>TweetVimSay<CR>
      nnoremap <silent><buffer> G G:<C-u>call tweetvim#action('cursor_up')<CR>
      nmap <silent><buffer> x <Plug>(tweetvim_action_remove_status)
    endfunction

    let g:tweetvim_tweet_per_page = 100
    let g:tweetvim_config_dir     = expand('~/.vim/cache/tweetvim/')
    let g:tweetvim_display_source = 1
    let g:tweetvim_say_insert_account = 1
    let g:tweetvim_expand_t_co = 1
    let g:tweetvim_align_right = 1
    let g:tweetvim_async_post = 1
  endfunction

  call neobundle#untap()
endif
" }}}

" }}}

" editorconfig-vim {{{
if neobundle#tap('editorconfig-vim')
  function! s:load_editorconfig()
    if findfile('.editorconfig', '.;') != ''
      NeoBundleSource editorconfig-vim
      EditorConfigReload
    endif
  endfunction

  AutoCmd VimEnter * call s:load_editorconfig()

  call neobundle#untap()
endif
" }}}

" vimproc {{{
if neobundle#tap('vimproc')
  call neobundle#config({
  \ 'build' : {
  \     'windows' : 'make -f make_mingw32.mak',
  \     'cygwin' : 'make -f make_cygwin.mak',
  \     'mac' : 'make -f make_mac.mak',
  \     'unix' : 'make -f make_unix.mak'
  \   }
  \ })

  call neobundle#untap()
endif
" }}}


" open-browser.vim {{{
if neobundle#tap('open-browser.vim')
  let g:openbrowser_browser_commands = [{
  \   "name": "xdg-open",
  \   "args": ["{browser}", "{uri}"]
  \ }]

  call neobundle#untap()
endif
" }}}


" vim-quickrun {{{
if neobundle#tap('vim-quickrun')
  call neobundle#config({
  \   'autoload': {
  \     'mappings': [['nxo', '<Plug>(quickrun)']],
  \     'commands': 'QuickRun'
  \   }
  \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let s:quickfix4watchdogs = quickrun#outputter#quickfix#new()
    function! s:quickfix4watchdogs.finish(session)
      call call(quickrun#outputter#quickfix#new().finish, [a:session], self)
      HierUpdate
      QuickfixStatusEnable
      if &filetype ==# 'qf'
        execute "normal! \<C-w>\<C-p>"
      endif
    endfunction
    call quickrun#register_outputter("quickfix4watchdogs", s:quickfix4watchdogs)

    let g:quickrun_config = {
    \   '_': {
    \     'runner': 'vimproc',
    \     'runner/vimproc/updatetime': 60,
    \     'tempfile': '%{expand("%:p:h") . "/" . system("echo -n $(uuidgen)")}'
    \   },
    \   'markdown': {
    \     'type':      'markdown/gfm',
    \     'outputter': 'browser'
    \   },
    \   'ruby.rspec': {
    \     'command': 'rspec',
    \     'exec': 'bundle exec %c --color --tty %s'
    \   },
    \   'watchdogs_checker/_': {
    \     "outputter": "quickfix4watchdogs"
    \   }
    \ }

    AutoCmd FileType quickrun AnsiEsc
  endfunction

  nnoremap <silent><Leader>r :QuickRun<CR>

  call neobundle#untap()
endif
" }}}

" vim-quickrun-markdown-gfm {{{
if neobundle#tap('vim-quickrun-markdown-gfm')
  call neobundle#config({
  \   'autoload': {
  \     'filetypes': 'markdown'
  \   },
  \   'depends': [
  \     'mattn/webapi-vim',
  \     'thinca/vim-quickrun',
  \     'tyru/open-browser.vim'
  \   ]
  \ })

  call neobundle#untap()
endif
" }}}


" vim-watchdogs {{{
if neobundle#tap('vim-watchdogs')
  call neobundle#config({
  \   'depends': [
  \     'thinca/vim-quickrun',
  \     'Shougo/vimproc',
  \     'osyo-manga/shabadou.vim',
  \     'cohama/vim-hier',
  \     'syngan/vim-vimlint',
  \     'ynkdir/vim-vimlparser',
  \     'dannyob/quickfixstatus'
  \   ]
  \ })

  augroup source-watchdogs
    autocmd!
    autocmd BufWritePre * NeoBundleSource vim-watchdogs
    autocmd BufWritePre * autocmd! source-watchdogs
  augroup END

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:watchdogs_check_BufWritePost_enable = 1
    call watchdogs#setup(g:quickrun_config)
  endfunction

  call neobundle#untap()
endif
" }}}

" vim-vimlint {{{
if neobundle#tap('vim-vimlint')
  let g:vimlint#config = { "EVL103": 1 }

  call neobundle#untap()
endif
" }}}





" vim-visualstar {{{
if neobundle#tap('vim-visualstar')
  call neobundle#config({
  \   'autoload': {
  \     'mappings': [
  \       ['xv', '*'], ['xv', '#'], ['xv', 'g'], ['xv', 'g*']
  \     ]
  \   }
  \ })

  call neobundle#untap()
endif
" }}}



" vim-fugitive {{{
if neobundle#tap('vim-fugitive')
  function! neobundle#tapped.hooks.on_post_source(bundle)
    doautoall fugitive BufNewFile
  endfunction

  nnoremap <silent> <Space>gs :<C-u>Gstatus <CR>
  nnoremap <silent> <Space>gc :<C-u>Gcommit <CR>
  nnoremap <silent> <Space>gb :<C-u>Gblame  <CR>
  nnoremap <silent> <Space>gd :<C-u>Gdiff   <CR>
  nnoremap <silent> <Space>ga :<C-u>Gwrite  <CR>

  call neobundle#untap()
endif
" }}}


" gitv {{{
if neobundle#tap('gitv')
  call neobundle#config({
  \   'autoload': {
  \     'commands': ['Git', 'Gitv']
  \   },
  \   'depends': ['tpope/vim-fugitive']
  \ })

  nnoremap <Space>gv :<C-u>Gitv<CR>

  call neobundle#untap()
endif
" }}}

" vim-automatic {{{
if neobundle#tap('vim-automatic')
  call neobundle#config({
  \   'depends': ['osyo-manga/vim-gift']
  \ })

  function! s:my_temp_win_init(config, context)
    nnoremap <buffer> q :<C-u>q<CR>
  endfunction

  let g:automatic_default_set_config = {
  \   'apply':  function('s:my_temp_win_init'),
  \   'height': '60%',
  \   'move':   'bottom'
  \ }

  let g:automatic_config = [
  \   {
  \     'match': {
  \       'filetype': 'help',
  \       'buftype':  'help'
  \     },
  \     'set': {
  \       'width': 80,
  \       'move': 'right',
  \       'height': '100%'
  \     }
  \   },
  \   {
  \     'match': {
  \       'bufname': '\V[quickrun output]'
  \     },
  \     'set': {
  \       'height': 8,
  \     }
  \   }
  \ ]

  call neobundle#untap()
endif
" }}}

" vim {{{
" vimhelpgenerator {{{
if neobundle#tap('vimhelpgenerator')
  call neobundle#config({
  \   'autoload': {
  \     'commands': 'VimHelpGenerator'
  \   }
  \ })

  function! neobundle#tapped.hooks.on_post_source(bundle)
    let g:vimhelpgenerator_author  = 'Author  : pocke <p.ck.t22@gmail.com>'
    let g:vimhelpgenerator_license = 'vimhelpgenerator/MIT'
    let g:vimhelpgenerator_uri     = 'https://github.com/pocke/'
  endfunction

  call neobundle#untap()
endif
" }}}

" vim-prettyprint {{{
if neobundle#tap('vim-prettyprint')
  call neobundle#config({
  \   'autoload': {
  \     'commands': [{'name': 'PP', 'complete': 'expression'}],
  \     'functions': 'PP'
  \   }
  \ })

  call neobundle#untap()
endif
" }}}

" capture.vim {{{
if neobundle#tap('capture.vim')
  call neobundle#config({
  \   'autoload': {
  \     'commands':  [{'name': 'Capture', 'complete': 'command'}]
  \   }
  \ })

  call neobundle#untap()
endif
" }}}
" }}}


" keybind {{{

" vim-submode {{{
if neobundle#tap('vim-submode')
  let g:submode_keep_leaving_key = 1
  call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
  call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
  call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>-')
  call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>+')
  call submode#map('winsize', 'n', '', '>', '<C-w>>')
  call submode#map('winsize', 'n', '', '<', '<C-w><')
  call submode#map('winsize', 'n', '', '+', '<C-w>-')
  call submode#map('winsize', 'n', '', '-', '<C-w>+')

  function! s:my_x()
      undojoin
      normal! "_x
  endfunction

  nnoremap <silent> <Plug>(my-x) :<C-u>call <SID>my_x()<CR>
  call submode#enter_with('my_x', 'n', '', 'x', '"_x')
  call submode#map('my_x', 'n', 'r', 'x', '<Plug>(my-x)')

  call neobundle#untap()
endif
" }}}

" }}}



" netrw {{{
let g:netrw_http_xcmd = '-L -o'
" }}}

" }}}

" other {{{
syntax enable

" 256色
if $TERM == 'xterm' || $TERM == 'screen-256color'
  set t_Co=256
endif
" カラースキーム
colorscheme p
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

" swapファイルを作らない
set noswapfile

set helplang=ja,en

"indent
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set list
set listchars=tab:>-
if exists('+breakindent')
  set breakindent
endif

" ノーマルモードでoOで改行した時にコメントを追加しない
AutoCmd FileType * setlocal formatoptions-=o

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

" 入力中のコマンドを表示
set showcmd

" 余裕を持ってスクロール
set scrolloff=4

" コマンドラインでの補完を強くする
set wildmenu
set wildmode=longest:full,full
set wildignorecase
set history=1000

" ファイルを閉じてもundo
if has('persistent_undo')
  set undodir=~/.vim/undo
  if ! isdirectory(&undodir)
    call mkdir(&undodir, 'p')
  endif
  set undofile
endif

" 前回終了したカーソル行に移動
AutoCmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

" filetype
AutoCmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
AutoCmd BufNewFile,BufRead *.json                     set filetype=javascript
AutoCmd BufNewFile,BufRead *.jbuilder                 set filetype=ruby
AutoCmd BufWinEnter,BufNewFile *_spec.rb              set filetype=ruby.rspec

AutoCmd BufNewFile,BufRead *.css,*.scss,*.less setlocal foldmethod=marker foldmarker={,}
AutoCmd FileType eruby exec 'set filetype=' . 'eruby.' . b:eruby_subtype
AutoCmd FileType qf   nnoremap <buffer> <CR> <CR> | setlocal cursorline
AutoCmd CmdwinEnter * nnoremap <buffer> <CR> <CR> | setlocal cursorline
AutoCmd CmdwinEnter * nnoremap <buffer><silent> q :q<CR>
AutoCmd FileType gitcommit if getline(1) == '' | startinsert | endif
" TODO: kramdownを書いていると、markdownItalic ではないところで_を使えるが、
"       そのような場合にだけ markdownItalic を無効にしたい。
AutoCmd Syntax markdown syntax clear markdownItalic

" 長いFiletypeを省略する
AutoCmd FileType js nested setlocal ft=javascript
AutoCmd FileType md nested setlocal ft=markdown

" Open & AutoReload .vimrc {{{
" https://github.com/haya14busa/dotfiles
command! EVimrc e $MYVIMRC
command! ETabVimrc tabnew $MYVIMRC
command! SoVimrc source $MYVIMRC
AutoCmd BufWritePost *vimrc nested source $MYVIMRC
AutoCmd BufWritePost *gvimrc if has('gui_running') source $MYGVIMRC
"}}}

" statuslineを表示
set laststatus=2
set noshowmode

" 沢山表示
set display& display+=lastline

" ビープ音を鳴らさない
set visualbell t_vb=
set noerrorbells

set updatetime=200

" コマンドラインウィンドウの末尾20行を除いて全て削除
"AutoCmd CmdwinEnter * :<C-u>silent! 1,$-20 delete _ | call cursor("$", 1)


" }}}

" keybind {{{
nnoremap ; :
nnoremap : ;
vnoremap ; :
vnoremap : ;
" コマンドラインでのC-n|p と Up, Downの入れ替え
cnoremap <C-n>  <Down>
cnoremap <C-p>  <Up>
cnoremap <Down> <C-n>
cnoremap <Up>   <C-p>


" :h hogehoge@ とかなってhelpが見つからないのを解消
cnoremap <CR> <C-\>e <SID>cmdline_cr()<CR><CR>
function! s:cmdline_cr()
  let cmdline_orig = getcmdline()
  if cmdline_orig !~# '\v^h%[elp] .+\@$'
    return cmdline_orig
  endif

  let cmdline_ret = substitute(cmdline_orig, '\v\@$', '', '')
  return cmdline_ret
endfunction


" Esc 2回で強調を解除
" Can't use noh in function
function! s:hier_clear()
  if exists(':HierClear')
    HierClear
  endif
endfunction
nnoremap <silent> <Esc><Esc> :<C-u>nohlsearch<CR>:<C-u>call <SID>hier_clear()<CR>

" タブ移動
nnoremap <silent> <C-l> :<C-u>tabnext<CR>
nnoremap <silent> <C-h> :<C-u>tabprevious<CR>
nnoremap <silent> <Space>tt :<C-u>tabnew<CR>
nnoremap <silent> <Space>tc :<C-u>tabclose<CR>
call submode#enter_with('changetab', 'n', '', 'gt', 'gt')
call submode#enter_with('changetab', 'n', '', 'gT', 'gT')
call submode#map('changetab', 'n', '', 't', 'gt')
call submode#map('changetab', 'n', '', 'T', 'gT')

" タグジャンプを新しいタブで開く
nnoremap <F3> :<C-u>tab stj <C-R>=expand('<cword>')<CR><CR>

" TABにて対応ペアにジャンプ
nmap <Tab> %
nmap <Tab> %

nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz

nnoremap <Space>w :<C-u>w<CR>
nnoremap <Space>q :<C-u>q<CR>
nnoremap <Space>Q :<C-u>q!<CR>

nnoremap <Space>h ^
nnoremap <Space>l $

nnoremap <Left>  <C-w>h
nnoremap <Down>  <C-w>j
nnoremap <Up>    <C-w>k
nnoremap <Right> <C-w>l

nnoremap <C-Left>  <C-w><
nnoremap <C-Down>  <C-w>-
nnoremap <C-Up>    <C-w>+
nnoremap <C-Right> <C-w>>

vnoremap <Left>  <Nop>
vnoremap <Down>  <Nop>
vnoremap <Up>    <Nop>
vnoremap <Right> <Nop>

inoremap <Left>  <Nop>
inoremap <Down>  <Nop>
inoremap <Up>    <Nop>
inoremap <Right> <Nop>

" set undo point
inoremap <CR> <C-g>u<CR>

inoremap <C-o> <Esc>O

nnoremap Q <Nop>
" }}}


" set vim operators {{{
function! s:for_vim_operator()
  NeoBundleSource vim-operator-user
  function! s:operator_vim_execute(motion_wise)
    if line("'[") != line("']")
      return
    endif
    let start = col("'[") - 1
    let end   = col("']")
    let sel = strpart(getline('.'), start, end - start)
    execute sel
  endfunction

  call operator#user#define('vim-execute', s:SID . 'operator_vim_execute')

  map <buffer> E <Plug>(operator-vim-execute)


  function! s:operator_help(motion_wise)
    if line("'[") != line("']")
      return
    endif
    let start = col("'[") - 1
    let end   = col("']")
    let sel = strpart(getline('.'), start, end - start)
    execute "help " . sel
  endfunction

  call operator#user#define('help', s:SID . 'operator_help')

  map <buffer> <F1> <Plug>(operator-help)


  " http://deris.hatenablog.jp/entry/2013/07/05/023835 {{{
  function! s:open_neo_bundle_path(motion_wise)
    if line("'[") != line("']")
      return
    endif
    let start = col("'[") - 1
    let end = col("']")
    let sel = strpart(getline('.'), start, end - start)
    let sel = substitute(sel, '^\%(github\|gh\|git@github\.com\):\(.\+\)', 'https://github.com/\1', '')
    let sel = substitute(sel, '^\%(bitbucket\|bb\):\(.\+\)', 'https://bitbucket.org/\1', '')
    let sel = substitute(sel, '^gist:\(.\+\)', 'https://gist.github.com/\1', '')
    let sel = substitute(sel, '^git://', 'https://', '')
    if sel =~ '^https\?://'
      call openbrowser#open(sel)
    elseif sel =~ '/'
      call openbrowser#open('https://github.com/'.sel)
    else
      call openbrowser#open('https://github.com/vim-scripts/'.sel)
    endif
  endfunction

  call operator#user#define('open-neobundlepath', s:SID . 'open_neo_bundle_path')

  map <buffer> gz <Plug>(operator-open-neobundlepath)
  " }}}
endfunction

AutoCmd FileType vim call s:for_vim_operator()
" }}}

function! s:show_cursor()
  set cursorline!
  set cursorcolumn!

  redraw
  sleep 50 m

  set cursorline!
  set cursorcolumn!
  return ''
endfunction
nnoremap <silent><C-s> :<C-u>call <SID>show_cursor()<CR>
inoremap <silent><C-s> <C-r>=<SID>show_cursor()<CR>



" vim:set foldmethod=marker:
