# Contributing to Smart LLM Agents (SLA)

## 貢獻指南

歡迎任何形式的貢獻！

### 如何貢獻

1. Fork 這個倉庫
2. 建立你的 feature branch：`git checkout -b feat/your-feature`
3. Commit 你的修改：`git commit -m "feat: add something"`
4. Push 到 branch：`git push origin feat/your-feature`
5. 開一個 Pull Request

### 貢獻類型

- **新 Skill** — 在 `skills/` 下新增資料夾 + `SKILL.md`
- **改進現有 Skill** — 直接修改對應 `SKILL.md`
- **文件改善** — README、guides 的修正或翻譯
- **Bug 回報** — 開 GitHub Issue

### Skill 格式規範

每個 Skill 需要有標準 frontmatter：

```markdown
---
status: ready
name: skill-name
description: 一句話說明這個 Skill 做什麼，何時觸發。
---
```

### 語言規範

- Skill 說明文字：中英雙語（英文 + 繁體中文）
- Code 和指令：保留英文原文
- Commit 訊息：英文（`feat:` / `fix:` / `docs:` / `chore:`）

---

For English contributors: Same rules, just write descriptions in both English and Traditional Chinese.
