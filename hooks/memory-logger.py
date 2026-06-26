#!/usr/bin/env python3
"""
memory-logger.py — Extrait et log les faits importants après chaque session Claude Code.
Déclenché automatiquement par le hook Stop dans .claude/settings.json
"""
import json, sys, os, urllib.request
from datetime import datetime
from pathlib import Path

def load_api_key(brain_path: Path) -> str:
    key = os.environ.get('ANTHROPIC_API_KEY', '')
    if key:
        return key
    keystore = brain_path / 'secrets' / 'keystore.env'
    if keystore.exists():
        for line in keystore.read_text().splitlines():
            if line.startswith('ANTHROPIC_API_KEY='):
                return line.split('=', 1)[1].strip().strip('"\'')
    return ''

def extract_text(content) -> str:
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return ' '.join(
            c.get('text', '') for c in content
            if isinstance(c, dict) and c.get('type') == 'text'
        )
    return ''

def main():
    try:
        raw = sys.stdin.read()
        data = json.loads(raw) if raw.strip() else {}
    except Exception:
        return

    brain_path = Path(os.environ.get('CS_BRAIN_PATH', Path.home() / 'second-brain'))
    api_key = load_api_key(brain_path)
    if not api_key:
        return

    transcript = data.get('transcript', [])
    if not transcript:
        return

    # Prend les 8 derniers messages pour le contexte
    exchanges = []
    for msg in transcript[-8:]:
        role = msg.get('role', '')
        text = extract_text(msg.get('content', ''))[:600]
        if text and role in ('user', 'assistant'):
            exchanges.append(f"{role.upper()}: {text}")

    if not exchanges:
        return

    prompt = (
        "Extrait les faits importants de cet échange :\n"
        "décisions prises, infos business, préférences, contexte projet, actions planifiées.\n"
        "Format : liste de bullets ultra-concis (max 6 bullets).\n"
        "Si rien d'important, réponds uniquement : SKIP\n\n"
        + '\n'.join(exchanges)
    )

    payload = json.dumps({
        "model": "claude-haiku-4-5-20251001",
        "max_tokens": 250,
        "messages": [{"role": "user", "content": prompt}]
    }).encode()

    req = urllib.request.Request(
        'https://api.anthropic.com/v1/messages',
        data=payload,
        headers={
            'x-api-key': api_key,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json'
        }
    )

    try:
        with urllib.request.urlopen(req, timeout=12) as resp:
            result = json.loads(resp.read())
            facts = result['content'][0]['text'].strip()
    except Exception:
        return

    if not facts or facts.upper() == 'SKIP':
        return

    memory_log = brain_path / 'memory' / 'log.md'
    memory_log.parent.mkdir(parents=True, exist_ok=True)

    date_str = datetime.now().strftime('%Y-%m-%d %H:%M')
    with open(memory_log, 'a', encoding='utf-8') as f:
        f.write(f'\n## {date_str}\n{facts}\n')

if __name__ == '__main__':
    main()
