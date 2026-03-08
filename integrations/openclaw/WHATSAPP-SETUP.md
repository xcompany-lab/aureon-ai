# WhatsApp Setup Guide - OpenClaw Integration

## Overview

This guide explains how to configure WhatsApp pairing on the OpenClaw server so that Aureon AI can send messages remotely.

## Prerequisites

- ✅ OpenClaw installed and running on server
- ✅ SSH access configured (root@openclaw-xcompany.local)
- ✅ Remote skills deployed (`send_whatsapp.py`)
- ⏳ WhatsApp Web session paired (this guide)

## Current Status

**Issue:**
```
Error: Channel is required (no configured channels detected).
```

**Root Cause:**
WhatsApp Web session is not paired/active on the OpenClaw server.

## Setup Steps

### 1. Start OpenClaw Gateway (if not running)

```bash
ssh openclaw-xcompany

# Check if gateway is running
openclaw doctor

# Start gateway if needed
openclaw gateway
```

### 2. Pair WhatsApp Web

There are two methods:

#### Method A: Via Web UI (Recommended)

```bash
# On server
openclaw gateway --port 3000

# Then open in browser:
http://openclaw-xcompany.local:3000
```

1. Navigate to **Channels** → **Add Channel** → **WhatsApp**
2. Scan QR code with WhatsApp mobile app
3. Wait for pairing confirmation
4. Save channel configuration

#### Method B: Via CLI

```bash
ssh openclaw-xcompany

# Start interactive pairing
openclaw onboard

# Follow prompts to:
# 1. Choose WhatsApp
# 2. Scan QR code
# 3. Confirm pairing
```

### 3. Verify Pairing

```bash
ssh openclaw-xcompany "openclaw channels list --json"
```

**Expected output:**
```json
{
  "chat": {
    "whatsapp": {
      "id": "whatsapp",
      "name": "WhatsApp",
      "status": "connected",
      "number": "+5551XXXXXXXX"
    }
  }
}
```

### 4. Test Message Sending

From your local machine:

```bash
python3 bin/openclaw-send-message.py \
  --to "+5551981503645" \
  --message "Test from Aureon AI" \
  --verbose
```

**Expected output:**
```
✅ Message sent to +5551981503645
```

## Troubleshooting

### Issue: QR Code Not Showing

**Solution:**
```bash
# Restart gateway
ssh openclaw-xcompany "openclaw restart"

# Then try pairing again
ssh openclaw-xcompany "openclaw onboard"
```

### Issue: "Session expired"

**Solution:**
```bash
# Re-authenticate WhatsApp Web
ssh openclaw-xcompany
openclaw channels remove whatsapp
openclaw onboard  # Scan QR code again
```

### Issue: "Multiple state directories detected"

**Solution:**
```bash
# Consolidate to single state directory
ssh openclaw-xcompany

# Backup old state
cp -r ~/.openclaw ~/.openclaw.backup

# Remove duplicate
rm -rf /home/aureon/.openclaw

# Restart gateway
openclaw restart
```

### Issue: "Permission denied" on send

**Solution:**
```bash
# Check OpenClaw permissions
ssh openclaw-xcompany "openclaw doctor --fix"

# Verify SSH key permissions locally
chmod 600 ~/.ssh/id_ed25519
```

## Configuration Files

### Local Environment (`.env`)

```bash
OPENCLAW_REMOTE_HOST=openclaw-xcompany.local
OPENCLAW_REMOTE_USER=root
OPENCLAW_SSH_KEY=/home/aureon/.ssh/id_ed25519
OPENCLAW_GATEWAY_URL=http://openclaw-xcompany.local:3000
```

### Remote OpenClaw Config

Location: `~/.openclaw/openclaw.json`

Relevant sections:
```json
{
  "gateway": {
    "mode": "local",
    "port": 3000
  },
  "channels": {
    "whatsapp": {
      "enabled": true,
      "autoConnect": true
    }
  }
}
```

## Architecture

```
User Request
    ↓
Aureon AI (Claude Code)
    ↓ Skill: /send-whatsapp
bin/openclaw-send-message.py
    ↓ SSH
OpenClaw Server
    ↓ /home/openclaw/aureon-skills/send_whatsapp.py
OpenClaw Gateway
    ↓ openclaw message send --target X --message Y
WhatsApp Web Session
    ↓
Recipient's WhatsApp
```

## Security Notes

1. **WhatsApp Web Session:**
   - Expires after ~14 days of inactivity
   - Requires re-pairing via QR code
   - Limited to 1 active web session per phone

2. **SSH Access:**
   - Uses public key authentication (no passwords)
   - Key location: `~/.ssh/id_ed25519`
   - Encrypted transport (SSH protocol)

3. **Message Privacy:**
   - Messages transmitted over SSH tunnel
   - No message logging on Aureon AI side
   - OpenClaw logs controlled by server config

## Next Steps

Once WhatsApp is paired:

1. ✅ Test basic message sending
2. ✅ Add skill to Claude Code (`/send-whatsapp`)
3. ✅ Test via natural language ("Send message to Kethely")
4. ⏭️ Add media file support (images, PDFs)
5. ⏭️ Add group message support
6. ⏭️ Add message templates

## Support

**OpenClaw Docs:**
https://docs.openclaw.ai/channels/whatsapp

**Aureon AI Skills:**
`integrations/openclaw/skills/send_whatsapp.py`

**Local Script:**
`bin/openclaw-send-message.py`

**Claude Code Skill:**
`.claude/skills/send-whatsapp/SKILL.md`

## Quick Reference

```bash
# Check status
bash integrations/openclaw/remote-doctor.sh

# View logs
bash integrations/openclaw/remote-logs.sh 50

# Restart gateway
bash integrations/openclaw/remote-restart.sh

# Send test message
python3 bin/openclaw-send-message.py \
  --to "Kethely" \
  --message "Test" \
  --verbose
```

## Pairing Checklist

- [ ] OpenClaw gateway running
- [ ] Navigate to web UI or run `openclaw onboard`
- [ ] Scan QR code with WhatsApp mobile
- [ ] Verify connection: `openclaw channels list`
- [ ] Test message send
- [ ] Save configuration (auto-saved)
- [ ] Document phone number in `.env`

---

**Status:** 🟡 Infrastructure ready, pending WhatsApp pairing
**Last updated:** 2026-03-08
**Author:** Aureon AI
