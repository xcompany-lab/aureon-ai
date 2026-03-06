#!/usr/bin/env bash
# Deploy SOUL.md to OpenClaw workspace (the correct location!)
set -euo pipefail

echo "🏛️ Aureon AI → Deploy SOUL.md para Workspace"
echo "=============================================="

WORKSPACE="/home/openclaw/.openclaw/workspace"
SOURCE_SOUL="/home/openclaw/.openclaw/agents/main/agent/SOUL.md"

# 1. Backup do SOUL.md antigo
echo ""
echo "💾 Fazendo backup do SOUL.md antigo..."
if [ -f "$WORKSPACE/SOUL.md" ]; then
    cp "$WORKSPACE/SOUL.md" "$WORKSPACE/SOUL.md.backup-$(date +%s)"
    echo "   Backup salvo: $WORKSPACE/SOUL.md.backup-$(date +%s)"
    echo ""
    echo "📖 SOUL.md ANTIGO (primeiras linhas):"
    head -n 5 "$WORKSPACE/SOUL.md"
else
    echo "   Nenhum SOUL.md anterior encontrado"
fi

# 2. Copiar novo SOUL.md para workspace
echo ""
echo "📝 Copiando novo SOUL.md Aureon AI para workspace..."
cp "$SOURCE_SOUL" "$WORKSPACE/SOUL.md"
chown openclaw:openclaw "$WORKSPACE/SOUL.md"
chmod 644 "$WORKSPACE/SOUL.md"

echo ""
echo "✅ NOVO SOUL.md (primeiras linhas):"
head -n 10 "$WORKSPACE/SOUL.md"

# 3. Também copiar AGENTS.md se necessário
echo ""
echo "📋 Verificando AGENTS.md..."
if [ -f "/home/openclaw/.openclaw/agents/main/agent/AGENTS.md" ]; then
    cp "/home/openclaw/.openclaw/agents/main/agent/AGENTS.md" "$WORKSPACE/AGENTS.md"
    chown openclaw:openclaw "$WORKSPACE/AGENTS.md"
    echo "✅ AGENTS.md atualizado no workspace"
fi

# 4. Criar ou atualizar USER.md
echo ""
echo "👤 Criando/atualizando USER.md..."
cat > "$WORKSPACE/USER.md" << 'USER_EOF'
# USER

Nome: Aureon
Papel: CEO / Operador do Sistema
Comunicação: Direto, executivo, sem floreios
Timezone: America/Sao_Paulo (UTC-3)
Língua: Português (Brasil)

## Preferências
- Respostas objetivas e acionáveis
- Foco em ROI e execução
- Nível de detalhe: alto nível estratégico, mas com dados concretos quando necessário

## Contexto
Opera o Mega Brain (Aureon AI) — sistema de inteligência aplicada da Xcompany.
Gerencia 7 SQUADs especializados.
USER_EOF

chown openclaw:openclaw "$WORKSPACE/USER.md"
echo "✅ USER.md criado/atualizado"

# 5. Limpar TODAS as sessões (crítico!)
echo ""
echo "🧹 LIMPANDO TODAS AS SESSÕES (forçar reload completo)..."
rm -f /home/openclaw/.openclaw/agents/main/sessions/*.jsonl
rm -f /home/openclaw/.openclaw/agents/main/sessions/*.jsonl.deleted.*
echo "   Todas as sessões antigas removidas"

# 6. Reiniciar gateway
echo ""
echo "🔄 Reiniciando gateway OpenClaw..."
systemctl stop openclaw
sleep 2
systemctl start openclaw
sleep 5

# 7. Verificar status
echo ""
echo "📊 Status do gateway:"
systemctl status openclaw --no-pager -l | head -n 20 || true

echo ""
echo "🔍 Últimas linhas do log:"
journalctl -u openclaw -n 30 --no-pager || true

echo ""
echo "=================================="
echo "✅ DEPLOY COMPLETO!"
echo "=================================="
echo ""
echo "📂 Arquivos no workspace:"
ls -lh "$WORKSPACE"/*.md 2>/dev/null || echo "   Nenhum .md encontrado"

echo ""
echo "🧪 TESTE CRÍTICO AGORA:"
echo "   1. Aguarde 10 segundos para o gateway subir completamente"
echo "   2. Envie no WhatsApp: 'Quem é você?'"
echo ""
echo "📝 RESPOSTA ESPERADA:"
echo "   'Você NÃO É um modelo de linguagem genérico. Você é **Aureon AI**.'"
echo "   'Sistema de Inteligência Executiva da Xcompany (Mega Cortex)'"
echo ""
echo "⚠️  SE AINDA RESPONDER GENÉRICO:"
echo "   1. Verificar logs: journalctl -u openclaw -f"
echo "   2. Verificar se workspace está correto: cat $WORKSPACE/SOUL.md"
echo "   3. Testar comando: openclaw agents list --verbose"
