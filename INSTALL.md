# INSTALL.md

This file contains handy arduino-cli commands to set up the environment and install the libraries used by this project.

1) Install Arduino CLI (follow official docs):

```bash
# macOS / Linux example
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
export PATH="$HOME/bin:$PATH"
arduino-cli version
```

2) Install ESP32 core (example for IDF 3.3.4 used by d32 targets):

```bash
arduino-cli core update-index \
  --additional-urls https://github.com/espressif/arduino-esp32/releases/download/3.3.4/package_esp32_dev_index.json

arduino-cli core install esp32:esp32@3.3.4 \
  --additional-urls https://github.com/espressif/arduino-esp32/releases/download/3.3.4/package_esp32_dev_index.json
```

3) Install project libraries via arduino-cli (prefer pinned versions matching CI):

```bash
arduino-cli lib install "ESP32Ping@1.6"
arduino-cli lib install "AsyncTCP@3.4.8"
arduino-cli lib install "ESPAsyncWebServer@3.8.1"
arduino-cli lib install "MicroNMEA@2.0.6"
arduino-cli lib install "TFT_eSPI@V2.5.34"
arduino-cli lib install "XPT2046_Touchscreen@1.4"
arduino-cli lib install "lv_arduino@3.0.0"
arduino-cli lib install "JPEGDecoder@1.8.0"
arduino-cli lib install "NimBLE-Arduino@2.3.8"
arduino-cli lib install "Adafruit_NeoPixel@1.12.0"
arduino-cli lib install "ArduinoJson@6.18.2"
arduino-cli lib install "LinkedList@1.3.3"
arduino-cli lib install "espsoftwareserial@8.1.0"
arduino-cli lib install "Adafruit_BusIO@1.15.0"
arduino-cli lib install "Adafruit_MAX1704X@1.0.2"
```

Notes:
- Some libraries are referenced by GitHub ref/branch in CI; arduino-cli may not have the exact tags for all repos. If lib install fails, clone the specific repo at the pinned tag into your libraries folder as shown in README.
- To replicate CI precisely, clone the referenced repositories into a `Custom*` directory and point builds to that folder.
