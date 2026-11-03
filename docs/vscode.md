# VS Code

[← Back to README](../README.md)

The VS Code theme ships in [`vscode-extension/`](../vscode-extension) and is
published as **Noir Omarchy**. It is a separate extension, so it does not
install with the Omarchy theme.

## Install

### From the Marketplace

```bash
code --install-extension tahasadough.noir-omarchy
```

Or search **Noir Omarchy** in the Extensions view. Then open the Command
Palette (`Ctrl+Shift+P`) → **Preferences: Color Theme** → select **Noir Dawn**.

### From source

```bash
cd vscode-extension
npm install -g @vscode/vsce
vsce package
code --install-extension noir-omarchy-0.2.1.vsix
```

### From folder (dev)

1. Open `vscode-extension/` in VS Code and add `.vscode/launch.json`:

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

2. Press `F5`, then select **Noir Dawn** from the color theme picker.

## Palette

| Role       | Hex       | Used for                |
| ---------- | --------- | ----------------------- |
| `bg`       | `#0c0b0c` | Editor background       |
| `alt_bg`   | `#1c1c1c` | Panels, hovers, status  |
| `fg`       | `#c1c1c1` | Foreground              |
| `comment`  | `#505050` | Comments                |
| `constant` | `#aaaaaa` | Constants, numbers      |
| `func`     | `#888888` | Functions               |
| `keyword`  | `#999999` | Keywords, storage       |
| `operator` | `#9b99a3` | Operators, punctuation  |
| `string`   | `#aa9988` | Strings                 |
| `type`     | `#777755` | Types, classes          |
| `visual`   | `#333333` | Selection               |
| `accent`   | `#8a9a7b` | Accent, focus, tags     |
