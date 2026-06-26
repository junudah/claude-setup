#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/ask.sh"

[ -f /tmp/claude-setup-env.sh ] && source /tmp/claude-setup-env.sh

log_step "01" "Initialisation du Second Cerveau"

DEFAULT_BRAIN="$HOME/second-brain"
BRAIN_PATH="$(ask "Où créer ton Second Cerveau" "$DEFAULT_BRAIN")"
BRAIN_PATH="${BRAIN_PATH/#\~/$HOME}"

if [ -d "$BRAIN_PATH" ] && [ -f "$BRAIN_PATH/user.md" ]; then
  log_skip "Second Cerveau déjà présent à $BRAIN_PATH — préservé."
  echo "export CS_BRAIN_PATH=\"$BRAIN_PATH\"" >> /tmp/claude-setup-env.sh
  exit 0
fi

mkdir -p "$BRAIN_PATH/00-system"/{secrets,scripts}
mkdir -p "$BRAIN_PATH/01-identity"
mkdir -p "$BRAIN_PATH/02-goals"
mkdir -p "$BRAIN_PATH/10-projects"
mkdir -p "$BRAIN_PATH"/{inbox,90-archive,skills,hooks,memory,.claude}
chmod 700 "$BRAIN_PATH/00-system/secrets"
log_ok "Structure créée : $BRAIN_PATH"

TEMPLATES_DIR="$SCRIPT_DIR/../templates"

# Questions profil
USER_NAME="$(ask "Ton prénom")"
USER_BUSINESS="$(ask "Ton type de business (ex: coaching, e-com, infopreneuriat)")"
USER_TOOLS="$(ask "Tes outils principaux (ex: Calendly, iClosed, ManyChat)")"
USER_LEVEL="$(ask_choice_inline "Niveau Claude Code" "débutant intermédiaire avancé" "débutant")"
USER_PROFILE="$(ask_choice_inline "Ton profil" "lancement e-com scaling" "lancement")"

sed -e "s|{{NAME}}|$USER_NAME|g" \
    -e "s|{{BUSINESS}}|$USER_BUSINESS|g" \
    -e "s|{{TOOLS}}|$USER_TOOLS|g" \
    -e "s|{{LEVEL}}|$USER_LEVEL|g" \
    "$TEMPLATES_DIR/user.md" > "$BRAIN_PATH/user.md"
log_ok "user.md créé"

OS_VAL="${CS_OS:-$(uname -s)}"
ARCH_VAL="${CS_ARCH:-$(uname -m)}"
SHELL_VAL="${CS_SHELL:-$SHELL}"
NODE_VAL="$(command -v node 2>/dev/null && node --version 2>/dev/null || echo 'non installé')"
PYTHON_VAL="$(command -v python3 2>/dev/null && python3 --version 2>/dev/null || echo 'non installé')"

sed -e "s|{{OS}}|$OS_VAL|g" \
    -e "s|{{ARCH}}|$ARCH_VAL|g" \
    -e "s|{{SHELL}}|$SHELL_VAL|g" \
    -e "s|{{NODE}}|$NODE_VAL|g" \
    -e "s|{{PYTHON}}|$PYTHON_VAL|g" \
    -e "s|{{BRAIN_PATH}}|$BRAIN_PATH|g" \
    "$TEMPLATES_DIR/environment.md" > "$BRAIN_PATH/environment.md"
log_ok "environment.md créé"

sed -e "s|{{NAME}}|$USER_NAME|g" \
    -e "s|{{BRAIN_PATH}}|$BRAIN_PATH|g" \
    "$TEMPLATES_DIR/CLAUDE.md" > "$BRAIN_PATH/CLAUDE.md"
log_ok "CLAUDE.md créé"

# Templates identité et objectifs (fichiers vides prêts à remplir)
cp "$TEMPLATES_DIR/01-identity/profil.md" "$BRAIN_PATH/01-identity/profil.md"
cp "$TEMPLATES_DIR/01-identity/voix.md"   "$BRAIN_PATH/01-identity/voix.md"
cp "$TEMPLATES_DIR/02-goals/objectifs.md" "$BRAIN_PATH/02-goals/objectifs.md"
log_ok "01-identity/ et 02-goals/ créés"

# Hook mémoire automatique
cp "$SCRIPT_DIR/../hooks/memory-logger.py" "$BRAIN_PATH/hooks/memory-logger.py"
chmod +x "$BRAIN_PATH/hooks/memory-logger.py"
log_ok "memory-logger.py installé"

# settings.json Claude Code (active le hook Stop)
sed -e "s|{{BRAIN_PATH}}|$BRAIN_PATH|g" \
    "$TEMPLATES_DIR/settings.json" > "$BRAIN_PATH/.claude/settings.json"
log_ok "Hook Stop configuré → memory/log.md après chaque session"

# Dossiers 03-business selon le profil
case "$USER_PROFILE" in
  lancement)
    mkdir -p "$BRAIN_PATH/03-business"/{offre,icp,client}
    ;;
  e-com)
    mkdir -p "$BRAIN_PATH/03-business"/{offre,ads,shops}
    ;;
  scaling)
    mkdir -p "$BRAIN_PATH/03-business"/{offre,équipe,systemes,kpi,client}
    ;;
esac
log_ok "03-business/ créé pour le profil : $USER_PROFILE"

{
  echo "export CS_BRAIN_PATH=\"$BRAIN_PATH\""
  echo "export CS_USER_NAME=\"$USER_NAME\""
  echo "export CS_USER_PROFILE=\"$USER_PROFILE\""
} >> /tmp/claude-setup-env.sh

log_done "Second Cerveau initialisé"
