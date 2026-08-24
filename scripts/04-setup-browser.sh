#!/usr/bin/env bash
# 04-setup-browser.sh — Automatisation navigateur en CLI : playwright + opencli
# Pas de serveur MCP : une CLI ne coûte rien tant que l'agent ne l'appelle pas.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/ask.sh"

log_step "04" "Automatisation navigateur (Playwright CLI + opencli)"

if ! command -v npm >/dev/null 2>&1; then
  log_warn "npm absent — étape skippée (installe Node : brew install node)"
  exit 0
fi

# 1) Playwright CLI — navigateur propre, headless, screenshots
if command -v playwright >/dev/null 2>&1; then
  log_skip "playwright déjà installé"
else
  if ask_yes_no "Installer Playwright CLI (navigateur pilotable) ?" "y"; then
    if npm install -g playwright >/dev/null 2>&1; then
      log_ok "playwright installé"
      log_info "Téléchargement de Chromium…"
      playwright install chromium >/dev/null 2>&1 \
        && log_ok "Chromium installé" \
        || log_warn "Chromium : échec — relance 'playwright install chromium'"
    else
      log_warn "playwright : échec npm"
    fi
  else
    log_skip "playwright skippé"
  fi
fi

# 2) opencli — pilote les sites où tu es DÉJÀ connecté, via ton Chrome
if command -v opencli >/dev/null 2>&1; then
  log_skip "opencli déjà installé"
else
  if ask_yes_no "Installer opencli (Instagram, X, GitHub… via ta session Chrome) ?" "y"; then
    NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)"
    if [ "$NODE_MAJOR" -lt 21 ]; then
      log_warn "opencli demande Node >= 21 (tu as v$NODE_MAJOR) — skippé"
    elif npm install -g @jackwener/opencli >/dev/null 2>&1; then
      log_ok "opencli installé"
    else
      log_warn "opencli : échec npm"
    fi
  else
    log_skip "opencli skippé"
  fi
fi

if command -v opencli >/dev/null 2>&1; then
  echo ""
  log_info "Pour activer opencli : 'opencli init', puis charge l'extension Chrome"
  log_info "(Chrome > Extensions > Mode développeur > Charger l'extension non empaquetée)"
fi

log_done "Navigateur prêt"
