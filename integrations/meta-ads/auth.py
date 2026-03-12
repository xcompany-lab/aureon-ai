#!/usr/bin/env python3
"""
Meta Ads API Authentication
Handles authentication and API client initialization for Meta Marketing API
"""

import os
import sys
from dotenv import load_dotenv

# Load environment variables
env_path = os.path.join(os.path.dirname(__file__), '../../.env')
load_dotenv(env_path)

# Facebook Ads SDK imports (will be installed later)
try:
    from facebook_business.api import FacebookAdsApi
    from facebook_business.adobjects.adaccount import AdAccount
    SDK_AVAILABLE = True
except ImportError:
    SDK_AVAILABLE = False
    print("⚠️  Facebook Ads SDK not installed yet.")
    print("    Install with: pip3 install --break-system-packages facebookads")


class MetaAdsAuth:
    """Meta Ads API Authentication Manager"""

    def __init__(self):
        self.app_id = os.getenv('META_APP_ID')
        self.app_secret = os.getenv('META_APP_SECRET')
        self.access_token = os.getenv('META_ACCESS_TOKEN')
        self.ad_account_id = os.getenv('META_AD_ACCOUNT_ID')

        # Validate credentials
        self.validate_credentials()

    def validate_credentials(self):
        """Validate that all required credentials are present"""
        missing = []

        if not self.app_id:
            missing.append('META_APP_ID')
        if not self.app_secret:
            missing.append('META_APP_SECRET')
        if not self.access_token:
            missing.append('META_ACCESS_TOKEN')
        if not self.ad_account_id:
            missing.append('META_AD_ACCOUNT_ID')

        if missing:
            print("❌ Missing required environment variables:")
            for var in missing:
                print(f"   - {var}")
            print("\n📝 Please add these to your .env file")
            print("   See docs/meta-ads/SETUP.md for instructions")
            return False

        return True

    def init_api(self):
        """Initialize Facebook Ads API client"""
        if not SDK_AVAILABLE:
            print("❌ Facebook Ads SDK not installed")
            print("   Install with: pip3 install --break-system-packages facebookads")
            return None

        if not self.validate_credentials():
            return None

        try:
            # Initialize API
            FacebookAdsApi.init(
                self.app_id,
                self.app_secret,
                self.access_token
            )

            print("✅ Meta Ads API initialized successfully")
            return FacebookAdsApi.get_default_api()

        except Exception as e:
            print(f"❌ Failed to initialize Meta Ads API: {e}")
            return None

    def get_ad_account(self):
        """Get Ad Account object"""
        if not SDK_AVAILABLE:
            return None

        api = self.init_api()
        if not api:
            return None

        try:
            account = AdAccount(self.ad_account_id)

            # Test connection by fetching account name
            account_data = account.api_get(fields=['name', 'currency', 'timezone_name'])

            print(f"✅ Connected to Ad Account: {account_data.get('name')}")
            print(f"   Currency: {account_data.get('currency')}")
            print(f"   Timezone: {account_data.get('timezone_name')}")

            return account

        except Exception as e:
            print(f"❌ Failed to access Ad Account: {e}")
            return None


def test_connection():
    """Test Meta Ads API connection"""
    print("=" * 60)
    print("META ADS API — Connection Test")
    print("=" * 60)
    print()

    auth = MetaAdsAuth()

    if not SDK_AVAILABLE:
        print("\n⚠️  SDK not installed. Install with:")
        print("    pip3 install --break-system-packages facebookads")
        print("\nOr add to requirements.txt and install via venv")
        return

    account = auth.get_ad_account()

    if account:
        print("\n✅ Connection test PASSED")
        print("\nNext steps:")
        print("1. Test fetching campaigns: python3 integrations/meta-ads/campaigns.py")
        print("2. Run first sync to Supabase")
    else:
        print("\n❌ Connection test FAILED")
        print("\nTroubleshooting:")
        print("1. Check your .env file has all META_* variables")
        print("2. Verify your Access Token is valid (not expired)")
        print("3. Confirm Ad Account ID format: act_123456789")
        print("4. See docs/meta-ads/SETUP.md for detailed instructions")


if __name__ == "__main__":
    test_connection()
