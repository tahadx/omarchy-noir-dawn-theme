# Noir Dawn for Visual Studio Code

![Noir Dawn](https://github.com/tahasadough/noir-vscode/raw/HEAD/icon.png)

A dark theme for Visual Studio Code. Soft black background (`#1c1c1c`), warm grey text,
muted sage accents.

## Install

### From the Marketplace

```bash
code --install-extension tahasadough.noir-omarchy
```

Or search **Noir Omarchy** in the Extensions view. Then open the Command
Palette (`Ctrl+Shift+P`) → **Preferences: Color Theme** → select **Noir Dawn**.

### From source

```bash
npm install -g @vscode/vsce
vsce package
code --install-extension noir-omarchy-0.2.0.vsix
```

### From folder (dev)

1. `code --install-extension` doesn't work on folders; instead open the repo
   in VS Code and press F5 (or run the "Extension Development Host" from the
   Run and Debug panel) after adding a `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "extensionHost",
      "request": "launch",
      "name": "Launch Extension",
      "args": ["--extensionDevelopmentPath=${workspaceFolder}"]
    }
  ]
}
```

2. Select **Noir Dawn** from the color theme picker.

## Palette

| Role       | Hex       | Used for                |
| ---------- | --------- | ----------------------- |
| `bg`       | `#1c1c1c` | Editor background       |
| `alt_bg`   | `#333333` | Panels, hovers, status  |
| `fg`       | `#c1c1c1` | Foreground              |
| `comment`  | `#505050` | Comments                |
| `constant` | `#aaaaaa` | Constants, numbers      |
| `func`     | `#888888` | Functions               |
| `keyword`  | `#999999` | Keywords, storage       |
| `operator` | `#9b99a3` | Operators, punctuation  |
| `string`   | `#aa9988` | Strings                 |
| `type`     | `#777755` | Types, classes          |
| `visual`   | `#505050` | Selection               |
| `accent`   | `#8a9a7b` | Accent, focus, tags     |

## License

MIT
