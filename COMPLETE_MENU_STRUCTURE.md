# ESP32 Marauder Complete Menu Structure

**Version**: v1.11.0
**Date**: 2025-03-23
**Board**: V6 (MARAUDER_V6)

---

## Main Menu

| Item | Icon | Target Menu | Description |
|------|------|-------------|-------------|
| WiFi | wifi_22.xbm | wifiMenu | WiFi scanning, attacks, and utilities |
| Bluetooth | bluetooth_22.xbm | bluetoothMenu | Bluetooth scanning and attacks |
| GPS | gps_22.xbm | gpsMenu | GPS functions (only if GPS module detected) |
| Device | device_22.xbm | deviceMenu | Device settings, info, and update |
| Reboot | reboot_22.xbm | - | Reboot the device |

---

## WiFi Menu

| Item | Icon | Target Menu/Action | Description |
|------|------|-------------------|-------------|
| Sniffers | sniff_22.xbm | wifiSnifferMenu | Packet capture and monitoring modes |
| Scanners | scan_22.xbm | wifiScannerMenu | Network scanning tools |
| **Wardriving** | - | (integrated into Sniffers) | GPS-enabled wardriving (if GPS available) |
| Attacks | attack_22.xbm | wifiAttackMenu | WiFi attack modes |
| General Apps | general_apps_22.xbm | wifiGeneralMenu | General utilities and settings |

### WiFi Sniffers Menu (wifiSnifferMenu)

| Item | Scan Mode | Description |
|------|-----------|-------------|
| EAPOL | WIFI_SCAN_EAPOL | EAPOL packet capture |
| Packet Monitor | WIFI_PACKET_MONITOR | Live packet monitoring |
| Channel Analyzer | WIFI_SCAN_CHAN_ANALYZER | Channel activity visualization |
| Channel Summary | WIFI_SCAN_CHAN_ACT | Channel activity summary |
| Raw Capture | WIFI_SCAN_RAW_CAPTURE | Raw 802.11 packet capture |
| Pwnagotchi | WIFI_SCAN_PWN | Pwnagotchi integration |
| PineAP | WIFI_SCAN_PINESCAN | PineAP detection |
| MultiSSID | WIFI_SCAN_MULTISSID | Multi-SSID detection |
| Target AP | WIFI_SCAN_TARGET_AP | Targeted AP sniffing |
| **Scan AP/STA** | WIFI_SCAN_AP_STA | Combined AP/Station scan |
| Signal Monitor | WIFI_SCAN_SIG_STREN | Signal strength monitoring |
| MAC Monitor | WIFI_SCAN_DETECT_FOLLOW | Device tracking |
| SAE Commit | WIFI_SCAN_SAE_COMMIT | SAE commit capture |
| **Wardrive** | WIFI_SCAN_WAR_DRIVE | Wardriving with GPS (if available) |

### WiFi Scanners Menu (wifiScannerMenu)

| Item | Scan Mode | Description |
|------|-----------|-------------|
| Ping Scan | WIFI_PING_SCAN | ICMP ping scan |
| ARP Scan | WIFI_ARP_SCAN | ARP scan (not available on dual-band) |
| Port Scan All | WIFI_PORT_SCAN_ALL | Port scan all active IPs |
| SSH Scan | WIFI_SCAN_SSH | SSH service detection |
| Service Detect | WIFI_SCAN_SERVICE | Full service detection |

### WiFi Attack Menu (wifiAttackMenu)

| Item | Attack Mode | Description |
|------|-------------|-------------|
| Beacon List | WIFI_ATTACK_BEACION_LIST | Attack from discovered AP list |
| Beacon Spam | WIFI_ATTACK_BEACON_SPAM | Random beacon spam |
| Funny Beacon | WIFI_ATTACK_FUNNY_BEACON | Funny beacon names |
| Rick Roll | WIFI_ATTACK_RICK_ROLL | Rick Roll beacon spam |
| Auth | WIFI_ATTACK_AUTH | Authentication DoS |
| **Evil Portal** | WIFI_SCAN_EVIL_PORTAL | Captive portal attack |
| Deauth | WIFI_ATTACK_DEAUTH | Deauthentication attack |
| AP Spam | WIFI_ATTACK_AP_SPAM | AP spam attack |
| Targeted Deauth | WIFI_ATTACK_DEAUTH_TARGETED | Targeted deauth |
| **Karma** | WIFI_SCAN_EVIL_PORTAL | Karma attack (probe response) |
| Bad Msg | WIFI_ATTACK_BAD_MSG | Malformed message attack |
| Targeted Bad Msg | WIFI_ATTACK_BAD_MSG_TARGETED | Targeted malformed message |
| Assoc Sleep | WIFI_ATTACK_SLEEP | Association flood |
| Targeted Assoc Sleep | WIFI_ATTACK_SLEEP_TARGETED | Targeted association flood |
| SAE Commit Flood | WIFI_ATTACK_SAE_COMMIT | SAE commit flood |
| Channel Switch | WIFI_ATTACK_CSA | Channel switch attack |
| Quiet Time | WIFI_ATTACK_QUIET | Quiet time attack |

