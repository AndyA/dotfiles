" vim.vim

so $VIMRUNTIME/ftplugin/vim.vim

setlocal shiftround
setlocal expandtab

if executable('ack')
  setlocal grepprg=ack\ --type=vim
endif
