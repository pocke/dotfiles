" encoding
set encoding=utf-8
scriptencoding utf-8
" これで開こうとする
set fileencodings=utf-8,cp932,sjis,euc-jp
" これで保存しようとする
set fileencoding=utf-8
set termencoding=utf-8


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
if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

let g:neobundle#install_max_processes = 20

call neobundle#begin(expand('~/.vim/bundle/'))


function! s:load_bundles()
  NeoBundleFetch 'Shougo/neobundle.vim'

  " 入力系プラグイン {{{

  " 補完
  NeoBundle     'Shougo/neocomplete'

  NeoBundleLazy 'osyo-manga/vim-marching'

  NeoBundle     'Shougo/neosnippet'
  NeoBundle     'Shougo/neosnippet-snippets'
  NeoBundle     'pocke/neosnippet-incomment'


  NeoBundleLazy 'kana/vim-smartinput'
  NeoBundleLazy 'kana/vim-smartchr'
  NeoBundleLazy 'mattn/emmet-vim'
  NeoBundleLazy 'LeafCage/yankround.vim'

  " text object {{{
  NeoBundleLazy 'terryma/vim-expand-region'
  NeoBundleLazy 'kana/vim-textobj-user'
  NeoBundleLazy 'rhysd/vim-textobj-ruby'
  NeoBundleLazy 'sgur/vim-textobj-parameter'
  NeoBundleLazy 'kana/vim-textobj-entire'
  NeoBundleLazy 'whatyouhide/vim-textobj-xmlattr'

  " }}}

  " operator {{{
  NeoBundleLazy 'kana/vim-operator-user'
  NeoBundleLazy 'rhysd/vim-operator-surround'
  NeoBundleLazy 'emonkak/vim-operator-comment'
  NeoBundleLazy 'tyru/operator-camelize.vim'
  NeoBundleLazy 'chikatoike/concealedyank.vim'
  NeoBundleLazy 'kana/vim-operator-replace'
  " }}}

  " }}}

  " 表示系プラグイン {{{
  NeoBundle     'thinca/vim-splash'
  NeoBundleLazy 'vim-scripts/AnsiEsc.vim'
  NeoBundle     'itchyny/lightline.vim'
  NeoBundle     'osyo-manga/vim-brightest'
  NeoBundleLazy 'haya14busa/incsearch.vim'

  NeoBundleLazy 'pocke/ruby_hl_lvar.vim'

  " colorscheme {{{
  NeoBundle 'chriskempson/vim-tomorrow-theme'
  NeoBundle 'w0ng/vim-hybrid'
  " }}}
  " }}}

  " 移動系プラグイン {{{
  " ぬるぬるスクロール
  NeoBundleLazy 'yonchu/accelerated-smooth-scroll'
  NeoBundleLazy 'Lokaltog/vim-easymotion'
  NeoBundleLazy 'rhysd/clever-f.vim'
  " }}}

  " syntax and filetype plugins {{{
  " JavaScript {{{
  NeoBundleLazy 'jelera/vim-javascript-syntax'
  NeoBundleLazy 'marijnh/tern_for_vim'
  " AltJS {{{
  NeoBundleLazy 'kchmck/vim-coffee-script'
  NeoBundleLazy 'leafgarland/typescript-vim'
  NeoBundleLazy 'clausreinke/typescript-tools'
  " }}}
  " }}}

  NeoBundleLazy 'hail2u/vim-css3-syntax'
  NeoBundleLazy 'groenewege/vim-less'
  NeoBundleLazy 'wavded/vim-stylus'
  NeoBundleLazy 'slim-template/vim-slim'

  " scala {{{
  NeoBundleLazy 'derekwyatt/vim-scala'
  NeoBundleLazy 'derekwyatt/vim-sbt'
  " }}}

  NeoBundleLazy 'vim-scripts/javacomplete'
  NeoBundleLazy 'fatih/vim-go'
  NeoBundleLazy 'yosssi/vim-ace'
  NeoBundleLazy 'cespare/vim-toml'
  NeoBundleLazy 'stephpy/vim-yaml'
  " If lazy, compound filetype is wrong...
  NeoBundle 'vim-ruby/vim-ruby'
  NeoBundle 'gre/play2vim'

  NeoBundle 'https://vimperator-labs.googlecode.com/hg/', {
  \   'name': 'vimperator-syntax',
  \   'type': 'hg',
  \   'rtp':  'vimperator/contrib/vim/'
  \ }
  " }}}

  " Application Plugins {{{

  " Unite {{{
  NeoBundleLazy 'Shougo/unite.vim'
  NeoBundleLazy 'Shougo/unite-outline'
  " }}}

  NeoBundleLazy 'Shougo/vimfiler'
  NeoBundleLazy 'sjl/gundo.vim'
  NeoBundleLazy 'thinca/vim-ref'

  NeoBundleLazy 'thinca/vim-scouter'

  " Web service {{{
  NeoBundleLazy 'moznion/hateblo.vim'
  NeoBundleLazy 'lambdalisue/vim-gista'
  " }}}

  " }}}

  NeoBundle     'sudo.vim'
  NeoBundleLazy 'editorconfig/editorconfig-vim'

  " 非同期処理
  NeoBundle     'Shougo/vimproc.vim'
  NeoBundleLazy 'tyru/open-browser.vim'

  " コマンド実行
  NeoBundleLazy 'thinca/vim-quickrun'
  " markdown quickrun
  NeoBundleLazy 'superbrothers/vim-quickrun-markdown-gfm'
  " 構文チェック
  NeoBundleLazy 'osyo-manga/vim-watchdogs'


  " Visual Mode でも * で検索
  NeoBundleLazy 'haya14busa/vim-asterisk'

  " git
  NeoBundleLazy 'tpope/vim-fugitive'
  NeoBundle     'rhysd/committia.vim'

  " window管理
  NeoBundle     'pocke/vim-automatic'
  " Buffer移動
  NeoBundleLazy 'kana/vim-altr'

  " vim {{{
  NeoBundleLazy 'vim-jp/vimdoc-ja'
  NeoBundleLazy 'thinca/vim-prettyprint'
  NeoBundleLazy 'tyru/capture.vim'
  NeoBundleFetch 'thinca/vim-themis'
  "}}}


  " keybind {{{
  NeoBundle     'kana/vim-submode'
  NeoBundle     'kana/vim-arpeggio'
  " }}}
