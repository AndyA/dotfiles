" Useful stuff
function! Get_location()
  let l:window = ( line('w0') + line('w$') ) / 2
  let l:line   = line('.')
  let l:col    = col('.')
  return { 'window': l:window, 'line': l:line, 'col': l:col }
endfunction

function! Set_location(loc)
  exec 'normal ' . a:loc['window'] . 'zz'
  exec 'normal ' . a:loc['line']   . 'G'
  exec 'normal ' . a:loc['col']    . '|'
endfunction
