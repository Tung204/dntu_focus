# Kế hoạch: Sửa màu sắc Home Screen theo Design Dark Mode

## 🎨 Design Reference

Dựa trên hình dark mode design mà người dùng cung cấp, trang Home trong Dark Mode phải có:

- ✅ **Nền trên (header)**: Giữ nguyên màu cam (#FF6347)
- ✅ **Nền dưới**: Màu đen tối (#1C1C1E hoặc #2C2C2E)
- ✅ **Timer circle**: Nền đen tối với progress ring màu cam
- ✅ **Task selector**: Nền đen với text trắng
- ✅ **Buttons và icons**: Text/icon trắng trên nền tối

## 🔍 Vấn đề hiện tại

File [`home_screen.dart`](../lib/features/home/presentation/home_screen.dart) đang hardcode màu sắc, không responsive với theme mode.

## 📋 Các thay đổi cần thực hiện

### 1. Cập nhật Dark Theme Colors (QUAN TRỌNG!)

**File:** [`lib/core/themes/design_tokens.dart`](../lib/core/themes/design_tokens.dart:23-24)

**Hiện tại (Line 23-24):**
```dart
// Dark mode
static const Color darkBackground = Color(0xFF130F26); // Tím đậm ❌
static const Color darkSurface = Color(0xFF35383F); // Xám xanh ❌
```

**Cần đổi thành:**
```dart
// Dark mode - Updated to match Figma design
static const Color darkBackground = Color(0xFF1C1C1E); // Đen tối ✅
static const Color darkSurface = Color(0xFF2C2C2E); // Đen xám ✅
```

**Lý do:** Design mới yêu cầu màu đen tối thay vì tím, phù hợp với iOS dark mode guidelines.

### 2. Giữ nguyên màu nền Scaffold (Line 135)

**Hiện tại:**
```dart
Scaffold(
  backgroundColor: FigmaColors.primary,  // ✅ GIỮ NGUYÊN - Đúng rồi
  ...
)
```

**Không cần thay đổi** - Màu cam ở header là đúng theo design.

### 3. Sửa màu nền phần dưới (Line 180)

**Hiện tại:**
```dart
Container(
  decoration: const BoxDecoration(
    color: Colors.white,  // ❌ Hardcoded trắng
    borderRadius: BorderRadius.only(...),
  ),
)
```

**Cần đổi thành:**
```dart
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).scaffoldBackgroundColor,  // ✅ Động theo theme
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(30),
      topRight: Radius.circular(30),
    ),
  ),
)
```

**Kết quả:**
- Light mode: `#FAFAFA` (trắng kem)
- Dark mode: `#1C1C1E` (đen tối)

### 4. Sửa màu nền Timer Circle (Line 382)

**Hiện tại:**
```dart
Container(
  width: timerSize,
  height: timerSize,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.white,  // ❌ Hardcoded trắng
    boxShadow: [...],
  ),
)
```

**Cần đổi thành:**
```dart
Container(
  width: timerSize,
  height: timerSize,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Theme.of(context).colorScheme.surface,  // ✅ Động theo theme
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(
          Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.1
        ),
        blurRadius: 20,
        spreadRadius: 2,
        offset: const Offset(0, 5),
      ),
    ],
  ),
)
```

**Kết quả:**
- Light mode: `#FFFFFF` (trắng) với shadow nhẹ
- Dark mode: `#2C2C2E` (đen xám) với shadow đậm hơn

### 5. Cập nhật màu Progress Indicator (Line 396-404)

**Hiện tại:**
```dart
SizedBox(
  width: timerSize - 16,
  height: timerSize - 16,
  child: CircularProgressIndicator(
    value: state.isCountingUp ? null : progress,
    strokeWidth: strokeWidth,
    backgroundColor: Colors.grey.shade200,  // ❌ Hardcoded
    valueColor: AlwaysStoppedAnimation<Color>(FigmaColors.primary),
  ),
)
```

**Cần đổi thành:**
```dart
SizedBox(
  width: timerSize - 16,
  height: timerSize - 16,
  child: CircularProgressIndicator(
    value: state.isCountingUp ? null : progress,
    strokeWidth: strokeWidth,
    backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.15),  // ✅ Động
    valueColor: AlwaysStoppedAnimation<Color>(
      Theme.of(context).colorScheme.primary,  // ✅ Luôn màu cam
    ),
  ),
)
```

**Kết quả:**
- Light mode: Background xám nhạt, progress cam
- Dark mode: Background xám tối, progress cam

### 6. Cập nhật màu text thời gian (Line 410-416)

**Hiện tại:**
```dart
Text(
  '$minutes:$seconds',
  style: TextStyle(
    fontSize: timeFontSize,
    fontWeight: FontWeight.bold,
    color: Colors.black87,  // ❌ Hardcoded đen
  ),
)
```

**Cần đổi thành:**
```dart
Text(
  '$minutes:$seconds',
  style: TextStyle(
    fontSize: timeFontSize,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.onSurface,  // ✅ Động theo theme
  ),
)
```

**Kết quả:**
- Light mode: Đen (#212121)
- Dark mode: Trắng (#FFFFFF)

### 7. Cập nhật màu text session (Line 419-425)

**Hiện tại:**
```dart
Text(
  sessionText,
  style: TextStyle(
    fontSize: sessionFontSize,
    color: Colors.grey.shade500,  // ❌ Hardcoded xám
    fontWeight: FontWeight.w400,
  ),
)
```

**Cần đổi thành:**
```dart
Text(
  sessionText,
  style: TextStyle(
    fontSize: sessionFontSize,
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),  // ✅ Động
    fontWeight: FontWeight.w400,
  ),
)
```

### 8. Cập nhật Task Card colors (Line 308-349)

**Hiện tại (Line 313-322):**
```dart
Container(
  padding: EdgeInsets.symmetric(...),
  decoration: BoxDecoration(
    color: Colors.white,  // ❌ Hardcoded
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  ...
)
```

**Cần đổi thành:**
```dart
Container(
  padding: EdgeInsets.symmetric(...),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,  // ✅ Động theo theme
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(
          Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.08
        ),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  ...
)
```

**Text color (Line 328-336):**
```dart
Text(
  state.selectedTask ?? 'Select Task',
  style: TextStyle(
    fontSize: fontSize,
    fontWeight: FontWeight.w400,
    color: state.selectedTask != null
        ? Theme.of(context).colorScheme.onSurface  // ✅ Đen/Trắng
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),  // ✅ Mờ hơn
  ),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
)
```

**Icon color (Line 341-344):**
```dart
Icon(
  Icons.keyboard_arrow_down,
  size: screenWidth < 360 ? 20 : 24,
  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),  // ✅ Động
)
```

### 9. Cập nhật Quick Settings Icons (Line 652, 661)

**Hiện tại (Line 652):**
```dart
border: Border.all(
  color: isActive ? FigmaColors.primary : Colors.grey.shade300,  // ❌ Hardcoded xám
  width: 1.5,
),
```

**Cần đổi thành:**
```dart
border: Border.all(
  color: isActive 
    ? FigmaColors.primary 
    : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),  // ✅ Động
  width: 1.5,
),
```

**Icon color (Line 661):**
```dart
Icon(
  icon,
  size: iconSize,
  color: isActive 
    ? FigmaColors.primary 
    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),  // ✅ Động
)
```

**Label color (Line 669):**
```dart
Text(
  label,
  style: TextStyle(
    fontSize: labelSize,
    color: isActive 
      ? FigmaColors.primary 
      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),  // ✅ Động
    fontWeight: FontWeight.w500,
  ),
  ...
)
```

## 🎯 Kết quả mong đợi

### Light Mode (giữ nguyên)
- Nền trên: Cam đỏ (#FF6347)
- Nền dưới: Trắng kem (#FAFAFA)  
- Timer: Nền trắng (#FFFFFF)
- Text: Đen (#212121)
- Task card: Trắng

### Dark Mode (sau khi sửa)
- Nền trên: Cam đỏ (#FF6347) - Giữ nguyên
- Nền dưới: Đen tối (#1C1C1E)
- Timer: Nền đen xám (#2C2C2E)
- Progress ring: Cam (#FF6347)
- Text: Trắng (#FFFFFF)
- Task card: Đen xám (#2C2C2E)
- Icons inactive: Xám tối với opacity

## 📝 Lưu ý kỹ thuật

1. **Bỏ `const` keyword**: Khi dùng `Theme.of(context)`, widget không thể là const
2. **Shadow intensity**: Dark mode cần shadow đậm hơn để tạo depth
3. **Opacity cho inactive states**: Dùng `.withOpacity()` thay vì hardcode grey colors
4. **Kiểm tra `Theme.of(context).brightness`**: Để điều chỉnh động shadow, opacity
5. **Hot reload**: Sau khi đổi theme trong settings, app cần rebuild để apply changes

## 🧪 Test Cases

1. ✅ Mở Settings → Chọn Dark Mode → Quay lại Home
2. ✅ Home screen nền dưới phải đen tối (#1C1C1E)
3. ✅ Timer circle nền đen với progress ring cam
4. ✅ Task selector nền đen với text trắng
5. ✅ Tất cả text phải đọc được rõ (contrast đủ)
6. ✅ Icons inactive hiện màu xám tối
7. ✅ Chuyển lại Light Mode → Tất cả trở về bình thường
8. ✅ Auto Mode → Theo system theme (test cả ngày/đêm)

## 🔄 Quy trình thực hiện

1. **Bước 1**: Cập nhật [`design_tokens.dart`](../lib/core/themes/design_tokens.dart) - Đổi `darkBackground` và `darkSurface`
2. **Bước 2**: Sửa [`home_screen.dart`](../lib/features/home/presentation/home_screen.dart) - Apply 9 changes trên
3. **Bước 3**: Hot restart app (không chỉ hot reload)
4. **Bước 4**: Test chuyển đổi theme trong Settings
5. **Bước 5**: Verify tất cả màu sắc match với design
6. **Bước 6**: Commit changes

## 📚 Files cần chỉnh sửa

1. [`lib/core/themes/design_tokens.dart`](../lib/core/themes/design_tokens.dart) - Lines 23-24
2. [`lib/features/home/presentation/home_screen.dart`](../lib/features/home/presentation/home_screen.dart) - Multiple lines

## ⚠️ Breaking Changes

**KHÔNG CÓ** - Tất cả thay đổi đều backward compatible. Light mode giữ nguyên như cũ.