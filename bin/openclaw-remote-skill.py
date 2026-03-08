#!/usr/bin/env python3
"""
Aureon AI - OpenClaw Remote Skill Executor
Execute OpenClaw skills on remote server via SSH or HTTP webhook.

Usage:
    python3 bin/openclaw-remote-skill.py system_status
    python3 bin/openclaw-remote-skill.py read_logs --service openclaw --lines 50
    python3 bin/openclaw-remote-skill.py send_whatsapp --recipient "+5551981503645" --message "Hello"
    python3 bin/openclaw-remote-skill.py --method http system_status
"""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Dict, Any, Optional

# Environment variables
OPENCLAW_REMOTE_HOST = os.getenv("OPENCLAW_REMOTE_HOST", "openclaw-xcompany.local")
OPENCLAW_REMOTE_USER = os.getenv("OPENCLAW_REMOTE_USER", "root")
OPENCLAW_SSH_KEY = os.getenv("OPENCLAW_SSH_KEY", str(Path.home() / ".ssh" / "id_ed25519"))
OPENCLAW_GATEWAY_URL = os.getenv("OPENCLAW_GATEWAY_URL", "http://openclaw-xcompany.local:3000")
N8N_WEBHOOK_URL = os.getenv("N8N_WEBHOOK_URL", "")

# Available skills and their remote script paths
SKILLS = {
    "system_status": "/home/openclaw/aureon-skills/system_status.py",
    "read_logs": "/home/openclaw/aureon-skills/read_logs.py",
    "deploy_app": "/home/openclaw/aureon-skills/deploy_app.py",
    "n8n_trigger": "/home/openclaw/aureon-skills/n8n_trigger.py",
    "squad_activation": "/home/openclaw/aureon-skills/squad_activation.py",
    "send_whatsapp": "/home/openclaw/aureon-skills/send_whatsapp.py",
    "execute_command": "/home/openclaw/aureon-skills/execute_command.py",
}


def execute_via_ssh(skill: str, args: Dict[str, Any], verbose: bool = False) -> dict:
    """
    Execute skill via SSH on remote server.

    Args:
        skill: Skill name (e.g., "system_status")
        args: Skill arguments
        verbose: Print debug information

    Returns:
        dict with 'success', 'output', and 'error' keys
    """
    if skill not in SKILLS:
        return {
            "success": False,
            "output": None,
            "error": f"Unknown skill: {skill}. Available: {', '.join(SKILLS.keys())}"
        }

    script_path = SKILLS[skill]

    # Build command with arguments
    cmd_parts = [f"python3 {script_path}"]

    # Add skill-specific arguments
    if skill == "read_logs":
        cmd_parts.append(args.get("service", "openclaw"))
        cmd_parts.append(str(args.get("lines", 50)))
    elif skill == "deploy_app":
        cmd_parts.append(args.get("environment", "staging"))
        if args.get("confirmed"):
            cmd_parts.append("--confirmed")
    elif skill == "n8n_trigger":
        cmd_parts.append(args.get("workflow", ""))
    elif skill == "squad_activation":
        cmd_parts.append(args.get("squad", "sales"))
    elif skill == "send_whatsapp":
        cmd_parts.append(f"'{args.get('recipient', '')}'")
        cmd_parts.append(f"'{args.get('message', '')}'")
    elif skill == "execute_command":
        cmd_parts.append(f"'{args.get('command', '')}'")
        if args.get("confirmed"):
            cmd_parts.append("--confirmed")
    elif skill == "system_status":
        if args.get("detailed"):
            cmd_parts.append("--detailed")

    remote_cmd = " ".join(cmd_parts)

    if verbose:
        print(f"🔧 Executing skill remotely...")
        print(f"   Skill: {skill}")
        print(f"   SSH: {OPENCLAW_REMOTE_USER}@{OPENCLAW_REMOTE_HOST}")
        print(f"   Command: {remote_cmd}")

    # Build SSH command
    ssh_cmd = [
        "ssh",
        "-i", OPENCLAW_SSH_KEY,
        f"{OPENCLAW_REMOTE_USER}@{OPENCLAW_REMOTE_HOST}",
        remote_cmd
    ]

    try:
        # Execute SSH command
        result = subprocess.run(
            ssh_cmd,
            capture_output=True,
            text=True,
            timeout=60
        )

        if result.returncode == 0:
            # Try to parse JSON output
            try:
                output = json.loads(result.stdout.strip())
            except json.JSONDecodeError:
                output = result.stdout.strip()

            if verbose:
                print("✅ Skill executed successfully!")
                if isinstance(output, dict):
                    print(f"   Result: {json.dumps(output, indent=2)}")
                else:
                    print(f"   Output: {output}")

            return {
                "success": True,
                "output": output,
                "error": None
            }
        else:
            error_msg = result.stderr.strip() or result.stdout.strip()
            if verbose:
                print(f"❌ Skill execution failed")
                print(f"   Error: {error_msg}")

            return {
                "success": False,
                "output": None,
                "error": error_msg
            }

    except subprocess.TimeoutExpired:
        error_msg = "SSH command timed out after 60 seconds"
        if verbose:
            print(f"⏱️  {error_msg}")
        return {
            "success": False,
            "output": None,
            "error": error_msg
        }

    except FileNotFoundError:
        error_msg = f"SSH key not found: {OPENCLAW_SSH_KEY}"
        if verbose:
            print(f"🔑 {error_msg}")
        return {
            "success": False,
            "output": None,
            "error": error_msg
        }

    except Exception as e:
        error_msg = str(e)
        if verbose:
            print(f"💥 Unexpected error: {error_msg}")
        return {
            "success": False,
            "output": None,
            "error": error_msg
        }


