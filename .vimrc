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
  NeoBundle     'Shougo/neocomplete', {
  \   'depends': ['Shougo/context_filetype.vim', 'ujihisa/neco-look', 'pocke/neco-gh-issues', 'Shougo/neco-syntax'],
  \ }

  NeoBundleLazy 'osyo-manga/vim-marching', {
  \   'on_ft': ['c', 'cpp'],
  \   'depends': ['Shougo/vimproc.vim', 'osyo-manga/vim-reunions'],
  \ }

  NeoBundle     'Shougo/neosnippet'
  NeoBundle     'Shougo/neosnippet-snippets'
  NeoBundleFetch 'tekkoc/PHPSnippetsCreator'
  NeoBundle     'pocke/neosnippet-incomment'
  NeoBundle     'pocke/serverspec.vim'


  NeoBundleLazy 'kana/vim-smartinput', {
  \   'on_i': 1,
  \ }
  NeoBundleLazy 'mattn/emmet-vim', {
  \   'on_ft': [
  \     'html',
  \     'xhtml',
  \     'css',
  \     'sass',
  \     'styl',
  \     'xml',
  \     'xls',
  \     'markdown',
  \   ]
  \ }
  NeoBundle 'LeafCage/yankround.vim'
  NeoBundleLazy 'osyo-manga/vim-trip', {
  \   'on_map': ['<Plug>(trip-'],
  \ }

  " text object {{{
  function! TextobjConfig(mappings) abort
    return {
    \   'depends': 'kana/vim-textobj-user',
    \   'on_map': map(a:mappings, '["xo", v:val]'),
    \ }
  endfunction

  NeoBundleLazy 'terryma/vim-expand-region', {
  \   'on_map': ['<Plug>(expand_region_'],
  \ }
  NeoBundleLazy 'kana/vim-textobj-user'
  NeoBundleLazy 'rhysd/vim-textobj-ruby',
  \   TextobjConfig(['ar', 'ir'])
  NeoBundleLazy 'sgur/vim-textobj-parameter',
  \   TextobjConfig(['a,', 'i,'])
  NeoBundleLazy 'kana/vim-textobj-entire',
  \   TextobjConfig(['ae', 'ie'])
  NeoBundleLazy 'whatyouhide/vim-textobj-xmlattr',
  \   TextobjConfig(['ax', 'ix'])

  delfunction TextobjConfig
  " }}}

  " operator {{{
  function! OperatorConfig(mappings)
    return {
    \   'depends': 'kana/vim-operator-user',
    \   'on_map': a:mappings,
    \ }
  endfunction

  NeoBundleLazy 'kana/vim-operator-user'
  NeoBundleLazy 'rhysd/vim-operator-surround',
  \   OperatorConfig('<Plug>(operator-surround-')
  NeoBundleLazy 'emonkak/vim-operator-comment',
  \   OperatorConfig(['<Plug>(operator-comment)', '<Plug>(operator-uncomment)', '<Plug>(operator-uncomment)<Plug>(operator-uncomment)', '<Plug>(operator-comment)<Plug>(operator-comment)'])
  NeoBundleLazy 'tyru/operator-camelize.vim',
  \   OperatorConfig('<Plug>(operator-camelize-toggle)')
  NeoBundleLazy 'kana/vim-operator-replace',
  \   OperatorConfig('<Plug>(operator-replace)')

  delfunction OperatorConfig
  " }}}

  " }}}

  " 表示系プラグイン {{{
  NeoBundle     'thinca/vim-splash'
  NeoBundleLazy 'vim-scripts/AnsiEsc.vim', {
  \   'on_cmd': ['AnsiEsc'],
  \ }
  NeoBundle     'itchyny/lightline.vim'
  NeoBundleLazy 'haya14busa/incsearch.vim', {
  \   'on_map': ['<Plug>(incsearch-'],
  \ }

  NeoBundleLazy 'todesking/ruby_hl_lvar.vim', {
  \   'on_ft': ['ruby'],
  \ }

  NeoBundle     'w0ng/vim-hybrid'
  " }}}

  " 移動系プラグイン {{{
  " ぬるぬるスクロール
  NeoBundle     'yonchu/accelerated-smooth-scroll'
  NeoBundleLazy 'easymotion/vim-easymotion', {
  \   'on_map': ['<Plug>(easymotion-']
  \ }
  NeoBundleLazy 'rhysd/clever-f.vim', {
  \   'on_map': ['f', 'F']
  \ }
  " }}}

  " syntax and filetype plugins {{{
  function! FiletypeConfig(ft)
    return {
    \   'on_ft': a:ft,
    \ }
  endfunction

  " JavaScript {{{
  NeoBundleLazy 'jelera/vim-javascript-syntax',
  \   FiletypeConfig("javascript")
  NeoBundle     'jason0x43/vim-js-indent'
  NeoBundleLazy 'marijnh/tern_for_vim', {
  \   'build': {
  \     'others': 'npm install'
  \   },
  \   'on_func': ['tern#Complete', 'tern#Enable'],
  \   'on_ft': ['javascript'],
  \   'on_cmd': [
  \     'TernDef', 'TernDoc', 'TernType', 'TernRefs', 'TernRename'
  \   ]
  \ }
  " AltJS {{{
  NeoBundleLazy 'kchmck/vim-coffee-script',
  \   FiletypeConfig("coffee")
  NeoBundleLazy 'leafgarland/typescript-vim',
  \   FiletypeConfig("typescript")
  NeoBundleLazy 'Quramy/tsuquyomi',
  \   FiletypeConfig("typescript")
  " }}}
  " }}}

  NeoBundleLazy 'hail2u/vim-css3-syntax',
  \   FiletypeConfig("css")
  NeoBundleLazy 'groenewege/vim-less',
  \   FiletypeConfig("less")
  NeoBundleLazy 'wavded/vim-stylus',
  \   FiletypeConfig("stylus")
  NeoBundleLazy 'slim-template/vim-slim',
  \   FiletypeConfig("slim")

  " scala {{{
  NeoBundleLazy 'derekwyatt/vim-scala',
  \   FiletypeConfig("scala")
  NeoBundleLazy 'derekwyatt/vim-sbt',
  \   FiletypeConfig("sbt")
  " }}}

  NeoBundleLazy 'fatih/vim-go',
  \   FiletypeConfig("go")
  NeoBundleLazy 'yosssi/vim-ace',
  \   FiletypeConfig("ace")
  NeoBundleLazy 'cespare/vim-toml',
  \   FiletypeConfig("toml")
  NeoBundleLazy 'stephpy/vim-yaml',
  \   FiletypeConfig("yaml")
  " If lazy, compound filetype is wrong...
  NeoBundle     'vim-ruby/vim-ruby'
  NeoBundle     'gre/play2vim'
  NeoBundleLazy 'PProvost/vim-ps1',
  \   FiletypeConfig("ps1")
  NeoBundleLazy 'keith/tmux.vim',
  \   FiletypeConfig("tmux")

  NeoBundleLazy 'OrangeT/vim-csharp',
  \   FiletypeConfig(['cs', 'csi', 'csx'])

  NeoBundle     'https://vimperator-labs.googlecode.com/hg/', {
  \   'name': 'vimperator-syntax',
  \   'type': 'hg',
  \   'rtp':  'vimperator/contrib/vim/'
  \ }
  " }}}

  " Application Plugins {{{

  " Unite {{{
  NeoBundleLazy 'Shougo/unite.vim', {
  \   'on_cmd': [ "Unite", "UniteWithBufferDir" ],
  \   'depends': ['Shougo/neomru.vim'],
  \ }
  " }}}

  NeoBundleLazy 'sjl/gundo.vim', {
  \   'on_cmd': ['GundoToggle'],
  \ }
  NeoBundleLazy 'thinca/vim-ref', {
  \   'on_cmd': ['Ref'],
  \   'on_map': ['<Plug>(ref-keyword)']
  \ }

  NeoBundleLazy 'thinca/vim-scouter', {
  \   'on_cmd': ['Scouter', 'Scouter!'],
  \ }

  " }}}

  NeoBundle     'sudo.vim'
  NeoBundleLazy 'editorconfig/editorconfig-vim'

  " 非同期処理
  NeoBundle     'Shougo/vimproc.vim', {
  \ 'build' : {
  \     'windows' : 'make -f make_mingw32.mak',
  \     'cygwin' : 'make -f make_cygwin.mak',
  \     'mac' : 'make -f make_mac.mak',
  \     'unix' : 'make -f make_unix.mak'
  \   }
  \ }
  NeoBundleLazy 'tyru/open-browser.vim'

  " コマンド実行
  NeoBundleLazy 'thinca/vim-quickrun', {
  \   'on_map': [['nxo', '<Plug>(quickrun)']],
  \   'on_cmd': 'QuickRun',
  \ }
  " markdown quickrun
  NeoBundleLazy 'superbrothers/vim-quickrun-markdown-gfm', {
  \   'on_ft': 'markdown',
  \   'depends': [
  \     'mattn/webapi-vim',
  \     'thinca/vim-quickrun',
  \     'tyru/open-browser.vim'
  \   ]
  \ }
  " 構文チェック
  NeoBundleLazy 'osyo-manga/vim-watchdogs', {
  \   'on_cmd': ['WatchdogsRun'],
  \   'depends': [
  \     'thinca/vim-quickrun',
  \     'Shougo/vimproc.vim',
  \     'osyo-manga/shabadou.vim',
  \     'pocke/vim-hier',
  \     'dannyob/quickfixstatus'
  \   ]
  \ }


  " Visual Mode でも * で検索
  NeoBundleLazy 'haya14busa/vim-asterisk', {
  \   'on_map': ['<Plug>(incsearch-nohl)<Plug>(asterisk-'],
  \   'depends': ['haya14busa/incsearch.vim']
  \ }

  " git
  NeoBundleLazy 'tpope/vim-fugitive', {
  \   'on_cmd': ['Gblame'],
  \ }
  NeoBundle     'rhysd/committia.vim'

  " window管理
  NeoBundle     'pocke/vim-automatic', {
  \   'depends': ['osyo-manga/vim-gift']
  \ }
  " Buffer移動
  NeoBundleLazy 'kana/vim-altr', {
  \   'on_map': '<Plug>(altr-',
  \ }

  " vim {{{
  NeoBundleLazy 'vim-jp/vimdoc-ja'
  NeoBundleLazy 'thinca/vim-prettyprint', {
  \   'on_cmd': [{'name': 'PP', 'complete': 'expression'}],
  \   'on_func': 'PP',
  \ }
  NeoBundle     'vim-jp/vital.vim'
  NeoBundle     'haya14busa/vital-vimlcompiler'
  NeoBundle     'haya14busa/vital-power-assert'
  NeoBundleLazy 'thinca/vim-themis',
  \   FiletypeConfig('vimspec')
  "}}}


  " keybind {{{
  NeoBundle     'kana/vim-submode'
  NeoBundle     'kana/vim-arpeggio'
  " }}}

  NeoBundle 'pocke/vueim'
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


  if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
  endif

  let g:neocomplete#force_omni_input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'
  let g:neocomplete#force_omni_input_patterns.typescript = '[^. \t]\.\%(\h\w*\)\?' " Same as JavaScript
  let g:neocomplete#force_omni_input_patterns.go = '[^. \t]\.\%(\h\w*\)\?'         " Same as JavaScript

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
  imap <silent><C-k> <Esc>:let g:neosnippet_expanding_or_jumpping = 1<CR>a<Plug>(neosnippet_expand_or_jump)
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
  AutoCmd FileType php NeoSnippetSource ~/.vim/bundle/PHPSnippetsCreator/dist/php_functions.snip
  AutoCmd BufNewFile,BufRead *db/migrate* NeoSnippetSource ~/dotfiles/snippets/rails_migration.snip

  call neobundle#untap()
