# TOOLS — Aureon AI Execution Capabilities

## 🔧 AVAILABLE TOOLS

### File Operations
- `read_file(path)` — Read file contents
- `write_file(path, content)` — Create or overwrite file
- `list_directory(path)` — List files in directory
- `search_files(pattern)` — Find files matching pattern

### Command Execution
- `bash(command)` — Execute shell command
- `python(script)` — Run Python script
- `node(script)` — Run Node.js script

### Git Operations
- `git_status()` — Check repository status
- `git_diff()` — Show changes
- `git_log(n)` — Show last n commits

### System Information
- `system_status()` — CPU, RAM, disk usage
- `process_list()` — Running processes
- `logs(service, lines)` — Service logs

### Integrations
- `n8n_trigger(webhook_id, payload)` — Trigger N8N workflow
- `notion_query(database, filter)` — Query Notion database
- `drive_list(folder_id)` — List Google Drive files

## 🎯 SKILL DEFINITIONS

### Skill: Execute Server Command

**Trigger:** `/execute`, `/ssh`, `/bash`, `/run`

**Function:**
```python
def execute_server_command(command: str, confirm: bool = False):
    """
    Execute shell command on the server.

    Args:
        command: Shell command to execute
        confirm: Whether user confirmed destructive operations

    Returns:
        stdout, stderr, exit_code
    """
    # Safety checks
    destructive_patterns = ['rm -rf', 'dd', '> /dev/', 'mkfs', 'format']
    if any(pattern in command for pattern in destructive_patterns):
        if not confirm:
            return "⚠️ DESTRUCTIVE COMMAND DETECTED. Type '/execute confirm' to proceed."

    # Execute
    result = subprocess.run(command, shell=True, capture_output=True, text=True)

    return {
        'stdout': result.stdout,
        'stderr': result.stderr,
        'exit_code': result.returncode
    }
```

---

### Skill: Generate Report

**Trigger:** `/report`, `/analise`, `/dre`

**Function:**
```python
def generate_report(type: str, context: dict):
    """
    Generate structured report based on type.

    Types:
        - sales: Pipeline, conversion, revenue
        - finance: DRE, cash flow, margins
        - ops: Process efficiency, SOP status
        - tech: System health, deploy status

    Returns:
        Formatted report with charts and insights
    """
    templates = {
        'sales': render_sales_report,
        'finance': render_finance_report,
        'ops': render_ops_report,
        'tech': render_tech_report
    }

    return templates[type](context)
```

---

### Skill: Deploy Application

**Trigger:** `/deploy`

**Function:**
```python
def deploy_application(environment: str, branch: str = 'main'):
    """
    Deploy application to specified environment.

    Args:
        environment: 'staging' or 'production'
        branch: Git branch to deploy (default: main)

    Steps:
        1. Run tests
        2. Build application
        3. Backup current version
        4. Deploy new version
        5. Health check
        6. Rollback if failed

    Returns:
        Deployment status and logs
    """
    # Pre-flight checks
    tests_passed = run_tests()
    if not tests_passed:
        return "❌ Tests failed. Deployment aborted."

    # Backup
    backup_current_version()

    # Deploy
    deploy_status = execute_deployment(environment, branch)

    # Health check
    if not health_check_passed():
        rollback()
        return "❌ Health check failed. Rolled back."

    return f"✅ Deployed {branch} to {environment} successfully."
```

---

### Skill: N8N Workflow Trigger

**Trigger:** `/n8n`, `/workflow`, `/automation`

