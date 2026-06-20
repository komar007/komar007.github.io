+++
title = "zdiff3 and (neo)vim"
date = 2026-06-19
draft = false
[taxonomies]
tags = ["git", "vim", "hack"]
+++

Working with git, I found that I am missing very simple functionality from a few plugins I've
checked out - accept the area of the conflict region under cursor and remove the rest. Most plugins
have actions to select "ours" and "theirs", but, strangely, not the hunk I'm looking at right now.

Here's the solution. No error handling, no conditions, pure vim.

``` viml
:nnnoremap <leader>gc mc?^[=><\|]\{7\}?1<CR>d?^<\{7\}<CR>/^[=><\|]\{7\}<CR>d/^>\{7\}<CR>dd`c
```

In neovim/lua, I map it like this:

``` lua
vim.keymap.set('n', '<leader>gc',
  [[mc?^[=><\|]\{7\}?1<CR>d?^<\{7\}<CR>/^[=><\|]\{7\}<CR>d/^>\{7\}<CR>dd`c]],
  { noremap = true }
)
```
