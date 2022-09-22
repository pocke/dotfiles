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

" 多分これ壊れてる
command! NXOmap -nargs=+ nmap <args> | xmap <args> | omap <args>


if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

let g:neobundle#install_max_processes = 20

call neobundle#begin(expand('~/.vim/bundle/'))


function! s:load_bundles()
  NeoBundleFetch 'Shougo/neobundle.vim'


  " 補完
  NeoBundle      'Shougo/deoplete.nvim', {
  \   'depends': ['ujihisa/neco-look'],
  \ }
  NeoBundle      'roxma/nvim-yarp'
  NeoBundle      'roxma/vim-hug-neovim-rpc'

  let g:deoplete#enable_at_startup = 1

  NeoBundle     'Shougo/neosnippet'
  NeoBundle     'Shougo/neosnippet-snippets'
  NeoBundleFetch 'tekkoc/PHPSnippetsCreator'
  NeoBundle     'pocke/neosnippet-incomment'
  NeoBundle     'pocke/iro.vim'

  NeoBundleLazy 'kana/vim-smartinput', {
  \   'on_i': 1,
  \ }
  NeoBundle 'mattn/emmet-vim'

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
  NeoBundleLazy 'kana/vim-textobj-entire',
  \   TextobjConfig(['ae', 'ie'])
  NeoBundleLazy 'whatyouhide/vim-textobj-xmlattr',
  \   TextobjConfig(['ax', 'ix'])

  delfunction TextobjConfig

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
  NeoBundleLazy 'pocke/vim-operator-trailing-space',
  \   OperatorConfig('<Plug>(operator-trailing-space')


  delfunction OperatorConfig


  NeoBundle     'pocke/ansi_color.vim'
  NeoBundle     'itchyny/lightline.vim'
  NeoBundleLazy 'haya14busa/incsearch.vim', {
  \   'on_map': ['<Plug>(incsearch-'],
  \ }

  NeoBundle     'w0ng/vim-hybrid'

  " ぬるぬるスクロール
  NeoBundle     'yuttie/comfortable-motion.vim'
  NeoBundleLazy 'easymotion/vim-easymotion', {
  \   'on_map': ['<Plug>(easymotion-']
  \ }
  NeoBundle 'haya14busa/vim-edgemotion'
  NeoBundleLazy 'rhysd/clever-f.vim', {
  \   'on_map': ['f', 'F', 't']
  \ }

  function! FiletypeConfig(ft)
    return {
    \   'on_ft': a:ft,
    \ }
  endfunction

  NeoBundleLazy 'jelera/vim-javascript-syntax',
  \   FiletypeConfig("javascript")
  NeoBundle     'jason0x43/vim-js-indent'
  NeoBundleLazy 'kchmck/vim-coffee-script',
  \   FiletypeConfig("coffee")
  NeoBundleLazy 'AndrewRadev/vim-eco', {
  \   'on_ft': 'eco',
  \   'depends': ['kchmck/vim-coffee-script']
  \ }
  NeoBundleLazy 'pocke/rbs.vim',
  \   FiletypeConfig("rbs")

  NeoBundleLazy 'leafgarland/typescript-vim',
  \   FiletypeConfig("typescript")
  NeoBundleLazy 'Quramy/tsuquyomi',
  \   FiletypeConfig("typescript")

  NeoBundleLazy 'hail2u/vim-css3-syntax',
  \   FiletypeConfig("css")
  NeoBundleLazy 'wavded/vim-stylus',
  \   FiletypeConfig("stylus")
  NeoBundleLazy 'slim-template/vim-slim',
  \   FiletypeConfig("slim")
  NeoBundleLazy 'othree/html5.vim',
  \   FiletypeConfig("html")

  NeoBundleLazy 'fatih/vim-go',
  \   FiletypeConfig("go")
  NeoBundleLazy 'yosssi/vim-ace',
  \   FiletypeConfig("ace")
  NeoBundleLazy 'cespare/vim-toml',
  \   FiletypeConfig("toml")
  NeoBundleLazy 'PProvost/vim-ps1',
  \   FiletypeConfig("ps1")
  NeoBundleLazy 'keith/tmux.vim',
  \   FiletypeConfig("tmux")

  NeoBundleLazy 'keith/swift.vim',
  \   FiletypeConfig('swift')

  NeoBundleLazy 'davidhalter/jedi-vim',
  \   FiletypeConfig('python')

  NeoBundleLazy 'msteinert/vim-ragel',
  \   FiletypeConfig('ragel')
  NeoBundleLazy 'google/vim-jsonnet',
  \   FiletypeConfig('jsonnet')
  NeoBundleLazy 'evanphx/kpeg/', {'on_ft': 'kpeg', 'rtp': 'vim/syntax_kpeg'}


  NeoBundle 'prabirshrestha/async.vim'
  NeoBundle 'prabirshrestha/vim-lsp'
  NeoBundle 'thomasfaingnaert/vim-lsp-snippets'
  NeoBundle 'thomasfaingnaert/vim-lsp-neosnippet'

  NeoBundle     'sudo.vim'
  NeoBundleLazy 'editorconfig/editorconfig-vim'
  NeoBundle 'pocke/ika2.vim'
  NeoBundleLazy 'pocke/cuculus.vim',
  \   FiletypeConfig("ruby")
  AutoCmd FileType ruby nnoremap <silent><buffer> % :<C-u>call cuculus#jump()<CR>
  AutoCmd CursorMoved * call cuculus#display_pair_to_popup()
  NeoBundle 'pocke/rurema.vim'

  NeoBundle 'pocke/tnite.vim'
  NeoBundle 'pocke/hatenikki.vim'
  nnoremap <Space>n :tabe hatenikki://today<CR>

  " 非同期処理
  " It is necessary for NeoBundle
  NeoBundle     'Shougo/vimproc.vim', {
  \ 'build' : {
  \     'windows' : 'make -f make_mingw32.mak',
  \     'cygwin' : 'make -f make_cygwin.mak',
  \     'mac' : 'make -f make_mac.mak',
  \     'unix' : 'make -f make_unix.mak'
  \   }
  \ }
  NeoBundleLazy 'tyru/open-browser.vim'
  NeoBundleLazy 'tyru/open-browser-github.vim', {
  \   'on_cmd': ['OpenGithubFile'],
  \   'depends': ['tyru/open-browser.vim'],
  \ }

  " コマンド実行
  NeoBundleLazy 'thinca/vim-quickrun', {
  \   'on_map': [['nxo', '<Plug>(quickrun)']],
  \   'on_cmd': 'QuickRun',
  \ }
  " 構文チェック
  NeoBundleLazy 'osyo-manga/vim-watchdogs', {
  \   'on_cmd': ['WatchdogsRun'],
  \   'depends': [
  \     'thinca/vim-quickrun',
  \     'osyo-manga/shabadou.vim',
  \     'pocke/vim-hier',
  \     'dannyob/quickfixstatus'
  \   ]
  \ }
  NeoBundle 'prettier/vim-prettier', {'build': 'yarn install'}


  " Visual Mode でも * で検索
  NeoBundleLazy 'haya14busa/vim-asterisk', {
  \   'on_map': ['<Plug>(incsearch-nohl)<Plug>(asterisk-'],
  \   'depends': ['haya14busa/incsearch.vim']
  \ }

  " git
  NeoBundle     'rhysd/committia.vim'

  " window管理
  NeoBundle     'pocke/vim-automatic', {
  \   'depends': ['osyo-manga/vim-gift']
  \ }
  " Buffer移動
  NeoBundleLazy 'kana/vim-altr', {
  \   'on_map': '<Plug>(altr-',
  \ }

  NeoBundleLazy 'vim-jp/vimdoc-ja'
  "}}}


  NeoBundle     'mopp/autodirmake.vim'
  NeoBundle     'vim-jp/vital.vim'
