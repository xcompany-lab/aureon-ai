#!/usr/bin/env python3
"""
Aureon AI — WhatsApp Memory Saver Skill
========================================
Roda no servidor OpenClaw (mesma máquina que o projeto Aureon).
Grava conversas importantes do WhatsApp diretamente em WHATSAPP-MEMORY.md
ou via webhook localhost:5000 (primeira opção tentada).

Uso (chamado pelo Aureon via AGENTS.md após conversas significativas):
    python3 /home/openclaw/aureon-skills/save_conversation.py \
        --summary "Usuário discutiu lançamento do produto X e decidiu Q2" \
        --user_message "Como foi a call de vendas?" \
        --bot_response "Senhor, a call foi excelente..."
"""

import argparse
import json
import os
import sys
import urllib.request
import urllib.error
from datetime import datetime
from pathlib import Path

# ============================================================
# Configuração — mesma máquina
# ============================================================

# Webhook no backend local (mesma máquina = localhost)
AUREON_WEBHOOK_URL = os.getenv(
    "AUREON_MEMORY_WEBHOOK",
    "http://localhost:5000/api/whatsapp/memory"
)

# Caminho direto para o arquivo de memória (mesma máquina)
# Detecta automaticamente o usuário do projeto Aureon
_aureon_home = Path("/home/aureon/projects/mega-brain-lab/mega-brain")
DIRECT_MEMORY_FILE = str(_aureon_home / ".claude/aureon/WHATSAPP-MEMORY.md")


def save_via_webhook(entry: dict) -> bool:
    """Salva via webhook HTTP no backend Flask (localhost:5000)."""
    try:
        payload = json.dumps(entry).encode("utf-8")
        req = urllib.request.Request(
            AUREON_WEBHOOK_URL,
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST"
        )
        with urllib.request.urlopen(req, timeout=5) as resp:
            result = json.loads(resp.read().decode("utf-8"))
            return result.get("status") == "saved"
    except Exception as e:
        print(f"[webhook] {e}", file=sys.stderr)
        return False


def save_direct_to_file(entry: dict) -> bool:
    """Fallback: escreve diretamente no WHATSAPP-MEMORY.md (mesma máquina)."""
    try:
        memory_path = Path(DIRECT_MEMORY_FILE)
        memory_path.parent.mkdir(parents=True, exist_ok=True)

        # Criar arquivo com cabeçalho se não existir
        if not memory_path.exists():
            memory_path.write_text(
                "# AUREON WHATSAPP MEMORY\n"
                "# Histórico de conversas via WhatsApp (OpenClaw)\n"
                "# Gravado automaticamente pelo skill save_conversation.py\n\n"
                "---\n\n## Histórico de Conversas\n",
                encoding="utf-8"
            )

        timestamp = entry.get("timestamp", datetime.now().strftime("%Y-%m-%d %H:%M"))
        entry_text = f"\n### [{timestamp}] WhatsApp\n"
        if entry.get("user_message"):
            entry_text += f"- **Operador:** {entry['user_message'][:500]}\n"
        if entry.get("bot_response"):
            entry_text += f"- **Aureon:** {entry['bot_response'][:500]}\n"
        if entry.get("summary"):
            entry_text += f"- **Resumo:** {entry['summary']}\n"

        with open(memory_path, "a", encoding="utf-8") as f:
            f.write(entry_text)

        print(f"[memory] Gravado direto em {DIRECT_MEMORY_FILE}", file=sys.stderr)
        return True

    except Exception as e:
        print(f"[direct_file] {e}", file=sys.stderr)
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Save WhatsApp conversation to Aureon unified memory"
    )
    parser.add_argument("--user_message", default="", help="User's message")
    parser.add_argument("--bot_response", default="", help="Aureon's response")
    parser.add_argument("--summary", default="", help="1-line summary of the exchange")
    args = parser.parse_args()

    if not any([args.user_message, args.bot_response, args.summary]):
        print("Erro: forneça --user_message, --bot_response ou --summary", file=sys.stderr)
        sys.exit(1)

    entry = {
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M"),
        "user_message": args.user_message,
        "bot_response": args.bot_response,
        "summary": args.summary,
        "channel": "whatsapp"
    }

    # Tenta webhook primeiro (backend ativo), fallback para arquivo direto
    if save_via_webhook(entry):
        print(json.dumps({"success": True, "method": "webhook_localhost"}))
    elif save_direct_to_file(entry):
        print(json.dumps({"success": True, "method": "direct_file"}))
    else:
        print(json.dumps({"success": False, "error": "all methods failed"}), file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
