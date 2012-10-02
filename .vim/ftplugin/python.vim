" python.vim

so $VIMRUNTIME/ftplugin/python.vim

setlocal shiftround
setlocal expandtab
setlocal textwidth=72

if executable('ack')
  setlocal grepprg=ack\ --type=python
endif

function! s:tidy()
  let l:loc = g:get_location()
  exec ':%!pydent'
  call g:set_location(l:loc)
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>