endfunction

if neobundle#load_cache()
  call s:load_bundles()
  NeoBundleSaveCache
endif

call neobundle#end()
filetype plugin indent on     " Required!
"}}}



" plugins settings {{{
call arpeggio#load()

" 入力系プラグイン {{{
" neocomplete {{{
if neobundle#tap('neocomplete')
  call neobundle#config({
  \   'depends': ['Shougo/context_filetype.vim', 'pocke/neco-look'],
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
  " preview window を閉じない
  let g:neocomplete#enable_auto_close_preview = 0
  AutoCmd InsertLeave * silent! pclose!

  let g:neocomplete#max_keyword_width = 10000


  if !exists('g:neocomplete#delimiter_patterns')
    let g:neocomplete#delimiter_patterns= {}
  endif
  let g:neocomplete#delimiter_patterns.ruby = ['::']

  if !exists('g:neocomplete#same_filetypes')
    let g:neocomplete#same_filetypes = {}
  endif
  let g:neocomplete#same_filetypes.ruby = 'eruby'

  if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
  endif

  let g:neocomplete#sources#omni#input_patterns.go = '.*'

  if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
  endif

  let g:neocomplete#force_omni_input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'

  let s:neco_dicts_dir = $HOME . '/dicts'
  if isdirectory(s:neco_dicts_dir)
    let g:neocomplete#sources#dictionary#dictionaries = {
    \   'ruby': s:neco_dicts_dir . '/ruby.dict',
    \   'javascript': s:neco_dicts_dir . '/jquery.dict',
    \ }
  endif
  let g:neocomplete#data_directory = $HOME . '/.vim/cache/neocomplete'

  call neocomplete#custom#source('look', 'min_pattern_length', 1)

  call neobundle#untap()
