#!/usr/bin/env bash
# remote-doctor.sh
# Executa openclaw doctor remotamente para diagnosticar problemas
set -e

SERVER="openclaw-xcompany"
FIX_MODE="${1:-}"

echo "🔍 OpenClaw Doctor — Diagnóstico Remoto"
echo "========================================"
echo "Servidor: $SERVER"
echo ""

if [ "$FIX_MODE" = "--fix" ]; then
  echo "🔧 Modo: FIX (corrigir problemas automaticamente)"
  ssh $SERVER "sudo -u openclaw HOME=/home/openclaw /usr/bin/openclaw doctor --fix --non-interactive"
else
  echo "🔍 Modo: DIAGNÓSTICO (somente leitura)"
  ssh $SERVER "sudo -u openclaw HOME=/home/openclaw /usr/bin/openclaw doctor --non-interactive"
fi

echo ""
echo "✅ Diagnóstico completo!"
echo ""
echo "💡 Para corrigir problemas automaticamente:"
echo "   bash integrations/openclaw/remote-doctor.sh --fix"
