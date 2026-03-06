#!/usr/bin/env bash
# Inject SOUL.md as agent system instructions via OpenClaw config
set -euo pipefail

echo "🧠 Injetando SOUL.md como system instructions do agente"
echo "========================================================"

OPENCLAW_CONFIG="/home/openclaw/.openclaw/openclaw.json"
SOUL_FILE="/home/openclaw/.openclaw/agents/main/agent/SOUL.md"

# 1. Backup
echo ""
echo "💾 Fazendo backup do config..."
cp "$OPENCLAW_CONFIG" "$OPENCLAW_CONFIG.backup-$(date +%s)"

# 2. Ler SOUL.md
echo ""
echo "📖 Lendo SOUL.md..."
if [ ! -f "$SOUL_FILE" ]; then
    echo "❌ SOUL.md não encontrado!"
    exit 1
fi

echo "Primeiras linhas do SOUL.md:"
head -n 5 "$SOUL_FILE"

# 3. Injetar no config usando campo correto do OpenClaw
echo ""
echo "⚙️  Injetando no openclaw.json..."

# Ler conteúdo do SOUL e escapar para JSON
SOUL_CONTENT=$(cat "$SOUL_FILE" | jq -Rs .)

# Tentar diferentes campos que o OpenClaw pode usar:
# - instructions (campo recomendado para agents)
# - systemInstructions
# - soul

jq --argjson soul "$SOUL_CONTENT" \
   '.agents.list[0].instructions = $soul' \
   "$OPENCLAW_CONFIG" > "$OPENCLAW_CONFIG.tmp"

mv "$OPENCLAW_CONFIG.tmp" "$OPENCLAW_CONFIG"
chown openclaw:openclaw "$OPENCLAW_CONFIG"

echo "✅ Campo 'instructions' adicionado ao agente"

# 4. Verificar resultado
echo ""
echo "📋 Configuração do agente após injeção:"
jq '.agents.list[0] | {id, name, identity, instructions: (.instructions | split("\n")[0:3] | join("\n"))}' "$OPENCLAW_CONFIG"

# 5. Limpar TODAS as sessões (forçar nova sessão limpa)
echo ""
echo "🧹 Limpando TODAS as sessões para forçar reload..."
rm -f /home/openclaw/.openclaw/agents/main/sessions/*.jsonl
rm -f /home/openclaw/.openclaw/agents/main/sessions/*.jsonl.deleted.*

# 6. Reiniciar gateway
echo ""
echo "🔄 Reiniciando gateway..."
systemctl restart openclaw
sleep 5

# 7. Verificar se subiu
echo ""
echo "📊 Verificando status..."
su - openclaw -c "openclaw doctor" | head -n 50

echo ""
echo "================================"
echo "✅ INJEÇÃO COMPLETA!"
echo "================================"
echo ""
echo "🧪 TESTE CRÍTICO:"
echo "   1. Aguarde 10 segundos"
echo "   2. Envie no WhatsApp: 'Quem é você?'"
echo ""
echo "📝 SE AINDA RESPONDER GENÉRICO:"
echo "   O OpenClaw pode não suportar 'instructions' no config."
echo "   Alternativa: usar API ou modificar source do OpenClaw."
echo ""
echo "🔍 DEBUG:"
echo "   Verificar logs: journalctl -u openclaw -n 100 --no-pager"
