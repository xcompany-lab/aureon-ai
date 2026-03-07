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

## Remote Management Scripts

Scripts para gerenciar o servidor OpenClaw remotamente via SSH (requer chave SSH configurada).

### Scripts Disponíveis

| Script | Descrição | Uso |
|--------|-----------|-----|
| [remote-restart.sh](remote-restart.sh) | Reinicia OpenClaw e mostra status | `bash integrations/openclaw/remote-restart.sh` |
| [remote-logs.sh](remote-logs.sh) | Visualiza logs (últimas 100 linhas ou tempo real) | `bash integrations/openclaw/remote-logs.sh [linhas] [-f]` |
| [remote-doctor.sh](remote-doctor.sh) | Executa diagnóstico e corrige problemas | `bash integrations/openclaw/remote-doctor.sh [--fix]` |
| [remote-deploy.sh](remote-deploy.sh) | Deploy completo do Aureon AI no servidor | `bash integrations/openclaw/remote-deploy.sh` |
| [remote-restore-backup.sh](remote-restore-backup.sh) | Restaura backup mais recente do config | `bash integrations/openclaw/remote-restore-backup.sh` |

### Exemplos de Uso

```bash
# Reiniciar o serviço remotamente
bash integrations/openclaw/remote-restart.sh

# Ver logs em tempo real
bash integrations/openclaw/remote-logs.sh 50 -f

# Diagnosticar e corrigir problemas
bash integrations/openclaw/remote-doctor.sh --fix

# Fazer deploy completo
bash integrations/openclaw/remote-deploy.sh

# Restaurar backup (se algo quebrar)
bash integrations/openclaw/remote-restore-backup.sh
```

### Configuração SSH Necessária

Para usar os scripts remotos, configure acesso SSH sem senha:

```bash
# 1. Gerar chave SSH (se não existir)
ssh-keygen -t rsa -b 4096 -C "aureon-megabrain" -N ""

# 2. Copiar chave para o servidor
ssh-copy-id root@openclaw-xcompany

# 3. Criar ~/.ssh/config
cat >> ~/.ssh/config << 'EOF'
Host openclaw-xcompany
    HostName openclaw-xcompany.local
    User root
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
EOF

chmod 600 ~/.ssh/config

# 4. Testar
ssh openclaw-xcompany whoami
```

## Comandos de Administração (Local)

Se você estiver conectado diretamente no servidor:

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

## Audio Transcription (OpenAI Whisper)

O Aureon AI transcreve automaticamente áudios do WhatsApp usando OpenAI Whisper.

### Configuração Correta (v2026.2.23+)

```json
{
  "tools": {
    "media": {
      "audio": {
        "enabled": true,
        "maxBytes": 20971520,
        "models": [
          {
            "provider": "openai",
            "model": "gpt-4o-mini-transcribe"
          }
        ]
      }
    }
  }
}
```

**Nota:** A estrutura mudou na versão 2026.2+. Use `models` (array) em vez de configuração direta.

### Requisitos

1. **OPENAI_API_KEY** configurado em `/opt/openclaw.env`
2. Áudios até 20MB (definido em `tools.media.audio.maxBytes`)
3. OpenClaw v2026.2.23 ou superior

### Como Funciona

1. Usuário envia áudio pelo WhatsApp
2. OpenClaw baixa o arquivo (até 20MB)
3. OpenAI transcreve usando `gpt-4o-mini-transcribe`
4. Claude recebe o texto transcrito automaticamente
5. Bot responde normalmente ao conteúdo

### Habilitar em Instalação Existente

```bash
# Script atualizado para v2026.2.23+
bash integrations/openclaw/enable-audio-v2.sh
```

O script vai:
- ✅ Criar backup automático do config
- ✅ Aplicar configuração correta
- ✅ Verificar se OPENAI_API_KEY está configurado
- ✅ Validar com `openclaw doctor`
- ✅ Reiniciar o serviço

### Custos

- OpenAI Whisper: ~$0.006 por minuto de áudio
- Áudio de 30 segundos: ~$0.003
- Áudio de 2 minutos: ~$0.012 (muito barato)

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
