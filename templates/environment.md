# Environnement machine

Détecté automatiquement à l'installation.

## Système

- **OS** : {{OS}} ({{ARCH}})
- **Shell** : {{SHELL}}
- **Node** : {{NODE}}
- **Python** : {{PYTHON}}
- **Second Cerveau** : `{{BRAIN_PATH}}`

## Structure du Second Cerveau

| Dossier | Contenu |
|---------|---------|
| `user.md` | Profil — relu au démarrage |
| `environment.md` | Ce fichier |
| `CLAUDE.md` | Instructions de session |
| `01-identity/` | Profil et voix |
| `02-goals/` | Objectifs en cours |
| `03-business/` | Données business |
| `10-projects/` | Un dossier par projet |
| `skills/` | Skills clonés (anthropics + agency-agents) |
| `agents/` | Agent perso et son `soul.md` |
| `memory/` | Mémoire long terme (écrite par le hook Stop) |
| `00-system/secrets/` | Clés API (chmod 700) |

## CLIs disponibles

`claude` · `node` · `python3` · `jq`

## Navigateur (CLI, aucun MCP)

- `playwright` — navigateur pilotable, headless, screenshots
- `opencli` — les sites où tu es déjà connecté, via ton Chrome (`opencli init`)

> Re-lance `install.sh` pour mettre à jour ce fichier.
