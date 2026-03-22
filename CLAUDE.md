# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ESP32 Marauder is an Arduino-based firmware providing WiFi/Bluetooth offensive and defensive tools for ESP32 hardware. The main sketch is `esp32_marauder/esp32_marauder.ino`. Current version is defined in `esp32_marauder/configs.h` as `MARAUDER_VERSION`.

## Building

This project uses **Arduino CLI** (not a makefile or cmake). The CI workflow in `.github/workflows/build_parallel.yml` documents the exact build process.

**Board FQBN examples:**
- Most hardware (d32-based): `esp32:esp32:d32:PartitionScheme=min_spiffs`
- S2-based (Flipper, Rev Feather): `esp32:esp32:esp32s2:PartitionScheme=min_spiffs,FlashSize=4M,PSRAM=enabled`
- S3-based (Cardputer, MultiBoard S3): `esp32:esp32:esp32s3:PartitionScheme=min_spiffs,FlashSize=8M`
- C5: `esp32:esp32:esp32c5:FlashSize=8M,PartitionScheme=min_spiffs`

**Build command pattern:**
```bash
arduino-cli compile \
  --fqbn esp32:esp32:d32:PartitionScheme=min_spiffs \
  --build-property compiler.cpp.extra_flags='-DMARAUDER_V6' \
  esp32_marauder/esp32_marauder.ino
```

