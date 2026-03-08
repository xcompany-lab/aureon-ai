# Interface J.A.R.V.I.S — Aureon AI Dashboard

> **Status:** 📐 Ready to build
> **Architecture:** React 18 + Flask + Supabase
> **Timeline:** 44-58 hours (7 phases)

---

## 🎯 Quick Start

### Prerequisites

1. **Supabase Account** → [supabase.com](https://supabase.com)
2. **Node.js 18+** → [nodejs.org](https://nodejs.org)
3. **Python 3.11+** → Already installed
4. **SSH Access** → OpenClaw remote server

### Setup (5 minutes)

```bash
# 1. Setup Supabase
# Follow instructions in: supabase/README.md
# Run migration: supabase/migrations/001_initial_schema.sql

# 2. Configure environment
cp .env.example .env
# Edit .env and add your Supabase credentials

# 3. Backend setup
cd interface/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 4. Frontend setup
cd ../frontend
npm install

# 5. Run development servers
# Terminal 1 (Backend)
cd interface/backend
source venv/bin/activate
python app.py

# Terminal 2 (Frontend)
cd interface/frontend
npm run dev
```

Access: http://localhost:5173

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [INTERFACE-JARVIS-SPEC.md](../docs/INTERFACE-JARVIS-SPEC.md) | Complete technical specification (30+ pages) |
| [supabase/README.md](supabase/README.md) | Supabase setup guide |
| [supabase/migrations/001_initial_schema.sql](supabase/migrations/001_initial_schema.sql) | Database schema (7 tables, RLS policies, functions) |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Browser (React)                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  Dashboard  │  │    Chat     │  │   Control   │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└────────────┬────────────────────────────────────────────────┘
             │
             ├─► Supabase JS Client (Auth + DB + Storage + Realtime)
             │
             ├─► Flask API (Skills Execution)
             │        │
             │        └─► bin/openclaw-remote-skill.py
             │                    │
             │                    └─► SSH → OpenClaw Server
             │
             └─► Supabase PostgreSQL
                      │
                      ├─► N8N (workflows)
                      └─► Aureon AI Core (knowledge base)
```

---

## 🎨 Features

### 1. Dashboard 📊
- System status (CPU, RAM, Disk, Uptime)
- 7 SQUAD cards (Sales, Exec, Ops, Tech, Marketing, Research, Finance)
- Real-time charts (CPU/RAM history)
- Activity feed (live events stream)

### 2. Chat 💬
- Direct chat with Aureon AI
- Session management
- Markdown rendering
- File upload
- Command support (`/status`, `/execute`, etc.)

### 3. Control Panel ⚙️
- Execute 7 remote skills (system_status, read_logs, deploy_app, etc.)
- Deploy panel (staging/production)
- N8N workflow triggers
- Execution history with details

### 4. Logs & Monitoring 📜
- Multi-source log viewer (OpenClaw, Aureon, System)
- Advanced filters (time, level, search)
- Syntax highlighting
- Download logs

### 5. WhatsApp Integration 📱
- Message list (incoming/outgoing)
- Send messages via UI
- Contact management
- Pairing status

### 6. Settings ⚙️
- User profile
- System configuration
- Security (tokens, sessions)
- Notifications

---

## 🗄️ Database Schema (Supabase)

| Table | Rows (initial) | Purpose |
|-------|----------------|---------|
| `users` | 0 | User profiles, roles, preferences |
| `chat_sessions` | 0 | Chat sessions with Aureon AI |
| `chat_messages` | 0 | Individual messages (user/assistant) |
| `skill_executions` | 0 | Execution history |
| `whatsapp_messages` | 0 | WhatsApp messages (incoming/outgoing) |
| `system_metrics` | 0 | System metrics (CPU, RAM, Disk) |
| `activity_feed` | 0 | Real-time events stream |
| `squads` | 7 | SQUADs configuration (pre-populated) |

**Total tables:** 8
**Total functions:** 5 (insert_activity, insert_whatsapp_message, etc.)
**Total policies:** 20+ (Row Level Security)

---

## 📊 Implementation Phases

### ✅ Phase 0: Planning (COMPLETE)
- [x] Full specification document
- [x] Database schema design
- [x] Supabase migration script
- [x] Setup documentation

### ⏳ Phase 1: Foundation (10-12h)
- [ ] Setup React + Vite + TypeScript + Tailwind
- [ ] Setup Flask + Supabase Python client
- [ ] Implement Supabase Auth (login/logout/register)
- [ ] Implement Supabase Realtime (WebSocket setup)
- [ ] Basic layout (Sidebar, Header, Routes)

### ⏳ Phase 2: Dashboard (8-10h)
- [ ] System status cards (integrate with remote skills)
- [ ] SQUAD cards (read from Supabase)
- [ ] Real-time charts (Recharts + system_metrics table)
- [ ] Activity feed (subscribe to activity_feed channel)

### ⏳ Phase 3: Control Panel (6-8h)
- [ ] Skill executor (dynamic form based on skill)
- [ ] Deploy panel (staging/production flow)
- [ ] N8N trigger (payload builder)
- [ ] Execution history table (skill_executions)

### ⏳ Phase 4: Chat (6-8h)
- [ ] Chat window (ChatGPT-like UI)
- [ ] Session management (create, list, delete)
- [ ] Markdown rendering (react-markdown)
- [ ] File upload (Supabase Storage)
- [ ] Commands support

### ⏳ Phase 5: Logs & WhatsApp (6-8h)
- [ ] Log viewer (read_logs skill integration)
- [ ] Filters (time, level, search)
- [ ] WhatsApp message list (whatsapp_messages table)
- [ ] Send message form (openclaw-send-message.py)

### ⏳ Phase 6: Settings & Polish (4-6h)
- [ ] User profile (avatar upload to Supabase Storage)
- [ ] System configuration (OpenClaw, N8N URLs)
- [ ] Security settings (change password, API tokens)
- [ ] Mobile responsive (Tailwind breakpoints)
- [ ] Dark mode toggle

### ⏳ Phase 7: Deployment (4-6h)
- [ ] Nginx config
- [ ] Systemd services
- [ ] API documentation (Swagger/OpenAPI)
- [ ] User guide
- [ ] Deploy scripts

**Total:** 44-58 hours

---

## 🔑 Key Benefits of Supabase Integration

1. **Shared Data Layer**
   - Interface, N8N, and Aureon AI share the same database
   - No need for sync mechanisms or APIs between services
   - Single source of truth

2. **Real-time by Default**
   - Supabase Realtime replaces Socket.IO
   - Less code, less complexity
   - Native broadcast channels

3. **Auth Built-in**
   - JWT tokens
   - OAuth providers (Google, GitHub, etc.)
   - Magic Links (passwordless)
   - Row Level Security (permissions at DB level)

4. **Storage Included**
   - Upload avatars, files, logs
   - CDN integration
   - Automatic public URLs

5. **Managed PostgreSQL**
   - Automatic backups
   - Scalable (upgrade plan as needed)
   - Dashboard with SQL editor

---

## 🔐 Security

- **Row Level Security (RLS)** enabled on all tables
- **JWT tokens** for authentication
- **Service Role Key** never exposed to frontend
- **CORS** configured for production domain
- **Environment variables** for all secrets

---

## 🚀 Next Steps

1. **Create Supabase project** → [supabase.com](https://supabase.com)
2. **Run migration** → [supabase/migrations/001_initial_schema.sql](supabase/migrations/001_initial_schema.sql)
3. **Update .env** → Add Supabase credentials
4. **Start building** → Phase 1 (Foundation)

---

## 📞 Support

Questions? Check:
- [INTERFACE-JARVIS-SPEC.md](../docs/INTERFACE-JARVIS-SPEC.md) — Full technical spec
- [supabase/README.md](supabase/README.md) — Supabase setup guide
- [Supabase Docs](https://supabase.com/docs) — Official documentation

---

**Status:** 🟢 Ready to build
**Last updated:** 2026-03-08
