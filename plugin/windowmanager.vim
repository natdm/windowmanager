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

let s:action_nav = 0
let s:action_swap = 1
let s:action_delete = 2
let s:action_swap_follow = 3
let s:action_swap_two = 4

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

function! SwapTwoWins()
	call windowmanager#exec(s:action_swap_two)
endfunction

function! s:select_win(store, skip_winnrrs, msg) abort
	let curr_num = winnr()
	let char_idx_mapto_winnr = {}
	let char_idx = 0
	for winnr in range(1, winnr('$'))
		let bufnr = winbufnr(winnr)
		call s:store_statusline(a:store, winnr)

		" loop the window numbres to skip and if the current loop
		" matches one of the values, skip
		let skip = 0	
		for n in a:skip_winnrrs
			echom "looping:" . n . "with winnr: " . winnr
			if winnr ==# n
				let skip = 1
				break
			endif
		endfor
		if skip ==# 1
			continue
		endif

		let char_idx_mapto_winnr[char_idx] = winnr
		let char = s:select_wins_chars[char_idx]
		let statusline = printf('%%#%s#%s %s', g:windowmanager_color, repeat(' ', winwidth(winnr)/2-1), char)
		call setwinvar(winnr, '&statusline', statusline)
		let char_idx += 1
	endfor

	if len(char_idx_mapto_winnr) == 0
		call s:restore_statuslines(a:store)
	elseif len(char_idx_mapto_winnr) == 1
		call s:restore_statuslines(a:store)
	else
		redraw!
		let select_winnr = -1
		while 1
			call s:echo_msg(a:msg)
			let nr = getchar()
			if nr == 27 "ESC
				call s:restore_statuslines(a:store)
				return
			else
				let select_winnr = get(char_idx_mapto_winnr, string(nr - char2nr('a')), -1)
				if select_winnr != -1
					break
				endif
			endif
		endwhile
		call s:restore_statuslines(a:store)
		return select_winnr
	endif
	return -1
endfunction

function! windowmanager#exec(swap) abort
	let store = {}
	let curr_num = winnr()
	let curr_buff = bufnr("%")
	let curr_line = line(".")
	let curr_col = col(".")

	" this happens regardless, so if 'nav' is chosen as the action, just
	" don't pay attention to any of the other options
	let select_winnr = s:select_win(store, [curr_num], 'Select window')

	if a:swap ==# s:action_swap_two
		let other_winnr = s:select_win(store, [curr_num, select_winnr], 'Select window to swap with')
		let other_buff = bufnr("%")

		echon 'Done'
		return
	endif

	exe select_winnr . "wincmd w" 
	let marked_buf = bufnr("%")

	if a:swap ==# s:action_swap || a:swap ==# s:action_swap_follow
		let marked_col = col(".")
		exe 'hide buf' curr_buff
		exe curr_num . "wincmd w"
		call cursor(curr_line, curr_col)	
		exe 'hide buf' marked_buf
		if a:swap ==# s:action_swap_follow
			exe select_winnr . "wincmd w"
		endif
	elseif a:swap ==# s:action_delete
		exe 'bdelete' marked_buf
	endif
	echon 'Done'
endfunction

command! -n=0 -bar WMSwap :call SwapWin()
command! -n=0 -bar WMSwapAndFollow :call SwapAndFollow()
command! -n=0 -bar WMNav :call NavWin()
command! -n=0 -bar WMDelete :call DeleteWin()
command! -n=0 -bar WMSwapTwo :call SwapTwoWins()
