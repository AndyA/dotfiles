" xml.vim

so $VIMRUNTIME/ftplugin/xml.vim

setlocal shiftround
setlocal expandtab
let g:xml_syntax_folding = 1 
setlocal foldmethod=syntax

function! s:tidy()
  let l:loc = g:get_location()
  exec ':%!xml_pp -s indented'
  call g:set_location(l:loc)
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>
