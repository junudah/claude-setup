# Architecture — Claude Setup

Comment les pièces s'articulent une fois `install.sh` passé.

---

## Les 4 piliers

```
┌──────────────────────────────────────────────────────────────┐
│                     Claude Code Session                       │
│                                                               │
│   ┌────────────┐  ┌────────────┐  ┌─────────────────────┐   │
│   │   Skills   │  │ Sub-agents │  │    Browser CLIs     │   │
│   │ anthropics │  │  Agency +  │  │ playwright · opencli│   │
│   │ + les tiens│  │   perso    │  │                     │   │
│   └─────┬──────┘  └─────┬──────┘  └──────────┬──────────┘   │
│         │               │                     │              │
│         └───────────────┴─────────────────────┘              │
│                         │                                     │
│                         ▼                                     │
│           ┌──────────────────────────┐                        │
│           │      Second Cerveau      │                        │
│           │      ~/second-brain/     │                        │
│           │  user · environment      │                        │
│           │  identity · goals        │                        │
│           │  projects · memory · keys│                        │
│           └──────────────────────────┘                        │
└──────────────────────────────────────────────────────────────┘
```

| Pilier | Localisation | Rôle |
|--------|--------------|------|
| **Skills** | `~/second-brain/skills/`, symlink dans `~/.claude/skills/` | Procédures réutilisables. L'agent charge le `SKILL.md` qui correspond à la tâche. |
| **Sub-agents** | `~/.claude/agents/*.md` | Profils que Claude Code peut spawn pour déléguer. 32 fournis par Agency. |
| **Browser CLIs** | `playwright` et `opencli` dans le PATH | Automatisation navigateur en ligne de commande. Aucun serveur MCP : rien ne charge dans le contexte tant que l'agent n'appelle pas la commande. |
| **Second Cerveau** | `~/second-brain/` | Mémoire persistante : profil, environnement, identité, objectifs, projets, agent perso, secrets. |

---

## Flow d'une session

1. **Bootstrap** — Claude lit `~/second-brain/CLAUDE.md`, qui pointe vers `user.md`, `environment.md`, `01-identity/`, `02-goals/`.
2. **Contexte projet** — il ouvre le dossier concerné dans `10-projects/`.
3. **Délégation** — tâche lourde ou gros output → un sub-agent depuis `~/.claude/agents/`.
4. **Exécution** — skills pour les procédures, `playwright` / `opencli` pour le navigateur.
5. **Mémoire** — en fin de session, le hook Stop lance `hooks/memory-logger.py` qui extrait les faits durables et les append dans `memory/log.md`.

---

## Pourquoi ce setup

Il règle 4 problèmes qui reviennent à chaque session :

1. **L'agent oublie tout d'une session à l'autre** → Second Cerveau relu à chaque démarrage.
2. **L'agent ne sait pas ce qui est installé** → `environment.md` rempli automatiquement.
3. **L'agent réinvente la procédure à chaque fois** → skills Anthropic + les tiens.
4. **L'agent bloque sur les tâches longues** → sub-agents délégables.

---

## Le choix CLI plutôt que MCP

Un serveur MCP déclare ses outils dans le contexte à chaque session, qu'on s'en serve ou pas. Deux CLIs coûtent zéro token tant qu'elles ne sont pas appelées, se testent à la main, et `opencli` réutilise ta session Chrome au lieu d'ouvrir un navigateur vierge à re-loguer.

```bash
playwright screenshot https://example.com shot.png
playwright open https://example.com
opencli init
opencli instagram profile <username> --format json
```

Le premier pilote un navigateur propre (screenshots, scraping public, tests). Le second parle à des sites où tu es déjà connecté.

---

## Idempotence

Chaque script est rejouable :

| Script | Condition de skip |
|--------|-------------------|
| `00-detect-system` | Toujours rejouable (réécrit `/tmp/claude-setup-env.sh`) |
| `01-init-second-brain` | Skip si `$BRAIN_PATH/user.md` existe |
| `02-install-clis` | Skip par CLI si `command -v <cli>` répond |
| `03-install-skills` | `git pull` au lieu de `git clone` si `.git` existe |
| `04-setup-browser` | Skip `playwright` / `opencli` déjà présents |
| `05-collect-keys` | Skip si la clé est déjà dans le keystore |
| `06-create-agent` | Skip si `agents/<id>/soul.md` existe |

---

## Faire évoluer le setup

Ajouter une CLI → `02-install-clis.sh`. Ajouter un outil navigateur → `04-setup-browser.sh`. Ajouter une question → mets-la dans le script où elle a du sens, et exporte la réponse dans `/tmp/claude-setup-env.sh` pour les scripts suivants.
