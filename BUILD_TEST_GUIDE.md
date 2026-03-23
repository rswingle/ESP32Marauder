# ESP32 Marauder Build & Test Guide

## Prerequisites

### Required Software
```bash
# Install Arduino CLI
# On Linux:
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh

# On macOS:
brew install arduino-cli

# On Windows:
# Download from https://arduino.github.io/arduino-cli/installation/
```

### Required Hardware for Testing
- ESP32 Marauder device (V6 recommended for touchscreen testing)
- USB cable for programming
- Computer with Arduino CLI installed

---

## Quick Build Instructions

### 1. List Available Targets
```bash
cd /opt/ESP32Marauder
./build.sh
```

### 2. Build for Specific Target
```bash
# For V6 (most common, has touchscreen)
./build.sh v6

# For V6.1
./build.sh v6_1

# For CYD 2USB (Cheap Yellow Display)
./build.sh cyd_2usb

# For Cardputer
./build.sh cardputer
```

### 3. Expected Build Output
```
[build] Target:    v6 (MARAUDER_V6)
[build] FQBN:      esp32:esp32:d32:PartitionScheme=min_spiffs
[build] IDF:       3.3.4  NimBLE: 2.3.8
[build] TFT file:  User_Setup_og_marauder.h

[build] Installing ESP32 core 3.3.4...
[build] Installing libraries...
[build] Configuring TFT_eSPI...
[build] Applying zmuldefs patch...
[build] Building...
[build] Build complete.
[build] Binary: esp32_marauder/build/esp32.esp32.d32/esp32_marauder.ino.bin
[build] Size:   1.2M
```

---

## Flashing the Firmware

### Using esptool
```bash
# For ESP32/d32 targets (bootloader @ 0x1000)
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 write_flash -z \
  0x1000 esp32_marauder.ino.bootloader.bin \
  0x8000 esp32_marauder.ino.partitions.bin \
  0xe000 boot_app0.bin \
  0x10000 esp32_marauder.ino.bin

# For ESP32-S3 (bootloader @ 0x0)
esptool.py --chip esp32s3 --port /dev/ttyUSB0 --baud 921600 write_flash -z \
  0x0 esp32_marauder.ino.bootloader.bin \
  0x8000 esp32_marauder.ino.partitions.bin \
  0x10000 esp32_marauder.ino.bin
```

### Using Arduino CLI
```bash
arduino-cli upload -p /dev/ttyUSB0 --fqbn esp32:esp32:d32 \
  esp32_marauder/esp32_marauder.ino
```

---

## Testing the Touchscreen Fix

### Test Setup Required
- ✅ Device with ILI9341 touchscreen (V6, V6.1, V7, Kit, CYD variants)
- ✅ Firmware with the fix applied
- ✅ Menu with >6 items (to test scrolling)

### Manual Test Plan

#### Test 1: Horizontal Swipe (REGRESSION TEST)
**Purpose**: Verify the bug fix

Steps:
1. Navigate to a menu with >6 items
2. Place finger on a button area
3. Swipe horizontally left or right (>15px)
4. Release finger

**Expected Result**:
- ✅ Menu scrolls OR nothing happens
- ❌ Button should NOT execute

**Before Fix**: Button executed (BUG)

#### Test 2: Vertical Swipe Up
**Purpose**: Verify scrolling still works

Steps:
1. Navigate to a menu with >6 items
2. Place finger at bottom of screen
3. Swipe up (>15px vertical movement)
4. Release finger

**Expected Result**: Menu scrolls forward

#### Test 3: Vertical Swipe Down
**Purpose**: Verify reverse scrolling works

Steps:
1. Scroll down a few times
2. Place finger at top of screen
3. Swipe down (>15px vertical movement)
4. Release finger

**Expected Result**: Menu scrolls back

#### Test 4: Tap (Short Touch)
**Purpose**: Verify button taps still work

Steps:
1. Navigate to any menu
2. Quick tap on a button (<15px movement in any direction)
3. Release finger

**Expected Result**: Button executes

#### Test 5: Scroll Boundary - Top
**Purpose**: Verify no scrolling past top

Steps:
1. At top of menu (menu_start_index = 0)
2. Swipe down repeatedly

**Expected Result**: Stops at top, doesn't go to negative index

#### Test 6: Scroll Boundary - Bottom
**Purpose**: Verify no empty pages at bottom

Steps:
1. At bottom of menu
2. Swipe up repeatedly

**Expected Result**: Stops at last full page, doesn't show empty buttons

#### Test 7: Diagonal Swipe
**Purpose**: Verify diagonal gestures are ignored

Steps:
1. Place finger on button
2. Swipe diagonally (>15px on both axes)
3. Release finger

