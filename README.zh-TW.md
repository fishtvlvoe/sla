# Smart LLM Agents (SLA)

<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-black?style=flat-square&logo=anthropic&logoColor=white" alt="Claude Code">
  <img src="https://img.shields.io/badge/Ollama-blue?style=flat-square" alt="Ollama">
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="MIT License">
  <img src="https://img.shields.io/badge/version-1.0.0-orange?style=flat-square" alt="Version">
</p>

<p align="center">
  <a href="README.md">English</a> ·
  <a href="README.zh-TW.md">繁體中文</a>
</p>

> 智能多模型開發閉環套件 — 從規劃到 PR，全自動。

---

## ⚡ 一鍵安裝

```bash
curl -fsSL https://raw.githubusercontent.com/fishtvlvoe/sla/main/install.sh | bash
```

安裝腳本自動偵測環境，設定所有必要工具。

---

## SLA 是什麼？

SLA 是一套 Claude Code Skills 套件，根據任務類型自動選擇最合適的 AI 模型執行。涵蓋完整開發生命週期：規劃 → TDD 開發 → Code Review → PR → CI/CD 監控，形成完整閉環。

**解決的問題：** 不同任務需要不同模型。規劃適合 Claude Opus，代碼分析需要 Kimi 的長上下文，簡單修改不需要強大模型。SLA 自動處理這些路由判斷 — 你只需要描述你要做什麼。

---

## 完整流程

```
你說：「我要做 X 功能」
         ↓
   /sla:plan  ──── Claude Opus 規劃功能
         ↓         claude-in-chrome 搜尋技術文件（如需要）
         ↓         Kimi 讀現有代碼理解架構
         ↓  產出：PLAN.md + Epic + Stories
         ↓
   /sla:develop ── smart-route 依任務分配：
         │          簡單任務   → Ollama qwen3-coder:cloud
         │          複雜邏輯   → deepseek-v3.1:cloud / Claude Sonnet
         │          代碼分析   → Kimi MCP
         │
         │  ┌── TDD 循環 ──────────────────────────────┐
         │  │  寫測試（紅燈）→ 寫實作（綠燈）→ 重構    │
         │  │  → Playwright E2E 驗證                   │
         │  │  → 卡關？→ PUA + YES.md 自動介入         │
         │  └──────────────────────────────────────────┘
         ↓
   /sla:review ─── Kimi MCP 讀 git diff → Code Review 報告
         ↓         有問題回 develop 修正，通過繼續
   /sla:release ── git push → gh pr create → GitHub Actions 觸發
         ↓
   /sla:status ─── 監控 CI 結果
                   ✅ 成功 → 閉環完成 🎉
                   ❌ 失敗 → Kimi 讀 log 分析根因 → 回到 develop
```

---

## 指令說明

**開發閉環**

| 指令 | 說明 |
|------|------|
| `/smart-route "任務"` | 自動路由到最佳模型執行 |
| `/sla:plan "功能需求"` | 規劃功能，串接 GSD |
| `/sla:develop` | TDD 開發循環 |
| `/sla:review` | Kimi 驅動 Code Review |
| `/sla:release` | 推送 PR + 觸發 GitHub Actions |
| `/sla:status` | 監控 CI/CD 狀態 |

**CLAUDE.md 維護**

| 指令 | 說明 |
|------|------|
| `AI.MD` 或 `蒸餾` | 優化 CLAUDE.md 格式，減少 token 消耗 |
| `audit my CLAUDE.md` | 審查內容是否與代碼一致（Anthropic 官方工具） |
| `/revise-claude-md` | 把本次 Session 學到的新東西補進 CLAUDE.md |

**自我優化**

| 指令 | 說明 |
|------|------|
| `/learn` | 踩坑自動記錄（背景靜默執行） |
| `/diary` | Session 結束後寫反思日記 |
| `/reflect` | 每週分析規律，建議更新 CLAUDE.md |

---

## 模型分工

| 角色 | 首選模型 | Fallback | 用途 |
|------|---------|---------|------|
| PLANNER | Claude Opus | deepseek:671b-cloud | 規劃、架構設計 |
| CODER | Claude Sonnet | qwen3-coder:480b-cloud | 一般實作、修 bug |
| FAST_CODER | qwen3-coder:480b-cloud | qwen3:8b（本地） | 簡單修改、CSS |
| ANALYZER | Kimi MCP | Claude Sonnet | 代碼分析、大檔案閱讀 |
| REVIEWER | Kimi MCP | Claude Sonnet | Code Review、diff 分析 |
| BROWSER | claude-in-chrome | Playwright | 網頁搜尋、UI 驗證 |
| DEBUGGER | Claude Sonnet + PUA | deepseek:cloud | 卡關偵錯 |

---

## 系統需求

| 工具 | 必要 | 自動安裝 |
|------|------|---------|
| Claude Code | ✅ 必要 | 否（已假設安裝） |
| Ollama | ✅ 必要 | ✅ 是 |
| GitHub CLI (`gh`) | ✅ 必要 | ✅ 是 |
| GSD Framework | 建議 | 否（手動安裝） |
| Kimi API Key | 選填 | 否（安裝時引導） |
| PUA Skill | 建議 | ✅ 是 |
| YES.md Skill | 建議 | ✅ 是 |

---

## Ollama 雲端模型

SLA 使用 Ollama 雲端模型，**不需要本機 GPU**！

```bash
# SLA 自動使用以下模型
ollama run qwen3-coder:480b-cloud    # 快速代碼生成
ollama run deepseek-v3.1:671b-cloud  # 複雜推理
ollama run glm-4.6:cloud             # 中文推理
```

---

## 防放棄機制

SLA 內建兩個互補的 Skill，確保 AI 做事不走偏：

**[PUA](https://github.com/tanweai/pua)** — 讓 AI 不放棄：
```
失敗 2 次 → L1：溫和失望 → 切換本質不同方案
失敗 3 次 → L2：靈魂拷問 → WebSearch + 讀源碼
失敗 4 次 → L3：3.25 考核 → 7 項系統化檢查清單
失敗 5 次 → L4：畢業警告 → 拼命模式
```

**[YES.md](https://github.com/sstklen/yes.md)** — 讓 AI 做對的事：
- 下結論前必須有證據（不猜測）
- 改檔前先備份
- 修完必須驗證
- 漣漪檢查：確認沒有搞壞其他地方

> PUA 讓你繼續，YES.md 讓你繼續時保持正確。

---

## 自我優化閉環

```
開發過程：/learn 靜默記錄踩坑
Session 結束：/diary 寫反思日記
每週一次：/reflect 分析規律 → 建議更新 CLAUDE.md
          → /revise-claude-md 補充內容
          → AI.MD 優化格式
          → 下次 AI 更準確 🔄
```

---

## 移除

```bash
curl -fsSL https://raw.githubusercontent.com/fishtvlvoe/sla/main/uninstall.sh | bash
```

---

## 貢獻

歡迎 PR！請先閱讀[貢獻指南](docs/CONTRIBUTING.md)。

---

## Credits

- [tanweai/pua](https://github.com/tanweai/pua) — PUA 除錯 Skill
- [sstklen/yes.md](https://github.com/sstklen/yes.md) — 工程紀律 Skill
- [sstklen/ai-md](https://github.com/sstklen/ai-md) — CLAUDE.md 格式優化
- [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) — CLAUDE.md 管理（Anthropic 官方）
- [GSD Framework](https://github.com/ezyang/get-shit-done) — 開發工作流框架
- [Kimi MCP](https://platform.moonshot.cn) — 長上下文分析

## License

MIT
