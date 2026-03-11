# Smart LLM Agents (SLA) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 建立一個可從 GitHub 一鍵安裝的智能多模型開發閉環 Skills 套件，讓 Claude Code 用戶自動享有 smart-route 路由、GSD 整合、TDD 流程、GitHub Actions 自動化的完整開發體驗。

**Architecture:** SLA 是一組 Claude Code Skills 的集合，核心是 smart-route 路由引擎，串接 Claude / Ollama（本地+雲端）/ Kimi MCP 三大模型後端，並透過 GSD framework 管理開發生命週期，GHA 模板完成 CI/CD 閉環。

**Tech Stack:** Bash (installer), Claude Code Skills (SKILL.md), Ollama, Kimi MCP, GSD v1.22+, GitHub CLI (gh), Playwright MCP, claude-in-chrome MCP

---

## 專案結構目標

```
smart-llm-agents/
├── README.md                    # 雙語說明（EN + ZH-TW）
├── install.sh                   # 一鍵安裝腳本
├── uninstall.sh                 # 一鍵移除腳本
├── docs/
│   ├── plans/                   # 實作計畫
│   └── guides/
│       ├── en/quickstart.md     # 英文快速開始
│       └── zh/quickstart.md     # 中文快速開始
├── skills/
│   ├── smart-route/SKILL.md     # 核心路由引擎（升級版）
│   ├── sla-plan/SKILL.md        # 規劃階段
│   ├── sla-develop/SKILL.md     # TDD 開發循環
│   ├── sla-review/SKILL.md      # Code Review
│   ├── sla-release/SKILL.md     # PR + GitHub 推送
│   └── sla-status/SKILL.md      # GHA 狀態追蹤
├── config/
│   ├── models.json              # 模型角色定義
│   └── detect.sh                # 環境自動偵測腳本
└── .github/
    └── workflows/
        └── sla-ci.yml           # GHA CI/CD 模板（用戶複製用）
```

---

## Task 1: 建立專案基礎結構

**Files:**
- Create: `README.md`
- Create: `install.sh`
- Create: `uninstall.sh`
- Create: `config/models.json`
- Create: `config/detect.sh`

**Step 1: 建立所有目錄**

```bash
mkdir -p skills/smart-route
mkdir -p skills/sla-plan
mkdir -p skills/sla-develop
mkdir -p skills/sla-review
mkdir -p skills/sla-release
mkdir -p skills/sla-status
mkdir -p config
mkdir -p docs/guides/en
mkdir -p docs/guides/zh
mkdir -p .github/workflows
```

**Step 2: 建立 config/models.json（模型角色定義）**

```json
{
  "version": "1.0.0",
  "roles": {
    "PLANNER": {
      "description": "規劃、架構設計、高層次決策",
      "primary": "claude-opus",
      "fallback": ["ollama:deepseek-v3.1:671b-cloud", "claude-sonnet"]
    },
    "CODER": {
      "description": "一般功能實作、修 bug",
      "primary": "claude-sonnet",
      "fallback": ["ollama:qwen3-coder:480b-cloud", "ollama:qwen3:8b"]
    },
    "FAST_CODER": {
      "description": "簡單修改、快速任務、CSS/HTML",
      "primary": "ollama:qwen3-coder:480b-cloud",
      "fallback": ["ollama:qwen3:8b", "claude-haiku"]
    },
    "ANALYZER": {
      "description": "代碼分析、架構理解、大檔案閱讀",
      "primary": "kimi",
      "fallback": ["claude-sonnet", "ollama:deepseek-v3.1:671b-cloud"]
    },
    "REVIEWER": {
      "description": "Code Review、diff 分析",
      "primary": "kimi",
      "fallback": ["claude-sonnet"]
    },
    "BROWSER": {
      "description": "網頁搜尋、UI 驗證",
      "primary": "claude-in-chrome",
      "fallback": ["playwright"]
    }
  }
}
```

**Step 3: 建立 config/detect.sh（環境偵測）**

