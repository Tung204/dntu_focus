import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design Tokens được trích xuất từ Figma Design
/// File: Focusify - Pomodoro & Task Management App UI Kit
/// Màu chủ đạo: Tomato Red #FF6347
/// Font chủ yếu: Urbanist

class FigmaColors {
  FigmaColors._();

  // ==================== PRIMARY COLORS ====================
  static const Color primary = Color(0xFFFF6347); // Tomato Red - Màu chủ đạo
  static const Color primaryDark = Color(0xFFFF5726); // Cam sáng
  static const Color primaryLight = Color(0xFFFF8C73); // Đỏ cam nhạt
  
  // ==================== BACKGROUND COLORS ====================
  static const Color background = Color(0xFFFAFAFA); // Trắng kem
  static const Color surface = Color(0xFFEEEEEE); // Xám nhạt
  static const Color white = Color(0xFFFFFFFF); // Trắng
  
  // Dark mode - Updated to match Figma design
  static const Color darkBackground = Color(0xFF1C1C1E); // Đen tối
  static const Color darkSurface = Color(0xFF2C2C2E); // Đen xám
  
  // ==================== TEXT COLORS ====================
  static const Color textPrimary = Color(0xFF212121); // Xám đậm
  static const Color textSecondary = Color(0xFF35383F); // Xám xanh
  static const Color textTertiary = Color(0xFFDADADA); // Xám
  static const Color textDisabled = Color(0xFFE0E0E0); // Xám nhạt
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Trắng
  
  // ==================== ACCENT COLORS ====================
  static const Color success = Color(0xFF4AAF57); // Xanh lá
  static const Color error = Color(0xFFEA1E61); // Hồng/Đỏ
  static const Color warning = Color(0xFFFF5726); // Cam sáng
  static const Color info = Color(0xFF00BCD3); // Xanh cyan
  
  // ==================== SEMANTIC COLORS ====================
  static const Color focusTimer = Color(0xFF8BC255); // Xanh lá nhạt
  static const Color breakTimer = Color(0xFF00BCD3); // Xanh cyan
  static const Color divider = Color(0xFFE0E0E0); // Xám
  static const Color shadow = Color(0x1A000000); // Đen 10% opacity
}

class FigmaTextStyles {
  FigmaTextStyles._();

  // ==================== HEADINGS ====================
  
  /// H1 - Urbanist Bold 48px/69px
  /// Sử dụng cho: Hero titles, splash screens
  static TextStyle h1 = GoogleFonts.urbanist(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 69 / 48, // Line height ratio
    letterSpacing: 0,
    color: FigmaColors.textPrimary,
  );

  /// H2 - Urbanist Bold 32px/48px
  /// Sử dụng cho: Page titles
  static TextStyle h2 = GoogleFonts.urbanist(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 48 / 32,
    letterSpacing: 0,
    color: FigmaColors.textPrimary,
  );

  /// H3 - Urbanist Bold 24px/38.4px
  /// Sử dụng cho: Section headers
  static TextStyle h3 = GoogleFonts.urbanist(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 38.4 / 24,
    letterSpacing: 0,
    color: FigmaColors.textPrimary,
  );

  /// H4 - Urbanist Bold 20px/32px
  /// Sử dụng cho: Card titles, subsection headers
  static TextStyle h4 = GoogleFonts.urbanist(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 32 / 20,
    letterSpacing: 0,
    color: FigmaColors.textPrimary,
  );

  // ==================== BODY TEXT ====================
  
  /// Body Large - Urbanist SemiBold 20px/32px
  /// Sử dụng cho: Important body text
  static TextStyle bodyLarge = GoogleFonts.urbanist(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 32 / 20,
    letterSpacing: 0,
    color: FigmaColors.textPrimary,
  );

  /// Body Medium - Urbanist SemiBold 18px/28.8px
  /// Sử dụng cho: Standard body text
  static TextStyle bodyMedium = GoogleFonts.urbanist(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 28.8 / 18,
    letterSpacing: 0.2,
    color: FigmaColors.textPrimary,
  );

  /// Body Small - Urbanist Medium 12px/19.2px
  /// Sử dụng cho: Secondary text, captions
  static TextStyle bodySmall = GoogleFonts.urbanist(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 19.2 / 12,
    letterSpacing: 0.2,
    color: FigmaColors.textSecondary,
  );

  // ==================== LABELS & BUTTONS ====================
  
  /// Label Large - Urbanist Bold 16px/25.6px
  /// Sử dụng cho: Primary buttons
  static TextStyle labelLarge = GoogleFonts.urbanist(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 25.6 / 16,
    letterSpacing: 0.2,
    color: FigmaColors.textOnPrimary,
  );

  /// Label Medium - Urbanist SemiBold 16px/25.6px
  /// Sử dụng cho: Secondary buttons, labels
  static TextStyle labelMedium = GoogleFonts.urbanist(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 25.6 / 16,
    letterSpacing: 0.2,
    color: FigmaColors.textPrimary,
  );

  /// Label Small - Urbanist Medium 12px/19.2px
  /// Sử dụng cho: Small labels, tags
  static TextStyle labelSmall = GoogleFonts.urbanist(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 19.2 / 12,
    letterSpacing: 0.2,
    color: FigmaColors.textSecondary,
  );

  // ==================== SPECIAL ====================
  
  /// Caption - Urbanist Regular 18px/28.8px
  /// Sử dụng cho: Hints, helper text
  static TextStyle caption = GoogleFonts.urbanist(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28.8 / 18,
    letterSpacing: 0.2,
    color: FigmaColors.textTertiary,
  );

  /// Input - Urbanist Medium 16px/25.6px
  /// Sử dụng cho: Text fields
  static TextStyle input = GoogleFonts.urbanist(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 25.6 / 16,
    letterSpacing: 0,
    color: FigmaColors.textPrimary,
  );

  /// Hint - Urbanist Medium 16px/25.6px
  /// Sử dụng cho: Input placeholders
  static TextStyle hint = GoogleFonts.urbanist(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 25.6 / 16,
    letterSpacing: 0,
    color: FigmaColors.textSecondary,
  );
}

class FigmaSpacing {
  FigmaSpacing._();

  // ==================== SPACING ====================
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // ==================== COMPONENT SPECIFIC ====================
  static const double inputHeight = 56.0;
  static const double buttonHeight = 56.0;
  static const double logoSize = 100.0;
  static const double iconSize = 24.0;
  
  // ==================== PADDING ====================
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 24.0);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);
  
  // ==================== BORDER RADIUS ====================
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;
}

class FigmaElevation {
  FigmaElevation._();

  static const double none = 0;
  static const double sm = 2;
  static const double md = 4;
  static const double lg = 8;
  static const double xl = 16;
}

/// Extension để dễ dàng sử dụng colors
extension FigmaColorsExtension on Color {
  /// Tạo MaterialColor từ Color
  MaterialColor toMaterialColor() {
    final color = this;
    return MaterialColor(
      color.value,
      <int, Color>{
        50: color.withOpacity(0.1),
        100: color.withOpacity(0.2),
        200: color.withOpacity(0.3),
        300: color.withOpacity(0.4),
        400: color.withOpacity(0.5),
        500: color.withOpacity(0.6),
        600: color.withOpacity(0.7),
        700: color.withOpacity(0.8),
        800: color.withOpacity(0.9),
        900: color,
      },
    );
  }
}