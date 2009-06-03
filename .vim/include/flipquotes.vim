" Flip the quote type of a string

function! s:find_strings(str)
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
      let l:map = add(l:map, [l:strs, l:stre])
      let l:pos = l:stre + 1
    endif
  endwhile
  return l:map
endfunction

function! s:flip_escape(str, qc, cpos)
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

function! s:vis_bounds()
  return [ col("'<"), line("'<"), col("'>"), line("'>") ] 
endfunction

function! s:is_bare(str)
  return match(a:str, "\\m^-\\?[_a-zA-Z][_a-zA-Z0-9]*$") == 0
endfunction

function! s:matchg(str, pat)
  let l:pos = 0
  let l:map = []
  while l:pos < strlen(a:str)
    let l:mats = match(a:str, a:pat, l:pos)
    if l:mats < 0
      break
    endif
    let l:mate = matchend(a:str, a:pat, l:pos)
    let l:map  = add(l:map, [l:mats, l:mate])
    let l:pos  = l:mate
    if l:mats == l:mate
      let l:pos = l:pos + 1
    endif
  endwhile
  return l:map
endfunction

function! s:find_bare(str)
  return s:matchg(a:str, "\\m-\\?[_a-zA-Z][_a-zA-Z0-9]*")
endfunction

function! FlipQuote()

  let l:line = getline('.')
  let l:pos  = col('.') - 1
  let l:map  = s:find_strings(l:line)

  for l:str in l:map
    if l:pos >= l:str[0] && l:pos < l:str[1]
      let l:qc  = strpart(l:line, l:str[0], 1)
      let l:sub = strpart(l:line, l:str[0] + 1, l:str[1] - l:str[0] - 2)
      if l:qc == "'" && s:is_bare(l:sub)
        let l:rep = l:sub
        call cursor(0, l:pos)
      else
        let l:ncq = tr(l:qc, "'\"", "\"'")
        let l:flp = s:flip_escape(l:sub, l:qc, l:pos - l:str[0] - 1)
        let l:rep = l:ncq . l:flp[0] . l:ncq
        call cursor(0, l:flp[1] + l:str[0] + 2)
      endif
      call setline('.', strpart(l:line, 0, l:str[0]) 
        \ . l:rep . strpart(l:line, l:str[1]))
      return
    elseif l:pos < l:str[1]
      break
    endif
  endfor

  " Not inside a string; look for a bareword to quote
  let l:map = s:find_bare(l:line)
  for l:str in l:map
    if l:pos >= l:str[0] && l:pos < l:str[1]
      call cursor(0, l:pos + 2)
      call setline('.', strpart(l:line, 0, l:str[0]) 
        \ . '"' . strpart(l:line, l:str[0], l:str[1] - l:str[0]) . '"'
        \ . strpart(l:line, l:str[1]))
      return
    elseif l:pos < l:str[1]
      break
    endif
  endfor

endfunction
