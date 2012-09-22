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

if executable('astyle')
  function! s:tidy()
    let l:loc = g:get_location()
    exec ':%!astyle'
    call g:set_location(l:loc)
  endfunction
endif

noremap <buffer> <f2> :call <SID>tidy()<CR>

if executable('ack')
  setlocal grepprg=ack\ --type=cpp
endif

let b:did_ftplugin = 1
