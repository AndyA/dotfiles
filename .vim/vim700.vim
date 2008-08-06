" ~/.vim/vim700
"
" Stuff that only works with Vim 7
 
" Attempt to locate and expand a template for a new file.
function! ExpandTemplate(name, ext, type)
    let l:try = [ a:ext, a:type ]

    for l:hint in l:try
        let l:helper = expand('~/.vim/templates/helpers/' . l:hint)
        if filereadable(l:helper)
            exe '%!' . join( [ l:helper, a:name, a:ext ], ' ')
            return
        endif
    endfor

    for l:hint in l:try
        let l:template = expand('~/.vim/templates/' . l:hint . '.tpl')
        if filereadable(l:template)
            exe '0r ' . l:template
            return
        endif
    endfor

endfunction

" Read template named after extension (not filetype)
autocmd BufNewFile * call ExpandTemplate(expand('%'), expand('%:e'), &filetype)
