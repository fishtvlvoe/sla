---
status: ready
name: sla-plan
description: SLA 開發規劃。接收功能需求，透過 smart-route 路由到 Claude Opus 規劃，串接 GSD plan-phase 產出 PLAN.md + Epic + Stories。需要技術研究時自動用 claude-in-chrome 搜尋，需要讀現有代碼時用 Kimi MCP 分析架構。
---

# SLA Plan — 開發規劃

從需求到可執行計畫的全自動流程。

## 使用方式

```
/sla:plan "需求描述"

範例：
/sla:plan "建立多租戶訂單管理系統，支援 LINE 通知"
/sla:plan "重構購物車模組，改善性能"
/sla:plan "新增 Google OAuth 登入"
```

## 執行流程

```
用戶輸入需求
    ↓
1. smart-route → PLANNER（Claude Opus）
    ↓
2. 需要查技術資料？
   是 → claude-in-chrome 搜尋（有畫面，用戶可見）
   否 → 跳過
    ↓
3. 有現有代碼需要理解？
   是 → Kimi MCP 分析架構（長上下文讀檔）
   否 → 跳過
    ↓
4. 產出規劃文件：
   - PRD（產品需求）
   - 技術架構說明
   - Epic 拆解
   - Stories 清單
    ↓
5. gsd:plan-phase → 寫入 PLAN.md
    ↓
6. 詢問用戶確認，確認後 → /sla:develop
```

## 產出物格式

### PLAN.md 結構
```
# [功能名稱] 開發計畫

## 目標
一句話描述這個功能/改動的核心目標。

## 技術架構
2-3 句說明實作方式和關鍵技術選擇。

## Epic 拆解
- Epic 1: [名稱]
  - Story 1.1: [具體任務]
  - Story 1.2: [具體任務]
- Epic 2: [名稱]
  ...

## 測試策略
- 單元測試：[覆蓋範圍]
- 整合測試：[關鍵路徑]
- E2E 測試：[使用者流程]

## 預計 Commit 順序
1. feat: [第一個原子 commit]
2. feat: [第二個原子 commit]
...
```

## 觸發規則

| 情況 | 動作 |
|------|------|
| 用戶說「開始」「規劃」「計畫」「我要做 X」 | 自動觸發 /sla:plan |
| 有 GSD PLAN.md 尚未完成 | 詢問是否繼續上次計畫 |
| 計畫完成後 | 自動提示執行 /sla:develop |

## 與 GSD 銜接

- 呼叫 `gsd:plan-phase` 管理計畫狀態
- 呼叫 `gsd:discuss-phase` 深入討論需求
- 計畫存入 `.planning/` 目錄（GSD 標準路徑）

## 模型分工

| 任務 | 模型 |
|------|------|
| 需求分析、架構設計 | Claude Opus（PLANNER） |
| 查技術文件、搜尋 API | claude-in-chrome（BROWSER） |
| 讀現有代碼理解架構 | Kimi MCP（ANALYZER） |
| 規劃細節補充 | Claude Sonnet（CODER） |

## 注意事項

- 計畫完成前**不執行任何代碼**
- 有疑問時一次問一個問題，不同時問多個
- 產出計畫後必須讓用戶確認才進入開發
- YAGNI 原則：只規劃當前需求，不設計未來擴展
