#!/usr/bin/env python3
import time
import os
import psutil
import requests
import json
from datetime import datetime

# CONFIGURATION
INTERVAL = 30  # seconds
ENV_PATH = os.path.join(os.path.dirname(__file__), '../../.env')

def load_env():
    """Simple parser for .env file"""
    env_vars = {}
    if not os.path.exists(ENV_PATH):
        print(f"Error: .env file not found at {ENV_PATH}")
        return env_vars
        
    with open(ENV_PATH) as f:
        for line in f:
            if '=' in line and not line.startswith('#'):
                key, value = line.strip().split('=', 1)
                env_vars[key] = value
    return env_vars

env = load_env()
SUPABASE_URL = env.get('SUPABASE_URL')
SUPABASE_KEY = env.get('SUPABASE_ANON_KEY')

if not SUPABASE_URL or not SUPABASE_KEY:
    print("Error: Supabase credentials not found in .env")
    exit(1)

HEADERS = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=minimal"
}

def push_metric(metric_type, value, metadata=None):
    """Push as single metric to Supabase via RPC"""
    url = f"{SUPABASE_URL}/rest/v1/rpc/insert_system_metric"
    payload = {
        "p_metric_type": metric_type,
        "p_value": float(value),
        "p_metadata": metadata or {}
    }
    try:
        response = requests.post(url, headers=HEADERS, json=payload, timeout=10)
        return response.status_code in (200, 201, 204)
    except Exception as e:
        print(f"Error pushing metric {metric_type}: {e}")
        return False

def push_activity(event_type, title, description=None, metadata=None):
    """Push an activity event to Supabase via RPC"""
    url = f"{SUPABASE_URL}/rest/v1/rpc/insert_activity"
    payload = {
        "p_event_type": event_type,
        "p_title": title,
        "p_description": description,
        "p_metadata": metadata or {}
    }
    try:
        response = requests.post(url, headers=HEADERS, json=payload, timeout=10)
        return response.status_code in (200, 201, 204)
    except Exception as e:
        print(f"Error pushing activity: {e}")
        return False

def collect_and_push():
    """Collect system stats and push to Supabase"""
    print(f"[{datetime.now().strftime('%H:%M:%S')}] Collecting metrics...")
    
    # CPU
    cpu_percent = psutil.cpu_percent(interval=1)
    push_metric('cpu', cpu_percent)
    
    # RAM
    ram = psutil.virtual_memory()
    push_metric('ram', ram.percent, {
        "used_gb": round(ram.used / (1024**3), 2),
        "total_gb": round(ram.total / (1024**3), 2)
    })
    
    # Disk
    disk = psutil.disk_usage('/')
    push_metric('disk', disk.percent, {
        "used_gb": round(disk.used / (1024**3), 2),
        "total_gb": round(disk.total / (1024**3), 2)
    })
    
    # Alerts
    if cpu_percent > 90:
        push_activity('error', 'High CPU Usage Detected', f"CPU is at {cpu_percent}%", {"value": cpu_percent})
    elif ram.percent > 90:
        push_activity('error', 'High RAM Usage Detected', f"RAM is at {ram.percent}%", {"value": ram.percent})

def main():
    print(f"🚀 Aureon System Monitor started (Interval: {INTERVAL}s)")
    print(f"Connected to: {SUPABASE_URL}")
    
    # Notify system startup
    push_activity('system', 'System Monitor Started', 'Aureon J.A.R.V.I.S background monitoring is active.')
    
    try:
        while True:
            collect_and_push()
            time.sleep(INTERVAL)
    except KeyboardInterrupt:
        print("\nStopping Monitor...")

if __name__ == "__main__":
    main()
