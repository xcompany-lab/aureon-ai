# Aureon AI — Próximos Passos da Sequência

> Documento criado em: 2026-03-06 07:45 UTC-3
> Contexto: Sequência de 5 ações iniciada, 1.5 completas

---

## 📊 Status Geral

| Ação | Status | Tempo Estimado | Prioridade |
|------|--------|----------------|------------|
| 1. Rebrand A1 | ✅ COMPLETO | - | Alta |
| 2. Skills Reais | 🔄 20% (1/5 skills) | 2h restantes | Alta |
| 3. Pipeline Chunked | ⏳ Não iniciado | 3-4h | Alta |
| 4. Integração N8N | ⏳ Não iniciado | 1-2h | Média |
| 5. Rebrand A2 | ⏳ Não iniciado | 2-3h | Média |

**Tempo total restante:** ~10-12 horas

---

## ✅ 1. Rebrand A1 — COMPLETO

### O Que Foi Feito
- CONTRIBUTING.md rebrandado (Mega Brain → Aureon AI)
- docs/quick-start.md rebrandado
- docs/API-KEYS-GUIDE.md rebrandado
- docs/readme-ralph-cascateamento.md rebrandado
- bin/mega-brain.js removido
- Script automatizado criado: `scripts/rebrand-docs.sh`

### Commit
```
5cd5569 - refactor: Rebrand A1 — Docs e Superfície (Mega Brain → Aureon AI)
```

### Verificação
```bash
# Confirmar que não há mais referências antigas
grep -r "Mega Brain\|mega-brain" --include="*.md" docs/ README.md CONTRIBUTING.md
```

---

## 🔄 2. Skills Reais — 20% COMPLETO

### O Que Foi Feito
✅ **execute_command.py** — Skill de execução de comandos shell
- Safety checks (blocked patterns, destructive patterns)
- Confirmation flow para comandos destrutivos
- Timeout de 5 minutos
- Output estruturado em JSON

**Localização:** `integrations/openclaw/skills/execute_command.py`

### O Que Falta

#### 2.1 read_logs.py
**Função:** Ler logs de serviços systemd

```python
#!/usr/bin/env python3
"""Read systemd service logs"""
import subprocess
import sys
import json

def read_logs(service: str, lines: int = 50):
    """Read last N lines of service logs"""
    cmd = f"journalctl -u {service} -n {lines} --no-pager"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

    return {
        'service': service,
        'lines': lines,
        'logs': result.stdout,
        'status': 'success' if result.returncode == 0 else 'error'
    }

if __name__ == '__main__':
    service = sys.argv[1] if len(sys.argv) > 1 else 'openclaw'
    lines = int(sys.argv[2]) if len(sys.argv) > 2 else 50
    print(json.dumps(read_logs(service, lines), indent=2))
```

**Teste:**
```bash
python integrations/openclaw/skills/read_logs.py openclaw 30
```

---

#### 2.2 deploy_app.py
**Função:** Deploy de aplicação com safety checks

```python
#!/usr/bin/env python3
"""Deploy application to staging or production"""
import subprocess
import sys
import json
from datetime import datetime

ALLOWED_ENVIRONMENTS = ['staging', 'production']

def deploy_app(environment: str, branch: str = 'main', confirmed: bool = False):
    """Deploy application"""

    # Validation
    if environment not in ALLOWED_ENVIRONMENTS:
        return {
            'status': 'error',
            'error': f'Invalid environment. Must be: {", ".join(ALLOWED_ENVIRONMENTS)}'
        }

    # Production requires confirmation
    if environment == 'production' and not confirmed:
        return {
            'status': 'requires_confirmation',
            'warning': '⚠️ PRODUCTION DEPLOYMENT',
            'message': f'About to deploy branch "{branch}" to PRODUCTION',
            'instruction': 'Reply with "/deploy production --confirmed" to proceed.'
        }

    # Pre-flight checks
    steps = []

    # 1. Run tests
    steps.append({'step': 'Running tests', 'status': 'running'})
    # Implementation here

    # 2. Build
    steps.append({'step': 'Building application', 'status': 'running'})
    # Implementation here

    # 3. Backup
    steps.append({'step': 'Creating backup', 'status': 'running'})
    # Implementation here

    # 4. Deploy
    steps.append({'step': f'Deploying to {environment}', 'status': 'running'})
    # Implementation here

    # 5. Health check
    steps.append({'step': 'Running health check', 'status': 'running'})
    # Implementation here

    return {
        'status': 'success',
        'environment': environment,
        'branch': branch,
        'timestamp': datetime.now().isoformat(),
        'steps': steps
    }

if __name__ == '__main__':
    # Parse args
    pass
```

---

#### 2.3 n8n_trigger.py
**Função:** Disparar workflows N8N via webhook