endif
"}}}

" vim-marching {{{
if neobundle#tap('vim-marching')
  call neobundle#config({
  \   'autoload': {
  \     'filetypes': ['c', 'cpp']
  \   },
  \   'depends': ['Shougo/vimproc.vim', 'osyo-manga/vim-reunions']
  \ })

  let g:marching_enable_neocomplete = 1

  call neobundle#untap()
endif
" }}}

" neosnippet {{{
if neobundle#tap('neosnippet')
  "http://kazuph.hateblo.jp/entry/2013/01/19/193745

  " <TAB>: completion.
  inoremap <expr><S-TAB>  pumvisible() ? "\<C-p>" : "\<S-TAB>"

  " Plugin key-mappings.
  imap <C-k> <Esc>:let g:neosnippet_expanding_or_jumpping = 1<CR>a<Plug>(neosnippet_expand_or_jump)
  smap <C-k> <Plug>(neosnippet_expand_or_jump)

  " SuperTab like snippets behavior.
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
    \   'at':       '\v(''[^"]*)@<!\V\%#',
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

    call smartinput#map_to_trigger('i', ':', ':', ':')
    call smartinput#define_rule({
    \   'at':       '\w\%#',
    \   'char':     ':',
    \   'input':    ': <Esc>bbi"<Esc>wwi"<Right><Right>',
    \   'filetype': ['json'],
    \   'syntax':   ['jsonFold']
    \ })

    call smartinput#map_to_trigger('i', '<Plug>(smartinput_CR)', '<Enter>', '<Enter>')
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
  \     'functions': 'yankround#is_active', 
  \     'unite_sources': ['yankround'],
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
  \     'mappings': ['<Plug>(expand_region_']
  \   }
  \ })

  map <CR> <Plug>(expand_region_expand)
  map <BS> <Plug>(expand_region_shrink)

  function! neobundle#tapped.hooks.on_source(bundle)
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
    let g:expand_region_text_objects_html = copy(g:expand_region_text_objects)
    let g:expand_region_text_objects_html.it = 1
    let g:expand_region_text_objects_html.ax = 1
  endfunction

  call neobundle#untap()
endif
" }}}

function! s:textobj_tap(name, mappings)
  if neobundle#tap(a:name)
    call neobundle#config({
    \   'depends': 'kana/vim-textobj-user',
    \   'autoload': {
    \     'mappings': map(a:mappings, '["xo", v:val]')
    \   }
    \ })

    call neobundle#untap()
  endif
endfunction

" vim-textobj-ruby {{{
call s:textobj_tap("vim-textobj-ruby", ['ar', 'ir'])
" }}}

" vim-textobj-parameter {{{
call s:textobj_tap('vim-textobj-parameter', ['a,', 'i,'])
" }}}

" vim-textobj-entire {{{
call s:textobj_tap('vim-textobj-entire', ['ae', 'ie'])
" }}}

" vim-textobj-xmlattr {{{
call s:textobj_tap('vim-textobj-xmlattr', ['ix', 'ax'])
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
  Arpeggio map <silent>CO <Plug>(operator-comment)<Plug>(operator-comment)
  Arpeggio map <silent>CU <Plug>(operator-uncomment)<Plug>(operator-uncomment)

  call s:operator_config(['<Plug>(operator-comment)', '<Plug>(operator-uncomment)', '<Plug>(operator-uncomment)<Plug>(operator-uncomment)', '<Plug>(operator-comment)<Plug>(operator-comment)'])

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

" vim-operator-replace {{{
if neobundle#tap('vim-operator-replace')
  map _ <Plug>(operator-replace)

  call s:operator_config('<Plug>(operator-replace)')

  call neobundle#untap()
endif
" }}}

" }}}


" 表示系プラグイン {{{

" vim-splash {{{
if neobundle#tap('vim-splash')
  let g:splash#path = $HOME . '/dotfiles/octocat.txt'
  " Don't work starting 'vim -t {tag}'
  autocmd BufReadPre * autocmd! plugin-splash VimEnter

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
  \       ['readonly', 'filename', 'modified'],
  \     ]
  \   },
  \   'component': {},
  \   'component_visible_condition': {},
  \ }

  call neobundle#untap()
