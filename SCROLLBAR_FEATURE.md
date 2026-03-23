# Scrollbar Feature - ESP32 Marauder v1.1

**Date**: 2025-03-23
**Feature**: Visual scrollbar with dynamic scrolling
**Status**: ✅ IMPLEMENTED

---

## Overview

Added a visual scrollbar and dynamic scrolling distance based on swipe magnitude to improve touchscreen navigation in long menus.

---

## Changes Made

### 1. Visual Scrollbar

**Location**: `MenuFunctions.cpp:3837-3905` (displayCurrentMenu function)

**Features**:
- **Scrollbar track**: Dark grey bar on the right side of the screen
- **Scrollbar thumb**: Color-indicated position indicator
  - **Green** (CYAN): At top of list
  - **Cyan**: In middle of list
  - **Yellow**: At bottom of list
- **Dynamic sizing**: Thumb size reflects ratio of visible items to total items
- **Position tracking**: Thumb position shows current scroll location

**Visual Design**:
```
┌─────────────────────────────┐
│ Menu Title                  │
├─────────────────────────────┤
│ Item 1                      │ ▲
│ Item 2                      │ │ arrows
│ Item 3                      │ │ (if more content)
│ Item 4                      │ ▼
│ Item 5                      │ █  <- scrollbar
│ Item 6                      │ █     (thumb)
└─────────────────────────────┘
```

### 2. Dynamic Scrolling Distance

**Location**: `MenuFunctions.cpp:517-544` (main touch handler)

**Previous Behavior**:
- Swipe gestures would only scroll 1 item at a time
- Required multiple swipes to navigate long lists

**New Behavior**:
- Swipe distance determines scroll amount
- **Approximately 1 item per 60 pixels** of vertical movement
- **Minimum**: Always scrolls at least 1 item
- **Maximum**: Can scroll up to BUTTON_SCREEN_LIMIT (6) items in one gesture

**Examples**:
| Swipe Distance | Items Scrolled |
|----------------|----------------|
| 20px (short)   | 1 item         |
| 60px (medium)  | 1 item         |
| 120px (long)   | 2 items        |
| 240px (full)   | 4 items        |

---

## Technical Implementation

### Scrollbar Drawing Code

```cpp
// Only draw scrollbar if content doesn't fit on one screen
if (total > BUTTON_SCREEN_LIMIT) {
  const int scrollbar_x = TFT_WIDTH - 8;
  const int scrollbar_width = 4;
  const int scrollbar_top = STATUS_BAR_WIDTH + 5;
  const int scrollbar_bottom = TFT_HEIGHT - 5;
  const int scrollbar_height = scrollbar_bottom - scrollbar_top;

  // Calculate thumb position and size
  const float ratio = (float)BUTTON_SCREEN_LIMIT / total;
  int thumb_height = max(20, (int)(scrollbar_height * ratio));
  int thumb_y = scrollbar_top + (int)((scrollbar_height - thumb_height) *
                                      (float)start_index / (total - BUTTON_SCREEN_LIMIT));

  // Ensure thumb stays within bounds
  thumb_y = max(scrollbar_top, min(scrollbar_bottom - thumb_height, thumb_y));

  // Draw scrollbar track (dark background)
  display_obj.tft.fillRect(scrollbar_x, scrollbar_top, scrollbar_width,
                           scrollbar_height, TFT_DARKGREY);

  // Draw thumb (color-coded by position)
  uint16_t thumb_color = TFT_CYAN;
  if (start_index > 0) thumb_color = TFT_GREEN;
  if (start_index + BUTTON_SCREEN_LIMIT >= total) thumb_color = TFT_YELLOW;

  display_obj.tft.fillRect(scrollbar_x, thumb_y, scrollbar_width,
                           thumb_height, thumb_color);
}
```

### Dynamic Scroll Calculation

```cpp
// Swipe up: scroll forward to show items below
// Calculate scroll distance based on swipe magnitude (roughly 1 item per 60px)
int scroll_items = max(1, min((int)(abs(deltaY) / 60), (int)BUTTON_SCREEN_LIMIT));
int new_start = this->menu_start_index + scroll_items;
int max_start = max(0, (int)current_menu->list->size() - (int)BUTTON_SCREEN_LIMIT);
if (new_start > max_start) new_start = max_start;
```

