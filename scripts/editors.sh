#!/usr/bin/env bash
# Noir Dawn — guided setup for editors and coding agents.
#
# Omarchy already themes most of these apps on every `omarchy theme set`, by
# regenerating their configs from the theme's colors.toml. This script does not
# duplicate that. It looks for what is installed, asks before touching
# anything, and calls Omarchy's own hooks where they exist — plus the one app
# Omarchy has no integration for (Zed).
#
# Usage:
#   scripts/editors.sh              scan, then ask per app
#   scripts/editors.sh --dry-run    show what would happen, change nothing
#   scripts/editors.sh --yes        apply every detected app, no prompts
#   scripts/editors.sh --only zed,claude
#   scripts/editors.sh --list       only report what is installed
#
# Every file this script overwrites is backed up beside the original with a
# timestamp suffix. It never uses sudo.

set -uo pipefail

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CURRENT_THEME="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/current/theme"
STAMP="$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
ASSUME_YES=0
LIST_ONLY=0
ONLY=""
FAILED=()

if [[ -t 1 ]]; then
  B=$'\e[1m'; D=$'\e[2m'; G=$'\e[32m'; Y=$'\e[33m'; R=$'\e[31m'; N=$'\e[0m'
else
  B=""; D=""; G=""; Y=""; R=""; N=""
fi

usage() {
  sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while (( $# )); do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --yes | -y) ASSUME_YES=1 ;;
    --list) LIST_ONLY=1 ;;
    --only) ONLY="${2:-}"; shift ;;
    --only=*) ONLY="${1#*=}" ;;
    -h | --help) usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

# ---------------------------------------------------------------- helpers

have() { command -v "$1" >/dev/null 2>&1; }

ok()   { printf '  %sok%s   %s\n' "$G" "$N" "$*"; }
applied() { if (( DRY_RUN )); then ok "would $*"; else ok "$*"; fi; }
skip() { printf '  %s--%s   %s\n' "$D" "$N" "$*"; }
warn() { printf '  %s!!%s   %s\n' "$Y" "$N" "$*"; }
bad()  { printf '  %sxx%s   %s\n' "$R" "$N" "$*"; }
note() { printf '       %s%s%s\n' "$D" "$*" "$N"; }

run() {
  if (( DRY_RUN )); then
    printf '  %s+%s   %s\n' "$D" "$N" "$*"
  else
    "$@"
  fi
}

backup() {
  local f="$1"
  [[ -e "$f" || -L "$f" ]] || return 0
  local b="$f.bak.$STAMP"
  cp -a "$f" "$b" && printf '%s\n' "$b"
}

ask() {
  (( ASSUME_YES || DRY_RUN )) && return 0
  [[ -t 0 ]] || return 1
  local reply
  read -r -p "  $1 [Y/n] " reply
  [[ -z "$reply" || "$reply" =~ ^[Yy] ]]
}

# ---------------------------------------------------------------- apps

APPS=(nvim zed vscode herdr-app herdr claude pi opencode codex obsidian hermes t3code slack)

label() {
  case "$1" in
    nvim)     echo "Neovim" ;;
    zed)      echo "Zed" ;;
    vscode)   echo "VS Code / VSCodium / Cursor" ;;
    herdr-app) echo "Herdr desktop" ;;
    herdr)    echo "Herdr CLI" ;;
    claude)   echo "Claude Code" ;;
    pi)       echo "Pi" ;;
    opencode) echo "opencode" ;;
    codex)    echo "Codex" ;;
    obsidian) echo "Obsidian" ;;
    hermes)   echo "Hermes" ;;
    t3code)   echo "T3 Code" ;;
    slack)    echo "Slack" ;;
  esac
}

detect() {
  case "$1" in
    nvim)     have nvim || [[ -d "$HOME/.config/nvim" ]] ;;
    zed)      have zed || [[ -d "$HOME/.config/zed" ]] ;;
    vscode)   have code || have codium || have cursor ;;
    herdr-app) have herdr-app || [[ -d "${HERDR_APP_HOME:-$HOME/.config/herdr-app}" ]] ;;
    herdr)    have herdr || [[ -d "$HOME/.config/herdr" ]] ;;
    claude)   have claude || [[ -d "${CLAUDE_CONFIG_DIR:-$HOME/.claude}" ]] ;;
    pi)       have pi || [[ -d "$HOME/.pi/agent" ]] ;;
    opencode) have opencode || [[ -d "$HOME/.config/opencode" ]] ;;
    codex)    have codex || [[ -d "${CODEX_HOME:-$HOME/.codex}" ]] ;;
    obsidian) [[ -d "$HOME/.config/obsidian" ]] ;;
    hermes)   have hermes || [[ -d "${HERMES_HOME:-$HOME/.hermes}" ]] ;;
    t3code)   have t3code || [[ -d "${T3CODE_HOME:-$HOME/.t3}" ]] ;;
    slack)    [[ -d "$HOME/.config/Slack" ]] || have slack ;;
  esac
}

