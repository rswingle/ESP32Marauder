# TODO

- [ ] analyze codebase and use all available tools to determine upgrades and enhancements that can be made
- [ ] add suggested enhancements as TODO items

Completed tasks:
- [x] analyze codebase and use all available tools to determine upgrades and enhancements that can be made
  - Note: Completed analysis (firmware: Arduino CLI-based ESP32 C++ project). See CLAUDE.md for build/board details. Added context stubs under .opencode/context/core/.
- [x] add suggested enhancements as TODO items

Suggested enhancements (new TODOs):
- [ ] Add project-intelligence/technical-domain.md describing local tech stack, patterns, and example API/component snippets
- [ ] Add CI job or script to validate Arduino CLI builds for primary board targets (use .github/workflows/build_parallel.yml as reference)
- [ ] Document TFT_eSPI User_Setup copy instructions in README or docs (make flashing/display setup explicit)
- [ ] Create host-side unit test harness or mocks for core logic (to enable CI testing without hardware)
- [ ] Pin required library versions in documentation and provide install commands (Arduino CLI install snippets)
