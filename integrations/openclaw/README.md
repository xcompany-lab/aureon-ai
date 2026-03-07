# Aureon AI ↔ OpenClaw Integration

## Overview

Integração completa do Aureon AI com OpenClaw para operação via WhatsApp. O Aureon AI opera como agente `main` do OpenClaw, recebendo mensagens do WhatsApp e respondendo com personalidade e SQUADs configurados.

## Arquitetura

```
WhatsApp (usuário)
      ↓
OpenClaw Gateway (:18789)
      ↓
Agente "main" (Claude claude-opus)
      ↓  personalidade via SOUL.md + AGENTS.md
Aureon AI → SQUAD Router → Especialista
      ↓
Resposta → WhatsApp
```

## Arquivos de Configuração

| Arquivo | Propósito |
|---------|-----------|
| `/opt/openclaw.env` | Variáveis do serviço (ANTHROPIC_API_KEY, portas, token) |
| `~/.openclaw/openclaw.json` | Configuração de agentes, modelo, allowlist WhatsApp |
| `~/.openclaw/agents/main/agent/SOUL.md` | Personalidade do Aureon AI |
| `~/.openclaw/agents/main/agent/AGENTS.md` | SQUADs, comandos e regras de roteamento |

## Configuração Atual

```json
{
  "channels": {
    "whatsapp": {
      "dmPolicy": "allowlist",
      "allowFrom": ["+555193623832"]
    }
  },
  "agents": {
    "defaults": {
      "model": { "primary": "anthropic/claude-opus-4-5" }
    }
  }
}
```

## Comandos de Administração

```bash
# Status do canal WhatsApp
openclaw channels status --probe

# Reiniciar gateway
sudo systemctl restart openclaw

# Ver logs em tempo real
sudo journalctl -u openclaw -f --no-pager

# Listar agentes e bindings
openclaw agents list --bindings
```

## Audio Transcription (Whisper)

O Aureon AI transcreve automaticamente áudios do WhatsApp usando OpenAI Whisper.

### Configuração

```json
{
  "tools": {
    "media": {
      "audio": {
        "provider": "openai",
        "model": "whisper-1",
        "echoTranscript": true,
        "echoFormat": "📝 Transcrição: {transcript}"
      }
    }
  }
}
```

### Requisitos

1. **OPENAI_API_KEY** configurado em `/opt/openclaw.env`
2. Áudios até 50MB (definido em `channels.whatsapp.mediaMaxMb`)

### Como Funciona

1. Usuário envia áudio pelo WhatsApp
2. OpenClaw baixa o arquivo
3. Whisper transcreve automaticamente
4. Bot envia confirmação: `📝 Transcrição: [texto]`
5. Claude processa o texto transcrito normalmente

### Habilitar em Instalação Existente

```bash
# Método 1: Script standalone (recomendado)
bash enable-audio-transcription.sh

# Método 2: Redeploy completo
bash deploy-aureon-openclaw.sh
```

### Custos

- Whisper: ~$0.006 por minuto de áudio
- Áudio de 30 segundos: ~$0.003 (muito barato)

## Comandos disponíveis no WhatsApp

| Comando | Ação |
|---------|------|
| `/status` | Status do sistema e squads |
| `/sales` | Ativa o Sales Squad |
| `/exec` | Ativa o Exec Squad |
| `/ops` | Ativa o Ops Squad |
| `/marketing` | Ativa o Marketing Squad |
| `/tech` | Ativa o Tech Squad |
| `/research` | Ativa o Research Squad |
| `/finance` | Ativa o Finance Squad |
| `/help` | Lista todos os comandos |

## Segurança

- **dmPolicy: allowlist** — apenas `+555193623832` pode enviar DMs
- **Groups:** requer menção `@aureon` para responder em grupos
- **Token de gateway:** `e9c841c7...` (em `/opt/openclaw.env`, não versionar)

## Deployment

### No servidor remoto (openclaw-xcompany):

```bash
# 1. Upload do script
scp deploy-aureon-openclaw.sh root@openclaw-xcompany:/root/

# 2. Executar como root
ssh root@openclaw-xcompany
bash /root/deploy-aureon-openclaw.sh
```

### O que o script faz:

1. ✅ Cria estrutura de diretórios
2. ✅ Grava SOUL.md (personalidade Aureon AI)
3. ✅ Grava IDENTITY.md (identidade visual)
4. ✅ Grava AGENTS.md (guia de SQUADs)
5. ✅ Cria openclaw.json (SEM chaves inválidas)
6. ✅ Executa `openclaw doctor --fix`
7. ✅ Configura `gateway.mode = local`
8. ✅ Sincroniza identidade visual
9. ✅ Aplica permissões corretas
10. ✅ Reinicia serviço systemd

## Post-Deployment Steps

### 1. Configurar Token Anthropic

```bash
su - openclaw
openclaw setup-token
# Cole a API key quando solicitado
```

### 2. Verificar Environment Variables

```bash
cat /opt/openclaw.env
# Se necessário, editar:
sudo nano /opt/openclaw.env
```

### 3. Reiniciar e Validar

```bash
sudo systemctl restart openclaw
su - openclaw
openclaw doctor
```

### 4. Testar WhatsApp

Enviar: `Quem é você?`

Resposta esperada: `Sou Aureon AI — sistema de inteligência aplicada...`

## Troubleshooting

### "Invalid config: Unrecognized key"
```bash
su - openclaw
openclaw doctor --fix
```

### "Gateway not running"
```bash
sudo systemctl status openclaw
sudo systemctl restart openclaw
sudo journalctl -u openclaw -f
```

### "Missing auth: anthropic"
```bash
su - openclaw
openclaw setup-token
# OU editar /opt/openclaw.env
```

### "Port 18789 already in use"
```bash
sudo lsof -i :18789
sudo systemctl stop openclaw
sudo pkill -f openclaw
sudo systemctl start openclaw
```

## Expansão Futura

- Adicionar mais números ao `allowFrom` para acesso por terceiros autorizados
- Criar agente separado (`biz`) com número/conta WhatsApp Business diferente
- Integrar com `Broadcast groups` para notificações ativas
- Habilitar memory search com embedding provider
