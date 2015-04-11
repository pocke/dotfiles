" Copyright 2014, pocket
" Licensed MIT
" http://opensource.org/licenses/mit-license.php

scriptencoding utf-8

set background=dark
hi clear
if exists("g:syntax_on")
  syntax reset
endif
let g:colors_name = expand('<sfile>:t:r')


hi Normal       ctermfg=White         "ctermbg=Black

hi ErrorMsg     ctermfg=White         ctermbg=DarkRed     cterm=bold
hi WarningMsg   ctermfg=232           ctermbg=Yellow      cterm=bold
hi StatusLine                                             cterm=reverse,bold
hi WildMenu     ctermfg=Black         ctermbg=170
hi ModeMsg                                                cterm=bold
hi VertSplit                                              cterm=reverse
hi Visual                             ctermbg=DarkGrey
hi Directory    ctermfg=Blue                              cterm=bold
hi LineNr       ctermfg=LightBlue     ctermbg=235
hi MoreMsg      ctermfg=LightGreen
hi Question     ctermfg=LightGreen                        cterm=bold
hi NonText      ctermfg=LightBlue
hi IncSearch    ctermfg=Black         ctermbg=Green       cterm=NONE
hi Search       ctermfg=Black         ctermbg=LightGreen
hi SpecialKey   ctermfg=DarkGray                          cterm=bold
hi Title        ctermfg=200                               cterm=bold
hi Folded       ctermfg=Blue          ctermbg=238
"hi FoldColumn   ctermfg=LightGrey     ctermbg=DarkBlue

hi CursorLine                         ctermbg=238         cterm=NONE

" 差分モード
hi DiffText                           ctermbg=88          cterm=bold
hi DiffAdd                            ctermbg=22
hi DiffChange                         ctermbg=DarkMagenta
hi DiffDelete                         ctermbg=88

" popup
hi Pmenu        ctermfg=Black         ctermbg=225
hi PmenuSel     ctermfg=Black         ctermbg=205

" TabLine
hi TabLine      ctermfg=Black         ctermbg=225
hi TabLineSel   ctermfg=Black         ctermbg=207
hi TabLineFill                        ctermbg=252         cterm=NONE


" ------------------------------------------------
" syntax

hi Comment      ctermfg=gray
hi Constant     ctermfg=205
hi Identifier   ctermfg=LightBlue
hi Statement    ctermfg=DarkYellow
"hi PreProc
"hi Type
hi Special      ctermfg=165
"hi Underlined
hi Ignore       ctermfg=gray
"hi Error
hi Error        ctermfg=White       ctermbg=DarkRed       cterm=bold
hi Todo         ctermfg=232         ctermbg=Yellow        cterm=bold
hi SpellBad     ctermfg=White       ctermbg=DarkRed       cterm=bold

" ------------------------------------------------
" filetype

" diff
hi diffAdded    ctermfg=DarkGreen
hi diffRemoved  ctermfg=Red

" git
hi link gitcommitSummary Normal

" markdown
hi markdownCode                                           cterm=bold
