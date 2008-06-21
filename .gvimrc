" Font setting appears to work differently on Mac OS. Probably need
" a case for Windows too.
let s:guifont = 'Bitstream Vera Sans Mono 10'
let s:remote  = split( $SSH_CONNECTION )

"call append(0, s:remote[2])

function! s:remote_uname(addr)
endfunction

if has('mac') 
    set guifont=Bitstream_Vera_Sans_Mono:h14
else
    set guifont=Bitstream\ Vera\ Sans\ Mono\ 10
endif
colorscheme fnaqevan 
"colorscheme candycode
"colorscheme darkocean
"colorscheme golden
set guioptions=aegimrLt
set guitablabel=%t\ %m
set antialias
set vb
set t_vb=
