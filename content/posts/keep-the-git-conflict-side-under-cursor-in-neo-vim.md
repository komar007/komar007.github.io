+++
title = '''Keep the git conflict "side" under cursor in (neo)vim'''
date = 2026-06-26
taxonomies.tags = ["git", "vim", "hack"]
extra.comment = true
+++
tl;dr `` mc?^\([=><\|]\)\1\{6\}<CR>d?^<<<<<<<?0<CR>/^\([=><\|]\)\1\{6\}<CR>d/^>>>>>>>/0<CR>`c ``

<!-- more -->

----------------------------------------------------------------------------------------------------

Working with git, I found that I am missing very simple functionality from a few plugins I've
checked out - accept the side of the conflict region under cursor and remove the rest. Most
plugins have actions to keep the *ours* side and the *theirs* side but, strangely, not the side I'm
looking at right now.

> [!NOTE]
> Throughout this post I use the term *side* to refer to the area between any 2 adjacent git
> conflict markers, as that seems to be a historically reasonable name. I use `zdiff3` exclusively
> where there is also a "third" *side*, but who cares. Let *conflict region* be the region of test
> between `<<<<<<<` and `>>>>>>>`. It is sometimes also called a *hunk*.

# Solution

Here's the solution. No error handling, no conditions, pure vim.

``` viml
:nnoremap <leader>gc mc?^\([=><\|]\)\1\{6\}<CR>d?^<<<<<<<?0<CR>/^\([=><\|]\)\1\{6\}<CR>d/^>>>>>>>/0<CR>`c
```

In neovim/lua, I map it like this:

``` lua
vim.keymap.set('n', '<leader>gc',
  [[mc?^\([=><\|]\)\1\{6\}<CR>d?^<<<<<<<?0<CR>/^\([=><\|]\)\1\{6\}<CR>d/^>>>>>>>/0<CR>`c]],
  { noremap = true }
)
```

# Explanation

> [!NOTE]
> I have found ChatGPT suprisingly good at "understanding" and explaining this mapping, but I will
> break it down anyway, because, well, I like breaking things down.

First, find (up from the cursor) any conflict delimiter. That is

> 7 times `=`, `>`, `<` or `|`

or, in regex terms:

> one of `=`, `>`, `<` or `|`, followed by 6 more of the same

In vim/neovim, special regex characters must be escaped, so this becomes a bit messy:

<pre><code>  ?^\([=><\|]\)\1\{6\}&lt;CR></code></pre>

Now we are one line above what we want to keep. Then, delete that line and everything above it until
the beginning of the whole conflict region (`<<<<<<<`):

<pre><code><span class="dimmed">  ?^\([=><\|]\)\1\{6\}&lt;CR></span>d?^&lt;&lt;&lt;&lt;&lt;&lt;&lt;?0&lt;CR></code></pre>

`?0` at the end of the search phrase (or `/0` when searching forward) turns the search into a
linewise motion which conveniently also removes the whole line containing the beginning marker when
used as an operator to `d`.

Now a forward search to any conflict marker moves us to the line below the part we want to keep (as
after the last deletion the cursor is on the first line of the conflict side of interest)...

<pre><code><span class="dimmed">  ?^\([=><\|]\)\1\{6\}&lt;CR>d?^&lt;&lt;&lt;&lt;&lt;&lt;&lt;?0&lt;CR></span>/^\([=><\|]\)\1\{6\}&lt;CR></code></pre>

...followed by deletion until the final marker:

<pre><code><span class="dimmed">  ?^\([=><\|]\)\1\{6\}&lt;CR>d?^&lt;&lt;&lt;&lt;&lt;&lt;&lt;?0&lt;CR>/^\([=><\|]\)\1\{6\}&lt;CR></span>d/^>>>>>>>/0&lt;CR></code></pre>

And a cherry on top: remember the initial position of the cursor and revert it after the operation:

<pre><code>mc<span class="dimmed">?^\([=><\|]\)\1\{6\}&lt;CR>d?^&lt;&lt;&lt;&lt;&lt;&lt;&lt;?0&lt;CR>/^\([=><\|]\)\1\{6\}&lt;CR>d/^>>>>>>>/0&lt;CR></span>`c </code></pre>

See a visualisation below:

<pre><code>             ?<span class="dimmed">...</span>            d?<span class="dimmed">...</span>          /<span class="dimmed">...</span>             d/<span class="dimmed">...</span>           `c
common text 1   common text 1
<<<<<<< ours  <span class="deletion">✗</span> <<<<<<< ours   common text 1    common text 1   common text 1  common text 1
ours1         <span class="deletion">✗</span> ours1         <span class="cursor">ꕯ</span>base1            base1           base1          base1
ours2         <span class="deletion">✗</span> ours2          base2            base2           base2          base2
||||||| base  <span class="deletion">✗</span><span class="cursor">ꕯ</span>||||||| base   base3<span class="mark-c">`c </span>         base3<span class="mark-c">`c </span>        base3<span class="mark-c">`c </span>       base3<span class="cursor">ꕯ</span><span class="mark-c">`c </span>
base1           base1          =======        <span class="deletion">✗</span><span class="cursor">ꕯ</span>=======        <span class="cursor">ꕯ</span>common text 2  common text 2
base2           base2          theirs         <span class="deletion">✗</span> theirs
base3<span class="cursor">ꕯ</span><span class="mark-c">`c </span>       base3<span class="mark-c">`c </span>       >>>>>>> theirs <span class="deletion">✗</span> >>>>>>> theirs
=======         =======        common text 2    common text 2
theirs          theirs
>>>>>>> theirs  >>>>>>> theirs
common text 2   common text 2
</code></pre>

Legend:

- <span class="cursor">`ꕯ`</span> - cursor position
- <span class="mark-c">``  `c ``</span> - position of mark c
- <span class="deletion">`✗`</span> - lines scheduled to be deleted (placed on the left of each
  line)

# Shortcomings

Admittedly, I have purposely kept this solution without any error handling. It does not work well
when a side is empty, it is unclear what it should do when the cursor is on a conflict marker and it
deletes stuff when the cursor is between hunks. I wish I could say I don't care. But I will try my
best not to fix it to retain the crudity. It will be hard, it will be against my nature, but I will
try.

The keymap has found its [place in my neovim
dotfiles](https://github.com/komar007/dot-nvim/blob/9a32be27a8b2add95222d6e1bf27dda77eb960ae/lua/keymaps.lua#L18-L22).
Feel free to bash me if it gets any less crude.

# Other solutions

At first I thought it would be natural to first find the conflict side of interest between any
conflict markers up and down from the cursor, yank it, then select the whole conflict region and
substitute with the yanked content. But this makes it impossible to restore the original cursor
position, as deleting lines with a mark inside deletes the mark. Note that in the presented solution
the deletions before the mark conveniently preserve the logical position of the mark (decrease the
line number associated with the mark) and deletions after the mark are irrelevant.

<style>
  .cursor {
    color: green;
    font-weight: bold;
  }
  .deletion {
    color: red;
    font-weight: bold;
  }
  .mark-c {
    color: orange;
    font-weight: bold;
  }
  .dimmed {
    opacity: 0.3;
  }
</style>