```bash
#!/bin/bash
# SLA 環境偵測腳本
# 輸出：~/.claude/sla-config.json

set -e
CONFIG_FILE="$HOME/.claude/sla-config.json"

detect_ollama() {
  if command -v ollama &>/dev/null; then
    echo "✅ Ollama 已安裝"
    echo '"ollama": true'
  else
    echo "❌ Ollama 未安裝，開始安裝..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
      brew install ollama 2>/dev/null || {
        echo "brew 失敗，使用官方腳本..."
        curl -fsSL https://ollama.ai/install.sh | sh
      }
    else
      curl -fsSL https://ollama.ai/install.sh | sh
    fi
    echo '"ollama": true'
  fi
}

detect_kimi() {
  if [[ -n "$KIMI_API_KEY" ]]; then
    echo "✅ Kimi API Key 已設定"
    echo '"kimi": true'
  else
    echo ""
    read -p "🔧 輸入 Kimi API Key（選填，直接 Enter 跳過）: " KIMI_KEY
    if [[ -n "$KIMI_KEY" ]]; then
      # 寫入 shell profile
      PROFILE="$HOME/.zshrc"
      [[ -f "$HOME/.bashrc" ]] && PROFILE="$HOME/.bashrc"
      echo "export KIMI_API_KEY=\"$KIMI_KEY\"" >> "$PROFILE"
      echo '"kimi": true'
    else
      echo '"kimi": false'
    fi
  fi
}

detect_gh() {
  if command -v gh &>/dev/null; then
    echo "✅ GitHub CLI 已安裝"
    echo '"gh": true'
  else
    echo "❌ GitHub CLI 未安裝，開始安裝..."
    brew install gh 2>/dev/null || apt-get install gh -y 2>/dev/null
    echo '"gh": true'
  fi
}

detect_gsd() {
  if [[ -d "$HOME/.claude/get-shit-done" ]]; then
    echo "✅ GSD 已安裝"
    echo '"gsd": true'
  else
    echo "❌ GSD 未安裝，開始安裝..."
    curl -fsSL https://raw.githubusercontent.com/ezyang/get-shit-done/main/install.sh | bash
    echo '"gsd": true'
  fi
}

# 輸出 JSON 設定檔
echo "🔍 偵測環境中..."
OLLAMA=$(detect_ollama)
KIMI=$(detect_kimi)
GH=$(detect_gh)
GSD=$(detect_gsd)

cat > "$CONFIG_FILE" <<EOF
{
  "version": "1.0.0",
  "detected_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "capabilities": {
    $OLLAMA,
    $KIMI,
    $GH,
    $GSD,
    "claude_in_chrome": true,
    "playwright": true
  }
}
EOF

echo ""
echo "✅ 設定已儲存至 $CONFIG_FILE"
```

**Step 4: Commit**

```bash
git add config/
git commit -m "feat: add model registry and environment detection config"
```

---

## Task 2: 建立核心 smart-route Skill（升級版）

**Files:**
- Create: `skills/smart-route/SKILL.md`

**Step 1: 將現有 smart-route 升級，加入雲端模型支援**

內容重點：
- 加入 Ollama 雲端模型（`:cloud` 後綴）
- 加入 Playwright / claude-in-chrome 的 BROWSER 角色
- 加入 GSD 連動觸發規則
- 讀取 `~/.claude/sla-config.json` 判斷可用模型

**Step 2: Commit**

```bash
git add skills/smart-route/
git commit -m "feat: upgrade smart-route with cloud models and GSD integration"
```

---

## Task 3: 建立 sla:plan Skill

**Files:**
- Create: `skills/sla-plan/SKILL.md`

**核心邏輯：**
1. 接收用戶任務描述
2. smart-route → Claude Opus 規劃
3. 呼叫 `gsd:plan-phase` 產出 PLAN.md
4. 如需技術研究 → claude-in-chrome 搜尋 + Kimi 讀資料
5. 輸出：PRD + Epic + Stories + PLAN.md

**Step 1: Commit**

```bash
git add skills/sla-plan/
git commit -m "feat: add sla:plan skill with GSD integration"
```

---

## Task 4: 建立 sla:develop Skill（TDD 循環）

**Files:**
- Create: `skills/sla-develop/SKILL.md`

**核心邏輯：**
1. 讀取 PLAN.md 中的當前任務
2. smart-route 分配模型
3. **TDD 循環**：
   - 寫測試（失敗）
   - 寫實作（通過）
   - 重構
   - Playwright 執行 E2E 測試驗證
4. 呼叫 `gsd:execute-phase` 管理執行狀態
5. 原子 commit，每個任務獨立提交

**Step 1: Commit**

