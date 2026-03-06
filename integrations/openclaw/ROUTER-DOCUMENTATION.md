# Aureon AI — Sistema de Router + Execução

## Overview

Transformação do OpenClaw WhatsApp em **canal de comando operacional** completo com roteamento inteligente de SQUADs e execução de tarefas.

## Arquitetura

```
┌──────────────────────────────────────────────────────┐
│              WhatsApp Message                         │
│         "Como melhorar conversão?"                    │
└────────────────┬─────────────────────────────────────┘
                 │
                 ↓
┌──────────────────────────────────────────────────────┐
│            OpenClaw Gateway                           │
│         (Port 18789, WhatsApp Plugin)                 │
└────────────────┬─────────────────────────────────────┘
                 │
                 ↓
┌──────────────────────────────────────────────────────┐
│         Aureon AI Core (SOUL.md)                      │
│   "Sistema de Inteligência Executiva"                 │
└────────────────┬─────────────────────────────────────┘
                 │
                 ↓
┌──────────────────────────────────────────────────────┐
│       Intent Detection (AGENTS.md)                    │
│   Keywords: "conversão" → SQUAD Sales                 │
└────────────────┬─────────────────────────────────────┘
                 │
                 ↓
┌──────────────────────────────────────────────────────┐
│           SQUAD Activation                            │
│   SQUAD Sales (BDR, SDS, Closer, Manager)             │
└────────────────┬─────────────────────────────────────┘
                 │
                 ↓
┌──────────────────────────────────────────────────────┐
│        Execution Layer (TOOLS.md)                     │
│   - Generate report                                   │
│   - Query database                                    │
│   - Execute command                                   │
│   - Trigger workflow                                  │
└────────────────┬─────────────────────────────────────┘
                 │
                 ↓
┌──────────────────────────────────────────────────────┐
│         Formatted Response                            │
│   🏛️ AUREON AI — SQUAD SALES                         │
│   [Análise + Ações + Próximos Passos]                │
└────────────────┬─────────────────────────────────────┘
                 │
                 ↓
┌──────────────────────────────────────────────────────┐
│            WhatsApp Reply                             │
└──────────────────────────────────────────────────────┘
```

## Componentes

### 1. SOUL.md (Personalidade + Identidade)

**Localização:** `~/.openclaw/workspace/SOUL.md`

**Função:**
- Define identidade Aureon AI
- Estabelece tom e postura
- Configura regras de ouro
- Define formato de resposta padrão

**Características:**
- Tom: Direto, executivo, proativo
- Postura: Sistema proprietário (não assistente)
- Foco: Ação > Conversa
- Linguagem: Português executivo de alto nível

### 2. AGENTS.md (Router Inteligente)

**Localização:** `~/.openclaw/workspace/AGENTS.md`

**Função:**
- Define 7 SQUADs especializados
- Mapeia triggers (keywords) para cada SQUAD
- Lista comandos disponíveis
- Implementa lógica de roteamento

**SQUADs Disponíveis:**

| SQUAD | Triggers | Especialistas | Comandos |
|-------|----------|---------------|----------|
| Sales 💰 | vendas, pipeline, conversão | BDR, SDS, Closer, Manager | `/sales`, `/pipeline`, `/proposta` |
| Tech 💻 | código, deploy, bug, api | Arch, DevOps, Security | `/tech`, `/deploy`, `/debug` |
| Ops 📊 | processo, sop, workflow | COO, Ops Manager, Process | `/ops`, `/sop`, `/workflow` |
| Exec 🎯 | estratégia, kpi, ebitda | CRO, CFO, COO | `/exec`, `/decisao`, `/kpi` |
| Marketing 📢 | marketing, ads, funil | CMO, Growth, Copy | `/marketing`, `/copy`, `/funil` |
| Research 🔬 | pesquisa, análise, dados | Research, Analyst | `/research`, `/analise`, `/mercado` |
| Finance 💵 | financeiro, dre, margem | CFO, Controller, Pricing | `/finance`, `/dre`, `/pricing` |

**Lógica de Roteamento:**

1. **Prioridade 1:** Comandos explícitos (`/sales`, `/tech`)
2. **Prioridade 2:** Detecção de keywords (conversão → Sales)
3. **Prioridade 3:** Multi-SQUAD (ads + DRE → Marketing + Finance)
4. **Prioridade 4:** Core Aureon (identidade, help, status)

### 3. TOOLS.md (Execução de Tarefas)

**Localização:** `~/.openclaw/workspace/TOOLS.md`

