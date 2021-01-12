# windowmanager

windowmanager.vim gives the ability to easily rearrange or navigate windows in split windows.

*By default, nothing is mapped for you.* Feel free to call the functions or map to your own mappings

The exported functions are `:WMSwap`, `:WMSwapAndStay`, `:WMNav`, and `:WMDelete`.

## Example mapping

```vim
nnoremap <leader>ne :WMSwap<CR>
nnoremap <leader>ns :WMSwapAndStay<CR>
nnoremap <leader>nn :WMNav<CR>
nnoremap <leader>nd :WMDelete<CR>
```

## `WMSwap()` and `WMSwapAndStay`

WMSwap will label all the open windows (except the current window) with an alphanumeric character. 
Enter the character to swap the current window and the selected window. The cursor will remain in the same window, with the selected window contents.

`WMSwapAndStay` will do the exact same thing, except it will stay with the file as it swaps windows

![Swap Example](/images/swap.gif)

## `WMNav()`

WMNav will do the exact same as WMSwap, except it will send you to that window and not swap the contents.

![Nav Example](/images/nav.gif)

## `WMDelete()`

WMDelete is a convenience wrapper around `:bdelete`. It labels all the open windows except the current one, and you select the one in which to delete.

![Del example](/images/del.gif)

## Options

Just one option, `g:windowmanager_color`. Look at `:so $VIMRUNTIME/syntax/hitest.vim` and select a color to change it to if the default does not suit you. 
Currently, it's set to "Search". Override it with `let g:windowmanager_color = "SomeOtherColor"`

## Credit where credit is due

A lot of this is borrowed from some useful functionality I liked from [Coc-Explorer](https://github.com/weirongxu/coc-explorer)