endif
"}}}

" vim-smartinput {{{
if neobundle#tap('vim-smartinput')

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

" yankround.vim {{{
if neobundle#tap('yankround.vim')
  let g:yankround_dir         = '~/.vim/cache/yankround'
  let g:yankround_max_history = 64

  nmap p <Plug>(yankround-p)
  xmap p <Plug>(yankround-p)
  nmap P <Plug>(yankround-P)

  " 直接nmapするとキーマップが展開されてしまうため、一旦マップを置き換える
  nnoremap <silent> <SID>(bp) :<C-u>bp<CR>
  nnoremap <silent> <SID>(bn) :<C-u>bn<CR>
  nmap <expr><C-p> yankround#is_active() ? "\<Plug>(yankround-prev)" : "\<SID>(bp)"
  nmap <expr><C-n> yankround#is_active() ? "\<Plug>(yankround-next)" : "\<SID>(bn)"

  call neobundle#untap()
endif
" }}}

" vim-trip {{{
if neobundle#tap('vim-trip')
  nmap <C-a> <Plug>(trip-increment)
  nmap <C-x> <Plug>(trip-decrement)

  call neobundle#untap()
endif
" }}}

" text object {{{

" vim-expand-region {{{
if neobundle#tap('vim-expand-region')
  map <CR> <Plug>(expand_region_expand)
  map <BS> <Plug>(expand_region_shrink)

  function! neobundle#tapped.hooks.on_source(bundle)
    let g:expand_region_text_objects = {
    \   "i'": 0,
    \   'i"': 0,
    \   "i`": 0,
    \   'i)': 0,
    \   'i}': 0,
    \   'i]': 0,
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

" }}}

" operator {{{
" vim-operator-surround {{{
if neobundle#tap('vim-operator-surround')
  Arpeggio map <silent>sa <Plug>(operator-surround-append)
  Arpeggio map <silent>sd <Plug>(operator-surround-delete)
  Arpeggio map <silent>sr <Plug>(operator-surround-replace)

  call neobundle#untap()
endif
" }}}

" vim-operator-comment {{{
if neobundle#tap('vim-operator-comment')
  Arpeggio map <silent>co <Plug>(operator-comment)
  Arpeggio map <silent>cu <Plug>(operator-uncomment)
  Arpeggio map <silent>CO <Plug>(operator-comment)<Plug>(operator-comment)
  Arpeggio map <silent>CU <Plug>(operator-uncomment)<Plug>(operator-uncomment)

  call neobundle#untap()
endif
" }}}

" operator-camelize.vim {{{
if neobundle#tap('operator-camelize.vim')
  Arpeggio map <silent>ca <Plug>(operator-camelize-toggle)

  call neobundle#untap()
endif
" }}}

" vim-operator-replace {{{
if neobundle#tap('vim-operator-replace')
  map _ <Plug>(operator-replace)

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

" incsearch.vim {{{
if neobundle#tap('incsearch.vim')
  map / <Plug>(incsearch-forward)
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
  let g:ruby_hl_lvar_show_warnings = 1
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
" }}}

" vim-easymotion {{{
if neobundle#tap('vim-easymotion')
  let g:EasyMotion_smartcase   = 1
  let g:EasyMotion_use_migemo  = 1

  nmap e <Plug>(easymotion-s2)

  call neobundle#untap()
endif
" }}}

" clever-f {{{
if neobundle#tap('clever-f.vim')
  function! neobundle#tapped.hooks.on_source(bundle)
    let g:clever_f_ignore_case           = 1
    let g:clever_f_fix_key_direction     = 1
    let g:clever_f_chars_match_any_signs = "\<C-f>"
  endfunction

  call neobundle#untap()
endif
" }}}

" }}}


" syntax plugins {{{
" tern_for_vim {{{
if neobundle#tap('tern_for_vim')
  let g:tern_map_keys = 0

  call neobundle#untap()
endif
" }}}

let g:tsuquyomi_disable_quickfix = 1

" vim-css3-syntax {{{
if neobundle#tap('vim-css3-syntax')
  AutoCmd FileType css setlocal iskeyword+=-

  call neobundle#untap()
endif
" }}}


" vim-go {{{
if neobundle#tap('vim-go')
  function! neobundle#tapped.hooks.on_source(bundle)
    if executable("goimports")
      let g:go_fmt_command = "goimports"
    endif

    function! s:go_cmd_alias() abort
      command! -nargs=1 -buffer -complete=customlist,go#package#Complete Import GoImport <args>
      command! -nargs=? -buffer                                          Rename GoRename <args>
      nmap <buffer>? <Plug>(go-info)
    endfunction

    AutoCmd FileType go call s:go_cmd_alias()
  endfunction

  call neobundle#untap()
endif
" }}}
" }}}


" Application Plugins {{{

" Unite{{{
" unite.vim {{{
if neobundle#tap('unite.vim')
  function! neobundle#tapped.hooks.on_source(bundle)
    let g:unite_enable_start_insert=1
    let g:unite_source_history_yank_enable=1
    let g:unite_source_file_mru_limit=200
  endfunction

  nnoremap <SID>(unite) <Nop>
  nmap <Space>u <SID>(unite)
  nnoremap <silent> <SID>(unite)t :<C-u>Unite file file_mru buffer -buffer-name='file-buffer' -tab<CR>
  nnoremap <silent> <SID>(unite)u :<C-u>Unite file file_mru buffer -buffer-name='file-buffer'<CR>
  nnoremap <silent> <SID>(unite)v :<C-u>vs<CR>:Unite file file_mru buffer -buffer-name='file-buffer'<CR>
  nnoremap <silent> <SID>(unite)s :<C-u>sp<CR>:Unite file file_mru buffer -buffer-name='file-buffer'<CR>
  nnoremap <silent> <SID>(unite)y :<C-u>Unite yankround<CR>

  AutoCmd FileType unite call s:unite_fix_key()
  function! s:unite_slash() abort
    if getpos('.')[2] == 1
      return '/'
    else
      return '*/'
    endif
  endfunction

  function! s:unite_fix_key() abort
    if bufname('%') =~# "file-buffer"
      inoremap <buffer><expr> / <SID>unite_slash()
      inoremap <buffer> * **/
    endif
  endfunction

  call neobundle#untap()
endif
" }}}
" }}}


" gundo.vim {{{
if neobundle#tap('gundo.vim')
  nnoremap <silent> <F2> :<C-u>GundoToggle<CR>
  call neobundle#untap()
endif
" }}}

" vim-ref {{{
if neobundle#tap('vim-ref')
  silent! nmap <silent> <unique> K <Plug>(ref-keyword)
  silent! vmap <silent> <unique> K <Plug>(ref-keyword)

  let g:ref_cache_dir = $HOME . '/.vim/cache/vim-ref'

  AutoCmd FileType ref nnoremap <buffer> q <C-w>c

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

  nnoremap <silent><Leader>r :QuickRun<CR>

  call neobundle#untap()
endif
" }}}


" vim-watchdogs {{{
if neobundle#tap('vim-watchdogs')
  augroup source-watchdogs
    autocmd!
    autocmd BufWritePre * NeoBundleSource vim-watchdogs
    autocmd BufWritePre * autocmd! source-watchdogs
  augroup END

  AutoCmd FileType go command! -buffer Lint WatchdogsRun watchdogs_checker/golint
  AutoCmd FileType go command! -buffer Build WatchdogsRun watchdogs_checker/go_build
  AutoCmd FileType go command! -buffer Test WatchdogsRun watchdogs_checker/go_test

  AutoCmd FileType ruby command! -buffer Rubocop WatchdogsRun watchdogs_checker/rubocop

  let g:hier_highlight_group_qf = 'Error'

  function! neobundle#tapped.hooks.on_source(bundle)
    try
      let s:quickfix4watchdogs = quickrun#outputter#loclist#new()
    catch /s:save_cpo/
      let s:quickfix4watchdogs = quickrun#outputter#loclist#new()
    endtry
    function! s:quickfix4watchdogs.finish(session)
      call call(quickrun#outputter#quickfix#new().finish, [a:session], self)
      HierUpdate
      QuickfixStatusEnable
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
    \   'exec':        '%c build %o ./%s:.:h',
    \   "errorformat" : '%f:%l: %m,%-G%.%#',
    \ }

    let g:quickrun_config['watchdogs_checker/go_test'] = {
    \   'command':     'go',
    \   'exec':        '%c test %o ./%s:.:h',
    \   "errorformat" : '%f:%l: %m,%-G%.%#',
    \ }

    let g:quickrun_config['watchdogs_checker/go_metalinter'] = {
    \   'command': 'gometalinter',
    \   'exec': '%c --fast --disable=golint %o ./%s:.:h',
    \   'errorformat': '%f:%l:%c:%*[^:]:%m,%f:%l::%*[^:]:%m'
    \ }

    let g:quickrun_config['c/watchdogs_checker'] = {
    \   "type": "watchdogs_checker/gcc",
    \   "cmdopt": '%{PathToGccOpt()}',
    \ }

    let g:quickrun_config['typescript/watchdogs_checker'] = {'type': 'watchdogs_checker/tslint'}
    let g:quickrun_config['ruby.rspec/watchdogs_checker'] = {'type': 'watchdogs_checker/ruby'}
    let g:quickrun_config['go/watchdogs_checker']         = {'type': 'watchdogs_checker/go_metalinter'}

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
  map * <Plug>(incsearch-nohl)<Plug>(asterisk-*)
  map # <Plug>(incsearch-nohl)<Plug>(asterisk-#)
  map z* <Plug>(incsearch-nohl)<Plug>(asterisk-z*)
  map z# <Plug>(incsearch-nohl)<Plug>(asterisk-z#)

  call neobundle#untap()
endif
" }}}



" vim-fugitive {{{
if neobundle#tap('vim-fugitive')
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
  \     'match': { 'bufname': '\V[quickrun output]' },
  \     'set': {
  \       'height': 8,
  \     }
  \   },
  \   {
  \     'match': { 'bufname': '^\[quickrun output rspec\]' },
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
  nmap <PageUp>   <Plug>(altr-forward)
  nmap <PageDown> <Plug>(altr-back)

  function neobundle#tapped.hooks.on_source(bundle)
    " For rails tdd
    call altr#define('app/%/%.rb', 'spec/%/%_spec.rb')

    call altr#define('config/locales/%en.%yml', 'config/locales/%ja.%yml')
    call altr#define('lib/%.rb', 'spec/lib/%_spec.rb')
    call altr#define('lib/%.rb', 'spec/%_spec.rb')
    call altr#define('lib/%.rb', 'test/%_test.rb')

    " For golang test
    call altr#define('%.go', '%_test.go')
  endfunction

  call neobundle#untap()
endif
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
set foldcolumn=1
" 何行目の何列目にカーソルがいるか表示
set ruler
" 新しい行のインデントを現在行と同じに
set autoindent

" K で:help
set keywordprg=""

" 折りたたみ-展開
set foldmethod=manual
set nofoldenable
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
set breakindent

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

let g:java_highlight_all=1
let g:java_highlight_debug=1
let g:java_allow_cpp_keywords=1
let g:java_space_errors=1
let g:java_highlight_functions=1


" 前回終了したカーソル行に移動
AutoCmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

" filetype
AutoCmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
AutoCmd BufNewFile,BufRead ISSUE_EDITMSG              set filetype=markdown
AutoCmd BufNewFile,BufRead *.jbuilder                 set filetype=ruby
AutoCmd BufNewFile,BufRead Guardfile                  set filetype=ruby
AutoCmd BufNewFile,BufRead .pryrc                     set filetype=ruby
AutoCmd BufNewFile,BufRead *_spec.rb                  set filetype=ruby.rspec
AutoCmd BufNewFile,BufRead *.vue                      call s:editing_vue()
function! s:editing_vue() abort
  set ft=html
  nnoremap <SID>(vue) <Nop>
  nmap <Space>v <SID>(vue)
  nnoremap <buffer><SID>(vue)s :<C-u>call vueim#split_all('split')<CR>
  nnoremap <buffer><SID>(vue)v :<C-u>call vueim#split_all('vsplit')<CR>
endfunction


AutoCmd FileType eruby exec 'set filetype=' . 'eruby.' . b:eruby_subtype
AutoCmd FileType qf   nnoremap <buffer> <CR> <CR> | setlocal cursorline
AutoCmd CmdwinEnter * nnoremap <buffer> <CR> <CR> | setlocal cursorline

AutoCmd CmdwinEnter *  nnoremap <buffer><silent> q :q<CR>
AutoCmd FileType godoc nnoremap <buffer><silent> q :q<CR>
AutoCmd FileType qf    nnoremap <buffer><silent> q :q<CR>

AutoCmd FileType gitcommit if getline(1) == '' | startinsert | endif
" TODO: kramdownを書いていると、markdownItalic ではないところで_を使えるが、
"       そのような場合にだけ markdownItalic を無効にしたい。
AutoCmd Syntax markdown syntax clear markdownItalic
AutoCmd Syntax markdown syntax sync fromstart
AutoCmd FileType markdown,text,gitcommit setl spell
AutoCmd BufNewFile,BufRead config/locales/*.yml setl spell
AutoCmd FileType ruby setl tags+=~/.gem/ruby/2.2.0/gems/tags
AutoCmd FileType ruby inoremap <C-b> (&:)<Left>

" 長いFiletypeを省略する
AutoCmd FileType js nested setlocal ft=javascript
AutoCmd FileType md nested setlocal ft=markdown

AutoCmd FileType ruby setl iskeyword+=?

" help key mappings
AutoCmd FileType help call s:set_help_keymap()
function! s:set_help_keymap()
  if &buftype != 'help'
    return
  endif

  nnoremap <buffer> <CR> <C-]>
  nnoremap <buffer> <BS> <C-t>
endfunction

AutoCmd BufNewFile,BufRead * let b:neosnippet_disable_snippet_triggers = ['fname', 'path']
AutoCmd VimResized * wincmd =




" keybind {{{
nnoremap ; :
vnoremap ; :
" コマンドラインでのC-n|p と Up, Downの入れ替え
cnoremap <C-n>  <Down>
cnoremap <C-p>  <Up>
cnoremap <Down> <C-n>
cnoremap <Up>   <C-p>

inoremap <C-a> <Home>
inoremap <C-e> <End>

cnoremap <C-a> <Home>
cnoremap <C-e> <End>

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
nnoremap <F3> :<C-u>tab stj <C-R>=expand('<cword>')<CR><CR>zz
nnoremap <F4> :<C-u>%s/<C-r>//

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

snoremap <C-w> a<C-h>

iabbrev stirng string
iabbrev cosnt const
" }}}


" http://hail2u.net/blog/software/vim-auto-close-quickfix-window.html
function! s:auto_close_quickfix()
  if winnr('$') == 1 && getbufvar(winbufnr(0), '&buftype') == 'quickfix'
    quit
  endif
endfunction
AutoCmd WinEnter * call s:auto_close_quickfix()
" }}}

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

" vim:set foldmethod=marker:
