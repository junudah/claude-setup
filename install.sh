#!/usr/bin/env bash
# install.sh — Claude Setup by Rayan (@rayuqi)
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/junudah/claude-setup/main/install.sh)
#   or:  bash install.sh   (après git clone)

set -euo pipefail

if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  SCRIPT_DIR="$(mktemp -d)"
  echo "==> Téléchargement de claude-setup…"
  git clone --depth 1 https://github.com/junudah/claude-setup.git "$SCRIPT_DIR" >/dev/null 2>&1 || {
    echo "ERR: clone échoué" >&2; exit 1
  }
fi

source "$SCRIPT_DIR/scripts/lib/colors.sh"
source "$SCRIPT_DIR/scripts/lib/log.sh"
source "$SCRIPT_DIR/scripts/lib/ask.sh"

trap 'log_err "Échec à la ligne $LINENO."' ERR

clear
cat <<'EOF'

  ╔═══════════════════════════════════════════╗
  ║     Claude Setup — Second Cerveau IA      ║
  ║          by Rayan · @rayuqi               ║
  ╚═══════════════════════════════════════════╝

EOF

printf "${C_BCYAN}Configure ton Second Cerveau en 5 minutes — Claude Code, Codex ou Cursor.${C_RESET}\n\n"

if ! ask_yes_no "On commence ?" "y"; then
  echo "Bye."
  exit 0
fi

# Reset env temp
rm -f /tmp/claude-setup-env.sh
touch /tmp/claude-setup-env.sh

bash "$SCRIPT_DIR/scripts/00-detect-system.sh"
bash "$SCRIPT_DIR/scripts/01-init-second-brain.sh"
bash "$SCRIPT_DIR/scripts/02-install-clis.sh"
bash "$SCRIPT_DIR/scripts/03-install-skills.sh"
bash "$SCRIPT_DIR/scripts/04-setup-browser.sh"
bash "$SCRIPT_DIR/scripts/05-collect-keys.sh"
bash "$SCRIPT_DIR/scripts/06-create-agent.sh"

[ -f /tmp/claude-setup-env.sh ] && source /tmp/claude-setup-env.sh

BRAIN_PATH="${CS_BRAIN_PATH:-$HOME/second-brain}"

log_section "SETUP TERMINÉ"

cat <<EOF

  Second Cerveau  : $BRAIN_PATH/
  Instructions    : $BRAIN_PATH/AGENTS.md (+ CLAUDE.md qui pointe dessus)
  Agents branchés : ${CS_AGENTS:-aucun}
  Skills          : $BRAIN_PATH/skills/anthropics/ + agency-agents/
  Navigateur      : playwright + opencli (CLI, aucun MCP)
  Agent perso     : ${CS_AGENT_ID:-aucun}

  ─────────────────────────────────────────

  Pour démarrer, depuis $BRAIN_PATH :
    claude          (lit CLAUDE.md → AGENTS.md)
    codex           (lit AGENTS.md)
    cursor .        (lit AGENTS.md)

  Ton agent connaîtra ton business dès la première phrase.

EOF
