" perl.vim

setlocal shiftwidth=4
setlocal softtabstop=4
setlocal shiftround
setlocal expandtab

setlocal cindent
setlocal comments=:#
setlocal cinkeys-=0#
setlocal keywordprg=perldoc
setlocal iskeyword+=:
setlocal tags=./tags,tags,~/.vim/perltags

noremap <f2> :%!perltidy<CR>