**Função:**
- Define skills disponíveis
- Implementa safety rules
- Mapeia comandos para funções
- Exemplos de uso

**Skills Implementados:**

| Skill | Trigger | Função | Confirmação |
|-------|---------|--------|-------------|
| Execute Command | `/execute`, `/ssh` | Executa comando shell | ⚠️ Se destrutivo |
| Generate Report | `/report`, `/dre` | Gera relatórios | ✅ Automático |
| Deploy App | `/deploy` | Deploy em staging/prod | ⚠️ Sempre |
| N8N Workflow | `/n8n` | Dispara workflow | ✅ Automático |
| Read Logs | `/logs` | Mostra logs de serviço | ✅ Automático |
| Squad Activation | `/sales`, `/tech` | Ativa contexto SQUAD | ✅ Automático |

**Safety Rules:**

- ✅ **Auto-execute:** Read, list, status, logs, reports
- ⚠️ **Require confirmation:** Write, execute, deploy, modify
- ❌ **Blocked:** rm -rf, credentials, firewall, kernel ops

## Formato de Resposta Padrão

Todas as respostas seguem este template:

```
🏛️ AUREON AI [— SQUAD X]

[Análise direta e objetiva]

[Dados concretos, números, exemplos]

---
💡 Próximos passos:
- [Ação 1 específica]
- [Ação 2 específica]

📌 [Comandos relacionados se relevante]
```

## Exemplos de Uso

### Exemplo 1: Roteamento Automático

**Input (WhatsApp):**
```
Como melhorar a conversão do meu funil?
```

**Processamento:**
1. Detecta keywords: "conversão", "funil"
2. Identifica SQUAD: Sales
3. Ativa contexto Sales
4. Consulta especialistas: BDR, SDS, Closer

**Output:**
```
🏛️ AUREON AI — SQUAD SALES

Conversão atual estimada: 15-20% (padrão do setor)
Meta agressiva: 30%+

Alavancas imediatas:
1. Follow-up em 24-48h (aumenta 40% conversão)
2. Script de objeção BANT customizado
3. Prova social no pitch (case studies)

Estrutura recomendada:
- Qualificação BANT antes do pitch
- 3 touchpoints mínimos antes do close
- Scarcity trigger no fechamento

---
💡 Próximos passos:
- Rodar /proposta [cliente] para pitch estruturado
- Implementar follow-up automatizado (N8N)

📌 Comandos relacionados:
/pipeline — ver status do funil
/proposta — gerar proposta customizada
```

### Exemplo 2: Comando Explícito

**Input (WhatsApp):**
```
/tech
```

**Output:**
```
🏛️ AUREON AI — SQUAD TECH

Contexto ativado: Arquitetura, código e automação
Especialistas disponíveis: Arch Agent, DevOps, Security Agent

📌 Comandos específicos:
  /deploy [ambiente] — deploy para staging/prod
  /debug [issue] — análise de problema técnico
  /ssh [comando] — executa comando no servidor

Pronto para operar. O que precisa?
```

### Exemplo 3: Multi-SQUAD

**Input (WhatsApp):**
```
Quanto devo investir em ads considerando meu DRE atual?
```

**Processamento:**
1. Detecta keywords: "ads" (Marketing) + "DRE" (Finance)
2. Identifica: Multi-SQUAD coordination
3. Consulta Marketing + Finance
4. Sintetiza resposta

**Output:**
```
🏛️ AUREON AI — SQUAD MARKETING + FINANCE

Análise integrada de investimento em ads:

📊 Contexto Financeiro (Finance):
- DRE atual: EBITDA 25%
- Margem de contribuição: 60%
- CAC atual: R$ 150
- LTV: R$ 900 (LTV/CAC = 6:1)

📢 Recomendação Marketing:
Budget sugerido: R$ 30k/mês (10% do revenue)
Canais priorizados: Meta Ads (60%), Google (40%)
ROI esperado: 4:1 no primeiro trimestre

Estrutura de funil:
- CPL esperado: R$ 25
- Conversão lead→cliente: 5%
- Novos clientes/mês: 60

---
💡 Próximos passos:
- Alocar R$ 30k no orçamento de Marketing
- Configurar tracking de CAC por canal
- Setup de funil de conversão no N8N

📌 Comandos relacionados:
/funil [produto] — desenhar funil completo
/dre — atualizar DRE com novo budget
```

### Exemplo 4: Execução de Comando

**Input (WhatsApp):**
```
/deploy staging
```

