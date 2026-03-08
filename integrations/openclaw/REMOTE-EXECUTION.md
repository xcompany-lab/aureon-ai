# Remote Execution Architecture - Aureon AI ↔ OpenClaw

## Overview

This document describes the architecture for executing operations remotely between Aureon AI (running locally in Claude Code) and the OpenClaw server (openclaw-xcompany.local).

## Problem Statement

Aureon AI runs in a local Claude Code environment with limited access to external tools like `curl`, `openclaw` CLI, and direct API access. However, users need to:

1. **Send WhatsApp messages** via the OpenClaw gateway
2. **Access Google Drive files** for knowledge management
3. **Execute administrative skills** on the remote OpenClaw server
4. **Trigger N8N workflows** for automation

## Solution Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     USER (Natural Language)                      │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                 Aureon AI (Claude Code - Local)                  │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ send-whatsapp│  │ drive-access │  │remote-execute│          │
│  │    SKILL     │  │    SKILL     │  │    SKILL     │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                  │                  │                   │
│         ↓                  ↓                  ↓                   │
│  ┌──────────────────────────────────────────────────┐           │
│  │          Python Scripts (bin/)                    │           │
│  │  • openclaw-send-message.py                      │           │
│  │  • openclaw-remote-skill.py                      │           │
│  └──────┬──────────────────────────────┬────────────┘           │
│         │                               │                         │
└─────────┼───────────────────────────────┼─────────────────────────┘
          │                               │
          │ SSH                           │ SSH or HTTP
          │                               │
          ↓                               ↓
┌─────────────────────────────────────────────────────────────────┐
│              OpenClaw Server (openclaw-xcompany.local)           │
│                                                                   │
│  ┌────────────────────────────────────────────────────┐         │
│  │   Python Skills (/home/openclaw/aureon-skills/)    │         │
│  │   • send_whatsapp.py                               │         │
│  │   • system_status.py                               │         │
│  │   • read_logs.py                                   │         │
│  │   • deploy_app.py                                  │         │
│  │   • n8n_trigger.py                                 │         │
│  │   • squad_activation.py                            │         │
│  │   • execute_command.py                             │         │
│  └────────────┬───────────────────────────────────────┘         │
│               │                                                   │
│               ↓                                                   │
│  ┌────────────────────────────────────────────────────┐         │
│  │          OpenClaw Gateway (port 3000)              │         │
│  │          • WhatsApp Web Session                    │         │
│  │          • Agent Router (v2.0 with SQUADs)         │         │
│  │          • Message Queue                           │         │
│  └────────────┬───────────────────────────────────────┘         │
│               │                                                   │
└───────────────┼───────────────────────────────────────────────────┘
                │
                ↓
       ┌────────────────┐
       │ WhatsApp Cloud │
       │   (Meta API)   │
       └────────────────┘
```

### Data Flow Diagram

```
1. User: "Envie mensagem para Kethely"
      ↓
2. Aureon AI: Detect trigger "envie mensagem"
      ↓
3. Activate skill: /send-whatsapp
      ↓
4. Execute: bin/openclaw-send-message.py --to "Kethely" --message "..."
      ↓
5. SSH to openclaw-xcompany.local as root
      ↓
6. Run: python3 /home/openclaw/aureon-skills/send_whatsapp.py "+5551..." "..."
      ↓
7. OpenClaw skill: openclaw message send --target ... --message ...
      ↓
8. OpenClaw Gateway: Queue message to WhatsApp
      ↓
9. WhatsApp Cloud: Deliver message
      ↓
10. Return JSON result via SSH stdout
      ↓
