#!/usr/bin/env bash
# ESP32 Marauder local build script
# Usage: ./build.sh [target]
# Example: ./build.sh v6
#          ./build.sh cardputer
#          ./build.sh          (lists all targets)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKETCH="$SCRIPT_DIR/esp32_marauder/esp32_marauder.ino"
LIBS_DIR="${ARDUINO_LIBRARIES:-$HOME/Arduino/libraries}"
PLATFORM_BASE="$HOME/.arduino15/packages/esp32/hardware/esp32"
TFT_DIR="$LIBS_DIR/TFT_eSPI"

# ─── Target table ─────────────────────────────────────────────────────────────
# Fields: fqbn | flag | idf_ver | tft_file
declare -A FQBN FLAG IDF_VER TFT_FILE

add_target() {
  local key="$1" fqbn="$2" flag="$3" idf="$4" tft="$5"
  FQBN[$key]="$fqbn"; FLAG[$key]="$flag"; IDF_VER[$key]="$idf"; TFT_FILE[$key]="$tft"
}

add_target v4           "esp32:esp32:d32:PartitionScheme=min_spiffs"                                          MARAUDER_V4              3.3.4  User_Setup_og_marauder.h
add_target v6           "esp32:esp32:d32:PartitionScheme=min_spiffs"                                          MARAUDER_V6              3.3.4  User_Setup_og_marauder.h
add_target v6_1         "esp32:esp32:d32:PartitionScheme=min_spiffs"                                          MARAUDER_V6_1            3.3.4  User_Setup_og_marauder.h
add_target v7           "esp32:esp32:d32:PartitionScheme=min_spiffs"                                          MARAUDER_V7              3.3.4  User_Setup_dual_nrf24.h
add_target kit          "esp32:esp32:d32:PartitionScheme=min_spiffs"                                          MARAUDER_KIT             3.3.4  User_Setup_og_marauder.h
add_target mini         "esp32:esp32:d32:PartitionScheme=min_spiffs"                                          MARAUDER_MINI            3.3.4  User_Setup_marauder_mini.h
add_target lddb         "esp32:esp32:d32:PartitionScheme=min_spiffs"                                          ESP32_LDDB               3.3.4  ""
add_target dev_pro      "esp32:esp32:d32:PartitionScheme=min_spiffs"                                          MARAUDER_DEV_BOARD_PRO   3.3.4  ""
add_target flipper      "esp32:esp32:esp32s2:PartitionScheme=min_spiffs,FlashSize=4M,PSRAM=enabled"           MARAUDER_FLIPPER         2.0.11 ""
add_target multiboard_s3 "esp32:esp32:esp32s3:PartitionScheme=min_spiffs,FlashSize=4M"                        MARAUDER_MULTIBOARD_S3   2.0.11 ""
add_target rev_feather  "esp32:esp32:esp32s2:PartitionScheme=min_spiffs,FlashSize=4M,PSRAM=enabled"           MARAUDER_REV_FEATHER     2.0.11 User_Setup_marauder_rev_feather.h
add_target m5stickc     "esp32:esp32:m5stick-c:PartitionScheme=min_spiffs"                                    MARAUDER_M5STICKC        2.0.11 User_Setup_marauder_m5stickc.h
add_target m5stickcplus2 "esp32:esp32:m5stick-c:PartitionScheme=min_spiffs"                                   MARAUDER_M5STICKCP2      2.0.11 User_Setup_marauder_m5stickcp2.h
add_target cardputer    "esp32:esp32:esp32s3:PartitionScheme=min_spiffs,FlashSize=8M,PSRAM=disabled"          MARAUDER_CARDPUTER       2.0.11 User_Setup_marauder_m5cardputer.h
add_target cyd_micro    "esp32:esp32:d32:PartitionScheme=min_spiffs"                                          MARAUDER_CYD_MICRO       2.0.11 User_Setup_cyd_micro.h
add_target cyd_guition  "esp32:esp32:d32:PartitionScheme=min_spiffs"                                          MARAUDER_CYD_GUITION     2.0.11 User_Setup_cyd_guition.h
add_target cyd_2usb     "esp32:esp32:d32:PartitionScheme=min_spiffs"                                          MARAUDER_CYD_2USB        3.3.4  User_Setup_cyd_2usb.h
add_target cyd_3_5      "esp32:esp32:d32:PartitionScheme=min_spiffs"                                          MARAUDER_CYD_3_5_INCH    2.0.11 User_Setup_cyd_3_5_inch.h
add_target c5           "esp32:esp32:esp32c5:FlashSize=8M,PartitionScheme=min_spiffs,PSRAM=enabled"           MARAUDER_C5              3.3.4  ""

