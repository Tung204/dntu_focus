# Kế hoạch Thiết kế lại Timer Mode Dialog thành Bottom Sheet

## 📋 Tổng quan
Chuyển đổi Timer Mode dialogs từ center dialog (`showDialog`) sang bottom sheet (`showModalBottomSheet`) để thống nhất với Strict Mode dialog.

## 🎯 Mục tiêu
- Thay đổi cách hiển thị từ center dialog sang bottom sheet
- Giữ nguyên UI và functionality hiện tại
- Đảm bảo tính nhất quán với Strict Mode dialog

## 📊 Phân tích hiện tại

### 1. Cấu trúc Dialog hiện tại

#### TimerModeSimpleDialog
- **File**: `lib/features/home/presentation/widgets/timer_mode_simple_dialog.dart`
- **Phương thức hiển thị**: `showDialog()` (dòng 695 trong home_screen.dart)
- **Cấu trúc**: 
  - Container với `BoxDecoration` có `borderRadius`
  - Column chứa: Header, Divider, Content (Radio Options), Divider, Action Buttons
  - 2 radio options: "25:00 → 00:00" và "00:00 → ∞"
  - Link chuyển sang Advanced mode
  - Action buttons: Cancel và OK

#### TimerModeAdvancedDialog
- **File**: `lib/features/home/presentation/widgets/timer_mode_advanced_dialog.dart`
- **Phương thức hiển thị**: `showDialog()` (dòng 709 trong home_screen.dart)
- **Cấu trúc**:
  - Container với `BoxDecoration` có `borderRadius`
  - Column chứa: Header, Divider, Scrollable Content, Divider, Action Buttons
  - Các trường cấu hình: Timer Mode dropdown, Work/Break duration, Sessions, Sound settings, Auto-switch
  - Link chuyển về Simple mode
  - Action buttons: Cancel và OK

#### StrictModeDialog (tham khảo)
- **File**: `lib/features/home/presentation/widgets/strict_mode_dialog.dart`
- **Phương thức hiển thị**: `showModalBottomSheet()` (dòng 20)
- **Cấu trúc tương tự**: Container → Column → Header/Divider/Content/Divider/Actions

### 2. So sánh cấu trúc

```
┌─────────────────────────────────────┐
│ Timer Mode (Center Dialog)          │  ❌ Hiện tại
│  - AlertDialog wrapper              │
│  - showDialog()                     │
│  - Hiển thị giữa màn hình          │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Strict Mode (Bottom Sheet)          │  ✅ Mẫu tham khảo
│  - Container wrapper                │
│  - showModalBottomSheet()           │
│  - Hiển thị từ dưới lên            │
└─────────────────────────────────────┘
```

## 🔧 Phương án thay đổi

### Bước 1: Cập nhật TimerModeSimpleDialog
**Thay đổi trong file**: `timer_mode_simple_dialog.dart`

1. **Đã có sẵn phương thức `show()` helper** (dòng 19-31):
   - ✅ Đã sử dụng `showModalBottomSheet`
   - ✅ Đã có `backgroundColor: Colors.transparent`
   - **Không cần thay đổi!**

2. **Widget build** đã đúng format:
   - ✅ Sử dụng `Container` với `BoxDecoration`
   - ✅ Có `borderRadius` cho top corners
   - ✅ Padding để tránh keyboard overlap
   - **Không cần thay đổi!**

### Bước 2: Cập nhật TimerModeAdvancedDialog
**Thay đổi trong file**: `timer_mode_advanced_dialog.dart`

1. **Đã có sẵn phương thức `show()` helper** (dòng 20-32):
   - ✅ Đã sử dụng `showModalBottomSheet`
   - ✅ Đã có `isScrollControlled: true`
   - ✅ Đã có `backgroundColor: Colors.transparent`
   - **Không cần thay đổi!**

2. **Widget build** đã đúng format:
   - ✅ Sử dụng `Container` với `BoxDecoration`
   - ✅ Có `borderRadius` cho top corners
   - ✅ Có `Flexible` và `SingleChildScrollView` cho nội dung dài
   - **Không cần thay đổi!**

### Bước 3: Cập nhật home_screen.dart
**Thay đổi trong file**: `home_screen.dart`

**VẤN ĐỀ CHÍNH**: Các phương thức `_showSimpleDialog()` và `_showAdvancedDialog()` đang sử dụng `showDialog()` thay vì gọi helper method có sẵn.

#### Thay đổi cần thực hiện:

**Dòng 694-705** - `_showSimpleDialog()`:
```dart
// ❌ TRƯỚC (showDialog)
void _showSimpleDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => TimerModeSimpleDialog(
      onSwitchToAdvanced: () {
        Navigator.pop(context);
        _showAdvancedDialog(context);
      },
    ),
  );
}

// ✅ SAU (showModalBottomSheet thông qua helper)
void _showSimpleDialog(BuildContext context) {
  TimerModeSimpleDialog.show(
    context,
    onSwitchToAdvanced: () {
      Navigator.pop(context);
      _showAdvancedDialog(context);
    },
  );
}
```

**Dòng 707-718** - `_showAdvancedDialog()`:
```dart
// ❌ TRƯỚC (showDialog)
void _showAdvancedDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => TimerModeAdvancedDialog(
      onSwitchToSimple: () {
        Navigator.pop(context);
        _showSimpleDialog(context);
      },
    ),
  );
}

// ✅ SAU (showModalBottomSheet thông qua helper)
void _showAdvancedDialog(BuildContext context) {
  TimerModeAdvancedDialog.show(
    context,
    onSwitchToSimple: () {
      Navigator.pop(context);
      _showSimpleDialog(context);
    },
  );
}
```

## 📝 Tóm tắt thay đổi

### Files cần sửa:
1. ✅ `timer_mode_simple_dialog.dart` - **KHÔNG CẦN SỬA** (đã đúng format)
2. ✅ `timer_mode_advanced_dialog.dart` - **KHÔNG CẦN SỬA** (đã đúng format)  
3. ❗ `home_screen.dart` - **CẦN SỬA** (2 phương thức)

### Thay đổi cụ thể:
- Thay `showDialog()` bằng gọi trực tiếp helper method `.show()`
- Giữ nguyên logic switch giữa Simple/Advanced
- Giữ nguyên tất cả UI components

## ✅ Kết quả mong đợi

Sau khi thực hiện:
- Timer Mode dialogs sẽ hiển thị từ **dưới lên** (bottom sheet)
- UI giữ nguyên **100%**
- Chức năng switch giữa Simple/Advanced vẫn hoạt động bình thường
- Thống nhất với Strict Mode dialog về mặt UX

## 🔍 Kiểm tra chất lượng

- [ ] Timer Mode Simple hiển thị từ dưới lên
- [ ] Timer Mode Advanced hiển thị từ dưới lên
- [ ] Switch từ Simple → Advanced hoạt động
- [ ] Switch từ Advanced → Simple hoạt động
- [ ] Keyboard không che nội dung khi nhập liệu
- [ ] Tất cả các trường input hoạt động bình thường
- [ ] Action buttons (Cancel/OK) hoạt động đúng
- [ ] Dark mode vẫn hiển thị đúng