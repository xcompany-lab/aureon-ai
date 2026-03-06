#!/usr/bin/env bash
# Inject SOUL.md directly into openclaw.json as systemPrompt
set -euo pipefail

OPENCLAW_CONFIG="/home/openclaw/.openclaw/openclaw.json"
SOUL_FILE="/home/openclaw/.openclaw/agents/main/agent/SOUL.md"

echo "🧠 Injetando SOUL.md no openclaw.json..."

if [ ! -f "$SOUL_FILE" ]; then
    echo "❌ SOUL.md não encontrado em: $SOUL_FILE"
    exit 1
fi

# Fazer backup
cp "$OPENCLAW_CONFIG" "$OPENCLAW_CONFIG.backup-$(date +%s)"

# Ler SOUL.md e escapar para JSON
SOUL_CONTENT=$(cat "$SOUL_FILE" | jq -Rs .)

echo "📝 Conteúdo do SOUL.md (primeiras linhas):"
head -n 5 "$SOUL_FILE"

# Usar jq para injetar no config
jq --argjson soul "$SOUL_CONTENT" \
   '.agents.list[0].systemPrompt = $soul' \
   "$OPENCLAW_CONFIG" > "$OPENCLAW_CONFIG.tmp"

mv "$OPENCLAW_CONFIG.tmp" "$OPENCLAW_CONFIG"
chown openclaw:openclaw "$OPENCLAW_CONFIG"

echo ""
echo "✅ SOUL.md injetado no openclaw.json"
echo ""
echo "🔄 Reiniciando gateway..."
systemctl restart openclaw
sleep 3

echo ""
echo "📊 Verificando configuração..."
su - openclaw -c "openclaw doctor"

echo ""
echo "🧪 TESTE: Envie 'Quem é você?' no WhatsApp"