11. Aureon AI: Parse result, inform user
```

## Communication Methods

### Method 1: SSH (Default)

**Transport:** SSH (port 22)
**Protocol:** Encrypted shell session
**Authentication:** Public key (ed25519)
**Latency:** ~100-200ms
**Reliability:** High (direct connection)

**Configuration:**
```bash
# .env
OPENCLAW_REMOTE_HOST=openclaw-xcompany.local
OPENCLAW_REMOTE_USER=root
OPENCLAW_SSH_KEY=/home/aureon/.ssh/id_ed25519
```

**Flow:**
```
Local Python Script
    → SSH Client
    → SSH Server (openclaw-xcompany.local:22)
    → Execute Python skill
    → Return stdout/stderr
    → Parse JSON output
```

**Pros:**
- No intermediate services required
- Direct, low-latency execution
- Proven, secure protocol
- Works offline (LAN only)

**Cons:**
- Requires SSH access to server
- Synchronous only (no background jobs)
- No execution history/audit trail
- Limited to command/response pattern

### Method 2: HTTP Webhook (N8N)

**Transport:** HTTPS
**Protocol:** HTTP POST with JSON payload
**Authentication:** Webhook token or API key
**Latency:** ~300-500ms
**Reliability:** Medium (depends on N8N uptime)

**Configuration:**
```bash
# .env
N8N_WEBHOOK_URL=https://n8n.example.com/webhook/openclaw-execute-skill
N8N_API_KEY=your-n8n-api-key  # Optional
```

**Flow:**
```
Local Python Script
    → HTTP POST to N8N Webhook
    → N8N Workflow parses request
    → N8N SSH Node connects to server
    → Execute Python skill
    → N8N parses output
    → Return JSON via HTTP response
```

**Pros:**
- Execution history in N8N UI
- Can trigger additional automations
- Async workflows possible
- No local SSH key management
- Can add rate limiting, caching, etc.

**Cons:**
- Requires N8N setup and maintenance
- Higher latency (extra hop)
- Dependency on external service
- More complex error handling

## Component Details

### 1. Skills (Claude Code)

**Location:** `.claude/skills/`

**Purpose:** Detect user intent and route to appropriate Python script.

**Structure:**
```
.claude/skills/
├── send-whatsapp/
│   └── SKILL.md          # Triggers: "enviar mensagem", "whatsapp"
├── drive-access/
│   └── SKILL.md          # Triggers: "google drive", "listar arquivos"
└── remote-execute/
    └── SKILL.md          # Triggers: "status servidor", "ver logs"
```

**Responsibilities:**
- Pattern matching on user input
- Extracting entities (recipient, message, file names)
- Constructing proper CLI invocations
- Presenting results to user

### 2. Local Python Scripts

**Location:** `bin/`

**Files:**
- `openclaw-send-message.py` - WhatsApp bridge
- `openclaw-remote-skill.py` - Generic remote skill executor

**Responsibilities:**
- Validate inputs
- Build SSH/HTTP commands
- Handle authentication (SSH keys, tokens)
- Execute remote operations
- Parse and format results
- Error handling and retries

**Design Pattern:** Command Pattern

```python
class RemoteSkillExecutor:
    def execute(self, skill: str, args: dict) -> dict:
        # Build command
        # Choose transport (SSH or HTTP)
        # Execute remotely
        # Parse result
        # Return structured response
```

### 3. Remote Python Skills

**Location:** `/home/openclaw/aureon-skills/` (on server)

**Files:**
- `send_whatsapp.py` - Send messages via OpenClaw CLI
- `system_status.py` - System resource monitoring
- `read_logs.py` - Journalctl log reading
- `deploy_app.py` - Application deployment
- `n8n_trigger.py` - N8N workflow triggering
- `squad_activation.py` - SQUAD context activation
- `execute_command.py` - Safe command execution

**Responsibilities:**
- Execute specific operations using local tools
- Interface with OpenClaw CLI
- Validate safety constraints
- Return structured JSON output
- Log execution details

**Design Pattern:** Strategy Pattern

```python
class Skill:
    def validate(self) -> bool:
        # Check preconditions

    def execute(self) -> dict:
        # Perform operation

    def format_output(self) -> dict:
        # Return JSON result