# ─── Helpers ──────────────────────────────────────────────────────────────────
info()  { echo "[build] $*"; }
warn()  { echo "[warn]  $*" >&2; }
die()   { echo "[error] $*" >&2; exit 1; }

list_targets() {
  echo "Available targets:"
  for key in $(echo "${!FQBN[@]}" | tr ' ' '\n' | sort); do
    printf "  %-18s  %s\n" "$key" "${FLAG[$key]}"
  done
}

# ─── Prerequisite checks ──────────────────────────────────────────────────────
check_deps() {
  if ! command -v arduino-cli &>/dev/null; then
    die "arduino-cli not found. Install with: brew install arduino-cli  (or download from https://arduino.cc/en/software#arduino-cli)"
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
  arduino-cli core update-index \
    --additional-urls "$platform_url"
  arduino-cli core install "esp32:esp32@${idf_ver}" \
    --additional-urls "$platform_url"
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
  [[ -z "$tft_file" ]] && return  # no display, nothing to do

  [[ -d "$TFT_DIR" ]] || die "TFT_eSPI not found at $TFT_DIR — run library install first."

  # Copy all User_Setup_*.h files from repo root into TFT_eSPI dir
  info "Copying User_Setup files into TFT_eSPI..."
  cp "$SCRIPT_DIR"/User_Setup_*.h "$TFT_DIR/"

  # Activate the correct setup file in User_Setup_Select.h
  local select_file="$TFT_DIR/User_Setup_Select.h"
  [[ -f "$select_file" ]] || die "User_Setup_Select.h not found in $TFT_DIR"

  # Comment out all existing active #include lines, then uncomment the right one
  # macOS sed requires '' as the backup extension
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
  [[ -d "$platform_dir" ]] || { warn "Platform dir not found: $platform_dir"; return; }

  local platform_txt
  platform_txt="$(find "$platform_dir" -maxdepth 1 -name platform.txt | head -1)"
  [[ -f "$platform_txt" ]] || { warn "platform.txt not found under $platform_dir"; return; }

  if [[ "$idf_ver" == "3.3.4" ]]; then
    if grep -q "\-Wl,-zmuldefs" "$platform_txt"; then
      info "zmuldefs patch already applied to $platform_txt"
    else
      info "Applying zmuldefs patch to $platform_txt..."
      sed -i.bak 's/compiler.c.elf.extra_flags=/compiler.c.elf.extra_flags=-Wl,-zmuldefs /' "$platform_txt"
    fi
  elif [[ "$idf_ver" == "2.0.11" ]]; then
    if grep -q "\-zmuldefs" "$platform_txt"; then
      info "zmuldefs patch already applied to $platform_txt"
    else
      info "Applying zmuldefs patch (2.0.11) to $platform_txt..."
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
  local fqbn="${FQBN[$target]}"
  local flag="${FLAG[$target]}"
  local idf_ver="${IDF_VER[$target]}"
  local tft_file="${TFT_FILE[$target]}"
  local nimble_ver
  nimble_ver="$([ "$idf_ver" = "3.3.4" ] && echo "2.3.8" || echo "1.3.8")"

  info "Target:    $target ($flag)"
  info "FQBN:      $fqbn"
  info "IDF:       $idf_ver  NimBLE: $nimble_ver"
  info "TFT file:  ${tft_file:-none}"
  echo ""

  ensure_core "$idf_ver"
  install_libs "$nimble_ver"
  configure_tft "$tft_file"
  apply_zmuldefs "$idf_ver"

  info "Building..."
  arduino-cli compile \
    --fqbn "$fqbn" \
    --libraries "$LIBS_DIR" \
    --build-property "compiler.cpp.extra_flags='-D${flag}'" \
    --warnings none \
    "$SKETCH"

  # Report output binary location
  # arduino-cli places build output under the sketch dir in build/<board>/
  local board_short
  board_short="$(echo "$fqbn" | cut -d: -f3 | cut -d: -f1)"
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
  if [[ -z "${FQBN[$target]+x}" ]]; then
    die "Unknown target: '$target'"$'\n'"$(list_targets)"
  fi

  build "$target"
}

main "$@"
