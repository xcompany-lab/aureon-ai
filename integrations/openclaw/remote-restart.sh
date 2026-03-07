#!/usr/bin/env bash
# remote-restart.sh
# Reinicia o serviço OpenClaw remotamente e mostra o status
set -e

SERVER="openclaw-xcompany"

echo "🔄 Reiniciando OpenClaw no servidor $SERVER..."
echo ""

# Reiniciar o serviço
ssh $SERVER "systemctl restart openclaw"

echo "⏳ Aguardando 5 segundos..."
sleep 5

echo ""
echo "📊 Status do serviço:"
echo "===================="
ssh $SERVER "systemctl status openclaw --no-pager -l"

echo ""
echo "✅ Comando executado!"
echo ""
echo "💡 Para ver logs em tempo real:"
echo "   bash integrations/openclaw/remote-logs.sh"