```

### 4. OpenClaw Gateway

**Location:** Server process (systemd service)

**Port:** 3000 (HTTP), WebSocket
**Process:** `openclaw gateway`

**Responsibilities:**
- Maintain WhatsApp Web session
- Route messages to agents
- Queue outgoing messages
- Store conversation history
- Handle media files

**Not Modified:** We use the existing OpenClaw CLI to interact with the gateway.

## Security Architecture

### Authentication & Authorization

```
┌─────────────────────────────────────────────────────────────────┐
│                        Security Layers                           │
│                                                                   │
│  1. SSH Public Key Authentication                                │
│     • Key: ~/.ssh/id_ed25519 (4096-bit)                         │
│     • Passphrase: Optional (recommended)                         │
│     • Permissions: 0600 (owner read/write only)                  │
│                                                                   │
│  2. Skill-Level Safety Checks                                    │
│     • Blocked commands: rm -rf /, mkfs, dd, etc.                │
│     • Destructive commands require --confirmed flag              │
│     • Timeout limits (30-60 seconds per operation)              │
│                                                                   │
│  3. OpenClaw Gateway Authentication                              │
│     • WhatsApp session tied to phone number                      │
│     • Selective reply mode (owner-only)                          │
│     • Message validation and sanitization                        │
│                                                                   │
│  4. Environment Variable Protection                              │
│     • Credentials in .env (gitignored)                           │
│     • No hardcoded secrets in code                               │
│     • Variable substitution in configs                           │
└─────────────────────────────────────────────────────────────────┘
```

### Threat Model

| Threat | Mitigation |
|--------|------------|
| SSH key theft | Encrypted key with passphrase, 0600 permissions |
| Command injection | Input validation, escape quotes, blocked patterns |
| Unauthorized access | SSH key auth only (no passwords), selective reply mode |
| Data exfiltration | Minimal data in transit, encrypted SSH tunnel |
| DoS attacks | Rate limiting in skills, timeout enforcement |
| Credential exposure | .env gitignored, no logs of sensitive data |

### Audit Trail

**SSH Logs:**
```bash
# On server
tail -f /var/log/auth.log | grep openclaw-xcompany
```

**Skill Execution Logs:**
```bash
# Returned in JSON output
{
  "executedAt": "2026-03-08T04:30:00Z",
  "skill": "send_whatsapp",
  "args": {"recipient": "+5551...", "message": "..."},
  "result": {...}
}
```

**N8N Execution History:**
- Stored in N8N database
- Accessible via UI: Executions tab
- Retention: 30 days (configurable)

## Error Handling Strategy

### Levels of Error Handling

```
1. Input Validation (Local)
   ↓ (Invalid input → User error message)

2. Connection Errors (Transport)
   ↓ (SSH failed → Retry or fallback to HTTP)

3. Remote Execution Errors (Server)
   ↓ (Skill failed → Parse error, return to user)

4. Output Parsing Errors (Local)
   ↓ (Malformed JSON → Return raw output)

5. User Feedback (Aureon AI)
   ↓ (Present actionable error message)
```

### Example Error Flows

**Scenario 1: SSH Connection Failed**
```python
try:
    result = execute_via_ssh(skill, args)
except SSHConnectionError:
    if http_method_available:
        result = execute_via_http(skill, args)
    else:
        return user_error(
            "Cannot connect to server. Check SSH config."
        )
```

**Scenario 2: Skill Not Found**
```python
if skill not in AVAILABLE_SKILLS:
    return user_error(
        f"Unknown skill: {skill}. "
        f"Available: {', '.join(AVAILABLE_SKILLS.keys())}"
    )
```

**Scenario 3: WhatsApp Not Paired**
```python
if "Channel is required" in error:
    return user_error(
        "WhatsApp not paired. "
        "See: integrations/openclaw/WHATSAPP-SETUP.md"
    )
