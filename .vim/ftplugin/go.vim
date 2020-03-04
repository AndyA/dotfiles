" go.vim

so $VIMRUNTIME/ftplugin/go.vim

setlocal noexpandtab
setlocal tabstop=2
setlocal shiftwidth=2
setlocal cindent

if executable('ag')
  setlocal grepprg=ag\ --js
endif

function! s:tidy()
  if executable('gofmt')
    let l:loc = Get_location()
    exec ':%!gofmt ' . expand('%:t')
    call Set_location(l:loc)
  endif
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>

