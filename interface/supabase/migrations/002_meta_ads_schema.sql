-- ============================================================================
-- META ADS MANAGEMENT — Database Schema
-- Migration: 002_meta_ads_schema.sql
-- Purpose: Store campaigns, metrics, alerts, tasks for autonomous Meta Ads management
-- ============================================================================

-- Enable UUID extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- META ADS ACCOUNTS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS meta_ads_accounts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  account_id TEXT UNIQUE NOT NULL,              -- Meta Ad Account ID (e.g., act_123456)
  account_name TEXT NOT NULL,
  business_id TEXT,                              -- Meta Business Manager ID
  currency TEXT DEFAULT 'BRL',
  timezone TEXT DEFAULT 'America/Sao_Paulo',
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'paused')),
  access_token_expires_at TIMESTAMPTZ,          -- Token expiration reminder
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX idx_meta_ads_accounts_status ON meta_ads_accounts(status);

-- RLS Policies
ALTER TABLE meta_ads_accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view accounts"
  ON meta_ads_accounts FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admins can manage accounts"
  ON meta_ads_accounts FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================================================
-- META ADS CAMPAIGNS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS meta_ads_campaigns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  account_id UUID REFERENCES meta_ads_accounts(id) ON DELETE CASCADE NOT NULL,
  campaign_id TEXT UNIQUE NOT NULL,              -- Meta Campaign ID
  campaign_name TEXT NOT NULL,
  objective TEXT NOT NULL,                        -- OUTCOME_LEADS, OUTCOME_SALES, etc.
  status TEXT NOT NULL CHECK (status IN ('ACTIVE', 'PAUSED', 'DELETED', 'ARCHIVED')),
  daily_budget NUMERIC,                           -- Daily budget in cents (R$ 100 = 10000)
  lifetime_budget NUMERIC,                        -- Lifetime budget in cents
  start_time TIMESTAMPTZ,
  stop_time TIMESTAMPTZ,

  -- Performance Metrics (updated periodically)
  impressions BIGINT DEFAULT 0,
  clicks BIGINT DEFAULT 0,
  spend NUMERIC DEFAULT 0,                        -- Total spend in cents
  conversions INTEGER DEFAULT 0,

  -- Calculated Metrics
  ctr NUMERIC,                                    -- Click-through rate (%)
  cpc NUMERIC,                                    -- Cost per click (cents)
  cpa NUMERIC,                                    -- Cost per acquisition (cents)
  roas NUMERIC,                                   -- Return on ad spend (multiplier)

  last_synced_at TIMESTAMPTZ,                     -- Last API sync
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_campaigns_account ON meta_ads_campaigns(account_id);
CREATE INDEX idx_campaigns_status ON meta_ads_campaigns(status);
CREATE INDEX idx_campaigns_synced ON meta_ads_campaigns(last_synced_at DESC);

-- RLS Policies
ALTER TABLE meta_ads_campaigns ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view campaigns"
  ON meta_ads_campaigns FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "System can manage campaigns"
  ON meta_ads_campaigns FOR ALL
  WITH CHECK (true);

-- ============================================================================
-- META ADS AD SETS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS meta_ads_adsets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  campaign_id UUID REFERENCES meta_ads_campaigns(id) ON DELETE CASCADE NOT NULL,
  adset_id TEXT UNIQUE NOT NULL,                 -- Meta Ad Set ID
  adset_name TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('ACTIVE', 'PAUSED', 'DELETED', 'ARCHIVED')),

  -- Budget
  daily_budget NUMERIC,                           -- Daily budget in cents
  lifetime_budget NUMERIC,                        -- Lifetime budget in cents
  bid_amount NUMERIC,                             -- Bid cap in cents

  -- Targeting
  targeting JSONB DEFAULT '{}'::jsonb,            -- Audience targeting config
  age_min INTEGER,
  age_max INTEGER,
  genders JSONB DEFAULT '[]'::jsonb,              -- [1, 2] (1=male, 2=female)
  locations JSONB DEFAULT '[]'::jsonb,            -- Geo targets

  -- Optimization
  optimization_goal TEXT,                         -- LEAD, CONVERSION, etc.
  billing_event TEXT,                             -- IMPRESSIONS, LINK_CLICKS

  -- Performance Metrics
  impressions BIGINT DEFAULT 0,
  clicks BIGINT DEFAULT 0,
  spend NUMERIC DEFAULT 0,
  conversions INTEGER DEFAULT 0,

  -- Calculated Metrics
  ctr NUMERIC,
  cpc NUMERIC,
  cpa NUMERIC,
  roas NUMERIC,

  last_synced_at TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_adsets_campaign ON meta_ads_adsets(campaign_id);
