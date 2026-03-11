---
status: ready
name: sla-review
description: SLA Code Review。用 Kimi MCP 分析 git diff，產出結構化 Code Review 報告（問題清單、建議、安全風險）。有問題回到 sla:develop 修正，通過後自動進入 sla:release。串接 GSD verify-work 驗收流程。
---

# SLA Review — Code Review

Kimi 讀 diff → 分析問題 → 產出報告 → 通過進 release。

## 使用方式

```
/sla:review          # 自動比對 main 的 diff
/sla:review --branch feature/xxx  # 指定分支
```

## 執行流程

```
取得 git diff（與 main 比較）
    ↓
smart-route → REVIEWER（Kimi MCP）
    ↓
Kimi 分析 diff：
  - 邏輯問題
  - 安全風險
  - 性能隱患
  - 代碼風格
  - 測試覆蓋
    ↓
產出 Code Review 報告
    ↓
有問題？
  是 → 列出問題清單 → 回到 /sla:develop 修正
  否 → 通過 ✅ → 提示執行 /sla:release
```

## Code Review 報告格式

```markdown
# Code Review 報告

## 總覽
- 檔案變動：X 個
- 新增行數：+XXX
- 刪除行數：-XXX
- 整體評估：✅ 通過 / ⚠️ 需修正 / ❌ 重大問題

## 問題清單

### 🔴 重大問題（必須修正）
- [ ] `file.ts:42` — SQL 注入風險，直接拼接用戶輸入
- [ ] `api.ts:88` — 未驗證 JWT，任何人可訪問

### 🟡 建議改進（建議修正）
- [ ] `service.ts:120` — 函數超過 50 行，建議拆分
- [ ] `utils.ts:33` — 重複邏輯，可提取為共用函數

### 🟢 好的做法（值得保留）
- `auth.ts:55` — 正確使用了 parameterized query
- 測試覆蓋率良好，關鍵路徑均有測試

## 安全性檢查
- [ ] XSS 防護
- [x] SQL Injection 防護
- [x] CSRF Token
- [ ] 敏感資料加密

## 測試覆蓋評估
- 單元測試：完整 ✅
- 整合測試：部分缺失 ⚠️
- E2E 測試：已通過 ✅
```

## Kimi MCP 分析重點

Kimi 具備長上下文能力，適合分析大型 diff：

| 分析維度 | 檢查項目 |
|---------|---------|
| 安全性 | OWASP Top 10、SQL Injection、XSS、認證繞過 |
| 邏輯正確性 | 邊界條件、錯誤處理、空值處理 |
| 性能 | N+1 查詢、不必要的迴圈、記憶體洩漏 |
| 可維護性 | 函數長度、複雜度、重複代碼 |
| 測試品質 | 測試覆蓋、斷言品質、邊界測試 |

## Fallback

| Kimi 狀態 | 替代方案 |
|---------|---------|
| Kimi 不可用 | Claude Sonnet 讀 diff |
| diff 過大 | 分段送審，每段 < 2000 行 |

## GSD 連動

- 呼叫 `gsd:verify-work` 做最終驗收
- Review 結果寫入 `.planning/REVIEW.md`
- 通過後更新 GSD 狀態為 ready-to-release

## 通過標準

以下全部達到才算通過：
- ✅ 無重大問題（🔴）
- ✅ 建議問題已處理或有說明跳過原因
- ✅ 安全性檢查通過
- ✅ 測試覆蓋不低於開發前

## 注意事項

- Kimi 分析純閱讀，不修改任何檔案
- 報告儲存在 `.planning/REVIEW.md`
- 問題修正後可重新執行 `/sla:review` 驗證
