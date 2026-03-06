# AUREON AI — MASTER ROADMAP
> Última atualização: 2026-03-06 07:15 UTC-3

---

## 🧭 Estado Atual (Snapshot Real)

| Item | Status |
|------|--------|
| VPS com mega-brain instalado | ✅ Feito |
| OpenClaw coexistindo na VPS | ✅ Feito |
| Claude Code via antigravity operacional | ✅ Feito |
| Pipeline testado (Alex Hormozi — 1h mastermind) | ✅ Feito |
| Agentes gerados (Sales Squad: BDR/SDS/Closer/Manager/CRO/CFO/COO) | ✅ Feito |
| Repo desvinculado do original (rm -rf .git + init novo) | ✅ Feito |
| Repo próprio `xcompany-lab/aureon-ai` criado e com push | ✅ Feito |
| SSH GitHub autenticado | ✅ Feito |
| Squad Sales — agente roteador criado | ✅ Feito |
| Squad Exec (CRO/CFO/COO) — agente roteador criado | ✅ Feito |
| **Rebrand interno completo** | ❌ Pendente |
| **Pipeline otimizado (sem estouro de limite)** | ❌ Pendente |
| **SQUADs adicionais (Ops, Tech, Marketing, Research, Finance)** | ✅ Feito |
| **Integração OpenClaw / WhatsApp — Personalidade** | ✅ Feito |
| **Integração OpenClaw / WhatsApp — Router v2.0** | ✅ Feito |
| **Integração OpenClaw / WhatsApp — Skills Execution** | 🔄 Em Progresso |
| **Interface J.A.R.V.I.S (cockpit)** | ❌ Pendente |

---

## 📍 Linha de Progresso

```
[✅] Fase 0 — Engenharia Reversa
     → Análise da live do Finch, entendimento do mega-brain

[✅] Fase 1 — Ambiente Funcional
     → VPS + OpenClaw + antigravity + mega-brain rodando

[✅] Fase 2 — Validação do Motor
     → Ingest Hormozi → especialistas gerados → motor provado

[✅] Fase 3 — Tomada de Propriedade
     → repo próprio xcompany-lab/aureon-ai + SSH OK

[🔄] Fase 4 — Aureon AI Real (AQUI ESTAMOS)
     → rebrand interno + squads + pipeline otimizado + integrações + cockpit
```

---

## 🚀 Plano de Execução — Fase 4

### Pilar A — Rebrand Estrutural (Prioridade ALTA)
**Objetivo:** remover toda referência a Mega Brain / jarvis / Finch / MoneyClub sem quebrar o funcionamento.

**Etapa A1 — Docs e superfície (sem risco)**
- [ ] `README.md` → renomear para Aureon AI
- [ ] `QUICK-START.md` → rebrand
- [ ] `.claude/CLAUDE.md` → rebrand (trocar Mega Brain → Aureon AI, JARVIS → Aureon Core)
- [ ] `package.json` → name, author, keywords, bin names
- [ ] `agents/AGENT-INDEX.yaml` e `agents/README.md`
- [ ] `agents/persona-registry.yaml`
- [ ] `docs/` — todos os .md com referências antigas

**Etapa A2 — Core interno (com cuidado)**
- [ ] `core/jarvis/` → renomear pasta para `core/aureon/`
- [ ] `.claude/jarvis/` → `.claude/aureon/`
- [ ] Atualizar todos os imports e referências internas
- [ ] Comandos slash: `/jarvis-briefing` → `/aureon-status`, `/process-jarvis` → `/aureon-process`
- [ ] Scripts Python: substituir strings "jarvis" → "aureon"

**Etapa A3 — Binários e CLI**
- [ ] `bin/mega-brain.js` → `bin/aureon.js`
- [ ] `bin/cli.js` entry point → atualizar
- [ ] npm scripts: `start`, `install-wizard`, `validate`

---

### Pilar B — SQUADs (Prioridade ALTA)

**Squads já existentes:**
- ✅ `agents/squads/sales/` — roteador criado
- ✅ `agents/squads/exec/` — roteador criado

