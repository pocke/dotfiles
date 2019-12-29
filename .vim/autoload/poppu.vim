let g:poppu#range_finder = {
\   'vim': {
\     'start': { content, _indent, _idx -> match(content, '\v^\s*function') != -1 },
\     'end': { content, _indent, _idx -> match(content, '\v^\s*endf') != -1 },
\   }
\ }

let g:poppu#default_finder = {
\   'start': { _content, _indent, idx -> idx > 3 },
\   'end': { _content, _indent, idx -> idx > 3 },
\ }

" FIXME
" FIXME: It looks ignored
let g:poppu#highlight_group = 'PoppuPmenu'

function! poppu#clip(bufnr, start_lnum, end_lnum) abort
  const clip = s:Clip.new(a:bufnr, a:start_lnum, a:end_lnum)

  call clip.render()
endfunction

function! poppu#clip_here() abort
  const bufnr = bufnr('%')
  const finder = get(g:poppu#range_finder, &filetype, g:poppu#default_finder)

  const cur_lnum = getcurpos()[1]
  let start_lnum = cur_lnum
  while v:true
    if start_lnum == 0 | break | endif

    let content = getline(start_lnum)
    " TODO: indentation
    let indent = v:null
    if finder.start(content, indent, cur_lnum - start_lnum)
      break
    endif
    let start_lnum -= 1
  endwhile

  let end_lnum = cur_lnum
  while v:true
    if end_lnum == line('$') | break | endif

    let content = getline(end_lnum)
    " TODO: indentation
    let indent = v:null
    if finder.end(content, indent, end_lnum - cur_lnum)
      break
    endif
    let end_lnum += 1
  endwhile

  call poppu#clip(bufnr, start_lnum, end_lnum)
endfunction

function! poppu#jump_to(n) abort
  call s:clips[a:n].jump()
endfunction

function! poppu#yank(n) abort
  call s:clips[a:n].yank()
endfunction

" content: List of String
function! s:trim_indent(content) abort
  let min_indent = 99999
  for l in a:content
    let idx = match(l, '\v\S')
    if min_indent > idx && idx >= 0
      let min_indent = idx
    endif
  endfor

  if min_indent == 0
    return a:content
  end

  return map(copy(a:content), {_, v -> v[min_indent:]})
endfunction

" --- Clip protptype
let s:Clip = {}

function! s:Clip.new(bufnr, start_lnum, end_lnum) abort
  const this = copy(self)
  const content = s:trim_indent(getbufline(a:bufnr, a:start_lnum, a:end_lnum))
  let this.bufnr = a:bufnr
  let this.content = content
  let this.id = s:next_id()
  let this._start_lnum = a:start_lnum
  let this._end_lnum = a:end_lnum
  let this.winid = v:null
  call add(s:clips, this)

  call prop_add(this._start_lnum, 1, {
  \   'end_lnum': this._end_lnum,
  \   'bufnr': this.bufnr,
  \   'id': this.id,
  \   'type': s:PROP_TYPE,
  \ })

  return this
endfunction

function! s:Clip.render() abort
  let self.winid = popup_create(self.content, {
  \   'line': s:popup_line,
  \   'col': &columns,
  \   'pos': 'topright',
  \   'highlight': g:poppu#highlight_group,
  \   'border': [1,1,1,1],
  \ })
  let ft = getbufvar(self.bufnr, '&filetype')
  call win_execute(self.winid, 'set filetype=' . ft)
  call win_execute(self.winid, 'syntax enable')
  let border_height = 2
  let s:popup_line += len(self.content) + border_height
endfunction

function! s:Clip.start_lnum() abort
  " TODO: resolve textprop
  return self._start_lnum
endfunction

function! s:Clip.jump() abort
  execute self.start_lnum()
endfunction

function! s:Clip.yank() abort
  let @+ = join(self.content, "\n")
endfunction

" --- setup
function! s:setup() abort
  if exists('s:PROP_TYPE')
    return
  endif

  const s:PROP_TYPE = 'poppu'
  call prop_type_add(s:PROP_TYPE, {})

  let s:id = 0
  let s:popup_line = 1
  let s:clips = []

  " FIXME
  hi default link PoppuPmenu Pmenu
  hi PoppuPmenu ctermbg=232
endfunction

function! s:next_id() abort
  let s:id += 1
  return s:id
endfunction

call s:setup()
