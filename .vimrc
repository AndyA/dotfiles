" ~/.vimrc

function ScriptSettings()
    setlocal shiftwidth=4
    setlocal softtabstop=4
    setlocal shiftround
    setlocal expandtab
endfunction

function CLikeSettings()
    call ScriptSettings()
    setlocal cindent
endfunction

function CSettings()
    call CLikeSettings()
    setlocal formatoptions=croql
    setlocal keywordprg=man\ -S\ 3
    setlocal comments=sr:/*,mb:*,ex:*/,://
    setlocal cinoptions=:0
endfunction

" Run the current buffer as a perl script and capture any output
function PerlRun()
    let l:sourcetmp = tempname()
    let l:outputtmp = tempname()

    execute "normal:w!" . l:sourcetmp . "\<CR>"
    execute "normal:! perl ".l:sourcetmp." \> ".l:outputtmp." 2\>\&1 \<CR>"
    execute "normal:new\<CR>"
    execute "normal:edit " . l:outputtmp . "\<CR>"
endfunction

function PerlSettings()
    call CLikeSettings()
    setlocal comments=:#
    setlocal cinkeys-=0#
    setlocal keywordprg=perldoc
    noremap <f2> :%!perltidy<CR>
    noremap <f12> :call PerlRun()<CR>
endfunction

" Insert Perl boilerplate
function PerlStart()
    call append(0, "#!/usr/bin/env perl")
    call append(1, "")
    call append(2, "use strict;")
    call append(3, "use warnings;")
    call append(4, "")
    call append(5, "$| = 1;")
    call append(6, "")
endfunction

" Insert HTML boilerplate
function HTMLStart()
    call append(0, "<html>")
    call append(1, "    <head>")
    call append(2, "         <title></title>")
    call append(3, "    </head>")
    call append(4, "    <body>")
    call append(5, "    </body>")
    call append(6, "</html>")
endfunction

function TextSettings()
    setlocal textwidth=78
    setlocal formatoptions=tcql
endfunction

function HTMLSettings()
    call ScriptSettings()
    noremap <f2> :%!tidy<CR>
endfunction

function PHPSettings()
    call HTMLSettings()
endfunction

function VimSettings()
    call ScriptSettings()
endfunction

function ApacheSettings()
    call ScriptSettings()
endfunction

function ShSettings()
    call ScriptSettings()
    setlocal smartindent
    setlocal comments=:#
endfunction

function WikipediaSettings()
    set textwidth=78
endfunction

let os_type=system('uname -s')

" Filetype handling
autocmd FileType apache     :call ApacheSettings()
autocmd FileType c          :call CSettings()
autocmd FileType cpp        :call CSettings()
autocmd FileType html       :call HTMLSettings()
autocmd FileType perl       :call PerlSettings()
autocmd FileType php        :call PHPSettings()
autocmd FileType sh         :call ShSettings()
autocmd FileType text       :call TextSettings()
autocmd FileType vim        :call VimSettings()
autocmd FileType Wikipedia  :call WikipediaSettings()

" Handlers for new files
autocmd BufNewFile *.pl :call PerlStart()
autocmd BufNewFile *.{php,html,jsp} :call HTMLStart()

" Abbreviations
ia #e andy@hexten.net
ia Therese Thérèse

" Other global options
"colorscheme kib_darktango
colorscheme golden
set incsearch
set hlsearch
set background=dark
set title
set shiftwidth=4
set softtabstop=4
set shiftround
set expandtab
set vb
set t_vb=
syntax on

au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
  \| exe "normal g'\"" | endif

filetype indent on

set showcmd            " Show (partial) command in status line.
set showmatch           " Show matching brackets.
"set ignorecase         " Do case insensitive matching
"set smartcase          " Do smart case matching
set incsearch           " Incremental search
set autowrite           " Automatically save before commands like :next and :make
"set hidden             " Hide buffers when they are abandoned
"set mouse=a            " Enable mouse usage (all modes) in terminals
set hlsearch

" Extensions
"execute "source ~/.vim/FeralToggleCommentify.vim"

"map <M-c> :call ToggleCommentify()<CR>j
"imap <M-c> <ESC>:call ToggleCommentify()<CR>j 
"let g:showfuncctagsbin = $CTAGSPROG
"map <F3> <PLUG>ShowFunc