endif
" }}}

" vim-brightest {{{
if neobundle#tap('vim-brightest')
  AutoCmd ColorScheme * hi pluginVimBrightest ctermbg=239 guibg=#444444

  let g:brightest#enable_highlight_all_window = 0
  let g:brightest#highlight = {
  \   'group': 'pluginVimBrightest',
  \ }

  call neobundle#untap()
endif
" }}}

" incsearch.vim {{{
if neobundle#tap('incsearch.vim')
  call neobundle#config({
  \   'autoload': {
  \     'mappings': ['<Plug>(incsearch-']
  \   }
  \ })

  map / <Plug>(incsearch-forward)
  map ? <Plug>(incsearch-backward)
  map g/ <Plug>(incsearch-stay)

  function neobundle#tapped.hooks.on_post_source(bundle)
    let g:incsearch#magic = '\v'
    let g:incsearch#auto_nohlsearch = 1

    map n  <Plug>(incsearch-nohl-n)zz
    map N  <Plug>(incsearch-nohl-N)zz

    IncSearchNoreMap <CR> <CR>zz
    IncSearchNoreMap <C-h> <BS>
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

  function! neobundle#tapped.hooks.on_post_source(bundle)
    let g:ruby_hl_lvar_hl_group = 'PreProc'

    silent! execute 'doautocmd FileType' &filetype

    let g:neosnippet_expanding_or_jumpping = 0
    function! s:ruby_hl_lvar_on_textchanged() abort
      if g:neosnippet_expanding_or_jumpping
        let g:neosnippet_expanding_or_jumpping = 0
      else
        call ruby_hl_lvar#refresh(0)
      endif
    endfunction

    " override
    function! Ruby_hl_lvar_filetype()
      let groupname = 'vim_hl_lvar_'.bufnr('%')
      execute 'augroup '.groupname
        autocmd!
        if &filetype =~# '\<ruby\>'
          if g:ruby_hl_lvar_auto_enable
            call ruby_hl_lvar#refresh(1)
            autocmd TextChanged  <buffer> call s:ruby_hl_lvar_on_textchanged()
            autocmd InsertLeave  <buffer> call ruby_hl_lvar#refresh(0)
            autocmd TextChangedI <buffer> call ruby_hl_lvar#refresh(0)
          else
            call ruby_hl_lvar#disable(1)
          endif
        endif
      augroup END
    endfunction
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
  \     'mappings': ['<Plug>(ac-smooth-scroll-c-']
  \   }
  \ })

  let g:ac_smooth_scroll_no_default_key_mappings = 1

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
  \     'mappings': ['<Plug>(easymotion-']
  \   }
  \ })

  let g:EasyMotion_smartcase   = 1
  let g:EasyMotion_use_migemo  = 1

  nmap e <Plug>(easymotion-s2)

  call neobundle#untap()
endif
" }}}

" clever-f {{{
if neobundle#tap('clever-f.vim')
  call neobundle#config({
  \   'autoload': {
  \     'mappings': ['f', 'F']
  \   }
  \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:clever_f_ignore_case           = 1
    " let g:clever_f_use_migemo            = 1
    " let g:clever_f_fix_key_direction     = 1
    let g:clever_f_chars_match_any_signs = ';'
  endfunction

  call neobundle#untap()
endif
" }}}

" }}}


" syntax plugins {{{

function! s:tap_filetype(name, ft)
  if neobundle#tap(a:name)
    call neobundle#config({
    \   'autoload': {
    \     'filetypes': a:ft
    \   }
    \ })

    call neobundle#untap()
  endif
endfunction


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

  let g:tern_map_keys = 0

  call neobundle#untap()
endif
" }}}

call s:tap_filetype('vim-javascript-syntax', 'javascript')
call s:tap_filetype('vim-coffee-script', 'coffee')
call s:tap_filetype('typescript-vim', 'typescript')
call s:tap_filetype('typescript-tools', 'typescript')

