" ~/.vimrc

scriptencoding utf-8
set encoding=utf-8

execute pathogen#infect()

" Abbreviations
"ia #e andy@hexten.net

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
set winminheight=0

set autowrite       
set hlsearch
set incsearch     
set modeline
set scrolloff=5
set shiftround
set showcmd     
set showmatch  
set title
set number
set t_vb=
set vb
set lz
set backspace=indent,eol,start
set nofsync
set swapsync=
set backupskip=/tmp/*,/private/tmp/*" 

set wildmode=longest:full
set wildmenu

set laststatus=2
set statusline=%f%4(%m%)%r%h%w\ format:\ %{&ff}\ type:\ %y\ %4l/%L(%3p%%),\ %3v

set formatprg=perl\ -MText::Autoformat\ -e'autoformat'
set formatoptions=qro

if executable('ag')
  set grepprg=ag
elseif executable('ack')
  set grepprg=ack
endif

syntax on
filetype plugin indent on

source ~/.vim/functions.vim

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
" Jump to line we were on
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
  \| exe "normal g'\"" | endif

let mapleader=','
let perl_sub_signatures = 1

noremap <silent> <f3> <esc>:previous<cr>
noremap <silent> <f4> <esc>:next<cr>

noremap <silent> <f7> <esc>:cprevious<cr>
noremap <silent> <f8> <esc>:cnext<cr>

" On MacOS we have terminal keybindings for these too.
noremap <silent> <C-Up>    <esc><C-w>k<C-w>_
noremap <silent> <C-Down>  <esc><C-w>j<C-w>_
noremap <silent> <C-Left>  <esc><C-w>h<C-w>_
noremap <silent> <C-Right> <esc><C-w>l<C-w>_

map <leader>sp ms(V)k:sort u's
map <leader>sb msvi(:sort u's

imap <silent> <C-D><C-D> <C-R>=strftime("%Y/%m/%d")<CR>
imap <silent> <C-T><C-T> <C-R>=strftime("%H:%M:%S")<CR>
