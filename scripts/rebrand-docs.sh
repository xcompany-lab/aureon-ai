#!/usr/bin/env bash
# Rebrand docs from Mega Brain to Aureon AI
set -euo pipefail

echo "🎨 Aureon AI — Rebrand Docs A1"
echo "=============================="

# Files to rebrand
FILES=(
    "docs/quick-start.md"
    "docs/API-KEYS-GUIDE.md"
    "docs/readme-ralph-cascateamento.md"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "📝 Rebranding: $file"

        # Backup
        cp "$file" "$file.backup"

        # Replace patterns
        sed -i 's/Mega Brain/Aureon AI/g' "$file"
        sed -i 's/mega-brain/aureon-ai/g' "$file"
        sed -i 's/mega brain/Aureon AI/g' "$file"
        sed -i 's/MoneyClub Edition/X-Company Edition/g' "$file"
        sed -i 's/MoneyClub/X-Company/g' "$file"

        echo "   ✅ Done: $file"
    else
        echo "   ⚠️  File not found: $file"
    fi
done

echo ""
echo "✅ Rebrand completo!"
echo ""
echo "📋 Arquivos modificados:"
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "   - $file"
    fi
done
