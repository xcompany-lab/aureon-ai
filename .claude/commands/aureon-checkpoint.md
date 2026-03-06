# /aureon-checkpoint - Controle de Checkpoints do Pipeline

Gerencia o sistema de checkpoint para pipelines de materiais grandes.

## Uso

```
/aureon-checkpoint save <material_id>        # Salvar estado atual
/aureon-checkpoint resume <material_id>      # Retomar de checkpoint
/aureon-checkpoint list                      # Listar checkpoints disponíveis
/aureon-checkpoint show <material_id>        # Ver detalhes de um checkpoint
/aureon-checkpoint clear <material_id>       # Limpar checkpoints de um material
```

## Subcomandos

### save
Salva o estado atual do pipeline em um checkpoint.
- Executa: `core/tasks/checkpoint-save.md`
- Arquivo gerado: `processing/checkpoints/<material_id>-phase<N>.json`

### resume
Retoma o pipeline de onde parou.
- Executa: `core/tasks/checkpoint-resume.md`
- Lê o checkpoint mais recente do material
- Continua sem repetir fases já completadas

### list
Lista todos os checkpoints disponíveis em `processing/checkpoints/`:
```
AUREON CHECKPOINTS:
  alex-hormozi-mastermind-2026-03-phase2.json  (Phase 2/5 — 3 dias atrás)
  dan-martell-saas-2026-03-phase5.json         (Completo — 1 dia atrás)
```

### show
Mostra detalhes de um checkpoint específico:
```
CHECKPOINT: alex-hormozi-mastermind-2026-03
  Fase completada: 2/5
  Chunks processados: 4/12
  Artifacts gerados: 4 chunks, 4 insight files
  Último update: 2026-03-06 03:48
  Status: IN_PROGRESS — retomar com /aureon-checkpoint resume
```

### clear
Move checkpoints completados para `processing/checkpoints/archive/`.

## Quando usar

- **save**: ao pausar manualmente um pipeline longo
- **resume**: ao retomar após interrupção
- **list**: para ver o que está em andamento
- **clear**: para fazer housekeeping

## Pipeline Chunked

Para usar checkpoint junto com ingestão por chunks:
```
/aureon-process --chunked inbox/video-longo.md
```

O sistema cria checkpoints automáticos sem precisar chamar `/aureon-checkpoint save` manualmente.

---

**Workflow completo:** `core/workflows/wf-ingest-chunked.yaml`
