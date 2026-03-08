# Interface J.A.R.V.I.S — Frontend Setup

## Quick Start

### 1. Create `.env.local` file

```bash
cp .env.example .env.local
```

Then edit `.env.local` and add your Supabase credentials:

```bash
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
VITE_API_URL=http://localhost:5000
```

### 2. Install dependencies (if not already done)

```bash
npm install
```

### 3. Run development server

```bash
npm run dev
```

Access: http://localhost:5173

## Getting Supabase Credentials

1. Go to your Supabase project dashboard
2. Navigate to **Settings → API**
3. Copy:
   - **Project URL** → `VITE_SUPABASE_URL`
   - **anon/public key** → `VITE_SUPABASE_ANON_KEY`

## First Time Setup

### 1. Run Supabase Migration

Make sure you've run the migration script:
- See: `../supabase/migrations/001_initial_schema.sql`
- Instructions: `../supabase/README.md`

### 2. Create First User

When you first access the app, you'll see the login page. Click "Don't have an account? Sign up" to create your first user.

## Project Structure

```
src/
├── components/        # React components
│   ├── ui/           # shadcn/ui components (future)
│   ├── layout/       # Layout components (future)
│   └── ProtectedRoute.tsx
├── pages/            # Page components
│   ├── Login.tsx
│   └── Dashboard.tsx
├── services/         # API clients
│   └── supabase.ts
├── store/            # Zustand stores
│   └── authStore.ts
├── hooks/            # Custom React hooks (future)
├── types/            # TypeScript types (future)
├── utils/            # Utility functions (future)
├── App.tsx           # Main app component
├── main.tsx          # Entry point
└── index.css         # Global styles
```

## Available Scripts

- `npm run dev` — Start development server
- `npm run build` — Build for production
- `npm run preview` — Preview production build
- `npm run lint` — Run ESLint

## Troubleshooting

### "Missing Supabase environment variables"

- Make sure you created `.env.local` from `.env.example`
- Verify the file is in the `interface/frontend/` directory
- Restart the dev server after creating `.env.local`

### Login fails with "Invalid credentials"

- Verify Supabase project is active
- Check that migration script was executed
- Try creating a new account (Sign Up)

### Page is blank or stuck on "Initializing..."

- Open browser DevTools (F12) and check Console for errors
- Verify Supabase URL and keys are correct
- Check network tab for failed requests

## Next Steps (Phase 2)

Once Phase 1 is working:
- [ ] Real-time system metrics
- [ ] SQUAD status cards
- [ ] Activity feed with live updates
- [ ] Charts with historical data
- [ ] Sidebar navigation
- [ ] Header with user menu

---

**Status:** Phase 1 Foundation ✅ Complete
**Next:** Phase 2 Dashboard Implementation
