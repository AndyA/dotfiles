" ---------------------------------------------------------------------------
" Folding for unified diffs 
" http://pastey.net/1483, mgedmin on #vim

function! DiffFoldLevel(lineno) 
  let line = getline(a:lineno) 
  if line =~ '^Index:' 
    return '>1' 
  elseif line =~ '^===' || line =~ '^RCS file: ' || line =~ '^retrieving revision '
    let lvl = foldlevel(a:lineno - 1) 
    return lvl >= 0 ? lvl : '=' 
  elseif line =~ '^diff' 
    return getline(a:lineno - 1) =~ '^retrieving revision ' ? '=' : '>1' 
  elseif line =~ '^--- ' && getline(a:lineno - 1) !~ '^diff\|^===' 
    return '>1' 
  elseif line =~ '^@' 
    return '>2' 
  elseif line =~ '^[- +\\]' 
    let lvl = foldlevel(a:lineno - 1) 
    return lvl >= 0 ? lvl : '=' 
  else 
    return '0' 
  endif 
endf 

function! FT_Diff() 
  if v:version >= 600 
    setlocal foldmethod=expr 
    setlocal foldexpr=DiffFoldLevel(v:lnum) 
  else 
  endif 
endf 
 
" ---------------------------------------------------------------------------
" no folds in vimdiff

function! NoFoldsInDiffMode()
        if &diff 
                :silent! :%foldopen! 
        endif
endf

augroup Diffs 
  autocmd! 
  autocmd BufRead,BufNewFile *.patch :setf diff 
  autocmd BufEnter           *       :call NoFoldsInDiffMode()
  autocmd FileType           diff    :call FT_Diff() 
augroup END
