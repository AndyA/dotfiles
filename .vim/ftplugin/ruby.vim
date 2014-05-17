" ruby.vim

so $VIMRUNTIME/ftplugin/ruby.vim

setlocal shiftround
setlocal expandtab
setlocal textwidth=72

setlocal cindent
setlocal comments=:#
setlocal cinkeys-=0#
setlocal iskeyword+=:
setlocal makeprg=rake
 
if executable('ack')
  setlocal grepprg=ack\ --type=ruby
endif

function! s:tidy()
  let l:loc = Get_location()
  let l:tidy = ':%!rbeautify -'
  exec l:tidy
  call Set_location(l:loc)
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>

