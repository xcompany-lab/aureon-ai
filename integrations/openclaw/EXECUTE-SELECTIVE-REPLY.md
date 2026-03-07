# 🚀 EXECUÇÃO IMEDIATA — Selective Reply Mode

## O Que Você Vai Conseguir

✅ **Você (+555193623832):** Bot responde tudo, conversa normalmente, executa comandos
✅ **Outros números:** Bot recebe e registra, mas **NÃO responde** automaticamente
✅ **Envio manual:** Você pode mandar o bot enviar para qualquer número

---

## Passo a Passo (5 minutos)

### 1. No Terminal SSH do Servidor

Você já está conectado em `root@openclaw-xcompany`, certo?

Execute APENAS este comando:

```bash
bash /tmp/deploy-selective-reply.sh
```

**O que vai acontecer:**
- Script atualiza configuração OpenClaw
- Configura SOUL.md com regra de resposta seletiva
- Define modelo claude-3-haiku-20240307
- Reinicia gateway
- Mostra status final

⏱️ Tempo: ~30 segundos

---

### 2. Configurar API Key (se ainda não fez)

Se o script mostrar `⚠️ API key NÃO configurada`, execute:

```bash
sudo -u openclaw openclaw models auth add --agent main
```

Quando pedir:
1. **Token provider:** anthropic (Enter)
2. **Token method:** paste token (Enter)
3. **Profile ID:** (Enter - aceita padrão)
4. **Does this token expire:** No (Enter)
5. **Paste token:** Cole sua API key Anthropic válida

---

### 3. Testar

#### Teste A: Você Envia
Envie qualquer mensagem do seu WhatsApp (+555193623832)

**Resultado esperado:** Bot responde normalmente ✅

#### Teste B: Outro Número Envia
Peça para Bruna ou outra pessoa enviar "oi"

**Resultado esperado:** Bot **NÃO responde** (silêncio total) ✅

**Ver nos logs:**
```bash
tail -20 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
```

Deve mostrar "Inbound message" mas sem resposta.

---

### 4. Enviar Mensagem Manual (quando quiser)

```bash
sudo -u openclaw openclaw message send \
  --channel whatsapp \
  --target "+5521996255348" \
  --message "Oi Bruna, teste do Aureon AI"
```

---

## Comandos Úteis

### Ver Logs em Tempo Real
```bash
tail -f /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log
```

### Verificar Status Gateway
```bash
ps aux | grep openclaw-gateway | grep -v grep
```

### Reiniciar Gateway (se necessário)
```bash
pkill -f openclaw-gateway
sleep 2
sudo -i -u openclaw openclaw gateway &
```

---

## Troubleshooting Rápido

### Bot não está respondendo ninguém (nem você)

**1. Verificar logs:**
```bash
tail -50 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep -i error
```

**2. Se aparecer "401 authentication_error":**
```bash
sudo -u openclaw openclaw models auth add --agent main
# Cole API key válida
pkill -f openclaw-gateway
sleep 2
sudo -i -u openclaw openclaw gateway &
```

**3. Se aparecer "Unknown model":**
```bash
sudo -u openclaw openclaw config set agents.defaults.model.primary anthropic/claude-3-haiku-20240307
pkill -f openclaw-gateway
sleep 2
sudo -i -u openclaw openclaw gateway &
```

---

### Bot está respondendo todos os números

**Verificar SOUL.md:**
```bash
sudo -u openclaw grep "Resposta Seletiva" ~/.openclaw/agents/main/agent/SOUL.md
```

Se não aparecer nada, re-executar deploy:
```bash
bash /tmp/deploy-selective-reply.sh
```

---

## Próximo: Fazer Upload do Script

Se você ainda **não fez upload** do script para o servidor, execute no seu terminal LOCAL (máquina aureon):

```bash
scp integrations/openclaw/deploy-selective-reply.sh root@openclaw-xcompany:/tmp/
```

Depois execute no servidor:
```bash
ssh root@openclaw-xcompany
bash /tmp/deploy-selective-reply.sh
```

---

## Documentação Completa

Veja: `integrations/openclaw/SELECTIVE-REPLY-GUIDE.md`

- Arquitetura técnica detalhada
- Troubleshooting completo
- Próximas melhorias (allowlist dinâmica, webhooks)

---

*Criado: 2026-03-07*
*Versão: 1.0*