CREATE INDEX idx_adsets_status ON meta_ads_adsets(status);
CREATE INDEX idx_adsets_cpa ON meta_ads_adsets(cpa ASC NULLS LAST);

-- RLS Policies
ALTER TABLE meta_ads_adsets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view ad sets"
  ON meta_ads_adsets FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "System can manage ad sets"
  ON meta_ads_adsets FOR ALL
  WITH CHECK (true);

-- ============================================================================
-- META ADS ADS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS meta_ads_ads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  adset_id UUID REFERENCES meta_ads_adsets(id) ON DELETE CASCADE NOT NULL,
  ad_id TEXT UNIQUE NOT NULL,                    -- Meta Ad ID
  ad_name TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('ACTIVE', 'PAUSED', 'DELETED', 'ARCHIVED')),

  -- Creative
  creative_id TEXT,
  headline TEXT,
  body TEXT,
  call_to_action TEXT,
  image_url TEXT,
  video_url TEXT,

  -- Performance Metrics
  impressions BIGINT DEFAULT 0,
  clicks BIGINT DEFAULT 0,
  spend NUMERIC DEFAULT 0,
  conversions INTEGER DEFAULT 0,

  -- Calculated Metrics
  ctr NUMERIC,
  cpc NUMERIC,
  cpa NUMERIC,
  roas NUMERIC,

  -- A/B Testing
  test_group TEXT,                                -- Control, Variant A, Variant B, etc.
  is_winner BOOLEAN DEFAULT false,

  last_synced_at TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_ads_adset ON meta_ads_ads(adset_id);
CREATE INDEX idx_ads_status ON meta_ads_ads(status);
CREATE INDEX idx_ads_ctr ON meta_ads_ads(ctr DESC NULLS LAST);

-- RLS Policies
ALTER TABLE meta_ads_ads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view ads"
  ON meta_ads_ads FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "System can manage ads"
  ON meta_ads_ads FOR ALL
  WITH CHECK (true);

-- ============================================================================
-- META ADS METRICS HISTORY (Time Series)
-- ============================================================================
CREATE TABLE IF NOT EXISTS meta_ads_metrics_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  entity_type TEXT NOT NULL CHECK (entity_type IN ('campaign', 'adset', 'ad')),
  entity_id UUID NOT NULL,                        -- References campaign/adset/ad ID

  -- Snapshot Date
  date_start DATE NOT NULL,
  date_stop DATE NOT NULL,

  -- Performance Metrics
  impressions BIGINT DEFAULT 0,
  clicks BIGINT DEFAULT 0,
  spend NUMERIC DEFAULT 0,
  conversions INTEGER DEFAULT 0,

  -- Calculated Metrics
  ctr NUMERIC,
  cpc NUMERIC,
  cpa NUMERIC,
  roas NUMERIC,

  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_metrics_entity ON meta_ads_metrics_history(entity_type, entity_id);
CREATE INDEX idx_metrics_date ON meta_ads_metrics_history(date_start DESC);

-- Unique constraint: one record per entity per date range
CREATE UNIQUE INDEX idx_metrics_unique ON meta_ads_metrics_history(entity_type, entity_id, date_start, date_stop);

-- RLS Policies
ALTER TABLE meta_ads_metrics_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view metrics history"
  ON meta_ads_metrics_history FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "System can insert metrics"
  ON meta_ads_metrics_history FOR INSERT
  WITH CHECK (true);

