---
status: ready
name: smart-route
description: SLA 智能任務路由引擎。自動分析任務內容，判斷最適合的執行者（Claude Opus/Sonnet/Haiku、Kimi MCP、Ollama 本地/雲端模型），並路由執行。支援多模型自動分工、fallback 機制、GSD 連動、PUA 卡關觸發。
---

# Smart Route — SLA 核心路由引擎

智能任務路由器：分析任務 → 分配最佳模型 → 執行 → fallback 保底。

## 模型角色對照

| 角色 | 首選模型 | Fallback | 適用場景 |
|------|---------|---------|---------|
| PLANNER | Claude Opus | deepseek-v3.1:671b-cloud | 規劃、架構、PRD |
| CODER | Claude Sonnet | qwen3-coder:480b-cloud | 一般實作、修 bug |
| FAST_CODER | qwen3-coder:480b-cloud | qwen3:8b | 簡單修改、CSS/HTML |
| ANALYZER | Kimi MCP | Claude Sonnet | 代碼分析、讀大檔 |
| REVIEWER | Kimi MCP | Claude Sonnet | Code Review、diff 分析 |
| BROWSER | claude-in-chrome | playwright | 網頁搜尋、UI 驗證 |
| DEBUGGER | Claude Sonnet + PUA | deepseek-v3.1:671b-cloud | 卡關偵錯、死局突破 |

## 使用方式

```
/smart-route "你的任務內容"
```

系統自動：
1. 分析任務維度（分析度/編碼度/複雜度/速度/規模）
2. 讀取 `~/.claude/sla-config.json` 確認可用模型
3. 計算加權分數選最佳角色
4. 執行並在失敗時 fallback

## 分析維度（0-100）

### 分析度
**觸發詞**：分析、讀、理解、診斷、審查、看看、為什麼、是什麼
**高分條件**：讀檔案、理解邏輯、診斷根因
**→ ANALYZER（Kimi MCP）**

### 編碼度
**觸發詞**：寫、改、修、實作、建立、開發、新增
**高分條件**：寫程式碼、修 bug、實作功能
**→ CODER（Claude Sonnet）或 FAST_CODER（Ollama qwen3-coder）**

### 複雜度
**高分條件**：架構設計、多模組整合、系統級決策、1000+ 行代碼
**→ PLANNER（Claude Opus）**

### 速度優先
**觸發詞**：快速、現在、馬上、急、趕時間、立即
**→ FAST_CODER（Ollama qwen3-coder:cloud，零延遲）**

### 規模等級
**大規模（100+ 行/多檔案）**：ANALYZER（Kimi）或 PLANNER（Opus）
**小規模（10-100 行）**：FAST_CODER（Ollama）

### 瀏覽需求
**觸發詞**：搜尋、查資料、網頁、文件、官網
**→ BROWSER（claude-in-chrome 有畫面 / playwright 背景）**

## 路由決策公式

```
PLANNER 得分    = (複雜度 × 0.9 + 規劃度 × 0.8) / 2
CODER 得分      = (編碼度 × 0.8 + 複雜度 × 0.4) / 2
FAST_CODER 得分 = 編碼度 × 0.7 + 速度 × 0.6 - 複雜度 × 0.3
ANALYZER 得分   = 分析度 × 0.8 + 規模 × 0.4
REVIEWER 得分   = 分析度 × 0.6 + 編碼度 × 0.3（只在 review 上下文）
BROWSER 得分    = 瀏覽需求 × 1.0

→ 選最高得分角色，讀 sla-config.json 確認可用，不可用則 fallback
```

## Ollama 雲端模型說明

Ollama 支援本地和雲端兩種執行方式：

| 模型 | 類型 | 適合任務 |
|------|------|---------|
| `qwen3-coder:480b-cloud` | 雲端 | 大型程式碼生成 |
| `deepseek-v3.1:671b-cloud` | 雲端 | 複雜推理、架構 |
| `glm-4.6:cloud` | 雲端 | 中文推理、邏輯 |
| `gpt-oss:120b-cloud` | 雲端 | 通用高品質 |
| `qwen3:8b` | 本地 | 快速、離線 |
| `qwen3:14b` | 本地 | 平衡品質/速度 |

**雲端模型使用 Ollama 標準方式呼叫**，不需額外 API Key（Ollama 帳號即可）。

## GSD 連動規則

| 觸發情境 | Smart Route 行動 |
|---------|----------------|
| `/sla:plan` 呼叫 | 強制路由到 PLANNER（Claude Opus） |
| `/sla:develop` 呼叫 | 依任務自動分配 CODER/FAST_CODER |
| `/sla:review` 呼叫 | 強制路由到 REVIEWER（Kimi） |
| `gsd:execute-phase` 執行中 | 每個子任務獨立路由 |
| 任務失敗 >= 2 次 | 升級為 DEBUGGER + 觸發 PUA |

## PUA 整合（卡關處理）

當任務連續失敗 2 次以上，自動觸發 `/pua`：

```
第 2 次失敗 → PUA L1（溫和失望）→ 切換本質不同方案
第 3 次失敗 → PUA L2（靈魂拷問）→ WebSearch + 讀源碼
第 4 次失敗 → PUA L3（3.25 警告）→ 7 項系統化檢查清單
第 5 次失敗 → PUA L4（畢業警告）→ 拼命模式
```

## Fallback 流程

```
首選模型不可用？
    ↓
讀 ~/.claude/sla-config.json
    ↓
找下一個可用的 fallback 模型
    ↓
若所有 fallback 都不可用 → Claude Sonnet（Claude Code 保底）
```

## 使用案例

### 案例 1：複雜功能規劃
**任務**：「設計多租戶訂單系統架構」
- 複雜度：95 → PLANNER 得分最高
- **決策**：Claude Opus

### 案例 2：快速修 CSS
**任務**：「馬上修這個按鈕對齊問題」
- 速度：95、編碼度：70、複雜度：5
- FAST_CODER 得分：70×0.7 + 95×0.6 - 5×0.3 = 104
- **決策**：Ollama qwen3-coder:cloud

### 案例 3：大檔案代碼分析
**任務**：「分析 ProductService 的性能瓶頸」
- 分析度：90、規模：80
- ANALYZER 得分：90×0.8 + 80×0.4 = 104
- **決策**：Kimi MCP

### 案例 4：卡關 debug
**任務**：連續失敗 3 次的 API 串接問題
- 自動升級 DEBUGGER + PUA L2
- **決策**：Claude Sonnet + PUA 強制 WebSearch + 讀源碼

## 版本記錄

### v2.0.0（SLA 整合版）
- 加入 Ollama 雲端模型（`:cloud` 後綴）
- 新增 BROWSER 角色（claude-in-chrome + playwright）
- 新增 DEBUGGER 角色（PUA 連動）
- GSD framework 連動觸發規則
- 讀取 sla-config.json 動態判斷可用模型

### v1.0.0（2026-03-08）
- 初版：4 模型、5 維度分析
