# 🚀 Meta Ads Integration — Setup Guide

Complete setup instructions for Meta Ads SQUAD integration.

---

## 📋 Prerequisites

- Meta Business Manager account
- Meta Ad Account with active campaigns (or permission to create)
- Supabase project (already configured)
- Python 3.8+

---

## ⚡ Quick Start (5 Steps)

### Step 1: Run Supabase Migration

1. Open [Supabase Dashboard](https://supabase.com/dashboard)
2. Navigate to your project → **SQL Editor**
3. Copy contents of `interface/supabase/migrations/002_meta_ads_schema.sql`
4. Paste into SQL Editor
5. Click **Run** (or press Cmd/Ctrl + Enter)
6. Verify tables created:

```sql
SELECT tablename FROM pg_tables
WHERE schemaname = 'public'
  AND tablename LIKE 'meta_ads%'
ORDER BY tablename;
```

**Expected output:**
```
meta_ads_accounts
meta_ads_ads
meta_ads_adsets
meta_ads_alerts
meta_ads_campaigns
meta_ads_metrics_history
meta_ads_optimizations
meta_ads_tasks
```

✅ **Migration complete!**

---

### Step 2: Create Meta App

1. Go to [Facebook Developers](https://developers.facebook.com/apps)
2. Click **Create App**
3. Choose **Business** app type
4. Fill in details:
   - **App Name:** `Aureon Meta Ads Manager`
   - **App Contact Email:** Your email
   - **Business Account:** Select your Business Manager

5. Click **Create App**

6. In app dashboard, go to **Settings → Basic**:
   - Copy **App ID**
   - Copy **App Secret** (click Show)

7. Add **Marketing API** product:
   - Dashboard → **Add Product** → **Marketing API** → **Set Up**

✅ **App created!**

---

### Step 3: Generate Access Token

1. Go to [Meta Graph API Explorer](https://developers.facebook.com/tools/explorer/)

2. Select your app from dropdown (top right)

3. Click **Generate Access Token**

4. Grant permissions:
   - `ads_read`
   - `ads_management`
   - `business_management`

5. Click **Generate Token** → Copy token

6. **Convert to Long-Lived Token** (60 days):

```bash
curl -G "https://graph.facebook.com/v21.0/oauth/access_token" \
  -d "grant_type=fb_exchange_token" \
  -d "client_id=YOUR_APP_ID" \
  -d "client_secret=YOUR_APP_SECRET" \
  -d "fb_exchange_token=SHORT_LIVED_TOKEN"
```

**Response:**
```json
{
  "access_token": "LONG_LIVED_TOKEN_HERE",
  "token_type": "bearer",
  "expires_in": 5183944
}
```

Copy the `access_token` value.

✅ **Token generated!**

---

### Step 4: Get Ad Account ID

1. Go to [Meta Ads Manager](https://business.facebook.com/adsmanager/)

2. Look at URL — it contains your Ad Account ID:
   ```
   https://business.facebook.com/adsmanager/manage/campaigns?act=123456789
                                                             ^^^^^^^^^^^
   ```

3. Your Ad Account ID is: `act_123456789`

✅ **Account ID found!**

---

### Step 5: Configure Environment Variables

1. Open `.env` file in project root

2. Add Meta Ads credentials:

```bash
# ============================================================================
# META ADS API
# ============================================================================
META_APP_ID=1234567890123456                          # From Step 2
META_APP_SECRET=abcdef1234567890abcdef1234567890      # From Step 2
META_ACCESS_TOKEN=LONG_LIVED_TOKEN_FROM_STEP_3        # From Step 3
META_AD_ACCOUNT_ID=act_123456789                      # From Step 4
META_BUSINESS_ID=                                     # Optional (Business Manager ID)

# Optimization Settings (centavos = R$ 60.00)
META_TARGET_CPA=6000                                  # Target CPA in cents
META_TARGET_ROAS=3.0                                  # Target ROAS multiplier
META_MAX_DAILY_BUDGET=50000                           # Max budget per ad set/day (cents)
```

3. Save `.env` file

✅ **Configuration complete!**

---

## 🧪 Test Connection

### Install Python Dependencies

```bash
# Install Facebook Ads SDK
pip3 install --break-system-packages facebookads

# Install Supabase SDK (if not already installed)
pip3 install --break-system-packages supabase
```

### Test Meta API Connection

```bash
cd /home/aureon/projects/mega-brain-lab/mega-brain
python3 integrations/meta-ads/auth.py
```

**Expected output:**
```
============================================================
META ADS API — Connection Test
============================================================

✅ Meta Ads API initialized successfully
✅ Connected to Ad Account: Sua Empresa - Ads
   Currency: BRL
   Timezone: America/Sao_Paulo

✅ Connection test PASSED

Next steps:
1. Test fetching campaigns: python3 integrations/meta-ads/campaigns.py
2. Run first sync to Supabase
```

### Test Supabase Connection

```bash
python3 integrations/meta-ads/supabase_client.py
```

**Expected output:**
```
============================================================
SUPABASE CLIENT — Connection Test
============================================================

✅ Supabase client initialized
Testing database query...
✅ Database connection OK
   Campaigns in database: 0

✅ Connection test PASSED
```

### Sync First Campaigns

```bash
python3 integrations/meta-ads/campaigns.py
```

**Expected output:**
```
============================================================
META ADS CAMPAIGNS SYNC
============================================================

✅ Meta Ads API initialized successfully
✅ Connected to Ad Account: Sua Empresa - Ads
   Currency: BRL
   Timezone: America/Sao_Paulo

✅ Supabase client initialized

Fetching campaigns from Meta Ads API...
✅ Fetched 5 campaigns from Meta API

Syncing 5 campaigns to Supabase...
   ✅ Synced: Lead Gen Q1 2026 (ACTIVE)
   ✅ Synced: Brand Awareness (PAUSED)
   ✅ Synced: Retargeting (ACTIVE)
   ✅ Synced: Cold Audience Test (ACTIVE)
   ✅ Synced: Lookalike Campaign (ACTIVE)

✅ Sync complete: 5/5 campaigns synced

Next steps:
1. View campaigns in Supabase Dashboard
2. Run metrics sync: python3 integrations/meta-ads/insights.py
3. Create skill to query campaigns via voice
```

✅ **All tests passed!**

---

## 📊 Verify in Supabase

1. Open [Supabase Dashboard](https://supabase.com/dashboard)
2. Go to **Table Editor** → `meta_ads_campaigns`
3. You should see your synced campaigns

---

## 🔧 Troubleshooting

### Error: "SDK not installed"

```bash
pip3 install --break-system-packages facebookads supabase
```

### Error: "Missing environment variables"

- Check `.env` file exists in project root
- Verify all `META_*` variables are filled
- No quotes needed around values

### Error: "Invalid Access Token"

- Token may have expired (short-lived tokens expire in 1 hour)
- Generate new long-lived token (Step 3)
- Long-lived tokens last 60 days

### Error: "Ad Account not found"

- Verify Ad Account ID format: `act_123456789`
- Check you have permissions on this account
- Go to Meta Business Manager → Business Settings → Ad Accounts

### Error: "Permission denied"

- Ensure your app has Marketing API product added
- Check access token has `ads_read` and `ads_management` permissions
- Regenerate token with correct permissions (Step 3)

---

## 🔐 Security Best Practices

### Access Token Security

✅ **DO:**
- Store token in `.env` (gitignored)
- Use long-lived tokens (60 days)
- Set reminder to rotate token every 60 days

❌ **DON'T:**
- Commit token to git
- Share token publicly
- Use short-lived tokens in production

### Token Rotation

Create calendar reminder:
- **Date:** 60 days from today
- **Action:** Regenerate Meta Access Token
- **Process:** Repeat Step 3 above

---

## 📚 Additional Resources

- [Meta Marketing API Docs](https://developers.facebook.com/docs/marketing-apis)
- [Graph API Explorer](https://developers.facebook.com/tools/explorer/)
- [Facebook Business SDK (Python)](https://github.com/facebook/facebook-python-business-sdk)
- [Supabase Docs](https://supabase.com/docs)

---

## ✅ Next Steps

After successful setup:

1. **Test voice command:**
   ```
   "Aureon, quais campanhas estão ativas?"
   ```

2. **Create first alert:**
   ```bash
   python3 bin/meta-ads-monitor.py
   ```

3. **Setup cron jobs:**
   - Daily sync (8h): `campaigns.py`
   - Hourly alerts (4h): `monitor.py`

4. **Build dashboard:**
   - Add Meta Ads panel to Interface J.A.R.V.I.S.
   - Display campaigns, alerts, tasks

---

**Setup complete! Ready to manage Meta Ads autonomously.** 🚀

---

**Last updated:** 2026-03-11
**Version:** 1.0.0
