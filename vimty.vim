
" NOTE - on macOS, using chunkwm, this requires that the window be "floating" as defined by chunkwm !
" it also requires chunkwm to have ability to control floating windows
" (currently provided by a hacky bash script)

let s:os_name = system("uname -s")

if get(g:, "vimty_float_cmd", 0)
    let s:float_cmd = g:vimty_float_cmd
else
    let s:float_cmd = "$HOME/.config/scripts/chunk_float.sh"
endif

" remove whitespace from split list
function! s:Strip(inp)
    return substitute(a:inp, " ", "", "")
endfunction

function! Typewriter ()
    let a:cursor_pos = getpos(".")
    let g:cx = a:cursor_pos[2]
    let g:cy = a:cursor_pos[1]
    let g:topline = line("w0")

    " mac os resolution
    let mx = system("system_profiler SPDisplaysDataType|grep Resolution|cut -f1 -d 'x'|grep -o '[0-9]\+'")
    let my = system("system_profiler SPDisplaysDataType|grep Resolution|cut -f2 -d 'x'|grep -o '[0-9]\+'")

    " Current window w,h (make sure to strip whitespace after split)
    let res_window = system("osascript -e 'tell application \"iTerm\" to get the bounds of the front window'")
    let dims = map(split(res_window, ','), "s:Strip" . "(v:val)")
    let winwidth =  dims[2] - dims[0]
    let winheight = dims[3] - dims[1]

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
    let a:cursor_pos = getpos(".")
    let cx_new = a:cursor_pos[2]
    let cy_new = a:cursor_pos[1]
    let topline_new = line("w0")

    " Figure out the adjustment to the location of the window.
    let left = g:pxW * (cx_new - g:cx)
    let up =   g:pxH * (cy_new - g:cy - topline_new + g:topline)

    " Account for negative 'leftness'
    if left > 0
        let k = system(s:float_cmd . " move -x " . left)
    elseif left < 0
        let left  = 0 - left
        let k = system(s:float_cmd . " move +x ".left)
    endif

    " Account for negative 'topness'
    if up > 0
        let k = system(s:float_cmd . " move -y ".up)
    elseif up < 0
        let up  = 0 - up
        let k = system(s:float_cmd . " move +y ".up)
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
autocmd InsertEnter  * :call Typewriter()
autocmd VimResized   * :call Typewriter()
autocmd CursorMoved  * :call TypewriterMove()
autocmd CursorMovedI * :call TypewriterMove()
autocmd TextChangedI * :call TypeText()
