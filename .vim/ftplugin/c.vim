" c.vim

so $VIMRUNTIME/ftplugin/c.vim

setlocal shiftround
setlocal expandtab
setlocal cindent
setlocal formatoptions=croql
setlocal keywordprg=man\ -S\ 3
setlocal comments=sr:/*,mb:*,ex:*/,://
setlocal cinoptions=:0
setlocal tags=./tags,tags,~/.vim/tags

function! s:tidy()
  let l:loc = g:get_location()
  exec ':%!astyle'
  call g:set_location(l:loc)
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>

if executable('ack')
  setlocal grepprg=ack\ --type=cc
endif

nmap ,s :find %:t:r.c<cr> 
nmap ,S :sf %:t:r.c<cr> 
nmap ,h :find %:t:r.h<cr> 
nmap ,H :sf %:t:r.h<cr> 