**IDF versions by board family:**
- IDF 2.0.11: S2 and S3 targets (Flipper, MultiBoard S3, Rev Feather, CYD Micro, M5StickC, Cardputer, CYD 3.5")
- IDF 3.3.4: d32 targets (V4, V6, V6.1, V7, Kit, Mini, LDDB, Dev Board Pro, CYD 2USB, C5)

**NimBLE-Arduino versions:**
- 1.3.8 with IDF 2.0.11
- 2.3.8 with IDF 3.3.4

**Required libraries** (install via Arduino CLI or manually):
- ESP32Ping (marian-craciunescu/ESP32Ping @1.6)
- AsyncTCP (ESP32Async/AsyncTCP @v3.4.8)
- ESPAsyncWebServer (ESP32Async/ESPAsyncWebServer @v3.8.1)
- MicroNMEA (stevemarple/MicroNMEA @v2.0.6)
- TFT_eSPI (Bodmer/TFT_eSPI @V2.5.34)
- XPT2046_Touchscreen (PaulStoffregen/XPT2046_Touchscreen @v1.4)
- lv_arduino (lvgl/lv_arduino @3.0.0)
- JPEGDecoder (Bodmer/JPEGDecoder @1.8.0)
- NimBLE-Arduino (h2zero/NimBLE-Arduino)
- Adafruit_NeoPixel (adafruit/Adafruit_NeoPixel @1.12.0)
- ArduinoJson (bblanchon/ArduinoJson @v6.18.2)
- LinkedList (ivanseidel/LinkedList @v1.3.3)
- EspSoftwareSerial (plerup/espsoftwareserial @8.1.0)
- Adafruit_BusIO (adafruit/Adafruit_BusIO @1.15.0)
- Adafruit_MAX1704X (adafruit/Adafruit_MAX1704X @1.0.2)

**TFT_eSPI configuration:** Each hardware target has a corresponding `User_Setup_*.h` file at the repo root. Before building a display-enabled target, copy the appropriate file into the TFT_eSPI library directory and update `User_Setup_Select.h` to include it:
- `User_Setup_og_marauder.h` — V4, V6, V6.1, V7, Kit
- `User_Setup_marauder_mini.h` — Mini
- `User_Setup_marauder_m5stickc.h` — M5StickC Plus
- `User_Setup_marauder_m5stickcp2.h` — M5StickC Plus2
- `User_Setup_marauder_rev_feather.h` — Rev Feather
- `User_Setup_marauder_m5cardputer.h` — M5 Cardputer
- `User_Setup_cyd_micro.h` — CYD 2432S028
- `User_Setup_cyd_2usb.h` — CYD 2432S028 2USB
- `User_Setup_cyd_guition.h` — CYD 2432S024 GUITION
- `User_Setup_cyd_3_5_inch.h` — CYD 3.5"
- `User_Setup_dual_nrf24.h` — V7

## Flashing

Use `esptool.py` (or `esptool.exe` on Windows). Flash addresses vary by chip:
- ESP32 / d32 targets: bootloader at `0x1000`
- ESP32-S3: bootloader at `0x0`
- ESP32-C5: bootloader at `0x2000`

```bash
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 write_flash -z \
  0x1000 esp32_marauder.ino.bootloader.bin \
  0x8000 esp32_marauder.ino.partitions.bin \
  0xE000 boot_app0.bin \
  0x10000 esp32_marauder_<version>_<target>.bin
```

Serial monitor: **115200 baud**

## Architecture

### Hardware Abstraction via Preprocessor Defines

The entire codebase is gated on compile-time `#define` flags. Board targets (e.g., `MARAUDER_V6`, `MARAUDER_FLIPPER`) are defined either in `configs.h` (for local dev) or passed as `-DMARAUDER_V6` compiler flags (CI). Each board target sets feature flags:

- `HAS_SCREEN` — enables TFT display, `Display` and `MenuFunctions` objects
- `HAS_BT` — enables Bluetooth via NimBLE
- `HAS_GPS` — enables `GpsInterface`
- `HAS_SD` / `USE_SD` — enables `SDInterface`
- `HAS_BATTERY` — enables `BatteryInterface`
- `HAS_BUTTONS` — enables `Switches` objects (U/D/L/R/C buttons)
- `HAS_NEOPIXEL_LED` / `HAS_FLIPPER_LED` — selects LED driver
- `HAS_IDF_3` — enables IDF 3.x-specific code paths
- `HAS_NIMBLE_2` — enables NimBLE 2.x API

To add a new board target, define its feature flags in `configs.h` under the `BOARD FEATURES` section, add `HARDWARE_NAME`, and add a build entry to the CI matrix.

### Global Object Model

All subsystem objects are declared as globals in `esp32_marauder.ino` and accessed via `extern` declarations in other files. The primary objects are:

- `wifi_scan_obj` (`WiFiScan`) — core WiFi scanning/attack engine; owns scan mode state and packet callbacks
- `evil_portal_obj` (`EvilPortal`) — captive portal server
- `buffer_obj` (`Buffer`) — output buffer that saves data to SD and/or serial
- `settings_obj` (`Settings`) — SPIFFS-backed JSON settings store
- `cli_obj` (`CommandLine`) — serial CLI parser and command dispatcher
- `display_obj` (`Display`) — TFT display driver (screen targets only)
- `menu_function_obj` (`MenuFunctions`) — touch/button menu system (screen targets only)
- `gps_obj` (`GpsInterface`) — GPS NMEA parsing (GPS-capable targets only)
- `battery_obj` (`BatteryInterface`) — battery level monitoring

The main loop calls `.main(currentTime)` on each active object every iteration.

### Scan Mode State Machine

`WiFiScan` operates as a state machine driven by `currentScanMode`. Scan mode constants are defined in `WiFiScan.h` (e.g., `WIFI_SCAN_OFF`, `WIFI_SCAN_AP`, `WIFI_ATTACK_DEAUTH`, `BT_SCAN_ALL`). The CLI and menu both call `wifi_scan_obj.StartScan(mode)` / `wifi_scan_obj.StopScan()` to transition states.

### Settings Persistence

Settings are stored as JSON in SPIFFS. `Settings::begin()` loads from SPIFFS; if the format is incompatible it regenerates defaults. Use `settings_obj.loadSetting<T>("key")` and `settings_obj.saveSetting("key", value)` for access.

### CLI Commands

`CommandLine` parses newline-terminated input from Serial. Commands and their help strings are defined as `PROGMEM` constants in `CommandLine.h`. The `runCommand()` method dispatches to `wifi_scan_obj` methods or handles admin commands directly. All command names are lowercase strings (e.g., `scanap`, `attack`, `sniffbt`).

## Touchscreen Interaction (HAS_ILI9341 screens)

Menu navigation uses direct touch — no highlight-then-select cursor. The logic lives in `MenuFunctions::main()` (`MenuFunctions.cpp`):

- **Tap**: Touch release with `|deltaY| ≤ 15px` → hit-tests `display_obj.key[0..visible-1]` (via `TFT_eSPI_Button::contains()`) and calls the matched item's `callable()` directly.
- **Swipe up** (finger moves upward, `deltaY < -15`): increments `menu_start_index` by 1 and redraws.
- **Swipe down** (finger moves downward, `deltaY > 15`): decrements `menu_start_index` by 1 and redraws.
- **Scroll indicators**: `displayCurrentMenu()` draws small white triangles at the right edge (x = `TFT_WIDTH-6`) above the first button when scrolled down, and below the last button when more items exist below.
- **During active scans** (packet monitor, channel analyzer, etc.): the old 3-zone touch (top/bottom = channel up/down) is preserved in the `else` branch.
- Touch state is tracked with `static` locals (`_t_was_pressed`, `_t_start_x/y`, `_t_last_y`) inside `main()`.

## Key Files

| File | Purpose |
|------|---------|
| `esp32_marauder/configs.h` | Board targets, feature flags, version number — edit here to set target for local builds |
| `esp32_marauder/WiFiScan.h/.cpp` | WiFi/BT scan and attack logic, scan mode constants |
| `esp32_marauder/CommandLine.h/.cpp` | Serial CLI, all command strings and dispatch |
| `esp32_marauder/MenuFunctions.h/.cpp` | Touch/button UI menu system |
| `esp32_marauder/Display.h/.cpp` | TFT display rendering |
| `esp32_marauder/settings.h/.cpp` | SPIFFS JSON settings |
| `esp32_marauder/Buffer.h/.cpp` | Buffered output to SD/serial |
| `User_Setup_*.h` (repo root) | TFT_eSPI pin/driver configs per hardware target |
| `.github/workflows/build_parallel.yml` | CI build matrix — source of truth for all build parameters |
