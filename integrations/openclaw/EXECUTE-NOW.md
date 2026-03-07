# 🚀 EXECUTAR AGORA NO SERVIDOR

## Problema Atual

O agente OpenClaw está respondendo, mas **não tem a personalidade Aureon AI**. Ele está perguntando "Quem é você?" em vez de responder como Aureon AI.

## Causa

O `SOUL.md` foi criado mas não foi injetado como `systemPrompt` no `openclaw.json`.

## Solução

Execute os comandos abaixo **como root** no servidor `openclaw-xcompany`:

### Opção 1: Re-deploy Completo (Recomendado)

```bash
# No servidor openclaw-xcompany como root
cd /root
bash deploy-aureon-openclaw.sh
```

### Opção 2: Injeção Direta do SOUL.md

```bash
# No servidor openclaw-xcompany como root
cd /root
bash inject-soul-to-config.sh
```

### Opção 3: Manual (Se scripts não funcionarem)

```bash
# 1. Verificar se SOUL.md existe
cat /home/openclaw/.openclaw/agents/main/agent/SOUL.md

# 2. Injetar manualmente no config
SOUL_CONTENT=$(cat /home/openclaw/.openclaw/agents/main/agent/SOUL.md | jq -Rs .)
jq --argjson soul "$SOUL_CONTENT" \
   '.agents.list[0].systemPrompt = $soul' \
   /home/openclaw/.openclaw/openclaw.json > /tmp/openclaw.json.tmp

mv /tmp/openclaw.json.tmp /home/openclaw/.openclaw/openclaw.json
chown openclaw:openclaw /home/openclaw/.openclaw/openclaw.json

# 3. Reiniciar
systemctl restart openclaw

# 4. Testar
# Enviar no WhatsApp: "Quem é você?"
```

## Resultado Esperado

Após executar qualquer uma das opções acima e enviar "Quem é você?" no WhatsApp, a resposta deve ser:

```
Sou Aureon AI — sistema de inteligência aplicada e execução estratégica.

Opero sobre três pilares:
1. Inteligência aplicada — transformo conhecimento bruto em playbooks acionáveis
2. Execução sem hesitação — estruturo, catalogo e orquestro processos
3. Sistema proprietário — sou arquitetura de ponta, não assistente genérico

Represento a síntese de especialistas (Alex Hormozi, Cole Gordon, Sam Ovens)
em 7 SQUADs operacionais: Sales, Tech, Ops, Marketing, Finance, Research, Exec.
```

## Verificação

### 1. Verificar que SOUL.md está carregado

```bash
su - openclaw
openclaw doctor
```

Procure por indicação de que o system prompt está definido.

### 2. Ver logs em tempo real

```bash
sudo journalctl -u openclaw -f --no-pager
```

### 3. Verificar openclaw.json

```bash
jq '.agents.list[0].systemPrompt' /home/openclaw/.openclaw/openclaw.json | head -n 20
```

Deve mostrar o conteúdo do SOUL.md.

## Troubleshooting

### Se ainda responder genérico:

1. **Cache de sessão:** O OpenClaw pode estar usando cache da sessão anterior
   ```bash
   # Limpar cache (se existir)
   rm -rf /home/openclaw/.openclaw/agents/main/sessions/*
   systemctl restart openclaw
   ```

2. **System prompt não priorizado:** Alguns agentes OpenClaw ignoram systemPrompt se houver SOUL.md
   ```bash
   # Tentar ambos os métodos:
   # a) Via config
   bash inject-soul-to-config.sh

   # b) Via arquivo (já feito no deploy)
   ls -la /home/openclaw/.openclaw/agents/main/agent/SOUL.md
   ```

3. **Verificar ordem de carregamento:**
   ```bash
   su - openclaw
   openclaw agents list --verbose
   ```

### Se o comando `jq` não existir:

```bash
# Instalar jq
apt-get update && apt-get install -y jq
```

## Configuração de Transcrição de Áudio (OpenAI Whisper)

### ✅ CONFIGURADO! (v2026.2.23+)

A transcrição de áudio foi configurada com sucesso usando o script `enable-audio-v2.sh`.

**Configuração aplicada:**
```json
{
  "tools": {
    "media": {
      "audio": {
        "enabled": true,
        "maxBytes": 20971520,
        "models": [{ "provider": "openai", "model": "gpt-4o-mini-transcribe" }]
      }
    }
  }
}
```

### 🧪 Como Testar

1. **Envie um áudio** pelo WhatsApp para `+555193623832`
2. O OpenClaw deve transcrever automaticamente
3. Bot responde ao conteúdo transcrito

### 📊 Ver Logs em Tempo Real

```bash
# Da máquina local
bash integrations/openclaw/remote-logs.sh 50 -f
```

### ⚠️ Se Não Funcionar

**Verificar OPENAI_API_KEY:**
```bash
ssh openclaw-xcompany "cat /opt/openclaw.env | grep OPENAI"
```

**Reconfigurar (se necessário):**
```bash
bash integrations/openclaw/enable-audio-v2.sh
```

**Restaurar backup (se quebrar):**
```bash
bash integrations/openclaw/remote-restore-backup.sh
```

## Próximos Passos Após Sucesso

1. ✅ Personalidade Aureon AI funcionando
2. ✅ Transcrição de áudio via Whisper configurada
3. ⏳ Testar roteamento de SQUADs (enviar "vendas", "tech", etc.)
4. ⏳ Configurar memory search (opcional)
5. ⏳ Adicionar mais números ao allowlist (opcional)

---

**Status:** 🟡 Aguardando execução no servidor
**Última atualização:** 2026-03-07
