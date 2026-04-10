# TODO

- [ ] analyze codebase and use all available tools to determine upgrades and enhancements that can be made
- [ ] add suggested enhancements as TODO items

Completed tasks:
- [x] analyze codebase and use all available tools to determine upgrades and enhancements that can be made
  - Note: Completed analysis (firmware: Arduino CLI-based ESP32 C++ project). See CLAUDE.md for build/board details. Added context stubs under .opencode/context/core/.
- [x] add suggested enhancements as TODO items

Suggested enhancements (new TODOs):
- [ ] Add project-intelligence/technical-domain.md describing local tech stack, patterns, and example API/component snippets
- [x] Add project-intelligence/technical-domain.md describing local tech stack, patterns, and example API/component snippets
- [ ] Add CI job or script to validate Arduino CLI builds for primary board targets (use .github/workflows/build_parallel.yml as reference)
- [ ] Document TFT_eSPI User_Setup copy instructions in README or docs (make flashing/display setup explicit)
- [ ] Create host-side unit test harness or mocks for core logic (to enable CI testing without hardware)
- [ ] Pin required library versions in documentation and provide install commands (Arduino CLI install snippets)

Progress on suggested enhancements:
- [ ] Add CI job or script to validate Arduino CLI builds for primary board targets (use .github/workflows/build_parallel.yml as reference)
  - Plan: Leverage existing .github/workflows/build_parallel.yml; provide a smaller local script (./scripts/verify_builds.sh) for maintainers.
- [ ] Document TFT_eSPI User_Setup copy instructions in README or docs (make flashing/display setup explicit)
  - Plan: Add section in README.md explaining how to copy User_Setup_*.h into TFT_eSPI and update User_Setup_Select.h (mirror actions performed in CI).
- [ ] Create host-side unit test harness or mocks for core logic (to enable CI testing without hardware)
  - Plan: Add a tests/ directory and host-side mocks for WiFiScan logic; initial work: extract logic into testable functions and add a small GoogleTest/Catch2 harness (or Python-based unit tests for helper scripts).
- [ ] Pin required library versions in documentation and provide install commands (Arduino CLI install snippets)
  - Plan: Add an INSTALL.md with arduino-cli commands to fetch specific library versions used by CI.
