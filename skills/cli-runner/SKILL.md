---
name: cli-runner
description: 多工並行 worktree 工作流。把大型任務拆成獨立子任務，各自在 git worktree 跑 Claude Code Agent，檔案型 JSON 追蹤狀態，最後依序合併。用於任務互不重疊、需要真正並行的場景。觸發詞：「並行執行」「多工」「worktree」「分段處理」
---

# Worktree 並行工作流

把大任務拆成獨立子任務，各自在 git worktree 中執行，避免共享狀態（STATE.md、shared files）衝突。

## 什麼時候用

- 任務可拆成 2–4 個**互不修改相同檔案**的子任務
- 需要真正並行（不是假並行）
- GSD 子代理並行時 STATE.md 衝突 → 改用這個

不適合：子任務有依賴順序、小改動、共用同一個檔案

---

## 工具箱（放在 ~/Development/cli-runner/）

| 腳本 | 用途 |
|------|------|
| `dispatch-task.sh` | 建立 worktree + 寫 JSON manifest（追蹤用）|
| `wt-status.js` | 查所有子任務的進度 |
| `wt-merge.sh` | 依序合併所有 done 分支 |

---

## 五步流程

### Phase 1：拆任務

每個子任務必須：
- 操作**不重疊的檔案集合**
- 有明確完成條件
- 取一個短 slug（例如 `feat-auth`、`feat-tests`）

### Phase 2：建 worktree + 派發

```bash
# 建 worktree（也會自動寫 manifest）
bash ~/Development/cli-runner/dispatch-task.sh \
  <project-dir> \
  <slug> \
  "<完整任務描述>" \
  default \
  ~/Development/cli-runner
```

然後用 **Claude Code Agent tool** 在 worktree 目錄執行（不是 cliorch）：

```
Agent tool：
  working_directory: <project-dir>/.wt/<slug>
  prompt: "<子任務完整描述，含接受條件>"
```

每個子任務同時派出 → 真正並行。

### Phase 3：監控進度

```bash
node ~/Development/cli-runner/wt-status.js <project-dir>
```

輸出：
```
TASK          BRANCH           STATUS    STARTED
feat-auth     feat/feat-auth   done      10:00
feat-tests    feat/feat-tests  running   10:01
feat-docs     feat/feat-docs   pending   -

Summary: 1 done, 1 running, 0 failed, 1 pending / 3 total
```

等所有 done 才進下一步。

### Phase 4：合併結果

```bash
bash ~/Development/cli-runner/wt-merge.sh <project-dir>
```

衝突時出現 4 選項（Human-in-the-loop）：
```
[1] 手動解衝突（mergetool）
[2] 跳過這個分支
[3] 保留主分支
[4] 用分支版本蓋掉
```

### Phase 5：驗證 + 清理

```bash
# 跑測試
cd <project-dir> && composer test

# 清 worktrees
git worktree remove .wt/feat-auth
git worktree remove .wt/feat-tests

# 清 manifests
rm -rf <project-dir>/.cliorch/tasks/
```

---

## 整合你的工作流

### 搭配 GSD（解決 STATE.md 衝突）

1. `/gsd:plan-phase` → 取得子任務列表
2. 每個子任務 → `dispatch-task.sh` 建 worktree
3. Agent tool 在各 worktree 執行（不共用 STATE.md）
4. 全部 done → `wt-merge.sh` 合併
5. `/gsd:verify-work` 驗收

### 搭配 dev-orchestrator

大型功能改用 worktree 分工：
- 前端 UI → worktree `feat-ui`
- 後端 API → worktree `feat-api`
- 測試 → worktree `feat-tests`（dependsOn: feat-ui, feat-api）

---

## Manifest 格式

`<project-dir>/.cliorch/tasks/<slug>.json`：

```json
{
  "id": "feat-auth",
  "branch": "feat/feat-auth",
  "worktree": ".wt/feat-auth",
  "status": "pending",
  "startedAt": null,
  "completedAt": null,
  "output": null,
  "errors": [],
  "dependsOn": []
}
```

status 流轉：`pending` → `running` → `done` / `failed`

---

## 快速指令

```bash
# 查進度
node ~/Development/cli-runner/wt-status.js $(pwd)

# 合併
bash ~/Development/cli-runner/wt-merge.sh $(pwd)

# 清 worktrees
git worktree list && git worktree prune
```
