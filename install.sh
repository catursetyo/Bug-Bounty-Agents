#!/usr/bin/env bash
# Bug-Bounty-Agents installer
# Auto-detects supported LLM clients and installs agent prompts in the right place.
#
# Usage:
#   ./install.sh                # interactive: detect + ask
#   ./install.sh --target claude         # force claude code (global)
#   ./install.sh --target claude-local   # claude code, current project
#   ./install.sh --target copilot        # github copilot chat (vs code)
#   ./install.sh --target cursor         # cursor (current project)
<<<<<<< HEAD
=======
#   ./install.sh --target opencode       # opencode (global)
#   ./install.sh --target opencode-local # opencode, current project
>>>>>>> fd88053 (feat: add compatibility to opencode (oh my opencode))
#   ./install.sh --target all            # install everywhere detected
#   ./install.sh --dry-run               # show what would happen
#   ./install.sh --uninstall --target X  # remove agents from target

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
UNINSTALL=0
TARGET=""

# ---- helpers ----------------------------------------------------------------

c_reset=$'\033[0m'
c_bold=$'\033[1m'
c_dim=$'\033[2m'
c_red=$'\033[31m'
c_green=$'\033[32m'
c_yellow=$'\033[33m'
c_blue=$'\033[34m'

log()  { printf '%s\n' "$*"; }
info() { printf '%b\n' "${c_blue}info${c_reset}  $*"; }
ok()   { printf '%b\n' "${c_green}ok${c_reset}    $*"; }
warn() { printf '%b\n' "${c_yellow}warn${c_reset}  $*"; }
err()  { printf '%b\n' "${c_red}error${c_reset} $*" >&2; }

run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '%b%s%b\n' "${c_dim}" "[dry-run] $*" "${c_reset}"
  else
<<<<<<< HEAD
    eval "$@"
=======
    "$@"
>>>>>>> fd88053 (feat: add compatibility to opencode (oh my opencode))
  fi
}

usage() {
<<<<<<< HEAD
  sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
=======
  awk 'NR==1{next} /^#/{sub(/^# ?/, ""); print; next} {exit}' "$0"
>>>>>>> fd88053 (feat: add compatibility to opencode (oh my opencode))
  exit 0
}

# ---- arg parsing ------------------------------------------------------------

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)    TARGET="${2:-}"; shift 2 ;;
    --dry-run)   DRY_RUN=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    -h|--help)   usage ;;
    *) err "unknown arg: $1"; usage ;;
  esac
done

# ---- platform paths ---------------------------------------------------------

os="$(uname -s)"
case "$os" in
  Darwin) COPILOT_PROMPTS="$HOME/Library/Application Support/Code/User/prompts" ;;
  Linux)  COPILOT_PROMPTS="$HOME/.config/Code/User/prompts" ;;
  *)      COPILOT_PROMPTS="$HOME/.config/Code/User/prompts" ;;
esac

CLAUDE_GLOBAL="$HOME/.claude/agents"
CLAUDE_LOCAL=".claude/agents"
CURSOR_LOCAL=".cursor/rules"
<<<<<<< HEAD
=======
OPENCODE_GLOBAL="$HOME/.config/opencode/agents"
OPENCODE_LOCAL=".opencode/agents"

# OpenCode v1 uses a `permission` map with `bash`; v2 replaces it with a
# `permissions` rule list using `shell`. Pick the schema matching the install.
OPENCODE_FMT="v1"
if command -v opencode >/dev/null 2>&1; then
  OPENCODE_VERSION="$(opencode --version 2>/dev/null)"
  case "$OPENCODE_VERSION" in
    2*|"opencode 2"*) OPENCODE_FMT="v2" ;;
  esac
fi
>>>>>>> fd88053 (feat: add compatibility to opencode (oh my opencode))

# ---- detection --------------------------------------------------------------

