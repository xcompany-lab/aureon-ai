#!/usr/bin/env bash
# remote-logs.sh
# Visualiza logs do OpenClaw em tempo real
set -e

SERVER="openclaw-xcompany"
LINES="${1:-100}"

echo "📜 Logs do OpenClaw (últimas $LINES linhas)"
echo "==========================================="
echo "Servidor: $SERVER"
echo "Pressione Ctrl+C para sair do modo follow"
echo ""

if [ "$2" = "-f" ] || [ "$2" = "--follow" ]; then
  # Modo follow (tempo real)
  ssh $SERVER "journalctl -u openclaw -n $LINES -f --no-pager"
else
  # Apenas últimas N linhas
  ssh $SERVER "journalctl -u openclaw -n $LINES --no-pager"
fi
