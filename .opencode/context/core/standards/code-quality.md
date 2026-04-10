<!-- Context: core/standards/code-quality | Priority: critical | Version: 1.0 | Updated: 2026-04-10 -->

# Code Quality Standards

Purpose: Establish baseline code-quality expectations for contributors and automated agents.

Key points:
- Keep functions small and focused (single responsibility)
- Prefer explicit types and clear naming
- Write unit tests for public functions and modules
- Avoid duplicated logic; extract reusable utilities

Example guidance:
1. Use descriptive names (getUserById, not gUB).
2. Limit function length to ~50 lines; split large functions.
3. Add a short comment for non-obvious decisions.

📂 Codebase References: See esp32_marauder/*.h/.cpp for prevailing C++/Arduino patterns in this repo.
