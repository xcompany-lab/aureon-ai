# Interface J.A.R.V.I.S — Especificação Definitiva

> **Status:** 📐 Planning Phase
> **Target:** Production-ready, enterprise-grade web interface
> **Timeline:** 40-50 hours (phased implementation)
> **Version:** 1.0.0

---

## 🎯 Objetivos

### Primários
1. **Visibilidade Total** — Dashboard em tempo real do estado do Aureon AI
2. **Controle Completo** — Executar qualquer ação disponível via UI
3. **Chat Direto** — Conversar com Aureon AI sem WhatsApp
4. **Auditoria** — Histórico completo de execuções, logs, decisões

### Secundários
5. **Multi-user** — Suporte a múltiplos usuários com permissões
6. **Mobile-first** — Responsivo para acesso via celular
7. **Extensível** — Arquitetura que permite adicionar features facilmente

---

## 🏗️ Arquitetura Técnica

### Stack Escolhido

#### Frontend
- **Framework:** React 18 + TypeScript
- **UI Library:** shadcn/ui (componentes modernos, customizáveis)
- **Styling:** Tailwind CSS
- **State Management:** Zustand (leve, simples)
- **Real-time:** Supabase JS Client (realtime subscriptions)
- **Auth:** Supabase Auth (client-side)
- **Charts:** Recharts
- **Build:** Vite

**Por quê React + Supabase Client?**
- ✅ Ecosystem maduro
- ✅ TypeScript nativo
- ✅ shadcn/ui = componentes prontos + customizáveis
- ✅ Supabase Client = Auth + DB + Storage + Realtime em um SDK
- ✅ Fácil contratar desenvolvedores para manutenção futura

#### Backend
- **Framework:** Flask (Python 3.11+)
- **Real-time:** Supabase Realtime (broadcast channels + presence)
- **API:** RESTful + Supabase Client
- **Auth:** Supabase Auth (JWT + Row Level Security)
- **Database:** Supabase (PostgreSQL managed)
- **ORM:** Supabase Python Client (supabase-py)
- **Storage:** Supabase Storage (file uploads)
- **Task Queue:** Background threads (futuro: Celery)

**Por quê Flask + Supabase?**
- ✅ Integração direta com skills Python existentes
- ✅ **Database compartilhado com N8N e outros serviços**
- ✅ Real-time nativo (broadcast channels, sem Socket.IO)
- ✅ Auth completo built-in (OAuth, Magic Links, JWT)
- ✅ Storage para uploads (avatars, materiais, logs)
- ✅ Row Level Security (permissões no DB level)
- ✅ Backups automáticos e escalável (managed PostgreSQL)
- ✅ Webhooks nativos (integração com N8N facilitada)

#### Deployment
- **Development:** Vite dev server (frontend) + Flask dev server (backend)
- **Production:**
  - Frontend: Build estático servido por Nginx
  - Backend: Gunicorn (WSGI) + Nginx (reverse proxy)
  - Process Manager: systemd

---

## 📐 Estrutura de Diretórios

