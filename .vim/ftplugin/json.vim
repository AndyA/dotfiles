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
  if executable('jsontidy')
    let l:loc = Get_location()
    exec ':%!jsontidy'
    call Set_location(l:loc)
  endif
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>

