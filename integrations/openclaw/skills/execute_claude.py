#!/usr/bin/env python3
"""
Aureon AI — Execute Claude Code Skill
=======================================
Permite que o Aureon se auto-configure via WhatsApp.
Chama o endpoint local do backend Flask que roda o Claude Code como subprocess.

Uso (chamado automaticamente pelo Aureon via AGENTS.md):
    python3 /usr/local/bin/aureon-skills/execute_claude.py \
        --task "adiciona um squad de atendimento ao AGENTS.md"

Exemplos de tarefas:
    --task "mostra o conteúdo do AGENTS.md"
    --task "adiciona novo squad CUSTOMER ao AGENTS.md com triggers: suporte, atendimento"
    --task "lista todos os arquivos do projeto"
    --task "verifica se há erros no app.py"
"""

import argparse
import json
import os
import sys
import urllib.request
import urllib.error
from datetime import datetime

# Webhook no backend Flask local (mesma máquina)
EXECUTE_CLAUDE_URL = os.getenv(
    "AUREON_EXECUTE_CLAUDE_URL",
    "http://localhost:5000/api/execute-claude"
)


def execute_claude_task(task: str, timeout: int = 120) -> dict:
    """Envia a tarefa para o backend Flask executar via Claude Code."""
    try:
        payload = json.dumps({
            "task": task,
            "timeout": timeout
        }).encode("utf-8")

        req = urllib.request.Request(
            EXECUTE_CLAUDE_URL,
            data=payload,
            headers={"Content-Type": "application/json"},
            method="POST"
        )

        # Timeout maior que o padrão pois Claude Code pode demorar
        with urllib.request.urlopen(req, timeout=timeout + 10) as resp:
            return json.loads(resp.read().decode("utf-8"))

    except urllib.error.URLError as e:
        return {
            "status": "error",
            "output": f"Backend indisponível: {e}",
            "exit_code": -1
        }
    except Exception as e:
        return {
            "status": "error",
            "output": str(e),
            "exit_code": -1
        }


def main():
    parser = argparse.ArgumentParser(
        description="Execute Claude Code tasks on behalf of Aureon AI"
    )
    parser.add_argument(
        "--task",
        required=True,
        help="Task description for Claude Code to execute"
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=120,
        help="Timeout in seconds (default: 120)"
    )
    args = parser.parse_args()

    if not args.task.strip():
        print(json.dumps({"error": "Tarefa vazia"}), file=sys.stderr)
        sys.exit(1)

    print(f"[execute_claude] Enviando tarefa: {args.task[:80]}...", file=sys.stderr)

    result = execute_claude_task(args.task, args.timeout)

    # Saída JSON para o OpenClaw processar
    print(json.dumps(result, ensure_ascii=False))

    # Retorna código de erro se falhou
    if result.get("exit_code", 0) != 0 and result.get("status") not in ["done", "timeout"]:
        sys.exit(1)


if __name__ == "__main__":
    main()
