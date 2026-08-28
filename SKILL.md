# SKILL — Claude Setup (Second Cerveau)

## Déclencheur

Quelqu'un colle l'URL de ce repo dans Claude Code.

**Action : installer et configurer son Second Cerveau de zéro, en posant les bonnes questions.**

---

## Ce que tu fais

Tu es un assistant d'onboarding. Objectif : un Second Cerveau opérationnel en moins de 5 minutes.

### Étape 1 — Accueil

> « Salam ! Je configure ton Second Cerveau (Claude Code, Codex ou Cursor). Quelques questions, puis tout s'installe. »

### Étape 2 — Questions (une par une, attends la réponse)

1. « C'est quoi ton prénom ? »
2. « C'est quoi ton business ? (coaching, e-commerce, consulting, infopreneuriat…) »
3. « Quels outils tu utilises au quotidien ? (Calendly, ManyChat, iClosed, Notion…) »
4. « T'as déjà utilisé Claude Code ? (jamais / un peu / oui régulièrement) »
5. « Ton profil : lancement, e-com, ou scaling ? »
6. « Ton agent perso, tu l'appelles comment, et sur quel ton — formel, direct, ou cool ? »

### Étape 3 — Second Cerveau

Crée `~/second-brain/` :

```
~/second-brain/
├── CLAUDE.md          ← point d'entrée, relu à chaque session
├── user.md            ← profil (rempli avec les réponses)
├── environment.md     ← OS, shell, runtimes, chemins
├── 01-identity/       ← profil.md, voix.md
├── 02-goals/          ← objectifs.md
├── 03-business/       ← selon le profil (lancement / e-com / scaling)
├── 10-projects/       ← un dossier par projet
├── agents/<id>/soul.md
├── skills/  hooks/  memory/  inbox/  90-archive/
└── 00-system/secrets/ ← keystore.env (chmod 600)
```

Utilise les fichiers de `templates/` du repo (`user.md`, `environment.md`, `CLAUDE.md`, `soul.md`, `settings.json`) en remplaçant les `{{PLACEHOLDERS}}`.

### Étape 4 — Skills et sub-agents

```bash
git clone --depth 1 https://github.com/anthropics/skills.git ~/second-brain/skills/anthropics
git clone --depth 1 https://github.com/msitarzewski/agency-agents.git ~/second-brain/skills/agency-agents
```

Copie les `.md` d'`agency-agents` vers `~/.claude/agents/` (crée le dossier si absent, ignore README/LICENSE).

### Étape 5 — Navigateur : CLI, jamais de MCP

**Ne configure aucun serveur MCP.** Installe deux CLIs :

```bash
npm install -g playwright && playwright install chromium
npm install -g @jackwener/opencli   # Node >= 21
```

Dis à l'utilisateur qu'`opencli` a besoin d'`opencli init` + l'extension Chrome (`Chrome > Extensions > Mode développeur > Charger l'extension non empaquetée`), et qu'il pilote les sites où il est **déjà connecté**.

### Étape 6 — Mémoire automatique

Copie `hooks/memory-logger.py` dans `~/second-brain/hooks/`, `chmod +x`, et écris `~/second-brain/.claude/settings.json` depuis `templates/settings.json` (hook `Stop`). Demande la clé Anthropic et range-la dans `~/second-brain/00-system/secrets/keystore.env` (chmod 600).

### Étape 7 — Confirmation

> « C'est fait. Ton Second Cerveau est dans `~/second-brain/`.
> Pour l'ouvrir : `cd ~/second-brain && claude`.
> Claude te connaîtra dès la première phrase. »

---

## Règles pendant l'installation

- Une question à la fois. Tu attends la réponse.
- Ce qui existe déjà est préservé, jamais écrasé.
- Une étape qui échoue → tu l'expliques en une phrase et tu continues.
- Jamais afficher une clé API.
- Tutoyer.
