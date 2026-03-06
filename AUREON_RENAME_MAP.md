# AUREON AI — MAPA DE RENAME
> Referência para rebrand seguro: do nome antigo para o nome Aureon AI

---

## 🔴 Substituições de String (Em todos os arquivos)

| De | Para | Prioridade |
|----|------|-----------|
| `Mega Brain` | `Aureon AI` | ALTA |
| `mega-brain` | `aureon-ai` | ALTA |
| `mega-brain-ai` | `aureon-ai` | ALTA |
| `JARVIS` | `Aureon Core` | ALTA |
| `Jarvis` | `Aureon` | ALTA |
| `jarvis` | `aureon` | ALTA |
| `Finch` | `Aureon` | ALTA |
| `finch` | `aureon` | ALTA |
| `MoneyClub` | `X-Company` | ALTA |
| `moneyclub` | `x-company` | ALTA |
| `mega_brain` | `aureon_ai` | MÉDIA |
| `MEGA-BRAIN` | `AUREON-AI` | MÉDIA |

---

## 📁 Arquivos por Prioridade de Rename

### 🔴 Prioridade 1 — Superfície (sem risco de quebrar nada)

| Arquivo | O que muda |
|---------|-----------|
| `README.md` | Título, descrição, comandos, arquitetura |
| `QUICK-START.md` | Referências ao Mega Brain / Jarvis |
| `.claude/CLAUDE.md` | Mega Brain → Aureon AI, JARVIS → Aureon Core |
| `package.json` | `name`, `author`, `keywords`, `bin` entries |
| `agents/README.md` | Descrições e referências |
| `agents/persona-registry.yaml` | Nomes e referências |
| `agents/AGENT-INDEX.yaml` | Labels e paths |
| `agents/MASTER-AGENT.md` | Cabeçalho e referências |
| `artifacts/README.md` | Descrições |

### 🟡 Prioridade 2 — Core (cuidado com imports)

| Arquivo / Pasta | O que muda |
|---------|-----------|
| `core/jarvis/` → `core/aureon/` | Renomear pasta |
| `core/jarvis/AGENT.md` | Conteúdo interno |
| `core/jarvis/agent-creator/AGENT.md` | Conteúdo |
| `core/workflows/PIPELINE-JARVIS-DOCS.md` | Renomear arquivo → `PIPELINE-AUREON-DOCS.md` |
| `core/tasks/process-batch.md` | Referências jarvis |
| `core/tasks/extract-dna.md` | Referências jarvis |
| `core/intelligence/*.py` | Strings "jarvis" em Python |
| `.claude/jarvis/` → `.claude/aureon/` | Renomear pasta + STATE.json |

### 🟡 Prioridade 3 — Comandos e CLI

| Arquivo | O que muda |
|---------|-----------|
| `bin/mega-brain.js` → `bin/aureon.js` | Renomear + atualizar conteúdo |
| `bin/cli.js` | Entry point → apontar para `aureon.js` |
| `.claude/commands/` | `/jarvis-briefing` → `/aureon-status` |
| `.claude/skills/` | Referências jarvis nos SKILLs |

### 🟢 Prioridade 4 — Docs e Configuração

| Arquivo | O que muda |
|---------|-----------|
| `docs/jarvis-logging-protocol.md` | Renomear e rebrand |
| `docs/pipeline-completa-v4.md` | Referências |
| `docs/prd-mega-brain-quality-uplift-v1.md` | Renomear arquivo |
| `.cursor/rules/mega-brain.md` | Renomear + conteúdo |
| `.cursor/agents.yaml` | Referências |
| `core/templates/phases/dossier-compilation.md` | Referências jarvis |
| `core/templates/phases/sources-compilation.md` | Referências jarvis |

---

## 📋 Ordem de Execução Segura

```
PASSO 1: Substituições de string nos docs (sem mudar nomes de pasta)
   → README.md, QUICK-START.md, .claude/CLAUDE.md, package.json

PASSO 2: Renomear arquivos individuais (sem mudar estrutura de pasta)
   → bin/mega-brain.js → bin/aureon.js
   → docs/jarvis-logging-protocol.md → docs/aureon-logging-protocol.md
   → core/workflows/PIPELINE-JARVIS-DOCS.md → PIPELINE-AUREON-DOCS.md

PASSO 3: Renomear pastas críticas (com update de todos os imports)
   → core/jarvis/ → core/aureon/
   → .claude/jarvis/ → .claude/aureon/
   → Atualizar todos os paths em yaml e md que referenciam essas pastas

PASSO 4: Atualizar package.json bin entries e scripts
   → "mega-brain-ai": "bin/cli.js" → "aureon-ai": "bin/cli.js"
   → "mega-brain": "bin/cli.js" → "aureon": "bin/cli.js"

PASSO 5: Validar que nada quebrou
   → grep -r "jarvis\|mega-brain\|Finch\|MoneyClub" --include="*.md" --include="*.yaml" .
```

---

## ⚠️ Cuidados Especiais

1. **`core/jarvis/` rename** — Verificar TODOS os arquivos que referenciam este path antes de mover
2. **`.claude/jarvis/STATE.json`** — Contém estado do JARVIS, precisa ser migrado/resetado
3. **`package.json` bin entries** — Não quebrar o CLI pois pode afetar o `npx aureon-ai setup`
4. **Hooks Python** — Verificar se algum hook hardcoda o path `jarvis/` para encontrar agentes

---

## ✅ Checklist de Validação Pós-RENAME

```bash
# Verificar se sobrou alguma referência antiga
grep -rn "jarvis\|Mega Brain\|mega-brain\|Finch\|MoneyClub" \
  --include="*.md" --include="*.yaml" --include="*.json" \
  --include="*.js" --include="*.py" \
  --exclude-dir=".git" . | grep -v "RENAME_MAP\|ROADMAP"

# Verificar estrutura de pastas renomeadas
ls core/aureon/
ls .claude/aureon/

# Verificar binários funcionando
node bin/cli.js --version
```
