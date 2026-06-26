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
:nnnoremap <leader>gc mc?^\([=><\|]\)\1\{6\}<CR>d?^<<<<<<<?0<CR>/^\([=><\|]\)\1\{6\}<CR>d/^>>>>>>>/0<CR>`c
```

In neovim/lua, I map it like this:

``` lua
vim.keymap.set('n', '<leader>gc',
  [[mc?^\([=><\|]\)\1\{6\}<CR>d?^<<<<<<<?0<CR>/^\([=><\|]\)\1\{6\}<CR>d/^>>>>>>>/0<CR>`c]],
  { noremap = true }
)
```

I have found ChatGPT suprisingly good at "understanding" and explaining this mapping, but I will
break it down anyway, because, well, I like breaking things down.

First, find (up from the cursor) any conflict delimiter. That is
> 7 times `=`, `>`, `<` or `|`

or, in regex terms:
> one of `=`, `>`, `<` or `|`, followed by 6 more of the same

In vim/neovim, special regex characters must be escaped, so this becomes a bit messy:
``` plain
  ?^\([=><\|]\)\1\{6\}<CR>
```

That's one line above what we want to keep. Then, delete it and  everything above it until the
beginning of the whole conflict region (`<<<<<<<`):

``` plain
  ?^\([=><\|]\)\1\{6\}<CR>d?^<<<<<<<?0<CR>
                          ╰──────────────╯
```

`?0` at the end of the search phrase (or `/0` when searching forward) turns the search into
a linewise motion which conveniently also removes the whole line containing the beginning marker
when used as an operator to `d`.

``` plain
  ?^\([=><\|]\)\1\{6\}<CR>d?^<<<<<<<?0<CR>/^\([=><\|]\)\1\{6\}<CR>
                                          ╰──────────────────────╯
```

``` plain
  ?^\([=><\|]\)\1\{6\}<CR>d?^<<<<<<<?0<CR>/^\([=><\|]\)\1\{6\}<CR>d/^>>>>>>>/0<CR>
                                                                  ╰──────────────╯
```

``` plain
mc?^\([=><\|]\)\1\{6\}<CR>d?^<<<<<<<?0<CR>/^\([=><\|]\)\1\{6\}<CR>d/^>>>>>>>/0<CR>`c
╰╯                                                                                ╰╯
```
