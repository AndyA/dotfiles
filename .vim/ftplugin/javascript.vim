" javascript.vim

setlocal shiftround
setlocal expandtab
setlocal cindent
setlocal formatoptions=croql
setlocal keywordprg=man\ -S\ 3
setlocal comments=sr:/*,mb:*,ex:*/,://
setlocal cinoptions=:0

if executable('ack')
  setlocal grepprg=ack\ --type=js
endif

function! s:tidy()
  if executable('jsindent')
    let l:window = ( line('w0') + line('w$') ) / 2
    let l:line = line('.')
    let l:col  = col('.')
    let l:rc   = s:look_up('.perltidyrc', 5)
    exec l:tidy
    exec ':%!jsindent'
    exec 'normal ' . l:window . 'zz'
    exec 'normal ' . l:line   . 'G'
    exec 'normal ' . l:col    . '|'
  endif
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>