" vim-css3-syntax {{{
if neobundle#tap('vim-css3-syntax')
  call neobundle#config({
  \   'autoload': {
  \     'filetypes': 'css'
  \   }
  \ })

  augroup VimCSS3Syntax
    autocmd!
    autocmd FileType css setlocal iskeyword+=-
  augroup END

  call neobundle#untap()
endif
" }}}

call s:tap_filetype('vim-less', 'less')
call s:tap_filetype('vim-stylus', 'stylus')
call s:tap_filetype('vim-slim', 'slim')
call s:tap_filetype('vim-scala', 'scala')
call s:tap_filetype('vim-sbt', 'sbt')

if neobundle#tap('javacomplete')
  call neobundle#config({
  \   'build': {
  \     'others': 'javac autoload/Reflection.java',
  \   },
  \   'autoload': {
  \     'filetypes': 'java'
  \   }
  \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    AutoCmd FileType java setl omnifunc=javacomplete#Complete
  endfunction

  call neobundle#untap()
endif


" vim-go {{{
if neobundle#tap('vim-go')
  call neobundle#config({
  \   'autoload': {
  \     'filetypes': 'go'
  \   }
  \ })

  function! neobundle#tapped.hooks.on_source(bundle)
    if executable("goimports")
      let g:go_fmt_command = "goimports"
    endif
  endfunction

  call neobundle#untap()
endif
" }}}

call s:tap_filetype('vim-ace', 'ace')
call s:tap_filetype('vim-toml', 'toml')
call s:tap_filetype('vim-yaml', 'yaml')

" }}}


" Application Plugins {{{

" Unite{{{

" unite.vim {{{
if neobundle#tap('unite.vim')
  call neobundle#config({
  \   'autoload' : {
  \     'commands' : [ "Unite", "UniteWithBufferDir" ]
  \   },
  \   'depends': ['Shougo/neomru.vim'],
  \ })
  function! neobundle#tapped.hooks.on_source(bundle)
    let g:unite_enable_start_insert=1
    let g:unite_source_history_yank_enable=1
    let g:unite_source_file_mru_limit=200
  endfunction

  nnoremap <SID>(unite) <Nop>
  nmap <Space>u <SID>(unite)
  nnoremap <silent> <SID>(unite)u :<C-u>Unite file file_mru buffer<CR>
  nnoremap <silent> <SID>(unite)y :<C-u>Unite yankround<CR>

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

  nnoremap <silent> <SID>(unite)o :<C-u>Unite outline<CR>

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
  let g:vimfiler_ignore_pattern = '^.git'

  nnoremap <Space>ff :<C-u>VimFiler<CR>
  nnoremap <Space>ft :<C-u>VimFilerTab<CR>

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
  \   },
  \ })

  silent! nmap <silent> <unique> K <Plug>(ref-keyword)
  silent! vmap <silent> <unique> K <Plug>(ref-keyword)

  let g:ref_cache_dir = $HOME . '/.vim/cache/vim-ref'

  AutoCmd FileType ref nnoremap <buffer> q <C-w>c

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