```python
#!/usr/bin/env python3
"""Trigger N8N workflows"""
import requests
import sys
import json

# Webhook URLs (move to env vars in production)
WEBHOOKS = {
    'lead_enrichment': 'https://n8n.xcompany.com/webhook/lead-enrich',
    'email_sequence': 'https://n8n.xcompany.com/webhook/email-seq',
    'data_sync': 'https://n8n.xcompany.com/webhook/data-sync',
    'report_generation': 'https://n8n.xcompany.com/webhook/report'
}

def trigger_n8n(workflow_name: str, payload: dict = None):
    """Trigger N8N workflow"""

    url = WEBHOOKS.get(workflow_name)
    if not url:
        return {
            'status': 'error',
            'error': f'Workflow "{workflow_name}" not found',
            'available': list(WEBHOOKS.keys())
        }

    try:
        response = requests.post(url, json=payload or {}, timeout=30)

        return {
            'status': 'success',
            'workflow': workflow_name,
            'execution_id': response.json().get('executionId'),
            'response': response.json()
        }

    except requests.exceptions.RequestException as e:
        return {
            'status': 'error',
            'error': str(e),
            'workflow': workflow_name
        }

if __name__ == '__main__':
    # Parse args and payload
    pass
```

---

#### 2.4 squad_activation.py
**Função:** Ativar contexto de SQUAD

```python
#!/usr/bin/env python3
"""Activate SQUAD context"""
import sys
import json

SQUADS = {
    'sales': {
        'description': 'Conversão, growth, pipeline',
        'specialists': ['BDR', 'SDS', 'Closer', 'Sales Manager'],
        'commands': ['/pipeline', '/proposta', '/objecoes'],
        'emoji': '💰'
    },
    'tech': {
        'description': 'Código, deploy, arquitetura',
        'specialists': ['Arch Agent', 'DevOps', 'Security'],
        'commands': ['/deploy', '/debug', '/ssh'],
        'emoji': '💻'
    },
    'ops': {
        'description': 'Processos, SOPs, eficiência',
        'specialists': ['COO', 'Ops Manager', 'Process Agent'],
        'commands': ['/sop', '/workflow', '/checklist'],
        'emoji': '📊'
    },
    'exec': {
        'description': 'Estratégia, KPIs, decisões C-level',
        'specialists': ['CRO', 'CFO', 'COO'],
        'commands': ['/decisao', '/kpi', '/board'],
        'emoji': '🎯'
    },
    'marketing': {
        'description': 'Ads, funil, branding',
        'specialists': ['CMO', 'Growth Agent', 'Copy Agent'],
        'commands': ['/copy', '/funil', '/ads'],
        'emoji': '📢'
    },
    'research': {
        'description': 'Pesquisa, análise, mercado',
        'specialists': ['Research Agent', 'Analyst Agent'],
        'commands': ['/analise', '/mercado', '/insights'],
        'emoji': '🔬'
    },
    'finance': {
        'description': 'DRE, margem, precificação',
        'specialists': ['CFO', 'Controller Agent', 'Pricing Agent'],
        'commands': ['/dre', '/pricing', '/margem'],
        'emoji': '💵'
    }
}

def activate_squad(squad_name: str):
    """Activate SQUAD context"""

    squad = SQUADS.get(squad_name)
    if not squad:
        return {
            'status': 'error',
            'error': f'SQUAD "{squad_name}" not found',
            'available': list(SQUADS.keys())
        }

    return {
        'status': 'activated',
        'squad': squad_name,
        'emoji': squad['emoji'],
        'description': squad['description'],
        'specialists': squad['specialists'],
        'commands': squad['commands'],
        'message': f"🏛️ AUREON AI — SQUAD {squad_name.upper()}\n\n"
                   f"Contexto ativado: {squad['description']}\n"
                   f"Especialistas disponíveis: {', '.join(squad['specialists'])}\n\n"
                   f"📌 Comandos específicos:\n" +
                   '\n'.join(f"  {cmd}" for cmd in squad['commands']) + "\n\n"
                   f"Pronto para operar. O que precisa?"
    }

if __name__ == '__main__':
    squad_name = sys.argv[1] if len(sys.argv) > 1 else None
    if not squad_name:
        print(json.dumps({'status': 'error', 'error': 'Usage: python squad_activation.py <squad_name>'}))
        sys.exit(1)

    print(json.dumps(activate_squad(squad_name), indent=2))
```

---

#### 2.5 system_status.py
**Função:** Status do sistema (CPU, RAM, Disk, Processes)

