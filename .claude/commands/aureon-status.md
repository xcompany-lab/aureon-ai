# /aureon-status - Status Operacional Completo

Gera um briefing operacional completo do Aureon AI.

## Uso

```
/aureon-status          # Modo completo (default)
/aureon-status --compact # Versão resumida
/aureon-status --full    # Versão completa explícita
```

## Execução

### 1. Carregar Estado do Sistema

Ler os seguintes arquivos:

```
.claude/aureon/STATE.json         # Estado global
.claude/aureon/PENDING.md         # Pendências
.claude/aureon/MEMORY.md          # Memória relacional
.claude/aureon/CURRENT-TASK.md    # Tarefa atual
.claude/mission-control/MISSION-STATE.json  # Estado da missão
processing/insights/INSIGHTS-STATE.json     # Insights acumulados
processing/checkpoints/*.json               # Checkpoints pendentes
```

### 2. Calcular Health Score (0–100)

| Componente | Peso | Cálculo |
|------------|------|---------|
| Progresso Geral | 30pts | (files_processed / total_files) * 30 |
| Fontes Completas | 25pts | (sources_complete / total_sources) * 25 |
| Pendências Baixas | 20pts | max(0, 20 - (pending_high * 5) - (pending_medium * 2)) |
| Estado Atualizado | 15pts | 15 se state < 3 dias, 10 se < 7 dias, 0 se > 7 dias |
| Pipeline Limpo | 10pts | 10 se errors_pending = 0, else 0 |

### 3. Gerar Briefing Visual

**Responder as 4 perguntas fundamentais:**
1. **ONDE ESTAMOS?** — Posição exata na missão
2. **O QUE FOI FEITO?** — Progresso acumulado
3. **O QUE FALTA?** — Para finalização do projeto
4. **QUAL O PRÓXIMO PASSO?** — Ação mais importante agora

### 4. Padrões Visuais

- **Largura:** 120 caracteres
- **Containers:** 3 camadas (╔═══╗, ┌───┐, │)
- **Barras de progresso:** ████████░░░░░░░░ (16 blocos)
- **Tom:** Aureon Core (preciso, inteligente, conciso)

### 5. Salvamento

Salvar briefing em: `.claude/aureon/AUREON-STATUS.md`

---

**Nota:** Este comando substitui `/jarvis-briefing`.
