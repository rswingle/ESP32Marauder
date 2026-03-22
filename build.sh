#!/usr/bin/env bash
# ESP32 Marauder local build script
# Usage: ./build.sh [target]
# Example: ./build.sh v6
#          ./build.sh cardputer
#          ./build.sh          (lists all targets)
#
# Compatible with Bash 3.x (macOS default).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKETCH="$SCRIPT_DIR/esp32_marauder/esp32_marauder.ino"
LIBS_DIR="${ARDUINO_LIBRARIES:-$HOME/Arduino/libraries}"
PLATFORM_BASE="$HOME/.arduino15/packages/esp32/hardware/esp32"
TFT_DIR="$LIBS_DIR/TFT_eSPI"

# ─── Helpers ──────────────────────────────────────────────────────────────────
info()  { echo "[build] $*"; }
warn()  { echo "[warn]  $*" >&2; }
die()   { echo "[error] $*" >&2; exit 1; }

# ─── Target table (Bash 3.x compatible — no associative arrays) ───────────────
# Sets TARGET_FQBN, TARGET_FLAG, TARGET_IDF, TARGET_TFT for a given target name.
# Returns 1 for unknown targets.
get_target_params() {
  local target="$1"
  case "$target" in
    v4)
      TARGET_FQBN="esp32:esp32:d32:PartitionScheme=min_spiffs"
      TARGET_FLAG="MARAUDER_V4"
      TARGET_IDF="3.3.4"
      TARGET_TFT="User_Setup_og_marauder.h"
      ;;
    v6)
      TARGET_FQBN="esp32:esp32:d32:PartitionScheme=min_spiffs"
      TARGET_FLAG="MARAUDER_V6"
      TARGET_IDF="3.3.4"
      TARGET_TFT="User_Setup_og_marauder.h"
      ;;
    v6_1)
      TARGET_FQBN="esp32:esp32:d32:PartitionScheme=min_spiffs"
      TARGET_FLAG="MARAUDER_V6_1"
      TARGET_IDF="3.3.4"
      TARGET_TFT="User_Setup_og_marauder.h"
      ;;
    v7)
      TARGET_FQBN="esp32:esp32:d32:PartitionScheme=min_spiffs"
      TARGET_FLAG="MARAUDER_V7"
      TARGET_IDF="3.3.4"
      TARGET_TFT="User_Setup_dual_nrf24.h"
      ;;
    kit)
      TARGET_FQBN="esp32:esp32:d32:PartitionScheme=min_spiffs"
      TARGET_FLAG="MARAUDER_KIT"
      TARGET_IDF="3.3.4"
      TARGET_TFT="User_Setup_og_marauder.h"
      ;;
    mini)
      TARGET_FQBN="esp32:esp32:d32:PartitionScheme=min_spiffs"
      TARGET_FLAG="MARAUDER_MINI"
      TARGET_IDF="3.3.4"
      TARGET_TFT="User_Setup_marauder_mini.h"
      ;;
    lddb)
      TARGET_FQBN="esp32:esp32:d32:PartitionScheme=min_spiffs"
      TARGET_FLAG="ESP32_LDDB"
      TARGET_IDF="3.3.4"
      TARGET_TFT=""
      ;;
    dev_pro)
      TARGET_FQBN="esp32:esp32:d32:PartitionScheme=min_spiffs"
      TARGET_FLAG="MARAUDER_DEV_BOARD_PRO"
      TARGET_IDF="3.3.4"
      TARGET_TFT=""
      ;;
    flipper)
      TARGET_FQBN="esp32:esp32:esp32s2:PartitionScheme=min_spiffs,FlashSize=4M,PSRAM=enabled"
      TARGET_FLAG="MARAUDER_FLIPPER"
      TARGET_IDF="2.0.11"
      TARGET_TFT=""
      ;;
    multiboard_s3)
      TARGET_FQBN="esp32:esp32:esp32s3:PartitionScheme=min_spiffs,FlashSize=4M"
      TARGET_FLAG="MARAUDER_MULTIBOARD_S3"
      TARGET_IDF="2.0.11"
      TARGET_TFT=""
      ;;
    rev_feather)
      TARGET_FQBN="esp32:esp32:esp32s2:PartitionScheme=min_spiffs,FlashSize=4M,PSRAM=enabled"
      TARGET_FLAG="MARAUDER_REV_FEATHER"
      TARGET_IDF="2.0.11"
      TARGET_TFT="User_Setup_marauder_rev_feather.h"
      ;;
    m5stickc)
      TARGET_FQBN="esp32:esp32:m5stick-c:PartitionScheme=min_spiffs"
      TARGET_FLAG="MARAUDER_M5STICKC"
      TARGET_IDF="2.0.11"
      TARGET_TFT="User_Setup_marauder_m5stickc.h"
      ;;
    m5stickcplus2)
      TARGET_FQBN="esp32:esp32:m5stick-c:PartitionScheme=min_spiffs"
      TARGET_FLAG="MARAUDER_M5STICKCP2"
      TARGET_IDF="2.0.11"
      TARGET_TFT="User_Setup_marauder_m5stickcp2.h"
      ;;
    cardputer)
      TARGET_FQBN="esp32:esp32:esp32s3:PartitionScheme=min_spiffs,FlashSize=8M,PSRAM=disabled"
      TARGET_FLAG="MARAUDER_CARDPUTER"
      TARGET_IDF="2.0.11"
      TARGET_TFT="User_Setup_marauder_m5cardputer.h"
      ;;
    cyd_micro)
      TARGET_FQBN="esp32:esp32:d32:PartitionScheme=min_spiffs"
      TARGET_FLAG="MARAUDER_CYD_MICRO"
      TARGET_IDF="2.0.11"
      TARGET_TFT="User_Setup_cyd_micro.h"
      ;;
    cyd_guition)
      TARGET_FQBN="esp32:esp32:d32:PartitionScheme=min_spiffs"
      TARGET_FLAG="MARAUDER_CYD_GUITION"
      TARGET_IDF="2.0.11"
      TARGET_TFT="User_Setup_cyd_guition.h"
      ;;
    cyd_2usb)
      TARGET_FQBN="esp32:esp32:d32:PartitionScheme=min_spiffs"
      TARGET_FLAG="MARAUDER_CYD_2USB"
      TARGET_IDF="3.3.4"
      TARGET_TFT="User_Setup_cyd_2usb.h"
      ;;
    cyd_3_5)
      TARGET_FQBN="esp32:esp32:d32:PartitionScheme=min_spiffs"
      TARGET_FLAG="MARAUDER_CYD_3_5_INCH"
      TARGET_IDF="2.0.11"
      TARGET_TFT="User_Setup_cyd_3_5_inch.h"
      ;;
    c5)
      TARGET_FQBN="esp32:esp32:esp32c5:FlashSize=8M,PartitionScheme=min_spiffs,PSRAM=enabled"
      TARGET_FLAG="MARAUDER_C5"
      TARGET_IDF="3.3.4"
      TARGET_TFT=""
      ;;
    *)
      return 1
      ;;
  esac
}