detect() {
  local found=()
<<<<<<< HEAD
  command -v claude  >/dev/null 2>&1 && found+=("claude")
  command -v code    >/dev/null 2>&1 && found+=("copilot")
  command -v cursor  >/dev/null 2>&1 && found+=("cursor")
=======
  command -v claude   >/dev/null 2>&1 && found+=("claude")
  command -v code     >/dev/null 2>&1 && found+=("copilot")
  command -v cursor   >/dev/null 2>&1 && found+=("cursor")
  command -v opencode >/dev/null 2>&1 && found+=("opencode")
>>>>>>> fd88053 (feat: add compatibility to opencode (oh my opencode))
  printf '%s\n' "${found[@]:-}"
}

# ---- install / uninstall actions -------------------------------------------

agent_files() {
  # All top-level agent .md files except README/AGENTS/CHANGELOG/etc.
  find "$SCRIPT_DIR" -maxdepth 1 -type f -name '*.md' \
    ! -name 'README.md' \
    ! -name 'AGENTS.md' \
    ! -name 'CHANGELOG.md' \
    ! -name 'CONTRIBUTING.md' \
    ! -name 'SECURITY.md'
}

install_to_dir() {
  local dest="$1" suffix="${2:-}"
<<<<<<< HEAD
  run "mkdir -p \"$dest\""
=======
  run mkdir -p "$dest"
>>>>>>> fd88053 (feat: add compatibility to opencode (oh my opencode))
  local count=0
  while IFS= read -r f; do
    local base; base="$(basename "$f")"
    local out="$dest/${base%.md}${suffix}"
<<<<<<< HEAD
    run "cp \"$f\" \"$out\""
=======
    run cp "$f" "$out"
>>>>>>> fd88053 (feat: add compatibility to opencode (oh my opencode))
    count=$((count + 1))
  done < <(agent_files)
  ok "installed $count agents → $dest"
}

uninstall_from_dir() {
  local dest="$1" suffix="${2:-}"
  if [[ ! -d "$dest" ]]; then warn "nothing to uninstall at $dest"; return; fi
  local count=0
  while IFS= read -r f; do
    local base; base="$(basename "$f")"
    local out="$dest/${base%.md}${suffix}"
<<<<<<< HEAD
    if [[ -f "$out" ]]; then run "rm \"$out\""; count=$((count + 1)); fi
=======
    if [[ -f "$out" ]]; then run rm "$out"; count=$((count + 1)); fi
>>>>>>> fd88053 (feat: add compatibility to opencode (oh my opencode))
  done < <(agent_files)
  ok "removed $count agents from $dest"
}

<<<<<<< HEAD
=======
# ---- opencode frontmatter conversion ---------------------------------------
#
# OpenCode agent files differ from Claude Code's:
#   - the agent name comes from the file name (a `name:` key would be passed
#     through to the provider as a model option)
#   - `model:` expects provider/model-id (the `sonnet` alias is invalid), and
#     unset means "inherit the invoking agent's model"
#   - tool lists are replaced by permissions (`permission` map in v1,
#     `permissions` rule list with `shell` instead of `bash` in v2)
#   - agents need an explicit `mode:` (v2 defaults new agents to `primary`)
#
# opencode_transform() rewrites one Claude Code agent file into a valid
# OpenCode agent: description is kept verbatim, name/model are dropped, the
# tools list becomes permissions, and mode is set to subagent. Interactive
# tools stay "ask" so every command against a target keeps its approval
# prompt, mirroring Claude Code's permission behavior.