```
interface/
├── backend/
│   ├── api/
│   │   ├── __init__.py
│   │   ├── auth.py              # Endpoints de autenticação
│   │   ├── system.py            # Endpoints de status/monitoring
│   │   ├── squads.py            # Endpoints de SQUADs
│   │   ├── skills.py            # Endpoints para executar skills
│   │   ├── chat.py              # Endpoints de chat com Aureon AI
│   │   ├── logs.py              # Endpoints de logs
│   │   ├── whatsapp.py          # Endpoints de WhatsApp
│   │   └── files.py             # Endpoints de upload/download
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py              # User model
│   │   ├── session.py           # Chat session model
│   │   ├── execution.py         # Execution log model
│   │   └── message.py           # WhatsApp message model
│   ├── services/
│   │   ├── __init__.py
│   │   ├── remote_skill.py      # Service para executar skills remotos
│   │   ├── aureon_chat.py       # Service para chat com Aureon AI
│   │   ├── system_monitor.py    # Service de monitoring
│   │   └── whatsapp_bridge.py   # Service de integração WhatsApp
│   ├── utils/
│   │   ├── __init__.py
│   │   ├── auth.py              # JWT helpers
│   │   ├── validators.py        # Input validation
│   │   └── errors.py            # Error handlers
│   ├── config.py                # Configuração centralizada
│   ├── supabase_client.py       # Supabase client singleton
│   ├── app.py                   # Flask app factory
│   ├── wsgi.py                  # WSGI entry point
│   └── requirements.txt         # Python dependencies
├── frontend/
│   ├── public/
│   │   ├── favicon.ico
│   │   └── logo.svg
│   ├── src/
│   │   ├── components/
│   │   │   ├── ui/              # shadcn/ui components
│   │   │   ├── layout/
│   │   │   │   ├── Sidebar.tsx
│   │   │   │   ├── Header.tsx
│   │   │   │   └── Layout.tsx
│   │   │   ├── dashboard/
│   │   │   │   ├── StatusCard.tsx
│   │   │   │   ├── SystemChart.tsx
│   │   │   │   ├── SquadCard.tsx
│   │   │   │   └── ActivityFeed.tsx
│   │   │   ├── chat/
│   │   │   │   ├── ChatWindow.tsx
│   │   │   │   ├── MessageBubble.tsx
│   │   │   │   └── InputBox.tsx
│   │   │   ├── control/
│   │   │   │   ├── SkillExecutor.tsx
│   │   │   │   ├── DeployPanel.tsx
│   │   │   │   └── N8NTrigger.tsx
│   │   │   ├── logs/
│   │   │   │   ├── LogViewer.tsx
│   │   │   │   └── LogFilter.tsx
│   │   │   └── whatsapp/
│   │   │       ├── MessageList.tsx
│   │   │       └── SendMessage.tsx
│   │   ├── pages/
│   │   │   ├── Dashboard.tsx
│   │   │   ├── Chat.tsx
│   │   │   ├── Control.tsx
│   │   │   ├── Logs.tsx
│   │   │   ├── WhatsApp.tsx
│   │   │   ├── Settings.tsx
│   │   │   └── Login.tsx
│   │   ├── hooks/
│   │   │   ├── useAuth.ts
│   │   │   ├── useRealtime.ts   # Supabase realtime hook
│   │   │   ├── useSystemStatus.ts
│   │   │   └── useSquads.ts
│   │   ├── services/
│   │   │   ├── supabase.ts      # Supabase client singleton
│   │   │   ├── api.ts           # Flask API client (skills execution)
│   │   │   └── auth.ts          # Auth service (Supabase wrapper)
│   │   ├── store/
│   │   │   ├── authStore.ts     # Zustand auth store
│   │   │   ├── systemStore.ts   # Zustand system store
│   │   │   └── chatStore.ts     # Zustand chat store
│   │   ├── types/
│   │   │   ├── api.ts
│   │   │   ├── system.ts
│   │   │   └── squad.ts
│   │   ├── utils/
│   │   │   ├── formatters.ts
│   │   │   └── validators.ts
│   │   ├── App.tsx
│   │   ├── main.tsx
│   │   └── index.css
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts
│   └── tailwind.config.js
├── deployment/
│   ├── nginx.conf               # Nginx config
│   ├── systemd/
│   │   ├── jarvis-api.service   # Backend service
│   │   └── jarvis-frontend.service
│   ├── docker/
│   │   ├── Dockerfile.backend
│   │   ├── Dockerfile.frontend
│   │   └── docker-compose.yml
│   └── scripts/
│       ├── deploy.sh
│       ├── backup.sh
│       └── rollback.sh
├── docs/
│   ├── API.md                   # API documentation
│   ├── ARCHITECTURE.md          # Technical architecture
│   ├── DEPLOYMENT.md            # Deployment guide
│   └── USER-GUIDE.md            # User manual
├── .env.example
├── .gitignore
└── README.md
```

---

## 🗄️ Supabase Database Schema

### Tables

#### users
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'operator', -- admin, operator, viewer
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS (Row Level Security)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Admins can view all users"
  ON users FOR SELECT
  USING (auth.jwt() ->> 'role' = 'admin');
```

#### chat_sessions
```sql
CREATE TABLE chat_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE chat_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own sessions"
  ON chat_sessions FOR ALL
  USING (auth.uid() = user_id);
```

#### chat_messages
```sql
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES chat_sessions(id) ON DELETE CASCADE,
  role TEXT NOT NULL, -- user, assistant
  content TEXT NOT NULL,
  metadata JSONB, -- tokens, model, etc.
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view messages from their sessions"
  ON chat_messages FOR SELECT
  USING (
    session_id IN (
      SELECT id FROM chat_sessions WHERE user_id = auth.uid()
    )
  );
```

#### skill_executions
```sql
CREATE TABLE skill_executions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  skill_name TEXT NOT NULL,
  input_params JSONB,
  output JSONB,
  status TEXT NOT NULL, -- pending, running, success, error
  duration_ms INTEGER,
  error TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