-- ============================================================================
-- META ADS ALERTS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS meta_ads_alerts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  alert_type TEXT NOT NULL CHECK (alert_type IN (
    'high_cpa',           -- CPA above target
    'low_roas',           -- ROAS below target
    'low_ctr',            -- CTR below threshold
    'budget_spent',       -- Budget 80%+ spent early
    'ad_rejected',        -- Ad disapproved
    'performance_drop',   -- Sudden performance drop
    'anomaly'             -- Unusual pattern detected
  )),
  severity TEXT DEFAULT 'medium' CHECK (severity IN ('low', 'medium', 'high', 'critical')),

  -- Related Entity
  entity_type TEXT CHECK (entity_type IN ('campaign', 'adset', 'ad', 'account')),
  entity_id UUID,                                 -- References campaign/adset/ad/account
  entity_name TEXT,                               -- Cached name for display

  -- Alert Details
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  current_value NUMERIC,                          -- Current metric value
  threshold_value NUMERIC,                        -- Threshold that triggered alert

  -- Suggested Actions
  suggested_actions JSONB DEFAULT '[]'::jsonb,    -- Array of action objects

  -- Status
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'acknowledged', 'resolved', 'ignored')),
  acknowledged_at TIMESTAMPTZ,
  resolved_at TIMESTAMPTZ,

  -- Notification
  notified_via JSONB DEFAULT '[]'::jsonb,         -- ["whatsapp", "email", "dashboard"]
  notified_at TIMESTAMPTZ,

  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_alerts_type ON meta_ads_alerts(alert_type);
CREATE INDEX idx_alerts_status ON meta_ads_alerts(status);
CREATE INDEX idx_alerts_severity ON meta_ads_alerts(severity);
CREATE INDEX idx_alerts_entity ON meta_ads_alerts(entity_type, entity_id);
CREATE INDEX idx_alerts_created ON meta_ads_alerts(created_at DESC);

-- RLS Policies
ALTER TABLE meta_ads_alerts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view alerts"
  ON meta_ads_alerts FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "System can manage alerts"
  ON meta_ads_alerts FOR ALL
  WITH CHECK (true);

-- ============================================================================
-- META ADS TASKS TABLE (Action Items from Alerts)
-- ============================================================================
CREATE TABLE IF NOT EXISTS meta_ads_tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  alert_id UUID REFERENCES meta_ads_alerts(id) ON DELETE SET NULL,

  -- Task Details
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  task_type TEXT NOT NULL CHECK (task_type IN (
    'pause_adset',
    'increase_budget',
    'decrease_budget',
    'create_lookalike',
    'test_new_creative',
    'adjust_targeting',
    'change_bid',
    'review_creative',
    'manual_review'
  )),

  -- Related Entity
  entity_type TEXT CHECK (entity_type IN ('campaign', 'adset', 'ad', 'account')),
  entity_id UUID,
  entity_name TEXT,

  -- Task Parameters (for automation)
  action_params JSONB DEFAULT '{}'::jsonb,        -- { "new_budget": 15000, "reason": "..." }

  -- Status
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'failed', 'cancelled')),
  priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),

  -- Execution
  requires_approval BOOLEAN DEFAULT true,
  approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
  approved_at TIMESTAMPTZ,
  executed_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,

  -- Result
  result JSONB DEFAULT '{}'::jsonb,               -- Execution result/output
  error TEXT,

  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_tasks_status ON meta_ads_tasks(status);
CREATE INDEX idx_tasks_priority ON meta_ads_tasks(priority);
CREATE INDEX idx_tasks_alert ON meta_ads_tasks(alert_id);
CREATE INDEX idx_tasks_entity ON meta_ads_tasks(entity_type, entity_id);
CREATE INDEX idx_tasks_created ON meta_ads_tasks(created_at DESC);

-- RLS Policies
ALTER TABLE meta_ads_tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view tasks"
  ON meta_ads_tasks FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "System can insert tasks"
  ON meta_ads_tasks FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Users can update tasks"
  ON meta_ads_tasks FOR UPDATE
  USING (auth.role() = 'authenticated');