**Function:**
```python
def trigger_n8n_workflow(workflow_name: str, payload: dict = None):
    """
    Trigger N8N workflow via webhook.

    Available workflows:
        - lead_enrichment: Enrich lead data
        - email_sequence: Start email drip
        - data_sync: Sync data between platforms
        - report_generation: Generate and send report

    Args:
        workflow_name: Name of the workflow
        payload: Data to send to workflow

    Returns:
        Workflow execution ID and status
    """
    webhooks = {
        'lead_enrichment': 'https://n8n.xcompany.com/webhook/lead-enrich',
        'email_sequence': 'https://n8n.xcompany.com/webhook/email-seq',
        'data_sync': 'https://n8n.xcompany.com/webhook/data-sync',
        'report_generation': 'https://n8n.xcompany.com/webhook/report'
    }

    url = webhooks.get(workflow_name)
    if not url:
        return f"❌ Workflow '{workflow_name}' not found."

    response = requests.post(url, json=payload)

    return {
        'execution_id': response.json().get('executionId'),
        'status': response.json().get('status'),
        'message': f"✅ Workflow '{workflow_name}' triggered successfully."
    }
```

---

### Skill: Read System Logs

**Trigger:** `/logs`, `/tail`, `/journal`

**Function:**
```python
def read_system_logs(service: str = 'openclaw', lines: int = 50):
    """
    Read systemd service logs.

    Args:
        service: Service name (openclaw, nginx, n8n, etc.)
        lines: Number of lines to show

    Returns:
        Formatted log output
    """
    cmd = f"journalctl -u {service} -n {lines} --no-pager"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

    return f"📋 Logs de {service} (últimas {lines} linhas):\n\n{result.stdout}"
```

---

### Skill: Squad Context Activation

**Trigger:** `/sales`, `/tech`, `/ops`, `/exec`, `/marketing`, `/research`, `/finance`

**Function:**
```python
def activate_squad(squad_name: str):
    """
    Activate SQUAD context for subsequent messages.

    Args:
        squad_name: Name of the squad (sales, tech, ops, etc.)

    Returns:
        Squad activation confirmation and available commands
    """
    squads = {
        'sales': {
            'description': 'Conversão, growth, pipeline',
            'specialists': ['BDR', 'SDS', 'Closer', 'Sales Manager'],
            'commands': ['/pipeline', '/proposta', '/objecoes']
        },
        'tech': {
            'description': 'Código, deploy, arquitetura',
            'specialists': ['Arch Agent', 'DevOps', 'Security'],
            'commands': ['/deploy', '/debug', '/ssh']
        },
        # ... outros squads
    }

    squad = squads.get(squad_name)
    if not squad:
        return f"❌ SQUAD '{squad_name}' não encontrado."

    # Set context
    set_active_squad(squad_name)

    return f"""
🏛️ AUREON AI — SQUAD {squad_name.upper()}

Contexto ativado: {squad['description']}
Especialistas disponíveis: {', '.join(squad['specialists'])}

📌 Comandos específicos:
{chr(10).join(f'  {cmd}' for cmd in squad['commands'])}

Pronto para operar. O que precisa?
"""
```

---

## 🛡️ SAFETY RULES

### Auto-Execute (No Confirmation)
- Read operations
- List operations
- Log viewing
- Status checks
- Report generation

### Require Confirmation
- Write operations
- Command execution
- Deploy operations
- Database modifications
- External API calls

### Blocked (Never Execute)
- `rm -rf /` or similar
- Credential modifications
- Firewall changes
- User account modifications
- Kernel operations

---

## 📊 USAGE EXAMPLES

### Example 1: Check System Status
```
User: /status
Aureon: Executa system_status() + process_list()
Output: CPU 45%, RAM 60%, Disk 30%, 15 processes
```

### Example 2: Deploy to Production
```
User: /deploy production
Aureon: Solicita confirmação → Executa deploy_application('production')
Output: ✅ Deployed main to production. Health check passed.
```

### Example 3: Generate Sales Report
```
User: /report sales
Aureon: Executa generate_report('sales')
Output: Pipeline: 50 leads, 15 qualified, 5 closing, $120k ARR
```

### Example 4: Activate SQUAD Tech
```
User: /tech
Aureon: Executa activate_squad('tech')
Output: 🏛️ AUREON AI — SQUAD TECH [contexto ativo]
```

---

*Última atualização: 2026-03-06*
*Aureon AI — Sistema de Inteligência Executiva*