```

## Performance Characteristics

### Latency Breakdown

**SSH Method:**
```
User input → Skill detection:     10-50ms
Skill → Python script:            5-10ms
SSH handshake:                    50-100ms
Remote execution:                 100-5000ms (depends on skill)
Result parsing:                   5-10ms
Response to user:                 10-20ms
────────────────────────────────────────
Total:                            180-5190ms
```

**HTTP Method:**
```
User input → Skill detection:     10-50ms
Skill → Python script:            5-10ms
HTTP request to N8N:              50-100ms
N8N workflow processing:          100-200ms
N8N SSH to server:                50-100ms
Remote execution:                 100-5000ms
N8N result parsing:               50-100ms
HTTP response:                    50-100ms
Result parsing (local):           5-10ms
Response to user:                 10-20ms
────────────────────────────────────────
Total:                            425-5690ms
```

### Scalability

**Concurrency:**
- SSH: Limited by SSH session pool (~10 concurrent)
- HTTP: Limited by N8N executor threads (~50 concurrent)

**Throughput:**
- SSH: ~5-10 requests/second
- HTTP: ~20-30 requests/second (with N8N caching)

**Resource Usage:**
- Local: ~10-20 MB RAM per Python process
- Server: ~5-10 MB RAM per skill execution
- Network: ~1-5 KB per request/response

## Deployment Guide

### Prerequisites

1. **Local Environment:**
   - Python 3.11+
   - SSH client
   - Git (for version control)
   - Claude Code with Aureon AI

2. **Server Environment:**
   - OpenClaw installed and running
   - Python 3.11+
   - Systemd (for service management)
   - SSH server (OpenSSH)

3. **Network:**
   - LAN connectivity between local and server
   - Hostname resolution (openclaw-xcompany.local)
   - SSH port 22 accessible

### Deployment Steps

#### 1. Configure Local Environment

```bash
# 1. Clone repository
git clone <repo> mega-brain
cd mega-brain

# 2. Configure environment variables
cp .env.example .env
nano .env  # Add OPENCLAW_* variables

# 3. Setup SSH key (if not exists)
ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
ssh-copy-id root@openclaw-xcompany.local