-- ============================================================================
-- META ADS OPTIMIZATIONS LOG
-- ============================================================================
CREATE TABLE IF NOT EXISTS meta_ads_optimizations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  optimization_type TEXT NOT NULL CHECK (optimization_type IN (
    'budget_increase',
    'budget_decrease',
    'adset_pause',
    'adset_activate',
    'ad_pause',
    'ad_activate',
    'bid_adjustment',
    'targeting_update'
  )),

  -- Related Entity
  entity_type TEXT NOT NULL CHECK (entity_type IN ('campaign', 'adset', 'ad')),
  entity_id UUID NOT NULL,
  entity_name TEXT NOT NULL,

  -- Change Details
  before_value JSONB,                             -- Previous state
  after_value JSONB,                              -- New state
  reason TEXT NOT NULL,                           -- Why optimization was made

  -- Metrics Before
  cpa_before NUMERIC,
  roas_before NUMERIC,
  ctr_before NUMERIC,

  -- Metrics After (measured 7 days later)
  cpa_after NUMERIC,
  roas_after NUMERIC,
  ctr_after NUMERIC,

  -- Success Evaluation
  was_successful BOOLEAN,                         -- Did it improve performance?
  impact_score NUMERIC,                           -- -100 to +100 (negative = worse)

  executed_by TEXT DEFAULT 'system',              -- 'system' or user_id
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_optimizations_type ON meta_ads_optimizations(optimization_type);
CREATE INDEX idx_optimizations_entity ON meta_ads_optimizations(entity_type, entity_id);
CREATE INDEX idx_optimizations_created ON meta_ads_optimizations(created_at DESC);

-- RLS Policies
ALTER TABLE meta_ads_optimizations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view optimizations"
  ON meta_ads_optimizations FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "System can insert optimizations"
  ON meta_ads_optimizations FOR INSERT
  WITH CHECK (true);

-- ============================================================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================================================

CREATE TRIGGER update_meta_ads_accounts_updated_at
  BEFORE UPDATE ON meta_ads_accounts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_meta_ads_campaigns_updated_at
  BEFORE UPDATE ON meta_ads_campaigns
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_meta_ads_adsets_updated_at
  BEFORE UPDATE ON meta_ads_adsets
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_meta_ads_ads_updated_at
  BEFORE UPDATE ON meta_ads_ads
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_meta_ads_alerts_updated_at
  BEFORE UPDATE ON meta_ads_alerts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_meta_ads_tasks_updated_at
  BEFORE UPDATE ON meta_ads_tasks
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- REALTIME PUBLICATION
-- ============================================================================

-- Enable realtime for alerts (dashboard needs live updates)
ALTER PUBLICATION supabase_realtime ADD TABLE meta_ads_alerts;

-- Enable realtime for tasks
ALTER PUBLICATION supabase_realtime ADD TABLE meta_ads_tasks;

-- Enable realtime for campaigns (for live status updates)
ALTER PUBLICATION supabase_realtime ADD TABLE meta_ads_campaigns;

-- ============================================================================
-- FUNCTIONS FOR API & N8N INTEGRATION
-- ============================================================================

-- Function: Sync campaign metrics from Meta API
CREATE OR REPLACE FUNCTION sync_campaign_metrics(
  p_campaign_id UUID,
  p_impressions BIGINT,
  p_clicks BIGINT,
  p_spend NUMERIC,
  p_conversions INTEGER
)
RETURNS VOID AS $$
BEGIN
  UPDATE meta_ads_campaigns
  SET
    impressions = p_impressions,
    clicks = p_clicks,
    spend = p_spend,
    conversions = p_conversions,
    ctr = CASE WHEN p_impressions > 0 THEN (p_clicks::NUMERIC / p_impressions * 100) ELSE 0 END,
    cpc = CASE WHEN p_clicks > 0 THEN (p_spend / p_clicks) ELSE 0 END,
    cpa = CASE WHEN p_conversions > 0 THEN (p_spend / p_conversions) ELSE 0 END,
    last_synced_at = NOW()
  WHERE id = p_campaign_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function: Create alert and task
CREATE OR REPLACE FUNCTION create_alert_with_task(
  p_alert_type TEXT,
  p_severity TEXT,
  p_entity_type TEXT,
  p_entity_id UUID,
  p_entity_name TEXT,
  p_title TEXT,
  p_description TEXT,
  p_current_value NUMERIC,
  p_threshold_value NUMERIC,
  p_suggested_actions JSONB,
  p_task_type TEXT,
  p_task_title TEXT,
  p_task_description TEXT,
  p_action_params JSONB
)
RETURNS UUID AS $$
DECLARE
  v_alert_id UUID;
  v_task_id UUID;
