---
triggers:
  - status do servidor
  - ver logs
  - executar no servidor
  - rodar no openclaw
  - checar servidor
  - server status
  - remote execution
  - execute remotely
skill_name: remote-execute
version: "1.0.0"
description: Execute OpenClaw skills on remote server via SSH or HTTP
created_at: 2026-03-08
author: Aureon AI
tags: [openclaw, remote, ssh, execution, server]
---

# Remote Execute Skill

Execute OpenClaw Python skills on the remote server (openclaw-xcompany.local) via SSH or HTTP webhook.

## When to Activate

This skill activates when the user wants to:
- Check server status or health
- View logs from remote services
- Execute administrative commands on the server
- Run OpenClaw skills remotely
- Deploy applications
- Trigger N8N workflows
- Activate SQUAD contexts

## Trigger Examples

- "Qual o status do servidor OpenClaw?"
- "Mostre os logs do OpenClaw dos últimos 50 linhas"
- "Execute um system status no servidor"
- "Faça deploy da aplicação em staging"
- "Ative o SQUAD de sales"

## Available Skills

| Skill | Description | Arguments |
|-------|-------------|-----------|
| `system_status` | System resource usage (CPU, RAM, Disk) | `--detailed` |
| `read_logs` | Read service logs via journalctl | `--service SERVICE` `--lines N` |
| `deploy_app` | Deploy application to environment | `--environment ENV` `--confirmed` |
| `n8n_trigger` | Trigger N8N workflow | `--workflow NAME` |
| `squad_activation` | Activate SQUAD context | `--squad NAME` |
| `send_whatsapp` | Send WhatsApp message | `--recipient PHONE` `--message TEXT` |
| `execute_command` | Execute shell command safely | `--command CMD` `--confirmed` |

## How to Use

### Method 1: Via SSH (Default)

Use the Bash tool to execute:

```bash
python3 bin/openclaw-remote-skill.py SKILL_NAME [OPTIONS] --verbose
```

### Method 2: Via HTTP Webhook (N8N)

```bash
python3 bin/openclaw-remote-skill.py SKILL_NAME --method http [OPTIONS]
```

## Examples

### Example 1: Check Server Status

**User:** "Qual o status do servidor OpenClaw?"

**Assistant Action:**
```bash
python3 bin/openclaw-remote-skill.py system_status --verbose
```

**Expected Output:**
```
✅ Skill 'system_status' executed successfully
{
  "cpu_percent": 12.5,
  "memory_percent": 48.3,
  "disk_percent": 14.2,
  "status": "healthy",
  "uptime": "5 days, 3:42:15"
}
```

### Example 2: View Logs

**User:** "Mostre os últimos 50 linhas de log do OpenClaw"

**Assistant Action:**
```bash
python3 bin/openclaw-remote-skill.py read_logs \
  --service openclaw \
  --lines 50 \
  --verbose
```

**Expected Output:**
```
✅ Skill 'read_logs' executed successfully
[Last 50 lines of openclaw service logs...]
```

### Example 3: Deploy Application

**User:** "Faça deploy da aplicação em staging"

**Assistant Action:**
```bash
python3 bin/openclaw-remote-skill.py deploy_app \
  --environment staging \
  --verbose
```

**Expected Output:**
```
✅ Skill 'deploy_app' executed successfully
{
  "environment": "staging",
  "steps": {
    "pull": "success",
    "install": "success",
    "test": "success",
    "build": "success",
    "restart": "success",
    "health_check": "healthy"
  },
  "deployedAt": "2026-03-08T04:45:12Z"
}
```

### Example 4: Activate SQUAD

**User:** "Ative o SQUAD de sales"

**Assistant Action:**
```bash
python3 bin/openclaw-remote-skill.py squad_activation \
  --squad sales \
  --verbose
```

