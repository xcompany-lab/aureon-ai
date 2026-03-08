-- Interface J.A.R.V.I.S — Initial Database Schema
-- Run this migration in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- USERS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'operator' CHECK (role IN ('admin', 'operator', 'viewer')),
  timezone TEXT DEFAULT 'America/Sao_Paulo',
  preferences JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies for users
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own data"
  ON users FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Admins can view all users"
  ON users FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================================================
-- CHAT SESSIONS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS chat_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  title TEXT,
  context JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX idx_chat_sessions_user ON chat_sessions(user_id);
CREATE INDEX idx_chat_sessions_updated ON chat_sessions(updated_at DESC);

-- RLS Policies
ALTER TABLE chat_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own sessions"
  ON chat_sessions FOR ALL
  USING (auth.uid() = user_id);

-- ============================================================================
-- CHAT MESSAGES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id UUID REFERENCES chat_sessions(id) ON DELETE CASCADE NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
  content TEXT NOT NULL,
  metadata JSONB DEFAULT '{}'::jsonb, -- tokens, model, etc.
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX idx_chat_messages_session ON chat_messages(session_id);
CREATE INDEX idx_chat_messages_created ON chat_messages(created_at DESC);

-- RLS Policies
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view messages from their sessions"
  ON chat_messages FOR SELECT
  USING (
    session_id IN (
      SELECT id FROM chat_sessions WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert messages to their sessions"
  ON chat_messages FOR INSERT
  WITH CHECK (
    session_id IN (
      SELECT id FROM chat_sessions WHERE user_id = auth.uid()
    )
  );

-- ============================================================================
-- SKILL EXECUTIONS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS skill_executions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  skill_name TEXT NOT NULL,
  input_params JSONB DEFAULT '{}'::jsonb,
  output JSONB DEFAULT '{}'::jsonb,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'running', 'success', 'error')),
  duration_ms INTEGER,
  error TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

-- Index for faster queries
CREATE INDEX idx_skill_executions_user ON skill_executions(user_id);
CREATE INDEX idx_skill_executions_status ON skill_executions(status);
CREATE INDEX idx_skill_executions_created ON skill_executions(created_at DESC);

-- RLS Policies
ALTER TABLE skill_executions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view executions"
  ON skill_executions FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Users can insert their own executions"
  ON skill_executions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own executions"
  ON skill_executions FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================================================
-- WHATSAPP MESSAGES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS whatsapp_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  direction TEXT NOT NULL CHECK (direction IN ('incoming', 'outgoing')),
  contact_name TEXT,
  contact_number TEXT NOT NULL,
  message TEXT NOT NULL,
  status TEXT CHECK (status IN ('sent', 'delivered', 'read', 'failed')),
  squad_activated TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX idx_whatsapp_contact ON whatsapp_messages(contact_number);
CREATE INDEX idx_whatsapp_created ON whatsapp_messages(created_at DESC);
CREATE INDEX idx_whatsapp_direction ON whatsapp_messages(direction);

-- RLS Policies
ALTER TABLE whatsapp_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view messages"
  ON whatsapp_messages FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "System can insert messages"
  ON whatsapp_messages FOR INSERT
  WITH CHECK (true);

-- ============================================================================
-- SYSTEM METRICS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS system_metrics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  metric_type TEXT NOT NULL CHECK (metric_type IN ('cpu', 'ram', 'disk', 'network')),
  value NUMERIC NOT NULL,
  metadata JSONB DEFAULT '{}'::jsonb,
  recorded_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX idx_metrics_type ON system_metrics(metric_type);
CREATE INDEX idx_metrics_recorded ON system_metrics(recorded_at DESC);

-- RLS Policies
ALTER TABLE system_metrics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view metrics"
  ON system_metrics FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "System can insert metrics"
  ON system_metrics FOR INSERT
  WITH CHECK (true);

