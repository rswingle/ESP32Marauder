#!/usr/bin/env bash
set -euo pipefail

# scripts/verify_builds.sh
# Small helper to verify Arduino CLI build commands for a representative board.
# Supports --board <flag> and --dry-run to print commands without executing.

DRY_RUN=0
BOARD_FLAG="MARAUDER_V6"
FQBN="esp32:esp32:d32:PartitionScheme=min_spiffs"
PLATFORM_URL="https://github.com/espressif/arduino-esp32/releases/download/3.3.4/package_esp32_dev_index.json"

# Prefer repository-local arduino-cli if present (installed by CI or by installer script)
if [[ -x "${PWD}/bin/arduino-cli" ]]; then
  ARDUINO_CLI="${PWD}/bin/arduino-cli"
else
  ARDUINO_CLI="arduino-cli"
fi

usage() {
  cat <<EOF
Usage: $0 [--board FLAG] [--fqbn FQBN] [--platform-url URL] [--dry-run]

Options:
  --board FLAG        Build flag to pass as -D (default: MARAUDER_V6)
  --fqbn FQBN         Arduino board FQBN (default: $FQBN)
  --platform-url URL  Platform URL for arduino-esp32 (default points to IDF 3.3.4)
  --dry-run           Print commands instead of executing
  -h, --help          Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --board) BOARD_FLAG="$2"; shift 2 ;;
    --fqbn) FQBN="$2"; shift 2 ;;
    --platform-url) PLATFORM_URL="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 2 ;;
  esac
done

echo "verify_builds: board_flag=$BOARD_FLAG fqbn=$FQBN platform_url=$PLATFORM_URL dry_run=$DRY_RUN"

CMD_COMPILE=("$ARDUINO_CLI" compile --fqbn "$FQBN" --build-property "compiler.cpp.extra_flags=-D$BOARD_FLAG" esp32_marauder/esp32_marauder.ino)

run_arduino_core_update() {
  "$ARDUINO_CLI" core update-index --additional-urls "$PLATFORM_URL"
}

run_arduino_core_install() {
  "$ARDUINO_CLI" core install esp32:esp32@3.3.4 --additional-urls "$PLATFORM_URL"
}

install_libraries() {
  echo "Installing pinned libraries from INSTALL.md"
  # List from INSTALL.md (best-effort pinned names/versions)
  libs=(
    "ESP32Ping@1.6"
    "AsyncTCP@3.4.8"
    "ESPAsyncWebServer@3.8.1"
    "MicroNMEA@2.0.6"
    "TFT_eSPI@V2.5.34"
    "XPT2046_Touchscreen@1.4"
    "lv_arduino@3.0.0"
    "JPEGDecoder@1.8.0"
    "NimBLE-Arduino@2.3.8"
    "Adafruit_NeoPixel@1.12.0"
    "ArduinoJson@6.18.2"
    "LinkedList@1.3.3"
    "espsoftwareserial@8.1.0"
    "Adafruit_BusIO@1.15.0"
    "Adafruit_MAX1704X@1.0.2"
  )

  for l in "${libs[@]}"; do
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "+ $ARDUINO_CLI lib install \"$l\""
    else
      echo "Installing $l"
      if ! $ARDUINO_CLI lib install "$l"; then
        echo "Warning: failed to install $l via arduino-cli. Trying git clone fallback..."
        # Attempt git-clone fallback for known libraries
        git_clone_fallback "$l"
      fi
    fi
  done
}

git_clone_fallback() {
  local lib_spec="$1"
  local name="${lib_spec%%@*}"
  local repo=""
  local branch=""
  case "$name" in
    ESP32Ping)
      repo="https://github.com/marian-craciunescu/ESP32Ping.git"; branch="1.6" ;;
    AsyncTCP)
      repo="https://github.com/ESP32Async/AsyncTCP.git"; branch="v3.4.8" ;;
    ESPAsyncWebServer)
      repo="https://github.com/ESP32Async/ESPAsyncWebServer.git"; branch="v3.8.1" ;;
    TFT_eSPI)
      repo="https://github.com/Bodmer/TFT_eSPI.git"; branch="V2.5.34" ;;
    Adafruit_NeoPixel)
      repo="https://github.com/adafruit/Adafruit_NeoPixel.git"; branch="1.12.0" ;;
    Adafruit_BusIO)
      repo="https://github.com/adafruit/Adafruit_BusIO.git"; branch="1.15.0" ;;
    Adafruit_MAX1704X)
      repo="https://github.com/adafruit/Adafruit_MAX1704X.git"; branch="1.0.2" ;;
    *)
      echo "No git fallback mapping for $name"
      return 1
      ;;
  esac

  LIB_DIR="$HOME/Documents/Arduino/libraries"
  mkdir -p "$LIB_DIR"
  dest="$LIB_DIR/$(basename "$repo" .git)"
  if [[ -d "$dest" ]]; then
    echo "Library already present at $dest"
    return 0
  fi
  echo "Cloning $repo (branch $branch) into $dest"
  if git clone --depth 1 --branch "$branch" "$repo" "$dest"; then
    echo "Cloned $name -> $dest"
    return 0
  else
    echo "Git clone fallback failed for $name"
    return 2
  fi
}

copy_user_setup_to_tft_espi() {
  # Copy repository User_Setup files into the installed TFT_eSPI library to match CI
  TFT_LIB_DIR="$HOME/Documents/Arduino/libraries/TFT_eSPI"
  if [[ ! -d "$TFT_LIB_DIR" ]]; then
    echo "TFT_eSPI library not found at $TFT_LIB_DIR; skipping User_Setup copy"
    return 1
  fi

  # Prefer OG marauder setup for default build flag
  SRC_SETUP_FILE="$PWD/User_Setup_og_marauder.h"
  if [[ -f "$SRC_SETUP_FILE" ]]; then
    echo "Copying $SRC_SETUP_FILE to $TFT_LIB_DIR/"
    cp "$SRC_SETUP_FILE" "$TFT_LIB_DIR/"
    # Ensure User_Setup_Select.h includes the OG marauder setup
    SELECT_FILE="$TFT_LIB_DIR/User_Setup_Select.h"
    if [[ -f "$SELECT_FILE" ]]; then
      if ! grep -q "User_Setup_og_marauder.h" "$SELECT_FILE"; then
        echo "#include <User_Setup_og_marauder.h>" >> "$SELECT_FILE"
      fi
      # Uncomment the include if present but commented
      sed -i.bak 's|//\s*#include <User_Setup_og_marauder.h>|#include <User_Setup_og_marauder.h>|' "$SELECT_FILE" || true
    fi
    return 0
  else
    echo "No source User_Setup_og_marauder.h in repo; skipping"
    return 2
  fi
}

run_cmd() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "+ $*"
  else
    echo "Running: $*"
    eval "$*"
  fi
}

# Print commands
run_cmd "run_arduino_core_update"
run_cmd "run_arduino_core_install"
run_cmd "install_libraries"
run_cmd "${CMD_COMPILE[*]}"

echo "verify_builds: done (dry_run=$DRY_RUN). To actually run builds, rerun without --dry-run and ensure arduino-cli is installed."
