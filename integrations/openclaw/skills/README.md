# Aureon AI — OpenClaw Execution Skills

Python skills executáveis para integração OpenClaw/WhatsApp.

## 📦 Skills Disponíveis

### 1. execute_command.py
Executa comandos shell com safety checks.

**Features:**
- Bloqueio de comandos perigosos (rm -rf /, mkfs, dd, etc.)
- Confirmação para comandos destrutivos
- Timeout de 5 minutos
- Output JSON estruturado

**Uso:**
```bash
python3 execute_command.py "ls -la"
python3 execute_command.py "rm file.txt" --confirmed
```

**Output:**
```json
{
  "status": "success",
  "stdout": "...",
  "stderr": "",
  "exit_code": 0,
  "command": "ls -la"
}
```

---

### 2. read_logs.py
Lê logs de serviços systemd.

**Uso:**
```bash
python3 read_logs.py openclaw 30
python3 read_logs.py aureon-ai 50
```

**Output:**
```json
{
  "status": "success",
  "service": "openclaw",
  "lines_requested": 30,
  "logs": "...",
  "exit_code": 0
}
```

---

### 3. deploy_app.py
Deploy de aplicação com safety checks.

**Features:**
- Validação de environment (staging/production)
- Confirmação obrigatória para production
- Steps: pull → install → test → build → restart → health check
- Output detalhado de cada step

**Uso:**
```bash
python3 deploy_app.py staging
python3 deploy_app.py production main --confirmed
```

**Output:**
```json
{
  "status": "success",
  "environment": "staging",
  "branch": "main",
  "steps": [
    {"step": "Pulling latest code", "status": "success"},
    {"step": "Installing dependencies", "status": "success"}
  ],
  "summary": "Deployment succeeded (6 steps, 0 failed)"
}
```

---

### 4. n8n_trigger.py
Dispara workflows N8N via webhooks.

**Features:**
- 6 workflows pré-configurados
- Suporta requests library ou urllib (fallback)
- Configuração via environment variables
- Payload JSON customizável

**Workflows disponíveis:**
- `lead_enrichment` — Enriquecimento de leads
- `email_sequence` — Sequência de emails
- `data_sync` — Sincronização de dados
- `report_generation` — Geração de relatórios
- `notion_sync` — Sincronização Notion
- `drive_backup` — Backup Google Drive

**Uso:**
```bash
python3 n8n_trigger.py lead_enrichment '{"name":"John","email":"john@example.com"}'
python3 n8n_trigger.py data_sync
```

**Configuração:**
```bash
export N8N_WEBHOOK_LEAD_ENRICH="https://n8n.xcompany.com/webhook/abc123"
```

**Output:**
```json
{
  "status": "success",
  "workflow": "lead_enrichment",
  "status_code": 200,
  "response": {"executionId": "xyz789"}
}
```

---

### 5. squad_activation.py
Ativa contexto de SQUAD e exibe informações.

**Features:**
- 7 SQUADs disponíveis (sales, tech, ops, exec, marketing, research, finance)
- Exibe especialistas, comandos e triggers
- Formatação visual clara

**Uso:**
```bash
python3 squad_activation.py sales
python3 squad_activation.py tech
python3 squad_activation.py list
```

**Output:**
```json
{
  "status": "activated",
  "squad": "sales",
  "emoji": "💰",
  "description": "Conversão, growth, pipeline",
  "specialists": ["BDR", "SDS", "LNS", "Closer", "Sales Manager"],
  "commands": ["/pipeline", "/proposta", "/objecoes", "/follow-up"],
  "triggers": ["vendas", "pipeline", "fechamento"],
  "message": "..."
}
```

---

### 6. system_status.py
Status do sistema (CPU, RAM, Disk, Processes).

**Features:**
- Métricas em tempo real
- Health status (healthy/warning/critical)
- Modo detalhado (load average, memory details, disk details)

**Uso:**
```bash
python3 system_status.py
python3 system_status.py --detailed
```

**Output:**
```json
{
  "status": "healthy",
  "emoji": "🟢",
  "cpu_usage": "4.8%",
  "ram_usage": "48.5%",
  "disk_usage": "14.0%",
  "processes": 202,
  "uptime": "up 11 hours, 18 minutes",
  "message": "..."
}
```

---

## 🔗 Integração OpenClaw

Para usar via WhatsApp através do OpenClaw:

1. **Copiar skills para servidor OpenClaw:**
```bash
scp -r skills/ openclaw@server:/home/openclaw/aureon-skills/
```

2. **Atualizar TOOLS.md:**
```markdown
## 🔧 EXECUTION SKILLS

### Execute Command
python3 /home/openclaw/aureon-skills/execute_command.py "ls -la"

### Read Logs
python3 /home/openclaw/aureon-skills/read_logs.py openclaw 50

### SQUAD Activation
python3 /home/openclaw/aureon-skills/squad_activation.py sales

### System Status
python3 /home/openclaw/aureon-skills/system_status.py
```

3. **Testar via WhatsApp:**
```
/execute ls -la
/logs openclaw 30
/squad sales
/status
```

---

## 🛡️ Safety Features

- **execute_command.py**: Blocked patterns, confirmation flow
- **deploy_app.py**: Production confirmation, pre-flight checks
- **n8n_trigger.py**: URL validation, timeout handling
- All skills: JSON output, error handling, timeout protection

---

## 📝 Requirements

- Python 3.6+
- Standard library only (subprocess, json, sys, os)
- Optional: `requests` library (n8n_trigger.py falls back to urllib)

---

## 🧪 Testing

```bash
# Test all skills
cd integrations/openclaw/skills/

python3 system_status.py
python3 squad_activation.py sales
python3 execute_command.py "ls -la"
python3 read_logs.py openclaw 10
```

---

## 📚 Documentation

- Main router: `../ROUTER-DOCUMENTATION.md`
- SOUL.md: `../workspace-templates/SOUL.md`
- AGENTS.md: `../workspace-templates/AGENTS.md`
- TOOLS.md: `../workspace-templates/TOOLS.md`
