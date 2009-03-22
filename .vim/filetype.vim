" Override / augment default filetype detection
if exists("did_load_filetypes")
    finish
endif
augroup filetypedetect
  au! BufRead,BufNewFile *.t      setfiletype perl
  au! BufRead,BufNewFile *.wiki   setfiletype Wikipedia
  au! BufRead,BufNewFile *.schema setfiletype sql
augroup END

