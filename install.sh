#!/bin/bash
# Smart LLM Agents (SLA) — One-Click Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/fishtvlvoe/sla/main/install.sh | bash

set -e

SLA_VERSION="1.0.0"
REPO="fishtvlvoe/sla"
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

# ── Step 4: Install Third-Party Skills ───────────────
echo ""
echo "🧠 安裝第三方 Skills..."

# AI.MD
mkdir -p "$SKILLS_DIR/ai-md"
curl -fsSL https://raw.githubusercontent.com/sstklen/ai-md/main/SKILL.md \
  -o "$SKILLS_DIR/ai-md/SKILL.md" --silent
echo -e "  ${GREEN}✅${NC} ai-md（CLAUDE.md 格式優化）"

# YES.md
mkdir -p "$SKILLS_DIR/yes-zh"
curl -fsSL https://raw.githubusercontent.com/sstklen/yes.md/main/skills/yes-zh/SKILL.md \
  -o "$SKILLS_DIR/yes-zh/SKILL.md" --silent
echo -e "  ${GREEN}✅${NC} yes-zh（工程紀律：證據規則 + 安全閘門）"

# PUA
mkdir -p "$SKILLS_DIR/pua-debugging"
curl -fsSL https://raw.githubusercontent.com/tanweai/pua/main/skills/pua-debugging/SKILL.md \
  -o "$SKILLS_DIR/pua-debugging/SKILL.md" --silent 2>/dev/null || \
  (command -v claude &>/dev/null && claude plugin marketplace add tanweai/pua 2>/dev/null && claude plugin install pua@pua-skills 2>/dev/null) || true
echo -e "  ${GREEN}✅${NC} pua-debugging（讓 AI 不放棄）"

# claude-md-improver（Anthropic 官方）
mkdir -p "$SKILLS_DIR/claude-md-improver"
curl -fsSL https://raw.githubusercontent.com/anthropics/claude-plugins-official/main/plugins/claude-md-management/skills/claude-md-improver/SKILL.md \
  -o "$SKILLS_DIR/claude-md-improver/SKILL.md" --silent
echo -e "  ${GREEN}✅${NC} claude-md-improver（CLAUDE.md 內容審查，Anthropic 官方）"

# ── Step 5: Install Commands ──────────────────────────
echo ""
echo "📋 安裝自我優化指令..."
COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$COMMANDS_DIR"

# /learn
cat > "$COMMANDS_DIR/learn.md" << 'LEARN_EOF'
# /learn -- Auto-Learn from Mistakes

Automatically detect and save pitfall experiences during work sessions.

## When to Trigger (Claude decides on its own)

1. **Pitfall resolved** -- Tried the wrong approach, eventually found the fix
2. **Non-obvious workaround** -- Browser quirks, library limitations, platform-specific behavior
3. **Path/environment traps** -- Windows path issues, `~` resolution errors, cross-platform differences
4. **Deployment gotchas** -- Hosting platform quirks, cache issues, DNS delays
5. **3+ attempts to solve** -- If it took 3+ tries, it's worth recording

## What NOT to Learn

- Settings already documented in CLAUDE.md or project docs
- Common CSS/HTML patterns (easily searchable)
- One-off fixes that won't happen again

## Save Format

Save to `~/.claude/skills/learned/{pattern-name}.md`:

```markdown
# {Descriptive Title}

**Date:** {today}
**Project:** {which project}

## Problem
{What happened, what context}

## Solution
{How it was fixed}

## Next Time
{What situation should remind you of this}
```

## Behavior

- After saving, briefly tell the user: "Learned: {title}"
- Don't write a long explanation of why it was saved
- Learn quietly, don't interrupt the workflow
LEARN_EOF
echo -e "  ${GREEN}✅${NC} /learn（踩坑自動記錄）"

# /diary
cat > "$COMMANDS_DIR/diary.md" << 'DIARY_EOF'
# /diary -- Session Reflection Diary

Generate a reflection diary entry from the current conversation.

## Steps

1. **Review this conversation**: List the user's main requests, problems solved, and files modified
2. **Write a diary entry**: Save to `~/.claude/sessions/diary/` with date-based filename
3. **Format**:

