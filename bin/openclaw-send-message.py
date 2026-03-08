#!/usr/bin/env python3
"""
Aureon AI - OpenClaw WhatsApp Bridge
Sends WhatsApp messages via remote OpenClaw server using SSH.

Usage:
    python3 bin/openclaw-send-message.py --to "+5551981503645" --message "Hello!"
    python3 bin/openclaw-send-message.py --to "Kethely" --message "Oi amor!" --verbose
"""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

# Environment variables
OPENCLAW_REMOTE_HOST = os.getenv("OPENCLAW_REMOTE_HOST", "openclaw-xcompany.local")
OPENCLAW_REMOTE_USER = os.getenv("OPENCLAW_REMOTE_USER", "root")
OPENCLAW_SSH_KEY = os.getenv("OPENCLAW_SSH_KEY", str(Path.home() / ".ssh" / "id_ed25519"))

# Contact mapping (name -> phone number)
CONTACTS = {
    "kethely": "+5551981503645",
    "aureon": "+5551981503645",  # fallback
}


def normalize_phone(phone_or_name: str) -> str:
    """Convert name to phone number or validate phone format."""
    # Remove spaces and convert to lowercase
    normalized = phone_or_name.strip().lower()

    # Check if it's a known contact name
    if normalized in CONTACTS:
        return CONTACTS[normalized]

    # Return as-is if it looks like a phone number
    if phone_or_name.startswith("+"):
        return phone_or_name

    # Try to find partial match in contacts
    for name, phone in CONTACTS.items():
        if normalized in name:
            return phone

    return phone_or_name


def send_whatsapp_message(to: str, message: str, verbose: bool = False) -> dict:
    """
    Send WhatsApp message via remote OpenClaw server.

    Args:
        to: Phone number (E.164 format) or contact name
        message: Message text
        verbose: Print debug information

    Returns:
        dict with 'success', 'output', and 'error' keys
    """
    # Normalize recipient
    recipient = normalize_phone(to)

    if verbose:
        print(f"📱 Sending WhatsApp message...")
        print(f"   To: {recipient}")
        print(f"   Message: {message[:50]}{'...' if len(message) > 50 else ''}")
        print(f"   SSH: {OPENCLAW_REMOTE_USER}@{OPENCLAW_REMOTE_HOST}")

    # Build remote command
    # Escape single quotes in message
    escaped_message = message.replace("'", "'\"'\"'")
    remote_cmd = f"python3 /home/openclaw/aureon-skills/send_whatsapp.py '{recipient}' '{escaped_message}'"

    # Build SSH command
    ssh_cmd = [
        "ssh",
        "-i", OPENCLAW_SSH_KEY,
        f"{OPENCLAW_REMOTE_USER}@{OPENCLAW_REMOTE_HOST}",
        remote_cmd
    ]

    if verbose:
        print(f"   Command: {' '.join(ssh_cmd)}")

    try:
        # Execute SSH command
        result = subprocess.run(
            ssh_cmd,
            capture_output=True,
            text=True,
            timeout=30
        )

        if result.returncode == 0:
            if verbose:
                print("✅ Message sent successfully!")
                print(f"   Output: {result.stdout.strip()}")

            return {
                "success": True,
                "output": result.stdout.strip(),
                "error": None
            }
        else:
            error_msg = result.stderr.strip() or result.stdout.strip()
            if verbose:
                print(f"❌ Failed to send message")
                print(f"   Error: {error_msg}")

            return {
                "success": False,
                "output": None,
                "error": error_msg
            }

    except subprocess.TimeoutExpired:
        error_msg = "SSH command timed out after 30 seconds"
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


def main():
    parser = argparse.ArgumentParser(
        description="Send WhatsApp message via remote OpenClaw server"
    )
    parser.add_argument(
        "--to",
        required=True,
        help="Recipient phone number (E.164 format) or contact name"
    )
    parser.add_argument(
        "--message",
        required=True,
        help="Message text to send"
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

    args = parser.parse_args()

    # Send message
    result = send_whatsapp_message(args.to, args.message, args.verbose)

    # Output result
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        if result["success"]:
            print(f"✅ Message sent to {args.to}")
        else:
            print(f"❌ Failed to send message: {result['error']}", file=sys.stderr)
            sys.exit(1)


if __name__ == "__main__":
    main()
