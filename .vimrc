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
set hlsearch
set incsearch     
set modeline
set scrolloff=5
set shiftround
set shiftwidth=2
set tabstop=2
set showcmd     
set showmatch  
set title
set t_vb=
set vb
set lz
set backspace=indent,eol,start
set nofsync
set swapsync=

set laststatus=2
set statusline=%f%4(%m%)%r%h%w\ format:\ %{&ff}\ type:\ %y\ %4l/%L(%3p%%),\ %3v

set formatprg=perl\ -MText::Autoformat\ -e'autoformat'
set formatoptions=qro

if executable('ack')
  set grepprg=ack\ -a
endif

syntax on
filetype plugin indent on

source ~/.vim/functions.vim

if v:version >= 700
  source ~/.vim/vim700.vim
endif

" Jump to line we were on
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
  \| exe "normal g'\"" | endif

let mapleader=','

vmap bl :<C-U>!svn blame <C-R>=expand("%:p") <CR> \| 
  \sed -n <C-R>=line("'<") <CR>,<C-R>=line("'>") <CR>p <CR>

nmap <leader>tl :TlistToggle<cr>

if has('mac')
  vmap c y:call system("pbcopy", getreg("\""))<CR>
  nmap <leader>v :call setreg("\"",system("pbpaste"))<CR>p
endif

noremap <f3> <esc>:previous<cr>
noremap <f4> <esc>:next<cr>

"noremap <f5> <esc>:bprevious<cr>
"noremap <f6> <esc>:bnext<cr>

noremap <f7> <esc>:cprevious<cr>
noremap <f8> <esc>:cnext<cr>

" On MacOS we have terminal keybindings for these too.
noremap <C-Up>    <esc><C-w>k<C-w>_
noremap <C-Down>  <esc><C-w>j<C-w>_
noremap <C-Left>  <esc><C-w>h<C-w>_
noremap <C-Right> <esc><C-w>l<C-w>_

" Edit, load ~/.vimrc
map <leader>V :spl ~/.vimrc<CR><C-W>_
map <silent> <leader>W :source ~/.vimrc<CR>:filetype detect<CR>
      \ :exe ":echo 'vimrc reloaded'"<CR>

