" perl.vim

setlocal shiftwidth=4
setlocal softtabstop=4
setlocal shiftround
setlocal expandtab

setlocal cindent
setlocal comments=:#
setlocal cinkeys-=0#
setlocal keywordprg=perldoc
setlocal iskeyword+=:
setlocal tags=./tags,./perltags,tags,perltags,~/.vim/perltags

function! s:look_up(file, depth)
    let l:up = []
    while len(l:up) < a:depth
        let l:name = join(l:up + [a:file], '/')
        if filereadable(l:name)
            return l:name
        endif
        let l:up = l:up + ['..']
    endwhile
    return ''
endfunction

function! s:tidy()
    let l:line = line('.')
    let l:col  = col('.')
    let l:rc   = s:look_up('.perltidyrc', 5)
    if len(l:rc)
        let l:tidy = ':%!perltidy -pro=' . l:rc
    else
        let l:tidy = ':%!perltidy'
    endif
    exec l:tidy
    exec 'normal ' . l:line . 'G'
    exec 'normal ' . l:col . '|'
endfunction

noremap <f2> :call <SID>tidy()<CR>
