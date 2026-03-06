# TASK: checkpoint-save
# Aureon AI — Salvar Estado do Pipeline

## Objetivo
Salvar o estado atual do pipeline em um arquivo JSON de checkpoint para permitir resumo futuro sem repetir contexto.

## Quando usar
- Após completar cada fase do pipeline no modo chunked
- Quando o usuário precisa pausar o processamento
- Após cada chunk processado em materiais grandes

## Inputs necessários (extrair do contexto)
- `material_id` — identificador único do material (ex: "alex-hormozi-mastermind-2026-03")
- `expert_id` — nome do especialista (ex: "alex-hormozi")
- `phase_completed` — última fase concluída (1–5)
- `chunks_processed` — lista de chunks já processados
- `chunks_pending` — lista de chunks ainda pendentes
- `artifacts_generated` — lista de arquivos já gerados

## Protocolo de Execução

### 1. Montar o objeto de estado
```json
{
  "material_id": "<material_id>",
  "expert_id": "<expert_id>",
  "timestamp": "<ISO-8601>",
  "phase_completed": <1-5>,
  "chunks_processed": ["chunk-001.md", "chunk-002.md"],
  "chunks_pending": ["chunk-003.md"],
  "artifacts_generated": {
    "chunks": ["artifacts/chunks/<material_id>/chunk-001.md"],
    "insights": ["artifacts/insights/<material_id>/insights-chunk-001.md"],
    "narratives": [],
    "dossier": null,
    "playbook": null
  },
  "status": "in_progress"
}
```

### 2. Salvar o arquivo
- Caminho: `processing/checkpoints/<material_id>-phase<N>.json`
- Substituir checkpoint anterior da mesma fase se existir
- Manter histórico: não deletar checkpoints de fases anteriores

### 3. Confirmar salvamento
```
CHECKPOINT SAVED
  Material: <material_id>
  Phase: <N>/5 completed
  Chunks: <X> done, <Y> pending
  File: processing/checkpoints/<material_id>-phase<N>.json
  Status: SAFE TO INTERRUPT
```

## Notas
- Este é um task atômico — executar completamente ou não executar
- Se o salvamento falhar, reportar erro imediatamente antes de continuar
- O checkpoint é a única fonte de verdade para resumo
