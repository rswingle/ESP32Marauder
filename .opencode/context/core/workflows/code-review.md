<!-- Context: core/workflows/code-review | Priority: critical | Version: 1.0 | Updated: 2026-04-10 -->

# Code Review Workflow

Purpose: Provide a consistent, efficient code-review process for contributors and automated reviewers.

Key points:
- Submit focused pull requests with a clear summary and small scope
- Include testing steps and reproduction instructions in PR body
- Reviewers should check logic, tests, security, and style
- Use automated linters and CI checks where available

Example PR body:
```
Summary: Fix bug in WiFi scan mode handling

Changes:
- wifi_scan.cpp: fix state transition
- tests/wifi_scan_test.cpp: add regression test

Testing:
- Run unit tests: ./scripts/run_tests
```

📂 Codebase References: Follow esp32_marauder/CLAUDE.md for build instructions used in PR testing.
