# TODO

 - [x] analyze codebase and use all available tools to determine upgrades and enhancements that can be made
 - [x] add suggested enhancements as TODO items

Completed tasks:
- [x] analyze codebase and use all available tools to determine upgrades and enhancements that can be made
  - Note: Completed analysis (firmware: Arduino CLI-based ESP32 C++ project). See CLAUDE.md for build/board details. Added context stubs under .opencode/context/core/.
- [x] add suggested enhancements as TODO items

Suggested enhancements (new TODOs):
- [x] Add project-intelligence/technical-domain.md describing local tech stack, patterns, and example API/component snippets
- [x] Add CI job or script to validate Arduino CLI builds for primary board targets (use .github/workflows/build_parallel.yml as reference)
- [x] Document TFT_eSPI User_Setup copy instructions in README or docs (make flashing/display setup explicit)
- [x] Create host-side unit test harness or mocks for core logic (to enable CI testing without hardware)
- [x] Pin required library versions in documentation and provide install commands (Arduino CLI install snippets)

Progress on suggested enhancements:
- [x] Add CI job or script to validate Arduino CLI builds for primary board targets (use .github/workflows/build_parallel.yml as reference)
  - Plan: Leverage existing .github/workflows/build_parallel.yml; provided a smaller local script (./scripts/verify_builds.sh) for maintainers.
- [x] Document TFT_eSPI User_Setup copy instructions in README or docs (make flashing/display setup explicit)
  - Plan: Added README.md section explaining how to copy User_Setup_*.h into TFT_eSPI and update User_Setup_Select.h (mirrors actions performed in CI).
- [x] Create host-side unit test harness or mocks for core logic (to enable CI testing without hardware)
  - Plan: Added a tests/ directory and placeholder host-side harness; next: extract testable firmware functions for real tests.
- [x] Pin required library versions in documentation and provide install commands (Arduino CLI install snippets)
  - Plan: Added INSTALL.md with arduino-cli commands to fetch specific library versions used by CI.
- [x] remove touch support as is and revert to original navigation
  - Note: Reverted default behavior to disable touch in MenuFunctions::RunSetup(); touch can be re-enabled via hardware toggle (C button). See esp32_marauder/MenuFunctions.cpp
