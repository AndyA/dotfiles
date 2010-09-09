" ~/.vimrc

" Abbreviations
ia #e andy@hexten.net
ia Therese Thérèse

set background=dark
if $COLORTERM == 'gnome-terminal' || $TERM == 'xterm-256color'
  set t_Co=256
  colorscheme zenburn
else
  colorscheme fnaqevan 
endif

set tabstop=8
set shiftwidth=2
set softtabstop=2
set expandtab

set autowrite       
set hlsearch
set incsearch     
set modeline
set scrolloff=5
set shiftround
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

noremap <silent> <f3> <esc>:previous<cr>
noremap <silent> <f4> <esc>:next<cr>

noremap <silent> <f7> <esc>:cprevious<cr>
noremap <silent> <f8> <esc>:cnext<cr>

" On MacOS we have terminal keybindings for these too.
noremap <silent> <C-Up>    <esc><C-w>k<C-w>_
noremap <silent> <C-Down>  <esc><C-w>j<C-w>_
noremap <silent> <C-Left>  <esc><C-w>h<C-w>_
noremap <silent> <C-Right> <esc><C-w>l<C-w>_

" Bindings above seem to upset screen so define these alternatives
noremap <silent> <leader>k <esc><C-w>k<C-w>_
noremap <silent> <leader>j <esc><C-w>j<C-w>_
noremap <silent> <leader>h <esc><C-w>h<C-w>_
noremap <silent> <leader>l <esc><C-w>l<C-w>_

" Edit, load ~/.vimrc
map <leader>V :spl ~/.vimrc<CR><C-W>_
map <silent> <leader>W :source ~/.vimrc<CR>:filetype detect<CR>
      \ :exe ":echo 'vimrc reloaded'"<CR>

imap <silent> <C-D><C-D> <C-R>=strftime("%Y/%m/%d")<CR>
imap <silent> <C-T><C-T> <C-R>=strftime("%H:%M:%S")<CR>

noremap <silent> <f6> :call g:align_assignments()<CR>
set listchars=tab:▸\ ,eol:¬

map <leader>l :set list!<CR>

