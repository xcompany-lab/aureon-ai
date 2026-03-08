---
triggers:
  - enviar mensagem
  - mandar mensagem
  - send message
  - whatsapp
  - mandar whatsapp
  - enviar whatsapp
  - manda uma mensagem
  - manda um oi
skill_name: send-whatsapp
version: "1.0.0"
description: Send WhatsApp messages via remote OpenClaw server
created_at: 2026-03-08
author: Aureon AI
tags: [whatsapp, messaging, openclaw, remote]
---

# Send WhatsApp Skill

Send WhatsApp messages to contacts via the remote OpenClaw server.

## When to Activate

This skill activates when the user wants to:
- Send a WhatsApp message to someone
- Send a text message via WhatsApp
- Contact someone through WhatsApp
- Send greetings or messages to known contacts

## Trigger Examples

- "Envie uma mensagem para Kethely dizendo: Oi amor!"
- "Manda um oi pra Kethely"
- "Send a WhatsApp message to +5551981503645"
- "Mandar mensagem no WhatsApp para minha esposa"

## How to Use

### Step 1: Identify Recipient and Message

Extract from user's request:
- **Recipient**: Name (e.g., "Kethely") or phone number (e.g., "+5551981503645")
- **Message**: The text to send

### Step 2: Execute Python Script

Use the Bash tool to run:

```bash
python3 bin/openclaw-send-message.py --to "RECIPIENT" --message "MESSAGE" --verbose
```

**Parameters:**
- `--to`: Recipient name or phone number (E.164 format with +)
- `--message`: Message text (wrap in quotes)
- `--verbose`: Show detailed execution info (optional)
- `--json`: Output as JSON (optional)

### Step 3: Handle Response

**Success:**
```
✅ Message sent to Kethely
```

**Failure:**
```
❌ Failed to send message: SSH connection failed
```

## Known Contacts

The script has built-in contact mapping:

| Name | Phone Number |
|------|--------------|
| Kethely | +5551981503645 |
| Aureon | +5551981503645 |

You can use names instead of phone numbers for known contacts.

## Examples

### Example 1: Send by Name

**User:** "Envie uma mensagem para Kethely dizendo: Oi meu amor, tudo bem?"

**Assistant Action:**
```bash
python3 bin/openclaw-send-message.py \
  --to "Kethely" \
  --message "Oi meu amor, tudo bem?" \
  --verbose
```

**Expected Output:**
```
📱 Sending WhatsApp message...
   To: +5551981503645
   Message: Oi meu amor, tudo bem?
   SSH: openclaw@openclaw-xcompany.local
✅ Message sent successfully!
```

### Example 2: Send by Phone Number

**User:** "Send a message to +5551981503645 saying: Hello from Aureon AI!"

**Assistant Action:**
```bash
python3 bin/openclaw-send-message.py \
  --to "+5551981503645" \
  --message "Hello from Aureon AI!" \
  --verbose
```

### Example 3: Quick Greeting

**User:** "Manda um oi pra Kethely"

**Assistant Action:**
```bash
python3 bin/openclaw-send-message.py \
  --to "Kethely" \
  --message "Oi! 👋"
```

## Technical Details

### Architecture

```
Aureon AI (local)
    ↓
bin/openclaw-send-message.py
    ↓ SSH
OpenClaw Server (remote)
    ↓
/home/openclaw/aureon-skills/send_whatsapp.py
    ↓
WhatsApp Gateway
    ↓
Recipient's WhatsApp
```

### Environment Variables

Required in `.env`:

```bash
OPENCLAW_REMOTE_HOST=openclaw-xcompany.local
OPENCLAW_REMOTE_USER=openclaw
OPENCLAW_SSH_KEY=/home/aureon/.ssh/id_ed25519
```

### Remote Script

The remote script (`send_whatsapp.py`) must exist on the OpenClaw server at:
```
/home/openclaw/aureon-skills/send_whatsapp.py
```

## Error Handling

### Common Errors

**SSH Connection Failed:**
- Check SSH key permissions: `chmod 600 ~/.ssh/id_ed25519`
- Verify SSH config: `ssh openclaw-xcompany whoami`
- Check network connectivity

**Remote Script Not Found:**
- Deploy skills to server: `bash integrations/openclaw/remote-deploy.sh`
- Verify path: `ssh openclaw-xcompany "ls -l /home/openclaw/aureon-skills/"`

**Invalid Phone Number:**
- Use E.164 format: +[country code][number]
- Example: +5551981503645 (Brazil)

**Timeout:**
- Check OpenClaw gateway status: `bash integrations/openclaw/remote-doctor.sh`
- Verify WhatsApp connection

## Response Template

When successfully sending a message, respond to the user:

```
✅ Mensagem enviada com sucesso para [RECIPIENT]!

Conteúdo: "[MESSAGE]"
```

When failing:

```
❌ Não consegui enviar a mensagem para [RECIPIENT].

Erro: [ERROR_DETAILS]

Você pode tentar novamente ou verificar a conexão com o servidor OpenClaw.
```

## Integration with Other Skills

This skill can be combined with:
- **remote-execute**: Check server status before sending
- **drive-access**: Send files from Drive as messages (future feature)
- **squad-activation**: Sales team can send messages to leads

## Security Notes

- Phone numbers are not logged in plain text
- Messages are transmitted over SSH (encrypted)
- No credentials are stored in the script
- SSH key authentication required (no passwords)

## Limitations

- Maximum message length: 4096 characters (WhatsApp limit)
- Rate limit: ~10 messages per minute (OpenClaw gateway)
- Media files not supported yet (text only)
- Requires OpenClaw gateway to be running

## Future Enhancements

- [ ] Send media files (images, PDFs, audio)
- [ ] Group message support
- [ ] Message templates
- [ ] Scheduled messages
- [ ] Read receipts and delivery status
- [ ] Contact sync from Google Contacts

## Support

If this skill fails repeatedly:

1. Check remote logs: `bash integrations/openclaw/remote-logs.sh 50`
2. Run diagnostics: `bash integrations/openclaw/remote-doctor.sh --fix`
3. Restart gateway: `bash integrations/openclaw/remote-restart.sh`

For debugging, use `--verbose` and `--json` flags together:

```bash
python3 bin/openclaw-send-message.py \
  --to "Kethely" \
  --message "Test" \
  --verbose \
  --json
```
