if !exists("g:windowmanager_loaded")
	let g:windowmanager_loaded = 1
endif

let s:select_wins_chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

" add other colors from :so $VIMRUNTIME/syntax/hitest.vim as desired
let g:windowmanager_color = "Search"

function! s:restore_statuslines(store) abort
	for winnr in keys(a:store)
		call setwinvar(winnr, '&statusline', a:store[winnr])
	endfor
endfunction

function s:store_statusline(store, winnr) abort 
	let a:store[a:winnr] = getwinvar(a:winnr, '&statusline')
endfunction

function! s:echo_msg(msg) abort
	echohl Question
	echon a:msg . ": "
	echohl None
endfunction

function! DeleteWin()
	call windowmanager#exec(2)
endfunction

function! SwapAndStay()
	call windowmanager#exec(3)
endfunction

function! SwapWin()
	call windowmanager#exec(1)
endfunction

function! NavWin()
	call windowmanager#exec(0)
endfunction

function! windowmanager#exec(swap) abort
	let store = {}
	let char_idx_mapto_winnr = {}
	let char_idx = 0
	let curr_num = winnr()
	let curr_buff = bufnr("%")
	let curr_line = line(".")
	let curr_col = col(".")

	" update all the windows status lines with a letter
	for winnr in range(1, winnr('$'))
		let bufnr = winbufnr(winnr)
		call s:store_statusline(store, winnr)
		if winnr == curr_num
			continue
		endif
		let char_idx_mapto_winnr[char_idx] = winnr
		let char = s:select_wins_chars[char_idx]
		let statusline = printf('%%#%s#%s %s', g:windowmanager_color, repeat(' ', winwidth(winnr)/2-1), char)
		call setwinvar(winnr, '&statusline', statusline)
		let char_idx += 1
	endfor

	if len(char_idx_mapto_winnr) == 0
		call s:restore_statuslines(store)
	elseif len(char_idx_mapto_winnr) == 1
		call s:restore_statuslines(store)
	else
		redraw!
		let select_winnr = -1
		while 1
			if a:swap ==# 1
				call s:echo_msg('Select window to swap with')
			elseif a:swap ==# 0
				call s:echo_msg('Select window to move to')
			else
				call s:echo_msg('Select window to close')
			endif

			let nr = getchar()
			if nr == 27 "ESC
				call s:restore_statuslines(store)
				return
			else
				let select_winnr = get(char_idx_mapto_winnr, string(nr - char2nr('a')), -1)
				if select_winnr != -1
					break
				endif
			endif
		endwhile
		call s:restore_statuslines(store)
		" move to selected window
		exe select_winnr . "wincmd w" 
		if a:swap ==# 1 || a:swap ==# 3
			let marked_buf = bufnr("%")
			let marked_line = line(".")
			let marked_col = col(".")
			exe 'hide buf' curr_buff
			if a:swap ==# 1
				exe curr_num . "wincmd w"
			endif
			call cursor(curr_line, curr_col)	
			exe 'hide buf' marked_buf
		elseif a:swap ==# 2
			let marked_buf = bufnr("%")
			exe 'bdelete' marked_buf
		endif
		echon 'Done'
	endif
endfunction

command! -n=0 -bar WMSwap :call SwapWin()
command! -n=0 -bar WMSwapAndStay :call SwapAndStay()
command! -n=0 -bar WMNav :call NavWin()
command! -n=0 -bar WMDelete :call DeleteWin()
