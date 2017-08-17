" rust.vim

so $VIMRUNTIME/ftplugin/rust.vim

if executable('rustfmt')
  function! s:tidy()
    let l:loc = Get_location()
    exec '%!rustfmt'
    call Set_location(l:loc)
  endfunction
  noremap <buffer> <f2> :call <SID>tidy()<CR>
endif

