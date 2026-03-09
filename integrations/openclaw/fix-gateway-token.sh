#!/bin/bash
# fix-gateway-token.sh — Corrige token mismatch no gateway OpenClaw

set -euo pipefail

echo "🔧 Diagnóstico e Correção — Token Mismatch Gateway"
echo ""

# 1. Verificar processos
echo "1️⃣ Processos OpenClaw ativos:"
ps aux | grep -i openclaw | grep -v grep || echo "Nenhum processo encontrado"
echo ""

# 2. Verificar configuração do token
echo "2️⃣ Token configurado em openclaw.json:"
cat ~/.openclaw/openclaw.json | grep -A 3 '"auth"' || echo "Não encontrado"
echo ""

# 3. Reiniciar OpenClaw (força re-sincronização)
echo "3️⃣ Reiniciando OpenClaw..."
openclaw restart
sleep 3

# 4. Verificar status após restart
echo "4️⃣ Status pós-restart:"
ps aux | grep -i openclaw | grep -v grep || echo "Nenhum processo encontrado"
echo ""

# 5. Testar conexão
echo "5️⃣ Testando conexão..."
openclaw sessions list || echo "Falhou ao listar sessões"
echo ""

echo "✅ Diagnóstico completo!"
echo ""
echo "Se o problema persistir:"
echo "1. Verifique se o WhatsApp está conectado: openclaw sessions list"
echo "2. Tente desconectar e reconectar: openclaw pairing remove whatsapp && openclaw pairing add whatsapp"
echo "3. Verifique logs: journalctl -u openclaw -n 100"
