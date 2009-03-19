" c.vim

setlocal shiftround
setlocal expandtab
setlocal cindent
setlocal formatoptions=croql
setlocal keywordprg=man\ -S\ 3
setlocal comments=sr:/*,mb:*,ex:*/,://
setlocal cinoptions=:0

function! s:tidy()
  let l:window = ( line('w0') + line('w$') ) / 2
  let l:line = line('.')
  let l:col  = col('.')
  let l:rc   = s:look_up('.perltidyrc', 5)
  exec ':%!indent'
  exec 'normal ' . l:window . 'zz'
  exec 'normal ' . l:line   . 'G'
  exec 'normal ' . l:col    . '|'
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>

if executable('ack')
  setlocal grepprg=ack\ --type=cc
endif

nmap ,s :find %:t:r.c<cr> 
nmap ,S :sf %:t:r.c<cr> 
nmap ,h :find %:t:r.h<cr> 
nmap ,H :sf %:t:r.h<cr> 