**Expected Result**: No action (ignored)

### Test Results Template

```
Date: ___________
Device: ___________
Firmware: v1.11.0 with touchscreen fix

Test 1 (Horizontal Swipe):   PASS / FAIL
Test 2 (Swipe Up):            PASS / FAIL
Test 3 (Swipe Down):          PASS / FAIL
Test 4 (Tap):                 PASS / FAIL
Test 5 (Top Boundary):        PASS / FAIL
Test 6 (Bottom Boundary):     PASS / FAIL
Test 7 (Diagonal Swipe):       PASS / FAIL

Notes:
___________________________________________
___________________________________________
___________________________________________
```

---

## Code Verification

### Changes Summary
```diff
+ Added _t_last_x tracking for X-axis movement
+ Dual-axis gesture detection (deltaX AND deltaY)
+ Scroll boundary checking
+ Explicit gesture type flags (is_tap, is_swipe_up, is_swipe_down)
```

### Lines Changed
- File: `esp32_marauder/MenuFunctions.cpp`
- Lines: 473-525 (~50 lines)
- Complexity: Low (simple boolean logic)

### Logic Verification

**Before (Buggy)**:
```cpp
if (abs(deltaY) <= 15) { tap; }  // Only checks Y axis!
```

**After (Fixed)**:
```cpp
bool is_tap = (abs(deltaX) <= 15) && (abs(deltaY) <= 15);  // Both axes!
```

**Truth Table**:
| deltaX | deltaY | is_tap | Action |
|--------|--------|--------|--------|
| ≤15px  | ≤15px  | ✅     | Execute button |
| ≤15px  | >15px  | ❌     | Scroll (vertical swipe) |
| >15px  | ≤15px  | ❌     | Nothing (horizontal swipe) |
| >15px  | >15px  | ❌     | Nothing (diagonal swipe) |

---

## Continuous Integration (CI)

### GitHub Actions
The project uses GitHub Actions for CI:

```bash
# View CI workflows
cat .github/workflows/build_parallel.yml

# View build status
# https://github.com/justcallmekoko/ESP32Marauder/actions
```

The CI builds for **18+ board targets** in parallel.

---

## Troubleshooting

### Build Failures

**Error**: `arduino-cli not found`
```bash
# Install Arduino CLI
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
```

**Error**: `Library not found`
```bash
# The build.sh script auto-installs libraries
# Make sure git is installed
sudo apt-get install git  # Debian/Ubuntu
brew install git           # macOS
```

**Error**: `Linker error - multiple definition`
```bash
# The zmuldefs patch should be applied automatically
# If manual application needed:
sed -i 's/compiler.c.elf.extra_flags=/compiler.c.elf.extra_flags=-Wl,-zmuldefs /' \
  ~/.arduino15/packages/esp32/hardware/esp32/3.3.4/platform.txt
```

### Flashing Issues

**Error**: `Failed to connect`
```bash
# Check device permissions
ls -l /dev/ttyUSB0

# Add user to dialout group (Linux)
sudo usermod -a -G dialout $USER

# Or use sudo
sudo esptool.py ...
```

**Error**: `Wrong bootloader address`
```bash
# ESP32/d32:   bootloader @ 0x1000
# ESP32-S3:     bootloader @ 0x0
# ESP32-S2:     bootloader @ 0x1000
# ESP32-C5:     bootloader @ 0x2000
```

---

## Performance Metrics

### Build Time
- Full build (with deps): ~5-10 minutes
- Incremental build: ~30-60 seconds
- CI build time: ~15-25 minutes (all targets)

### Binary Size
- V6 firmware: ~1.2 MB
- Fits in 4MB flash with room for SPIFFS

### Memory Usage
- Static variables added: +4 bytes (_t_last_x)
- No heap allocations
- Stack usage: unchanged

---

## Next Steps

### For Development
1. Install Arduino CLI
2. Run `./build.sh v6` to build
3. Flash to device
4. Run manual tests (see Test Plan above)

### For Production
1. All tests must pass
2. Verify on at least 2 different hardware variants
3. Run full CI build
4. Create pull request with test results

### For Release
1. All 18+ board targets must build
2. Test on actual hardware for each target family
3. Update version in `configs.h`
4. Tag release in Git

---

## Summary

- **Build System**: Arduino CLI with custom build.sh wrapper
- **18+ Targets**: Supported via single build script
- **Change Impact**: ~50 lines, low complexity
- **Test Coverage**: Manual hardware tests required
- **CI**: GitHub Actions builds all targets automatically

**Recommendation**: Install Arduino CLI, build for V6 target, flash to device, and run the manual test plan to verify the touchscreen fix.