def execute_via_http(skill: str, args: Dict[str, Any], verbose: bool = False) -> dict:
    """
    Execute skill via HTTP webhook (N8N).

    Args:
        skill: Skill name
        args: Skill arguments
        verbose: Print debug information

    Returns:
        dict with 'success', 'output', and 'error' keys
    """
    if not N8N_WEBHOOK_URL:
        return {
            "success": False,
            "output": None,
            "error": "N8N_WEBHOOK_URL not configured in .env"
        }

    try:
        import urllib.request
        import urllib.error

        payload = {
            "skill": skill,
            "args": args
        }

        if verbose:
            print(f"🌐 Executing skill via HTTP...")
            print(f"   Skill: {skill}")
            print(f"   URL: {N8N_WEBHOOK_URL}")
            print(f"   Payload: {json.dumps(payload, indent=2)}")

        # Create request
        req = urllib.request.Request(
            N8N_WEBHOOK_URL,
            data=json.dumps(payload).encode('utf-8'),
            headers={'Content-Type': 'application/json'}
        )

        # Execute request
        with urllib.request.urlopen(req, timeout=60) as response:
            result = json.loads(response.read().decode('utf-8'))

            if verbose:
                print("✅ Skill executed successfully!")
                print(f"   Result: {json.dumps(result, indent=2)}")

            return {
                "success": True,
                "output": result,
                "error": None
            }

    except urllib.error.HTTPError as e:
        error_msg = e.read().decode('utf-8')
        if verbose:
            print(f"❌ HTTP error: {e.code}")
            print(f"   Error: {error_msg}")
        return {
            "success": False,
            "output": None,
            "error": f"HTTP {e.code}: {error_msg}"
        }

    except urllib.error.URLError as e:
        error_msg = str(e.reason)
        if verbose:
            print(f"❌ Connection error: {error_msg}")
        return {
            "success": False,
            "output": None,
            "error": error_msg
        }

    except Exception as e:
        error_msg = str(e)
        if verbose:
            print(f"💥 Unexpected error: {error_msg}")
        return {
            "success": False,
            "output": None,
            "error": error_msg
        }


def main():
    parser = argparse.ArgumentParser(
        description="Execute OpenClaw skills on remote server",
        epilog=f"Available skills: {', '.join(SKILLS.keys())}"
    )
    parser.add_argument(
        "skill",
        help="Skill name to execute"
    )
    parser.add_argument(
        "--method",
        choices=["ssh", "http"],
        default="ssh",
        help="Execution method (ssh or http via N8N webhook)"
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Print debug information"
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output result as JSON"
    )

    # Skill-specific arguments
    parser.add_argument("--service", help="Service name (for read_logs)")
    parser.add_argument("--lines", type=int, help="Number of lines (for read_logs)")
    parser.add_argument("--environment", help="Environment (for deploy_app)")
    parser.add_argument("--workflow", help="Workflow name (for n8n_trigger)")
    parser.add_argument("--squad", help="Squad name (for squad_activation)")
    parser.add_argument("--recipient", help="Recipient phone (for send_whatsapp)")
    parser.add_argument("--message", help="Message text (for send_whatsapp)")
    parser.add_argument("--command", help="Command to execute (for execute_command)")
    parser.add_argument("--confirmed", action="store_true", help="Confirm destructive operations")
    parser.add_argument("--detailed", action="store_true", help="Show detailed output")

    args = parser.parse_args()

    # Build args dict
    skill_args = {
        k: v for k, v in vars(args).items()
        if v is not None and k not in ["skill", "method", "verbose", "json"]
    }

    # Execute skill
    if args.method == "ssh":
        result = execute_via_ssh(args.skill, skill_args, args.verbose)
    else:
        result = execute_via_http(args.skill, skill_args, args.verbose)

    # Output result
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        if result["success"]:
            print(f"✅ Skill '{args.skill}' executed successfully")
            if result["output"]:
                if isinstance(result["output"], dict):
                    print(json.dumps(result["output"], indent=2))
                else:
                    print(result["output"])
        else:
            print(f"❌ Failed to execute skill '{args.skill}'", file=sys.stderr)
            print(f"Error: {result['error']}", file=sys.stderr)
            sys.exit(1)


if __name__ == "__main__":
    main()
