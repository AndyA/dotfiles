" apache.vim

setlocal shiftround
setlocal expandtab

function! s:tidy()
  let l:loc = Get_location()
  exec ':%!apachetidy'
  call Set_location(l:loc)
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>
