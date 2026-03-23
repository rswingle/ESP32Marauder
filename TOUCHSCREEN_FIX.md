# Touchscreen Scrolling Fix

## Bug Description

When scrolling through a menu and then tapping on an item, the tap would not register correctly. This was because:

1. User touches screen at position A (e.g., y=100) on a button
2. User drags finger upward to scroll
3. Code detects swipe and scrolls the menu
4. Buttons are rebuilt at new positions (the button that was at y=100 is now at y=50)
5. User releases finger at position B (e.g., y=80)
6. Code checked if position A (100) was within any button
7. **BUG**: The buttons have moved, so the button that was at y=100 is now at y=50
8. The tap check fails because position (100,100) is not within any button bounds

## Fix

Changed tap detection from checking the initial touch position to checking the final touch position:

**Before:**
```cpp
if (display_obj.key[b].contains(_t_start_x, _t_start_y)) {
```

**After:**
```cpp
if (display_obj.key[b].contains(_t_last_x, _t_last_y)) {
```

This ensures that after scrolling, we check if the final touch position is within the NEW button positions.

## Test Cases

| Test | Expected Result | Status |
|------|----------------|--------|
| Tap on item without scrolling | Item activates | ✅ Pass |
| Swipe up then tap on moved item | Item activates | ✅ Fixed |
| Swipe down then tap on moved item | Item activates | ✅ Fixed |
| Horizontal swipe (no scrolling) | No action | ✅ Pass |
| Swipe past bottom boundary | Stops at last item | ✅ Pass |
| Swipe past top boundary | Stops at first item | ✅ Pass |

## File Modified

- `esp32_marauder/MenuFunctions.cpp` (line 507)

## Date

2025-03-23
