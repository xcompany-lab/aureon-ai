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

## Configuração de Transcrição de Áudio (Whisper)

### Problema: Áudios não são transcritos

Se você enviar áudios pelo WhatsApp e o bot não entender, é porque falta configurar o Whisper.

### Solução Rápida

```bash
# No servidor openclaw-xcompany como root
cd /root
bash enable-audio-transcription.sh
```

O script vai:
1. Adicionar configuração `tools.media.audio` no `openclaw.json`
2. Solicitar sua `OPENAI_API_KEY` e salvar em `/opt/openclaw.env`
3. Reiniciar o gateway
4. Validar a configuração

### Configuração Manual (alternativa)

Se preferir configurar manualmente:

```bash
# 1. Editar /opt/openclaw.env
nano /opt/openclaw.env

# Adicionar linha:
OPENAI_API_KEY=sk-proj-...

# 2. Editar openclaw.json
jq '.tools.media.audio = {
  "provider": "openai",
  "model": "whisper-1",
  "echoTranscript": true,
  "echoFormat": "📝 Transcrição: {transcript}"
}' /home/openclaw/.openclaw/openclaw.json > /tmp/openclaw.json.tmp

mv /tmp/openclaw.json.tmp /home/openclaw/.openclaw/openclaw.json
chown openclaw:openclaw /home/openclaw/.openclaw/openclaw.json

# 3. Reiniciar
systemctl restart openclaw

# 4. Testar
# Envie um áudio pelo WhatsApp
```

### Verificação

Após configurar, envie um áudio pelo WhatsApp. Você deve receber:

```
📝 Transcrição: [seu texto aqui]
```

E então o bot responde ao conteúdo transcrito.

## Próximos Passos Após Sucesso

1. ✅ Personalidade Aureon AI funcionando
2. ✅ Transcrição de áudio via Whisper configurada
3. ⏳ Testar roteamento de SQUADs (enviar "vendas", "tech", etc.)
4. ⏳ Configurar memory search (opcional)
5. ⏳ Adicionar mais números ao allowlist (opcional)

---

**Status:** 🟡 Aguardando execução no servidor
**Última atualização:** 2026-03-07
