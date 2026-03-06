#!/usr/bin/env bash
# Diagnose where OpenClaw expects SOUL.md and IDENTITY.md
set -euo pipefail

echo "🔍 Diagnóstico de localização do SOUL.md"
echo "=========================================="
echo ""

# 1. Verificar estrutura de diretórios
echo "📁 Estrutura de diretórios do agente main:"
ls -laR /home/openclaw/.openclaw/agents/main/ 2>/dev/null || echo "❌ Diretório não acessível"

echo ""
echo "🔍 Procurando arquivos SOUL e IDENTITY:"
find /home/openclaw/.openclaw -type f \( -name "SOUL.md" -o -name "IDENTITY.md" -o -name "AGENTS.md" \) -exec ls -lh {} \;

echo ""
echo "📖 Conteúdo do SOUL.md (se existir):"
cat /home/openclaw/.openclaw/agents/main/agent/SOUL.md 2>/dev/null | head -n 20 || echo "❌ SOUL.md não encontrado"

echo ""
echo "📖 Conteúdo do IDENTITY.md (se existir):"
cat /home/openclaw/.openclaw/agents/main/IDENTITY.md 2>/dev/null || echo "❌ IDENTITY.md não encontrado em /home/openclaw/.openclaw/agents/main/"
cat /home/openclaw/.openclaw/agents/main/agent/IDENTITY.md 2>/dev/null || echo "❌ IDENTITY.md não encontrado em /home/openclaw/.openclaw/agents/main/agent/"

echo ""
echo "⚙️  Configuração atual do agente no openclaw.json:"
jq '.agents.list[0]' /home/openclaw/.openclaw/openclaw.json

echo ""
echo "📚 Documentação OpenClaw sobre system prompts:"
echo "   Verifique em: https://openclaw.io/docs/agents"