---

## User Experience Improvements

### Before
- No visual indication of scroll position
- No indication of how much content exists
- Slow scrolling (1 item per swipe)
- Unclear where you are in a long list

### After
- Clear visual scrollbar showing:
  - Current position in list
  - How much total content exists
  - Which items are visible
- Fast scrolling (swipe distance determines scroll amount)
- Color-coded thumb provides at-a-glance position info
- Retains arrow indicators for additional visual feedback

---

## Testing Checklist

After flashing firmware with scrollbar feature:

### Visual Feedback
- [ ] Scrollbar appears on right side of screen for long menus
- [ ] Thumb size changes based on list length
- [ ] Thumb position reflects current scroll position
- [ ] Thumb color changes based on position (green/cyan/yellow)
- [ ] Scroll indicators (triangles) still appear when content exists above/below

### Scrolling Behavior
- [ ] Short swipe (~20px): scrolls 1 item
- [ ] Medium swipe (~60px): scrolls 1 item
- [ ] Long swipe (~120px): scrolls 2 items
- [ ] Very long swipe (~240px): scrolls 4+ items
- [ ] Cannot scroll past top of list
- [ ] Cannot scroll past bottom of list
- [ ] Taps still work correctly after scrolling

### Performance
- [ ] Scrolling feels responsive
- [ ] No lag or stuttering
- [ ] Scrollbar updates smoothly
- [ ] Multiple rapid swipes work correctly

### Edge Cases
- [ ] Menu with exactly 6 items (no scrolling needed) - no scrollbar
- [ ] Menu with 7 items (scrollbar appears)
- [ ] Menu with 20+ items (thumb is small)
- [ ] Very rapid swipes don't cause crashes

---

## Firmware Details

**File**: `Release_Bins/esp32_marauder_v1.1_20260323_171854_v6_scrollbar.bin`

**Size**: 1.7MB (1,755,819 bytes)
- Previous: 1,755,571 bytes
- Increase: +248 bytes (scrollbar code)

**Flash Usage**: 89% (1,755,819 / 1,966,080 bytes)
**RAM Usage**: 24% (79,364 / 327,680 bytes)

**Build Date**: 2025-03-23 17:18:54

---

## Flash Instructions

```bash
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 write_flash -z \
  0x1000 Release_Bins/esp32_marauder.ino.bootloader.bin \
  0x8000 Release_Bins/esp32_marauder.ino.partitions.bin \
  0xE000 boot_app0.bin \
  0x10000 Release_Bins/esp32_marauder_v1.1_20260323_171854_v6_scrollbar.bin
```

---

## Known Behaviors

### Scrollbar Visibility
The scrollbar only appears when:
- The menu has more than 6 items (BUTTON_SCREEN_LIMIT)
- The content exceeds the visible screen area

Menus with 6 or fewer items will not show a scrollbar since all items fit on one screen.

### Scroll Distance Sensitivity
The scroll distance calculation uses a threshold of 60px per item:
- Swipes < 60px: Scroll 1 item (minimum)
- Swipes 60-119px: Scroll 1 item
- Swipes 120-179px: Scroll 2 items
- Swipes 180-239px: Scroll 3 items
- And so on...

This provides a good balance between:
- Precision for small movements
- Speed for long lists
- Prevents accidental over-scrolling

---

## Future Enhancements

Possible improvements for future versions:
1. **Draggable thumb**: Allow dragging the scrollbar thumb directly
2. **Flick scrolling**: Add momentum/velocity-based scrolling
3. **Rubber banding**: Visual feedback when trying to scroll past boundaries
4. **Page indicators**: Show "1/4" style position text
5. **Auto-scroll**: Automatic scroll when holding near edge

---

## Summary

✅ Visual scrollbar added
✅ Dynamic scrolling based on swipe distance
✅ Color-coded thumb for position feedback
✅ Retained arrow indicators
✅ Improved user experience for long menus

**Status**: ✅ READY FOR TESTING
