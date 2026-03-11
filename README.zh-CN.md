# Smart LLM Agents (SLA)

<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-black?style=flat-square&logo=anthropic&logoColor=white" alt="Claude Code">
  <img src="https://img.shields.io/badge/Ollama-blue?style=flat-square" alt="Ollama">
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="MIT License">
  <img src="https://img.shields.io/badge/version-1.0.0-orange?style=flat-square" alt="Version">
</p>

<p align="center">
  <a href="README.md">English</a> ·
  <a href="README.zh-TW.md">繁體中文</a> ·
  <a href="README.zh-CN.md">简体中文</a>
</p>

> 智能多模型开发闭环套件 — 从规划到 PR，全自动。

---

## ⚡ 一键安装

```bash
curl -fsSL https://raw.githubusercontent.com/fishtvlvoe/sla/main/install.sh | bash
```

安装脚本自动检测环境，配置所有必要工具。

---

## SLA 是什么？

SLA 是一套 Claude Code Skills 套件，根据任务类型自动选择最合适的 AI 模型执行。涵盖完整开发生命周期：规划 → TDD 开发 → Code Review → PR → CI/CD 监控，形成完整闭环。

**解决的问题：** 不同任务需要不同模型。规划适合 Claude Opus，代码分析需要 Kimi 的长上下文，简单修改不需要强大模型。SLA 自动处理这些路由判断 — 你只需要描述你要做什么。

---

## 完整流程

```
你说：「我要做 X 功能」
         ↓
   /sla:plan  ──── Claude Opus 规划功能
         ↓         claude-in-chrome 搜索技术文档（如需要）
         ↓         Kimi 读现有代码理解架构
         ↓  输出：PLAN.md + Epic + Stories
         ↓
   /sla:develop ── smart-route 按任务分配：
         │          简单任务   → Ollama qwen3-coder:cloud
         │          复杂逻辑   → deepseek-v3.1:cloud / Claude Sonnet
         │          代码分析   → Kimi MCP
         │
         │  ┌── TDD 循环 ──────────────────────────────┐
         │  │  写测试（红灯）→ 写实现（绿灯）→ 重构    │
         │  │  → Playwright E2E 验证                   │
         │  │  → 卡住？→ PUA + YES.md 自动介入         │
         │  └──────────────────────────────────────────┘
         ↓
   /sla:review ─── Kimi MCP 读 git diff → Code Review 报告
         ↓         有问题回 develop 修正，通过继续
   /sla:release ── git push → gh pr create → GitHub Actions 触发
         ↓
   /sla:status ─── 监控 CI 结果
                   ✅ 成功 → 闭环完成 🎉
                   ❌ 失败 → Kimi 读 log 分析根因 → 回到 develop
```

---

## 指令说明

**开发闭环**

| 指令 | 说明 |
|------|------|
| `/smart-route "任务"` | 自动路由到最佳模型执行 |
| `/sla:plan "功能需求"` | 规划功能，串接 GSD |
| `/sla:develop` | TDD 开发循环 |
| `/sla:review` | Kimi 驱动 Code Review |
| `/sla:release` | 推送 PR + 触发 GitHub Actions |
| `/sla:status` | 监控 CI/CD 状态 |

**CLAUDE.md 维护**

| 指令 | 说明 |
|------|------|
| `AI.MD` 或 `蒸馏` | 优化 CLAUDE.md 格式，减少 token 消耗 |
| `audit my CLAUDE.md` | 审查内容是否与代码一致（Anthropic 官方工具） |
| `/revise-claude-md` | 把本次 Session 学到的新东西补进 CLAUDE.md |

**自我优化**

| 指令 | 说明 |
|------|------|
| `/learn` | 踩坑自动记录（后台静默执行） |
| `/diary` | Session 结束后写反思日记 |
| `/reflect` | 每周分析规律，建议更新 CLAUDE.md |

---

## 模型分工

| 角色 | 首选模型 | Fallback | 用途 |
|------|---------|---------|------|
| PLANNER | Claude Opus | deepseek:671b-cloud | 规划、架构设计 |
| CODER | Claude Sonnet | qwen3-coder:480b-cloud | 一般实现、修 bug |
| FAST_CODER | qwen3-coder:480b-cloud | qwen3:8b（本地） | 简单修改、CSS |
| ANALYZER | Kimi MCP | Claude Sonnet | 代码分析、大文件阅读 |
| REVIEWER | Kimi MCP | Claude Sonnet | Code Review、diff 分析 |
| BROWSER | claude-in-chrome | Playwright | 网页搜索、UI 验证 |
| DEBUGGER | Claude Sonnet + PUA | deepseek:cloud | 卡住调试 |

---

## 系统需求

| 工具 | 必要 | 自动安装 |
|------|------|---------|
| Claude Code | ✅ 必要 | 否（已假设安装） |
| Ollama | ✅ 必要 | ✅ 是 |
| GitHub CLI (`gh`) | ✅ 必要 | ✅ 是 |
| GSD Framework | 建议 | 否（手动安装） |
| Kimi API Key | 选填 | 否（安装时引导） |
| PUA Skill | 建议 | ✅ 是 |
| YES.md Skill | 建议 | ✅ 是 |

---

## Ollama 云端模型

SLA 使用 Ollama 云端模型，**不需要本机 GPU**！

```bash
# SLA 自动使用以下模型
ollama run qwen3-coder:480b-cloud    # 快速代码生成
ollama run deepseek-v3.1:671b-cloud  # 复杂推理
ollama run glm-4.6:cloud             # 中文推理
```

---

## 防放弃机制

SLA 内置两个互补的 Skill，确保 AI 做事不跑偏：

**[PUA](https://github.com/tanweai/pua)** — 让 AI 不放弃：
```
失败 2 次 → L1：温和失望 → 切换本质不同方案
失败 3 次 → L2：灵魂拷问 → WebSearch + 读源码
失败 4 次 → L3：3.25 考核 → 7 项系统化检查清单
失败 5 次 → L4：毕业警告 → 拼命模式
```

**[YES.md](https://github.com/sstklen/yes.md)** — 让 AI 做对的事：
- 下结论前必须有证据（不猜测）
- 改文件前先备份
- 修完必须验证
- 涟漪检查：确认没有搞坏其他地方

> PUA 让你继续，YES.md 让你继续时保持正确。

---

## 自我优化闭环

```
开发过程：/learn 静默记录踩坑
Session 结束：/diary 写反思日记
每周一次：/reflect 分析规律 → 建议更新 CLAUDE.md
          → /revise-claude-md 补充内容
          → AI.MD 优化格式
          → 下次 AI 更准确 🔄
```

---

## 卸载

```bash
curl -fsSL https://raw.githubusercontent.com/fishtvlvoe/sla/main/uninstall.sh | bash
```

---

## 贡献

欢迎 PR！请先阅读[贡献指南](docs/CONTRIBUTING.md)。

---

## Credits

- [tanweai/pua](https://github.com/tanweai/pua) — PUA 调试 Skill
- [sstklen/yes.md](https://github.com/sstklen/yes.md) — 工程纪律 Skill
- [sstklen/ai-md](https://github.com/sstklen/ai-md) — CLAUDE.md 格式优化
- [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) — CLAUDE.md 管理（Anthropic 官方）
- [GSD Framework](https://github.com/ezyang/get-shit-done) — 开发工作流框架
- [Kimi MCP](https://platform.moonshot.cn) — 长上下文分析

## License

MIT
