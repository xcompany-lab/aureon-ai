#!/bin/bash
#
# Aureon AI - Remote Send WhatsApp Message
# Wrapper script to send WhatsApp messages via SSH to OpenClaw server
#
# Usage:
#   bash integrations/openclaw/remote-send-message.sh "+5551981503645" "Hello!"
#   bash integrations/openclaw/remote-send-message.sh "Kethely" "Oi amor!"
#

set -e

# Configuration
REMOTE_HOST="${OPENCLAW_REMOTE_HOST:-openclaw-xcompany.local}"
REMOTE_USER="${OPENCLAW_REMOTE_USER:-root}"
REMOTE_SCRIPT="/home/openclaw/aureon-skills/send_whatsapp.py"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Usage: $0 RECIPIENT MESSAGE${NC}"
    echo ""
    echo "Examples:"
    echo "  $0 '+5551981503645' 'Hello from Aureon!'"
    echo "  $0 'Kethely' 'Oi meu amor!'"
    exit 1
fi

RECIPIENT="$1"
MESSAGE="$2"

echo -e "${YELLOW}📱 Sending WhatsApp message...${NC}"
echo "   To: $RECIPIENT"
echo "   Message: ${MESSAGE:0:50}${MESSAGE:50:+...}"
echo ""

# Execute remote command
ssh "${REMOTE_USER}@${REMOTE_HOST}" "python3 ${REMOTE_SCRIPT} '$RECIPIENT' '$MESSAGE'" && {
    echo -e "${GREEN}✅ Message sent successfully!${NC}"
    exit 0
} || {
    echo -e "${RED}❌ Failed to send message${NC}"
    exit 1
}