endfunction

call s:load_bundles()
call neobundle#end()
filetype plugin indent on     " Required!
"}}}



"}}}

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
  AutoCmd BufNewFile,BufRead Gemfile NeoSnippetSource ~/dotfiles/snippets/Gemfile.snip
  AutoCmd BufNewFile,BufRead *db/migrate* NeoSnippetSource ~/dotfiles/snippets/rails_migration.snip
  AutoCmd BufNewFile,BufRead * let b:neosnippet_disable_snippet_triggers = ['fname', 'path']

  call neobundle#untap()
endif
"}}}

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


    call smartinput#map_to_trigger('i', '<Plug>(smartinput_CR)', '<Enter>', '<Enter>')
  endfunction

  call neobundle#untap()
endif

let g:user_emmet_settings = {
\   'html': {
\     'empty_element_suffix': ' />',
\   },
\   'typescript': {
\     'extends': 'tsx',
\   }
\}

inoremap <silent><C-y>, <C-r>=MyEmmetClosePopup()<CR><C-r>=emmet#expandAbbr(0,"")<CR>

function! MyEmmetClosePopup() abort
  return pumvisible() ? "\<right>\<left>" : ''
endfunction

if neobundle#tap('vim-trip')
  nmap <C-a> <Plug>(trip-increment)
  nmap <C-x> <Plug>(trip-decrement)

  call neobundle#untap()
