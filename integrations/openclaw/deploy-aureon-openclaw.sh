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

# 5. openclaw.json — Estrutura de Canais e Gateway
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
  "tools": {
    "media": {
      "audio": {
        "provider": "openai",
        "model": "whisper-1",
        "echoTranscript": true,
        "echoFormat": "📝 Transcrição: {transcript}"
      }
    }
  },
  "gateway": {
    "mode": "local",
    "bind": "auto",
    "token": "AureonToken2026"
  },
  "channels": {
    "whatsapp": {
      "enabled": true,
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

# 6. Injetar OPENAI_API_KEY no environment
echo "🔑 Configurando OPENAI_API_KEY para transcrição de áudio..."
if [ -f /opt/openclaw.env ]; then
  # Remover linha antiga se existir
  sed -i '/^OPENAI_API_KEY=/d' /opt/openclaw.env
fi
# Adicionar OPENAI_API_KEY (ou solicitar ao usuário)
if [ -z "$OPENAI_API_KEY" ]; then
  echo "⚠️  OPENAI_API_KEY não encontrado no ambiente atual."
  echo "   Por favor, adicione manualmente em /opt/openclaw.env:"
  echo "   OPENAI_API_KEY=sk-proj-..."
else
  echo "OPENAI_API_KEY=$OPENAI_API_KEY" >> /opt/openclaw.env
  echo "✅ OPENAI_API_KEY configurado em /opt/openclaw.env"
fi

# 7. Fix Config & Gateway Mode
echo "🔧 Corrigindo configuração..."
sudo -u openclaw HOME=/home/openclaw /usr/bin/openclaw doctor --fix --non-interactive || true

# 8. Sincronizar Identidade via CLI
echo "🎨 Sincronizando identidade visual no sistema..."
sudo -u openclaw HOME=/home/openclaw /usr/bin/openclaw agents set-identity --agent main --name "Aureon AI" --theme "executive"

# 9. Sincronizar Configurações (Garantir que ambos os usuários tenham a mesma config)
echo "📂 Sincronizando arquivos de configuração..."
mkdir -p /home/aureon/.openclaw 2>/dev/null || true
cp "$OPENCLAW_HOME/openclaw.json" /home/aureon/.openclaw/openclaw.json 2>/dev/null || true
chown -R openclaw:openclaw "$OPENCLAW_HOME"

# 10. Limpeza final e Permissões
chmod 700 "$OPENCLAW_HOME"
chmod 700 "$AGENT_DIR"
chmod 600 "$OPENCLAW_HOME/openclaw.json"

# 11. Reiniciar e Validar
echo "🔄 Reiniciando serviço (Forçando limpeza de porta)..."
fuser -k 18789/tcp 2>/dev/null || true
systemctl restart openclaw
sleep 5

echo ""
echo "📊 STATUS FINAL:"
sudo -u openclaw HOME=/home/openclaw /usr/bin/openclaw doctor --non-interactive

echo ""
echo "🎉 Aureon AI configurado!"
echo ""
echo "⚠️  PRÓXIMOS PASSOS:"
echo "   1. Configure o token Anthropic: openclaw setup-token"
echo "   2. Verifique variáveis de ambiente no arquivo: /opt/openclaw.env"
echo "   3. Se OPENAI_API_KEY não foi configurado automaticamente, adicione em /opt/openclaw.env"
echo "   4. Teste no WhatsApp:"
echo "      - Texto: 'Quem é você?'"
echo "      - Áudio: Envie um áudio qualquer (será transcrito automaticamente)"
