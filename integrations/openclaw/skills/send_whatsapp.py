#!/usr/bin/env python3
"""
OpenClaw Remote Skill - Send WhatsApp Message
Executed on the OpenClaw server to send WhatsApp messages.

Usage:
    python3 send_whatsapp.py "+5551981503645" "Hello from Aureon!"
"""

import json
import os
import sys
import subprocess
from datetime import datetime


def send_whatsapp(recipient: str, message: str) -> dict:
    """
    Send WhatsApp message using OpenClaw gateway.

    Args:
        recipient: Phone number in E.164 format (e.g., +5551981503645)
        message: Message text

    Returns:
        dict with success status and details
    """
    try:
        # Build openclaw command
        cmd = [
            "openclaw",
            "message",
            "send",
            "--target", recipient,
            "--message", message,
            "--json"
        ]

        # Execute command
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=30
        )

        if result.returncode == 0:
            return {
                "success": True,
                "recipient": recipient,
                "message": message,
                "timestamp": datetime.now().isoformat(),
                "output": result.stdout.strip()
            }
        else:
            return {
                "success": False,
                "recipient": recipient,
                "error": result.stderr.strip() or result.stdout.strip(),
                "timestamp": datetime.now().isoformat()
            }

    except subprocess.TimeoutExpired:
        return {
            "success": False,
            "recipient": recipient,
            "error": "OpenClaw command timed out after 30 seconds",
            "timestamp": datetime.now().isoformat()
        }

    except FileNotFoundError:
        return {
            "success": False,
            "recipient": recipient,
            "error": "OpenClaw command not found. Is OpenClaw installed?",
            "timestamp": datetime.now().isoformat()
        }

    except Exception as e:
        return {
            "success": False,
            "recipient": recipient,
            "error": str(e),
            "timestamp": datetime.now().isoformat()
        }


def main():
    if len(sys.argv) < 3:
        print("Usage: python3 send_whatsapp.py RECIPIENT MESSAGE", file=sys.stderr)
        sys.exit(1)

    recipient = sys.argv[1]
    message = sys.argv[2]

    # Validate phone number format
    if not recipient.startswith("+"):
        print(f"Error: Phone number must be in E.164 format (e.g., +5551981503645)", file=sys.stderr)
        sys.exit(1)

    # Send message
    result = send_whatsapp(recipient, message)

    # Output result as JSON
    print(json.dumps(result, indent=2))

    # Exit with appropriate code
    sys.exit(0 if result["success"] else 1)


if __name__ == "__main__":
    main()