endif


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
    let g:expand_region_text_objects_html = copy(g:expand_region_text_objects)
    let g:expand_region_text_objects_html.it = 1
    let g:expand_region_text_objects_html.ax = 1
  endfunction

  call neobundle#untap()
endif


if neobundle#tap('vim-operator-surround')
  map <silent><space>sa <Plug>(operator-surround-append)
  map <silent><space>sd <Plug>(operator-surround-delete)
  map <silent><space>sr <Plug>(operator-surround-replace)

  call neobundle#untap()
endif

if neobundle#tap('vim-operator-comment')
  map <silent><space>co <Plug>(operator-comment)
  map <silent><space>cu <Plug>(operator-uncomment)
  map <silent><space>CO <Plug>(operator-comment)<Plug>(operator-comment)
  map <silent><space>CU <Plug>(operator-uncomment)<Plug>(operator-uncomment)

  call neobundle#untap()
endif

if neobundle#tap('operator-camelize.vim')
  map <silent><space>ca <Plug>(operator-camelize-toggle)

  call neobundle#untap()
endif

if neobundle#tap('vim-operator-replace')
  map - <Plug>(operator-replace)

  call neobundle#untap()
endif


if neobundle#tap('vim-operator-trailing-space')
  map <Space><Space> <Plug>(operator-trailing-space)

  call neobundle#untap()
endif



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

if neobundle#tap('incsearch.vim')
  map / <Plug>(incsearch-forward)
  map g/ <Plug>(incsearch-stay)

  function neobundle#tapped.hooks.on_post_source(bundle)
    let g:incsearch#magic = '\v'
    let g:incsearch#auto_nohlsearch = 1

    NXOmap n  <Plug>(incsearch-nohl-n)zz
    NXOmap N  <Plug>(incsearch-nohl-N)zz

    IncSearchNoreMap <CR> <CR>zz
    IncSearchNoreMap <C-h> <BS>
  endfunction

  call neobundle#untap()
endif


if neobundle#tap('comfortable-motion.vim')
  nnoremap <silent> <C-d> :call comfortable_motion#flick(100)<CR>
  nnoremap <silent> <C-u> :call comfortable_motion#flick(-100)<CR>

  nnoremap <silent> <C-f> :call comfortable_motion#flick(400)<CR>
  nnoremap <silent> <C-b> :call comfortable_motion#flick(-400)<CR>
endif


if neobundle#tap('vim-easymotion')
  let g:EasyMotion_smartcase   = 1
  let g:EasyMotion_use_migemo  = 1

  nmap e <Plug>(easymotion-s2)

  call neobundle#untap()
endif

if neobundle#tap('vim-edgemotion')
  map <Space>j <Plug>(edgemotion-j)
  map <Space>k <Plug>(edgemotion-k)

  call neobundle#untap()
endif

if neobundle#tap('clever-f.vim')
  function! neobundle#tapped.hooks.on_source(bundle)
    let g:clever_f_ignore_case           = 1
    let g:clever_f_fix_key_direction     = 1
    let g:clever_f_chars_match_any_signs = "\<C-f>"
  endfunction

  call neobundle#untap()
endif



let g:tsuquyomi_disable_quickfix = 1
let g:tsuquyomi_completion_detail = 1

if neobundle#tap('vim-css3-syntax')
  AutoCmd FileType css setlocal iskeyword+=-

  call neobundle#untap()
endif


if neobundle#tap('vim-go')
  function! neobundle#tapped.hooks.on_source(bundle)
    let g:go_gocode_unimported_packages = 1
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

  let g:go_highlight_array_whitespace_error = 1
  let g:go_highlight_chan_whitespace_error = 1
  let g:go_highlight_extra_types = 1
  let g:go_highlight_space_tab_error = 1
  let g:go_highlight_trailing_whitespace_error = 1
  let g:go_highlight_operators = 1
  let g:go_highlight_functions = 1
  let g:go_highlight_function_arguments = 1
  let g:go_highlight_function_calls = 1
  let g:go_highlight_fields = 1
  let g:go_highlight_types = 1
  let g:go_highlight_build_constraints = 1
  let g:go_highlight_generate_tags = 1
  let g:go_highlight_variable_assignments = 1
  let g:go_highlight_variable_declarations = 1

  call neobundle#untap()
