" javascript.vim

setlocal shiftround
setlocal expandtab
setlocal textwidth=72

setlocal cindent
"setlocal keywordprg=perldoc
"setlocal iskeyword+=:
"setlocal tags=./tags,./perltags,tags,perltags,~/.vim/perltags
 
if executable('ack')
  setlocal grepprg=ack\ --type=js
endif

function! s:tidy()
  if executable('jsindent')
    let l:line = line('.')
    let l:col  = col('.')
    exec ':%!jsindent'
    exec 'normal ' . l:line . 'G'
    exec 'normal ' . l:col . '|'
    exec 'normal zz'
  endif
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>