```markdown
# Diary {YYYY-MM-DD}

## What I did today
- {List main work items}

## What I learned
- {Pitfalls, discoveries, user preferences}

## Patterns I noticed
- {User's work patterns, recurring needs}

## Notes for next time
- {Reminders for future sessions}
```

4. **Report**: Briefly say "Diary written, noted X key points"

## Notes
- Keep it concise and actionable, not a verbose log
- Focus on "what I learned" and "patterns", not play-by-play
- Each entry should be under 30 lines
DIARY_EOF
echo -e "  ${GREEN}✅${NC} /diary（Session 反思日記）"

# /reflect
cat > "$COMMANDS_DIR/reflect.md" << 'REFLECT_EOF'
# /reflect -- Reflection Analysis

Analyze recent diary entries and session records to find patterns and suggest improvements.

## Steps

1. **Read recent diaries**: Scan `~/.claude/sessions/diary/` (last 7 days)
2. **Read session summaries**: Scan `~/.claude/sessions/` for recent records
3. **Read pitfall records**: Scan `~/.claude/skills/learned/auto-pitfall-*.md`
4. **Analyze patterns**:
   - What type of work does the user do most?
   - Which pitfalls keep recurring? Should they be added to CLAUDE.md?
   - Any new preferences or rules to record?
   - Any outdated MEMORY.md entries to clean up?
5. **Suggest changes**: List specific update suggestions for user confirmation

## Output Format

```
Reflection Report ({date range})

Work stats:
- X sessions total, most active project: {name}
- Most used tools: {list}

Patterns found:
1. {pattern} -> Suggestion: {action}
2. ...

Pitfall stats:
- Recurring: {description} -> Suggest adding to CLAUDE.md
- Resolved: {description} -> Can be archived from learned/

Suggested updates:
- [ ] Add to CLAUDE.md: {new rule}
- [ ] Update MEMORY.md: {which entry}
- [ ] Remove outdated: {which files}
```

## Notes
- Only suggest changes, never auto-modify CLAUDE.md (user must confirm)
- Keep the report clear and actionable
REFLECT_EOF
echo -e "  ${GREEN}✅${NC} /reflect（每週規律分析 + 建議更新 CLAUDE.md）"

mkdir -p "$HOME/.claude/sessions/diary"
mkdir -p "$HOME/.claude/skills/learned"

# ── Step 6: CLAUDE.md Optimization Prompt ────────────
echo ""
read -p "🔧 要現在用 AI.MD 優化你的 CLAUDE.md 嗎？（建議！可減少 token 消耗）[y/N]: " OPT_AIMD
if [[ "$OPT_AIMD" =~ ^[Yy]$ ]]; then
  echo "✅ 請在 Claude Code 中輸入「AI.MD」或「蒸餾」即可開始優化。"
fi

# ── Step 7: Done ──────────────────────────────────────
echo ""
echo -e "${GREEN}══════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ SLA 安裝完成！${NC}"
echo ""
echo "開發閉環指令："
echo "  /sla:plan     — 開發規劃（串接 GSD）"
echo "  /sla:develop  — TDD 開發循環"
echo "  /sla:review   — Code Review（Kimi 驅動）"
echo "  /sla:release  — 推送 PR + GitHub Actions"
echo "  /sla:status   — 追蹤 CI/CD 狀態"
echo ""
echo "智能路由："
echo "  /smart-route  — 自動選最佳模型執行任務"
echo ""
echo "CLAUDE.md 維護："
echo "  AI.MD / 蒸餾            — 優化格式"
echo "  audit my CLAUDE.md      — 審查內容（Anthropic 官方）"
echo "  /revise-claude-md       — 補充 Session 學習"
echo ""
echo "自我優化："
echo "  /learn    — 踩坑自動記錄"
echo "  /diary    — Session 反思日記"
echo "  /reflect  — 每週規律分析 + 建議更新"
echo ""
echo "📖 文件：https://github.com/$REPO"
echo -e "${GREEN}══════════════════════════════════════════${NC}"
echo ""
