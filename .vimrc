" ~/.vimrc

" Abbreviations
ia #e andy@hexten.net
ia Therese Thérèse

set background=dark
if $COLORTERM == 'gnome-terminal'
    set t_Co=256
    colorscheme zenburn
else
    colorscheme fnaqevan 
endif
set autowrite       
set expandtab
"set hidden        
set hlsearch
"set ignorecase   
set incsearch     
set modeline
"set mouse=a     
set scrolloff=5
set shiftround
set shiftwidth=2
set tabstop=2
set showcmd     
set showmatch  
"set smartcase  
set title
set t_vb=
set vb
set lz
set backspace=indent,eol,start
"set foldenable
"set foldmethod=indent
"set foldlevel=100

set laststatus=2
set statusline=%f%4(%m%)%r%h%w\ format:\ %{&ff}\ type:\ %y\ %4l/%L(%3p%%),\ %3v

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

vmap bl :<C-U>!svn blame <C-R>=expand("%:p") <CR> \| sed -n <C-R>=line("'<") <CR>,<C-R>=line("'>") <CR>p <CR>

noremap <f3> <esc>:previous<cr>
noremap <f4> <esc>:next<cr>

noremap <f5> <esc>:bprevious<cr>
noremap <f6> <esc>:bnext<cr>

noremap <f7> <esc>:cprevious<cr>
noremap <f8> <esc>:cnext<cr>

if executable('ack')
    set grepprg=ack\ -a
endif