-- RLS
ALTER TABLE skill_executions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all executions"
  ON skill_executions FOR SELECT
  USING (true);

CREATE POLICY "Users can insert their own executions"
  ON skill_executions FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

#### whatsapp_messages
```sql
CREATE TABLE whatsapp_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  direction TEXT NOT NULL, -- incoming, outgoing
  contact_name TEXT,
  contact_number TEXT NOT NULL,
  message TEXT NOT NULL,
  status TEXT, -- sent, delivered, read, failed
  squad_activated TEXT, -- sales, exec, ops, etc.
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index para busca rápida
CREATE INDEX idx_whatsapp_contact ON whatsapp_messages(contact_number);
CREATE INDEX idx_whatsapp_created ON whatsapp_messages(created_at DESC);

-- RLS
ALTER TABLE whatsapp_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view messages"
  ON whatsapp_messages FOR SELECT
  USING (auth.role() = 'authenticated');
```

#### system_metrics
```sql
CREATE TABLE system_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  metric_type TEXT NOT NULL, -- cpu, ram, disk
  value NUMERIC NOT NULL,
  metadata JSONB,
  recorded_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index para queries por tempo
CREATE INDEX idx_metrics_time ON system_metrics(recorded_at DESC);

-- RLS
ALTER TABLE system_metrics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view metrics"
  ON system_metrics FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "System can insert metrics"
  ON system_metrics FOR INSERT
  WITH CHECK (true);
```

#### activity_feed
```sql
CREATE TABLE activity_feed (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type TEXT NOT NULL, -- execution, whatsapp, squad_activation, error
  title TEXT NOT NULL,
  description TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index para busca rápida
CREATE INDEX idx_activity_created ON activity_feed(created_at DESC);

-- RLS
ALTER TABLE activity_feed ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view activity"
  ON activity_feed FOR SELECT
  USING (auth.role() = 'authenticated');
```

### Supabase Realtime Channels

#### `system-metrics` channel
- **Purpose:** Broadcasting system status (CPU, RAM, Disk) em tempo real
- **Events:**
  - `cpu_update` — CPU usage atualizado
  - `ram_update` — RAM usage atualizado
  - `disk_update` — Disk usage atualizado

#### `activity-feed` channel
- **Purpose:** Stream de eventos em tempo real
- **Events:**
  - `new_activity` — Nova atividade registrada

#### `whatsapp` channel
- **Purpose:** Notificações de mensagens WhatsApp
- **Events:**
  - `message_received` — Nova mensagem recebida
  - `message_sent` — Mensagem enviada

### Supabase Storage Buckets

#### `avatars`
- **Purpose:** User profile avatars
- **Public:** Yes
- **Allowed MIME types:** image/png, image/jpeg, image/webp
- **Max file size:** 2MB

