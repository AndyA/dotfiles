" Override / augment default filetype detection
if exists("did_load_filetypes")
    finish
endif
augroup filetypedetect
  au! BufRead,BufNewFile *.t      setfiletype perl
  au! BufRead,BufNewFile *.tt     setfiletype tt2html
  au! BufRead,BufNewFile *.tt2    setfiletype tt2html
  au! BufRead,BufNewFile *.wiki   setfiletype Wikipedia
  au! BufRead,BufNewFile *.schema setfiletype sql
augroup END

:let b:tt2_syn_tags = '\[% %] <!-- -->' 

"au BufNewFile,BufRead *.tt2 
"  \ if ( getline(1) . getline(2) . getline(3) =~ '<\chtml' 
"  \           && getline(1) . getline(2) . getline(3) !~ '<[%?]' ) 
"  \   || getline(1) =~ '<!DOCTYPE HTML' | 
"  \   setf tt2html | 
"  \ else | 
"  \   setf tt2 | 
"  \ endif 
