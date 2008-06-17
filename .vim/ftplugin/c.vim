" c.vim

setlocal shiftwidth=4
setlocal softtabstop=4
setlocal shiftround
setlocal expandtab
setlocal cindent
setlocal formatoptions=croql
setlocal keywordprg=man\ -S\ 3
setlocal comments=sr:/*,mb:*,ex:*/,://
setlocal cinoptions=:0

nmap ,s :find %:t:r.c<cr> 
nmap ,S :sf %:t:r.c<cr> 
nmap ,h :find %:t:r.h<cr> 
nmap ,H :sf %:t:r.h<cr> 

