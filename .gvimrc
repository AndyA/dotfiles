" Font setting appears to work differently on Mac OS. Probably need
" a case for Windows too.

let s:guifont = 'Bitstream Vera Sans Mono 10'

function! s:remote_uname(addr)
endfunction

function! s:prepare_font(parts)
    if has('mac')
        return join( a:parts[0:-2], '_' ) . printf( ':h%d', a:parts[-1] * 14 / 10 ); 
    else
        return join( a:parts, ' ' )
    endif
endfunction

let s:fontparts = split( s:guifont )
call append(0, s:prepare_font( s:fontparts ))

let s:remote  = split( $SSH_CONNECTION )
if len( s:remote ) == 4
    " Assume we're running gvim on a remote host
    call append(0, s:remote[2])
endif

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
