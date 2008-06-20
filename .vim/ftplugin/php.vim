" php.vim

setlocal shiftwidth=4
setlocal softtabstop=4
setlocal shiftround
setlocal expandtab
noremap <f2> :%!tidy<CR>

if executable('ack')
    setlocal grepprg=ack\ --type=php
endif
