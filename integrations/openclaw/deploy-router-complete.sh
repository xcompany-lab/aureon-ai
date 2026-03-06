#!/usr/bin/env bash
# Deploy Aureon AI Router + Skills Completo
set -euo pipefail

echo "🏛️ Aureon AI — Deploy Router + Skills v2.0"
echo "==========================================="

WORKSPACE="/home/openclaw/.openclaw/workspace"
TEMPLATES="/home/aureon/projects/mega-brain-lab/mega-brain/integrations/openclaw/workspace-templates"

# 1. Backup dos arquivos atuais
echo ""
echo "💾 Backup dos arquivos atuais..."
BACKUP_DIR="$WORKSPACE/backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -f "$WORKSPACE/SOUL.md" ]; then
    cp "$WORKSPACE/SOUL.md" "$BACKUP_DIR/"
fi
if [ -f "$WORKSPACE/AGENTS.md" ]; then
    cp "$WORKSPACE/AGENTS.md" "$BACKUP_DIR/"
fi
if [ -f "$WORKSPACE/TOOLS.md" ]; then
    cp "$WORKSPACE/TOOLS.md" "$BACKUP_DIR/"
fi

echo "   Backup salvo em: $BACKUP_DIR"

# 2. Deploy dos novos arquivos
echo ""
echo "📝 Deploying SOUL.md v2.0 (Router + Execution)..."
cp "$TEMPLATES/SOUL.md" "$WORKSPACE/SOUL.md"
chown openclaw:openclaw "$WORKSPACE/SOUL.md"
chmod 644 "$WORKSPACE/SOUL.md"

echo "📝 Deploying AGENTS.md (Router Inteligente)..."
cp "$TEMPLATES/AGENTS.md" "$WORKSPACE/AGENTS.md"
chown openclaw:openclaw "$WORKSPACE/AGENTS.md"
chmod 644 "$WORKSPACE/AGENTS.md"

echo "📝 Deploying TOOLS.md (Skills de Execução)..."
cp "$TEMPLATES/TOOLS.md" "$WORKSPACE/TOOLS.md"
chown openclaw:openclaw "$WORKSPACE/TOOLS.md"
chmod 644 "$WORKSPACE/TOOLS.md"

# 3. Verificar conteúdo
echo ""
echo "✅ Arquivos deployados:"
ls -lh "$WORKSPACE"/{SOUL,AGENTS,TOOLS}.md

echo ""
echo "📖 Preview SOUL.md:"
head -n 15 "$WORKSPACE/SOUL.md"

echo ""
echo "📖 Preview AGENTS.md (Router):"
head -n 30 "$WORKSPACE/AGENTS.md"

# 4. Limpar sessões (forçar reload)
echo ""
echo "🧹 Limpando sessões antigas..."
rm -f /home/openclaw/.openclaw/agents/main/sessions/*.jsonl
rm -f /home/openclaw/.openclaw/agents/main/sessions/*.jsonl.deleted.*
echo "   Todas as sessões removidas. Nova sessão será iniciada com router v2.0"

# 5. Reiniciar gateway
echo ""
echo "🔄 Reiniciando OpenClaw Gateway..."
systemctl stop openclaw
sleep 2
systemctl start openclaw
sleep 5

# 6. Verificar status
echo ""
echo "📊 Status do Gateway:"
systemctl status openclaw --no-pager -l | head -n 15 || true

echo ""
echo "🔍 Últimas linhas do log:"
journalctl -u openclaw -n 20 --no-pager || true

# 7. Mostrar comandos disponíveis
echo ""
echo "=================================="
echo "✅ DEPLOY COMPLETO!"
echo "=================================="
echo ""
echo "📂 Arquivos no workspace:"
ls -lh "$WORKSPACE"/*.md | awk '{print "   " $9 " (" $5 ")"}'

echo ""
echo "🎯 NOVOS RECURSOS ATIVADOS:"
echo ""
echo "1️⃣  ROUTER AUTOMÁTICO DE SQUADS"
echo "   - Detecção automática de intenção"
echo "   - Ativação contextual de SQUADs"
echo "   - Respostas especializadas por área"
echo ""
echo "2️⃣  COMANDOS DISPONÍVEIS:"
echo ""
echo "   🏢 SQUADs:"
echo "      /sales      — SQUAD Sales (conversão, pipeline)"
echo "      /tech       — SQUAD Tech (código, deploy)"
echo "      /ops        — SQUAD Ops (processos, SOPs)"
echo "      /exec       — SQUAD Exec (estratégia, KPIs)"
echo "      /marketing  — SQUAD Marketing (ads, funil)"
echo "      /research   — SQUAD Research (análise, mercado)"
echo "      /finance    — SQUAD Finance (DRE, margem)"
echo ""
echo "   ⚙️  Sistema:"
echo "      /status     — Status de todos os SQUADs"
echo "      /help       — Lista todos os comandos"
echo "      /info       — Informações sobre Aureon AI"
echo ""
echo "   🚀 Execução:"
echo "      /execute [comando]  — Executa comando no servidor"
echo "      /logs [serviço]     — Mostra logs"
echo "      /deploy [ambiente]  — Deploy de aplicação"
echo "      /n8n [workflow]     — Dispara workflow N8N"
echo ""
echo "3️⃣  INTELIGÊNCIA CONTEXTUAL:"
echo "   - Mensagens sem comando são roteadas automaticamente"
echo "   - Exemplo: 'Como melhorar conversão?' → SQUAD Sales"
echo "   - Exemplo: 'Preciso de um DRE' → SQUAD Finance"
echo ""
echo "🧪 TESTE AGORA NO WHATSAPP:"
echo ""
echo "   Teste 1 — Roteamento automático:"
echo "   → 'Como melhorar a conversão do meu funil?'"
echo "   Esperado: SQUAD Sales ativado + estratégias de conversão"
echo ""
echo "   Teste 2 — Comando explícito:"
echo "   → '/tech'"
echo "   Esperado: SQUAD Tech ativado + comandos disponíveis"
echo ""
echo "   Teste 3 — Multi-SQUAD:"
echo "   → 'Quanto investir em ads considerando meu DRE?'"
echo "   Esperado: Marketing + Finance coordenados"
echo ""
echo "⚠️  AGUARDE 10 SEGUNDOS antes de testar para garantir reload completo"
echo ""
echo "📋 VERIFICAÇÃO:"
echo "   1. cat $WORKSPACE/SOUL.md | head -20"
echo "   2. cat $WORKSPACE/AGENTS.md | head -30"
echo "   3. journalctl -u openclaw -f"
echo ""

# 8. Countdown
echo "⏳ Aguardando gateway estabilizar..."
for i in {10..1}; do
    echo -n "$i... "
    sleep 1
done
echo ""
echo ""
echo "🎉 PRONTO! Teste no WhatsApp agora!"
