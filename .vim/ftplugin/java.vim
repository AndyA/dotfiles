" java.vim

so $VIMRUNTIME/ftplugin/java.vim

setlocal shiftround
setlocal shiftwidth=4
setlocal expandtab
setlocal textwidth=72
setlocal tabstop=4

setlocal cindent
 
if executable('ack')
  setlocal grepprg=ack\ --type=java
endif

function! s:look_up(file, depth)
  let l:up = []
  while len(l:up) < a:depth
    let l:name = join(l:up + [a:file], '/')
    if filereadable(l:name)
      return l:name
    endif
    let l:up = l:up + ['..']
  endwhile
  return ''
endfunction

function! s:tidy()
  let l:loc = g:get_location()
  let l:rc  = s:look_up('.settings/org.eclipse.jdt.core.prefs', 5)
  if len(l:rc)
    let l:tidy = ':%!jindent --config=' . l:rc
  else
    let l:tidy = ':%!jindent'
  endif
  exec l:tidy
  call g:set_location(l:loc)
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>

