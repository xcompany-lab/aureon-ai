#!/usr/bin/env python3
"""
Aureon AI - Execute Command Skill
Executes shell commands with safety checks
"""

import subprocess
import sys
import json
from typing import Dict, Any

# Destructive patterns that require confirmation
DESTRUCTIVE_PATTERNS = [
    'rm -rf',
    'dd',
    '> /dev/',
    'mkfs',
    'format',
    'fdisk',
    ':(){:|:&};:',  # fork bomb
    '> /',
    'chmod 777',
    'chmod -R 777'
]

# Blocked patterns (never execute)
BLOCKED_PATTERNS = [
    'rm -rf /',
    'rm -rf /*',
    'rm -rf /home',
    'rm -rf /etc',
    'rm -rf /var',
    'sudo rm -rf',
    'mkfs.',
    '> /dev/sd',
]


def is_blocked(command: str) -> bool:
    """Check if command contains blocked patterns"""
    for pattern in BLOCKED_PATTERNS:
        if pattern in command:
            return True
    return False


def is_destructive(command: str) -> bool:
    """Check if command is potentially destructive"""
    for pattern in DESTRUCTIVE_PATTERNS:
        if pattern in command:
            return True
    return False


def execute_command(command: str, confirmed: bool = False) -> Dict[str, Any]:
    """
    Execute shell command with safety checks.

    Args:
        command: Shell command to execute
        confirmed: Whether user confirmed destructive operation

    Returns:
        Dict with stdout, stderr, exit_code, and status
    """
    # Blocked check
    if is_blocked(command):
        return {
            'status': 'blocked',
            'error': '🚫 BLOCKED: Command contains dangerous patterns and cannot be executed.',
            'command': command,
            'exit_code': -1
        }

    # Destructive check
    if is_destructive(command) and not confirmed:
        return {
            'status': 'requires_confirmation',
            'warning': '⚠️ DESTRUCTIVE COMMAND DETECTED',
            'message': f'Command `{command}` may cause irreversible changes.',
            'instruction': 'Reply with "/execute confirm" to proceed.',
            'command': command,
            'exit_code': -2
        }

    # Execute
    try:
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
            timeout=300  # 5 minutes timeout
        )

        return {
            'status': 'success' if result.returncode == 0 else 'error',
            'stdout': result.stdout,
            'stderr': result.stderr,
            'exit_code': result.returncode,
            'command': command
        }

    except subprocess.TimeoutExpired:
        return {
            'status': 'timeout',
            'error': f'⏱️ Command timed out after 5 minutes',
            'command': command,
            'exit_code': -3
        }

    except Exception as e:
        return {
            'status': 'exception',
            'error': f'❌ Execution failed: {str(e)}',
            'command': command,
            'exit_code': -4
        }


def main():
    """CLI interface for the skill"""
    if len(sys.argv) < 2:
        print(json.dumps({
            'status': 'error',
            'error': 'Usage: python execute_command.py "<command>" [--confirmed]'
        }))
        sys.exit(1)

    command = sys.argv[1]
    confirmed = '--confirmed' in sys.argv or '--confirm' in sys.argv

    result = execute_command(command, confirmed)
    print(json.dumps(result, indent=2))

    sys.exit(0 if result['status'] == 'success' else 1)


if __name__ == '__main__':
    main()
