# AUREON AI — SQUADS SPEC
> Arquitetura e especificação de todos os SQUADs do sistema

---

## 🧠 Conceito de SQUAD

Um **SQUAD** é um time de agentes especialistas organizados por setor/função.

**Fluxo de acionamento:**
```
Usuário → Master Router → Squad Router → Especialista Correto → Resposta
```

**Contrato de SQUAD:**
- **Objetivo:** o que o squad resolve
- **Membros:** lista de agentes especializados
- **Roteador:** agente que distribui para o membro correto
- **Entradas:** tipos de input aceitos
- **Saídas:** formato de output esperado
- **Triggers:** palavras/intenções que ativam o squad
- **Escalada:** quando escalar para outro squad

---

## 📊 Status dos SQUADs

| Squad | Status | Agentes | Roteador |
|-------|--------|---------|----------|
| **Sales** | ✅ Criado | BDR/SDS/LNS/Closer/Sales Manager | `agents/squads/sales/AGENT.md` |
| **Exec** | ✅ Criado | CRO/CFO/COO | `agents/squads/exec/AGENT.md` |
| **Operations** | ❌ Pendente | COO/OpsManager/ProcessAgent | `agents/squads/ops/AGENT.md` |
| **Marketing** | ❌ Pendente | CMO/GrowthAgent/CopyAgent | `agents/squads/marketing/AGENT.md` |
| **Tech** | ❌ Pendente | DevOps/ArchAgent/SecurityAgent | `agents/squads/tech/AGENT.md` |
| **Research** | ❌ Pendente | ResearchAgent/AnalystAgent | `agents/squads/research/AGENT.md` |
| **Finance** | ❌ Pendente | CFO/ControllerAgent | `agents/squads/finance/AGENT.md` |

---

## 🔵 SQUAD: SALES (✅ Existente)

**Objetivo:** resolver tudo relacionado a receita, pipeline de vendas e performance comercial.

**Membros:**
| Agente | Especialidade | Path |
|--------|--------------|------|
| BDR | Prospecção, listas, cadência outbound, contact rate | `agents/cargo/sales/bdr/AGENT.md` |
| SDS | Qualificação, discovery, value call, show rate | `agents/cargo/sales/sds/AGENT.md` |
| LNS | Nutrição, reativação MAYBE, follow-up | `agents/cargo/sales/lns/AGENT.md` |
| CLOSER | Objeções, fechamento, negociação, CLOSE framework | `agents/cargo/sales/closer/AGENT.md` |
| SALES MANAGER | Hiring, OTE, comissionamento, QC, 1:1, scaling | `agents/cargo/sales/sales-manager/AGENT.md` |

**Triggers:** vendas, closer, fechamento, objeção, pipeline, sdr, bdr, show rate, close rate, comissão, ote

---

## 🔵 SQUAD: EXEC (✅ Existente)

**Objetivo:** decisões estratégicas de negócio, financeiras e operacionais de alto nível.

**Membros:**
| Agente | Especialidade | Path |
|--------|--------------|------|
| CRO | Receita, pricing, unit economics, growth | `agents/cargo/c-level/cro/AGENT.md` |
| CFO | Margem, EBITDA, caixa, projeções | `agents/cargo/c-level/cfo/AGENT.md` |
| COO | Processos, headcount, eficiência operacional | `agents/cargo/c-level/coo/AGENT.md` |

**Triggers:** margem, net profit, ebitda, valuation, exit, m&a, scaling, headcount

---

## 🟡 SQUAD: OPERATIONS (❌ Pendente)

**Objetivo:** otimizar processos, SOPs, gestão de projetos, eficiência operacional.

**Membros a criar:**
| Agente | Especialidade |
|--------|--------------|
| OpsManager | Gestão de processos, SOPs, KPIs operacionais |
| ProcessAgent | Mapeamento de processos, automação, checklists |
| ProjectAgent | Gestão de projetos, cronogramas, entregáveis |

**Triggers:** processo, SOP, checklist, operação, eficiência, KPI, projeto, prazo, entrega

**Path alvo:** `agents/squads/ops/AGENT.md`

---

## 🟡 SQUAD: MARKETING (❌ Pendente)

**Objetivo:** estratégia de marketing, conteúdo, tráfego, posicionamento e branding.