endif

if neobundle#tap('vim-lsp')
  if executable('go-langserver')
      au User lsp_setup call lsp#register_server({
          \ 'name': 'go-langserver',
          \ 'cmd': {server_info->['go-langserver', '-gocodecompletion']},
          \ 'whitelist': ['go'],
          \ })
  endif

  if executable('golsp')
      au User lsp_setup call lsp#register_server({
          \ 'name': 'golsp',
          \ 'cmd': {server_info->['golsp', '-mode', 'stdio']},
          \ 'whitelist': ['go'],
          \ })
  endif

  if executable('bingo')
      au User lsp_setup call lsp#register_server({
          \ 'name': 'bingo',
          \ 'cmd': {server_info->['bingo', '-mode', 'stdio']},
          \ 'whitelist': ['go'],
          \ })
  endif

  if executable('steep')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'steep',
        \ 'cmd': {server_info->['bash', '-c', 'bundle exec steep langserver --log-output=/tmp/steep.log --verbose 2> /tmp/steep.error.log']},
        \ 'whitelist': ['ruby', 'rbs'],
        \ })
  endif
  call neobundle#untap()
endif





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


if neobundle#tap('open-browser.vim')
  let s:cmd = has('mac') ? 'open' : 'xdg-open'
  let g:openbrowser_browser_commands = [{
  \   "name": s:cmd,
  \   "args": ["{browser}", "{uri}"]
  \ }]
  unlet s:cmd

  call neobundle#untap()
endif


if neobundle#tap('vim-quickrun')
  let g:quickrun_config = {
  \   '_': {
  \     'runner': 'job',
  \     'tempfile': '%{expand("%:p:h") . "/" . system("echo -n $(uuidgen)")}',
  \     'outputter/buffer/split': 'belowright',
  \   },
  \   'markdown': {
  \     'type':      'markdown/gfm',
  \     'outputter': 'browser'
  \   },
  \   'rubyvm_ast': {
  \     'type': 'rubyvm_ast',
  \     'command': '~/bin/print-focused-ast.rb',
  \     'exec':  "ruby %C %s --line %{line('.')} --column %{col('.') - 1}",
  \     'hook/shebang/enable': 0,
  \   },
  \   'ruby.rspec': {
  \     'type': 'rspec',
  \     'exec':  "bundle exec rspec %s",
  \     'hook/shebang/enable': 0,
  \   },
  \ }

  function! neobundle#tapped.hooks.on_source(bundle)
    let s:my_quickrun_hook = { 'kind': 'hook', 'name': 'my_hook' }
    function! s:my_quickrun_hook.on_ready(session, context) abort
      if $TMUX != ''
        call system('tmux set status-left-style none')
      endif
    endfunction

    function! s:my_quickrun_hook.on_success(session, context) abort
      if $TMUX != ''
        call system('tmux set status-left-style bg=green')
      endif
    endfunction

    function! s:my_quickrun_hook.on_failure(session, context) abort
      if $TMUX != ''
        call system('tmux set status-left-style bg=red')
      endif
    endfunction

    call quickrun#module#register(s:my_quickrun_hook)
  endfunction

  nnoremap <silent><Leader>r :QuickRun<CR>
  nnoremap <silent><Leader>a :QuickRun rubyvm_ast<CR>

  call neobundle#untap()
endif


