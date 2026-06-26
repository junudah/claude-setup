#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/colors.sh"
source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/ask.sh"

log_step "04" "Configuration MCP (Playwright)"

if ! ask_yes_no "Configurer le MCP Playwright (browser automation) ?" "y"; then
  log_skip "MCP skippé"
  exit 0
fi

if ! command -v npm >/dev/null 2>&1; then
  log_warn "npm absent — MCP skippé"
  exit 0
fi

CLAUDE_JSON="$HOME/.claude.json"

if [ ! -f "$CLAUDE_JSON" ]; then
  echo '{"mcpServers":{}}' > "$CLAUDE_JSON"
fi

if command -v jq >/dev/null 2>&1; then
  ALREADY=$(jq -r '.mcpServers.playwright // empty' "$CLAUDE_JSON" 2>/dev/null || echo "")
  if [ -n "$ALREADY" ]; then
    log_skip "MCP playwright déjà configuré"
    exit 0
  fi

  TMP=$(mktemp)
  jq '.mcpServers.playwright = {
    "command": "npx",
    "args": ["@playwright/mcp@latest"]
  }' "$CLAUDE_JSON" > "$TMP" && mv "$TMP" "$CLAUDE_JSON"
  log_ok "MCP playwright ajouté à ~/.claude.json"
else
  log_warn "jq absent — MCP non configuré automatiquement"
  log_info "Ajoute manuellement dans ~/.claude.json :"
  cat <<'EOF'
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
EOF
fi

log_done "MCP configuré"
