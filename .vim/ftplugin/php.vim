" php.vim

setlocal shiftround
setlocal expandtab
noremap <f2> :%!tidy<CR>

if executable('ack')
  setlocal grepprg=ack\ --type=php
endif
