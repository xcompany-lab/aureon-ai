#!/usr/bin/env python3
"""Read systemd service logs

Usage:
    python3 read_logs.py <service_name> [lines]

Examples:
    python3 read_logs.py openclaw 30
    python3 read_logs.py aureon-ai 50
"""
import subprocess
import sys
import json

def read_logs(service: str, lines: int = 50):
    """Read last N lines of service logs"""

    # Build journalctl command
    cmd = f"journalctl -u {service} -n {lines} --no-pager"

    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=10
        )

        return {
            'status': 'success' if result.returncode == 0 else 'error',
            'service': service,
            'lines_requested': lines,
            'logs': result.stdout if result.returncode == 0 else result.stderr,
            'exit_code': result.returncode
        }

    except subprocess.TimeoutExpired:
        return {
            'status': 'error',
            'service': service,
            'error': 'Command timed out after 10 seconds'
        }
    except Exception as e:
        return {
            'status': 'error',
            'service': service,
            'error': str(e)
        }

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(json.dumps({
            'status': 'error',
            'error': 'Usage: python3 read_logs.py <service_name> [lines]',
            'example': 'python3 read_logs.py openclaw 30'
        }, indent=2))
        sys.exit(1)

    service = sys.argv[1]
    lines = int(sys.argv[2]) if len(sys.argv) > 2 else 50

    result = read_logs(service, lines)
    print(json.dumps(result, indent=2))