describe() {
  case "$1" in
    nvim)     echo "link ~/.config/nvim/lua/plugins/theme.lua to Omarchy's generated theme" ;;
    zed)      echo "write ~/.config/zed/themes/noir-dawn.json (Omarchy has no Zed support)" ;;
    vscode)   echo "run omarchy-theme-set-vscode: local Omarchy theme + select it" ;;
    herdr-app) echo "run omarchy-theme-set-herdr-app --activate" ;;
    herdr)    echo "follow the terminal palette ([theme] name = \"terminal\")" ;;
    claude)   echo "run omarchy-theme-set-claude --activate" ;;
    pi)       echo "run omarchy-theme-set-pi --activate" ;;
    opencode) echo "make sure the CLI follows the terminal (theme = system)" ;;
    codex)    echo "no theme system — reports only" ;;
    obsidian) echo "run omarchy-theme-set-obsidian for every vault" ;;
    hermes)   echo "run omarchy-theme-set-hermes --activate" ;;
    t3code)   echo "run omarchy-theme-set-t3code" ;;
    slack)    echo "run omarchy-theme-set-slack" ;;
  esac
}

# ---------------------------------------------------------------- actions

apply_nvim() {
  local target="$HOME/.config/nvim/lua/plugins/theme.lua"
  local source="$CURRENT_THEME/neovim.lua"

  if [[ ! -f "$source" ]]; then
    warn "Omarchy has not generated $source yet"
    note "run: omarchy theme set noir-dawn"
    return 1
  fi

  if [[ -L "$target" ]] && [[ "$(readlink -f "$target")" == "$(readlink -f "$source")" ]]; then
    skip "already linked"
    return 0
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    local b
    b="$(backup "$target")"
    note "backup: $b"
  fi

  run mkdir -p "$(dirname "$target")"
  run ln -sfn "$source" "$target"
  applied "link theme.lua -> $source"
  note "prefer noir.nvim instead? see docs/neovim.md"
}

apply_zed() {
  local source="$THEME_DIR/docs/zed.md"
  local target="$HOME/.config/zed/themes/noir-dawn.json"

  if [[ ! -f "$source" ]]; then
    warn "missing $source"
    return 1
  fi

  local json
  json="$(awk '/^```json[[:space:]]*$/{f=1;next} /^```[[:space:]]*$/{if(f)exit} f' "$source")"
  if [[ -z "$json" ]]; then
    warn "no JSON block found in $source"
    return 1
  fi

  if have jq && ! printf '%s' "$json" | jq empty >/dev/null 2>&1; then
    warn "the JSON in docs/zed.md does not parse"
    return 1
  fi

  if (( DRY_RUN )); then
    ok "would write $target"
    return 0
  fi

  if [[ -e "$target" ]]; then
    local b
    b="$(backup "$target")"
    note "backup: $b"
  fi

  mkdir -p "$(dirname "$target")"
  printf '%s\n' "$json" >"$target"
  ok "wrote $target"
  note "then: command palette -> zed: select theme -> Noir Dawn"
}

apply_vscode() {
  if ! have omarchy-theme-set-vscode; then
    warn "omarchy-theme-set-vscode is not available"
    return 1
  fi
  run omarchy-theme-set-vscode
  applied "generate and select the Omarchy VS Code theme"
}

apply_herdr_app() {
  if ! have omarchy-theme-set-herdr-app; then
    warn "omarchy-theme-set-herdr-app is not available"
    return 1
  fi
  if ! pgrep -x herdr-app >/dev/null 2>&1; then
    warn "Herdr desktop is not running; the theme is written but not activated"
  fi
  run omarchy-theme-set-herdr-app --activate
  applied "write the Herdr desktop theme"
}

apply_herdr() {
  local cfg="${HERDR_CONFIG_PATH:-$HOME/.config/herdr/config.toml}"

  if [[ ! -f "$cfg" ]]; then
    warn "no Herdr config at $cfg"
    return 1
  fi

  if (( DRY_RUN )); then
    ok "would set [theme] name = \"terminal\" in $cfg"
    note "and comment out [theme.custom] so the terminal palette wins"
    return 0
  fi

  local b
  b="$(backup "$cfg")"
  note "backup: $b"

  python3 - "$cfg" <<'PY'
import re, sys
path = sys.argv[1]
lines = open(path, encoding="utf-8").read().splitlines()
out, section, seen = [], None, False
for line in lines:
    header = re.match(r"^\s*\[([^\]]+)\]\s*(#.*)?$", line)
    if header:
        section = header.group(1).strip()
        seen = seen or section == "theme"
        out.append(line)
        continue
    if section == "theme" and re.match(r"^\s*name\s*=", line):
        out.append('name = "terminal"')
        continue
    if section and section.startswith("theme.custom"):
        out.append(line if not line.strip() or line.lstrip().startswith("#") else "# " + line)
        continue
    out.append(line)
if not seen:
    out = ["[theme]", 'name = "terminal"', ""] + out
open(path, "w", encoding="utf-8").write("\n".join(out) + "\n")
PY

  ok "Herdr now follows the terminal palette"
  if pgrep -f "herdr server" >/dev/null 2>&1; then
    run herdr server reload-config || warn "could not reload the Herdr server"
  else
    note "start Herdr to pick it up"
  fi
}

