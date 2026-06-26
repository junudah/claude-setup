#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/ask.sh"

[ -f /tmp/claude-setup-env.sh ] && source /tmp/claude-setup-env.sh
BRAIN_PATH="${CS_BRAIN_PATH:-$HOME/second-brain}"

log_step "03" "Installation des skills"

if ! command -v git >/dev/null 2>&1; then
  log_err "git absent — étape skippée"
  exit 0
fi

mkdir -p "$BRAIN_PATH/skills" "$HOME/.claude/skills"

# 1) anthropics/skills
TARGET_ANTHROPIC="$BRAIN_PATH/skills/anthropics"
if [ -d "$TARGET_ANTHROPIC/.git" ]; then
  log_skip "anthropics/skills déjà cloné — pull"
  git -C "$TARGET_ANTHROPIC" pull --quiet 2>/dev/null || log_warn "pull échoué (offline ?)"
else
  log_info "Clone anthropics/skills…"
  if git clone --depth 1 https://github.com/anthropics/skills.git "$TARGET_ANTHROPIC" 2>/dev/null; then
    log_ok "anthropics/skills cloné ($(find "$TARGET_ANTHROPIC/skills" -maxdepth 1 -type d | wc -l | tr -d ' ') skills)"
  else
    log_warn "Clone échoué — vérifie ta connexion"
  fi
fi

# Symlink skills anthropic dans ~/.claude/skills si pas déjà là
if [ -d "$TARGET_ANTHROPIC/skills" ] && [ ! -L "$HOME/.claude/skills/anthropics" ]; then
  ln -sf "$TARGET_ANTHROPIC/skills" "$HOME/.claude/skills/anthropics"
  log_ok "Symlink ~/.claude/skills/anthropics → créé"
fi

# 2) agency-agents (sub-agents)
if ask_yes_no "Installer les sub-agents Agency (~/.claude/agents/) ?" "y"; then
  TARGET_AGENCY="$BRAIN_PATH/skills/agency-agents"
  if [ -d "$TARGET_AGENCY/.git" ]; then
    log_skip "agency-agents déjà cloné — pull"
    git -C "$TARGET_AGENCY" pull --quiet 2>/dev/null || log_warn "pull échoué"
  else
    log_info "Clone agency-agents…"
    if git clone --depth 1 https://github.com/msitarzewski/agency-agents.git "$TARGET_AGENCY" 2>/dev/null; then
      log_ok "agency-agents cloné"
    else
      log_warn "Clone échoué"
    fi
  fi

  if [ -d "$TARGET_AGENCY" ]; then
    mkdir -p "$HOME/.claude/agents"
    COUNT=0
    while IFS= read -r -d '' file; do
      base="$(basename "$file")"
      case "$base" in README*|LICENSE*|CONTRIBUTING*|CHANGELOG*) continue ;; esac
      cp "$file" "$HOME/.claude/agents/$base"
      COUNT=$((COUNT + 1))
    done < <(find "$TARGET_AGENCY" -type f -name "*.md" ! -path "*/.git/*" -print0)
    log_ok "$COUNT sub-agents copiés vers ~/.claude/agents/"
  fi
fi

log_done "Skills installés"