**Expected Output:**
```
✅ Skill 'squad_activation' executed successfully

🎯 SQUAD: Sales
👥 Specialists: BDR, SDR, LNS, Closer, Manager
🔧 Commands: Prospecção, Pipeline, Objeções, Fechamento
⚡ Triggers: vendas, pipeline, leads, deals
```

### Example 5: Trigger N8N Workflow

**User:** "Dispare o workflow de lead enrichment no N8N"

**Assistant Action:**
```bash
python3 bin/openclaw-remote-skill.py n8n_trigger \
  --workflow lead_enrichment \
  --verbose
```

**Expected Output:**
```
✅ Skill 'n8n_trigger' executed successfully
{
  "workflow": "lead_enrichment",
  "status": "triggered",
  "executionId": "abc123",
  "webhookUrl": "https://n8n.example.com/webhook/..."
}
```

### Example 6: Execute Safe Command

**User:** "Execute 'ls -la' no servidor"

**Assistant Action:**
```bash
python3 bin/openclaw-remote-skill.py execute_command \
  --command "ls -la /home/openclaw/aureon-skills" \
  --verbose
```

**Expected Output:**
```
✅ Skill 'execute_command' executed successfully
{
  "command": "ls -la /home/openclaw/aureon-skills",
  "output": "total 32K\ndrwxr-xr-x 2 openclaw openclaw 4.0K Mar  8 04:30 .\n...",
  "exitCode": 0,
  "executedAt": "2026-03-08T04:47:30Z"
}
```

## Execution Methods

### SSH Method (Default)

**Pros:**
- Direct execution on server
- No intermediate services
- Works without N8N setup
- Lower latency

**Cons:**
- Requires SSH access
- No execution history in N8N
- Limited to synchronous execution

**Configuration:**
```bash
# .env
OPENCLAW_REMOTE_HOST=openclaw-xcompany.local
OPENCLAW_REMOTE_USER=root
OPENCLAW_SSH_KEY=/home/aureon/.ssh/id_ed25519
```

### HTTP Method (N8N Webhook)

**Pros:**
- Execution history in N8N
- Supports async workflows
- Can trigger additional automations
- No SSH key management

**Cons:**
- Requires N8N setup
- Higher latency
- Depends on webhook availability

**Configuration:**
```bash
# .env
N8N_WEBHOOK_URL=https://n8n.example.com/webhook/openclaw-execute-skill
```

**Setup:**
1. Import `integrations/openclaw/api/n8n-workflow.json` to N8N
2. Activate workflow
3. Copy webhook URL to `.env`
4. Test with: `python3 bin/openclaw-remote-skill.py system_status --method http`

## Architecture

```
User Request
    ↓
Aureon AI (Claude Code)
    ↓ Skill: /remote-execute
bin/openclaw-remote-skill.py
    ↓
    ├─ SSH Method
    │   ↓ SSH (port 22)
    │   OpenClaw Server
    │   ↓ Execute Python skill
    │   Return JSON result
    │
    └─ HTTP Method
        ↓ HTTPS POST
        N8N Webhook
        ↓ SSH via N8N
        OpenClaw Server
        ↓ Execute Python skill
        ↓ Parse result
        Return JSON via HTTP
```

## Response Template

### Successful Execution

```
✅ Skill executado com sucesso: [SKILL_NAME]

Resultado:
[FORMATTED_OUTPUT]

Executado em: [TIMESTAMP]
```

### Execution Failed

```
❌ Falha ao executar skill: [SKILL_NAME]

Erro: [ERROR_MESSAGE]

Possíveis soluções:
- Verifique a conexão SSH: ssh openclaw-xcompany whoami
- Verifique se o script existe no servidor
- Execute com --verbose para mais detalhes
- Veja logs remotos: bash integrations/openclaw/remote-logs.sh
```

## Error Handling

### Common Errors

**SSH Connection Failed:**
```bash
# Solution
chmod 600 ~/.ssh/id_ed25519
ssh-add ~/.ssh/id_ed25519
ssh openclaw-xcompany whoami  # Test connection
```

