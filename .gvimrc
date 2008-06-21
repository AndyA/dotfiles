" Font setting appears to work differently on Mac OS. Probably need
" a case for Windows too.
if has('mac') 
    set guifont=Bitstream_Vera_Sans_Mono:h14
else
    set guifont=Bitstream\ Vera\ Sans\ Mono\ 11
endif
set guioptions=aegimrLt
set vb
set t_vb=
