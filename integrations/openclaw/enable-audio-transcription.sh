#!/usr/bin/env bash
# enable-audio-transcription.sh
# Fix rápido para habilitar transcrição de áudio em instalação existente do OpenClaw
set -e

OPENCLAW_HOME="/home/openclaw/.openclaw"
CONFIG_FILE="$OPENCLAW_HOME/openclaw.json"

echo "🎙️ Habilitando Transcrição de Áudio — OpenClaw"
echo "=============================================="

# 1. Validar que openclaw.json existe
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ ERRO: $CONFIG_FILE não encontrado"
  echo "   Execute deploy-aureon-openclaw.sh primeiro"
  exit 1
fi

# 2. Backup do config atual
echo "📦 Criando backup..."
cp "$CONFIG_FILE" "$CONFIG_FILE.backup-$(date +%Y%m%d-%H%M%S)"

# 3. Adicionar seção tools.media.audio usando jq (ou python se jq não disponível)
echo "🔧 Injetando configuração de transcrição..."
if command -v jq &> /dev/null; then
  # Método 1: usando jq (mais seguro)
  jq '.tools.media.audio = {
    "provider": "openai",
    "model": "whisper-1",
    "echoTranscript": true,
    "echoFormat": "📝 Transcrição: {transcript}"
  }' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
else
  # Método 2: usando python (fallback)
  python3 << PYTHON_EOF
import json
with open('$CONFIG_FILE', 'r') as f:
  config = json.load(f)

if 'tools' not in config:
  config['tools'] = {}

if 'media' not in config['tools']:
  config['tools']['media'] = {}

config['tools']['media']['audio'] = {
  "provider": "openai",
  "model": "whisper-1",
  "echoTranscript": True,
  "echoFormat": "📝 Transcrição: {transcript}"
}

with open('$CONFIG_FILE', 'w') as f:
  json.dump(config, f, indent=2)
PYTHON_EOF
fi

# 4. Configurar OPENAI_API_KEY
echo "🔑 Configurando OPENAI_API_KEY..."
if [ -f /opt/openclaw.env ]; then
  # Remover linha antiga se existir
  sed -i '/^OPENAI_API_KEY=/d' /opt/openclaw.env

  # Perguntar ao usuário
  echo ""
  echo "📝 Por favor, cole sua OPENAI_API_KEY:"
  read -r OPENAI_KEY

  if [ -n "$OPENAI_KEY" ]; then
    echo "OPENAI_API_KEY=$OPENAI_KEY" >> /opt/openclaw.env
    echo "✅ OPENAI_API_KEY configurado em /opt/openclaw.env"
  else
    echo "⚠️  Nenhuma key fornecida. Adicione manualmente em /opt/openclaw.env"
  fi
else
  echo "⚠️  /opt/openclaw.env não encontrado. Crie manualmente com:"
  echo "   OPENAI_API_KEY=sk-proj-..."
fi

# 5. Aplicar permissões
chmod 600 "$CONFIG_FILE"
chown openclaw:openclaw "$CONFIG_FILE"

# 6. Validar config
echo "🔍 Validando configuração..."
sudo -u openclaw HOME=/home/openclaw /usr/bin/openclaw doctor --non-interactive || true

# 7. Reiniciar gateway
echo "🔄 Reiniciando gateway..."
systemctl restart openclaw
sleep 3

# 8. Status final
echo ""
echo "✅ Transcrição de áudio HABILITADA!"
echo ""
echo "📊 Status:"
sudo -u openclaw HOME=/home/openclaw /usr/bin/openclaw doctor --non-interactive || true

echo ""
echo "🎙️ TESTE:"
echo "   Envie um áudio pelo WhatsApp para +555193623832"
echo "   O bot responderá com: '📝 Transcrição: [seu texto]'"
echo ""
echo "💡 Backup salvo em: $CONFIG_FILE.backup-*"
