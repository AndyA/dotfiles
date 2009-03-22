" cpp.vim
 
so $VIMRUNTIME/ftplugin/cpp.vim

if executable('ack')
  setlocal grepprg=ack\ --type=cpp
endif
