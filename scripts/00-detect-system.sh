#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/log.sh"

log_step "00" "Détection de l'environnement"

OS="$(uname -s)"
ARCH="$(uname -m)"
SHELL_BIN="${SHELL:-/bin/zsh}"

log_ok "OS : $OS ($ARCH)"
log_ok "Shell : $SHELL_BIN"

if [[ "$OS" != "Darwin" ]]; then
  log_warn "Ce script est optimisé pour macOS. Linux non testé."
fi

# Agents détectés — décide où le Second Cerveau se branche
AGENTS=""
command -v claude >/dev/null 2>&1 && AGENTS="$AGENTS claude"
command -v codex  >/dev/null 2>&1 && AGENTS="$AGENTS codex"
{ command -v cursor-agent >/dev/null 2>&1 || [ -d "$HOME/.cursor" ]; } && AGENTS="$AGENTS cursor"
AGENTS="${AGENTS# }"

if [ -z "$AGENTS" ]; then
  log_warn "Aucun agent détecté (claude / codex / cursor) — le Second Cerveau sera créé quand même."
else
  log_ok "Agents : $AGENTS"
fi

if ! command -v brew >/dev/null 2>&1; then
  log_warn "Homebrew absent — certaines installations seront skippées."
  log_info "Installe Homebrew : https://brew.sh"
fi

{
  echo "export CS_OS=\"$OS\""
  echo "export CS_ARCH=\"$ARCH\""
  echo "export CS_SHELL=\"$SHELL_BIN\""
  echo "export CS_AGENTS=\"$AGENTS\""
} >> /tmp/claude-setup-env.sh

log_done "Système détecté"
