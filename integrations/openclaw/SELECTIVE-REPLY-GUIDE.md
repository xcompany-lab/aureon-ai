# Aureon AI — Modo Selective Reply

## Visão Geral

O bot OpenClaw está configurado para **receber mensagens de qualquer número**, mas **só responder automaticamente para o owner** (+555193623832).

### Comportamento

| Remetente | Ação do Bot |
|-----------|-------------|
| **+555193623623832 (Owner - Você)** | ✅ Responde tudo, conversa, executa comandos, envia notificações proativas |
| **Outros números** | 📝 Registra mensagem nos logs, **NÃO responde automaticamente** |
| **Envio manual para outros** | ✅ Você pode mandar o bot enviar mensagens para qualquer número via comando |

---

## Como Funciona

### 1. Configuração do Gateway
```json
{
  "channels": {
    "whatsapp": {
      "dmPolicy": "open",      // Recebe de todos
      "allowFrom": ["*"]       // Não filtra recebimento
    }
  }
}
```

### 2. Lógica no SOUL.md (System Prompt)
O agente tem instrução explícita para **só responder o owner**:

```markdown
### 1. Resposta Seletiva (CRÍTICO)
**OWNER (Aureon): +555193623832**

QUANDO RECEBER MENSAGEM:
- Se remetente = `+555193623832` → RESPONDA NORMALMENTE
- Se remetente ≠ `+555193623832` → **RETORNE VAZIO** (não responda)
```

---

## Deployment

### Servidor: openclaw-xcompany

```bash
# 1. Upload do script (da sua máquina local)
scp integrations/openclaw/deploy-selective-reply.sh root@openclaw-xcompany:/tmp/

# 2. Conectar no servidor
ssh root@openclaw-xcompany

# 3. Executar deploy
bash /tmp/deploy-selective-reply.sh
```

### O que o script faz:

1. ✅ Atualiza `SOUL.md` com regra de resposta seletiva
2. ✅ Configura `openclaw.json` com `dmPolicy: open`
3. ✅ Define modelo `claude-3-haiku-20240307` (compatível com sua API key)
4. ✅ Executa `openclaw doctor --fix`
5. ✅ Reinicia gateway
6. ✅ Cria backup do config anterior

---

## Comandos Úteis

### Enviar Mensagem Manual (para qualquer número)

```bash
sudo -u openclaw openclaw message send \
  --channel whatsapp \
  --target "+5521996255348" \
  --message "Oi Bruna, teste de mensagem do Aureon AI"
```

### Ver Logs em Tempo Real

```bash
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
```

### Ver Mensagens Recebidas (mas não respondidas)

```bash
grep "Inbound message" /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
```

### Status do Gateway

```bash
ps aux | grep openclaw-gateway
```

### Reiniciar Gateway

```bash
pkill -f openclaw-gateway
sleep 2
sudo -i -u openclaw openclaw gateway &
```

---

## Testes de Validação

### Teste 1: Você (Owner) Envia Mensagem
**Ação:** Envie "teste" do WhatsApp +555193623832
**Resultado Esperado:** Bot responde normalmente com personalidade Aureon AI

### Teste 2: Outro Número Envia Mensagem
**Ação:** Peça para alguém (+5521996255348) enviar "oi"
**Resultado Esperado:** Bot **NÃO responde** (silêncio total)

**Verificar logs:**
```bash
grep "+5521996255348" /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
```

Deve mostrar "Inbound message" mas **não** deve mostrar resposta.

### Teste 3: Envio Manual
**Ação:**
```bash
sudo -u openclaw openclaw message send \
  --channel whatsapp \
  --target "+5521996255348" \
  --message "Teste de envio manual"
```

**Resultado Esperado:** Bruna recebe a mensagem no WhatsApp

---

## Troubleshooting

### Problema: Bot está respondendo todos os números

**Causa:** SOUL.md não foi aplicado corretamente

