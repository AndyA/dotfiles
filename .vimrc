" ~/.vimrc

" Abbreviations
ia #e andy@hexten.net
ia Therese Thérèse

if $COLORTERM == 'gnome-terminal'
    set t_Co=256
    colorscheme zenburn
else
    colorscheme fnaqevan 
endif
set autowrite       
set background=dark
set expandtab
"set hidden        
set hlsearch
"set ignorecase   
set incsearch     
set modeline
"set mouse=a     
set scrolloff=5
set shiftround
set shiftwidth=4
set showcmd     
set showmatch  
"set smartcase  
set softtabstop=4
set title
set t_vb=
set vb
set lz
set backspace=indent,eol,start
set foldenable
set foldmethod=indent
set foldlevel=100

set laststatus=2
set statusline=%-30(%f%m%r%h%w%)\ format:\ [%{&ff}]\ type:\ %y\ loc:\ [%4l,\ %3v,\ %3p%%]\ lines:\ [%L]\ buf:\ [%n]\ %a

set formatprg=perl\ -MText::Autoformat\ -e'autoformat'
set formatoptions=qro

syntax on
filetype plugin indent on

if v:version >= 700
    source ~/.vim/vim700.vim
endif

" Jump to line we were on
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
  \| exe "normal g'\"" | endif

let mapleader=','

nmap <leader>tp :tabp<cr> 
nmap <leader>tn :tabn<cr> 
nmap <leader>tl :TlistToggle<cr>

noremap <f3> <esc>:previous<cr>
noremap <f4> <esc>:next<cr>

noremap <f5> <esc>:bprevious<cr>
noremap <f6> <esc>:bnext<cr>

noremap <f7> <esc>:cprevious<cr>
noremap <f8> <esc>:cnext<cr>

if executable('ack')
    set grepprg=ack\ -a
endif