#### `uploads`
- **Purpose:** Arquivos enviados via chat (materiais, PDFs)
- **Public:** No (authenticated only)
- **Allowed MIME types:** application/pdf, text/*, video/*, audio/*
- **Max file size:** 100MB

#### `logs`
- **Purpose:** Log files exportados
- **Public:** No (authenticated only)
- **Allowed MIME types:** text/plain
- **Max file size:** 50MB

### Environment Variables

```bash
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-role-key  # Backend only (admin operations)

# Supabase Auth (optional, se usar OAuth)
SUPABASE_JWT_SECRET=your-jwt-secret
```

### Integration Benefits

1. **Shared Data Layer**
   - N8N workflows podem ler/escrever diretamente no Supabase
   - Interface e N8N compartilham mesmas tabelas
   - Sem necessidade de APIs intermediárias

2. **Real-time by Default**
   - Supabase Realtime substitui Socket.IO
   - Menos código, menos complexidade
   - Broadcast channels nativos

3. **Auth Unificado**
   - Single sign-on entre Interface e N8N (se configurado)
   - JWT tokens compartilhados
   - Row Level Security automático

4. **Storage Simplificado**
   - Upload de arquivos via Supabase Storage
   - URLs públicas automáticas
   - Integração com CDN

---

## 🎨 Features Completas

### 1. Dashboard (Página Principal)

#### Sistema de Cards
- **CPU Status Card**
  - Gauge visual (0-100%)
  - Média dos últimos 5 minutos
  - Threshold warnings (>70% = warning, >90% = critical)

- **RAM Status Card**
  - Usado vs Disponível
  - Progress bar
  - Memory details (buffers, cache)

- **Disk Status Card**
  - Usado vs Total
  - Progress bar
  - Warning se < 10% disponível

- **Uptime Card**
  - Sistema uptime
  - Última reinicialização

- **SQUADs Ativos**
  - 7 cards (Sales, Exec, Ops, Tech, Marketing, Research, Finance)
  - Status: Active/Idle
  - Última ativação
  - Botão "Activate"

#### Gráficos Real-Time
- **CPU History** (últimos 60 minutos)
- **RAM History** (últimos 60 minutos)
- **Request Rate** (requisições/minuto)

#### Activity Feed
- Stream de atividades em tempo real
- Filtros: All, Executions, WhatsApp, Errors
- Formato:
  ```
  [12:34:56] SQUAD Sales activated by WhatsApp message
  [12:35:01] Skill execute_command ran successfully
  [12:35:10] WhatsApp message sent to Kethely
  ```

---

### 2. Chat com Aureon AI

#### Interface
- **Chat Window**
  - Mensagens do usuário (direita, azul)
  - Respostas do Aureon AI (esquerda, cinza)
  - Avatars
  - Timestamps
  - Markdown rendering (código, listas, etc.)

- **Input Box**
  - Text area com auto-resize
  - Botão "Send" (ou Enter)
  - File upload (arrastar e soltar)
  - Emoji picker (opcional)

- **Session Management**
  - Sidebar com histórico de sessões
  - Botão "New Session"
  - Busca em histórico
  - Export sessão como Markdown

#### Features
- **Context Awareness**
  - Aureon AI tem acesso ao estado completo do sistema
  - Pode executar skills via chat
  - Pode ativar SQUADs

- **Commands**
  - `/status` — Status do sistema
  - `/squads` — Listar SQUADs
  - `/execute <skill>` — Executar skill
  - `/logs <service>` — Ver logs

---

### 3. Control Panel

#### Skill Executor
- **UI**
  - Dropdown de skills disponíveis (7 skills)
  - Form dinâmico baseado no skill selecionado
  - Botão "Execute" (com confirmação para ações destrutivas)

- **Skills Disponíveis**
  1. `system_status` — Status do sistema
  2. `read_logs` — Ler logs
  3. `deploy_app` — Deploy aplicação
  4. `n8n_trigger` — Trigger N8N workflow
  5. `squad_activation` — Ativar SQUAD
  6. `send_whatsapp` — Enviar mensagem WhatsApp
  7. `execute_command` — Executar comando shell

- **Execution Output**
  - JSON viewer (syntax highlight)
  - Success/Error status
  - Execution time
  - Botão "Copy" (copiar output)
  - Botão "Retry"

#### Deploy Panel
- **Environments**
  - Staging
  - Production

- **Steps**
  1. Select environment
  2. Confirm (checkbox "I understand...")
  3. Execute
  4. Show progress (git pull → npm install → build → restart → health check)
  5. Show result

#### N8N Trigger
- **Workflows Disponíveis**
  - Lead Enrichment
  - Email Sequence
  - Data Sync
  - Report Generation
  - Custom (input webhook URL)

- **Payload Builder**
  - JSON editor com syntax highlight
  - Templates pré-definidos
  - Validation

---

### 4. Logs & Monitoring

#### Log Viewer
- **Sources**
  - OpenClaw Gateway
  - Aureon AI Core
  - System (syslog)
  - Custom (qualquer journalctl service)

- **Filters**
  - Time range (última hora, últimas 24h, custom)
  - Log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
  - Search query (regex support)

- **Display**
  - Syntax highlighting
  - Line numbers
  - Auto-scroll (toggle)
  - Refresh button
  - Download logs (txt file)

#### Execution History
- **Table**
  - Timestamp
  - Skill executado
  - Usuário
  - Status (Success/Error)
  - Duration
  - Botão "View Details"

- **Details Modal**
  - Input parameters
  - Full output
  - Stack trace (se error)
  - Botão "Re-run"

---

### 5. WhatsApp Integration

#### Message List
- **Display**
  - Contact name/number
  - Message preview
  - Timestamp
  - Direction (incoming/outgoing)
  - Status (sent/delivered/read)

- **Filters**
  - Contact
  - Date range
  - Direction

#### Send Message
- **Form**
  - To: (dropdown de contatos conhecidos + input manual)
  - Message: (text area)
  - Attach: (opcional, futuro)

- **Send**
  - Validation (E.164 format)
  - Confirmation
  - Status feedback

#### Pairing Status
- **Display**
  - Connection status (Connected/Disconnected)
  - Last sync
  - QR Code (se não pareado)
  - Botão "Restart Pairing"

---

### 6. Settings

#### User Profile
- Name
- Email
- Avatar (upload)
- Timezone
- Language (futuro: i18n)

#### System Configuration
- **OpenClaw**
  - Remote host
  - SSH key path
  - Gateway URL

- **N8N**
  - Base URL
  - Webhook URLs (por workflow)

- **Google Drive** (futuro)
  - OAuth status
  - Re-authenticate

#### Security
- Change password
- API tokens (gerar/revogar)
- Session management (ver sessões ativas, logout all)

#### Notifications
- Email notifications (on/off)
- Slack notifications (futuro)
- Discord notifications (futuro)

---

## 🔐 Autenticação & Permissões

### Autenticação
- **JWT-based**
  - Access token (15 min expiry)
  - Refresh token (7 days expiry)
  - HttpOnly cookies (secure)

- **Login Flow**
  1. User submits email + password
  2. Backend validates
  3. Returns access token + refresh token
  4. Frontend stores in memory + HttpOnly cookie
  5. Auto-refresh antes de expirar

### Permissões (Futuro: Role-Based Access Control)
- **Admin**
  - Tudo

- **Operator**
  - Executar skills
  - Ver logs
  - Enviar mensagens WhatsApp
  - Não pode: mudar configurações, gerenciar usuários

- **Viewer**
  - Ver dashboard
  - Ver logs
  - Não pode: executar ações

---

## 🔌 API Specification

### REST Endpoints

#### Authentication
```
POST   /api/auth/login
POST   /api/auth/logout
POST   /api/auth/refresh
GET    /api/auth/me
```

#### System
```
GET    /api/system/status
GET    /api/system/metrics/cpu
GET    /api/system/metrics/ram
GET    /api/system/metrics/disk
GET    /api/system/uptime
```

#### SQUADs
```
GET    /api/squads
GET    /api/squads/:id
POST   /api/squads/:id/activate
GET    /api/squads/:id/status
```

#### Skills
```
GET    /api/skills
GET    /api/skills/:id
POST   /api/skills/:id/execute
GET    /api/skills/executions
GET    /api/skills/executions/:id
```

#### Chat
```
GET    /api/chat/sessions
POST   /api/chat/sessions
GET    /api/chat/sessions/:id
POST   /api/chat/sessions/:id/messages
DELETE /api/chat/sessions/:id
```

#### Logs
```
GET    /api/logs/services
GET    /api/logs/:service
GET    /api/logs/:service/download
```

#### WhatsApp
```
GET    /api/whatsapp/status
GET    /api/whatsapp/messages
POST   /api/whatsapp/messages
GET    /api/whatsapp/contacts
POST   /api/whatsapp/pair
```

#### Files
```
POST   /api/files/upload
GET    /api/files/:id
DELETE /api/files/:id
```

### WebSocket Events

#### Client → Server
```
connect
authenticate
subscribe_system_metrics
subscribe_logs
send_chat_message
```

#### Server → Client
```
authenticated
system_metrics_update
log_entry
chat_message
execution_started
execution_completed
whatsapp_message_received
error
```

---

## 🎨 Design System

### Color Palette
```css
/* Brand Colors */
--primary: #3B82F6      /* Blue */
--secondary: #8B5CF6    /* Purple */
--accent: #10B981       /* Green */

