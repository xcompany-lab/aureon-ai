# Quick Start - Aureon AI

> Do zero ao primeiro insight em 5 minutos.

Este guia assume que você já executou a instalação (`npx aureon-ai install`) e o setup inicial (`/setup`). Se ainda não fez isso, consulte o [README.md](README.md).

---

## Passo 1: Insira seu primeiro conteúdo

O Aureon AI aceita qualquer material de especialista. Vamos começar com um vídeo do YouTube.

**Comando:**

```
/ingest https://www.youtube.com/watch?v=EXEMPLO_ID
```

**O que acontece:**
- O Aureon baixa a transcrição automaticamente
- O arquivo é salvo em `inbox/` com metadados (título, autor, data)
- Um registro é criado no sistema de rastreabilidade

**Saída esperada:**

```
AUREON: Material recebido.

  Fonte:    YouTube
  Título:   "Como Criar Ofertas Irrecusáveis"
  Autor:    Alex Hormozi
  Duração:  42:15
  Palavras: 6.230

  Salvo em: inbox/alex-hormozi/como-criar-ofertas-irrecusaveis.md

  Próximo passo: execute /aureon-process para processar.
```

**Dica:** Você também pode ingerir arquivos locais (PDFs, transcrições, documentos):

```
/ingest /caminho/para/playbook-vendas.pdf
```

---

## Passo 2: Processe com Aureon

Agora o Aureon vai processar o material pelo pipeline de 5 fases.

**Comando:**

```
/aureon-process
```

**O que acontece:**
1. **Chunking** - Quebra o conteúdo em segmentos semânticos
2. **Resolução** - Identifica pessoas, conceitos e entidades
3. **Extração** - Extrai frameworks, insights e regras práticas
4. **Síntese** - Consolida narrativas por tema
5. **Compilação** - Gera dossiê e playbook prontos para uso

**Saída esperada:**

```
AUREON: Pipeline iniciado.

  Fase 1/5 - Chunking .............. OK (23 chunks)
  Fase 2/5 - Resolução ............ OK (8 entidades)
  Fase 3/5 - Extração ............. OK (12 insights)
  Fase 4/5 - Síntese .............. OK (3 narrativas)
  Fase 5/5 - Compilação ........... OK

  Resultado:
    Dossiê:   knowledge/dossiers/alex-hormozi.md
    Playbook: knowledge/playbooks/ofertas-irrecusaveis.md
    Insights: 12 novos insights indexados

  Tempo total: 2m 34s
```

---

## Passo 3: Veja o resultado

Confira o status geral do sistema e os materiais processados.

**Comando:**

```
/aureon-status
```

**Saída esperada:**

```
AUREON: Status Operacional

  Health Score: 92/100

  Base de Conhecimento:
    Especialistas:  1
    Dossiês:        1
    Playbooks:      1
    Insights:       12

  Último processamento:
    "Como Criar Ofertas Irrecusáveis" (Alex Hormozi)
    Processado em: 2026-03-06 03:48

  SQUADs ativos:
    Sales Squad .... Pronto (12 insights carregados)
    Exec Squad ..... Pronto (4 insights carregados)
    Ops Squad ...... Aguardando material
    Marketing Squad  Aguardando material

  Inbox pendente: 0 arquivos
```

---

## Passo 4: Primeira extração de DNA

A extração de DNA cria um clone mental completo de um especialista. Funciona melhor quando você já processou vários materiais do mesmo autor.

**Comando:**

```
/extract-dna alex-hormozi
```

**O que acontece:**
- O Aureon analisa todos os materiais processados daquele especialista
- Extrai o DNA cognitivo em 5 camadas (Filosofias, Modelos Mentais, Heurísticas, Frameworks, Metodologias)
- Cria um agente dedicado que responde como o especialista

**Saída esperada:**

```
AUREON: Extração de DNA iniciada.

  Especialista: Alex Hormozi
  Materiais analisados: 1

  Camada L1 - Filosofias .......... OK (5 crenças extraídas)
  Camada L2 - Modelos Mentais ..... OK (3 frameworks)
  Camada L3 - Heurísticas ......... OK (8 regras práticas)
  Camada L4 - Frameworks .......... OK (2 metodologias)
  Camada L5 - Metodologias ........ OK (1 processo completo)

  DNA salvo em: knowledge/dna/alex-hormozi-dna.md
  Agente criado: agents/minds/alex-hormozi.md

  Agora você pode consultar:
    /ask alex-hormozi "Como precificar minha oferta high-ticket?"
```

**Dica:** Quanto mais materiais de um especialista você processar antes da extração de DNA, mais rico e preciso será o clone. Recomendamos pelo menos 3-5 materiais por especialista.

---

## Passo 5: Ativar um SQUAD

Os SQUADs são times de especialistas organizados por setor. Use o SQUAD correto para resolver qualquer demanda.

**Comando:**

```
/squad sales "Como responder objeção de preço?"
```

**O que acontece:**
- O Master Router identifica o SQUAD correto
- O Squad Router despacha para o especialista dentro do SQUAD
- O especialista responde com base no conhecimento processado

**Saída esperada:**

```
AUREON SQUAD — SALES
  SELECTED: CLOSER
  CONTEXT PACK:
  - Objeção de preço identificada
  - Material base: Alex Hormozi — Value Equation
  - Framework aplicado: CLOSE method
  USE AGENT: agents/cargo/sales/closer/AGENT.md

CLOSER: A objeção de preço quase sempre é uma objeção de valor...
```

---

## Passo 6: Primeira sessão do Conclave

O Conclave é um conselho de 3 conselheiros que debate qualquer decisão estratégica do seu negócio.

**Comando:**

```
/conclave "Devo lançar um produto de R$2.997 ou R$4.997?"
```

**O que acontece:**
- 3 conselheiros analisam sua pergunta sob perspectivas diferentes
- Cada um fundamenta sua posição com base no conhecimento processado
- O Sintetizador consolida as posições em uma recomendação

---

## Próximos Passos

Agora que você tem o básico funcionando, considere:

1. **Processar mais materiais** - Quanto mais conteúdo, mais inteligente o sistema fica
2. **Diversificar especialistas** - Cada novo especialista adiciona perspectivas
3. **Usar SQUADs** - Sales, Exec, Ops, Marketing, Tech, Research, Finance
4. **Conectar OpenClaw** - Comandos via WhatsApp → squads → resposta automática

Para configurar API keys adicionais, consulte [docs/api-keys-guide.md](docs/api-keys-guide.md).

---

*Aureon AI v2.0.0 — X-Company*
