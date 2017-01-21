" less.vim

"so $VIMRUNTIME/ftplugin/less.vim

setlocal shiftround
setlocal expandtab
setlocal cindent
setlocal formatoptions=croql
setlocal keywordprg=man\ -S\ 3
setlocal comments=sr:/*,mb:*,ex:*/,://
setlocal cinoptions=:0
setlocal tags=./tags,tags,~/.vim/tags

function! s:look_up(file, depth)
  let l:up = []
  while len(l:up) < a:depth
    let l:name = join(l:up + [a:file], '/')
    if filereadable(l:name)
      return l:name
    endif
    let l:up = l:up + ['..']
  endwhile
  return ''
endfunction

function! s:find_rc(file)
  let l:up = s:look_up(a:file, 10)
  if len(l:up)
    return l:up
  endif
  let l:home = globpath('~', a:file)
  if filereadable(l:home)
    return l:home
  endif
  return ''
endfunction

if executable('csscomb-wrapper')
  function! s:tidy()
    let l:loc = Get_location()
    let l:rc  = s:find_rc('.csscomb.jsobn')
    if len(l:rc)
      let l:tidy = ':%!csscomb-wrapper -c' . l:rc
    else
      let l:tidy = ':%!csscomb-wrapper'
    endif
    exec l:tidy
    call Set_location(l:loc)
  endfunction
  noremap <buffer> <f2> :call <SID>tidy()<CR>
endif
