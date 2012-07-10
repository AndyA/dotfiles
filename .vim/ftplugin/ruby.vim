" ruby.vim

so $VIMRUNTIME/ftplugin/ruby.vim

setlocal shiftround
setlocal expandtab
setlocal textwidth=72

setlocal cindent
setlocal comments=:#
setlocal cinkeys-=0#
setlocal iskeyword+=:
 
if executable('ack')
  setlocal grepprg=ack\ --type=ruby
endif

function! s:tidy()
  let l:loc = g:get_location()
  let l:tidy = ':%!rbeautify -'
  exec l:tidy
  call g:set_location(l:loc)
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>

