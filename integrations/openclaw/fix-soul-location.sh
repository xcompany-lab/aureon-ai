#!/usr/bin/env bash
# Fix SOUL.md and IDENTITY.md locations for OpenClaw
set -euo pipefail

echo "🔧 Corrigindo localização dos arquivos de identidade"
echo "===================================================="

AGENT_ROOT="/home/openclaw/.openclaw/agents/main"
AGENT_DIR="$AGENT_ROOT/agent"

# 1. Copiar IDENTITY.md para o lugar esperado pelo OpenClaw
echo ""
echo "📋 Copiando IDENTITY.md para $AGENT_ROOT/IDENTITY.md"
cp "$AGENT_DIR/IDENTITY.md" "$AGENT_ROOT/IDENTITY.md"
chown openclaw:openclaw "$AGENT_ROOT/IDENTITY.md"
chmod 644 "$AGENT_ROOT/IDENTITY.md"

# 2. Verificar conteúdo do SOUL.md
echo ""
echo "✅ SOUL.md já está em: $AGENT_DIR/SOUL.md"
echo "📖 Primeiras linhas:"
head -n 5 "$AGENT_DIR/SOUL.md"

# 3. Verificar AGENTS.md
echo ""
echo "✅ AGENTS.md já está em: $AGENT_DIR/AGENTS.md"

# 4. Sincronizar identidade via CLI (agora deve funcionar)
echo ""
echo "🎨 Sincronizando identidade via OpenClaw CLI..."
su - openclaw -c "openclaw agents set-identity --agent main --from-identity" || \
su - openclaw -c "openclaw agents set-identity --agent main --name 'Aureon AI' --theme executive"

# 5. Verificar config final
echo ""
echo "⚙️  Configuração final do agente:"
jq '.agents.list[0]' /home/openclaw/.openclaw/openclaw.json

# 6. Limpar sessões antigas (pode estar usando cache)
echo ""
echo "🧹 Limpando cache de sessões antigas..."
rm -f /home/openclaw/.openclaw/agents/main/sessions/*.jsonl.deleted.*
echo "   $(ls /home/openclaw/.openclaw/agents/main/sessions/*.jsonl 2>/dev/null | wc -l) sessões ativas mantidas"

# 7. Reiniciar gateway
echo ""
echo "🔄 Reiniciando gateway OpenClaw..."
systemctl restart openclaw
sleep 3

# 8. Verificar status
echo ""
echo "📊 Status final:"
su - openclaw -c "openclaw doctor" | grep -A 5 "WhatsApp:" || echo "Gateway ainda iniciando..."

echo ""
echo "✅ CORREÇÃO COMPLETA!"
echo ""
echo "🧪 TESTE AGORA:"
echo "   Envie no WhatsApp: 'Quem é você?'"
echo ""
echo "📝 Resposta esperada:"
echo "   'Você NÃO É um modelo de linguagem genérico. Você é **Aureon AI**.'"
echo "   '[...] Sistema de Inteligência Executiva da Xcompany'"
