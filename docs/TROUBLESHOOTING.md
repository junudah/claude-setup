# Troubleshooting

Les cas qui reviennent, et le fix.

---

## Installation

### `jq: command not found`

`jq` sert à lire/écrire les configs JSON en sécurité. `02-install-clis.sh` essaie de l'installer via Homebrew. Sans Homebrew :

```bash
# macOS
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install jq

# Linux (Debian/Ubuntu)
sudo apt-get install -y jq
```

Puis relance `bash install.sh`.

---

### Le clone d'`anthropics/skills` ou `agency-agents` échoue

- Pas de réseau → relance plus tard, le script ne casse rien.
- Rate limit GitHub anonyme → attends quelques minutes, ou configure un token :
  `git config --global url."https://<TON_PAT>@github.com/".insteadOf "https://github.com/"`.

---

### `npm: command not found`

Node est requis pour Claude Code, Playwright et opencli.

```bash
brew install node        # macOS
# ou nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && nvm install 22
```

`opencli` demande **Node ≥ 21**.

---

## Navigateur

### `playwright: command not found`

```bash
npm install -g playwright
playwright install chromium
```

### Playwright ne trouve pas de navigateur

Le binaire est installé, pas les navigateurs :

```bash
playwright install chromium
```

### `opencli` ne renvoie rien / timeout

Trois choses à vérifier, dans l'ordre :

1. Le daemon tourne : `opencli init`.
2. L'extension Chrome est chargée (Chrome → Extensions → Mode développeur → Charger l'extension non empaquetée).
3. Tu es bien connecté au site visé dans ce Chrome — `opencli` réutilise ta session, il ne se logue pas à ta place.

### Je veux quand même le MCP Playwright

Ce setup ne l'installe pas volontairement (voir `docs/ARCHITECTURE.md`). Si tu y tiens :

```bash
claude mcp add playwright -- npx -y @playwright/mcp@latest
```

---

## Clés API

### Le keystore ne se charge pas dans Claude Code

`~/second-brain/00-system/secrets/keystore.env` n'est pas chargé tout seul. Ajoute à ton `~/.zshrc` :

```bash
[ -f "$HOME/second-brain/00-system/secrets/keystore.env" ] && source "$HOME/second-brain/00-system/secrets/keystore.env"
```

Puis `source ~/.zshrc`.

### Permission denied sur `keystore.env`

```bash
chmod 700 ~/second-brain/00-system/secrets
chmod 600 ~/second-brain/00-system/secrets/keystore.env
```

---

## Mémoire automatique

### `memory/log.md` reste vide

1. La clé `ANTHROPIC_API_KEY` doit être dans le keystore (c'est elle qui paie l'extraction).
2. Le hook doit être déclaré : vérifie `~/second-brain/.claude/settings.json`, section `hooks.Stop`.
3. Le fichier doit être exécutable : `chmod +x ~/second-brain/hooks/memory-logger.py`.
4. Le hook ne tourne que si la session a démarré **dans** `~/second-brain/`.

---

## Agent perso

### L'agent ignore son `soul.md`

Vérifie que `~/second-brain/CLAUDE.md` pointe bien vers `agents/<id>/soul.md`, et que ta session Claude Code démarre dans `~/second-brain/`.

### Changer le ton de l'agent

Édite la section `## Communication` de `~/second-brain/agents/<id>/soul.md`. Rien d'autre à relancer.

---

## Reset complet

Efface le Second Cerveau — fais un backup avant :

```bash
cp -r ~/second-brain ~/second-brain.backup.$(date +%s)
rm -rf ~/second-brain ~/.claude/agents
bash <(curl -fsSL https://raw.githubusercontent.com/junudah/claude-setup/main/install.sh)
```
