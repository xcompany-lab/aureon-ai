#!/usr/bin/env python3
"""
Meta Ads Campaigns Sync
Sync campaigns from Meta Ads API to Supabase database
"""

import os
import sys
from datetime import datetime
from auth import MetaAdsAuth
from supabase_client import MetaAdsSupabase

# Facebook Ads SDK imports
try:
    from facebook_business.adobjects.campaign import Campaign
    SDK_AVAILABLE = True
except ImportError:
    SDK_AVAILABLE = False


def fetch_campaigns_from_meta(account):
    """Fetch all campaigns from Meta Ads API"""
    if not account:
        return []

    try:
        fields = [
            'id',
            'name',
            'objective',
            'status',
            'daily_budget',
            'lifetime_budget',
            'start_time',
            'stop_time',
            'created_time',
            'updated_time'
        ]

        campaigns = account.get_campaigns(fields=fields)

        print(f"✅ Fetched {len(campaigns)} campaigns from Meta API")
        return campaigns

    except Exception as e:
        print(f"❌ Error fetching campaigns: {e}")
        return []


def sync_campaign_to_supabase(campaign, db, account_uuid):
    """Sync single campaign to Supabase"""

    try:
        # Convert budget from cents to integer (Meta API returns strings)
        daily_budget = None
        lifetime_budget = None

        if campaign.get('daily_budget'):
            daily_budget = int(float(campaign.get('daily_budget')))

        if campaign.get('lifetime_budget'):
            lifetime_budget = int(float(campaign.get('lifetime_budget')))

        # Prepare data for Supabase
        campaign_data = {
            'account_id': account_uuid,
            'campaign_id': campaign.get('id'),
            'campaign_name': campaign.get('name'),
            'objective': campaign.get('objective'),
            'status': campaign.get('status'),
            'daily_budget': daily_budget,
            'lifetime_budget': lifetime_budget,
            'start_time': campaign.get('start_time'),
            'stop_time': campaign.get('stop_time'),
            'last_synced_at': datetime.utcnow().isoformat(),
            'metadata': {
                'created_time': campaign.get('created_time'),
                'updated_time': campaign.get('updated_time')
            }
        }

        # Upsert to database
        result = db.upsert_campaign(campaign_data)

        if result:
            print(f"   ✅ Synced: {campaign.get('name')} ({campaign.get('status')})")
            return True
        else:
            print(f"   ❌ Failed to sync: {campaign.get('name')}")
            return False

    except Exception as e:
        print(f"   ❌ Error syncing campaign {campaign.get('name')}: {e}")
        return False


def sync_all_campaigns():
    """Main function to sync all campaigns from Meta to Supabase"""
    print("=" * 60)
    print("META ADS CAMPAIGNS SYNC")
    print("=" * 60)
    print()

    if not SDK_AVAILABLE:
        print("❌ Facebook Ads SDK not installed")
        print("   Install with: pip3 install --break-system-packages facebookads")
        return

    # Initialize Meta API
    auth = MetaAdsAuth()
    account = auth.get_ad_account()

    if not account:
        print("\n❌ Failed to connect to Meta Ads API")
        print("   See docs/meta-ads/SETUP.md for configuration instructions")
        return

    # Initialize Supabase
    db = MetaAdsSupabase()

    if not db.client:
        print("\n❌ Failed to connect to Supabase")
        print("   Check SUPABASE_URL and SUPABASE_SERVICE_KEY in .env")
        return

    # Fetch campaigns from Meta
    print("\nFetching campaigns from Meta Ads API...")
    campaigns = fetch_campaigns_from_meta(account)

    if not campaigns:
        print("\n⚠️  No campaigns found")
        return

    # First, ensure ad account exists in database
    # For now, we'll use a placeholder UUID (you should create account record first)
    # TODO: Implement meta_ads_accounts table population
    account_uuid = "00000000-0000-0000-0000-000000000000"  # Placeholder

    # Sync each campaign to Supabase
    print(f"\nSyncing {len(campaigns)} campaigns to Supabase...")

    success_count = 0
    for campaign in campaigns:
        if sync_campaign_to_supabase(campaign, db, account_uuid):
            success_count += 1

    # Log activity
    db.log_activity(
        event_type='system',
        title='Meta Ads Campaigns Synced',
        description=f'Synced {success_count}/{len(campaigns)} campaigns from Meta Ads API',
        metadata={
            'total_campaigns': len(campaigns),
            'successful': success_count,
            'failed': len(campaigns) - success_count
        }
    )

    print(f"\n✅ Sync complete: {success_count}/{len(campaigns)} campaigns synced")
    print(f"\nNext steps:")
    print(f"1. View campaigns in Supabase Dashboard")
    print(f"2. Run metrics sync: python3 integrations/meta-ads/insights.py")
    print(f"3. Create skill to query campaigns via voice")


if __name__ == "__main__":
    sync_all_campaigns()