list_targets() {
  echo "Available targets:"
  printf "  %-18s  %s\n" "v4"           "MARAUDER_V4              (IDF 3.3.4)"
  printf "  %-18s  %s\n" "v6"           "MARAUDER_V6              (IDF 3.3.4)  <-- most common"
  printf "  %-18s  %s\n" "v6_1"         "MARAUDER_V6_1            (IDF 3.3.4)"
  printf "  %-18s  %s\n" "v7"           "MARAUDER_V7              (IDF 3.3.4)"
  printf "  %-18s  %s\n" "kit"          "MARAUDER_KIT             (IDF 3.3.4)"
  printf "  %-18s  %s\n" "mini"         "MARAUDER_MINI            (IDF 3.3.4)"
  printf "  %-18s  %s\n" "lddb"         "ESP32_LDDB               (IDF 3.3.4)"
  printf "  %-18s  %s\n" "dev_pro"      "MARAUDER_DEV_BOARD_PRO   (IDF 3.3.4)"
  printf "  %-18s  %s\n" "flipper"      "MARAUDER_FLIPPER         (IDF 2.0.11)"
  printf "  %-18s  %s\n" "multiboard_s3" "MARAUDER_MULTIBOARD_S3  (IDF 2.0.11)"
  printf "  %-18s  %s\n" "rev_feather"  "MARAUDER_REV_FEATHER     (IDF 2.0.11)"
  printf "  %-18s  %s\n" "m5stickc"     "MARAUDER_M5STICKC        (IDF 2.0.11)"
  printf "  %-18s  %s\n" "m5stickcplus2" "MARAUDER_M5STICKCP2     (IDF 2.0.11)"
  printf "  %-18s  %s\n" "cardputer"    "MARAUDER_CARDPUTER       (IDF 2.0.11)"
  printf "  %-18s  %s\n" "cyd_micro"    "MARAUDER_CYD_MICRO       (IDF 2.0.11)"
  printf "  %-18s  %s\n" "cyd_guition"  "MARAUDER_CYD_GUITION     (IDF 2.0.11)"
  printf "  %-18s  %s\n" "cyd_2usb"     "MARAUDER_CYD_2USB        (IDF 3.3.4)"
  printf "  %-18s  %s\n" "cyd_3_5"      "MARAUDER_CYD_3_5_INCH    (IDF 2.0.11)"
  printf "  %-18s  %s\n" "c5"           "MARAUDER_C5              (IDF 3.3.4)"
}

