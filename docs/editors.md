# Editors and agents

[← Back to README](../README.md)

Omarchy already themes most editors and coding agents on every
`omarchy theme set`, by regenerating their configs from the theme's
`colors.toml`. This page covers what is automatic, what is not, and how to run
the guided setup.

## What Omarchy does automatically

| App | Automatic | Notes |
| --- | --- | --- |
| VS Code / VSCodium / Cursor | yes | builds a local `omarchy-theme` extension and selects it |
| Herdr desktop | yes | `omarchy-theme-set-herdr-app` writes `~/.config/herdr-app/themes/omarchy.json` |
| Claude Code | writes the theme | activation is one-time (see below) |
| Pi | writes the theme | activation is one-time (see below) |
| Obsidian | yes | writes the `Omarchy` theme into every vault |
| Hermes | writes the skin | activation is one-time (see below) |
| T3 Code | yes | writes `~/.t3/userdata/themes/omarchy.json` |
| Slack | yes, when enabled | needs `omarchy-theme-set-slack` state |
| opencode | no | follows the terminal when `theme = "system"` |
| Codex | no | no theme system; inherits the terminal's ANSI palette |
| Neovim | generates only | Omarchy writes `current/theme/neovim.lua`, but nothing links it into `~/.config/nvim` |
| Zed | no | Omarchy has no Zed integration |

## Guided setup

`scripts/editors.sh` scans for what is installed, asks before each app, and
calls Omarchy's own hooks where they exist. It never uses `sudo`, and backs up
every file it overwrites.

```bash
"$(omarchy theme dir noir-dawn)/scripts/editors.sh"
```

From a clone of the repo:

```bash
./scripts/editors.sh
```

| Flag | What it does |
| --- | --- |
| *(none)* | scan, then ask per app |
| `--dry-run` | show what would happen, change nothing |
| `--yes` | apply every detected app without prompting |
| `--only zed,claude` | restrict to a comma-separated list |
| `--list` | only report what is installed |

## Per-app notes

### Neovim

The script links `~/.config/nvim/lua/plugins/theme.lua` to Omarchy's generated
`neovim.lua`, which uses [aether.nvim](https://github.com/omacom/aether.nvim)
with the theme's palette. If a Neovim is already running, the script also tells
it to re-apply the colorscheme. If you prefer the dedicated
[noir.nvim](https://github.com/tahadx/noir.nvim) colorscheme, see
[neovim.md](neovim.md) instead.

### Zed

The script writes `~/.config/zed/themes/noir-dawn.json` from the JSON in
[zed.md](zed.md). Then pick it in Zed: command palette → `zed: select theme` →
**Noir Dawn**.

### Herdr

There are two Herdr surfaces:

- **Desktop app** — themed by `omarchy-theme-set-herdr-app`.
- **CLI** — has no Omarchy integration. The script writes the theme's palette
  into `[theme.custom]` — sage accent, soft-black surfaces, theme greys — over
  `[theme] name = "terminal"`, then reloads the server. This keeps Herdr's
  accent sage instead of falling back to the terminal's grey.

### Claude Code, Pi, Hermes

Omarchy writes their theme files on every switch, but does not change the app's
active theme setting. The script runs the hooks with `--activate`, which sets:

- Claude Code — `theme = "custom:omarchy"`
- Pi — `theme = "omarchy-system"`
- Hermes — the `omarchy` skin

### opencode

opencode's `theme = "system"` reads the terminal palette, so nothing needs to be
installed. The script only makes sure that value is set.

### Codex

Codex has no theme system. It inherits the terminal's ANSI palette, which
Omarchy already sets.