" vimproc.vim {{{
if neobundle#tap('vimproc.vim')
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
    \     'exec': 'bundle exec %c --color --tty %s',
    \     'outputter/buffer/name': '[quickrun output rspec]'
    \   },
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
  \   'autoload': {
  \     'commands': ['WatchdogsRun']
  \ },
  \   'depends': [
  \     'thinca/vim-quickrun',
  \     'Shougo/vimproc.vim',
  \     'osyo-manga/shabadou.vim',
  \     'cohama/vim-hier',
  \     'dannyob/quickfixstatus'
  \   ]
  \ })

  augroup source-watchdogs
    autocmd!
    autocmd BufWritePre * NeoBundleSource vim-watchdogs
    autocmd BufWritePre * autocmd! source-watchdogs
  augroup END

  AutoCmd FileType go command! -buffer Lint WatchdogsRun watchdogs_checker/golint
  AutoCmd FileType go command! -buffer Build WatchdogsRun watchdogs_checker/go_build
  AutoCmd FileType go command! -buffer Test WatchdogsRun watchdogs_checker/go_test

  let g:hier_highlight_group_qf = 'Error'

  function! neobundle#tapped.hooks.on_source(bundle)
    let s:quickfix4watchdogs = quickrun#outputter#quickfix#new()
    function! s:quickfix4watchdogs.finish(session)
      call call(quickrun#outputter#quickfix#new().finish, [a:session], self)
      HierUpdate
      QuickfixStatusEnable
      if &filetype ==# 'qf'
        nnoremap <buffer>q :q<CR>
        wincmd p
      endif
      if &ft == 'go'
        if GoComma()
          w
          WatchdogsRun
        endif
      endif
    endfunction
    call quickrun#register_outputter("quickfix4watchdogs", s:quickfix4watchdogs)

    let g:quickrun_config['watchdogs_checker/_'] = {
    \   "outputter": "quickfix4watchdogs"
    \ }

    let g:quickrun_config['watchdogs_checker/golint'] = {
    \   'command':     'golint',
    \   'exec':        '%c %o %s:p',
    \   "errorformat" : '%f:%l:%c: %m,%-G%.%#',
    \ }

    let g:quickrun_config['watchdogs_checker/go_build'] = {
    \   'command':     'go',
    \   'exec':        '%c build %o',
    \   "errorformat" : '%f:%l: %m,%-G%.%#',
    \ }

    let g:quickrun_config['watchdogs_checker/go_test'] = {
    \   'command':     'go',
    \   'exec':        '%c test %o',
    \   "errorformat" : '%f:%l: %m,%-G%.%#',
    \ }

    let g:quickrun_config['c/watchdogs_checker'] = {
    \   "type": "watchdogs_checker/gcc",
    \   "cmdopt": '%{PathToGccOpt()}',
    \ }

    let g:quickrun_config['ruby.rspec/watchdogs_checker'] = {
    \   'type': 'watchdogs_checker/ruby',
    \ }

    let g:watchdogs_check_BufWritePost_enable = 1
    call watchdogs#setup(g:quickrun_config)

    function! PathToGccOpt()
      let p = &path
      let sp = split(p, ',')
      let sp = map(sp, '"-I" . v:val')
      let result = join(sp, ' ')
      return result
    endfunction
  endfunction


  call neobundle#untap()
endif
" }}}

" vim-asterisk {{{
if neobundle#tap('vim-asterisk')
  call neobundle#config({
  \   'autoload': {
  \     'mappings': [
  \       '<Plug>(incsearch-nohl)<Plug>(asterisk-',
  \     ]
  \   },
  \   'depends': ['haya14busa/incsearch.vim']
  \ })

  map * <Plug>(incsearch-nohl)<Plug>(asterisk-*)
  map # <Plug>(incsearch-nohl)<Plug>(asterisk-#)
  map z* <Plug>(incsearch-nohl)<Plug>(asterisk-z*)
  map z# <Plug>(incsearch-nohl)<Plug>(asterisk-z#)

  call neobundle#untap()
endif
" }}}



" vim-fugitive {{{
if neobundle#tap('vim-fugitive')
  call neobundle#config({
  \   'autoload': {
  \     'commands': ['Gblame']
  \   }
  \ })

  function! neobundle#tapped.hooks.on_post_source(bundle)
    doautoall fugitive BufNewFile
  endfunction

  call neobundle#untap()
endif
" }}}

" committia.vim {{{
if neobundle#tap('committia.vim')
  let g:committia_hooks = {}
  function! g:committia_hooks.edit_open(info)
    setlocal spell

    imap <buffer><C-d> <Plug>(committia-scroll-diff-down-half)
    imap <buffer><C-u> <Plug>(committia-scroll-diff-up-half)
    nmap <buffer><C-d> <Plug>(committia-scroll-diff-down-half)
    nmap <buffer><C-u> <Plug>(committia-scroll-diff-up-half)
  endfunction

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
    nnoremap <buffer> Q :<C-u>q<CR>
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
  \   },
  \   {
  \     'match': {
  \       'bufname': '^\[quickrun output rspec\]'
  \     },
  \     'set': {
  \       'height': '20%'
  \     }
  \   }
  \ ]

  call neobundle#untap()