**Script Not Found:**
```bash
# Solution: Deploy skills to server
scp -r integrations/openclaw/skills/* openclaw-xcompany:/home/openclaw/aureon-skills/
```

**Permission Denied:**
```bash
# Solution: Fix permissions on server
ssh openclaw-xcompany "chmod +x /home/openclaw/aureon-skills/*.py"
```

**Timeout:**
```bash
# Solution: Increase timeout in script or check server load
python3 bin/openclaw-remote-skill.py system_status --verbose
```

## Security Considerations

1. **SSH Key Protection:**
   - Store in `~/.ssh/` with `0600` permissions
   - Never commit to git
   - Use encrypted key with passphrase (optional)

2. **Command Execution:**
   - All commands go through safety checks
   - Destructive commands require `--confirmed` flag
   - Blocked patterns: `rm -rf /`, `mkfs`, `dd`, fork bombs

3. **Webhook Security:**
   - Use HTTPS for N8N webhooks
   - Add webhook authentication (N8N feature)
   - Validate request signatures
   - Rate limit requests

4. **Audit Logging:**
   - SSH logs: `/var/log/auth.log` on server
   - N8N logs: Execution history in N8N UI
   - Skill logs: Returned in JSON output

## Integration with Other Skills

### With `send-whatsapp`

```bash
# Check server status, then send alert via WhatsApp
python3 bin/openclaw-remote-skill.py system_status --json > /tmp/status.json
# Parse status and send alert if unhealthy
```

### With `drive-access`

```bash
# Download logs from server, upload to Google Drive
python3 bin/openclaw-remote-skill.py read_logs --lines 1000 > /tmp/logs.txt
# Upload to Drive via MCP tool
```

### With SQUAD activation

```bash
# Activate SQUAD before processing requests
python3 bin/openclaw-remote-skill.py squad_activation --squad sales
# SQUAD context now available for subsequent operations
```

## Testing

### Test SSH Connection

```bash
ssh openclaw-xcompany "whoami && python3 --version"
```

**Expected:**
```
root
Python 3.11.x
```

### Test Skill Execution

```bash
python3 bin/openclaw-remote-skill.py system_status --verbose --json
```

**Expected:**
```json
{
  "success": true,
  "output": {
    "cpu_percent": 12.5,
    "memory_percent": 48.3,
    "disk_percent": 14.2,
    "status": "healthy"
  },
  "error": null
}
```

### Test HTTP Method (if N8N configured)

```bash
python3 bin/openclaw-remote-skill.py system_status --method http --verbose
```

## Troubleshooting

Run diagnostics:

```bash
# 1. Check SSH access
bash integrations/openclaw/remote-doctor.sh

# 2. View recent logs
bash integrations/openclaw/remote-logs.sh 50

# 3. Test skill locally on server
ssh openclaw-xcompany "python3 /home/openclaw/aureon-skills/system_status.py"

# 4. Check N8N webhook (if using HTTP method)
curl -X POST "$N8N_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"skill":"system_status","args":{}}'
```

## Quick Reference

```bash
# System status
python3 bin/openclaw-remote-skill.py system_status

# View logs
python3 bin/openclaw-remote-skill.py read_logs --service openclaw --lines 50

# Deploy app
python3 bin/openclaw-remote-skill.py deploy_app --environment staging

# Activate SQUAD
python3 bin/openclaw-remote-skill.py squad_activation --squad sales

# Execute command
python3 bin/openclaw-remote-skill.py execute_command --command "uptime"

# Via HTTP (N8N)
python3 bin/openclaw-remote-skill.py system_status --method http
```

---

**Status:** 🟢 Ready (SSH method)
**Status:** 🟡 Pending (HTTP method - requires N8N setup)
**Last updated:** 2026-03-08
**Author:** Aureon AI
