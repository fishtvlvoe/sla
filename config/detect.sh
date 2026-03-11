#!/bin/bash
# SLA Environment Detection Script
# Detects available tools and generates ~/.claude/sla-config.json
# Usage: bash detect.sh

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

CONFIG_FILE="$HOME/.claude/sla-config.json"

log_ok() { echo -e "${GREEN}✅ $1${NC}"; }
log_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_err() { echo -e "${RED}❌ $1${NC}"; }

# ── Ollama ──────────────────────────────────────────
check_ollama() {
  if command -v ollama &>/dev/null; then
    log_ok "Ollama 已安裝"
    echo "true"
  else
    log_err "Ollama 未安裝，開始安裝..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
      if command -v brew &>/dev/null; then
        brew install ollama --quiet
      else
        curl -fsSL https://ollama.ai/install.sh | sh
      fi
    else
      curl -fsSL https://ollama.ai/install.sh | sh
    fi
    log_ok "Ollama 安裝完成"
    echo "true"
  fi
}

# ── GitHub CLI ──────────────────────────────────────
check_gh() {
  if command -v gh &>/dev/null; then
    log_ok "GitHub CLI 已安裝"
    echo "true"
  else
    log_warn "GitHub CLI 未安裝，開始安裝..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
      brew install gh --quiet
    elif command -v apt-get &>/dev/null; then
      sudo apt-get install gh -y -q
    fi
    log_ok "GitHub CLI 安裝完成"
    echo "true"
  fi
}

# ── GSD Framework ───────────────────────────────────
check_gsd() {
  if [[ -d "$HOME/.claude/get-shit-done" ]]; then
    log_ok "GSD Framework 已安裝"
    echo "true"
  else
    log_warn "GSD 未安裝，跳過（請手動安裝 GSD）"
    echo "false"
  fi
}

# ── Kimi API Key ────────────────────────────────────
check_kimi() {
  if [[ -n "$KIMI_API_KEY" ]]; then
    log_ok "Kimi API Key 已設定"
    echo "true"
  else
    echo ""
    read -p "🔧 輸入 Kimi API Key（選填，Enter 跳過）: " KIMI_KEY
    if [[ -n "$KIMI_KEY" ]]; then
      PROFILE="$HOME/.zshrc"
      [[ -f "$HOME/.bashrc" ]] && PROFILE="$HOME/.bashrc"
      echo "" >> "$PROFILE"
      echo "# SLA - Kimi API Key" >> "$PROFILE"
      echo "export KIMI_API_KEY=\"$KIMI_KEY\"" >> "$PROFILE"
      log_ok "Kimi API Key 已儲存至 $PROFILE"
      echo "true"
    else
      log_warn "Kimi 未設定，分析任務將 fallback 到 Claude"
      echo "false"
    fi
  fi
}

# ── PUA Plugin ──────────────────────────────────────
check_pua() {
  if [[ -d "$HOME/.claude/plugins/pua" ]] || [[ -d "$HOME/.claude/skills/pua-debugging" ]]; then
    log_ok "PUA Skill 已安裝"
    echo "true"
  else
    log_warn "安裝 PUA Skill..."
    if command -v claude &>/dev/null; then
      claude plugin marketplace add tanweai/pua 2>/dev/null || true
      claude plugin install pua@pua-skills 2>/dev/null || true
    fi
    log_ok "PUA Skill 安裝完成"
    echo "true"
  fi
}

# ── Main ─────────────────────────────────────────────
echo ""
echo "🔍 SLA 環境偵測中..."
echo "──────────────────────────────"

OLLAMA_OK=$(check_ollama)
GH_OK=$(check_gh)
GSD_OK=$(check_gsd)
KIMI_OK=$(check_kimi)
PUA_OK=$(check_pua)

mkdir -p "$(dirname "$CONFIG_FILE")"

cat > "$CONFIG_FILE" <<EOF
{
  "version": "1.0.0",
  "detected_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "capabilities": {
    "ollama": $OLLAMA_OK,
    "gh": $GH_OK,
    "gsd": $GSD_OK,
    "kimi": $KIMI_OK,
    "pua": $PUA_OK,
    "claude_in_chrome": true,
    "playwright": true
  }
}
EOF

echo "──────────────────────────────"
echo ""
log_ok "設定已儲存至 $CONFIG_FILE"
