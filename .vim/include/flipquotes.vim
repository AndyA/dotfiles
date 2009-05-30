" Flip the quote type of a string

function! FindStrings(str)
  let l:pos = 0
  let l:map = []
  while 1
    let l:strs = match(a:str, "\\m['\"]", l:pos)
    if l:strs < 0
      break
    endif
    let l:strq = strpart(a:str, l:strs, 1)
    if strpart(a:str, l:strs, 1) == '"'
      let l:strq = "\\m[\"\\\\]"
    else
      let l:strq = "\\m['\\\\]"
    endif
    let l:strp = l:strs + 1
    let l:stre = -1
    while 1
      let l:strp = match(a:str, l:strq, l:strp)
      if l:strp < 0
        break
      elseif strpart(a:str, l:strp, 1 ) == '\'
        let l:strp = l:strp + 2
      else
        let l:stre = l:strp + 1
        break
      endif
    endwhile
    if l:stre < 0
      break
    else
      "echo l:strs l:stre strpart(a:str, l:strs, l:stre - l:strs)
      let l:map = add(l:map, [l:strs, l:stre])
      let l:pos = l:stre + 1
    endif
  endwhile
  return l:map
endfunction

function! FlipEscape(str, qc, cpos)
  let l:pos  = 0
  let l:cpos = a:cpos
  let l:nqc  = tr(a:qc, "'\"", "\"'")
  let l:pat  = "\\m[\\\\" . l:nqc . "]"
  let l:out  = ''
  while 1
    let l:hit = match(a:str, l:pat, l:pos)
    if l:hit < 0
      break
    endif
    let l:out = l:out . strpart(a:str, l:pos, l:hit - l:pos)
    if strpart(a:str, l:hit, 1) == '\'
      if strpart(a:str, l:hit + 1, 1) == a:qc
        let l:out = l:out . a:qc
      else
        let l:out = l:out . strpart(a:str, l:hit, 2)
      endif
      let l:pos = l:hit + 2
    else
      let l:out = l:out . '\' . l:nqc
      let l:pos = l:hit + 1
    endif
    if a:cpos >= l:pos
      let l:cpos = l:cpos + strlen(l:out) - l:pos
    endif
  endwhile
  return [ l:out . strpart(a:str, l:pos), l:cpos ]
endfunction

function! FlipQuote()
  let l:line = getline('.')
  let l:pos  = col('.') - 1
  let l:map  = FindStrings(l:line)
  for l:str in l:map
    if l:pos >= l:str[0] && l:pos < l:str[1]
      let l:qc  = strpart(l:line, l:str[0], 1)
      let l:ncq = tr(l:qc, "'\"", "\"'")
      let l:flp = FlipEscape(
        \     strpart(l:line, l:str[0] + 1, l:str[1] - l:str[0] - 2), 
        \     l:qc, l:pos - l:str[0] - 1)
      call setline('.', strpart(l:line, 0, l:str[0]) 
        \ . l:ncq . l:flp[0] . l:ncq . strpart(l:line, l:str[1]))
      call cursor(0, l:flp[1] + l:str[0] + 2)
      break
    endif
  endfor
endfunction