endif
" }}}

" vim-altr {{{
if neobundle#tap('vim-altr')
  call neobundle#config({
  \   'autoload': {
  \     'mappings': '<Plug>(altr-'
  \   }
  \ })

  nmap <PageUp>   <Plug>(altr-forward)
  nmap <PageDown> <Plug>(altr-back)

  function neobundle#tapped.hooks.on_source(bundle)
    " For rails tdd
    call altr#define('app/%/%.rb', 'spec/%/%_spec.rb')

    call altr#define('config/locales/en.%yml', 'config/locales/ja.%yml')
    call altr#define('lib/%.rb', 'spec/lib/%_spec.rb')

    " For golang test
    call altr#define('%.go', '%_test.go')
  endfunction

  call neobundle#untap()
endif
" }}}

" vim {{{

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

" K で:help
set keywordprg=""

" 折りたたみ-展開
set foldmethod=manual
set foldlevel=99
set conceallevel=0

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

" statuslineを表示
set laststatus=2
set noshowmode

" 沢山表示
set display& display+=lastline

" ビープ音を鳴らさない
set visualbell t_vb=
set noerrorbells

set updatetime=1000

set tabpagemax=100

" h clipboard-excludeを参照。excludeは一番最後じゃないとだめ
set clipboard& clipboard^=unnamedplus

set mouse=a
set spelllang+=cjk

" Vim script で \ を入力した時にインデントしない
let g:vim_indent_cont = 0

augroup remove_java_option_env_var
  autocmd!
  autocmd FileType java silent !unset '$_JAVA_OPTIONS'
  autocmd FileType java autocmd! remove_java_option_env_var
augroup END

let g:java_highlight_all=1
let g:java_highlight_debug=1
let g:java_allow_cpp_keywords=1
let g:java_space_errors=1
let g:java_highlight_functions=1


" 前回終了したカーソル行に移動
AutoCmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

" filetype
AutoCmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
AutoCmd BufNewFile,BufRead *.jbuilder                 set filetype=ruby
AutoCmd BufNewFile,BufRead Guardfile                  set filetype=ruby
AutoCmd BufNewFile,BufRead .pryrc                     set filetype=ruby
AutoCmd BufNewFile,BufRead *_spec.rb                  set filetype=ruby.rspec

AutoCmd BufNewFile,BufRead *.css,*.scss,*.less setlocal foldmethod=marker foldmarker={,}

