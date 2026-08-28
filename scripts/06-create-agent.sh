#!/usr/bin/env bash
# 06-create-agent.sh — Crée l'agent perso et son soul.md

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/ask.sh"

[ -f /tmp/claude-setup-env.sh ] && source /tmp/claude-setup-env.sh
BRAIN_PATH="${CS_BRAIN_PATH:-$HOME/second-brain}"
USER_NAME="${CS_USER_NAME:-toi}"

log_step "06" "Agent perso"

if ! ask_yes_no "Créer un agent perso (avec son soul.md) ?" "y"; then
  log_skip "Agent perso skippé"
  exit 0
fi

AGENT_ID="$(ask "Nom de l'agent" "bro")"
AGENT_ID="$(printf '%s' "$AGENT_ID" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_-')"
[ -z "$AGENT_ID" ] && AGENT_ID="bro"

AGENT_TONE="$(ask_choice_inline "Ton de l'agent" "formel direct cool" "direct")"

AGENT_DIR="$BRAIN_PATH/agents/$AGENT_ID"
if [ -f "$AGENT_DIR/soul.md" ]; then
  log_skip "Agent $AGENT_ID existe déjà — préservé"
  echo "export CS_AGENT_ID=\"$AGENT_ID\"" >> /tmp/claude-setup-env.sh
  exit 0
fi

case "$AGENT_TONE" in
  formel) TONE_DESC="Tu t'exprimes de façon professionnelle et structurée. Tu vouvoies." ;;
  cool)   TONE_DESC="Tu es détendu, complice, parfois drôle. Tu tutoies. Vocabulaire familier OK." ;;
  *)      TONE_DESC="Tu vas droit au but. Phrases courtes. Zéro filler. Tu tutoies." ;;
esac

mkdir -p "$AGENT_DIR"
sed -e "s|{{AGENT_ID}}|$AGENT_ID|g" \
    -e "s|{{USER_NAME}}|$USER_NAME|g" \
    -e "s|{{TONE}}|$AGENT_TONE|g" \
    -e "s|{{TONE_DESC}}|$TONE_DESC|g" \
    -e "s|{{BRAIN_PATH}}|$BRAIN_PATH|g" \
    "$SCRIPT_DIR/../templates/soul.md" > "$AGENT_DIR/soul.md"
log_ok "Agent $AGENT_ID créé : $AGENT_DIR/soul.md"

# AGENTS.md doit pointer vers le soul
if [ -f "$BRAIN_PATH/AGENTS.md" ] && ! grep -q "agents/$AGENT_ID/soul.md" "$BRAIN_PATH/AGENTS.md"; then
  printf '\n## Agent perso\n\nLis `agents/%s/soul.md` au démarrage — c'"'"'est ton identité sur ce Second Cerveau.\n' \
    "$AGENT_ID" >> "$BRAIN_PATH/AGENTS.md"
  log_ok "AGENTS.md pointe vers agents/$AGENT_ID/soul.md"
fi

echo "export CS_AGENT_ID=\"$AGENT_ID\"" >> /tmp/claude-setup-env.sh
log_done "Agent perso prêt"
