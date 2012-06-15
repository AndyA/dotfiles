" cpp.vim
 
so $VIMRUNTIME/ftplugin/cpp.vim

function! s:tidy()
  let l:loc = g:get_location()
  exec ':%!astyle'
  call g:set_location(l:loc)
endfunction

if executable('ack')
  setlocal grepprg=ack\ --type=cpp
endif
