#!/usr/bin/env python3
"""
Supabase Client for Meta Ads Integration
Handles all database operations for Meta Ads data
"""

import os
import sys
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables
env_path = os.path.join(os.path.dirname(__file__), '../../.env')
load_dotenv(env_path)

# Supabase client (using installed package)
try:
    from supabase import create_client, Client
    SUPABASE_AVAILABLE = True
except ImportError:
    SUPABASE_AVAILABLE = False
    print("⚠️  Supabase SDK not installed.")
    print("    Install with: pip3 install --break-system-packages supabase")


class MetaAdsSupabase:
    """Supabase client for Meta Ads data operations"""

    def __init__(self):
        self.url = os.getenv('SUPABASE_URL')
        self.service_key = os.getenv('SUPABASE_SERVICE_KEY')

        if not self.url or not self.service_key:
            print("❌ Missing Supabase credentials in .env:")
            if not self.url:
                print("   - SUPABASE_URL")
            if not self.service_key:
                print("   - SUPABASE_SERVICE_KEY")
            self.client = None
        else:
            self.client = self._init_client()

    def _init_client(self):
        """Initialize Supabase client"""
        if not SUPABASE_AVAILABLE:
            print("❌ Supabase SDK not available")
            return None

        try:
            client = create_client(self.url, self.service_key)
            print("✅ Supabase client initialized")
            return client
        except Exception as e:
            print(f"❌ Failed to initialize Supabase client: {e}")
            return None

    # ============================================================================
    # CAMPAIGNS
    # ============================================================================

    def upsert_campaign(self, campaign_data):
        """Insert or update campaign in database"""
        if not self.client:
            return None

        try:
            result = self.client.table('meta_ads_campaigns').upsert(
                campaign_data,
                on_conflict='campaign_id'
            ).execute()

            return result.data[0] if result.data else None

        except Exception as e:
            print(f"❌ Error upserting campaign: {e}")
            return None

    def get_campaigns(self, status=None):
        """Fetch campaigns from database"""
        if not self.client:
            return []

        try:
            query = self.client.table('meta_ads_campaigns').select('*')

            if status:
                query = query.eq('status', status)

            result = query.order('created_at', desc=True).execute()
            return result.data

        except Exception as e:
            print(f"❌ Error fetching campaigns: {e}")
            return []

    def get_campaign_by_id(self, campaign_id):
        """Get single campaign by Meta campaign_id"""
        if not self.client:
            return None

        try:
            result = self.client.table('meta_ads_campaigns')\
                .select('*')\
                .eq('campaign_id', campaign_id)\
                .execute()

            return result.data[0] if result.data else None

        except Exception as e:
            print(f"❌ Error fetching campaign: {e}")
            return None

    # ============================================================================
    # AD SETS
    # ============================================================================

    def upsert_adset(self, adset_data):
        """Insert or update ad set in database"""
        if not self.client:
            return None

        try:
            result = self.client.table('meta_ads_adsets').upsert(
                adset_data,
                on_conflict='adset_id'
            ).execute()

            return result.data[0] if result.data else None

        except Exception as e:
            print(f"❌ Error upserting ad set: {e}")
            return None

    def get_adsets(self, campaign_id=None):
        """Fetch ad sets from database"""
        if not self.client:
            return []

        try:
            query = self.client.table('meta_ads_adsets').select('*')

            if campaign_id:
                query = query.eq('campaign_id', campaign_id)

            result = query.order('created_at', desc=True).execute()
            return result.data

        except Exception as e:
            print(f"❌ Error fetching ad sets: {e}")
            return []

    # ============================================================================
    # ADS
    # ============================================================================

    def upsert_ad(self, ad_data):
        """Insert or update ad in database"""
        if not self.client:
            return None

        try:
            result = self.client.table('meta_ads_ads').upsert(
                ad_data,
                on_conflict='ad_id'
            ).execute()

            return result.data[0] if result.data else None

        except Exception as e:
            print(f"❌ Error upserting ad: {e}")
            return None

    # ============================================================================
    # METRICS HISTORY
    # ============================================================================

    def insert_metrics_history(self, entity_type, entity_id, date_start, date_stop, metrics):
        """Insert metrics history record"""
        if not self.client:
            return None

        try:
            data = {
                'entity_type': entity_type,
                'entity_id': entity_id,
                'date_start': date_start,
                'date_stop': date_stop,
                **metrics
            }

            result = self.client.table('meta_ads_metrics_history').insert(data).execute()
            return result.data[0] if result.data else None

        except Exception as e:
            # Ignore duplicate key errors (already exists for this date range)
            if 'duplicate key' not in str(e).lower():
                print(f"❌ Error inserting metrics history: {e}")
            return None

    # ============================================================================
    # ALERTS
    # ============================================================================

    def create_alert(self, alert_data):
        """Create new alert"""
        if not self.client:
            return None

        try:
            result = self.client.table('meta_ads_alerts').insert(alert_data).execute()
            return result.data[0] if result.data else None

        except Exception as e:
            print(f"❌ Error creating alert: {e}")
            return None

    def get_open_alerts(self):
        """Get all open alerts"""
        if not self.client:
            return []

        try:
            result = self.client.table('meta_ads_alerts')\
                .select('*')\
                .eq('status', 'open')\
                .order('created_at', desc=True)\
                .execute()

            return result.data

        except Exception as e:
            print(f"❌ Error fetching alerts: {e}")
            return []

    # ============================================================================
    # TASKS
    # ============================================================================

    def create_task(self, task_data):
        """Create new task"""
        if not self.client:
            return None

        try:
            result = self.client.table('meta_ads_tasks').insert(task_data).execute()
            return result.data[0] if result.data else None

        except Exception as e:
            print(f"❌ Error creating task: {e}")
            return None

    def get_pending_tasks(self):
        """Get all pending tasks"""
        if not self.client:
            return []

        try:
            result = self.client.table('meta_ads_tasks')\
                .select('*')\
                .eq('status', 'pending')\
                .order('priority', desc=True)\
                .order('created_at', desc=False)\
                .execute()

            return result.data

        except Exception as e:
            print(f"❌ Error fetching tasks: {e}")
            return []

    def update_task_status(self, task_id, status, result_data=None, error=None):
        """Update task status"""
        if not self.client:
            return None

        try:
            update_data = {
                'status': status,
                'completed_at': datetime.utcnow().isoformat() if status == 'completed' else None
            }

            if result_data:
                update_data['result'] = result_data

            if error:
                update_data['error'] = error

            result = self.client.table('meta_ads_tasks')\
                .update(update_data)\
                .eq('id', task_id)\
                .execute()

            return result.data[0] if result.data else None

        except Exception as e:
            print(f"❌ Error updating task: {e}")
            return None

    # ============================================================================
    # ACTIVITY FEED
    # ============================================================================

    def log_activity(self, event_type, title, description=None, metadata=None):
        """Log activity to activity_feed table"""
        if not self.client:
            return None

        try:
            data = {
                'event_type': event_type,
                'title': title,
                'description': description,
                'metadata': metadata or {}
            }

            result = self.client.table('activity_feed').insert(data).execute()
            return result.data[0] if result.data else None

        except Exception as e:
            print(f"❌ Error logging activity: {e}")
            return None


def test_connection():
    """Test Supabase connection"""
    print("=" * 60)
    print("SUPABASE CLIENT — Connection Test")
    print("=" * 60)
    print()

    if not SUPABASE_AVAILABLE:
        print("⚠️  Supabase SDK not installed. Install with:")
        print("    pip3 install --break-system-packages supabase")
        return

    db = MetaAdsSupabase()

    if not db.client:
        print("\n❌ Connection test FAILED")
        print("\nCheck your .env file for:")
        print("  - SUPABASE_URL")
        print("  - SUPABASE_SERVICE_KEY")
        return

    # Test fetching campaigns
    print("Testing database query...")
    campaigns = db.get_campaigns()

    print(f"✅ Database connection OK")
    print(f"   Campaigns in database: {len(campaigns)}")

    if campaigns:
        print(f"\n   Latest campaign: {campaigns[0].get('campaign_name')}")

    print("\n✅ Connection test PASSED")


if __name__ == "__main__":
    test_connection()
