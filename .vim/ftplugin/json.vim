" json.vim

"so $VIMRUNTIME/ftplugin/json.vim

setlocal shiftround
setlocal expandtab
setlocal cindent
setlocal formatoptions=croql
setlocal keywordprg=man\ -S\ 3
setlocal comments=sr:/*,mb:*,ex:*/,://
setlocal cinoptions=:0

setlocal foldmethod=syntax
"if has('conceal')
"  setlocal conceallevel=2
"endif

if executable('ack')
  setlocal grepprg=ack\ --type=js
endif

function! s:tidy()
  if executable('jsindent')
    let l:loc = g:get_location()
    exec ':%!jsontidy'
    call g:set_location(l:loc)
  endif
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>

