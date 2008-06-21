" Font setting appears to work differently on Mac OS. Probably need
" a case for Windows too.

let s:guifont = 'Bitstream Vera Sans Mono 10'

" Convert between different DPI settings.
function! s:scale(n, ptfrom, ptto)
    return (a:n * a:ptfrom + a:ptfrom / 2) / a:ptto
endfunction

function! s:to_mac(n)
    return s:scale(a:n, 96, 72)
endfunction

function! s:from_mac(n)
    return s:scale(a:n, 72, 96)
endfunction

function! s:remote_uname(addr)
    " TODO: Make sure this can't prompt and hang
    let l:uname = system('ssh -o PasswordAuthentication=no ' . a:addr . ' uname')
    if v:shell_error != 0
        return 'not remote'
    endif
    return l:uname
endfunction

function! s:prepare_font(parts)
    if has('mac')
        let l:name = join( a:parts[0:-2], '_' )
        let l:size = printf( ':h%d', s:to_mac(a:parts[-1]) )
        return l:name . l:size
    else
        return join( a:parts, ' ' )
    endif
endfunction

let s:fontparts = split( s:guifont )

" If we're connected to a remote X server and it's a Mac we need to do more
" scaling.
let s:connection  = split( $SSH_CONNECTION )
if len( s:connection ) == 4
    let s:remsys = s:remote_uname( s:connection[0] )
    if s:remsys =~ '^Darwin'
        let s:fontparts[-1] = s:to_mac(s:fontparts[-1])
        " Scale window down
        let &lines = s:from_mac(&lines)
        let &columns = s:from_mac(&columns)
    endif
endif

let s:fontname  = s:prepare_font( s:fontparts )
let &guifont = s:fontname

colorscheme fnaqevan 
"colorscheme candycode
"colorscheme darkocean
"colorscheme golden
set guioptions=aegimrLt
set guitablabel=%t\ %m
set antialias
set vb
set t_vb=
