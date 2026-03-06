# Aureon AI — AI Knowledge Management System

## What is Aureon AI?

AI-powered system that transforms expert materials (videos, PDFs, transcriptions) into structured playbooks, DNA schemas, and mind-clone agents. Organized into SQUADs of specialist agents by sector.

## Quick Start

1. Run `npx aureon-ai setup` (auto-triggers on first use if `.env` missing)
2. Fill in API keys when prompted (only `OPENAI_API_KEY` is required)
3. Use `/aureon-status` to see system status

## Architecture

```
aureon-ai/
├── core/           -> Engine (tasks, workflows, schemas)
│   ├── tasks/          -> Atomic tasks
│   ├── workflows/      -> YAML orchestration
│   ├── intelligence/   -> Python scripts
│   ├── patterns/       -> YAML configs
│   ├── schemas/        -> JSON schemas
│   ├── aureon/         -> Aureon Core orchestrator
│   ├── templates/      -> Log templates
│   └── glossary/       -> Domain glossaries
├── agents/         -> AI agents
│   ├── squads/         -> SQUAD routers (sales/exec/ops/marketing/tech/research/finance)
│   ├── cargo/          -> Functional role agents
│   ├── minds/          -> Expert mind clones
│   └── conclave/       -> Multi-agent deliberation
├── .claude/        -> Claude Code integration
├── docs/           -> Documentation, PRDs, plans
├── bin/            -> CLI tools (npm)
├── inbox/          -> Raw materials (L3)
├── artifacts/      -> Pipeline stages (L3)
├── knowledge/      -> Knowledge base (L3)
└── logs/           -> Session logs (L3)
```

## Plan Mode

Plans MUST be saved to `docs/plans/` (not ~/.claude/plans/).
When in plan mode, save the plan file to: `docs/plans/YYYY-MM-DD-description.md`

### Layer System

| Layer | Content | Git Status |
|-------|---------|------------|
| L1 (Community) | core/, agents/conclave, .claude/, bin/, docs/ | Tracked (npm package) |
| L2 (Pro) | agents/cargo, agents/squads | Tracked (premium) |
| L3 (Personal) | .data/, .env, agents/minds | Gitignored |

## Community vs Pro

| Feature | Community | Pro |
|---------|-----------|-----|
| CLI & Templates | yes | yes |
| Skills & Hooks | yes | yes |
| Agent Templates | yes | yes |
| Knowledge Base (populated) | - | yes |
| Mind Clone Agents | - | yes |
| Pipeline Processing | - | yes |
| SQUADs | - | yes |
| Conclave | - | yes |

## DNA Schema (5 Knowledge Layers)

| Layer | Name | Description |
|-------|------|-------------|
| L1 | PHILOSOPHIES | Core beliefs and worldview |
| L2 | MENTAL-MODELS | Thinking and decision frameworks |
| L3 | HEURISTICS | Practical rules and decision shortcuts |
| L4 | FRAMEWORKS | Structured methodologies and processes |
| L5 | METHODOLOGIES | Step-by-step implementations |

## Commands

| Command | Description |
|---------|-------------|
| `/aureon-status` | Operational status + health score |
| `/aureon-process` | Full pipeline (ingest + process + enrich) |
| `/ingest` | Ingest new material |
| `/conclave` | Council session (multi-agent debate) |
| `/save` | Save current session |
| `/resume` | Resume previous session |
| `/setup` | Environment setup wizard |

## SQUADs

| Squad | Specialists | Triggers |
|-------|-------------|---------|
| Sales | BDR/SDS/LNS/Closer/Manager | vendas, pipeline, fechamento |
| Exec | CRO/CFO/COO | EBITDA, scaling, valuation |
| Ops | OpsManager/ProcessAgent | processo, SOP, checklist |
| Marketing | CMO/GrowthAgent/CopyAgent | marketing, tráfego, copy |
| Tech | ArchAgent/DevOps/AutomationAgent | código, deploy, automação |
| Research | ResearchAgent/AnalystAgent | pesquisar, analisar, dados |
| Finance | CFO/ControllerAgent/PricingAgent | financeiro, DRE, margem |

## Agents

Defined in `agents/AGENT-INDEX.yaml`, activated via slash commands.

| Type | Purpose |
|------|---------|
| MINDS | Expert mind clones |
| CARGO | Functional roles (Sales, Marketing, Ops, Finance) |
| SQUADS | Sector routers (7 squads) |
| CONCLAVE | Multi-perspective deliberation |
| SYSTEM | Aureon Core orchestrator + Agent-Creator |

## Configuration

- **`.env`** is the ONLY source of truth for credentials
- Run `/setup` to configure interactively
- Never hardcode API keys anywhere
- `.mcp.json` uses `${ENV_VAR}` syntax for MCP servers

### Required Keys

| Key | Purpose | Required? |
|-----|---------|-----------|
| `OPENAI_API_KEY` | Whisper transcription | Yes (pipeline needs it) |
| `VOYAGE_API_KEY` | Semantic embeddings (RAG) | Recommended |
| `GOOGLE_CLIENT_ID` | Drive import | Optional |
| `ANTHROPIC_API_KEY` | N/A with Claude Code | Not needed |

## Hooks System

20+ active hooks in `.claude/hooks/` (Python 3, stdlib + PyYAML only).
Configured in `settings.json` (distributed) and `settings.local.json` (local overrides).

| Event | Key Hooks |
|-------|-----------|
| SessionStart | `session_start.py`, `inbox_age_alert.py`, `skill_indexer.py` |
| UserPromptSubmit | `skill_router.py`, `quality_watchdog.py`, `memory_updater.py` |
| PreToolUse | `creation_validator.py`, `claude_md_guard.py` |
| PostToolUse | `post_tool_use.py`, `enforce_dual_location.py` |
| Stop | `stop_hook_completeness.py` |

## Rules (Lazy Loading)

Detailed rules are loaded on-demand via keyword matching from `.claude/rules/`:

| Group | Topics | File |
|-------|--------|------|
| PHASE-MANAGEMENT | phases, pipeline, batch | RULE-GROUP-1.md |
| PERSISTENCE | sessions, save, resume | RULE-GROUP-2.md |
| OPERATIONS | parallel, templates, KPIs | RULE-GROUP-3.md |
| PHASE-5 | agents, dossiers, cascading | RULE-GROUP-4.md |
| VALIDATION | source-sync, integrity | RULE-GROUP-5.md |
| AUTO-ROUTING | skills, sub-agents, GitHub | RULE-GROUP-6.md |

## Security

1. **NEVER** hardcode API keys or tokens in code
2. **ALWAYS** use `.env` for credentials (gitignored)
3. Google OAuth credentials via config file, not code
4. `git push` is blocked by `settings.json` deny rules — delegate to @devops

## Conventions

- Folders: lowercase (`inbox`, `system`)
- Config files: SCREAMING-CASE (`STATE.json`, `MEMORY.md`)
- Python scripts: snake_case, use `pathlib.Path` for cross-platform paths
- Skills: kebab-case directories (`knowledge-extraction/`)

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Hook failed" | Check Python 3 is in PATH |
| ".env not found" | Run `npx aureon-ai setup` |
| "Permission denied on git push" | By design — use branch + PR workflow |
| Skills not auto-activating | Check `SKILL-INDEX.json` is generated on SessionStart |

## CLAUDE.md Policy

- Only 2 CLAUDE.md files are valid: root `CLAUDE.md` and `.claude/CLAUDE.md` (this file)
- NEVER create CLAUDE.md in data or code subdirectories
- Agent memory lives in `.claude/aureon/` and `.claude/skills/`