**Membros a criar:**
| Agente | Especialidade |
|--------|--------------|
| CMO | Estratégia de marketing, posicionamento, branding |
| GrowthAgent | Tráfego pago, SEO, funis, CPA, ROAS |
| CopyAgent | Copywriting, headlines, VSLs, scripts de venda |

**Triggers:** marketing, tráfego, copy, anúncio, conteúdo, branding, posicionamento, funil, lead, CPA, ROAS

**Path alvo:** `agents/squads/marketing/AGENT.md`

---

## 🟡 SQUAD: TECH (❌ Pendente)

**Objetivo:** arquitetura de sistemas, desenvolvimento, automações, infraestrutura.

**Membros a criar:**
| Agente | Especialidade |
|--------|--------------|
| ArchAgent | Arquitetura de software, decisões de stack |
| DevOps | Deploy, infra, CI/CD, VPS, Docker |
| AutomationAgent | N8n, Zapier, integrações, APIs |

**Triggers:** código, sistema, deploy, API, automação, integração, banco de dados, arquitetura, VPS, bug, erro

**Path alvo:** `agents/squads/tech/AGENT.md`

---

## 🟡 SQUAD: RESEARCH (❌ Pendente)

**Objetivo:** pesquisa, análise de mercado, inteligência competitiva, síntese de conhecimento.

**Membros a criar:**
| Agente | Especialidade |
|--------|--------------|
| ResearchAgent | Pesquisa profunda, coleta de dados, fontes |
| AnalystAgent | Análise, síntese, relatórios, insights |
| IntelAgent | Inteligência competitiva, benchmarks |

**Triggers:** pesquisar, analisar, mercado, concorrente, dados, relatório, benchmark, tendência

**Path alvo:** `agents/squads/research/AGENT.md`

---

## 🟡 SQUAD: FINANCE (❌ Pendente)

**Objetivo:** controle financeiro, DRE, fluxo de caixa, projections, pricing.

**Membros a criar:**
| Agente | Especialidade |
|--------|--------------|
| CFO | Estratégia financeira, valuation, captação |
| ControllerAgent | DRE, balanço, fluxo de caixa, conciliação |
| PricingAgent | Precificação, margens, unit economics |

**Triggers:** financeiro, DRE, caixa, receita, custo, margem, precificação, balanço, controller

**Path alvo:** `agents/squads/finance/AGENT.md`

---

## 🌐 MASTER ROUTER (❌ Pendente)

**Arquivo:** `agents/squads/MASTER-ROUTER.md`

**Objetivo:** receber qualquer input e despachar para o squad correto.

**Lógica:**
```
Input → Analisar intent → Identificar squad → Ativar Squad Router → Especialista
```

**Regras de roteamento Master:**
1. Mencionou vendas/pipeline/closer/BDR → **SQUAD SALES**
2. Mencionou margem/EBITDA/exit/valuation/scaling → **SQUAD EXEC**
3. Mencionou processo/SOP/operação/checklist → **SQUAD OPS**
4. Mencionou marketing/tráfego/copy/conteúdo → **SQUAD MARKETING**
5. Mencionou código/sistema/deploy/automação → **SQUAD TECH**
6. Mencionou pesquisar/analisar/mercado/dados → **SQUAD RESEARCH**
7. Mencionou financeiro/DRE/caixa/margem → **SQUAD FINANCE**
8. Ambíguo → retornar lista de squads disponíveis e pedir clarificação

---

## 📋 Ordem de Criação dos SQUADs

```
Fase 1 (Agora):
  → Criar MASTER-ROUTER.md
  → Criar agents/squads/ops/AGENT.md
  → Criar agents/squads/marketing/AGENT.md

Fase 2:
  → Criar agents/squads/tech/AGENT.md
  → Criar agents/squads/research/AGENT.md
  → Criar agents/squads/finance/AGENT.md

Fase 3:
  → Atualizar SQUAD-INDEX.yaml com todos os novos squads
  → Criar agentes especialistas para cada squad (cargo/)
  → Ingerir materiais para treinar cada especialista
```

---

## 🔗 Integração com OpenClaw / WhatsApp

**Formato de comando via WhatsApp:**
```
/sales analisar objeção de preço
/ops criar SOP para onboarding
/tech estruturar arquitetura para nova integração
/research pesquisar ferramentas de automação para CRM
```

**Flow:**
```
Mensagem WhatsApp → OpenClaw Webhook → Master Router → Squad → Resposta → WhatsApp
```
