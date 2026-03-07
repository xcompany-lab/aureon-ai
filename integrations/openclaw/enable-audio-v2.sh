#!/usr/bin/env bash
# enable-audio-v2.sh
# Habilita transcrição de áudio com configuração correta para OpenClaw v2026.2.23+
set -e

SERVER="openclaw-xcompany"
CONFIG_PATH="/home/openclaw/.openclaw/openclaw.json"
ENV_FILE="/opt/openclaw.env"

echo "🎙️ OpenClaw Audio Transcription Setup v2"
echo "=========================================="
echo "Versão: 2026.2.23+"
echo "Provider: OpenAI Whisper (gpt-4o-mini-transcribe)"
echo ""

# 1. Backup do config atual
echo "📦 Criando backup..."
ssh $SERVER "cp '$CONFIG_PATH' '$CONFIG_PATH.backup-\$(date +%Y%m%d-%H%M%S)'"

# 2. Adicionar configuração de áudio usando Python (mais confiável que jq)
echo "🔧 Aplicando configuração de áudio..."
cat << 'PYTHON_SCRIPT' | ssh $SERVER "python3"
import json

CONFIG_FILE = '/home/openclaw/.openclaw/openclaw.json'

# Ler config atual
with open(CONFIG_FILE, 'r') as f:
    config = json.load(f)

# Adicionar tools.media.audio
if 'tools' not in config:
    config['tools'] = {}

if 'media' not in config['tools']:
    config['tools']['media'] = {}

config['tools']['media']['audio'] = {
    "enabled": True,
    "maxBytes": 20971520,  # 20MB
    "models": [
        {
            "provider": "openai",
            "model": "gpt-4o-mini-transcribe"
        }
    ]
}

# Salvar
with open(CONFIG_FILE, 'w') as f:
    json.dump(config, f, indent=2)

print("✅ Configuração de áudio aplicada!")
PYTHON_SCRIPT

# 3. Configurar OPENAI_API_KEY
echo ""
echo "🔑 Configurando OPENAI_API_KEY..."

# Verificar se já existe
EXISTING_KEY=$(ssh $SERVER "grep '^OPENAI_API_KEY=' '$ENV_FILE' 2>/dev/null || echo ''")

if [ -n "$EXISTING_KEY" ]; then
    echo "✅ OPENAI_API_KEY já configurado em $ENV_FILE"
else
    echo "⚠️  OPENAI_API_KEY não encontrado em $ENV_FILE"
    echo ""
    echo "📝 Cole sua OPENAI_API_KEY (ou pressione Enter para configurar manualmente depois):"
    read -r OPENAI_KEY

    if [ -n "$OPENAI_KEY" ]; then
        ssh $SERVER "echo 'OPENAI_API_KEY=$OPENAI_KEY' >> '$ENV_FILE'"
        echo "✅ OPENAI_API_KEY adicionado a $ENV_FILE"
    else
        echo "⏭️  Pulado. Configure manualmente:"
        echo "   ssh $SERVER"
        echo "   echo 'OPENAI_API_KEY=sk-proj-...' >> $ENV_FILE"
    fi
fi

# 4. Validar permissões
echo ""
echo "🔒 Ajustando permissões..."
ssh $SERVER "chmod 600 '$CONFIG_PATH' && chown openclaw:openclaw '$CONFIG_PATH'"

# 5. Validar config
echo ""
echo "🔍 Validando configuração..."
ssh $SERVER "sudo -u openclaw HOME=/home/openclaw /usr/bin/openclaw doctor --non-interactive" || echo "⚠️  Validação com avisos (verifique logs)"

# 6. Reiniciar serviço
echo ""
echo "🔄 Reiniciando OpenClaw..."
ssh $SERVER "systemctl restart openclaw"
sleep 5

# 7. Status final
echo ""
echo "📊 Status do serviço:"
ssh $SERVER "systemctl status openclaw --no-pager -l" || true

echo ""
echo "✅ Configuração completa!"
echo ""
echo "🎙️ TESTE DE ÁUDIO:"
echo "   1. Envie um áudio pelo WhatsApp"
echo "   2. O OpenClaw deve transcrever automaticamente"
echo "   3. Verifique os logs: bash integrations/openclaw/remote-logs.sh 50 -f"
echo ""
echo "📚 Configuração aplicada:"
echo "   Provider: OpenAI"
echo "   Model: gpt-4o-mini-transcribe"
echo "   Max size: 20MB"
echo ""
echo "💰 Custos estimados:"
echo "   - ~\$0.006 por minuto de áudio"
echo "   - Áudio de 1 min: ~\$0.006"
echo ""
echo "💡 Se não funcionar, verifique:"
echo "   - OPENAI_API_KEY está correto em $ENV_FILE"
echo "   - Logs: bash integrations/openclaw/remote-logs.sh 100"
