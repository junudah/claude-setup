#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/ask.sh"

[ -f /tmp/claude-setup-env.sh ] && source /tmp/claude-setup-env.sh
BRAIN_PATH="${CS_BRAIN_PATH:-$HOME/second-brain}"
KEYSTORE="$BRAIN_PATH/00-system/secrets/keystore.env"

log_step "05" "Clé API Anthropic (pour la mémoire automatique)"

if [ -f "$KEYSTORE" ] && grep -q "ANTHROPIC_API_KEY=" "$KEYSTORE" 2>/dev/null; then
  log_skip "Clé Anthropic déjà présente dans keystore.env"
  exit 0
fi

log_info "La mémoire automatique nécessite ta clé API Anthropic."
log_info "Tu la trouves sur : console.anthropic.com → API Keys"
echo ""

ANTHROPIC_KEY="$(ask "Colle ta clé Anthropic API (sk-ant-...)")"

if [ -z "$ANTHROPIC_KEY" ]; then
  log_warn "Clé vide — mémoire automatique désactivée (tu peux l'ajouter plus tard dans $KEYSTORE)"
  exit 0
fi

mkdir -p "$BRAIN_PATH/00-system/secrets"
chmod 700 "$BRAIN_PATH/00-system/secrets"
touch "$KEYSTORE"
chmod 600 "$KEYSTORE"

echo "ANTHROPIC_API_KEY=\"$ANTHROPIC_KEY\"" >> "$KEYSTORE"
log_ok "Clé sauvegardée dans $KEYSTORE (chmod 600)"

log_done "Clé API configurée"
