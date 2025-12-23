# Kế Hoạch Redesign Login/Register Theo Figma Design

## 📊 Design Tokens Từ Figma

### 🎨 Color Palette
Dựa trên phân tích, các màu chính:

```dart
// Primary Colors
primaryColor: Color(0xFFFF6347)        // Đỏ cam (Tomato) - Màu chủ đạo
darkColor: Color(0xFF212121)           // Xám đậm - Text chính
lightColor: Color(0xFFFFFFFF)          // Trắng - Background

// Background Colors
backgroundColor: Color(0xFFFAFAFA)     // Trắng kem
surfaceColor: Color(0xFFEEEEEE)        // Xám nhạt
darkSurfaceColor: Color(0xFF130F26)   // Tím đậm (Dark mode)

// Text Colors
textPrimary: Color(0xFF212121)         // Xám đậm
textSecondary: Color(0xFF35383F)       // Xám xanh
textTertiary: Color(0xFFE0E0E0)        // Xám

// Accent Colors
successColor: Color(0xFF4AAF57)        // Xanh lá
errorColor: Color(0xFFEA1E61)          // Hồng/Đỏ
warningColor: Color(0xFFFF5726)        // Cam sáng
infoColor: Color(0xFF00BCD3)           // Xanh cyan
```

### ✍️ Typography (Font Urbanist)
```dart
// Headings
h1: Urbanist 700 (Bold) - 48px / 69px
h2: Urbanist 700 (Bold) - 32px / 48px
h3: Urbanist 700 (Bold) - 24px / 38.4px
h4: Urbanist 700 (Bold) - 20px / 32px

// Body Text
bodyLarge: Urbanist 600 (SemiBold) - 20px / 32px
bodyMedium: Urbanist 600 (SemiBold) - 18px / 28.8px (Letter: 0.2)
bodySmall: Urbanist 500 (Medium) - 12px / 19.2px (Letter: 0.2)

// Labels & Buttons
labelLarge: Urbanist 700 (Bold) - 16px / 25.6px (Letter: 0.2)
labelMedium: Urbanist 600 (SemiBold) - 16px / 25.6px (Letter: 0.2)
labelSmall: Urbanist 500 (Medium) - 12px / 19.2px (Letter: 0.2)

// Caption
caption: Urbanist 400 (Regular) - 18px / 28.8px (Letter: 0.2)
```

## 🎯 Mục Tiêu