```bash
git add skills/sla-develop/
git commit -m "feat: add sla:develop skill with TDD loop and Playwright"
```

---

## Task 5: 建立 sla:review Skill

**Files:**
- Create: `skills/sla-review/SKILL.md`

**核心邏輯：**
1. 讀取 git diff（與 main 比較）
2. smart-route → Kimi MCP 分析 diff
3. 輸出 Code Review 報告（問題 + 建議）
4. 如有問題 → 回到 sla:develop 修正
5. 通過 → 繼續 sla:release

**Step 1: Commit**

```bash
git add skills/sla-review/
git commit -m "feat: add sla:review skill with Kimi-powered code review"
```

---

## Task 6: 建立 sla:release Skill

**Files:**
- Create: `skills/sla-release/SKILL.md`

**核心邏輯：**
1. 確認所有測試通過
2. git push 到遠端
3. `gh pr create`（自動帶 PR 描述）
4. 觸發 GitHub Actions
5. 監聽 GHA 狀態

**Step 1: Commit**

```bash
git add skills/sla-release/
git commit -m "feat: add sla:release skill with auto PR and GHA trigger"
```

---

## Task 7: 建立 sla:status Skill

**Files:**
- Create: `skills/sla-status/SKILL.md`

**核心邏輯：**
1. `gh run list` 查看 GHA 狀態
2. 失敗 → Kimi 讀 log 分析根因
3. 回饋給用戶並建議修正方向
4. 成功 → 更新 GSD 狀態，閉環完成

**Step 1: Commit**

```bash
git add skills/sla-status/
git commit -m "feat: add sla:status skill with GHA log analysis"
```

---

## Task 8: 建立 GitHub Actions 模板

**Files:**
- Create: `.github/workflows/sla-ci.yml`

**核心內容：**
- 觸發：PR opened / push to main
- 步驟：安裝依賴 → 跑測試 → 回報結果

**Step 1: Commit**

```bash
git add .github/
git commit -m "feat: add GHA CI template for SLA users"
```

---

## Task 9: 建立 install.sh（一鍵安裝）

**Files:**
- Create: `install.sh`

**Step 1: 完整安裝腳本邏輯**

```bash
#!/bin/bash
set -e

echo "🚀 Smart LLM Agents (SLA) 安裝程式"
echo "======================================"

SLA_DIR="$HOME/.claude/skills"
REPO_URL="https://github.com/fishtvlvoe/smart-llm-agents"

# 1. 下載/更新 SLA 檔案
if [[ -d "/tmp/sla-install" ]]; then rm -rf /tmp/sla-install; fi
git clone --depth 1 "$REPO_URL" /tmp/sla-install

# 2. 執行環境偵測
bash /tmp/sla-install/config/detect.sh

# 3. 複製 Skills
mkdir -p "$SLA_DIR"
cp -r /tmp/sla-install/skills/* "$SLA_DIR/"

# 4. 完成
echo ""
echo "✅ SLA 安裝完成！"
echo ""
echo "可用指令："
echo "  /smart-route  - 智能路由引擎"
echo "  /sla:plan     - 開發規劃"
echo "  /sla:develop  - TDD 開發循環"
echo "  /sla:review   - Code Review"
echo "  /sla:release  - 推送 + PR"
echo "  /sla:status   - 追蹤 GHA 狀態"
```

**Step 2: Commit**

```bash
git add install.sh uninstall.sh
git commit -m "feat: add one-click install/uninstall scripts"
```

---

## Task 10: 建立雙語 README

**Files:**
- Create: `README.md`
- Create: `docs/guides/en/quickstart.md`
- Create: `docs/guides/zh/quickstart.md`

**README 結構：**
1. 英文簡介 + 徽章（stars, license）
2. 中文簡介
3. 一鍵安裝指令（最顯眼）
4. 完整流程圖
5. 模型分工表
6. 各指令說明
7. 貢獻指南

**Step 1: Commit**

```bash
git add README.md docs/
git commit -m "docs: add bilingual README and quickstart guides"
```

---

## 執行順序建議

```
Task 1（結構）→ Task 2（smart-route）→ Task 3-7（各 Skill）
→ Task 8（GHA）→ Task 9（installer）→ Task 10（README）
```

所有 Task 完成後：
- `git push origin main`
- 在 GitHub 設定 README 中的 install 指令
- 測試一鍵安裝流程
