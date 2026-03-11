# Smart LLM Agents (SLA)

<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-black?style=flat-square&logo=anthropic&logoColor=white" alt="Claude Code">
  <img src="https://img.shields.io/badge/Ollama-blue?style=flat-square" alt="Ollama">
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="MIT License">
  <img src="https://img.shields.io/badge/version-1.0.0-orange?style=flat-square" alt="Version">
</p>

> **Intelligent multi-model development loop for Claude Code**
> 智能多模型開發閉環 — 從規劃到 PR，全自動。

---

## ⚡ One-Click Install / 一鍵安裝

```bash
curl -fsSL https://raw.githubusercontent.com/fishtvlvoe/smart-llm-agents/main/install.sh | bash
```

That's it. The installer auto-detects your environment and configures everything.
安裝腳本自動偵測環境，設定所有必要工具。

---

## What is SLA? / 什麼是 SLA？

**English:** SLA is a Claude Code skill pack that routes tasks to the best AI model automatically. It covers the full development lifecycle: planning → TDD development → code review → PR → CI/CD monitoring — all in one closed loop.

**中文：** SLA 是一套 Claude Code Skills 套件，根據任務類型自動選擇最合適的 AI 模型執行。涵蓋完整開發生命週期：規劃 → TDD 開發 → Code Review → PR → CI/CD 監控，形成完整閉環。

---

## Full Workflow / 完整流程

```
User: "I want to build X" / 用戶說「我要做 X」
         ↓
   /sla:plan  ──── Claude Opus 規劃 + claude-in-chrome 搜尋資料
         ↓         Kimi 讀現有代碼理解架構
   GSD PLAN.md + Epic + Stories 產出
         ↓
   /sla:develop ── smart-route 自動分配：
         │          簡單任務 → Ollama qwen3-coder:cloud
         │          複雜邏輯 → deepseek-v3.1:cloud / Claude Sonnet
         │          代碼分析 → Kimi MCP
         │
         │  ┌── TDD 循環 ──────────────────┐
         │  │  寫測試（紅）→ 寫實作（綠）  │
         │  │  → 重構 → Playwright E2E     │
         │  │  → 卡關？→ PUA 觸發突破      │
         │  └──────────────────────────────┘
         ↓
   /sla:review ─── Kimi MCP 讀 diff → Code Review 報告
         ↓         有問題回 develop，通過繼續
   /sla:release ── git push → gh pr create → GHA 觸發
         ↓
   /sla:status ─── 監控 CI 結果
                   成功 → 閉環完成 🎉
                   失敗 → Kimi 讀 log → 分析根因 → 回 develop
```

---

## Commands / 指令說明

**開發閉環 / Development Loop**

| Command | Description | 說明 |
|---------|-------------|------|
| `/smart-route "task"` | Auto-route to best model | 自動路由到最佳模型 |
| `/sla:plan "feature"` | Plan with GSD integration | 規劃功能，串接 GSD |
| `/sla:develop` | TDD development loop | TDD 開發循環 |
| `/sla:review` | Kimi-powered code review | Kimi 驅動 Code Review |
| `/sla:release` | Push PR + trigger CI | 推送 PR + 觸發 CI |
| `/sla:status` | Monitor GitHub Actions | 監控 GitHub Actions |

**CLAUDE.md 維護 / CLAUDE.md Maintenance**

| Command | Description | 說明 |
|---------|-------------|------|
| `AI.MD` / `蒸餾` | Optimize CLAUDE.md format | 優化格式，減少 token 消耗 |
| `audit my CLAUDE.md` | Audit content accuracy | 審查內容是否與代碼一致（官方） |
| `/revise-claude-md` | Capture session learnings | 補充本次 Session 學到的新東西 |

**自我優化 / Self-Improvement**

| Command | Description | 說明 |
|---------|-------------|------|
| `/learn` | Auto-record pitfalls | 踩坑自動記錄（背景靜默執行） |
| `/diary` | Write session diary | Session 結束後寫反思日記 |
| `/reflect` | Weekly pattern analysis | 每週分析規律，建議更新 CLAUDE.md |

---

## Model Routing / 模型分工

| Role / 角色 | Primary / 首選 | Fallback | Use Case / 用途 |
|------------|---------------|---------|----------------|
| PLANNER | Claude Opus | deepseek:671b-cloud | Planning, architecture |
| CODER | Claude Sonnet | qwen3-coder:480b-cloud | Implementation |
| FAST_CODER | qwen3-coder:480b-cloud | qwen3:8b (local) | Quick changes, CSS |
| ANALYZER | Kimi MCP | Claude Sonnet | Code analysis, large files |
| REVIEWER | Kimi MCP | Claude Sonnet | Code review, diff analysis |
| BROWSER | claude-in-chrome | Playwright | Web search, UI validation |
| DEBUGGER | Claude Sonnet + PUA | deepseek:cloud | Stuck debugging |

---

## Requirements / 系統需求

| Tool | Required | Auto-installed |
|------|----------|---------------|
| Claude Code | ✅ Yes | No (assumed) |
| Ollama | ✅ Yes | ✅ Yes |
| GitHub CLI (`gh`) | ✅ Yes | ✅ Yes |
| GSD Framework | Recommended | No (manual) |
| Kimi API Key | Optional | No (guided) |
| PUA Skill | Recommended | ✅ Yes |

---

## Ollama Cloud Models / Ollama 雲端模型

SLA uses Ollama's cloud models — no local GPU required!
SLA 使用 Ollama 雲端模型，不需要本機 GPU！

```bash
# Used by SLA automatically / SLA 自動使用
ollama run qwen3-coder:480b-cloud    # Fast coding
ollama run deepseek-v3.1:671b-cloud  # Complex reasoning
ollama run glm-4.6:cloud             # Chinese reasoning
```

---

## PUA Integration / PUA 整合

SLA integrates [tanweai/pua](https://github.com/tanweai/pua) to prevent AI from giving up.
SLA 整合 PUA Skill，確保 AI 不輕易放棄：

```
Failure × 2 → L1: "你這個 bug 都解決不了？" → Switch approach
Failure × 3 → L2: "底層邏輯是什麼？" → WebSearch + read source
Failure × 4 → L3: "3.25 考核" → 7-item systematic checklist
Failure × 5 → L4: "畢業警告" → All-in mode
```

---

## Uninstall / 移除

```bash
curl -fsSL https://raw.githubusercontent.com/fishtvlvoe/smart-llm-agents/main/uninstall.sh | bash
```

---

## Contributing / 貢獻

PRs welcome! Please read our [contributing guide](docs/CONTRIBUTING.md).
歡迎 PR！請先閱讀[貢獻指南](docs/CONTRIBUTING.md)。

---

## Credits

- [tanweai/pua](https://github.com/tanweai/pua) — PUA debugging skill
- [sstklen/yes.md](https://github.com/sstklen/yes.md) — Engineering discipline skill (YES.md)
- [sstklen/ai-md](https://github.com/sstklen/ai-md) — CLAUDE.md AI-native optimizer
- [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) — CLAUDE.md management (official)
- [GSD Framework](https://github.com/ezyang/get-shit-done) — Development workflow
- [Kimi MCP](https://platform.moonshot.cn) — Long-context analysis

## License

MIT
