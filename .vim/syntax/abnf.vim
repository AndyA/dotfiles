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
hi link abnfIdentifier        Identifier

"hi link podmanSubSectTitle String
"hi link podmanSectTitle	Statement
"hi link podmanText      Normal
"hi link podmanExample   Comment

" POD commands
"syn match podmanSectTitle    "^[A-Z][A-Z -]\+"
"syn match podmanSubSectTitle "^  [^ ].*$"
"syn match podmanText         "^    [^ ].\+$"
"syn match podmanExample      "^      .\+"

syn match abnfComment         ";.*"
syn match abnfLiteral         "'[^']*'"
syn match abnfCaseLiteral     @"[^"]*"@
"syn match abnfIdentifier      "[a-zA-Z]\+(-[a-zA-Z])*"
syn match abnfIdentifier      "[a-zA-Z]\+\(-[a-zA-Z]\+\)*"

let b:current_syntax = "mxml"
if main_syntax == 'mxml'
  unlet main_syntax
endif

let &cpo = s:mxml_cpo_save
unlet s:mxml_cpo_save
