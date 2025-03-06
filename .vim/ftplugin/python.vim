" python.vim

so $VIMRUNTIME/ftplugin/python.vim

setlocal shiftround
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal expandtab
setlocal textwidth=72

if executable('ack')
  setlocal grepprg=ack\ --type=python
endif

function! s:tidy()
  let l:loc = Get_location()
  exec ':%!uvx black -q -'
  call Set_location(l:loc)
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>