opencode_transform() {
  awk -v fmt="$OPENCODE_FMT" '
    function maptool(t) {
      k = ""; e = ""
      if (t == "Bash")          { k = (fmt == "v2" ? "shell" : "bash"); e = "ask" }
      else if (t == "Read")     { k = "read";      e = "allow" }
      else if (t == "Write" || t == "Edit") { k = "edit"; e = "ask" }
      else if (t == "Grep")     { k = "grep";      e = "allow" }
      else if (t == "Glob")     { k = "glob";      e = "allow" }
      else if (t == "WebFetch") { k = "webfetch";  e = "ask" }
      else if (t == "WebSearch"){ k = "websearch"; e = "allow" }
      else if (t == "Task")     { k = (fmt == "v2" ? "subagent" : "task"); e = "allow" }
      else printf "opencode: %s: unmapped tool \"%s\"\n", FILENAME, t > "/dev/stderr"
      if (k != "" && !(k in seen)) { seen[k] = 1; key[++n] = k; eff[n] = e }
    }
    BEGIN { state = "pre"; lastkey = ""; n = 0 }
    state == "pre" && FNR == 1 && /^---[[:space:]]*$/ { print; state = "fm"; next }
    state == "pre" { print; next }
    state == "fm" && /^---[[:space:]]*$/ {
      print "mode: subagent"
      if (n > 0) {
        print (fmt == "v2" ? "permissions:" : "permission:")
        for (i = 1; i <= n; i++) {
          if (fmt == "v2")
            printf "  - action: %s\n    resource: \"*\"\n    effect: %s\n", key[i], eff[i]
          else
            printf "  %s: %s\n", key[i], eff[i]
        }
      }
      print; state = "body"; next
    }
    state == "fm" && /^description:/ { print; lastkey = "description"; next }
    state == "fm" && /^tools:/ {
      lastkey = "tools"
      if (match($0, /\[.*\]/)) {
        m = split(substr($0, RSTART + 1, RLENGTH - 2), arr, ",")
        for (j = 1; j <= m; j++) {
          t = arr[j]
          gsub(/[[:space:]]+/, "", t)
          maptool(t)
        }
      }
      next
    }
    state == "fm" && /^(name|model):/ { lastkey = ""; next }
    state == "fm" && lastkey == "tools" && /^[[:space:]]*-[[:space:]]+/ {
      t = $0
      sub(/^[[:space:]]*-[[:space:]]+/, "", t)
      sub(/[[:space:]]+$/, "", t)
      maptool(t)
      next
    }
    state == "fm" && lastkey == "description" && /^[[:space:]]/ { print; next }
    state == "fm" && /^[[:space:]]*$/ { next }
    state == "fm" {
      printf "opencode: %s: dropping unsupported line \"%s\"\n", FILENAME, $1 > "/dev/stderr"
      next
    }
    { print }
  ' "$1" > "$2"
}

install_opencode_to_dir() {
  local dest="$1"
  run mkdir -p "$dest"
  local count=0
  while IFS= read -r f; do
    local base; base="$(basename "$f")"
    local stem="${base%.md}"
    if [[ "$stem" == _* ]]; then
      # Underscore-prefixed files are shared prompt layers, not standalone
      # agents; OpenCode requires a description frontmatter for every agent.
      info "skipped $base (shared prompt layer, not a standalone agent)"
      continue
    fi
    run opencode_transform "$f" "$dest/$stem.md"
    count=$((count + 1))
  done < <(agent_files)
  ok "installed $count agents → $dest (opencode $OPENCODE_FMT frontmatter)"
}

>>>>>>> fd88053 (feat: add compatibility to opencode (oh my opencode))
apply() {
  local target="$1"
  local action="install"; [[ $UNINSTALL -eq 1 ]] && action="uninstall"
  case "$target" in
    claude)
      info "$action: Claude Code (global) → $CLAUDE_GLOBAL"
<<<<<<< HEAD
      [[ $UNINSTALL -eq 1 ]] && uninstall_from_dir "$CLAUDE_GLOBAL" ".md" \
                             || install_to_dir   "$CLAUDE_GLOBAL" ".md"
      ;;
    claude-local)
      info "$action: Claude Code (project) → $CLAUDE_LOCAL"
      [[ $UNINSTALL -eq 1 ]] && uninstall_from_dir "$CLAUDE_LOCAL" ".md" \
                             || install_to_dir   "$CLAUDE_LOCAL" ".md"
      ;;
    copilot)
      info "$action: GitHub Copilot Chat → $COPILOT_PROMPTS"
      [[ $UNINSTALL -eq 1 ]] && uninstall_from_dir "$COPILOT_PROMPTS" ".chatmode.md" \
                             || install_to_dir   "$COPILOT_PROMPTS" ".chatmode.md"
      ;;
    cursor)
      info "$action: Cursor (project) → $CURSOR_LOCAL"
      [[ $UNINSTALL -eq 1 ]] && uninstall_from_dir "$CURSOR_LOCAL" ".md" \
                             || install_to_dir   "$CURSOR_LOCAL" ".md"
