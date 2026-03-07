#!/usr/bin/env bash
# remote-restore-backup.sh
# Restaura o backup mais recente do openclaw.json
set -e

SERVER="openclaw-xcompany"
CONFIG_PATH="/home/openclaw/.openclaw/openclaw.json"

echo "♻️  Restaurar Backup — OpenClaw Config"
echo "======================================"
echo "Servidor: $SERVER"
echo ""

# 1. Listar backups disponíveis
echo "📦 Backups disponíveis:"
echo "======================"
ssh $SERVER "ls -lht $CONFIG_PATH.backup-* 2>/dev/null || echo 'Nenhum backup encontrado'"

echo ""
echo "🔍 Selecionando backup mais recente..."

# 2. Pegar o backup mais recente
LATEST_BACKUP=$(ssh $SERVER "ls -t $CONFIG_PATH.backup-* 2>/dev/null | head -n 1")

if [ -z "$LATEST_BACKUP" ]; then
  echo "❌ ERRO: Nenhum backup encontrado em $CONFIG_PATH.backup-*"
  exit 1
fi

echo "✅ Backup selecionado: $LATEST_BACKUP"
echo ""

# 3. Confirmar restauração
echo "⚠️  ATENÇÃO: Isso irá sobrescrever a configuração atual!"
echo ""
read -p "Deseja continuar? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "❌ Operação cancelada."
  exit 0
fi

# 4. Restaurar backup
echo ""
echo "♻️  Restaurando backup..."
ssh $SERVER "cp '$LATEST_BACKUP' '$CONFIG_PATH' && chown openclaw:openclaw '$CONFIG_PATH' && chmod 600 '$CONFIG_PATH'"

echo "✅ Backup restaurado!"
echo ""

# 5. Reiniciar serviço
echo "🔄 Reiniciando OpenClaw..."
ssh $SERVER "systemctl restart openclaw"
sleep 3

echo ""
echo "📊 Status final:"
ssh $SERVER "systemctl status openclaw --no-pager"

echo ""
echo "✅ Configuração restaurada e serviço reiniciado!"
echo ""
echo "💡 Próximos passos:"
echo "   - Teste no WhatsApp"
echo "   - Ver logs: bash integrations/openclaw/remote-logs.sh"
