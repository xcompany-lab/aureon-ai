#!/usr/bin/env bash
# remote-deploy.sh
# Faz deploy completo do Aureon AI no servidor OpenClaw remotamente
set -e

SERVER="openclaw-xcompany"
SCRIPT="deploy-aureon-openclaw.sh"

echo "🚀 Deploy Remoto — Aureon AI OpenClaw"
echo "======================================"
echo "Servidor: $SERVER"
echo ""

# 1. Upload do script
echo "📤 [1/3] Enviando script de deploy..."
scp "integrations/openclaw/$SCRIPT" "$SERVER:/root/"

# 2. Dar permissão de execução
echo "🔑 [2/3] Configurando permissões..."
ssh $SERVER "chmod +x /root/$SCRIPT"

# 3. Executar deploy
echo "⚙️  [3/3] Executando deploy no servidor..."
echo ""
ssh $SERVER "bash /root/$SCRIPT"

echo ""
echo "✅ Deploy completo!"
echo ""
echo "🧪 Próximos passos:"
echo "   1. Teste no WhatsApp: 'Quem é você?'"
echo "   2. Ver logs: bash integrations/openclaw/remote-logs.sh"
echo "   3. Status: bash integrations/openclaw/remote-doctor.sh"
