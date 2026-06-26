# Second Cerveau — {{NAME}}

Instructions de session pour Claude Code.

## Au démarrage de chaque conversation

1. Lis `user.md` — qui je suis, mon business, mes outils.
2. Lis `environment.md` — ma stack et mes chemins.
3. Charge les clés API si le fichier existe : `source {{BRAIN_PATH}}/secrets/keystore.env`

## Structure

- `user.md` — profil utilisateur
- `environment.md` — environnement machine
- `skills/` — anthropics/skills + agency-agents
- `projects/` — notes par projet (un sous-dossier par projet)
- `memory/` — mémoire long terme cross-sessions
- `secrets/` — clés API (jamais commiter)

## Règles absolues

1. **Ne jamais afficher une clé API** en clair dans une réponse ou un log.
2. **Ne jamais supprimer** un fichier sans archiver d'abord.
3. **Mettre à jour `memory/`** quand une décision ou un contexte important est établi.
4. **Tutoyer** — l'utilisateur préfère la communication directe.