### WiFi General Menu (wifiGeneralMenu)

| Item | Action | Description |
|------|--------|-------------|
| Generate SSIDs | generateSSIDsMenu | Generate random SSIDs |
| **Select Probe SSIDs** | selectProbeSSIDsMenu | Select from captured probe requests |
| **Add SSID** | - | Manually add SSID via keyboard |
| **Join WiFi** | wifiAPMenu | **Connect to WiFi network** |
| **Join Saved WiFi** | - | **Connect to saved network** |
| Clear SSIDs | clearSSIDsMenu | Clear generated SSID list |
| Clear APs | clearAPsMenu | Clear discovered AP list |
| Clear Stations | - | Clear discovered stations |
| Select EP HTML File | htmlMenu | Select Evil Portal HTML file |
| Select APs | wifiAPMenu | Select from discovered APs |
| View AP Info | apInfoMenu | View detailed AP information |
| Select Stations | wifiStationMenu | Select from discovered stations |
| Save/Load Files | saveFileMenu | Save/load settings to SD |
| Set MACs | setMacMenu | Set random MAC addresses |
| Shutdown WiFi | - | Disable WiFi radio |

---

## Bluetooth Menu

| Item | Icon | Target Menu/Action | Description |
|------|------|-------------------|-------------|
| Sniffers | bluetooth_sniff_22.xbm | bluetoothSnifferMenu | Bluetooth capture modes |
| Attacks | - | bluetoothAttackMenu | Bluetooth attack modes |

### Bluetooth Sniffers Menu

| Item | Scan Mode | Description |
|------|-----------|-------------|
| All Devices | BT_SCAN_ALL | Scan all BT devices |
| Skimmers | BT_SCAN_SKIMMERS | Detect skimming devices |
| Airtag | BT_SCAN_AIRTAG | Detect Apple AirTags |
| Flipper | BT_SCAN_FLIPPER | Detect Flipper Zero |
| Flock | BT_SCAN_FLOCK | Detect Flock boards |
| Simple | BT_SCAN_SIMPLE | Simple BT scan |
| Sniff | BT_SNIFF | Bluetooth packet sniffing |

### Bluetooth Attack Menu

| Item | Attack Mode | Description |
|------|-------------|-------------|
| Swiftpair Spam | BT_ATTACK_SWIFTPAIR | Swiftpair spam |
| Sour Apple | BT_ATTACK_SOUR_APPLE | Sour Apple attack |
| Samsung Spam | BT_ATTACK_SAMSUNG_SPAM | Samsung spam |
| Google Spam | BT_ATTACK_GOOGLE_SPAM | Google spam |
| Flipper Spam | BT_ATTACK_FLIPPER_SPAM | Flipper spam |

---

## GPS Menu (gpsMenu)
*Only shown if GPS module is detected*

| Item | Action | Description |
|------|--------|-------------|
| GPS Data | WIFI_SCAN_GPS_DATA | View current GPS data |
| NMEA Stream | WIFI_SCAN_GPS_NMEA | Raw NMEA output |
| GPS Tracker | GPS_TRACKER | GPS tracking mode |
| GPS POI | GPS_POI | Point of Interest marking |

### GPS POI Menu (gpsPOIMenu)

| Item | Action | Description |
|------|--------|-------------|
| Mark POI | - | Mark current location as POI |

---

## Device Menu

| Item | Icon | Target Menu/Action | Description |
|------|------|-------------------|-------------|
| Settings | settings_22.bmp | settingsMenu | Device settings |
| Info | device_info_22.xbm | infoMenu | Device information |
| Update | update_22.xbm | updateMenu | Update firmware |

### Settings Menu

Dynamic list of boolean settings from SPIFFS.

---

## Key Features Confirmed Present

✅ **WiFi Connection**: "Join WiFi" and "Join Saved WiFi" in WiFi General menu
✅ **GPS Section**: Full GPS menu with Data, NMEA, Tracker, and POI
✅ **All Attacks**: Complete attack menu with 20+ attack modes
✅ **Wardriving**: Integrated into Sniffers menu (when GPS available)
✅ **Station Scan**: "Scan AP/STA" in Sniffers menu
✅ **AP Scan**: Multiple scan modes including AP discovery

---

## Menu Navigation

- **Touch**: Tap directly on any button to activate
- **Swipe Up**: Scroll down in menu (show items below)
- **Swipe Down**: Scroll up in menu (show items above)
- **Back Button**: Returns to previous menu

---

## Notes

- All menus support up to BUTTON_SCREEN_LIMIT items visible at once
- Scrolling indicators (triangles) appear at right edge when more items exist
- Menu items with icons use 22x22 XBM format
- Color coding indicates function type (Red=attacks, Green=scanning, etc.)

---

**Report Generated**: 2025-03-23
**Status**: All features verified and documented
