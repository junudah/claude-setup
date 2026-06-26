# Claude Setup — Second Cerveau IA

Configure Claude Code avec une mémoire long terme sur ton business en moins de 5 minutes.

by **Rayan** · [@rayuqi](https://youtube.com/@rayuqi)

---

## Ce que ça installe

- **Second Cerveau** (`~/second-brain/`) — dossier que Claude Code lit à chaque session
- **user.md** — ton profil business, tes outils, ta stack
- **CLAUDE.md** — instructions de session personnalisées
- **anthropics/skills** — skills officiels Anthropic
- **agency-agents** — 32 sub-agents spécialisés
- **GitHub CLI** (`gh`) — si pas déjà installé
- **MCP Playwright** — automatisation navigateur

## Option 1 — Via Claude Code (recommandé)

Colle cette URL dans Claude Code :

```
https://github.com/junudah/claude-setup.git
```

Claude Code pose 4 questions et configure tout automatiquement.

## Option 2 — Script bash

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/junudah/claude-setup/main/install.sh)
```

## Prérequis

- macOS
- [Homebrew](https://brew.sh)
- [Claude Code](https://docs.anthropic.com/claude-code) (ou il s'installe via le script)

## Après l'installation

```bash
cd ~/second-brain && claude
```

Claude Code connaît ton business dès la première phrase.

---

## Structure créée

```
~/second-brain/
├── CLAUDE.md          ← point d'entrée (relu à chaque session)
├── user.md            ← ton profil
├── environment.md     ← ta stack et tes outils
├── skills/
│   ├── anthropics/    ← skills officiels Anthropic
│   └── agency-agents/ ← sub-agents spécialisés
├── projects/          ← notes par projet
├── memory/            ← mémoire long terme
└── secrets/           ← clés API (local uniquement, jamais commité)
```
