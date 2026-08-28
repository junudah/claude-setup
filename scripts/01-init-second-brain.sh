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
# une seule ligne par valeur : sed casse sur un retour à la ligne
NODE_VAL="$(node --version 2>/dev/null || echo 'non installé')"
PYTHON_VAL="$(python3 --version 2>/dev/null || echo 'non installé')"

sed -e "s|{{OS}}|$OS_VAL|g" \
    -e "s|{{ARCH}}|$ARCH_VAL|g" \
    -e "s|{{SHELL}}|$SHELL_VAL|g" \
    -e "s|{{NODE}}|$NODE_VAL|g" \
    -e "s|{{PYTHON}}|$PYTHON_VAL|g" \
    -e "s|{{BRAIN_PATH}}|$BRAIN_PATH|g" \
    "$TEMPLATES_DIR/environment.md" > "$BRAIN_PATH/environment.md"
log_ok "environment.md créé"

# AGENTS.md = le seul fichier d'instructions. Claude Code lit CLAUDE.md, Codex et Cursor lisent
# AGENTS.md : on écrit l'un et on pointe l'autre dessus, jamais deux copies à maintenir.
sed -e "s|{{NAME}}|$USER_NAME|g" \
    -e "s|{{BRAIN_PATH}}|$BRAIN_PATH|g" \
    "$TEMPLATES_DIR/AGENTS.md" > "$BRAIN_PATH/AGENTS.md"
printf '@AGENTS.md\n' > "$BRAIN_PATH/CLAUDE.md"
log_ok "AGENTS.md créé (Claude Code · Codex · Cursor) + CLAUDE.md qui pointe dessus"

# Templates identité et objectifs (fichiers vides prêts à remplir)
for tpl in 01-identity/profil.md 01-identity/voix.md 02-goals/objectifs.md; do
  sed "s|{{NAME}}|$USER_NAME|g" "$TEMPLATES_DIR/$tpl" > "$BRAIN_PATH/$tpl"
done
log_ok "01-identity/ et 02-goals/ créés"

# Hook mémoire automatique — Claude Code seulement (Codex et Cursor n'ont pas de hook Stop)
if [[ " ${CS_AGENTS:-claude} " == *" claude "* ]]; then
  cp "$SCRIPT_DIR/../hooks/memory-logger.py" "$BRAIN_PATH/hooks/memory-logger.py"
  chmod +x "$BRAIN_PATH/hooks/memory-logger.py"
  sed -e "s|{{BRAIN_PATH}}|$BRAIN_PATH|g" \
      "$TEMPLATES_DIR/settings.json" > "$BRAIN_PATH/.claude/settings.json"
  log_ok "Hook Stop configuré → memory/log.md après chaque session"
else
  log_skip "Mémoire auto : Claude Code seulement — sur Codex/Cursor, écris dans memory/ à la main."
fi

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
