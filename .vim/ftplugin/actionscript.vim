" javascript.vim

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo-=C

" Set 'formatoptions' to break comment lines but not other lines,
" " and insert the comment leader when hitting <CR> or using "o".
setlocal formatoptions-=t formatoptions+=croql

" Set completion with CTRL-X CTRL-O to autoloaded function.
if exists('&ofu')
    setlocal omnifunc=javascriptcomplete#CompleteJS
endif

" Set 'comments' to format dashed lists in comments.
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://

setlocal commentstring=//%s

" Change the :browse e filter to primarily show Java-related files.
if has("gui_win32")
    let  b:browsefilter="Actionscript Files (*.as)\t*.as\n" .
		\	"All Files (*.*)\t*.*\n"
endif
       
let b:undo_ftplugin = "setl fo< ofu< com< cms<" 

setlocal shiftround
setlocal expandtab
setlocal cindent
setlocal formatoptions=croql
setlocal keywordprg=man\ -S\ 3
setlocal comments=sr:/*,mb:*,ex:*/,://
setlocal cinoptions=:0
setlocal makeprg=rake

if executable('ack')
  setlocal grepprg=ack\ --type=actionscript
endif

function! s:tidy()
  if executable('jsindent')
    let l:loc = g:get_location()
    exec ':%!jsindent'
    call g:set_location(l:loc)
  endif
endfunction

noremap <buffer> <f2> :call <SID>tidy()<CR>

let &cpo = s:cpo_save
unlet s:cpo_save
