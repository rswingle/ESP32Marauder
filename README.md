<!---[![License: MIT](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/justcallmekoko/ESP32Marauder/blob/master/LICENSE)--->
<!---[![Gitter](https://badges.gitter.im/justcallmekoko/ESP32Marauder.png)](https://gitter.im/justcallmekoko/ESP32Marauder)--->
<!---[![Build Status](https://travis-ci.com/justcallmekoko/ESP32Marauder.svg?branch=master)](https://travis-ci.com/justcallmekoko/ESP32Marauder)--->
<!---Shields/Badges https://shields.io/--->

# ESP32 Marauder
<p align="center"><img alt="Marauder logo" src="https://github.com/justcallmekoko/ESP32Marauder/blob/master/pictures/marauder_skull_patch_04_full_final.png?raw=true" width="300"></p>
<p align="center">
  <b>A suite of WiFi/Bluetooth offensive and defensive tools for the ESP32</b>
  <br><br>
  <a href="https://github.com/justcallmekoko/ESP32Marauder/blob/master/LICENSE"><img alt="License" src="https://img.shields.io/github/license/mashape/apistatus.svg"></a>
  <a href="https://gitter.im/justcallmekoko/ESP32Marauder"><img alt="Gitter" src="https://badges.gitter.im/justcallmekoko/ESP32Marauder.png"/></a>
  <a href="https://github.com/justcallmekoko/ESP32Marauder/releases/latest"><img src="https://img.shields.io/github/downloads/justcallmekoko/ESP32Marauder/total" alt="Downloads"/></a>
  <br>
  <a href="https://twitter.com/intent/follow?screen_name=jcmkyoutube"><img src="https://img.shields.io/twitter/follow/jcmkyoutube?style=social&logo=twitter" alt="Twitter"></a>
  <a href="https://www.instagram.com/just.call.me.koko"><img src="https://img.shields.io/badge/Follow%20Me-Instagram-orange" alt="Instagram"/></a>
  <br><br>
</p>
    
[![Build and Push](https://github.com/justcallmekoko/ESP32Marauder/actions/workflows/build_push.yml/badge.svg)](https://github.com/justcallmekoko/ESP32Marauder/actions/workflows/build_push.yml)

## Getting Started
Download the [latest release](https://github.com/justcallmekoko/ESP32Marauder/releases/latest) of the firmware.

Check out the project [wiki](https://github.com/justcallmekoko/ESP32Marauder/wiki) for a full overview of the ESP32 Marauder

# For Sale Now
You can buy the ESP32 Marauder using [this link](https://www.justcallmekokollc.com)

---

## Touchscreen Navigation

Screens with an ILI9341 display (V4, V6, V6.1, V7, Kit, CYD variants) use direct touch interaction:

- **Tap** an item to activate it immediately — no cursor navigation required.
- **Swipe up** (drag finger upward) to scroll the menu forward.
- **Swipe down** (drag finger downward) to scroll the menu back.
- Scroll arrows appear at the right edge of the screen when more items exist above or below the visible window.

During active scans (packet monitor, channel analyzer), the screen reverts to the original three-zone touch for channel up/down control.

---

## Building from Source

### Prerequisites

- [Arduino CLI](https://arduino.cc/en/software#arduino-cli)
- Python 3 + `esptool` (`pip install esptool`)
- Git

### Install the ESP32 Arduino Core

For **V6 and other d32-based targets** (IDF 3.3.4):

```bash
arduino-cli core update-index \
  --additional-urls https://github.com/espressif/arduino-esp32/releases/download/3.3.4/package_esp32_dev_index.json

arduino-cli core install esp32:esp32@3.3.4 \
  --additional-urls https://github.com/espressif/arduino-esp32/releases/download/3.3.4/package_esp32_dev_index.json
```

### Install Required Libraries

```bash
# Clone each library into your Arduino libraries directory (~/Arduino/libraries/ on Linux/macOS,
# Documents\Arduino\libraries on Windows)

git clone --branch 1.6       https://github.com/marian-craciunescu/ESP32Ping
git clone --branch v3.4.8    https://github.com/ESP32Async/AsyncTCP
git clone --branch v3.8.1    https://github.com/ESP32Async/ESPAsyncWebServer
git clone --branch v2.0.6    https://github.com/stevemarple/MicroNMEA
git clone --branch V2.5.34   https://github.com/Bodmer/TFT_eSPI
git clone --branch v1.4      https://github.com/PaulStoffregen/XPT2046_Touchscreen
git clone --branch 3.0.0     https://github.com/lvgl/lv_arduino
git clone --branch 1.8.0     https://github.com/Bodmer/JPEGDecoder
git clone --branch 2.3.8     https://github.com/h2zero/NimBLE-Arduino    # use 1.3.8 for S2/S3 targets
git clone --branch 1.12.0    https://github.com/adafruit/Adafruit_NeoPixel
git clone --branch v6.18.2   https://github.com/bblanchon/ArduinoJson
git clone --branch v1.3.3    https://github.com/ivanseidel/LinkedList
git clone --branch 8.1.0     https://github.com/plerup/espsoftwareserial
git clone --branch 1.15.0    https://github.com/adafruit/Adafruit_BusIO
git clone --branch 1.0.2     https://github.com/adafruit/Adafruit_MAX1704X
```


### Configure TFT_eSPI (display targets only)

Copy all `User_Setup_*.h` files from the repo root into your `TFT_eSPI` library directory, then activate the correct setup file in `User_Setup_Select.h`.

**For V6 (and V4, V6.1, V7, Kit):**

```bash
cp User_Setup_*.h ~/Arduino/libraries/TFT_eSPI/
```

Edit `~/Arduino/libraries/TFT_eSPI/User_Setup_Select.h` and uncomment the line:

```cpp
#include <User_Setup_og_marauder.h>
```

Make sure all other `#include` lines in that file are commented out.

TFT_eSPI - User Setup (developer-friendly steps)
------------------------------------------------

If you prefer to keep a local checkout of TFT_eSPI (or mirror CI behavior), follow these steps which mirror the repository workflow:

1. Create a local `CustomTFT_eSPI` directory (or use your Arduino libraries folder):

   ```bash
   git clone --branch V2.5.34 https://github.com/Bodmer/TFT_eSPI CustomTFT_eSPI
   cp User_Setup_og_marauder.h CustomTFT_eSPI/
   # Update User_Setup_Select.h inside CustomTFT_eSPI to include your chosen file
   ```

2. When using Arduino CLI or scripts, make sure the `CustomTFT_eSPI` path is included in your library path (`--libraries` flag) or placed in your standard libraries folder so the build picks the correct setup file.

3. CI workflows (see .github/workflows/build_parallel.yml) already copy and configure the correct User_Setup_*.h into their TFT_eSPI checkout before building — replicate those steps locally to reproduce CI builds.

### Apply the `-zmuldefs` Linker Patch (IDF 3.3.4)

IDF 3.3.4 requires a one-time patch to `platform.txt` to avoid duplicate-symbol linker errors:

```bash
PLATFORM_TXT=$(find ~/.arduino15/packages/esp32/hardware/esp32/3.3.4 -name platform.txt)
sed -i 's/compiler.c.elf.extra_flags=/compiler.c.elf.extra_flags=-Wl,-zmuldefs /' "$PLATFORM_TXT"
```

### Build for Marauder V6

```bash
arduino-cli compile \
  --fqbn esp32:esp32:d32:PartitionScheme=min_spiffs \
  --build-property "compiler.cpp.extra_flags='-DMARAUDER_V6'" \
  --warnings none \
  esp32_marauder/esp32_marauder.ino
```

The compiled `.bin` files land in:
```
esp32_marauder/build/esp32.esp32.d32/
```

---

## Flashing (V6)

The V6 uses a standard ESP32 (d32 board), so the bootloader loads at `0x1000`.

```bash
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 write_flash -z \
  0x1000  esp32_marauder.ino.bootloader.bin \
  0x8000  esp32_marauder.ino.partitions.bin \
  0xe000  boot_app0.bin \
  0x10000 esp32_marauder.ino.bin
```

Replace `/dev/ttyUSB0` with your actual serial port (`COMx` on Windows, `/dev/cu.usbserial-*` on macOS).

After flashing, open a serial monitor at **115200 baud**.

### Flash addresses by chip family

| Chip | Bootloader address |
|------|--------------------|
| ESP32 / d32 (V4, V6, V6.1, V7, Kit, Mini, CYD variants) | `0x1000` |
| ESP32-S2 (Flipper, Rev Feather) | `0x1000` |
| ESP32-S3 (MultiBoard S3, Cardputer) | `0x0` |
| ESP32-C5 | `0x2000` |

---

## Board Targets Quick Reference

| Hardware | Compile flag | FQBN | IDF | NimBLE | TFT setup file |
|----------|-------------|------|-----|--------|----------------|
| Marauder V6 | `MARAUDER_V6` | `esp32:esp32:d32:PartitionScheme=min_spiffs` | 3.3.4 | 2.3.8 | `User_Setup_og_marauder.h` |
| Marauder V6.1 | `MARAUDER_V6_1` | `esp32:esp32:d32:PartitionScheme=min_spiffs` | 3.3.4 | 2.3.8 | `User_Setup_og_marauder.h` |
| Marauder V4 | `MARAUDER_V4` | `esp32:esp32:d32:PartitionScheme=min_spiffs` | 3.3.4 | 2.3.8 | `User_Setup_og_marauder.h` |
| Marauder V7 | `MARAUDER_V7` | `esp32:esp32:d32:PartitionScheme=min_spiffs` | 3.3.4 | 2.3.8 | `User_Setup_dual_nrf24.h` |
| Marauder Kit | `MARAUDER_KIT` | `esp32:esp32:d32:PartitionScheme=min_spiffs` | 3.3.4 | 2.3.8 | `User_Setup_og_marauder.h` |
| Marauder Mini | `MARAUDER_MINI` | `esp32:esp32:d32:PartitionScheme=min_spiffs` | 3.3.4 | 2.3.8 | `User_Setup_marauder_mini.h` |
| Flipper WiFi Dev Board | `MARAUDER_FLIPPER` | `esp32:esp32:esp32s2:PartitionScheme=min_spiffs,FlashSize=4M,PSRAM=enabled` | 2.0.11 | 1.3.8 | — |
| Rev Feather | `MARAUDER_REV_FEATHER` | `esp32:esp32:esp32s2:PartitionScheme=min_spiffs,FlashSize=4M,PSRAM=enabled` | 2.0.11 | 1.3.8 | `User_Setup_marauder_rev_feather.h` |
| M5Cardputer | `MARAUDER_CARDPUTER` | `esp32:esp32:esp32s3:PartitionScheme=min_spiffs,FlashSize=8M,PSRAM=disabled` | 2.0.11 | 1.3.8 | `User_Setup_marauder_m5cardputer.h` |
| CYD 2432S028 | `MARAUDER_CYD_MICRO` | `esp32:esp32:d32:PartitionScheme=min_spiffs` | 2.0.11 | 1.3.8 | `User_Setup_cyd_micro.h` |
| CYD 2432S028 2USB | `MARAUDER_CYD_2USB` | `esp32:esp32:d32:PartitionScheme=min_spiffs` | 3.3.4 | 2.3.8 | `User_Setup_cyd_2usb.h` |
| CYD 3.5" | `MARAUDER_CYD_3_5_INCH` | `esp32:esp32:d32:PartitionScheme=min_spiffs` | 2.0.11 | 1.3.8 | `User_Setup_cyd_3_5_inch.h` |
| ESP32-C5 DevKitC-1 | `MARAUDER_C5` | `esp32:esp32:esp32c5:FlashSize=8M,PartitionScheme=min_spiffs,PSRAM=enabled` | 3.3.4 | 2.3.8 | — |
