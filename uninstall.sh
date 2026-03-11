#!/bin/bash
# SLA Uninstaller

SKILLS_DIR="$HOME/.claude/skills"
CONFIG="$HOME/.claude/sla-config.json"

echo "🗑️  移除 SLA Skills..."

for skill in smart-route sla-plan sla-develop sla-review sla-release sla-status; do
  if [[ -d "$SKILLS_DIR/$skill" ]]; then
    rm -rf "$SKILLS_DIR/$skill"
    echo "  ✅ 已移除 $skill"
  fi
done

[[ -f "$CONFIG" ]] && rm "$CONFIG" && echo "  ✅ 已移除 sla-config.json"

echo ""
echo "✅ SLA 已移除完成"
