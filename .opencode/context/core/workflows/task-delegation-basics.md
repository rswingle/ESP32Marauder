<!-- Context: core/workflows/task-delegation | Priority: critical | Version: 1.0 | Updated: 2026-04-10 -->

# Task Delegation Basics

Purpose: Minimal guidance for delegating tasks to subagents and external contributors.

Key points:
- Provide clear acceptance criteria and expected outputs
- Include file paths and relevant context files the delegate should load
- Break complex tasks into verifiable subtasks with explicit checks

Example delegation checklist:
1. Load context: .opencode/context/core/standards/code-quality.md
2. Files to edit: src/.., tests/.. (list exact files)
3. Acceptance: All unit tests pass; TODOs removed

📂 Codebase References: This repository uses Arduino CLI and firmware targets — include CLAUDE.md when delegating build/flash tasks.