/* Status Colors */
--success: #10B981      /* Green */
--warning: #F59E0B      /* Amber */
--error: #EF4444        /* Red */
--info: #3B82F6         /* Blue */

/* Neutrals */
--bg-primary: #0F172A   /* Dark blue-gray */
--bg-secondary: #1E293B /* Lighter dark */
--text-primary: #F1F5F9 /* Light gray */
--text-secondary: #94A3B8 /* Medium gray */
```

### Typography
- **Headings:** Inter (font-weight: 700)
- **Body:** Inter (font-weight: 400)
- **Monospace:** JetBrains Mono

### Components (shadcn/ui)
- Button
- Card
- Input
- Textarea
- Select
- Dialog
- Dropdown
- Badge
- Progress
- Tabs
- Toast (notifications)
- Skeleton (loading states)

---

## 🚀 Deployment

### Development
```bash
# Backend
cd interface/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py

# Frontend
cd interface/frontend
npm install
npm run dev
```

Access: http://localhost:5173

### Production

#### Build
```bash
# Frontend
cd interface/frontend
npm run build
# Output: dist/

# Backend (no build, já é Python)
```

#### Nginx Config
```nginx
server {
    listen 80;
    server_name jarvis.xcompany.local;

    # Frontend (static files)
    location / {
        root /var/www/jarvis/frontend;
        try_files $uri /index.html;
    }

    # Backend API
    location /api {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # WebSocket
    location /socket.io {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_set_header Host $host;
    }
}
```

#### Systemd Service
```ini
# /etc/systemd/system/jarvis-api.service
[Unit]
Description=J.A.R.V.I.S API
After=network.target

[Service]
User=aureon
WorkingDirectory=/home/aureon/projects/mega-brain-lab/mega-brain/interface/backend
ExecStart=/home/aureon/projects/mega-brain-lab/mega-brain/interface/backend/venv/bin/gunicorn -w 4 -b 127.0.0.1:5000 wsgi:app
Restart=always

[Install]
WantedBy=multi-user.target
```

---

## 📊 Timeline Estimado

### Fase 1: Foundation (10-12h)
- [x] Especificação completa (este documento)
- [ ] Setup projeto (Vite + Flask)
- [ ] Estrutura de diretórios
- [ ] Design system (Tailwind + shadcn/ui)
- [ ] Backend base (Flask + SQLAlchemy + JWT)
- [ ] Frontend base (React + Router + Zustand)
- [ ] Autenticação completa
- [ ] WebSocket setup

### Fase 2: Dashboard (8-10h)
- [ ] System status cards (CPU, RAM, Disk, Uptime)
- [ ] SQUADs cards (7 squads)
- [ ] Real-time charts (CPU/RAM history)
- [ ] Activity feed
- [ ] WebSocket integration (auto-refresh)

### Fase 3: Control Panel (6-8h)
- [ ] Skill executor (7 skills)
- [ ] Deploy panel
- [ ] N8N trigger
- [ ] Execution history

### Fase 4: Chat (6-8h)
- [ ] Chat window
- [ ] Session management
- [ ] Markdown rendering
- [ ] File upload
- [ ] Commands support

### Fase 5: Logs & WhatsApp (6-8h)
- [ ] Log viewer (multi-source)
- [ ] Filters e search
- [ ] WhatsApp message list
- [ ] Send message
- [ ] Pairing status

### Fase 6: Settings & Polish (4-6h)
- [ ] User profile
- [ ] System configuration
- [ ] Security settings
- [ ] Notifications
- [ ] Mobile responsive
- [ ] Dark mode (toggle)

### Fase 7: Deployment & Docs (4-6h)
- [ ] Nginx config
- [ ] Systemd services
- [ ] Docker setup (opcional)
- [ ] API documentation
- [ ] User guide
- [ ] Deploy scripts

**Total:** 44-58 horas

---

## 🧪 Testing Strategy

### Backend
- **Unit Tests:** pytest (70% coverage mínimo)
- **Integration Tests:** API endpoints
- **Load Tests:** Locust (simular 100 usuários concorrentes)

### Frontend
- **Unit Tests:** Vitest (componentes isolados)
- **Integration Tests:** React Testing Library
- **E2E Tests:** Playwright (fluxos críticos)

---

## 📈 Monitoring & Analytics (Futuro)

- **Error Tracking:** Sentry
- **Analytics:** Plausible (self-hosted, privacy-friendly)
- **APM:** OpenTelemetry (traces, métricas)

---

## 🔮 Roadmap Futuro (v2.0+)

1. **Mobile App** (React Native)
2. **Voice Control** (Speech-to-Text)
3. **Multi-tenancy** (suporte a múltiplas empresas)
4. **Plugin System** (adicionar skills via UI)
5. **AI Assistente** (copilot dentro da interface)
6. **Collaborative Features** (múltiplos usuários trabalhando juntos)
7. **Integração Notion** (sincronizar playbooks)
8. **Integração ClickUp** (tasks)
9. **Alerting** (Slack/Discord/Email automático)
10. **Dashboards Customizados** (drag-and-drop widgets)

---

## 📝 Next Steps

1. **Aprovar esta spec** ✋ (aguardando user)
2. **Setup projeto** (criar estrutura)
3. **Implementar Fase 1** (Foundation)
4. **Implementar Fase 2** (Dashboard)
5. **Deploy MVP** (Dashboard + Control Panel)
6. **Iterar** (adicionar features incrementalmente)

---

**Status:** 🟡 Aguardando aprovação para iniciar implementação

