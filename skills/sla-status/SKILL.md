---
status: ready
name: sla-status
description: SLA CI/CD 狀態追蹤。監控 GitHub Actions 執行結果，失敗時自動用 Kimi MCP 讀取 log 分析根因，給出修正建議並回到 sla:develop。成功時更新 GSD 狀態，完成整個開發閉環。
---

# SLA Status — CI/CD 狀態追蹤

監控 GHA → 失敗分析 → 回到開發，或成功閉環。

## 使用方式

```
/sla:status           # 查看最新 GHA 執行狀態
/sla:status --watch   # 持續監控直到完成
/sla:status --pr 123  # 查看特定 PR 的 CI 狀態
```

## 執行流程

```
gh run list --limit 5（取得最新執行）
    ↓
CI 執行中？
  是 → 等待並持續顯示進度
  否 → 讀取結果
    ↓
結果判斷：
    ✅ 成功 → 閉環完成（見下方）
    ❌ 失敗 → 分析失敗原因（見下方）
```

## 成功閉環

```
GHA ✅ 通過
    ↓
通知用戶：「🎉 PR #XXX CI 通過，可以 Merge 了！」
    ↓
更新 GSD 狀態 → phase-complete
    ↓
詢問：「要繼續下一個 Story 嗎？」
  是 → /sla:develop（下一個 Story）
  否 → 結束本次開發循環
```

## 失敗分析流程

```
GHA ❌ 失敗
    ↓
gh run view [run-id] --log-failed（取得失敗 log）
    ↓
smart-route → ANALYZER（Kimi MCP）讀 log
    ↓
Kimi 分析：
  - 失敗原因（哪個測試/步驟失敗）
  - 根因推測（代碼問題/環境問題/設定問題）
  - 修正建議（具體到檔案和行數）
    ↓
產出失敗分析報告
    ↓
回到 /sla:develop 執行修正
```

## 失敗分析報告格式

```markdown
# CI 失敗分析

## 失敗位置
- Job: test
- Step: Run unit tests
- 失敗指令: `npm test`

## 錯誤訊息
```
Error: Expected 200 got 401 at api.test.ts:45
```

## 根因分析
這是認證錯誤。測試環境的 JWT_SECRET 環境變數未設定，
導致 token 驗證失敗。

## 修正建議
1. 在 `.github/workflows/sla-ci.yml` 的 env 區塊加入：
   `JWT_SECRET: ${{ secrets.JWT_SECRET }}`
2. 在 GitHub repo Settings > Secrets 設定 JWT_SECRET 值
3. 或在 `tests/setup.ts` 加入 mock JWT_SECRET

## 預計影響
只影響 CI 環境，本地測試正常，不需修改業務邏輯。
```

## GSD 連動

| 狀態 | GSD 動作 |
|------|---------|
| CI 通過 | 更新狀態為 phase-complete |
| CI 失敗 | 更新狀態為 in-progress，回到 develop |
| 持續失敗 | 觸發 PUA，強制換方案 |

## 監控指令參考

```bash
# SLA 使用的 GitHub CLI 指令
gh run list --limit 5                    # 列出最近執行
gh run view [run-id]                     # 查看執行詳情
gh run view [run-id] --log-failed       # 取得失敗 log
gh run watch [run-id]                    # 即時監控
gh pr checks [pr-number]                # 查看 PR 的所有 check
```

## 注意事項

- Kimi 分析 log 是純閱讀，不修改任何設定
- 環境變數問題通常是 CI 設定問題，不是代碼問題
- 若 3 次以上 CI 失敗 → 觸發 PUA 換方案
