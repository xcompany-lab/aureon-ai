#!/usr/bin/env python3
"""Trigger N8N workflows via webhooks

Usage:
    python3 n8n_trigger.py <workflow_name> [payload_json]

Examples:
    python3 n8n_trigger.py lead_enrichment '{"name":"John","email":"john@example.com"}'
    python3 n8n_trigger.py data_sync
"""
import sys
import json
import os

# Try to import requests, fallback to urllib if not available
try:
    import requests
    HAS_REQUESTS = True
except ImportError:
    import urllib.request
    import urllib.error
    HAS_REQUESTS = False

# N8N Webhook URLs
# NOTE: Move these to environment variables in production
WEBHOOKS = {
    'lead_enrichment': os.getenv('N8N_WEBHOOK_LEAD_ENRICH', 'https://n8n.example.com/webhook/lead-enrich'),
    'email_sequence': os.getenv('N8N_WEBHOOK_EMAIL_SEQ', 'https://n8n.example.com/webhook/email-seq'),
    'data_sync': os.getenv('N8N_WEBHOOK_DATA_SYNC', 'https://n8n.example.com/webhook/data-sync'),
    'report_generation': os.getenv('N8N_WEBHOOK_REPORT', 'https://n8n.example.com/webhook/report'),
    'notion_sync': os.getenv('N8N_WEBHOOK_NOTION', 'https://n8n.example.com/webhook/notion-sync'),
    'drive_backup': os.getenv('N8N_WEBHOOK_DRIVE', 'https://n8n.example.com/webhook/drive-backup')
}

def trigger_with_requests(url: str, payload: dict):
    """Trigger using requests library"""
    try:
        response = requests.post(url, json=payload, timeout=30)
        response.raise_for_status()

        return {
            'status': 'success',
            'status_code': response.status_code,
            'response': response.json() if response.headers.get('content-type', '').startswith('application/json') else response.text
        }

    except requests.exceptions.Timeout:
        return {
            'status': 'error',
            'error': 'Request timed out after 30 seconds'
        }
    except requests.exceptions.RequestException as e:
        return {
            'status': 'error',
            'error': str(e)
        }

def trigger_with_urllib(url: str, payload: dict):
    """Trigger using urllib (stdlib fallback)"""
    try:
        data = json.dumps(payload).encode('utf-8')
        req = urllib.request.Request(
            url,
            data=data,
            headers={'Content-Type': 'application/json'}
        )

        with urllib.request.urlopen(req, timeout=30) as response:
            response_data = response.read().decode('utf-8')

            try:
                response_json = json.loads(response_data)
            except json.JSONDecodeError:
                response_json = response_data

            return {
                'status': 'success',
                'status_code': response.status,
                'response': response_json
            }

    except urllib.error.HTTPError as e:
        return {
            'status': 'error',
            'error': f'HTTP {e.code}: {e.reason}'
        }
    except urllib.error.URLError as e:
        return {
            'status': 'error',
            'error': f'URL Error: {e.reason}'
        }
    except Exception as e:
        return {
            'status': 'error',
            'error': str(e)
        }

def trigger_n8n(workflow_name: str, payload: dict = None):
    """Trigger N8N workflow"""

    # Get webhook URL
    url = WEBHOOKS.get(workflow_name)
    if not url:
        return {
            'status': 'error',
            'error': f'Workflow "{workflow_name}" not found',
            'available_workflows': list(WEBHOOKS.keys())
        }

    # Check if URL is configured (not example)
    if 'example.com' in url:
        return {
            'status': 'error',
            'error': f'Webhook URL not configured for "{workflow_name}"',
            'instruction': f'Set environment variable N8N_WEBHOOK_{workflow_name.upper().replace("_", "_")} with real webhook URL'
        }

    # Use payload or empty dict
    payload = payload or {}

    # Trigger webhook
    if HAS_REQUESTS:
        result = trigger_with_requests(url, payload)
    else:
        result = trigger_with_urllib(url, payload)

    # Add workflow info to result
    result['workflow'] = workflow_name
    result['url'] = url

    return result

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(json.dumps({
            'status': 'error',
            'error': 'Usage: python3 n8n_trigger.py <workflow_name> [payload_json]',
            'available_workflows': list(WEBHOOKS.keys()),
            'example': 'python3 n8n_trigger.py lead_enrichment \'{"name":"John"}\''
        }, indent=2))
        sys.exit(1)

    workflow_name = sys.argv[1]

    # Parse payload if provided
    payload = {}
    if len(sys.argv) > 2:
        try:
            payload = json.loads(sys.argv[2])
        except json.JSONDecodeError as e:
            print(json.dumps({
                'status': 'error',
                'error': f'Invalid JSON payload: {e}'
            }, indent=2))
            sys.exit(1)

    result = trigger_n8n(workflow_name, payload)
    print(json.dumps(result, indent=2))

    # Exit with error code if failed
    sys.exit(0 if result['status'] == 'success' else 1)