```python
#!/usr/bin/env python3
"""Get system status"""
import subprocess
import json

def get_system_status():
    """Get system resource usage"""

    # CPU
    cpu_cmd = "top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1"
    cpu = subprocess.run(cpu_cmd, shell=True, capture_output=True, text=True).stdout.strip()

    # RAM
    ram_cmd = "free | grep Mem | awk '{print ($3/$2) * 100.0}'"
    ram = subprocess.run(ram_cmd, shell=True, capture_output=True, text=True).stdout.strip()

    # Disk
    disk_cmd = "df -h / | tail -1 | awk '{print $5}' | cut -d'%' -f1"
    disk = subprocess.run(disk_cmd, shell=True, capture_output=True, text=True).stdout.strip()

    # Processes
    proc_cmd = "ps aux | wc -l"
    processes = subprocess.run(proc_cmd, shell=True, capture_output=True, text=True).stdout.strip()

    return {
        'cpu': f"{cpu}%",
        'ram': f"{float(ram):.1f}%",
        'disk': f"{disk}%",
        'processes': int(processes) - 1,  # Exclude header
        'status': 'healthy' if float(cpu) < 80 and float(ram) < 80 else 'warning'
    }

if __name__ == '__main__':
    print(json.dumps(get_system_status(), indent=2))
```

---

### Integração com OpenClaw

Após criar todos os skills, atualizar `TOOLS.md` no workspace do OpenClaw:

**Localização:** `/home/openclaw/.openclaw/workspace/TOOLS.md`

Adicionar seção:

```markdown
## 🔧 IMPLEMENTED SKILLS

Skills disponíveis em: `/home/aureon/projects/mega-brain-lab/mega-brain/integrations/openclaw/skills/`

### Execute Command
```bash
python3 /path/to/skills/execute_command.py "ls -la"
```

### Read Logs
```bash
python3 /path/to/skills/read_logs.py openclaw 50
```

### Squad Activation
```bash
python3 /path/to/skills/squad_activation.py sales
```

### System Status
```bash
python3 /path/to/skills/system_status.py
```
```

---

## ⏳ 3. Pipeline Chunked

### Objetivo
Resolver estouro de limite em ingestão de materiais grandes (vídeos 2h+, PDFs 200+ páginas).

### Problema Atual
- Ingestão de materiais grandes estoura limite 4x+ antes de terminar
- Contexto cresce exponencialmente
- Sem checkpoint/resume

### Solução Proposta

**Estrutura:**
```
core/workflows/
├── wf-ingest-chunked.yaml       # Workflow principal
├── wf-process-chunk.yaml        # Processa um chunk
└── wf-checkpoint.yaml           # Salva/resume estado

core/tasks/
├── checkpoint-save.md           # Task: salvar estado
├── checkpoint-resume.md         # Task: retomar de checkpoint
└── chunk-splitter.md            # Task: dividir material em chunks
```

**Workflow chunked:**
1. Dividir material em chunks de 15-20min (vídeos) ou 10-15 páginas (PDFs)
2. Processar cada chunk individualmente
3. Salvar checkpoint após cada chunk
4. Agregar resultados ao final
5. Resume automático se falhar

**Checkpoint format:**
```json
{
  "material_id": "alex-hormozi-2024-mastermind",
  "total_chunks": 8,
  "processed_chunks": 3,
  "current_chunk": 4,
  "artifacts": {
    "chunks": ["chunk-1.md", "chunk-2.md", "chunk-3.md"],
    "insights": ["insights-1.json", "insights-2.json", "insights-3.json"]
  },
  "timestamp": "2026-03-06T10:30:00Z",
  "status": "in_progress"
}
```

**Implementação:**
1. Criar `core/tasks/chunk-splitter.md`
2. Criar `core/workflows/wf-ingest-chunked.yaml`
3. Criar `core/tasks/checkpoint-save.md`
4. Criar `core/tasks/checkpoint-resume.md`
5. Testar com vídeo de 2h

**Tempo estimado:** 3-4 horas

---

## ⏳ 4. Integração N8N

### Objetivo
Conectar Aureon AI com workflows N8N para automações.

### Workflows Sugeridos

1. **Lead Enrichment** (lead-enrich)
   - Input: Nome, email, empresa
   - Process: Enriquece dados via APIs (Clearbit, Hunter.io)
   - Output: Lead completo com dados sociais

2. **Email Sequence** (email-seq)
   - Input: Lista de leads + template
   - Process: Dispara sequência de emails
   - Output: Status de envio

3. **Data Sync** (data-sync)
   - Input: Source + destination
   - Process: Sincroniza dados entre plataformas
   - Output: Relatório de sync

4. **Report Generation** (report-gen)
   - Input: Tipo de report + período
   - Process: Gera report automatizado
   - Output: PDF/Excel enviado

### Implementação

**1. Setup N8N Webhooks**
```bash
# No N8N, criar webhooks para cada workflow
# Anotar URLs geradas
```

