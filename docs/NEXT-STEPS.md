# Aureon AI — Próximos Passos da Sequência

> Documento criado em: 2026-03-06 07:45 UTC-3
> Contexto: Sequência de 5 ações iniciada, 1.5 completas

---

## 📊 Status Geral

| Ação | Status | Tempo Estimado | Prioridade |
|------|--------|----------------|------------|
| 1. Rebrand A1 | ✅ COMPLETO | - | Alta |
| 2. Skills Reais | ✅ COMPLETO (6/6 skills) | - | Alta |
| 3. Pipeline Chunked | ⏳ Não iniciado | 3-4h | Alta |
| 4. Integração N8N | ⏳ Não iniciado | 1-2h | Média |
| 5. Rebrand A2 | ⏳ Não iniciado | 2-3h | Média |

**Progresso:** 2/5 ações completas (40%)
**Tempo total restante:** ~8-10 horas

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

## ✅ 2. Skills Reais — 100% COMPLETO

### O Que Foi Feito

✅ **execute_command.py** — Execução segura de comandos shell
- Safety checks (blocked patterns, destructive patterns)
- Confirmation flow para comandos destrutivos
- Timeout de 5 minutos
- Output estruturado em JSON

✅ **read_logs.py** — Leitura de logs systemd
- journalctl wrapper
- Configurável número de linhas
- Timeout de 10 segundos
- Error handling robusto

✅ **deploy_app.py** — Deploy com safety checks
- Validação de environment (staging/production)
- Confirmação obrigatória para production
- Steps: pull → install → test → build → restart → health check
- Output detalhado de cada step

✅ **n8n_trigger.py** — Disparar workflows N8N
- 6 workflows pré-configurados
- Configuração via environment variables
- Fallback para urllib (sem dependências externas)
- Timeout de 30 segundos

✅ **squad_activation.py** — Ativar contexto SQUAD
- 7 SQUADs disponíveis (sales, tech, ops, exec, marketing, research, finance)
- Exibe especialistas, comandos e triggers
- Formatação visual clara
- Comando especial `list` para listar todos os SQUADs

✅ **system_status.py** — Status de recursos do sistema
- Métricas em tempo real (CPU, RAM, Disk, Processes)
- Health status automático (healthy/warning/critical)
- Modo detalhado com load average e memory details
- Uptime do sistema

✅ **README.md** — Documentação completa de todos os skills

✅ **TOOLS.md atualizado** — Seção "IMPLEMENTED SKILLS" adicionada

**Localização:** `integrations/openclaw/skills/`

**Commit:** `e7fa0f4 - feat: Complete OpenClaw Execution Skills`

---

## Seções Antigas Removidas

Os skills 2.1 a 2.5 (código template) foram implementados e estão disponíveis em `integrations/openclaw/skills/`.
Código e documentação completa em `integrations/openclaw/skills/README.md`.

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

