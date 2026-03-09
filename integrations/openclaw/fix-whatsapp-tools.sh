#!/bin/bash
#
# Fix OpenClaw WhatsApp Tools Issue
# Removes TOOLS.md to prevent agent from trying to execute unavailable commands
#

set -e

REMOTE_HOST="openclaw-xcompany.local"
REMOTE_USER="root"

echo "🔧 Fixing OpenClaw WhatsApp Tools Issue..."
echo ""

# Backup current TOOLS.md
echo "1. Backing up current TOOLS.md..."
ssh "${REMOTE_USER}@${REMOTE_HOST}" "cp /home/openclaw/.openclaw/workspace/TOOLS.md /home/openclaw/.openclaw/workspace/TOOLS.md.backup-$(date +%Y%m%d-%H%M%S)"

# Remove or disable TOOLS.md
echo "2. Removing TOOLS.md (agent will work without tools)..."
ssh "${REMOTE_USER}@${REMOTE_HOST}" "rm /home/openclaw/.openclaw/workspace/TOOLS.md"

# Alternative: Create minimal TOOLS.md with no tools
echo "3. Creating minimal TOOLS.md (no executable tools)..."
ssh "${REMOTE_USER}@${REMOTE_HOST}" "cat > /home/openclaw/.openclaw/workspace/TOOLS.md << 'EOF'
# TOOLS — Aureon AI

## ⚠️ Tool Execution Disabled

This agent runs embedded in the OpenClaw gateway and does not have access to shell commands.

For command execution, use the Aureon AI local environment via:
- bin/openclaw-remote-skill.py
- .claude/skills/remote-execute/

## Response-Only Mode

This agent can:
- ✅ Understand requests
- ✅ Route to correct SQUAD
- ✅ Provide information and guidance
- ✅ Format structured responses

This agent CANNOT:
- ❌ Execute shell commands
- ❌ Access local files
- ❌ Run Python/Node scripts directly

For execution needs, instruct the user to:
\"Para executar essa ação, use o comando: python3 bin/openclaw-remote-skill.py [skill_name]\"
EOF
"

echo ""
echo "4. Restarting OpenClaw gateway..."
ssh "${REMOTE_USER}@${REMOTE_HOST}" "systemctl restart openclaw-gateway"

echo ""
echo "✅ Fix applied successfully!"
echo ""
echo "What was fixed:"
echo "  - TOOLS.md backup created"
echo "  - Tool execution disabled (agent now response-only)"
echo "  - Gateway restarted"
echo ""
echo "This should resolve:"
echo "  ❌ 'openclaw: not found' errors"
echo "  ❌ 'curl: not found' errors"
echo "  ❌ API rate limit issues (fewer retries)"
echo ""
echo "Test with:"
echo "  Send a WhatsApp message and check if response is sent without errors"