BEGIN
  -- Create alert
  INSERT INTO meta_ads_alerts (
    alert_type, severity, entity_type, entity_id, entity_name,
    title, description, current_value, threshold_value, suggested_actions
  )
  VALUES (
    p_alert_type, p_severity, p_entity_type, p_entity_id, p_entity_name,
    p_title, p_description, p_current_value, p_threshold_value, p_suggested_actions
  )
  RETURNING id INTO v_alert_id;

  -- Create task
  INSERT INTO meta_ads_tasks (
    alert_id, title, description, task_type,
    entity_type, entity_id, entity_name, action_params,
    priority
  )
  VALUES (
    v_alert_id, p_task_title, p_task_description, p_task_type,
    p_entity_type, p_entity_id, p_entity_name, p_action_params,
    CASE p_severity
      WHEN 'critical' THEN 'urgent'
      WHEN 'high' THEN 'high'
      ELSE 'medium'
    END
  )
  RETURNING id INTO v_task_id;

  -- Log to activity feed
  PERFORM insert_activity(
    'squad_activation',
    'Meta Ads Alert: ' || p_title,
    p_description,
    jsonb_build_object(
      'alert_id', v_alert_id,
      'task_id', v_task_id,
      'entity_type', p_entity_type,
      'entity_name', p_entity_name,
      'severity', p_severity
    )
  );

  RETURN v_alert_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- VIEWS FOR DASHBOARD
-- ============================================================================

-- View: Campaign performance summary
CREATE OR REPLACE VIEW meta_ads_campaign_summary AS
SELECT
  c.id,
  c.campaign_id,
  c.campaign_name,
  c.status,
  c.objective,
  c.daily_budget / 100.0 AS daily_budget_brl,
  c.spend / 100.0 AS spend_brl,
  c.impressions,
  c.clicks,
  c.conversions,
  c.ctr,
  c.cpc / 100.0 AS cpc_brl,
  c.cpa / 100.0 AS cpa_brl,
  c.roas,
  c.last_synced_at,
  COUNT(DISTINCT a.id) FILTER (WHERE a.status = 'ACTIVE') AS active_adsets,
  COUNT(DISTINCT ad.id) FILTER (WHERE ad.status = 'ACTIVE') AS active_ads
FROM meta_ads_campaigns c
LEFT JOIN meta_ads_adsets a ON a.campaign_id = c.id
LEFT JOIN meta_ads_ads ad ON ad.adset_id = a.id
WHERE c.status != 'DELETED'
GROUP BY c.id;

-- View: Open alerts summary
CREATE OR REPLACE VIEW meta_ads_open_alerts AS
SELECT
  alert_type,
  severity,
  COUNT(*) as alert_count,
  MIN(created_at) as oldest_alert_at,
  MAX(created_at) as newest_alert_at
FROM meta_ads_alerts
WHERE status = 'open'
GROUP BY alert_type, severity
ORDER BY
  CASE severity
    WHEN 'critical' THEN 1
    WHEN 'high' THEN 2
    WHEN 'medium' THEN 3
    WHEN 'low' THEN 4
  END,
  alert_count DESC;

-- View: Pending tasks summary
CREATE OR REPLACE VIEW meta_ads_pending_tasks AS
SELECT
  task_type,
  priority,
  COUNT(*) as task_count,
  COUNT(*) FILTER (WHERE requires_approval = true) as awaiting_approval
FROM meta_ads_tasks
WHERE status = 'pending'
GROUP BY task_type, priority
ORDER BY
  CASE priority
    WHEN 'urgent' THEN 1
    WHEN 'high' THEN 2
    WHEN 'medium' THEN 3
    WHEN 'low' THEN 4
  END,
  task_count DESC;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

-- Verify tables created
SELECT
  tablename,
  schemaname
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename LIKE 'meta_ads%'
ORDER BY tablename;