**2. Atualizar n8n_trigger.py**
```python
# Adicionar URLs reais dos webhooks
WEBHOOKS = {
    'lead_enrichment': 'https://n8n.xcompany.com/webhook/abc123...',
    # etc
}
```

**3. Testar integração**
```bash
# Via Aureon AI no WhatsApp
/n8n lead_enrichment {"name": "John Doe", "email": "john@example.com"}
```

**Tempo estimado:** 1-2 horas

---

## ⏳ 5. Rebrand A2 — Core Interno

### Objetivo
Renomear estruturas internas (core/jarvis → core/aureon).

### Arquivos a Renomear

**Pastas:**
- `core/jarvis/` → `core/aureon/`
- `.claude/jarvis/` → `.claude/aureon/`

**Arquivos referenciados:**
```bash
# Encontrar todos os arquivos com referências
grep -r "jarvis\|JARVIS" --include="*.py" --include="*.js" --include="*.md" --include="*.yaml" core/ .claude/
```

### Plano de Execução

1. **Backup**
```bash
git checkout -b rebrand-a2-core
```

2. **Renomear pastas**
```bash
git mv core/jarvis core/aureon
git mv .claude/jarvis .claude/aureon
```

3. **Atualizar imports Python**
```bash
# Encontrar e substituir
find core/ -name "*.py" -exec sed -i 's/from core\.jarvis/from core.aureon/g' {} \;
find core/ -name "*.py" -exec sed -i 's/import jarvis/import aureon/g' {} \;
```

4. **Atualizar referências em YAML**
```bash
find core/ -name "*.yaml" -exec sed -i 's/jarvis/aureon/g' {} \;
```

5. **Atualizar comandos slash**
```bash
# Renomear arquivos de comandos
cd .claude/commands/
git mv jarvis-briefing.md aureon-status.md
git mv process-jarvis.md aureon-process.md
# etc
```

6. **Testar**
```bash
# Rodar validação
npm run validate

# Testar comando
/aureon-status
```

7. **Commit**
```bash
git commit -m "refactor: Rebrand A2 — Core Interno (jarvis → aureon)"
```

**Tempo estimado:** 2-3 horas

---

## 📋 Checklist Geral

### Skills Reais (2h restantes)
- [x] execute_command.py
- [ ] read_logs.py
- [ ] deploy_app.py
- [ ] n8n_trigger.py
- [ ] squad_activation.py
- [ ] system_status.py
- [ ] Atualizar TOOLS.md no workspace OpenClaw
- [ ] Testar cada skill individualmente
- [ ] Testar integração via WhatsApp

### Pipeline Chunked (3-4h)
- [ ] Criar chunk-splitter.md
- [ ] Criar wf-ingest-chunked.yaml
- [ ] Criar checkpoint-save.md
- [ ] Criar checkpoint-resume.md
- [ ] Testar com vídeo 2h+
- [ ] Validar checkpoint/resume

### Integração N8N (1-2h)
- [ ] Setup webhooks no N8N
- [ ] Atualizar n8n_trigger.py com URLs reais
- [ ] Criar workflows de teste
- [ ] Testar via WhatsApp
- [ ] Documentar workflows disponíveis

### Rebrand A2 (2-3h)
- [ ] Backup (branch rebrand-a2-core)
- [ ] Renomear core/jarvis → core/aureon
- [ ] Renomear .claude/jarvis → .claude/aureon
- [ ] Atualizar imports Python
- [ ] Atualizar referências YAML
- [ ] Renomear comandos slash
- [ ] Testar validação
- [ ] Commit

---

## 🎯 Ordem de Execução Recomendada

Quando retomar:

1. **Finalizar Skills Reais** (2h) — Impacto imediato no WhatsApp
2. **Pipeline Chunked** (3-4h) — Resolve problema crítico
3. **Integração N8N** (1-2h) — Expande capacidades
4. **Rebrand A2** (2-3h) — Limpeza estrutural

**Tempo total:** ~10-12 horas de desenvolvimento

---

## 💾 Comandos de Retomada

```bash
# Ver status atual
git status
git log --oneline -5

# Continuar de onde parou
cd /home/aureon/projects/mega-brain-lab/mega-brain

# Criar próximo skill
cd integrations/openclaw/skills/
nano read_logs.py

# Testar skill
python3 read_logs.py openclaw 30

# Quando terminar todos os skills
git add integrations/openclaw/skills/
git commit -m "feat: implement OpenClaw execution skills (Python)"
```

---

**Status:** 📍 Pausado após Rebrand A1 + 1 skill
**Próximo:** Completar Skills Reais (4 skills restantes)
**Meta:** Ter Aureon AI completamente executável via WhatsApp