apply_claude() {
  if ! have omarchy-theme-set-claude; then
    warn "omarchy-theme-set-claude is not available"
    return 1
  fi
  run omarchy-theme-set-claude --activate
  applied "set Claude Code to custom:omarchy"
}

apply_pi() {
  if ! have omarchy-theme-set-pi; then
    warn "omarchy-theme-set-pi is not available"
    return 1
  fi
  run omarchy-theme-set-pi --activate
  applied "set Pi to omarchy-system"
}

apply_opencode() {
  local cfg="$HOME/.config/opencode/cli.json"

  if [[ ! -f "$cfg" ]]; then
    warn "no opencode config at $cfg"
    return 0
  fi

  if have jq && jq -e '.theme.name == "system"' "$cfg" >/dev/null 2>&1; then
    skip "already follows the terminal"
    return 0
  fi

  if (( DRY_RUN )); then
    ok "would set theme.name = \"system\" in $cfg"
    return 0
  fi

  local b
  b="$(backup "$cfg")"
  note "backup: $b"

  local tmp
  tmp="$(mktemp)"
  if have jq; then
    jq '.theme.name = "system"' "$cfg" >"$tmp" && mv "$tmp" "$cfg"
  else
    python3 - "$cfg" <<'PY'
import json, sys
path = sys.argv[1]
data = json.load(open(path, encoding="utf-8"))
data.setdefault("theme", {})["name"] = "system"
json.dump(data, open(path, "w", encoding="utf-8"), indent=2)
open(path, "a", encoding="utf-8").write("\n")
PY
  fi
  ok "opencode follows the terminal palette"
}

apply_codex() {
  skip "Codex has no theme system; it inherits the terminal's ANSI palette"
  note "nothing to install"
}

apply_obsidian() {
  have omarchy-theme-set-obsidian || { warn "omarchy-theme-set-obsidian is not available"; return 1; }
  run omarchy-theme-set-obsidian
  applied "update every Obsidian vault"
}

apply_hermes() {
  have omarchy-theme-set-hermes || { warn "omarchy-theme-set-hermes is not available"; return 1; }
  run omarchy-theme-set-hermes --activate
  applied "activate the Hermes skin"
}

apply_t3code() {
  have omarchy-theme-set-t3code || { warn "omarchy-theme-set-t3code is not available"; return 1; }
  run omarchy-theme-set-t3code
  applied "write the T3 Code theme"
}

apply_slack() {
  have omarchy-theme-set-slack || { warn "omarchy-theme-set-slack is not available"; return 1; }
  run omarchy-theme-set-slack
  applied "write the Slack theme"
}

apply() {
  case "$1" in
    nvim)     apply_nvim ;;
    zed)      apply_zed ;;
    vscode)   apply_vscode ;;
    herdr-app) apply_herdr_app ;;
    herdr)    apply_herdr ;;
    claude)   apply_claude ;;
    pi)       apply_pi ;;
    opencode) apply_opencode ;;
    codex)    apply_codex ;;
    obsidian) apply_obsidian ;;
    hermes)   apply_hermes ;;
    t3code)   apply_t3code ;;
    slack)    apply_slack ;;
  esac
}

# ---------------------------------------------------------------- main

printf '\n%sNoir Dawn — editors and agents%s\n' "$B" "$N"
(( DRY_RUN )) && note "dry run: nothing will be written"
printf '\n'

found=0
for id in "${APPS[@]}"; do
  if [[ -n "$ONLY" && ",$ONLY," != *",$id,"* ]]; then
    continue
  fi

  if ! detect "$id"; then
    (( LIST_ONLY )) && skip "$(label "$id") — not installed"
    continue
  fi

  found=$((found + 1))
  printf '%s%s%s\n' "$B" "$(label "$id")" "$N"
  note "$(describe "$id")"

  if (( LIST_ONLY )); then
    ok "detected"
    printf '\n'
    continue
  fi

  if ! ask "Apply?"; then
    skip "skipped"
    printf '\n'
    continue
  fi

  if apply "$id"; then :; else FAILED+=("$(label "$id")"); fi
  printf '\n'
done

if (( found == 0 )); then
  if [[ -n "$ONLY" ]]; then
    warn "none of the requested apps were found: $ONLY"
  else
    warn "no supported editors or agents found"
  fi
fi

if (( ${#FAILED[@]} )); then
  printf '%sfailed:%s %s\n' "$R" "$N" "${FAILED[*]}"
  exit 1
fi

printf '%sdone.%s\n' "$G" "$N"
