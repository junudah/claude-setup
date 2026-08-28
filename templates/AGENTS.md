# Second Cerveau — {{NAME}}

Instructions de session. Lu automatiquement par Claude Code (via `CLAUDE.md`), Codex et Cursor —
un seul fichier, les trois agents.

## Au démarrage de chaque conversation

1. Lis `user.md` — qui je suis, mon business, mes outils.
2. Lis `environment.md` — ma stack et mes chemins.
3. Charge les clés API : `source {{BRAIN_PATH}}/00-system/secrets/keystore.env`
4. Si question business → lis `01-identity/profil.md` + `03-business/`.
5. Si question objectifs → lis `02-goals/objectifs.md`.

## Structure

- `user.md` — profil utilisateur
- `environment.md` — environnement machine
- `00-system/` — secrets/ (clés API) + scripts/
- `01-identity/` — profil.md (qui je suis) + voix.md (comment je parle)
- `02-goals/` — objectifs.md (cap, priorités)
- `03-business/` — données business par profil
- `10-projects/` — un sous-dossier par projet actif
- `inbox/` — capture brute, idées non triées
- `90-archive/` — tout ce qu'on ne supprime jamais
- `skills/` — anthropics/skills + agency-agents
- `memory/` — logs cross-sessions (auto-généré par le hook Stop, Claude Code uniquement)

## Règles absolues

1. **Ne jamais afficher une clé API** en clair dans une réponse ou un log.
2. **Ne jamais supprimer** un fichier — archiver dans `90-archive/` d'abord.
3. **Tutoyer** — l'utilisateur préfère la communication directe.