-- Auto-cleanup old metrics (keep only last 7 days)
CREATE OR REPLACE FUNCTION cleanup_old_metrics()
RETURNS void AS $$
BEGIN
  DELETE FROM system_metrics
  WHERE recorded_at < NOW() - INTERVAL '7 days';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- ACTIVITY FEED TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS activity_feed (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_type TEXT NOT NULL CHECK (event_type IN ('execution', 'whatsapp', 'squad_activation', 'error', 'deployment', 'system')),
  title TEXT NOT NULL,
  description TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX idx_activity_type ON activity_feed(event_type);
CREATE INDEX idx_activity_created ON activity_feed(created_at DESC);

-- RLS Policies
ALTER TABLE activity_feed ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view activity"
  ON activity_feed FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "System can insert activity"
  ON activity_feed FOR INSERT
  WITH CHECK (true);

-- Auto-cleanup old activity (keep only last 30 days)
CREATE OR REPLACE FUNCTION cleanup_old_activity()
RETURNS void AS $$
BEGIN
  DELETE FROM activity_feed
  WHERE created_at < NOW() - INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SQUADS TABLE (Configuration)
-- ============================================================================
CREATE TABLE IF NOT EXISTS squads (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  specialists JSONB DEFAULT '[]'::jsonb,
  triggers JSONB DEFAULT '[]'::jsonb,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default SQUADs
INSERT INTO squads (id, name, description, specialists, triggers) VALUES
  ('sales', 'Sales SQUAD', 'Especialistas em vendas, funil, conversão',
   '["BDR", "SDS", "Closer", "Sales Manager"]'::jsonb,
   '["vendas", "pipeline", "conversão", "fechamento", "funil"]'::jsonb),

  ('exec', 'Executive SQUAD', 'C-Level estratégico (CRO, CFO, COO)',
   '["CRO", "CFO", "COO"]'::jsonb,
   '["EBITDA", "scaling", "valuation", "estratégia"]'::jsonb),

  ('ops', 'Operations SQUAD', 'Processos, SOPs, eficiência operacional',
   '["Ops Manager", "Process Agent"]'::jsonb,
   '["processo", "SOP", "checklist", "operação"]'::jsonb),

  ('marketing', 'Marketing SQUAD', 'Tráfego, copy, growth',
   '["CMO", "Growth Agent", "Copy Agent"]'::jsonb,
   '["marketing", "tráfego", "copy", "ads", "growth"]'::jsonb),

  ('tech', 'Tech SQUAD', 'Arquitetura, DevOps, automação',
   '["Arch Agent", "DevOps", "Automation Agent"]'::jsonb,
   '["código", "deploy", "automação", "tech", "sistema"]'::jsonb),

  ('research', 'Research SQUAD', 'Análise de dados, pesquisa',
   '["Research Agent", "Analyst Agent"]'::jsonb,
   '["pesquisar", "analisar", "dados", "research"]'::jsonb),

  ('finance', 'Finance SQUAD', 'Finanças, DRE, pricing',
   '["CFO", "Controller Agent", "Pricing Agent"]'::jsonb,
   '["financeiro", "DRE", "margem", "custo", "pricing"]'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- RLS Policies
ALTER TABLE squads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view squads"
  ON squads FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admins can manage squads"
  ON squads FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================================================
-- UPDATED_AT TRIGGER FUNCTION
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to tables with updated_at
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chat_sessions_updated_at
  BEFORE UPDATE ON chat_sessions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_squads_updated_at
  BEFORE UPDATE ON squads
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- REALTIME PUBLICATION (Enable realtime for specific tables)
-- ============================================================================
-- Enable realtime for activity_feed
ALTER PUBLICATION supabase_realtime ADD TABLE activity_feed;

-- Enable realtime for system_metrics
ALTER PUBLICATION supabase_realtime ADD TABLE system_metrics;

-- Enable realtime for whatsapp_messages
ALTER PUBLICATION supabase_realtime ADD TABLE whatsapp_messages;

-- Enable realtime for skill_executions
ALTER PUBLICATION supabase_realtime ADD TABLE skill_executions;

-- ============================================================================
-- FUNCTIONS FOR N8N INTEGRATION
-- ============================================================================

-- Function to insert activity (callable via RPC)
CREATE OR REPLACE FUNCTION insert_activity(
  p_event_type TEXT,
  p_title TEXT,
  p_description TEXT DEFAULT NULL,
  p_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID AS $$
DECLARE
  v_id UUID;
BEGIN
  INSERT INTO activity_feed (event_type, title, description, metadata)
  VALUES (p_event_type, p_title, p_description, p_metadata)
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to insert WhatsApp message (callable via RPC)
CREATE OR REPLACE FUNCTION insert_whatsapp_message(
  p_direction TEXT,
  p_contact_number TEXT,
  p_message TEXT,
  p_contact_name TEXT DEFAULT NULL,
  p_status TEXT DEFAULT NULL,
  p_squad_activated TEXT DEFAULT NULL,
  p_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID AS $$
DECLARE
  v_id UUID;
BEGIN
  INSERT INTO whatsapp_messages (
    direction, contact_number, message, contact_name, status, squad_activated, metadata
  )
  VALUES (
    p_direction, p_contact_number, p_message, p_contact_name, p_status, p_squad_activated, p_metadata
  )
  RETURNING id INTO v_id;

  -- Also insert activity
  PERFORM insert_activity(
    'whatsapp',
    'WhatsApp message ' || p_direction,
    'Message to/from ' || COALESCE(p_contact_name, p_contact_number),
    jsonb_build_object('message_id', v_id, 'contact', p_contact_number)
  );

  RETURN v_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to insert system metric (callable via RPC)
CREATE OR REPLACE FUNCTION insert_system_metric(
  p_metric_type TEXT,
  p_value NUMERIC,
  p_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID AS $$
DECLARE
  v_id UUID;
BEGIN
  INSERT INTO system_metrics (metric_type, value, metadata)
  VALUES (p_metric_type, p_value, p_metadata)
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

-- View: Recent activity (last 100 events)
CREATE OR REPLACE VIEW recent_activity AS
SELECT * FROM activity_feed
ORDER BY created_at DESC
LIMIT 100;

-- View: Latest system metrics (last reading per metric type)
CREATE OR REPLACE VIEW latest_metrics AS
SELECT DISTINCT ON (metric_type)
  metric_type,
  value,
  metadata,
  recorded_at
FROM system_metrics
ORDER BY metric_type, recorded_at DESC;

-- View: WhatsApp messages summary (count by contact)
CREATE OR REPLACE VIEW whatsapp_summary AS
SELECT
  contact_number,
  contact_name,
  COUNT(*) as message_count,
  MAX(created_at) as last_message_at,
  COUNT(*) FILTER (WHERE direction = 'incoming') as incoming_count,
  COUNT(*) FILTER (WHERE direction = 'outgoing') as outgoing_count
FROM whatsapp_messages
GROUP BY contact_number, contact_name
ORDER BY last_message_at DESC;

-- ============================================================================
-- STORAGE BUCKETS (Run in Supabase Dashboard → Storage)
-- ============================================================================

-- Create buckets via SQL (alternative to UI)
-- Note: You may need to create these via Dashboard instead

-- INSERT INTO storage.buckets (id, name, public)
-- VALUES
--   ('avatars', 'avatars', true),
--   ('uploads', 'uploads', false),
--   ('logs', 'logs', false)
-- ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- SCHEDULED CLEANUP (via pg_cron or Edge Functions)
-- ============================================================================

-- Note: Supabase Free tier doesn't include pg_cron
-- Alternative: Create an Edge Function that runs daily to cleanup old data

-- Example Edge Function payload:
-- {
--   "action": "cleanup",
--   "tables": ["system_metrics", "activity_feed"]
-- }

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

-- Verify tables created
SELECT
  schemaname,
  tablename,
  tableowner
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