Tạo giao diện Login/Register với đặc điểm:
1. ✅ Màu sắc chính: Đỏ cam (#FF6347) với background trắng/xám nhạt
2. ✅ Font chữ: Urbanist (thay vì font hiện tại)
3. ✅ Design modern, clean với spacing hợp lý
4. ✅ Button có màu đỏ cam nổi bật
5. ✅ Input fields có border radius và padding phù hợp
6. ✅ Responsive cho mọi kích thước màn hình

## 📋 Các Bước Thực Hiện

### Bước 1: Setup Design Tokens
**File**: `lib/core/themes/design_tokens.dart`

```dart
class FigmaColors {
  // Primary
  static const primary = Color(0xFFFF6347);
  static const darkText = Color(0xFF212121);
  static const white = Color(0xFFFFFFFF);
  
  // Background
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFEEEEEE);
  static const darkSurface = Color(0xFF130F26);
  
  // ... etc
}

class FigmaTextStyles {
  static TextStyle h1 = GoogleFonts.urbanist(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 69/48,
  );
  
  // ... etc
}
```

### Bước 2: Cập Nhật Theme
**File**: `lib/core/themes/theme.dart`

Thay đổi:
- Primary color → `#FF6347`
- Font family → `Urbanist`
- Text styles theo Figma specs
- Button styles với màu đỏ cam
- Input decoration với border radius

### Bước 3: Thêm Font Urbanist
**File**: `pubspec.yaml`

```yaml
dependencies:
  google_fonts: ^6.2.1  # Đã có

# Hoặc download font local
fonts:
  - family: Urbanist
    fonts:
      - asset: fonts/Urbanist-Regular.ttf
        weight: 400
      - asset: fonts/Urbanist-Medium.ttf
        weight: 500
      - asset: fonts/Urbanist-SemiBold.ttf
        weight: 600
      - asset: fonts/Urbanist-Bold.ttf
        weight: 700
```

### Bước 4: Redesign Login Screen
**File**: `lib/features/auth/presentation/login_screen.dart`

**Layout mới:**
```
┌─────────────────────────────────┐
│         Logo (centered)          │
│                                  │
│       "Moji Focus"               │
│     (Urbanist Bold 32px)         │
│                                  │
│  ┌──────────────────────────┐  │
│  │  Email TextField         │  │
│  │  (với icon email)        │  │
│  └──────────────────────────┘  │
│                                  │
│  ┌──────────────────────────┐  │
│  │  Password TextField      │  │
│  │  (với icon lock & eye)   │  │
│  └──────────────────────────┘  │
│                                  │
│         Forgot Password?         │
│                                  │
│  ┌──────────────────────────┐  │
│  │   SIGN IN Button         │  │
│  │   (Tomato Red #FF6347)   │  │
│  └──────────────────────────┘  │
│                                  │
│         ────── OR ──────         │
│                                  │
│  ┌──────────────────────────┐  │
│  │  Sign in with Google     │  │
│  │  (Outlined button)       │  │
│  └──────────────────────────┘  │
│                                  │
│  Don't have account? Sign Up     │
└─────────────────────────────────┘
```

**Đặc điểm:**
- Background: `#FAFAFA`
- Input fields: 
  - Height: 56px
  - Border radius: 12px
  - Fill color: `#EEEEEE`
  - No border (filled style)
  - Hint text: `#35383F` (Urbanist Medium 16px)
- Primary button:
  - Background: `#FF6347`
  - Text: White (Urbanist Bold 16px)
  - Height: 56px
  - Border radius: 12px
  - Shadow: subtle
- Logo: 100x100

### Bước 5: Redesign Register Screen
**File**: `lib/features/auth/presentation/register_screen.dart`

**Layout tương tự Login nhưng thêm:**
```
┌─────────────────────────────────┐
│         Logo (centered)          │
│                                  │
│    "Create Account"              │
│   (Urbanist Bold 24px)           │
│                                  │
│  ┌──────────────────────────┐  │
│  │  Email TextField         │  │
│  └──────────────────────────┘  │
│                                  │
│  ┌──────────────────────────┐  │
│  │  Username TextField      │  │
│  └──────────────────────────┘  │
│                                  │
│  ┌──────────────────────────┐  │
│  │  Password TextField      │  │
│  └──────────────────────────┘  │
│                                  │
│  ┌──────────────────────────┐  │
│  │  Confirm Password        │  │
│  └──────────────────────────┘  │
│                                  │
│  ☑ I agree to Terms & Conditions │
│                                  │
│  ┌──────────────────────────┐  │
│  │  CREATE ACCOUNT Button   │  │
│  │  (Tomato Red #FF6347)    │  │
│  └──────────────────────────┘  │
│                                  │
│  Already have account? Log In    │
└─────────────────────────────────┘
```

### Bước 6: Tạo Reusable Widgets

**File**: `lib/features/auth/presentation/widgets/`

1. **auth_text_field.dart** - Custom TextField với Figma style
2. **auth_button.dart** - Primary button với Figma colors
3. **auth_divider.dart** - "OR" divider
4. **social_login_button.dart** - Google sign in button

## 🎨 Component Specifications

### TextField Style
```dart
InputDecoration(
  filled: true,
  fillColor: Color(0xFFEEEEEE),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
  contentPadding: EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 18,
  ),
  hintStyle: GoogleFonts.urbanist(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF35383F),
  ),
)
```

### Primary Button Style
```dart
ElevatedButton.styleFrom(
  backgroundColor: Color(0xFFFF6347),
  foregroundColor: Colors.white,
  minimumSize: Size(double.infinity, 56),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  elevation: 2,
  textStyle: GoogleFonts.urbanist(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  ),
)
```

### Outlined Button (Social Login)
```dart
OutlinedButton.styleFrom(
  foregroundColor: Color(0xFF212121),
  minimumSize: Size(double.infinity, 56),
  side: BorderSide(
    color: Color(0xFFEEEEEE),
    width: 1.5,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  textStyle: GoogleFonts.urbanist(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
)
```

## 📐 Spacing & Sizing

- **Logo size**: 100x100
- **Title spacing**: 24px below logo
- **Input spacing**: 16px between fields
- **Button height**: 56px
- **Border radius**: 12px (consistent)
- **Horizontal padding**: 24px
- **Vertical padding**: safe area

## ✅ Checklist Implementation

- [ ] Tạo `design_tokens.dart` với colors và text styles
- [ ] Cập nhật `theme.dart` với Figma colors
- [ ] Thêm font Urbanist (via google_fonts)
- [ ] Tạo `AuthTextField` widget
- [ ] Tạo `AuthButton` widget
- [ ] Redesign `login_screen.dart`
- [ ] Redesign `register_screen.dart`
- [ ] Test trên Android emulator
- [ ] Test trên iOS simulator (nếu có)
- [ ] Test dark mode (nếu cần)

## 🔍 Testing Checklist

- [ ] Logo hiển thị đúng
- [ ] Màu sắc khớp với Figma (#FF6347)
- [ ] Font Urbanist load được
- [ ] Input fields responsive
- [ ] Button có hover/press effects
- [ ] Validation hiển thị đúng
- [ ] Navigation hoạt động
- [ ] Keyboard không che input
- [ ] Scroll mượt mà

## 📝 Notes

- File Figma là "Focusify - Pomodoro & Task Management App UI Kit"
- Không có màn hình Login/Register riêng trong preview, nên design dựa trên color palette và typography
- Font chính: **Urbanist** (Bold 700, SemiBold 600, Medium 500, Regular 400)
- Màu chủ đạo: **Tomato Red #FF6347**
- Style: Clean, modern, minimalist

## 🚀 Next Steps

Sau khi hoàn thành redesign:
1. Áp dụng design system cho các màn hình khác
2. Tạo component library
3. Document design tokens
4. Setup Storybook/Widgetbook (optional)

---

**Tạo bởi**: Kilo Code (Architect Mode)  
**Ngày tạo**: 2025-12-22  
**Trạng thái**: Ready for Implementation