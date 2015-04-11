function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeget_SID$')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID


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


" http://deris.hatenablog.jp/entry/2013/07/05/023835 {{{
function! s:open_neo_bundle_path(motion_wise)
  NeoBundleSource open-browser.vim
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
