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

> Intelligent multi-model development loop for Claude Code — from planning to PR, fully automated.

---

## ⚡ One-Click Install

```bash
curl -fsSL https://raw.githubusercontent.com/fishtvlvoe/sla/main/install.sh | bash
```

The installer auto-detects your environment and configures everything.

---

## What is SLA?

SLA is a Claude Code skill pack that routes tasks to the best AI model automatically. It covers the full development lifecycle: planning → TDD development → code review → PR → CI/CD monitoring — all in one closed loop.

**The problem it solves:** Different tasks need different models. Planning needs Claude Opus. Code analysis needs Kimi's long context. Quick edits don't need a powerful model at all. SLA handles this routing automatically — you just describe what you want to build.

---

## Full Workflow

```
You: "I want to build X"
         ↓
   /sla:plan  ──── Claude Opus plans the feature
         ↓         claude-in-chrome searches docs if needed
         ↓         Kimi reads existing code for context
   Outputs: PLAN.md + Epics + Stories
         ↓
   /sla:develop ── smart-route assigns per task:
         │          Simple tasks  → Ollama qwen3-coder:cloud
         │          Complex logic → deepseek-v3.1:cloud / Claude Sonnet
         │          Code analysis → Kimi MCP
         │
         │  ┌── TDD Loop ─────────────────────────┐
         │  │  Write test (red) → Implement (green) │
         │  │  → Refactor → Playwright E2E          │
         │  │  → Stuck? → PUA + YES.md kick in      │
         │  └────────────────────────────────────────┘
         ↓
   /sla:review ─── Kimi MCP reads git diff → Code Review report
         ↓         Issues? Back to develop. Clean? Continue.
   /sla:release ── git push → gh pr create → GitHub Actions triggered
         ↓
   /sla:status ─── Monitor CI results
                   ✅ Pass → Loop complete 🎉
                   ❌ Fail → Kimi reads log → Root cause → Back to develop
```

---

## Commands

**Development Loop**

| Command | Description |
|---------|-------------|
| `/smart-route "task"` | Auto-route task to best model |
| `/sla:plan "feature"` | Plan feature with GSD integration |
| `/sla:develop` | TDD development loop |
| `/sla:review` | Kimi-powered code review |
| `/sla:release` | Push PR + trigger CI |
| `/sla:status` | Monitor GitHub Actions |

**CLAUDE.md Maintenance**

| Command | Description |
|---------|-------------|
| `AI.MD` | Optimize CLAUDE.md format for AI consumption |
| `audit my CLAUDE.md` | Audit content accuracy against codebase (official) |
| `/revise-claude-md` | Capture session learnings into CLAUDE.md |

**Self-Improvement**

| Command | Description |
|---------|-------------|
| `/learn` | Auto-record pitfalls in background |
| `/diary` | Write session reflection diary |
| `/reflect` | Weekly pattern analysis + suggest CLAUDE.md updates |

---

## Model Routing

| Role | Primary | Fallback | Use Case |
|------|---------|---------|---------|
| PLANNER | Claude Opus | deepseek:671b-cloud | Planning, architecture |
| CODER | Claude Sonnet | qwen3-coder:480b-cloud | Implementation |
| FAST_CODER | qwen3-coder:480b-cloud | qwen3:8b (local) | Quick changes, CSS |
| ANALYZER | Kimi MCP | Claude Sonnet | Code analysis, large files |
| REVIEWER | Kimi MCP | Claude Sonnet | Code review, diff analysis |
| BROWSER | claude-in-chrome | Playwright | Web search, UI validation |
| DEBUGGER | Claude Sonnet + PUA | deepseek:cloud | Stuck debugging |

---

## Requirements

| Tool | Required | Auto-installed |
|------|----------|---------------|
| Claude Code | ✅ Yes | No (assumed) |
| Ollama | ✅ Yes | ✅ Yes |
| GitHub CLI (`gh`) | ✅ Yes | ✅ Yes |
| GSD Framework | Recommended | No (manual) |
| Kimi API Key | Optional | No (guided) |
| PUA Skill | Recommended | ✅ Yes |
| YES.md Skill | Recommended | ✅ Yes |

---

## Ollama Cloud Models

SLA uses Ollama's cloud models — no local GPU required.

```bash
# Used by SLA automatically
ollama run qwen3-coder:480b-cloud    # Fast coding
ollama run deepseek-v3.1:671b-cloud  # Complex reasoning
ollama run glm-4.6:cloud             # Chinese reasoning
```

---

## Anti-Failure Mechanisms

SLA bundles two complementary skills to keep AI on track:

**[PUA](https://github.com/tanweai/pua)** — Prevents giving up:
```
Failure × 2 → L1: Mild pressure → Switch approach
Failure × 3 → L2: WebSearch + read source code
Failure × 4 → L3: 7-item systematic checklist
Failure × 5 → L4: All-in mode
```

**[YES.md](https://github.com/sstklen/yes.md)** — Enforces correctness:
- Evidence before conclusions (no guessing)
- Backup before modifying files
- Verify after every fix
- Ripple check: look for related issues

> PUA keeps you going. YES.md keeps you going correctly.

---

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/fishtvlvoe/sla/main/uninstall.sh | bash
```

---

## Contributing

PRs welcome! Please read our [contributing guide](docs/CONTRIBUTING.md).

---

## Credits

- [tanweai/pua](https://github.com/tanweai/pua) — PUA debugging skill
- [sstklen/yes.md](https://github.com/sstklen/yes.md) — Engineering discipline skill
- [sstklen/ai-md](https://github.com/sstklen/ai-md) — CLAUDE.md AI-native optimizer
- [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) — CLAUDE.md management (official)
- [GSD Framework](https://github.com/ezyang/get-shit-done) — Development workflow
- [Kimi MCP](https://platform.moonshot.cn) — Long-context analysis

## License

MIT
