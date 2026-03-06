# TASK: checkpoint-resume
# Aureon AI — Retomar Pipeline de Checkpoint

## Objetivo
Retomar o processamento de um material de onde parou, lendo o checkpoint mais recente, sem repetir contexto já processado.

## Quando usar
- Após interrupção inesperada do pipeline
- Quando o usuário executa `/aureon-checkpoint resume <material_id>`
- Quando há checkpoint pendente ao iniciar uma nova sessão

## Protocolo de Execução

### 1. Localizar o checkpoint mais recente
- Listar arquivos em `processing/checkpoints/` com prefixo `<material_id>`
- Selecionar o de maior número de fase (ex: `-phase3.json` > `-phase2.json`)
- Se não encontrar: informar o usuário e sugerir iniciar do zero

### 2. Ler e validar o checkpoint
Verificar que o arquivo contém os campos obrigatórios:
- `material_id`, `phase_completed`, `chunks_processed`, `chunks_pending`, `artifacts_generated`

### 3. Anunciar o estado
```
AUREON — RESUME MODE
  Material: <material_id>
  Especialista: <expert_id>
  Fase retomando: <N+1>/5
  Chunks já processados: <X>
  Chunks pendentes: <Y>
  Artifacts já gerados: <lista>

  Continuando de onde parou — sem repetir contexto anterior.
```

### 4. Retomar o processamento
- Pular fases já completadas (não reprocessar)
- Para fase parcialmente completa: processar apenas chunks pendentes
- Para chunks já processados: usar artifacts existentes diretamente
- Continuar até PHASE 5 — COMPILATION

### 5. Ao completar
- Atualizar o checkpoint com `"status": "complete"`
- Mover checkpoint para `processing/checkpoints/archive/`
- Gerar saída final normalmente

## Exemplo de uso
```
/aureon-checkpoint resume alex-hormozi-mastermind-2026-03
```

## Prompt ultra-direto para resumo manual

Se precisar retomar manualmente sem o comando, use exatamente este prompt:

```
CHECKPOINT RESUME: material_id=<ID>
Leia processing/checkpoints/<ID>-phase<N>.json
Continue da fase <N+1>. Não repita nada das fases anteriores.
Chunks pendentes: <lista>. Execute até PHASE 5.
```

## Notas
- Não carregar em contexto os materiais brutos já processados
- Usar apenas os artifacts gerados como input das fases seguintes
- Este protocolo é file-driven: toda a memória está nos arquivos, não no contexto
