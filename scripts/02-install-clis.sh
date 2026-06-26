#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/ask.sh"

[ -f /tmp/claude-setup-env.sh ] && source /tmp/claude-setup-env.sh

log_step "02" "Installation des CLIs"

install_brew_pkg() {
  local pkg="$1"
  if command -v brew >/dev/null 2>&1; then
    brew install "$pkg" >/dev/null 2>&1 && log_ok "$pkg installé" || log_warn "$pkg : échec brew"
  else
    log_warn "$pkg : brew absent — installation manuelle requise"
  fi
}

install_npm_global() {
  local pkg="$1" bin="$2"
  if ! command -v npm >/dev/null 2>&1; then
    log_warn "$bin : npm absent"
    return 0
  fi
  npm install -g "$pkg" >/dev/null 2>&1 && log_ok "$bin installé" || log_warn "$bin : échec npm"
}

# jq
if ! command -v jq >/dev/null 2>&1; then
  log_info "Installation de jq…"
  install_brew_pkg jq
else
  log_skip "jq déjà installé"
fi

# Claude Code CLI
if ! command -v claude >/dev/null 2>&1; then
  log_info "Installation de Claude Code…"
  install_npm_global "@anthropic-ai/claude-code" "claude"
else
  log_skip "Claude Code déjà installé"
fi

log_done "CLIs prêts"
