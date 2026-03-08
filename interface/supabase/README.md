# Supabase Setup Guide

## 📋 Overview

Este diretório contém as migrations SQL e configurações para o banco de dados Supabase compartilhado entre:

- **Interface J.A.R.V.I.S** (dashboard web)
- **N8N** (workflows de automação)
- **Aureon AI Core** (sistema de knowledge base)

## 🚀 Initial Setup

### 1. Create Supabase Project

1. Acesse [supabase.com](https://supabase.com)
2. Clique em "New Project"
3. Escolha organização e região (recomendado: South America - São Paulo)
4. Defina nome do projeto: `aureon-ai` (ou outro de sua escolha)
5. Defina senha do database (salve em local seguro!)
6. Aguarde provisioning (~2 minutos)

### 2. Get API Credentials

1. No dashboard do Supabase, vá para **Settings → API**
2. Copie as seguintes credenciais:
   - **Project URL** (ex: `https://abcdefgh.supabase.co`)
   - **anon/public key** (API Key pública)
   - **service_role key** (API Key com permissões admin - **nunca exponha no frontend!**)

3. No dashboard, vá para **Settings → Database → Connection String**
4. Copie o **JWT Secret** (será usado para validação de tokens)

### 3. Update .env File

Adicione as credenciais ao seu `.env`:

```bash
# Supabase
SUPABASE_URL=https://abcdefgh.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...  # Same as ANON_KEY
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_JWT_SECRET=your-super-secret-jwt-token-with-at-least-32-characters
```

### 4. Run Initial Migration

1. No dashboard do Supabase, vá para **SQL Editor**
2. Clique em **New Query**
3. Copie todo o conteúdo de [`migrations/001_initial_schema.sql`](migrations/001_initial_schema.sql)
4. Cole no editor SQL
5. Clique em **Run** (botão verde no canto inferior direito)
6. Aguarde execução (~10 segundos)
7. Verifique que não há erros (output deve mostrar "Success")

### 5. Verify Tables Created

No SQL Editor, execute:

```sql
SELECT tablename FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
```

Você deve ver as seguintes tabelas:
- `activity_feed`
- `chat_messages`
- `chat_sessions`
- `skill_executions`
- `squads`
- `system_metrics`
- `users`
- `whatsapp_messages`

### 6. Create Storage Buckets

1. No dashboard, vá para **Storage**
2. Clique em **New Bucket**

**Bucket 1: avatars**
- Name: `avatars`
- Public: ✅ Yes
- Allowed MIME types: `image/png, image/jpeg, image/webp`
- Max file size: `2MB`

**Bucket 2: uploads**
- Name: `uploads`
- Public: ❌ No
- Allowed MIME types: `application/pdf, text/*, video/*, audio/*`
- Max file size: `100MB`

**Bucket 3: logs**
- Name: `logs`
- Public: ❌ No
- Allowed MIME types: `text/plain`
- Max file size: `50MB`

### 7. Enable Realtime

1. No dashboard, vá para **Database → Replication**
2. Habilite as seguintes tabelas para replication:
   - ✅ `activity_feed`
   - ✅ `system_metrics`
   - ✅ `whatsapp_messages`
   - ✅ `skill_executions`

Isso permite que o frontend receba updates em tempo real via WebSocket.

## 🔐 Authentication Setup (Optional)

### Email/Password Auth

1. No dashboard, vá para **Authentication → Providers**
2. Habilite **Email** provider
3. Configure:
   - ✅ Enable email confirmations (recomendado para produção)
   - ✅ Secure email change (recomendado)

### Magic Link (Passwordless)

1. Em **Authentication → Providers**
2. Habilite **Email** provider
3. Marque ✅ **Enable Magic Link**

### OAuth Providers (Optional)

Habilite provedores sociais conforme necessário:
- Google
- GitHub
- GitLab
- etc.

## 📊 Database Schema

Veja o schema completo em [`migrations/001_initial_schema.sql`](migrations/001_initial_schema.sql).

### Main Tables

| Table | Purpose |
|-------|---------|
| `users` | User profiles, roles, preferences |
| `chat_sessions` | Chat sessions com Aureon AI |
| `chat_messages` | Mensagens individuais (user/assistant) |
| `skill_executions` | Histórico de execuções de skills |
| `whatsapp_messages` | Mensagens WhatsApp (incoming/outgoing) |
| `system_metrics` | Métricas do sistema (CPU, RAM, Disk) |
| `activity_feed` | Stream de eventos em tempo real |
| `squads` | Configuração dos 7 SQUADs |

### Row Level Security (RLS)

Todas as tabelas têm RLS habilitado. Exemplos de políticas:

- **users**: Usuários veem apenas seus próprios dados (admins veem todos)
- **chat_sessions**: Usuários gerenciam apenas suas próprias sessões
- **skill_executions**: Todos autenticados podem ver, mas só podem inserir os próprios
- **whatsapp_messages**: Todos autenticados podem ver (read-only para usuários)

## 🔧 Maintenance

### Cleanup Old Data

Execute periodicamente (via Edge Function ou manualmente):

```sql
-- Cleanup metrics older than 7 days
SELECT cleanup_old_metrics();

-- Cleanup activity older than 30 days
SELECT cleanup_old_activity();
```

### Backup Database

Supabase faz backups automáticos, mas você pode fazer backup manual:

1. No dashboard, vá para **Database → Backups**
2. Clique em **Create Backup**

## 🔌 N8N Integration

### Using Supabase Node in N8N

1. No N8N, adicione node **Supabase**
2. Configure credentials:
   - **Host**: `abcdefgh.supabase.co`
   - **Service Role Secret**: `your-service-key`

### Insert WhatsApp Message via N8N

```json
{
  "operation": "executeFunction",
  "function": "insert_whatsapp_message",
  "parameters": {
    "p_direction": "incoming",
    "p_contact_number": "+5551981234567",
    "p_contact_name": "John Doe",
    "p_message": "Olá, preciso de ajuda!",
    "p_squad_activated": "sales"
  }
}
```

### Insert Activity via N8N

```json
{
  "operation": "executeFunction",
  "function": "insert_activity",
  "parameters": {
    "p_event_type": "execution",
    "p_title": "N8N Workflow executed",
    "p_description": "Lead enrichment workflow completed",
    "p_metadata": {
      "workflow_id": "abc123",
      "execution_time": 1234
    }
  }
}
```

## 📚 Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase JS Client](https://supabase.com/docs/reference/javascript/introduction)
- [Supabase Python Client](https://supabase.com/docs/reference/python/introduction)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Realtime Documentation](https://supabase.com/docs/guides/realtime)

## 🆘 Troubleshooting

### "relation does not exist" error

- Certifique-se de que rodou a migration `001_initial_schema.sql`
- Verifique que está conectado ao projeto correto

### RLS blocking queries

- Se estiver testando, você pode temporariamente desabilitar RLS:
  ```sql
  ALTER TABLE your_table DISABLE ROW LEVEL SECURITY;
  ```
- Em produção, ajuste as policies conforme necessário

### Realtime not working

- Verifique que a tabela está habilitada em **Database → Replication**
- Confirme que o cliente está subscribed ao canal correto
- Check browser console para erros de WebSocket

---

**Status:** ✅ Setup completo quando todos os passos acima forem executados