# ─── Prerequisite checks ──────────────────────────────────────────────────────
check_deps() {
  if ! command -v arduino-cli &>/dev/null; then
    die "arduino-cli not found. Install with: brew install arduino-cli"
  fi
}

# ─── ESP32 core install ───────────────────────────────────────────────────────
ensure_core() {
  local idf_ver="$1"
  local platform_url="https://github.com/espressif/arduino-esp32/releases/download/${idf_ver}/package_esp32_dev_index.json"

  if arduino-cli core list 2>/dev/null | grep -q "esp32:esp32.*${idf_ver}"; then
    info "ESP32 core ${idf_ver} already installed."
    return
  fi

  info "Installing ESP32 core ${idf_ver}..."
  arduino-cli core update-index --additional-urls "$platform_url"
  arduino-cli core install "esp32:esp32@${idf_ver}" --additional-urls "$platform_url"
}

# ─── Library install (git clone into ~/Arduino/libraries) ─────────────────────
ensure_lib() {
  local name="$1" repo="$2" ref="$3"
  local dest="$LIBS_DIR/$name"
  if [[ -d "$dest" ]]; then
    info "Library $name already present, skipping."
    return
  fi
  info "Cloning $name @ $ref..."
  mkdir -p "$LIBS_DIR"
  git clone --depth 1 --branch "$ref" "https://github.com/${repo}" "$dest"
}

install_libs() {
  local nimble_ver="$1"

  ensure_lib ESP32Ping            marian-craciunescu/ESP32Ping          1.6
  ensure_lib AsyncTCP             ESP32Async/AsyncTCP                   v3.4.8
  ensure_lib ESPAsyncWebServer    ESP32Async/ESPAsyncWebServer          v3.8.1
  ensure_lib MicroNMEA            stevemarple/MicroNMEA                 v2.0.6
  ensure_lib TFT_eSPI             Bodmer/TFT_eSPI                       V2.5.34
  ensure_lib XPT2046_Touchscreen  PaulStoffregen/XPT2046_Touchscreen    v1.4
  ensure_lib lv_arduino           lvgl/lv_arduino                       3.0.0
  ensure_lib JPEGDecoder          Bodmer/JPEGDecoder                    1.8.0
  ensure_lib NimBLE-Arduino       h2zero/NimBLE-Arduino                 "$nimble_ver"
  ensure_lib Adafruit_NeoPixel    adafruit/Adafruit_NeoPixel            1.12.0
  ensure_lib ArduinoJson          bblanchon/ArduinoJson                 v6.18.2
  ensure_lib LinkedList           ivanseidel/LinkedList                 v1.3.3
  ensure_lib EspSoftwareSerial    plerup/espsoftwareserial              8.1.0
  ensure_lib Adafruit_BusIO       adafruit/Adafruit_BusIO               1.15.0
  ensure_lib Adafruit_MAX1704X    adafruit/Adafruit_MAX1704X            1.0.2
}

# ─── TFT_eSPI configuration ───────────────────────────────────────────────────
configure_tft() {
  local tft_file="$1"
  [[ -z "$tft_file" ]] && return  # headless target, nothing to do

  [[ -d "$TFT_DIR" ]] || die "TFT_eSPI not found at $TFT_DIR — run library install first."

  info "Copying User_Setup files into TFT_eSPI..."
  cp "$SCRIPT_DIR"/User_Setup_*.h "$TFT_DIR/"

  local select_file="$TFT_DIR/User_Setup_Select.h"
  [[ -f "$select_file" ]] || die "User_Setup_Select.h not found in $TFT_DIR"

  # Comment out all active #include lines, then uncomment the target one.
  # macOS sed requires an explicit (empty) backup extension with -i.
  sed -i.bak 's|^#include <User_Setup|//#include <User_Setup|g' "$select_file"
  sed -i.bak "s|^//#include <${tft_file}>|#include <${tft_file}>|" "$select_file"

  if grep -q "^#include <${tft_file}>" "$select_file"; then
    info "TFT_eSPI configured for ${tft_file}."
  else
    die "Failed to activate ${tft_file} in User_Setup_Select.h"
  fi
}

