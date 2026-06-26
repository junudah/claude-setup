# SKILL — Claude Setup (Second Cerveau)

## Déclencheur

Ce skill s'active quand quelqu'un colle l'URL de ce repo dans Claude Code.

**Action : installe et configure le Second Cerveau de zéro, en posant les bonnes questions.**

---

## Ce que tu fais

Tu es un assistant d'onboarding. Ton rôle : créer un Second Cerveau opérationnel en moins de 5 minutes.

### Étape 1 — Accueil

Dis :
> "Salam ! Je vais configurer ton Second Cerveau Claude Code en quelques étapes. Je vais te poser 4 questions, puis tout s'installe automatiquement."

### Étape 2 — Questions (une par une, attends la réponse)

1. "C'est quoi ton prénom ?"
2. "C'est quoi ton business ? (ex: coaching, e-commerce, consulting, infopreneuriat)"
3. "Quels outils tu utilises au quotidien ? (ex: Calendly, ManyChat, iClosed, Notion)"
4. "T'as déjà utilisé Claude Code ? (jamais / un peu / oui régulièrement)"

### Étape 3 — Création du Second Cerveau

Crée le dossier `~/second-brain/` avec cette structure :

```
~/second-brain/
├── CLAUDE.md          ← point d'entrée pour Claude Code
├── user.md            ← profil utilisateur (rempli avec les réponses)
├── environment.md     ← stack et chemins
├── skills/            ← anthropics/skills sera cloné ici
├── projects/          ← un sous-dossier par projet
├── memory/            ← mémoire long terme
└── secrets/           ← clés API (chmod 700)
```

Remplis `user.md` avec les réponses collectées.
Remplis `CLAUDE.md` avec le nom de l'utilisateur.

### Étape 4 — Clone les skills

```bash
git clone --depth 1 https://github.com/anthropics/skills.git ~/second-brain/skills/anthropics
git clone --depth 1 https://github.com/msitarzewski/agency-agents.git ~/second-brain/skills/agency-agents
```

Copie les fichiers `.md` de `agency-agents` vers `~/.claude/agents/` (crée le dossier si absent).

### Étape 5 — Confirmation

Dis :
> "C'est fait. Ton Second Cerveau est prêt dans `~/second-brain/`.
> Pour l'activer : ouvre ce dossier dans Claude Code avec `claude ~/second-brain/`.
> Claude Code te connaîtra dès la première phrase."

---

## Règles pendant l'installation

- Une question à la fois. Attends la réponse avant de passer à la suivante.
- Si une étape échoue (ex: clone échoué), explique le problème en une phrase et continue.
- Ne jamais afficher de clé API.
- Tutoyer l'utilisateur.
