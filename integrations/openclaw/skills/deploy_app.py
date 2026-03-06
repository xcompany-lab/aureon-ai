#!/usr/bin/env python3
"""Deploy application to staging or production

Usage:
    python3 deploy_app.py <environment> [branch] [--confirmed]

Examples:
    python3 deploy_app.py staging
    python3 deploy_app.py production main --confirmed
"""
import subprocess
import sys
import json
from datetime import datetime

ALLOWED_ENVIRONMENTS = ['staging', 'production']

def run_command(cmd: str, description: str):
    """Run shell command and return result"""
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=300  # 5 minutes
        )
        return {
            'step': description,
            'status': 'success' if result.returncode == 0 else 'failed',
            'output': result.stdout if result.returncode == 0 else result.stderr,
            'exit_code': result.returncode
        }
    except Exception as e:
        return {
            'step': description,
            'status': 'error',
            'error': str(e)
        }

def deploy_app(environment: str, branch: str = 'main', confirmed: bool = False):
    """Deploy application"""

    # Validation
    if environment not in ALLOWED_ENVIRONMENTS:
        return {
            'status': 'error',
            'error': f'Invalid environment. Must be: {", ".join(ALLOWED_ENVIRONMENTS)}'
        }

    # Production requires confirmation
    if environment == 'production' and not confirmed:
        return {
            'status': 'requires_confirmation',
            'warning': '⚠️ PRODUCTION DEPLOYMENT',
            'message': f'About to deploy branch "{branch}" to PRODUCTION',
            'instruction': 'Reply with "/deploy production --confirmed" to proceed.'
        }

    # Deployment steps
    steps = []

    print(json.dumps({
        'status': 'started',
        'environment': environment,
        'branch': branch,
        'timestamp': datetime.now().isoformat()
    }, indent=2))

    # 1. Git pull
    steps.append(run_command(
        f'git pull origin {branch}',
        'Pulling latest code from repository'
    ))

    # 2. Install dependencies
    steps.append(run_command(
        'npm install',
        'Installing dependencies'
    ))

    # 3. Run tests (if test script exists)
    steps.append(run_command(
        'npm test --if-present',
        'Running tests'
    ))

    # 4. Build (if build script exists)
    steps.append(run_command(
        'npm run build --if-present',
        'Building application'
    ))

    # 5. Restart service (example for systemd)
    service_name = f'aureon-ai-{environment}'
    steps.append(run_command(
        f'sudo systemctl restart {service_name}',
        f'Restarting {service_name} service'
    ))

    # 6. Health check (wait 5 seconds then check status)
    steps.append(run_command(
        f'sleep 5 && sudo systemctl is-active {service_name}',
        'Running health check'
    ))

    # Determine overall status
    failed_steps = [s for s in steps if s.get('status') in ['failed', 'error']]
    overall_status = 'failed' if failed_steps else 'success'

    return {
        'status': overall_status,
        'environment': environment,
        'branch': branch,
        'timestamp': datetime.now().isoformat(),
        'steps': steps,
        'summary': f'Deployment {"succeeded" if overall_status == "success" else "failed"} ({len(steps)} steps, {len(failed_steps)} failed)'
    }

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(json.dumps({
            'status': 'error',
            'error': 'Usage: python3 deploy_app.py <environment> [branch] [--confirmed]',
            'example': 'python3 deploy_app.py staging'
        }, indent=2))
        sys.exit(1)

    environment = sys.argv[1]
    branch = 'main'
    confirmed = False

    # Parse arguments
    for arg in sys.argv[2:]:
        if arg == '--confirmed':
            confirmed = True
        elif not arg.startswith('--'):
            branch = arg

    result = deploy_app(environment, branch, confirmed)
    print(json.dumps(result, indent=2))

    # Exit with error code if deployment failed
    sys.exit(0 if result['status'] in ['success', 'requires_confirmation'] else 1)
