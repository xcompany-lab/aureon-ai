#!/usr/bin/env bash
# Force reload Aureon AI identity into OpenClaw agent
set -euo pipefail

echo "🔍 Diagnóstico de Identidade Aureon AI"
echo "========================================"

AGENT_DIR="/home/openclaw/.openclaw/agents/main/agent"

# 1. Verificar se arquivos existem
echo ""
echo "📁 Verificando arquivos de identidade..."
if [ -f "$AGENT_DIR/SOUL.md" ]; then
    echo "✅ SOUL.md existe ($(wc -l < "$AGENT_DIR/SOUL.md") linhas)"
else
    echo "❌ SOUL.md NÃO ENCONTRADO"
fi

if [ -f "$AGENT_DIR/IDENTITY.md" ]; then
    echo "✅ IDENTITY.md existe ($(wc -l < "$AGENT_DIR/IDENTITY.md") linhas)"
else
    echo "❌ IDENTITY.md NÃO ENCONTRADO"
fi

if [ -f "$AGENT_DIR/AGENTS.md" ]; then
    echo "✅ AGENTS.md existe ($(wc -l < "$AGENT_DIR/AGENTS.md") linhas)"
else
    echo "❌ AGENTS.md NÃO ENCONTRADO"
fi

# 2. Mostrar conteúdo do SOUL.md
echo ""
echo "📖 Primeiras 10 linhas do SOUL.md:"
echo "-----------------------------------"
head -n 10 "$AGENT_DIR/SOUL.md" 2>/dev/null || echo "❌ Não foi possível ler SOUL.md"

# 3. Verificar system prompt atual
echo ""
echo "🤖 Verificando configuração do agente..."
su - openclaw -c "openclaw agents list --verbose" 2>/dev/null || echo "⚠️  Não foi possível listar agentes"

# 4. Forçar reload do system prompt
echo ""
echo "🔄 Forçando reload do system prompt..."

# Método 1: Via openclaw agents reload (se existir)
su - openclaw -c "openclaw agents reload main" 2>/dev/null && echo "✅ Agent reloaded via CLI" || echo "⚠️  Comando reload não disponível"

# Método 2: Reiniciar gateway (sempre funciona)
echo ""
echo "🔄 Reiniciando gateway..."
systemctl restart openclaw
sleep 3

# 5. Verificar status final
echo ""
echo "📊 Status final do agente:"
echo "-------------------------"
su - openclaw -c "openclaw agents status --agent main" 2>/dev/null || su - openclaw -c "openclaw doctor"

echo ""
echo "✅ Reload completo!"
echo ""
echo "🧪 TESTE AGORA:"
echo "   Envie no WhatsApp: 'Quem é você?'"
echo ""
echo "📝 Resposta esperada deve começar com:"
echo "   'Sou Aureon AI — sistema de inteligência aplicada...'"