# ─── zmuldefs linker patch ────────────────────────────────────────────────────
apply_zmuldefs() {
  local idf_ver="$1"
  local platform_dir="$PLATFORM_BASE/$idf_ver"
  [[ -d "$platform_dir" ]] || { warn "Platform dir not found: $platform_dir (skip zmuldefs)"; return; }

  local platform_txt
  platform_txt="$(find "$platform_dir" -maxdepth 1 -name platform.txt | head -1)"
  [[ -f "$platform_txt" ]] || { warn "platform.txt not found (skip zmuldefs)"; return; }

  if [[ "$idf_ver" == "3.3.4" ]]; then
    if grep -q "\-Wl,-zmuldefs" "$platform_txt"; then
      info "zmuldefs patch already applied."
    else
      info "Applying zmuldefs patch to platform.txt..."
      sed -i.bak 's/compiler.c.elf.extra_flags=/compiler.c.elf.extra_flags=-Wl,-zmuldefs /' "$platform_txt"
    fi
  elif [[ "$idf_ver" == "2.0.11" ]]; then
    if grep -q "\-zmuldefs" "$platform_txt"; then
      info "zmuldefs patch already applied."
    else
      info "Applying zmuldefs patch (2.0.11) to platform.txt..."
      for field in compiler.c.elf.libs.esp32c3 compiler.c.elf.libs.esp32s3 \
                   compiler.c.elf.libs.esp32s2 compiler.c.elf.libs.esp32; do
        sed -i.bak "s/${field}=/${field}=-zmuldefs /" "$platform_txt"
      done
    fi
  fi
}

# ─── Build ────────────────────────────────────────────────────────────────────
build() {
  local target="$1"

  get_target_params "$target"  # sets TARGET_FQBN TARGET_FLAG TARGET_IDF TARGET_TFT

  local nimble_ver
  if [[ "$TARGET_IDF" == "3.3.4" ]]; then
    nimble_ver="2.3.8"
  else
    nimble_ver="1.3.8"
  fi

  info "Target:    $target ($TARGET_FLAG)"
  info "FQBN:      $TARGET_FQBN"
  info "IDF:       $TARGET_IDF  NimBLE: $nimble_ver"
  info "TFT file:  ${TARGET_TFT:-none}"
  echo ""

  ensure_core "$TARGET_IDF"
  install_libs "$nimble_ver"
  configure_tft "$TARGET_TFT"
  apply_zmuldefs "$TARGET_IDF"

  info "Building..."
  arduino-cli compile \
    --fqbn "$TARGET_FQBN" \
    --libraries "$LIBS_DIR" \
    --build-property "compiler.cpp.extra_flags='-D${TARGET_FLAG}'" \
    --warnings none \
    "$SKETCH"

  # arduino-cli places output under sketch/build/<board>/
  local board_short
  board_short="$(echo "$TARGET_FQBN" | cut -d: -f3 | cut -d: -f1)"
  local build_dir="$SCRIPT_DIR/esp32_marauder/build/esp32.esp32.${board_short}"
  local bin="$build_dir/esp32_marauder.ino.bin"

  echo ""
  info "Build complete."
  if [[ -f "$bin" ]]; then
    info "Binary: $bin"
    info "Size:   $(du -sh "$bin" | cut -f1)"
  else
    info "Build output dir: $build_dir"
  fi
}

# ─── Entrypoint ───────────────────────────────────────────────────────────────
main() {
  check_deps

  if [[ $# -eq 0 ]]; then
    list_targets
    echo ""
    echo "Usage: $0 <target>"
    echo "Example: $0 v6"
    exit 0
  fi

  local target="$1"
  if ! get_target_params "$target" 2>/dev/null; then
    echo "[error] Unknown target: '$target'" >&2
    echo "" >&2
    list_targets >&2
    exit 1
  fi

  build "$target"
}

main "$@"
