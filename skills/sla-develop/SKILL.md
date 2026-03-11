---
status: ready
name: sla-develop
description: SLA TDD 開發循環。讀取 PLAN.md 執行任務，smart-route 自動分配最佳模型，嚴格遵守「測試先行」原則。用 Playwright 執行 E2E 測試，連續失敗時觸發 PUA 強制突破卡關。串接 GSD execute-phase 做原子 commit 管理。
---

# SLA Develop — TDD 開發循環

讀計畫 → 寫測試 → 寫實作 → 測試通過 → Commit → 下一個任務。

## 使用方式

```
/sla:develop          # 讀 PLAN.md 繼續開發
/sla:develop "任務"   # 指定特定任務開發
```

## TDD 循環（每個 Story 執行一次）

```
讀 PLAN.md 取得當前任務
    ↓
smart-route 分配模型
    ↓
┌─────────────────────────────────┐
│        TDD 循環                  │
│                                  │
│  1. 寫測試（預期失敗）            │
│         ↓                        │
│  2. 執行測試 → 確認紅燈           │
│         ↓                        │
│  3. 寫最小實作讓測試通過          │
│         ↓                        │
│  4. 執行測試 → 確認綠燈           │
│         ↓                        │
│  5. 重構（保持綠燈）              │
│         ↓                        │
│  6. Playwright E2E 驗證          │
│         ↓                        │
│  7. git commit（原子提交）        │
└─────────────────────────────────┘
    ↓
更新 GSD 狀態 → 下一個 Story
```

## 模型分配（smart-route 自動判斷）

| 任務類型 | 模型 | 例子 |
|---------|------|------|
| 架構性代碼 | Claude Sonnet | Service、Repository 層 |
| 簡單 UI | qwen3-coder:480b-cloud | CSS、表單、按鈕 |
| 複雜邏輯 | deepseek-v3.1:671b-cloud | 演算法、資料處理 |
| 代碼分析 | Kimi MCP | 讀現有代碼找整合點 |
| 快速修改 | qwen3:8b（本地） | 小改動、格式調整 |

## PUA 卡關機制

```
任務執行失敗
    ↓
計數 +1
    ↓
失敗 2 次 → PUA L1：「這個 bug 都解決不了？」→ 切換本質不同方案
失敗 3 次 → PUA L2：「底層邏輯是什麼？」→ WebSearch + 讀源碼
失敗 4 次 → PUA L3：「3.25 考核」→ 7 項系統化檢查清單
失敗 5 次 → PUA L4：「畢業警告」→ 拼命模式
```

## Playwright 測試整合

- **背景執行**（headless）：自動跑 E2E 測試，不打擾用戶
- **測試路徑**：`tests/e2e/` 或 `e2e/`
- **失敗時**：截圖 + 錯誤報告 → 回到 TDD 循環修正

```bash
# SLA 自動執行的指令
npx playwright test --reporter=json
```

## Git Commit 規則

每個 Story 完成後**原子提交**：

```bash
# 格式
git add [只加這個 Story 相關的檔案]
git commit -m "feat: [Story 描述]"

# 範例
git commit -m "feat: add order validation unit tests"
git commit -m "feat: implement order validation logic"
git commit -m "test: add E2E test for checkout flow"
```

**禁止**：
- `git add .` 或 `git add -A`（可能包含敏感檔案）
- 一個 commit 混入多個 Story 的改動

## GSD 連動

- 執行前讀 `.planning/PLAN.md`（GSD 標準路徑）
- 每個 Story 完成後更新 GSD 狀態
- 全部完成後提示執行 `/sla:review`

## 完成條件

一個 Story 完成需滿足：
- ✅ 測試全部通過（綠燈）
- ✅ E2E 測試通過（或已知跳過原因）
- ✅ 已 commit
- ✅ GSD 狀態已更新

## 注意事項

- **測試必須先寫**：沒有測試的實作不算完成
- **一次一個 Story**：不跳躍，不同時開多個
- **失敗是正常的**：TDD 第一步本來就是紅燈
- **不要 `--no-verify`**：必須讓 git hooks 跑完