**Próximos squads a criar:**
- [ ] `agents/squads/ops/` — Operações (COO + OpsManager + ProcessAgent)
- [ ] `agents/squads/marketing/` — CMO + Growth + CopyAgent
- [ ] `agents/squads/tech/` — DevOps + ArchAgent + SecurityAgent
- [ ] `agents/squads/research/` — ResearchAgent + AnalystAgent
- [ ] `agents/squads/finance/` — CFO + ControllerAgent

**Atualizar SQUAD-INDEX.yaml** com todos os novos squads.

**Squad Router Master:**
- [ ] Criar `agents/squads/MASTER-ROUTER.md` — detecta intenção e despacha para o squad correto

---

### Pilar C — Pipeline Otimizado (Prioridade ALTA)

**Problema:** ingestão de materiais grandes estoura limite 4x+ antes de terminar.

**Soluções a implementar:**
- [ ] `core/workflows/wf-ingest-chunked.yaml` — ingestão por lotes (chunks de 15-20 min)
- [ ] Checkpoint file após cada fase (Phase 1 → 5) em `processing/checkpoints/`
- [ ] Resume prompt ultra-direto: retomar de checkpoint sem repetir contexto
- [ ] `core/tasks/checkpoint-save.md` — task atômica para salvar estado
- [ ] `core/tasks/checkpoint-resume.md` — task atômica para retomar de arquivo
- [ ] Reduzir contexto repetido: usar file-driven state ao invés de contexto em memória

---

### Pilar D — Integração OpenClaw / WhatsApp ✅ COMPLETO

**Fluxo implementado:**
```
WhatsApp → OpenClaw Gateway → Aureon AI Core (SOUL.md) → Intent Detection (AGENTS.md) →
→ SQUAD Activation → Execution Layer (TOOLS.md) → Formatted Response → WhatsApp
```

**Status: ETAPA 5 COMPLETA (2026-03-06 07:15)**

#### Fase 1: Personalidade & Identidade ✅
- [x] OpenClaw instalado e conectado ao WhatsApp
- [x] SOUL.md com identidade Aureon AI
- [x] IDENTITY.md com branding (nome, theme)
- [x] Personalidade assumida corretamente
- [x] Agent respondendo como Aureon AI

#### Fase 2: Router Inteligente v2.0 ✅
- [x] AGENTS.md com 7 SQUADs definidos (Sales, Tech, Ops, Exec, Marketing, Research, Finance)
- [x] Sistema de detecção de intenção via keywords
- [x] Roteamento automático (exemplo: "conversão" → SQUAD Sales)
- [x] Comandos explícitos (`/sales`, `/tech`, `/ops`, `/exec`, `/marketing`, `/research`, `/finance`)
- [x] Multi-SQUAD coordination (exemplo: ads + DRE → Marketing + Finance)
- [x] Formato de resposta estruturado padrão
- [x] Testado e validado no WhatsApp ✅

#### Fase 3: Execution Layer (Definido, Implementação Pendente) 🔄
- [x] TOOLS.md com skills definidos
- [x] Safety rules (auto-execute, require confirmation, blocked)
- [x] Comandos de execução (`/execute`, `/logs`, `/deploy`, `/n8n`)
- [ ] Skills implementados em Python/Node (código real)
- [ ] Integração N8N via webhooks
- [ ] Integração Notion/Drive

**Arquivos criados:**
- `integrations/openclaw/workspace-templates/SOUL.md` — v2.0 Router + Execution
- `integrations/openclaw/workspace-templates/AGENTS.md` — Router Inteligente
- `integrations/openclaw/workspace-templates/TOOLS.md` — Execution Layer
- `integrations/openclaw/deploy-router-complete.sh` — Script de deploy
- `integrations/openclaw/ROUTER-DOCUMENTATION.md` — Documentação técnica completa

**Teste de validação realizado:**
- Input: "Como melhorar a conversão do meu funil?"
- Output: ✅ SQUAD Sales ativado + estratégias de conversão + próximos passos

**Próximo passo:** Implementar skills reais (Python/Node) para execução de comandos