if neobundle#tap('vim-watchdogs')
  augroup source-watchdogs
    autocmd!
    autocmd BufWritePre * NeoBundleSource vim-watchdogs
    autocmd BufWritePre * autocmd! source-watchdogs
  augroup END

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
    let s:quickfix4watchdogs.name = 'quickfix4watchdogs'
    let s:quickfix4watchdogs.kind = 'outputter'
    call quickrun#module#register(s:quickfix4watchdogs)

    let g:quickrun_config['watchdogs_checker/_'] = {
    \   'runner': 'job',
    \   "outputter": "quickfix4watchdogs"
    \ }


    let g:quickrun_config['watchdogs_checker/go_build'] = {
    \   'command':     'go',
    \   'exec':        '%c build %o ./%s:.:h',
    \   "errorformat" : '%f:%l: %m,%-G%.%#',
    \ }

    let g:quickrun_config['c/watchdogs_checker'] = {
    \   "type": "watchdogs_checker/gcc",
    \   "cmdopt": '%{PathToGccOpt()}',
    \ }

    let g:quickrun_config['watchdogs_checker/ruby'] = {
    \   "command" : "ruby",
    \   "exec"    : "%c %o -c %s:p > /dev/null",
    \ }

    let g:quickrun_config['watchdogs_checker/rbs'] = {
    \   "command" : "rbs",
    \   "exec"    : "%c parse %o %s:p",
    \ }

    let g:quickrun_config['watchdogs_checker/jsonlint'] = {
    \   "command" : "jsonlint",
    \   "exec"    : "%c %o -c %s:p > /dev/null",
    \   "errorformat" : '%f: line %l\\, col %c\\, %m',
    \ }

    let g:quickrun_config['ruby.rspec/watchdogs_checker'] = {'type': 'watchdogs_checker/ruby'}
    let g:quickrun_config['rbs/watchdogs_checker'] = {'type': 'watchdogs_checker/rbs'}
    let g:quickrun_config['go/watchdogs_checker'] = {'type': 'watchdogs_checker/go_build'}
    let g:quickrun_config['javascript/watchdogs_checker'] = {'type': ''}

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

let g:prettier#autoformat = 0
AutoCmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.vue call s:run_prettier()

function! s:run_prettier() abort
  let package_json = findfile('package.json', expand('%:p:h') . ';')
  if package_json == ''
    return
  endif
  let content = readfile(package_json)
  let enabled = v:false
  for line in content
    if line =~# 'prettier'
      let enabled = v:true
      break
    endif
  endfor

  if enabled
    Prettier
  endif
endfunction

if neobundle#tap('vim-asterisk')
  map * <Plug>(incsearch-nohl)<Plug>(asterisk-*)
  map z* <Plug>(incsearch-nohl)<Plug>(asterisk-z*)

  call neobundle#untap()
endif



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
  \       'move': v:null,
  \     }
  \   },
  \ ]

  call neobundle#untap()
endif

if neobundle#tap('vim-altr')
  nmap <PageUp>   <Plug>(altr-forward)
  nmap <PageDown> <Plug>(altr-back)

  function neobundle#tapped.hooks.on_source(bundle)
    " For rails tdd
    call altr#define('app/%/%.rb', 'spec/%/%_spec.rb')

    call altr#define('config/locales/%en.%yml', 'config/locales/%ja.%yml')
    call altr#define('test/test_%.rb', 'test/%_test.rb', 'lib/%.rb', 'spec/%_spec.rb')

    " For golang test
    call altr#define('%.go', '%_test.go')

    call altr#define('db/migrate/*.rb')
  endfunction

  call neobundle#untap()
endif


let g:netrw_http_xcmd = '-L -o'
let g:openbrowser_github_url_exists_check = 'ignore'


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

set tabpagemax=1000

" h clipboard-excludeを参照。excludeは一番最後じゃないとだめ
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

if has('mac')
  execute 'set rubydll=' . expand('~/.rbenv/versions/trunk/lib/libruby.dylib')
else
  execute 'set rubydll=' . expand('~/.rbenv/versions/trunk/lib/libruby.so')
endif

" Vim script で \ を入力した時にインデントしない
let g:vim_indent_cont = 0


" 前回終了したカーソル行に移動
AutoCmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

" filetype
AutoCmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
AutoCmd BufNewFile,BufRead ISSUE_EDITMSG              set filetype=markdown
AutoCmd BufNewFile,BufRead *.jbuilder                 set filetype=ruby
AutoCmd BufNewFile,BufRead *.jb                       set filetype=ruby
AutoCmd BufNewFile,BufRead *.schema                   set filetype=ruby " For ridgepole
AutoCmd BufNewFile,BufRead Guardfile                  set filetype=ruby
AutoCmd BufNewFile,BufRead .pryrc                     set filetype=ruby
AutoCmd BufNewFile,BufRead Steepfile                  set filetype=ruby
AutoCmd BufNewFile,BufRead *_spec.rb                  set filetype=ruby.rspec


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

" 長いFiletypeを省略する
AutoCmd FileType js ++nested setlocal ft=javascript
AutoCmd FileType ts ++nested setlocal ft=typescript
AutoCmd FileType md ++nested setlocal ft=markdown

AutoCmd FileType typescriptreact ++nested setlocal ft=typescript

AutoCmd FileType ruby setl iskeyword+=?
let g:ruby_path = ""
AutoCmd FileType javascript,typescript setlocal suffixesadd=.js,.jsx,.ts,.tsx
autocmd FileType javascript,typescript syntax sync minlines=1000 maxlines=2000

