#!/usr/bin/env bash
# Fix OpenClaw config validation errors
# Removes unsupported keys: auth.useEnv and agents.list[].emoji

set -euo pipefail

echo "🔧 Corrigindo configuração OpenClaw..."

# Fix for openclaw user
if [ -f /home/openclaw/.openclaw/openclaw.json ]; then
    echo "📝 Corrigindo /home/openclaw/.openclaw/openclaw.json"
    su - openclaw -c "openclaw doctor --fix" || true
fi

# Fix for aureon user (if different)
if [ -f /home/aureon/.openclaw/openclaw.json ]; then
    echo "📝 Corrigindo /home/aureon/.openclaw/openclaw.json"
    su - aureon -c "openclaw doctor --fix" || true
fi

# Configure gateway mode to local
echo "⚙️ Configurando gateway mode..."
su - openclaw -c "openclaw config set gateway.mode local" || true

# Show final status
echo ""
echo "✅ Configuração corrigida!"
echo ""
echo "📊 Status do OpenClaw:"
su - openclaw -c "openclaw doctor" || true

echo ""
echo "🎯 Próximo passo: configurar autenticação Anthropic"
echo "   Execute: openclaw setup-token"