=======
      if [[ $UNINSTALL -eq 1 ]]; then
        uninstall_from_dir "$CLAUDE_GLOBAL" ".md"
      else
        install_to_dir "$CLAUDE_GLOBAL" ".md"
      fi
      ;;
    claude-local)
      info "$action: Claude Code (project) → $CLAUDE_LOCAL"
      if [[ $UNINSTALL -eq 1 ]]; then
        uninstall_from_dir "$CLAUDE_LOCAL" ".md"
      else
        install_to_dir "$CLAUDE_LOCAL" ".md"
      fi
      ;;
    copilot)
      info "$action: GitHub Copilot Chat → $COPILOT_PROMPTS"
      if [[ $UNINSTALL -eq 1 ]]; then
        uninstall_from_dir "$COPILOT_PROMPTS" ".chatmode.md"
      else
        install_to_dir "$COPILOT_PROMPTS" ".chatmode.md"
      fi
      ;;
    cursor)
      info "$action: Cursor (project) → $CURSOR_LOCAL"
      if [[ $UNINSTALL -eq 1 ]]; then
        uninstall_from_dir "$CURSOR_LOCAL" ".md"
      else
        install_to_dir "$CURSOR_LOCAL" ".md"
      fi
      ;;
    opencode)
      info "$action: OpenCode (global) → $OPENCODE_GLOBAL"
      if [[ $UNINSTALL -eq 1 ]]; then
        uninstall_from_dir "$OPENCODE_GLOBAL" ".md"
      else
        install_opencode_to_dir "$OPENCODE_GLOBAL"
      fi
      ;;
    opencode-local)
      info "$action: OpenCode (project) → $OPENCODE_LOCAL"
      if [[ $UNINSTALL -eq 1 ]]; then
        uninstall_from_dir "$OPENCODE_LOCAL" ".md"
      else
        install_opencode_to_dir "$OPENCODE_LOCAL"
      fi
>>>>>>> fd88053 (feat: add compatibility to opencode (oh my opencode))
      ;;
    *) err "unknown target: $target"; exit 1 ;;
  esac
}

# ---- main -------------------------------------------------------------------

log "${c_bold}Bug-Bounty-Agents installer${c_reset}"
log ""

if [[ -n "$TARGET" ]]; then
  if [[ "$TARGET" == "all" ]]; then
    mapfile -t found < <(detect)
    [[ ${#found[@]} -eq 0 ]] && { err "no supported clients detected"; exit 1; }
    for t in "${found[@]}"; do apply "$t"; done
  else
    apply "$TARGET"
  fi
  exit 0
fi

# interactive
mapfile -t found < <(detect)
if [[ ${#found[@]} -eq 0 ]]; then
<<<<<<< HEAD
  warn "no clients auto-detected (claude, code, cursor not in PATH)"
=======
  warn "no clients auto-detected (claude, code, cursor, opencode not in PATH)"
>>>>>>> fd88053 (feat: add compatibility to opencode (oh my opencode))
  log "Pick a target manually:"
  log "  ./install.sh --target claude         (Claude Code global)"
  log "  ./install.sh --target claude-local   (Claude Code project)"
  log "  ./install.sh --target copilot        (Copilot Chat)"
  log "  ./install.sh --target cursor         (Cursor project)"
<<<<<<< HEAD
=======
  log "  ./install.sh --target opencode       (OpenCode global)"
  log "  ./install.sh --target opencode-local (OpenCode project)"
>>>>>>> fd88053 (feat: add compatibility to opencode (oh my opencode))
  exit 1
fi

info "detected clients: ${found[*]}"
read -r -p "Install for all detected clients? [Y/n] " ans
ans="${ans:-Y}"
if [[ "$ans" =~ ^[Yy]$ ]]; then
  for t in "${found[@]}"; do apply "$t"; done
else
  log "Aborted. Re-run with --target <name>."
fi
