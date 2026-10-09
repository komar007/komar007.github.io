+++
title = "Today I Declared: treesitter parsers in neovim"
date = 2026-10-07
[taxonomies]
tags = [ "neovim", "declarative"]
[extra]
comment = true
+++

*I don't install and uninstall things. I declare things installed. My treesitter parsers in neovim
should be no different!*

<!-- more -->

In neovim, the treesitter parsers can (and frequently are), managed by
[`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter). Its model of operation is
rather simple: install some parsers, uninstall some parsers and you're good to go.

What if you update the plugin itself and the installed parsers need updating? Well, there's
`:TSUpdate`, which you can run manually or bind to your package manager's plugin update event. For
example in `lazy.nvim`, it's as simple as `build = ':TSUpdate'` in the plugin spec. This setup is
almost perfect, except I am a nixos user, and nothing is ever perfect for me unless it is
declarative.

"Today" (a couple days ago, really), I made it declarative because my states must be disposable and
I want my list of parsers committed and tracked by git.

[`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter) has everything needed to
achieve this, so the solution is as simple as:
([*view in context*](https://github.com/komar007/dot-nvim/blob/01a2b66c0e590547b8a506f24b91b2a37025f7e5/lua/plugins/treesitter.lua#L1-L16))

```lua
local function declare_parsers(parsers)
  local timeout_ms = 5 * 60 * 1000

  local treesitter = require('nvim-treesitter')
  local ts_config = require('nvim-treesitter.config')

  treesitter.install(parsers):wait(timeout_ms)

  local parsers_resolved = ts_config.norm_languages(parsers, { unsupported = true })
  local stale_parsers = vim.tbl_filter(function(p)
    return not vim.list_contains(parsers_resolved, p)
  end, treesitter.get_installed())
  treesitter.uninstall(stale_parsers):wait(timeout_ms)

  treesitter.update():wait(timeout_ms)
end
```

Calling `require'nvim-treesitter'.update()` seems to be safe and free when parsers are already up to
date - no need to trust any events.

> [!NOTE]
> [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter) allows parsers to have
> dependencies in form of other parsers. That's why it's crucial to calculate `stale_parsers`
> against a resolved list of parsers that *would be installed*, not the declared list, as that would
> result in immediately uninstalling the dependencies, which the declaration may not contain.
>
> Did I learn about it the hard way? Of course. This way you don't have to.

Then, it's just a matter of:

```lua
declare_parsers({
  "nix",
  "rust",
  -- enough is enough, what else could one possibly want?
})
```

I also see no reason to not use a parser I declare installed, so as a bonus here's what I also do:
[*view in context*](https://github.com/komar007/dot-nvim/blob/01a2b66c0e590547b8a506f24b91b2a37025f7e5/lua/plugins/treesitter.lua#L61-L75):

```lua
local group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then
      return
    end
    local parser_available = vim.treesitter.language.add(lang)
    if not parser_available then
      return
    end
    vim.treesitter.start(args.buf, lang)
  end,
})
```
