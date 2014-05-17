" dosini.vim

function! s:tidy()
  let l:loc = Get_location()
  let l:tidy = ':%!prettyini'
  exec l:tidy
  call Set_location(l:loc)
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>