" help key mappings
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

AutoCmd BufWritePost *.go silent call system('go build &')

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

nnoremap <F4> :<C-u>%s/<C-r>//
vnoremap <F4> :s/<C-r>//
nnoremap <F3> :silent! !tig blame +<C-r>=line('.')<CR> %<CR>:redraw!<CR>
" TODO: filetype
nnoremap <F12> :TsuquyomiImport<CR>

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


" http://hail2u.net/blog/software/vim-auto-close-quickfix-window.html
function! s:auto_close_quickfix()
  if winnr('$') == 1 && getbufvar(winbufnr(0), '&buftype') == 'quickfix'
    quit
  endif
endfunction
AutoCmd WinEnter * call s:auto_close_quickfix()

function! OperatorGoogle(mosion_wize)
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
call operator#user#define('google-search', 'OperatorGoogle')
map go <Plug>(operator-google-search)

set rtp+=~/ghq/github.com/the-lambda-church/merlin/vim/merlin
set rtp+=~/go/src/github.com/pocke/whichpr/

silent mkspell! ~/.vim/spell/en.utf-8.add

let g:iro#enabled_filetypes = {
\   'ruby': 1,
\   'yaml': 1,
\ }



" TOOD:
"   - Improve function names
"   - Use blacklist
"   - Improve performance
"   - Plugin-ize
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

" Hack to suppress warning message of redefined `p` by if_ruby
silent ruby ()

function! TniteStartWithMap(cmds, action, option) abort
  call tnite#start(a:cmds, a:action, a:option)
  tnoremap <buffer><nowait><Esc> <Esc>
endfunction

let TniteTab = { -> TniteStartWithMap(["sh", "-c", "git ls-files | peco --initial-filter Fuzzy"], "tabswitch", {}) }
let TniteBuf = { -> TniteStartWithMap(["sh", "-c", "git ls-files | peco --initial-filter Fuzzy"], "switch", {}) }
let TniteGrepCword = { -> TniteStartWithMap(
\   ["sh", "-c", "git grep --line-number " . shellescape(expand('<cword>')) . " | peco --initial-filter Fuzzy | cut -d : -f 1,2"],
\   "tabswitch",
\   { "jump_to_line": v:true })
\ }
let TniteGrepCwordW = { -> TniteStartWithMap(
\   ["sh", "-c", "git grep -w --line-number " . shellescape(expand('<cword>')) . " | peco --initial-filter Fuzzy | cut -d : -f 1,2"],
\   "tabswitch",
\   { "jump_to_line": v:true })
\ }
let TniteGrepCwordI = { -> TniteStartWithMap(
\   ["sh", "-c", "git grep -i --line-number " . shellescape(expand('<cword>')) . " | peco --initial-filter Fuzzy | cut -d : -f 1,2"],
\   "tabswitch",
\   { "jump_to_line": v:true })
\ }
let TniteGrep = { -> TniteStartWithMap(
\   ["sh", "-c", "git grep --line-number " . shellescape(tnite#read_from_prompt("grep pattern> ")) . " | peco --initial-filter Fuzzy | cut -d : -f 1,2"],
\   "tabswitch",
\   { "jump_to_line": v:true })
\ }
let TniteJump = { -> TniteStartWithMap(
\   ["sh", "-c", "nl -b a -w1 -s ':\t' " . shellescape(expand('%:p')) . "| peco | cut -d : -f 1"],
\   "jump",
\   {}
\ )}

nnoremap <silent><Space>ut :<C-u>call TniteTab()<CR>
nnoremap <silent><Space>uu :<C-u>call TniteBuf()<CR>
nnoremap <silent><Space>ug :<C-u>call TniteGrepCword()<CR>
nnoremap <silent><Space>uw :<C-u>call TniteGrepCwordW()<CR>
nnoremap <silent><Space>ui :<C-u>call TniteGrepCwordI()<CR>
nnoremap <silent><Space>uG :<C-u>call TniteGrep()<CR>
nnoremap <silent><Space>uj :<C-u>call TniteJump()<CR>
nnoremap <silent><Space>/  :<C-u>call TniteJump()<CR>

nnoremap <silent><Space>pp :<C-u>call poppu#clip_here()<CR>
nnoremap <silent><Space>pj :<C-u>call poppu#jump_to()<Left>


" vim:set foldmethod=marker:
