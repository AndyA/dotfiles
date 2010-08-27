" dosini.vim

function! s:tidy()
  let l:loc = g:get_location()
  let l:tidy = ':%!prettyini'
  exec l:tidy
  call g:set_location(l:loc)
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>
