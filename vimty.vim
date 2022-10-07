function! Typewriter ()
    let b:cursor_pos = getpos(".")
    let g:cx = b:cursor_pos[2]
    let g:cy = b:cursor_pos[1]
    let g:topline = line("w0")

    " Screen size.
    let mx = system("xrandr -q --current | head -n2 | tail -n1 | cut --delimiter=' ' -f4 | cut --delimiter='x' -f1")
    let my = system("xrandr -q --current | head -n2 | tail -n1 | cut --delimiter=' ' -f4 | cut --delimiter='x' -f2 | cut --delimiter='+' -f1")

    " Current X window ID
    let curwin = system("xdotool getactivewindow | head -n1 | awk '{printf $0}'")
    " Current X window w,h
    let winwidth = system("xwininfo -id " . curwin . " | grep Width | xargs | cut --delimiter=' ' -f2")
    let winheight = system("xwininfo -id " . curwin . " | grep Height | xargs | cut --delimiter=' ' -f2")

    " Figuring out character width&height
    let g:pxW = winwidth  / &columns
    let g:pxH = winheight / &lines

    " Midpoint of screen
    let midX = mx / 2
    let midY = my / 2

    " Where the top-left of the window needs to be
    let left = midX - (g:pxW * (g:cx+4)) - (g:pxW / 2)
    let top  = midY - (g:pxH * (g:cy - g:topline)) - (g:pxH / 2)

    " Set it!
    "
    " TODO CENTER WINDOW
    "
    " let k = system("bspc node -v 0 0")

    call TypewriterMove()

endfunction

function! TypewriterMove()
    " Figure out the cursor delta from last positioning.
    let b:cursor_pos = getpos(".")
    " let cx_new = b:cursor_pos[2] % &columns
    let cx_new = virtcol('.') % &columns
    let cy_new = b:cursor_pos[1] % &lines
    let topline_new = line("w0")

    " Figure out the adjustment to the location of the window.
    let left = g:pxW * (cx_new - g:cx)
    let up =   g:pxH * (cy_new - g:cy - topline_new + g:topline)

    " Account for negative 'leftness'
    if left > 0
        let k = system("bspc node -v -".left." 0")
    elseif left < 0
        let left  = 0 - left
        let k = system("bspc node -v ".left." 0")
    endif

    " Account for negative 'topness'
    if up > 0
        let k = system("bspc node -v 0 -".up)
    elseif up < 0
        let up  = 0 - up
        let k = system("bspc node -v 0 ".up)
    endif

    " Update values
    let g:cx = cx_new
    let g:cy = cy_new
    let g:topline = topline_new
    let g:left = left
    let g:up = up
endfunction


function! TypeText()
    " Doing anything here causes my Vim to go mad.
    " This is where it SHOULD go, though!

    " up = 1 ie move down one line
    "if g:up == g:pxH
    "   DoQuietly paplay $HOME/Scripts/ding.wav
    "
    " left = 1 ie move right one column
    "if g:left == g:pxW
    "   DoQuietly paplay $HOME/type.wav
    "endif
endfunction


call Typewriter()
autocmd InsertEnter * :call Typewriter()
autocmd VimResized * :call Typewriter()
autocmd CursorMoved * :call TypewriterMove()
autocmd CursorMovedI * :call TypewriterMove()
autocmd TextChangedI * :call TypeText()
