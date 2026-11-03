# Neovim

[← Back to README](../README.md)

Omarchy doesn't ship a Neovim template for community themes, so set it up manually
with [noir.nvim](https://github.com/tahadx/noir.nvim). Save the snippet below
as `~/.config/nvim/lua/plugins/noir.lua`:

```lua
return {
  {
    "tahadx/noir.nvim",
    priority = 1000,
    config = true,
    opts = {
      variant = "dawn",
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "noir",
    },
  },
}
```
