" cpp.vim
 
if exists("b:did_ftplugin")
  finish
endif

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

if executable('astyle')
  function! s:tidy()
    let l:loc = g:get_location()
    let l:rc  = s:look_up('.astylerc', 5)
    if len(l:rc)
      let l:tidy = ':%!astyle --options=' . l:rc
    else
      let l:tidy = ':%!astyle'
    endif
    exec l:tidy
    call g:set_location(l:loc)
  endfunction
  noremap <buffer> <f2> :call <SID>tidy()<CR>
endif

if executable('ack')
  setlocal grepprg=ack\ --type=cpp
endif

let b:did_ftplugin = 1
