" Vim syntax file

" Maintainer:	Andy Armstrong <andy@hexten.net>

if !exists("main_syntax")
  if version < 600
    syntax clear
  elseif exists("b:current_syntax")
    finish
  endif
  let main_syntax = 'abnf'
endif

let s:mxml_cpo_save = &cpo
set cpo&vim

hi link abnfComment           Comment
hi link abnfLiteral           String
hi link abnfCaseLiteral       String
hi link abnfHexLiteral        Number
hi link abnfDecLiteral        Number
hi link abnfBinLiteral        Number
hi link abnfIdentifier        Identifier
hi link abnfOperator          Operator

syn match abnfComment         ";.*"
syn match abnfLiteral         "'[^']*'"
syn match abnfCaseLiteral     @"[^"]*"@
syn match abnfIdentifier      "[a-zA-Z]\+\(-[a-zA-Z]\+\)*"

syn match abnfHexLiteral      "%x[0-9A-Fa-f]\+"
syn match abnfHexLiteral      "%x[0-9A-Fa-f]\+-[0-9A-Fa-f]\+"
syn match abnfDecLiteral      "%d[0-9]\+"
syn match abnfDecLiteral      "%d[0-9]\+-[0-9]\+"
syn match abnfBinLiteral      "%d[0-1]\+"
syn match abnfBinLiteral      "%d[0-1]\+-[0-1]\+"

syn match abnfOperator        "/"

let b:current_syntax = "mxml"
if main_syntax == 'mxml'
  unlet main_syntax
endif

let &cpo = s:mxml_cpo_save
unlet s:mxml_cpo_save