---

### Pilar E — Interface J.A.R.V.I.S (Prioridade MÉDIA-BAIXA)

**Cockpit web para controlar o Aureon AI:**

- [ ] Stack: Next.js ou HTML/JS puro (a definir)
- [ ] Chat central com o Aureon AI
- [ ] Painel de Squads ativos (cards por squad)
- [ ] Log de jobs em tempo real
- [ ] Status da VPS (CPU, RAM, jobs rodando)
- [ ] Botões de ativação manual de squads
- [ ] Histórico de sessões
- [ ] Permissões por ação (o que o Aureon pode executar)

---

## 🗂 Estrutura Alvo do Aureon AI

```
aureon-ai/
├── core/
│   ├── aureon/          ← (renomear de core/jarvis/)
│   ├── intelligence/
│   ├── tasks/
│   ├── workflows/
│   ├── schemas/
│   ├── patterns/
│   └── templates/
├── agents/
│   ├── squads/
│   │   ├── SQUAD-INDEX.yaml
│   │   ├── MASTER-ROUTER.md   ← [NEW]
│   │   ├── sales/
│   │   ├── exec/
│   │   ├── ops/               ← [NEW]
│   │   ├── marketing/         ← [NEW]
│   │   ├── tech/              ← [NEW]
│   │   ├── research/          ← [NEW]
│   │   └── finance/           ← [NEW]
│   ├── specialists/           ← (renomear de agents/cargo/)
│   ├── minds/
│   ├── conclave/
│   └── _templates/
├── integrations/              ← ✅ CRIADO
│   ├── openclaw/              ← ✅ Router v2.0 implementado
│   │   ├── workspace-templates/
│   │   │   ├── SOUL.md
│   │   │   ├── AGENTS.md
│   │   │   └── TOOLS.md
│   │   ├── deploy-router-complete.sh
│   │   ├── ROUTER-DOCUMENTATION.md
│   │   └── README.md
│   ├── whatsapp/              ← (via OpenClaw)
│   └── github/
├── interface/                 ← [NEW]
│   ├── api/
│   ├── dashboard/
│   └── jarvis_ui/
├── pipeline/
│   ├── ingest/
│   ├── process/
│   ├── checkpoints/           ← [NEW]
│   └── summarize/
├── knowledge/
│   ├── dossiers/
│   ├── playbooks/
│   ├── dna/
│   └── sources/
├── docs/
│   ├── architecture/
│   ├── roadmap/               ← [NEW]
│   └── squads/                ← [NEW]
└── .claude/
    ├── aureon/                ← (renomear de .claude/jarvis/)
    ├── commands/
    ├── hooks/
    ├── rules/
    └── skills/
```

---

## ⚡ Próximo Passo Prático (Agora)

### ✅ Completados (2026-03-06)
1. ~~**OpenClaw conectado**~~ — WhatsApp funcionando
2. ~~**Personalidade Aureon AI**~~ — SOUL.md v2.0 deployado
3. ~~**Router de SQUADs**~~ — 7 SQUADs com detecção automática
4. ~~**Comandos básicos**~~ — `/sales`, `/tech`, `/ops`, etc.
5. ~~**Testado e validado**~~ — "Como melhorar conversão?" → SQUAD Sales ✅

### 🔄 Prioridade Alta (Próximas Ações)
1. **Skills reais (Execution Layer)** — Implementar Python/Node skills para comandos
2. **Integração N8N** — Conectar workflows via webhooks
3. **Pipeline chunked** — Resolver estouro de limite em ingestão
4. **Rebrand A1** — Docs e superfície (README, CLAUDE.md, package.json)
5. **Rebrand A2** — Core interno (renomear `core/jarvis/` → `core/aureon/`)

### ⏳ Médio Prazo
6. **Rebrand A3** — Comandos slash e binários
7. **SQUADs faltantes (code)** — Implementar estrutura completa de pastas
8. **Interface J.A.R.V.I.S** — Cockpit web (Etapa 6)

---

*Este documento é a bússola do Aureon AI. Atualize após cada entrega.*
