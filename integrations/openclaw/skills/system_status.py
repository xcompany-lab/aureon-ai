#!/usr/bin/env python3
"""Get system status (CPU, RAM, Disk, Processes)

Usage:
    python3 system_status.py [--detailed]

Examples:
    python3 system_status.py
    python3 system_status.py --detailed
"""
import subprocess
import sys
import json
import os

def run_cmd(cmd: str):
    """Run command and return output"""
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=5
        )
        return result.stdout.strip()
    except Exception:
        return None

def get_cpu_usage():
    """Get CPU usage percentage"""
    # Using top to get CPU usage
    cmd = "top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1"
    result = run_cmd(cmd)

    if result:
        try:
            return float(result)
        except ValueError:
            pass

    # Fallback: use uptime load average
    cmd = "uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ','"
    result = run_cmd(cmd)

    if result:
        try:
            # Rough approximation: load / cores * 100
            load = float(result)
            cores = os.cpu_count() or 1
            return min((load / cores) * 100, 100)
        except ValueError:
            pass

    return 0.0

def get_ram_usage():
    """Get RAM usage percentage"""
    cmd = "free | grep Mem | awk '{print ($3/$2) * 100.0}'"
    result = run_cmd(cmd)

    if result:
        try:
            return float(result)
        except ValueError:
            pass

    return 0.0

def get_disk_usage():
    """Get disk usage percentage for root partition"""
    cmd = "df -h / | tail -1 | awk '{print $5}' | cut -d'%' -f1"
    result = run_cmd(cmd)

    if result:
        try:
            return float(result)
        except ValueError:
            pass

    return 0.0

def get_process_count():
    """Get number of running processes"""
    cmd = "ps aux | wc -l"
    result = run_cmd(cmd)

    if result:
        try:
            # Subtract 1 for header line
            return max(int(result) - 1, 0)
        except ValueError:
            pass

    return 0

def get_uptime():
    """Get system uptime"""
    cmd = "uptime -p"
    result = run_cmd(cmd)

    if result:
        return result

    # Fallback
    cmd = "uptime | awk '{print $3, $4}' | tr -d ','"
    return run_cmd(cmd) or 'Unknown'

def get_memory_details():
    """Get detailed memory information"""
    cmd = "free -h | grep Mem | awk '{print $2, $3, $4}'"
    result = run_cmd(cmd)

    if result:
        parts = result.split()
        if len(parts) >= 3:
            return {
                'total': parts[0],
                'used': parts[1],
                'available': parts[2]
            }

    return {'total': 'N/A', 'used': 'N/A', 'available': 'N/A'}

def get_disk_details():
    """Get detailed disk information"""
    cmd = "df -h / | tail -1 | awk '{print $2, $3, $4}'"
    result = run_cmd(cmd)

    if result:
        parts = result.split()
        if len(parts) >= 3:
            return {
                'total': parts[0],
                'used': parts[1],
                'available': parts[2]
            }

    return {'total': 'N/A', 'used': 'N/A', 'available': 'N/A'}

def get_load_average():
    """Get system load average (1m, 5m, 15m)"""
    cmd = "uptime | awk -F'load average:' '{print $2}' | awk '{print $1, $2, $3}' | tr -d ','"
    result = run_cmd(cmd)

    if result:
        parts = result.split()
        if len(parts) >= 3:
            return {
                '1min': parts[0],
                '5min': parts[1],
                '15min': parts[2]
            }

    return {'1min': 'N/A', '5min': 'N/A', '15min': 'N/A'}

def get_system_status(detailed=False):
    """Get comprehensive system status"""

    cpu = get_cpu_usage()
    ram = get_ram_usage()
    disk = get_disk_usage()
    processes = get_process_count()

    # Determine health status
    if cpu > 90 or ram > 90 or disk > 90:
        status = 'critical'
        emoji = '🔴'
    elif cpu > 80 or ram > 80 or disk > 80:
        status = 'warning'
        emoji = '🟡'
    else:
        status = 'healthy'
        emoji = '🟢'

    result = {
        'status': status,
        'emoji': emoji,
        'cpu_usage': f"{cpu:.1f}%",
        'ram_usage': f"{ram:.1f}%",
        'disk_usage': f"{disk:.1f}%",
        'processes': processes,
        'uptime': get_uptime()
    }

    # Add detailed info if requested
    if detailed:
        result['memory_details'] = get_memory_details()
        result['disk_details'] = get_disk_details()
        result['load_average'] = get_load_average()
        result['cpu_cores'] = os.cpu_count()

    # Add summary message
    result['message'] = f"""{emoji} System Status: {status.upper()}

💻 CPU: {result['cpu_usage']}
🧠 RAM: {result['ram_usage']}
💾 Disk: {result['disk_usage']}
⚙️  Processes: {processes}
⏰ Uptime: {result['uptime']}"""

    if detailed and 'load_average' in result:
        result['message'] += f"""

📊 Load Average: {result['load_average']['1min']} | {result['load_average']['5min']} | {result['load_average']['15min']}
🧠 Memory: {result['memory_details']['used']} / {result['memory_details']['total']} (Available: {result['memory_details']['available']})
💾 Disk: {result['disk_details']['used']} / {result['disk_details']['total']} (Available: {result['disk_details']['available']})"""

    return result

if __name__ == '__main__':
    detailed = '--detailed' in sys.argv or '-d' in sys.argv

    result = get_system_status(detailed)
    print(json.dumps(result, indent=2))

    # Also print message
    print("\n" + "="*60)
    print(result['message'])
    print("="*60)
