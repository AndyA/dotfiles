" perl.vim

so $VIMRUNTIME/ftplugin/perl.vim

setlocal shiftround
setlocal expandtab
setlocal textwidth=72

setlocal cindent
setlocal comments=:#
setlocal cinkeys-=0#
setlocal iskeyword+=:
setlocal tags=./tags,./perltags,tags,perltags,~/.vim/perltags
setlocal keywordprg=magic-perldoc
 
if executable('ack')
  setlocal grepprg=ack\ --type=perl
endif

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
  let l:loc = g:get_location()
  let l:rc  = s:look_up('.perltidyrc', 5)
  if len(l:rc)
    let l:tidy = ':%!perltidy -pro=' . l:rc
  else
    let l:tidy = ':%!perltidy'
  endif
  exec l:tidy
  call g:set_location(l:loc)
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>

source ~/.vim/include/flipquotes.vim
nmap <leader>fq :call FlipQuote()<cr>
nmap <f5> :call FlipQuote()<cr>