**Output:**
```
🏛️ AUREON AI — SQUAD TECH

Preparando deploy para staging:
- Branch: main
- Target: servidor staging
- Tipo: rolling deploy (zero downtime)

Pre-flight check:
✅ Testes passando (24/24)
✅ Backup automático ativo
✅ Rollback configurado

Executando deploy...
[████████████████████] 100%

✅ Deploy concluído com sucesso!

Health check:
✅ API respondendo (200 OK)
✅ Database conectado
✅ Services ativos (3/3)

Deploy time: 2m 14s
Rollback disponível até: 23:59 hoje

---
💡 Próximos passos:
- Testar funcionalidades críticas
- Monitorar logs: /logs staging
- Deploy para prod: /deploy production

📌 /logs staging — acompanhar logs
```

## Deployment

### Setup Inicial

Execute no servidor **como root**:

```bash
cd /home/aureon/projects/mega-brain-lab/mega-brain/integrations/openclaw
bash deploy-router-complete.sh
```

### O que o script faz:

1. ✅ Backup dos arquivos atuais
2. ✅ Deploy SOUL.md v2.0 (Router + Execution)
3. ✅ Deploy AGENTS.md (Router Inteligente)
4. ✅ Deploy TOOLS.md (Skills de Execução)
5. ✅ Limpa sessões antigas
6. ✅ Reinicia gateway
7. ✅ Valida deployment

### Verificação

```bash
# Verificar arquivos
ls -la /home/openclaw/.openclaw/workspace/{SOUL,AGENTS,TOOLS}.md

# Ver logs em tempo real
journalctl -u openclaw -f

# Verificar status
su - openclaw -c "openclaw doctor"
```

## Testing

### Teste 1: Roteamento Automático
```
WhatsApp: "Como melhorar a conversão do meu funil?"
Esperado: SQUAD Sales ativado + estratégias de conversão
```

### Teste 2: Comando Explícito
```
WhatsApp: "/tech"
Esperado: SQUAD Tech ativado + comandos disponíveis
```

### Teste 3: Multi-SQUAD
```
WhatsApp: "Quanto investir em ads considerando meu DRE?"
Esperado: Marketing + Finance coordenados
```

### Teste 4: Comando de Sistema
```
WhatsApp: "/status"
Esperado: Status de todos os SQUADs + sistema
```

## Troubleshooting

### Router não detecta SQUAD corretamente

**Causa:** Keywords não mapeadas ou ambíguas

**Solução:**
```bash
# Editar AGENTS.md e adicionar keywords
nano /home/openclaw/.openclaw/workspace/AGENTS.md
# Reiniciar gateway
systemctl restart openclaw
```

### Comando não executa

**Causa:** Safety rules bloqueando ou skill não implementado

**Solução:**
```bash
# Ver logs para detalhes do erro
journalctl -u openclaw -n 50 --no-pager

# Verificar TOOLS.md
cat /home/openclaw/.openclaw/workspace/TOOLS.md
```

### Resposta genérica (sem SQUAD)

**Causa:** SOUL.md não carregado ou sessão antiga

**Solução:**
```bash
# Limpar sessões e reiniciar
rm -f /home/openclaw/.openclaw/agents/main/sessions/*.jsonl
systemctl restart openclaw
```

## Roadmap

### ✅ Fase 1: Router Básico (Completo)
- [x] SOUL.md com identidade Aureon AI
- [x] AGENTS.md com 7 SQUADs
- [x] Detecção de intenção por keywords
- [x] Comandos explícitos (`/sales`, `/tech`)

### 🔄 Fase 2: Execução Avançada (Em Progresso)
- [x] TOOLS.md com skills básicos
- [ ] Skills OpenClaw implementados (Python/Node)
- [ ] Integração N8N via webhooks
- [ ] Integração Notion/Drive

### ⏳ Fase 3: Intelligence Layer (Planejado)
- [ ] Context memory entre mensagens
- [ ] Learning de padrões de uso
- [ ] Sugestões proativas
- [ ] Auto-optimization de respostas

## Next Steps

1. **Deploy do Router:** Execute `deploy-router-complete.sh`
2. **Teste básico:** Enviar comandos no WhatsApp
3. **Validar roteamento:** Testar cada SQUAD
4. **Implementar skills:** Criar scripts Python para execução real
5. **Integrar N8N:** Conectar workflows

---

**Status:** ✅ Router v2.0 pronto para deploy
**Última atualização:** 2026-03-06
**Versão:** 2.0 (Router + Execution)
