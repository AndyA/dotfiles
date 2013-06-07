" Vim syntax file
" Language:	JSON
" Maintainer:	Eli Parra <eli@elzr.com>
" Last Change:	2013-02-01
" Version:      0.12

if !exists("main_syntax")
  if version < 600
    syntax clear
  elseif exists("b:current_syntax")
    finish
  endif
  let main_syntax = 'json'
endif

" NOTE that for the concealing to work your conceallevel should be set to 2

" Syntax: Strings
if has('conceal')
   syn region  jsonString oneline matchgroup=Quote start=/"/  skip=/\\\\\|\\"/  end=/"/ concealends contains=jsonEscape
else
   syn region  jsonString oneline matchgroup=Quote start=/"/  skip=/\\\\\|\\"/  end=/"/ contains=jsonEscape
endif

" Syntax: JSON does not allow strings with single quotes, unlike JavaScript.
syn region  jsonStringSQ oneline  start=+'+  skip=+\\\\\|\\"+  end=+'+

" Syntax: JSON Keywords
" Separated into a match and region because a region by itself is always greedy
syn match jsonKeywordMatch /"[^\"\:]\+"\:/ contains=jsonKeywordRegion
if has('conceal')
   syn region jsonKeywordRegion matchgroup=Quote start=/"/  end=/"\ze\:/ concealends contained
else
   syn region jsonKeywordRegion matchgroup=Quote start=/"/  end=/"\ze\:/ contained
endif

" Syntax: Escape sequences
syn match   jsonEscape    "\\["\\/bfnrt]" contained
syn match   jsonEscape    "\\u\x\{4}" contained

" Syntax: Strings should always be enclosed with quotes.
syn match   jsonNoQuotes  "\<\w\+\>"

" Syntax: Numbers
syn match   jsonNumber    "-\=\<\%(0\|[1-9]\d*\)\%(\.\d\+\)\=\%([eE][-+]\=\d\+\)\=\>"

" ERROR WARNINGS **********************************************
"
" Syntax: An integer part of 0 followed by other digits is not allowed.
syn match   jsonNumError  "-\=\<0\d\.\d*\>"

" Syntax: Decimals smaller than one should begin with 0 (so .1 should be 0.1).
syn match   jsonNumError  "\:\@<=\s*\zs\.\d\+"

" Syntax: No comments in JSON, see http://stackoverflow.com/questions/244777/can-i-comment-a-json-file 
syn match   jsonCommentError  "//.*"
syn match   jsonCommentError  "\(/\*\)\|\(\*/\)"

" Syntax: No semicolons in JSON
syn match   jsonSemicolonError  ";"

" Syntax: No trailing comma after the last element of arrays or objects
syn match   jsonCommaError  ",\_s*[}\]]"

" ********************************************** END OF ERROR WARNINGS

" Syntax: Boolean
syn keyword jsonBoolean   true false

" Syntax: Null
syn keyword jsonNull      null

" Syntax: Braces
syn region jsonFold matchgroup=jsonBraces start="{" end="}" transparent fold
syn region jsonFold matchgroup=jsonBraces start="\[" end="]" transparent fold

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_json_syn_inits")
  if version < 508
    let did_json_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif
  HiLink jsonString             String
  HiLink jsonEscape             Special
  HiLink jsonNumber		Number
  HiLink jsonBraces		Operator
  HiLink jsonNull		Function
  HiLink jsonBoolean		Boolean
  HiLink jsonKeywordRegion      Label

  HiLink jsonNumError           Error
  HiLink jsonCommentError       Error
  HiLink jsonSemicolonError     Error
  HiLink jsonCommaError     	Error
  HiLink jsonStringSQ           Error
  HiLink jsonNoQuotes           Error
  delcommand HiLink
endif

let b:current_syntax = "json"
if main_syntax == 'json'
  unlet main_syntax
endif

" Vim settings
" vim: ts=8 fdm=marker

" MIT License
" Copyright (c) 2013, Jeroen Ruigrok van der Werven, Eli Parra 
"Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the Software), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
"The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
"THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"See https://twitter.com/elzr/status/294964017926119424