" haya14busa.com/install-stylus-nib-and-vim-auto-compile/
AutoCmd BufWritePost *.styl silent !stylus <afile> -u nib > /dev/null
AutoCmd FileType eruby exec 'set filetype=' . 'eruby.' . b:eruby_subtype
AutoCmd FileType qf   nnoremap <buffer> <CR> <CR> | setlocal cursorline
AutoCmd CmdwinEnter * nnoremap <buffer> <CR> <CR> | setlocal cursorline
AutoCmd CmdwinEnter * nnoremap <buffer><silent> q :q<CR>
AutoCmd FileType godoc nnoremap <buffer><silent> q :q<CR>
AutoCmd FileType gitcommit if getline(1) == '' | startinsert | endif
" TODO: kramdownを書いていると、markdownItalic ではないところで_を使えるが、
"       そのような場合にだけ markdownItalic を無効にしたい。
AutoCmd Syntax markdown syntax clear markdownItalic
AutoCmd Syntax markdown syntax sync fromstart
AutoCmd FileType markdown,text,gitcommit setl spell
AutoCmd BufNewFile,BufRead config/locales/*.yml setl spell
AutoCmd FileType ruby setl tags+=~/.gem/ruby/2.2.0/gems/tags

" 長いFiletypeを省略する
AutoCmd FileType js nested setlocal ft=javascript
AutoCmd FileType md nested setlocal ft=markdown

" help key mappings
AutoCmd FileType help call s:set_help_keymap()
function! s:set_help_keymap()
  if &buftype != 'help'
    return
  endif

  nnoremap <buffer> <CR> <C-]>
  nnoremap <buffer> <BS> <C-t>
endfunction

" Open & AutoReload .vimrc {{{
" https://github.com/haya14busa/dotfiles
command! EVimrc e $MYVIMRC
command! ETabVimrc tabnew $MYVIMRC
command! SoVimrc source $MYVIMRC | if has('gui_running') | source $MYGVIMRC | endif
AutoCmd BufWritePost *vimrc nested SoVimrc
"}}}


AutoCmd VimResized * wincmd =




" keybind {{{
nnoremap ; :
vnoremap ; :
" コマンドラインでのC-n|p と Up, Downの入れ替え
cnoremap <C-n>  <Down>
cnoremap <C-p>  <Up>
cnoremap <Down> <C-n>
cnoremap <Up>   <C-p>

cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-f> <Right>
cnoremap <C-b> <Left>

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

" タグジャンプを新しいタブで開く
nnoremap <F3> :<C-u>tab stj <C-R>=expand('<cword>')<CR><CR>
nnoremap <F4> :<C-u>%s/<C-r>//

" TABにて対応ペアにジャンプ
nnoremap <Tab> %

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

nnoremap Q <Nop>
AutoCmd FileType javascript nnoremap <buffer> A: A;

nnoremap Y y$

nnoremap <silent><C-s> :<C-u>set spell!<CR>
nnoremap <silent><Tab> :<C-u>set cursorcolumn!<CR>
" }}}


" http://hail2u.net/blog/software/vim-auto-close-quickfix-window.html
function! s:auto_close_quickfix()
  if winnr('$') == 1 && getbufvar(winbufnr(0), '&buftype') == 'quickfix'
    quit
  endif
endfunction
AutoCmd WinEnter * call s:auto_close_quickfix()
" }}}

function! s:operator_google_filetype(mosion_wize)
  NeoBundleSource open-browser.vim
  if line("'[") != line("']")
    return
  endif
  let start = col("'[") - 1
  let end   = col("']")
  let sel = strpart(getline('.'), start, end - start)
  call openbrowser#search(sel . ' ' . &ft)
endfunction

function! s:operator_google(mosion_wize)
  NeoBundleSource open-browser.vim
  if line("'[") != line("']")
    return
  endif
  let start = col("'[") - 1
  let end   = col("']")
  let sel = strpart(getline('.'), start, end - start)
  call openbrowser#search(sel)
endfunction

NeoBundleSource vim-operator-user
call operator#user#define('google-search', s:SID . 'operator_google')
map go <Plug>(operator-google-search)
call operator#user#define('google-search-filetype', s:SID . 'operator_google_filetype')
map gf <Plug>(operator-google-search-filetype)

" Use vsplit mode
" http://qiita.com/kefir_/items/c725731d33de4d8fb096
if has("vim_starting") && !has('gui_running') && has('vertsplit')
  function! g:EnableVsplitMode()
    " enable origin mode and left/right margins
    let &t_CS = "y"
    let &t_ti = &t_ti . "\e[?6;69h"
    let &t_te = "\e[?6;69l" . &t_te
    let &t_CV = "\e[%i%p1%d;%p2%ds"
    call writefile([ "\e[?6h\e[?69h" ], "/dev/tty", "a")
  endfunction

  " old vim does not ignore CPR
  map <special> <Esc>[3;9R <Nop>

  " new vim can't handle CPR with direct mapping
  " map <expr> ^[[3;3R g:EnableVsplitMode()
  set t_F9=[3;3R
  map <expr> <t_F9> g:EnableVsplitMode()
  let &t_RV .= "\e[?6;69h\e[1;3s\e[3;9H\e[6n\e[0;0s\e[?6;69l"
endif

" commna いれる、comma 入れたら ture 返す
function! GoComma() abort
  let res = 0
  let errors = getqflist()
  for e in errors
    if !e.text == "missing '','' before newline in composite literal"
      continue
    endif

    let res = 1
    let c = e.col
    let l = e.lnum
    let line = getline(l)
    let newLine = line[0 : c-1] . "," . line[c-1 : -1]
    call setline(l, newLine)
  endfor
  return res
endfunction

" vim:set foldmethod=marker:
