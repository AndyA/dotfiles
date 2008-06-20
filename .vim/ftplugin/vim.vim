" vim.vim

setlocal shiftwidth=4
setlocal softtabstop=4
setlocal shiftround
setlocal expandtab

if executable('ack')
    setlocal grepprg=ack\ --type=vim
endif
