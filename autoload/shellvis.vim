function! shellvis#sys(cmd, input)
    return substitute(system(a:cmd, a:input), '\n$', '', 'g')
endfunction

function! shellvis#do(cmd)
    " Preserve line breaks
    let l:paste = &paste
    set paste
    " Reselect the visual mode text
    normal! gv
    " Apply transformation to the text
    execute "normal! c\<c-r>=shellvis#sys(\"" . a:cmd . "\", @\")\<cr>\<esc>"
    " Select the new text
    normal! `[v`]h
    " Revert to previous mode
    let &paste = l:paste
endfunction
