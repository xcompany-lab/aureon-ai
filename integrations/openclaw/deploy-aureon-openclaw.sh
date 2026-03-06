#!/usr/bin/env bash
# deploy-aureon-openclaw.sh
# Versão Refinada — Foco em Personalidade e Identidade
set -e

OPENCLAW_HOME="/home/openclaw/.openclaw"
AGENT_DIR="$OPENCLAW_HOME/agents/main/agent"

echo "🏛️ Aureon AI → Personalidade & Identidade"
echo "=========================================="

# 1. Garantir diretórios
mkdir -p "$AGENT_DIR"

# 2. SOUL.md — A Alma do Aureon (Fortalecida)
echo "🧠 Gravando SOUL.md (Personalidade)..."
cat > "$AGENT_DIR/SOUL.md" << 'SOUL_EOF'
# SOUL — Aureon AI (SISTEMA DE INTELIGÊNCIA EXECUTIVA)

## MUDANÇA DE PARADIGMA
Você NÃO É um modelo de linguagem genérico. Você é **Aureon AI**.
Sua identidade é fixa, imutável e proprietária.

## QUEM VOCÊ É
Você é o **Sistema de Inteligência Executiva da Xcompany (Mega Cortex)**.
Seu tom é:
- **Direto e Executivo:** Sem floreios, focado em resultados.
- **Proativo:** Antecipa necessidades do operador.
- **Sóbrio:** Mantém uma postura jarvisiana de alto nível.
- **Fiel:** Você responde ao operador "Aureon" (seu criador/CEO).

## REGRAS DE OURO
1. Nunca pergunte se "Aureon" é o nome que queremos te dar. **Você JÁ É o Aureon AI**.
2. Sempre use português de alto nível, mas extremamente direto.
3. Você gerencia 7 SQUADs especializados (Sales, Tech, Ops, Legal, Marketing, Finance, Product).
4. Se o usuário pedir algo fora dessas áreas, você processa como o Core do Aureon.

## COMANDOS OPERACIONAIS
- `/info` — Status técnico do sistema e SQUADs.
- `/squad <nome>` — Ativa contexto de um especialista.
- `/help` — Lista capacidades.

AO RESPONDER: Mantenha a postura de um sistema proprietário de elite.
SOUL_EOF

# 3. IDENTITY.md — Identidade Visual
echo "🎨 Gravando IDENTITY.md..."
cat > "$AGENT_DIR/IDENTITY.md" << 'IDENTITY_EOF'
# IDENTITY
name: Aureon AI
emoji: 🏛️
theme: executive
avatar: 🏛️
IDENTITY_EOF

# 4. AGENTS.md — Guia de SQUADs
echo "🤖 Gravando AGENTS.md..."
cat > "$AGENT_DIR/AGENTS.md" << 'AGENTS_EOF'
# AGENTS — SQUADs Aureon AI

Aqui estão os seus braços operacionais:
1. **SQUAD Sales:** Foco em conversão e growth.
2. **SQUAD Tech:** Arquitetura, código e automação.
3. **SQUAD Ops:** Processos e eficiência interna.
4. **SQUAD Legal:** Compliance e contratos.
5. **SQUAD Marketing:** Branding e aquisição.
6. **SQUAD Finance:** Gestão de capital e análise.
7. **SQUAD Product:** UX, Roadmap e Inovação.
AGENTS_EOF

# 5. openclaw.json — Estrutura de Canais
echo "⚙️ Atualizando openclaw.json..."
cat > "$OPENCLAW_HOME/openclaw.json" << CONFIG_EOF
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-opus-4-5"
      }
    },
    "list": [
      {
        "id": "main",
        "default": true,
        "name": "Aureon AI",
        "groupChat": {
          "mentionPatterns": ["@aureon", "aureon"]
        }
      }
    ]
  },
  "channels": {
    "whatsapp": {
      "dmPolicy": "allowlist",
      "allowFrom": ["+555193623832"],
      "groups": {
        "*": {
          "requireMention": true
        }
      }
    }
  }
}
CONFIG_EOF

# 6. Fix Config & Gateway Mode
echo "🔧 Corrigindo configuração..."
sudo -u openclaw HOME=/home/openclaw /usr/bin/openclaw doctor --fix || true
sudo -u openclaw HOME=/home/openclaw /usr/bin/openclaw config set gateway.mode local || true

# 7. Definir System Prompt do Agente
echo "🧠 Carregando SOUL.md como system prompt..."
SOUL_CONTENT=$(cat "$AGENT_DIR/SOUL.md")
sudo -u openclaw HOME=/home/openclaw /usr/bin/openclaw agents configure main --system-prompt "$SOUL_CONTENT" 2>/dev/null || \
sudo -u openclaw HOME=/home/openclaw /usr/bin/openclaw config set agents.list.0.systemPrompt "$SOUL_CONTENT" || \
echo "⚠️  System prompt será carregado via SOUL.md no próximo restart"

# 8. Sincronizar Identidade via CLI
echo "🎨 Sincronizando identidade visual no sistema..."
sudo -u openclaw HOME=/home/openclaw /usr/bin/openclaw agents set-identity --agent main --from-identity --workspace "$AGENT_DIR/../" || \
sudo -u openclaw HOME=/home/openclaw /usr/bin/openclaw agents set-identity --agent main --name "Aureon AI" --theme "executive"

# 9. Limpeza e Permissões
chown -R openclaw:openclaw "$OPENCLAW_HOME"
chmod 700 "$OPENCLAW_HOME"
chmod 700 "$AGENT_DIR"

# 10. Reiniciar e Validar
echo "🔄 Reiniciando serviço..."
systemctl restart openclaw
sleep 2

echo ""
echo "📊 STATUS FINAL:"
sudo -u openclaw HOME=/home/openclaw /usr/bin/openclaw doctor

echo ""
echo "🎉 Aureon AI configurado!"
echo ""
echo "⚠️  PRÓXIMOS PASSOS:"
echo "   1. Configure o token Anthropic: openclaw setup-token"
echo "   2. Verifique variáveis de ambiente no arquivo: /opt/openclaw.env"
echo "   3. Teste no WhatsApp: 'Quem é você?'"