**Solução:**
```bash
# Verificar se SOUL.md está no local correto
sudo -u openclaw cat ~/.openclaw/agents/main/agent/SOUL.md | grep "Resposta Seletiva"

# Se não aparecer, re-executar deploy
bash /tmp/deploy-selective-reply.sh
```

---

### Problema: Bot não está respondendo ninguém (nem owner)

**Causa 1:** API key inválida ou modelo incorreto

**Verificar:**
```bash
# Ver erro nos logs
tail -50 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep -i error
```

**Solução:**
```bash
# Reconfigurar API key
sudo -u openclaw openclaw models auth add --agent main
# Cole a API key válida
```

**Causa 2:** dmPolicy está incorreto

**Verificar:**
```bash
sudo -u openclaw cat ~/.openclaw/openclaw.json | grep dmPolicy
```

Deve mostrar: `"dmPolicy": "open"`

**Solução:**
```bash
sudo -u openclaw openclaw config set channels.whatsapp.dmPolicy open
pkill -f openclaw-gateway
sleep 2
sudo -i -u openclaw openclaw gateway &
```

---

### Problema: Mensagem manual não está sendo enviada

**Erro comum:** `Command not found: openclaw message send`

**Solução:** Verificar sintaxe correta:
```bash
sudo -u openclaw openclaw message send \
  --channel whatsapp \
  --target "+5521996255348" \
  --message "Texto aqui"
```

**Erro:** `Channel not connected`

**Solução:**
```bash
# Verificar status do WhatsApp
sudo -u openclaw openclaw channels status

# Reconectar se necessário
sudo -u openclaw openclaw channels login whatsapp
```

---

### Problema: "AI service temporarily overloaded"

**Causa:** API da Anthropic está com muita demanda

**Solução:**
1. Aguardar 1-2 minutos
2. Tentar novamente
3. Se persistir, verificar status: https://status.anthropic.com/

---

## Arquitetura Técnica

```
WhatsApp Message Received
        ↓
OpenClaw Gateway (:18789)
        ↓
Check: dmPolicy=open → ✅ Aceita de todos
        ↓
Agent "main" (Claude Haiku)
        ↓
System Prompt (SOUL.md):
  - IF sender == +555193623832 → Process normally
  - ELSE → Return empty (no response)
        ↓
[Se for owner] → Aureon AI responde
[Se não for owner] → Silêncio (log only)
```

---

## Configuração de Arquivos

### `/home/openclaw/.openclaw/openclaw.json`
```json
{
  "channels": {
    "whatsapp": {
      "dmPolicy": "open",          // Recebe de todos
      "allowFrom": ["*"]
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-3-haiku-20240307"
      }
    }
  }
}
```

### `/home/openclaw/.openclaw/agents/main/agent/SOUL.md`
```markdown
### 1. Resposta Seletiva (CRÍTICO)
**OWNER (Aureon): +555193623832**

QUANDO RECEBER MENSAGEM:
- Se remetente = `+555193623832` → RESPONDA NORMALMENTE
- Se remetente ≠ `+555193623832` → **RETORNE VAZIO**
```

---

## Próximas Melhorias

### Feature: Allowlist Dinâmica
Permitir que você adicione temporariamente números autorizados via comando:

```bash
/allow +5521996255348 1h
# Permite Bruna receber respostas por 1 hora
```

### Feature: Mensagem Automática para Outros
Configurar resposta automática genérica para não-owners:

```
"Obrigado pela mensagem. Este é um bot automatizado.
Para suporte, entre em contato via email@xcompany.com"
```

### Feature: Webhooks de Notificação
Notificar você quando alguém que NÃO é owner enviar mensagem:

```
📩 Nova mensagem de +5521996255348:
"Oi, preciso de ajuda"

Quer que eu responda?
/reply-last [sua mensagem]
```

---

*Última atualização: 2026-03-07*
*Versão: 1.0*
