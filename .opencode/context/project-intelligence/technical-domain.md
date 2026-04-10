<!-- Context: project-intelligence/technical | Priority: critical | Version: 1.0 | Updated: 2026-04-10 -->

# Technical Domain

Purpose: Describe the local tech stack, common patterns, build and testing guidance for the ESP32 Marauder firmware project.

Quick Reference
- Framework: Arduino-based firmware (C++ / Arduino core)
- Build: arduino-cli (see build examples in CLAUDE.md and .github/workflows/build_parallel.yml)
- Primary targets: ESP32 families (d32, esp32s2, esp32s3, esp32c5)
- Language: C++ (Arduino)

Primary Stack
| Layer | Technology | Version / Notes |
|---|---|---|
| Framework | Arduino CLI | see CLAUDE.md build examples |
| Language | C++ (Arduino) | - |
| Libraries | Multiple Arduino libraries (TFT_eSPI, ArduinoJson, NimBLE-Arduino, etc.) | versions pinned in docs |

Code Patterns
1. Files are organized by subsystem (esp32_marauder/*.h and *.cpp). Global objects are declared in the main sketch and accessed via extern declarations.
2. Build variants are selected via -D compile flags (MARAUDER_V6, MARAUDER_FLIPPER, etc.).

Naming Conventions
- Files: snake_case or PascalCase for classes where appropriate
- Global objects: suffix _obj where used (display_obj, wifi_scan_obj)

Code Standards
- Prefer small functions, clear naming, and short comments for non-obvious hardware interactions
- Hardware access should be abstracted behind interfaces where practical to enable host-side testing

Security Requirements
- Validate and sanitize any data saved to SPIFFS
- Avoid logging sensitive data (WiFi credentials) in persistent logs

📂 Codebase References
- esp32_marauder/esp32_marauder.ino — main sketch and global object declarations
- esp32_marauder/WiFiScan.* — core scanning/attack logic
- CLAUDE.md — build and board-specific instructions
