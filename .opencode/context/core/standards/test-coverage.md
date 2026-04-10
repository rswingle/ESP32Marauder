<!-- Context: core/standards/test-coverage | Priority: high | Version: 1.0 | Updated: 2026-04-10 -->

# Test Coverage Standards

Purpose: Define expectations for automated tests and acceptable coverage thresholds.

Key points:
- Write unit tests for critical logic paths
- Prefer deterministic tests; avoid flaky or time-dependent tests
- Aim for >70% coverage for core modules where feasible
- Use mocks/stubs for hardware interactions (ESP32 peripherals)

Example guidance:
1. Test helpers should set up and teardown any mocked hardware state.
2. CI should run test suite and fail on regressions.

📂 Codebase References: tests/ or platform-specific test helpers if present. For firmware, prefer host-side unit tests that exercise logic isolated from hardware.
