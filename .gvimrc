" Font setting appears to work differently on Mac OS. Probably need
" a case for Windows too.

let s:guifont = 'Bitstream Vera Sans Mono 10'

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
        let l:size = printf( ':h%d', a:parts[-1] * 14 / 10 )
        return l:name . l:size
    else
        return join( a:parts, ' ' )
    endif
endfunction

let s:fontparts = split( s:guifont )

let s:connection  = split( $SSH_CONNECTION )
if len( s:connection ) == 4
    let s:remsys = s:remote_uname( s:connection[0] )
    "call append(0, s:remsys)
    if s:remsys =~ '^Darwin'
        "call append(0, 'Remote is Mac')
        let s:fontparts[-1] = s:fontparts[-1] * 14 / 10
        " Scale window down
        let &lines = &lines * 10 / 14
        let &columns = &columns * 10 / 14
    endif
endif

let s:fontname  = s:prepare_font( s:fontparts )
let &guifont = s:fontname
"call append(0, s:prepare_font( s:fontparts ))

colorscheme fnaqevan 
"colorscheme candycode
"colorscheme darkocean
"colorscheme golden
set guioptions=aegimrLt
set guitablabel=%t\ %m
set antialias
set vb
set t_vb=
