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
setlocal tags=./tags,tags,~/.vim/perltags

function! s:tidy()
    let l:line = line('.')
    let l:col  = col('.')
    exec ':%!perltidy'
    exec 'normal ' . l:line . 'G'
    exec 'normal ' . l:col . '|'
endfunction

noremap <f2> :call <SID>tidy()<CR>
