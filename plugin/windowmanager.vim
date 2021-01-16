if !exists("g:windowmanager_loaded")
	let g:windowmanager_loaded = 1
endif

let s:select_wins_chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

" add other colors from :so $VIMRUNTIME/syntax/hitest.vim as desired
let g:windowmanager_color = "Search"
let g:windowmanager_selected_color = "DiffText"

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

" action constants for readability
let s:action_nav = 0
let s:action_swap = 1
let s:action_delete = 2
let s:action_swap_follow = 3
let s:action_move_below = 4

function! DeleteWin()
	call windowmanager#exec(s:action_delete)
endfunction

function! SwapAndFollow()
	call windowmanager#exec(s:action_swap_follow)
endfunction

function! SwapWin()
	call windowmanager#exec(s:action_swap)
endfunction

function! NavWin()
	call windowmanager#exec(s:action_nav)
endfunction

function! MoveBelow()
	call windowmanager#exec(s:action_move_below)

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

		let first_winnr = -1 " first window chosen
		while 1
			call s:echo_msg('Select first window')
			let nr = getchar()
			if nr == 27 
				call s:restore_statuslines(store)
				return
			else
				let first_winnr = get(char_idx_mapto_winnr, string(nr - char2nr('a')), -1)
				if first_winnr != -1
					let statusline = printf('%%#%s#%s %s', g:windowmanager_selected_color, repeat(' ', winwidth(first_winnr)/2-1), 'X')
					call setwinvar(first_winnr, '&statusline', statusline)
					break
				endif
			end
		endwhile

		let second_winnr = -1
		while 1
			if a:swap ==# s:action_swap || a:swap ==# s:action_swap_follow 
				call s:echo_msg('Select window to swap with')
			elseif a:swap ==# s:action_nav 
				call s:echo_msg('Select window to move to')
			else
				call s:echo_msg('Select window to close')
			endif

			let nr = getchar()
			if nr == 27 "ESC
				call s:restore_statuslines(store)
				return
			elseif nr ==# first_winnr
				call s:restore_statuslines(store)
				return
			else
				let second_winnr = get(char_idx_mapto_winnr, string(nr - char2nr('a')), -1)
				if second_winnr != -1
					break
				endif
			endif
		endwhile
		call s:restore_statuslines(store)
		" move to selected window
		exe second_winnr . "wincmd w" 
		if a:swap ==# s:action_swap || a:swap ==# s:action_swap_follow 
			let marked_buf = bufnr("%")
			let marked_line = line(".")
			let marked_col = col(".")
			"need to get the buffer from the selected window,
			"looks like I can use winbufnr?
			exe 'hide buf' winbufnr(first_winnr)
			exe first_winnr . "wincmd w"
			call cursor(curr_line, curr_col)	
			exe 'hide buf' marked_buf
			if a:swap ==# s:action_swap_follow 
				exe second_winnr . "wincmd w"
			endif
		elseif a:swap ==# s:action_delete 
			let marked_buf = bufnr("%")
			exe 'bdelete' marked_buf
		elseif a:swap ==# s:action_move_below
			echon 'moving below ' . marked_buf
		endif
		echon 'Done'
	endif
endfunction

command! -n=0 -bar WMSwap :call SwapWin()
command! -n=0 -bar WMSwapAndFollow :call SwapAndFollow()
command! -n=0 -bar WMNav :call NavWin()
command! -n=0 -bar WMDelete :call DeleteWin()
command! -n=0 -bar WMMoveBelow :call MoveBelow()