# 4. Test SSH connection
ssh openclaw-xcompany whoami  # Should print "root"
```

#### 2. Deploy Skills to Server

```bash
# Upload all skills
scp -r integrations/openclaw/skills/* \
  openclaw-xcompany:/home/openclaw/aureon-skills/

# Make executable
ssh openclaw-xcompany "chmod +x /home/openclaw/aureon-skills/*.py"

# Test skill execution
ssh openclaw-xcompany "python3 /home/openclaw/aureon-skills/system_status.py"
```

#### 3. Configure OpenClaw Gateway

```bash
# Deploy configuration (if needed)
bash integrations/openclaw/remote-deploy.sh

# Verify gateway status
bash integrations/openclaw/remote-doctor.sh

# Restart gateway
bash integrations/openclaw/remote-restart.sh
```

#### 4. Setup WhatsApp Pairing

```bash
# Follow pairing guide
cat integrations/openclaw/WHATSAPP-SETUP.md

# In summary:
ssh openclaw-xcompany
openclaw onboard  # Scan QR code with phone
openclaw channels list  # Verify pairing
```

#### 5. (Optional) Configure N8N Webhook

```bash
# 1. Import workflow to N8N
# Upload: integrations/openclaw/api/n8n-workflow.json

# 2. Activate workflow in N8N UI

# 3. Copy webhook URL
# Example: https://n8n.example.com/webhook/openclaw-execute-skill

# 4. Add to .env
echo "N8N_WEBHOOK_URL=<url>" >> .env
```

#### 6. Test Integration

```bash
# Test WhatsApp bridge
python3 bin/openclaw-send-message.py \
  --to "Kethely" \
  --message "Test from Aureon AI" \
  --verbose

# Test remote execution
python3 bin/openclaw-remote-skill.py system_status --verbose

# Test via Claude Code
# Ask: "Qual o status do servidor?"
```

## Maintenance

### Regular Tasks

**Daily:**
- Monitor server health: `python3 bin/openclaw-remote-skill.py system_status`
- Check logs for errors: `bash integrations/openclaw/remote-logs.sh 100`

**Weekly:**
- Verify WhatsApp session: `openclaw channels list`
- Update skills on server if changed
- Review N8N execution history

**Monthly:**
- Rotate SSH keys (optional)
- Update OpenClaw to latest version
- Backup configuration files

### Monitoring

**Health Check Script:**
```bash
#!/bin/bash
# integrations/openclaw/health-check.sh

# 1. SSH connectivity
ssh openclaw-xcompany "echo 'SSH OK'" || echo "SSH FAILED"

# 2. System status
python3 bin/openclaw-remote-skill.py system_status --json | \
  jq -r '.output.status'

# 3. WhatsApp session
ssh openclaw-xcompany "openclaw channels list --json" | \
  jq -r '.chat.whatsapp.status'

# 4. Gateway uptime
ssh openclaw-xcompany "systemctl is-active openclaw-gateway"
```

### Troubleshooting Runbook

| Symptom | Diagnosis | Solution |
|---------|-----------|----------|
| SSH connection refused | Server down or firewall | Check server status, ping server |
| "Permission denied" | Wrong SSH key or user | Verify key path in .env, test `ssh openclaw-xcompany` |
| "Script not found" | Skills not deployed | Run `scp` to upload skills |
| "Channel required" | WhatsApp not paired | Follow WHATSAPP-SETUP.md |
| Timeout on execution | Server overloaded or skill hung | Check `system_status`, kill process |
| "Command not found" | OpenClaw not installed | Reinstall OpenClaw on server |

## Future Enhancements

### Planned Features

1. **Async Execution:**
   - Long-running skills via background jobs
   - Status polling endpoint
   - Result caching

2. **Media Support:**
   - Send images/PDFs via WhatsApp
   - Download files from Drive
   - Screenshot sharing

3. **Batch Operations:**
   - Execute multiple skills in sequence
   - Conditional workflows
   - Error recovery and rollback

4. **Enhanced Security:**
   - Webhook HMAC signatures
   - Rate limiting per user
   - IP whitelisting

5. **Monitoring Dashboard:**
   - Real-time skill execution stats
   - Error rate graphs
   - Server health visualization

### Extension Points

**Add New Skill:**
1. Create `/home/openclaw/aureon-skills/new_skill.py`
2. Add to `SKILLS` dict in `openclaw-remote-skill.py`
3. Document in `.claude/skills/remote-execute/SKILL.md`
4. Deploy to server

**Add New Transport:**
Implement interface:
```python
class Transport:
    def execute(skill: str, args: dict) -> dict:
        pass
```

**Add Authentication Method:**
Modify SSH command builder to support:
- Password authentication
- Multi-factor authentication
- API token auth (for HTTP)

## References

- **OpenClaw Docs:** https://docs.openclaw.ai
- **N8N Workflow Automation:** https://n8n.io/docs
- **SSH Best Practices:** https://www.ssh.com/academy
- **MCP Protocol:** https://github.com/modelcontextprotocol

## Support

**Documentation:**
- WHATSAPP-SETUP.md - WhatsApp pairing guide
- REMOTE-EXECUTION.md - This file
- `.claude/skills/*/SKILL.md` - Individual skill docs

**Scripts:**
- `integrations/openclaw/remote-*.sh` - Remote management
- `bin/openclaw-*.py` - Local executors

**Issues:**
Report bugs or request features via GitHub Issues.

---

**Version:** 1.0.0
**Last Updated:** 2026-03-08
**Author:** Aureon AI
**License:** MIT (or as per project license)
