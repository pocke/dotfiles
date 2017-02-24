set ambiwidth=double

set visualbell t_vb=

colorscheme hybrid

set cursorline
set cursorcolumn

set guifontwide=Ricty-Regular\ 13
set guifont=Ricty\ 13

" Hide toolbar and menus.
" Scrollbar is always off.
set guioptions-=T
set guioptions-=m
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L
set guioptions-=t
set guioptions-=b
" Not guitablabel.
set guioptions-=e
" Confirm without window.
set guioptions+=c
set guioptions+=M
set guioptions-=a
set guioptions-=g

AutoCmd WinLeave * setlocal nocursorline | setlocal nocursorcolumn
AutoCmd WinEnter * setlocal cursorline | setlocal cursorcolumn


function! ColorschemeFix()
  if g:colors_name == "hybrid"
    "hybrid orange
    hi Special guifg=#de935f
    hi Error guifg=NONE guibg=NONE gui=undercurl,bold guisp=#ff0000
  endif
endfunction
call ColorschemeFix()

AutoCmd ColorScheme * call ColorschemeFix()

nnoremap <F3> :!sakura -x 'tig blame %'<CR>
