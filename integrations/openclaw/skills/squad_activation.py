#!/usr/bin/env python3
"""Activate SQUAD context and display specialist info

Usage:
    python3 squad_activation.py <squad_name>

Examples:
    python3 squad_activation.py sales
    python3 squad_activation.py tech
"""
import sys
import json

# SQUAD Definitions
SQUADS = {
    'sales': {
        'description': 'Conversão, growth, pipeline',
        'specialists': ['BDR', 'SDS', 'LNS', 'Closer', 'Sales Manager'],
        'commands': ['/pipeline', '/proposta', '/objecoes', '/follow-up'],
        'emoji': '💰',
        'triggers': ['vendas', 'pipeline', 'fechamento', 'conversão', 'proposta', 'follow-up']
    },
    'tech': {
        'description': 'Código, deploy, arquitetura',
        'specialists': ['Arch Agent', 'DevOps Agent', 'Security Agent'],
        'commands': ['/deploy', '/debug', '/ssh', '/logs'],
        'emoji': '💻',
        'triggers': ['código', 'deploy', 'bug', 'servidor', 'ssh', 'erro', 'sistema']
    },
    'ops': {
        'description': 'Processos, SOPs, eficiência',
        'specialists': ['COO', 'Ops Manager', 'Process Agent'],
        'commands': ['/sop', '/workflow', '/checklist', '/processo'],
        'emoji': '📊',
        'triggers': ['processo', 'sop', 'workflow', 'eficiência', 'operação', 'checklist']
    },
    'exec': {
        'description': 'Estratégia, KPIs, decisões C-level',
        'specialists': ['CRO', 'CFO', 'COO'],
        'commands': ['/decisao', '/kpi', '/board', '/estrategia'],
        'emoji': '🎯',
        'triggers': ['estratégia', 'decisão', 'kpi', 'c-level', 'board', 'visão']
    },
    'marketing': {
        'description': 'Ads, funil, branding',
        'specialists': ['CMO', 'Growth Agent', 'Copy Agent'],
        'commands': ['/copy', '/funil', '/ads', '/trafego'],
        'emoji': '📢',
        'triggers': ['marketing', 'ads', 'tráfego', 'copy', 'funil', 'branding', 'campanha']
    },
    'research': {
        'description': 'Pesquisa, análise, mercado',
        'specialists': ['Research Agent', 'Analyst Agent'],
        'commands': ['/analise', '/mercado', '/insights', '/pesquisa'],
        'emoji': '🔬',
        'triggers': ['pesquisa', 'análise', 'mercado', 'dados', 'insights', 'estudo']
    },
    'finance': {
        'description': 'DRE, margem, precificação',
        'specialists': ['CFO', 'Controller Agent', 'Pricing Agent'],
        'commands': ['/dre', '/pricing', '/margem', '/financeiro'],
        'emoji': '💵',
        'triggers': ['financeiro', 'dre', 'margem', 'preço', 'custo', 'receita', 'lucro']
    }
}

def activate_squad(squad_name: str):
    """Activate SQUAD context"""

    # Normalize squad name
    squad_name = squad_name.lower().strip()

    # Get squad data
    squad = SQUADS.get(squad_name)
    if not squad:
        return {
            'status': 'error',
            'error': f'SQUAD "{squad_name}" not found',
            'available_squads': list(SQUADS.keys()),
            'hint': 'Use one of: sales, tech, ops, exec, marketing, research, finance'
        }

    # Build activation message
    message = f"""🏛️ AUREON AI — SQUAD {squad_name.upper()} {squad['emoji']}

📋 Contexto: {squad['description']}

👥 Especialistas disponíveis:
{chr(10).join(f'  • {specialist}' for specialist in squad['specialists'])}

📌 Comandos específicos:
{chr(10).join(f'  {cmd}' for cmd in squad['commands'])}

🔍 Triggers automáticos:
{', '.join(squad['triggers'])}

✅ SQUAD ativado. Como posso ajudar?"""

    return {
        'status': 'activated',
        'squad': squad_name,
        'emoji': squad['emoji'],
        'description': squad['description'],
        'specialists': squad['specialists'],
        'commands': squad['commands'],
        'triggers': squad['triggers'],
        'message': message
    }

def list_squads():
    """List all available SQUADs"""

    squads_list = []
    for name, data in SQUADS.items():
        squads_list.append({
            'name': name,
            'emoji': data['emoji'],
            'description': data['description'],
            'specialists_count': len(data['specialists']),
            'commands_count': len(data['commands'])
        })

    return {
        'status': 'success',
        'total_squads': len(squads_list),
        'squads': squads_list
    }

if __name__ == '__main__':
    if len(sys.argv) < 2:
        # Show available squads if no argument
        result = list_squads()
        print(json.dumps(result, indent=2))
        print("\nUsage: python3 squad_activation.py <squad_name>")
        print("Example: python3 squad_activation.py sales")
        sys.exit(0)

    squad_name = sys.argv[1]

    # Special command to list squads
    if squad_name in ['list', '--list', '-l']:
        result = list_squads()
    else:
        result = activate_squad(squad_name)

    print(json.dumps(result, indent=2))

    # Print message in plain text if activated
    if result.get('status') == 'activated':
        print("\n" + "="*60)
        print(result['message'])
        print("="*60)

    # Exit with error code if failed
    sys.exit(0 if result['status'] in ['success', 'activated'] else 1)
