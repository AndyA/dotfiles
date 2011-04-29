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
  au! BufRead,BufNewFile *.as     setfiletype actionscript
  au! BufRead,BufNewFile *.mxml   setfiletype mxml
  au! BufRead,BufNewFile *.abnf   setfiletype abnf
  au! BufRead,BufNewFile *.json   setfiletype json
augroup END

:let b:tt2_syn_tags = '\[% %] <!-- -->' 
