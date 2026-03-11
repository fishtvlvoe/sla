#!/bin/bash
# Smart LLM Agents (SLA) — One-Click Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/smart-llm-agents/main/install.sh | bash

set -e

SLA_VERSION="1.0.0"
REPO="YOUR_USERNAME/smart-llm-agents"
SKILLS_DIR="$HOME/.claude/skills"
TMP_DIR="/tmp/sla-install-$$"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_banner() {
  echo ""
  echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║   Smart LLM Agents (SLA) v${SLA_VERSION}          ║${NC}"
  echo -e "${BLUE}║   智能多模型開發閉環套件                  ║${NC}"
  echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
  echo ""
}

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

print_banner

# ── Step 1: Download ─────────────────────────────────
echo "📦 下載 SLA..."
git clone --depth 1 "https://github.com/$REPO.git" "$TMP_DIR" --quiet

# ── Step 2: Detect Environment ───────────────────────
echo ""
bash "$TMP_DIR/config/detect.sh"

# ── Step 3: Install Skills ───────────────────────────
echo ""
echo "📚 安裝 Skills..."
mkdir -p "$SKILLS_DIR"

for skill_dir in "$TMP_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  cp -r "$skill_dir" "$SKILLS_DIR/$skill_name"
  echo -e "  ${GREEN}✅${NC} $skill_name"
done

# ── Step 4: Done ─────────────────────────────────────
echo ""
echo -e "${GREEN}══════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ SLA 安裝完成！${NC}"
echo ""
echo "可用指令："
echo "  /smart-route  — 智能任務路由"
echo "  /sla:plan     — 開發規劃（串接 GSD）"
echo "  /sla:develop  — TDD 開發循環"
echo "  /sla:review   — Code Review（Kimi 驅動）"
echo "  /sla:release  — 推送 PR + GitHub Actions"
echo "  /sla:status   — 追蹤 CI/CD 狀態"
echo ""
echo "📖 文件：https://github.com/$REPO"
echo -e "${GREEN}══════════════════════════════════════════${NC}"
echo ""
