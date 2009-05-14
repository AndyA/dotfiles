" xml.vim

so $VIMRUNTIME/ftplugin/xml.vim

setlocal shiftround
setlocal expandtab

function! s:tidy()
  let l:loc = g:get_location()
  exec ':%!xml_pp'
  call g:set_location(l:loc)
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>
