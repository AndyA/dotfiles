" Font setting appears to work differently on Mac OS. Probably need
" a case for Windows too.
if match(os_type, 'darwin') >= 0
    set guifont=Bitstream_Vera_Sans_Mono:h13
else
    set guifont=Bitstream\ Vera\ Sans\ Mono\ 10
endif
set guioptions=aegimrLt
set vb
set t_vb=
