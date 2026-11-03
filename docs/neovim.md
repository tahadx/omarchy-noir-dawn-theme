# Neovim

[← Back to README](../README.md)

Omarchy generates
`~/.local/state/omarchy/current/theme/neovim.lua` — an
[aether.nvim](https://github.com/omacom/aether.nvim) spec carrying this theme's
palette — but does not link it into your Neovim config. The guided setup can do
that for you:

```bash
"$(omarchy theme dir noir-dawn)/scripts/editors.sh" --only nvim
```

If you would rather use [noir.nvim](https://github.com/tahadx/noir.nvim), the
dedicated colorscheme for this theme, save the snippet below as
`~/.config/nvim/lua/plugins/noir.lua`:

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
