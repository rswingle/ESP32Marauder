# BUGS

- [x] v6 build cannot find wifi to join in "wifi" menu
  - Note: Verified touch-related logic prevented WIFI_CONNECTED state from being set on some touchscreen devices; setting MenuFunctions::disable_touch = true by default and ensuring WIFI_CONNECTED is set during join flow addresses the symptom. See MenuFunctions.cpp and WiFiScan.cpp for related fixes.
