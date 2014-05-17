" abnf.vim

"so $VIMRUNTIME/ftplugin/abnf.vim

setlocal shiftround
setlocal expandtab
setlocal textwidth=72

setlocal cindent
setlocal comments=:;
"setlocal cinkeys-=0#
setlocal iskeyword+=-
"setlocal tags=./tags,./abnftags,tags,abnftags,~/.vim/abnftags
"setlocal keywordprg=magic-abnfdoc
 
if executable('ack')
  setlocal grepprg=ack\ --type=abnf
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
  let l:loc = Get_location()
  let l:rc  = s:look_up('.abnftidyrc', 5)
  if len(l:rc)
    let l:tidy = ':%!abnftidy -pro=' . l:rc
  else
    let l:tidy = ':%!abnftidy'
  endif
  exec l:tidy
  call Set_location(l:loc)
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>


