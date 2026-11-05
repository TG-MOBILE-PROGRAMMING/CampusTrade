import 'package:flutter/material.dart';

/// ============================================================================
/// ANTI-SLOP SWISS EDITORIAL DESIGN SYSTEM (TOKENS & TYPOGRAPHY)
/// ============================================================================
class SwissColors {
  static const Color surface = Color(0xFFFAFAFA);
  static const Color obsidian = Color(0xFF09090B);
  static const Color white = Color(0xFFFFFFFF);

  // Zinc Scale
  static const Color zinc50 = Color(0xFFFAFAFA);
  static const Color zinc100 = Color(0xFFF4F4F5);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc300 = Color(0xFFD4D4D8);
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc950 = Color(0xFF09090B);

  // Indigo Scale
  static const Color indigo50 = Color(0xFFEEF2FF);
  static const Color indigo100 = Color(0xFFE0E7FF);
  static const Color indigo200 = Color(0xFFC7D2FE);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo700 = Color(0xFF4338CA);
  static const Color indigo800 = Color(0xFF3730A3);
  static const Color indigo950 = Color(0xFF1E1B4B);

  // Emerald Scale
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color emerald800 = Color(0xFF065F46);
  static const Color emerald900 = Color(0xFF064E3B);
  static const Color emerald950 = Color(0xFF022C22);

  // Amber Scale
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);
  static const Color amber950 = Color(0xFF451A03);

  // Rose Scale
  static const Color rose50 = Color(0xFFFFF1F2);
  static const Color rose100 = Color(0xFFFFE4E6);
  static const Color rose200 = Color(0xFFFECDD3);
  static const Color rose400 = Color(0xFFFB7185);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose600 = Color(0xFFE11D48);
  static const Color rose700 = Color(0xFFBE123C);

  // Blue Scale
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E40AF);
}

class SwissTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: SwissColors.surface,
      colorScheme: const ColorScheme.light(
        primary: SwissColors.zinc950,
        secondary: SwissColors.indigo600,
        surface: SwissColors.white,
        error: SwissColors.rose600,
      ),
      dividerColor: SwissColors.zinc200,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SwissColors.zinc950,
        contentTextStyle: const TextStyle(
          color: SwissColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static TextStyle display({
    double size = 18,
    FontWeight weight = FontWeight.w700,
    Color color = SwissColors.zinc950,
    double? height,
    double letterSpacing = -0.3,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle sans({
    double size = 12,
    FontWeight weight = FontWeight.w500,
    Color color = SwissColors.zinc800,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }

  static TextStyle mono({
    double size = 10,
    FontWeight weight = FontWeight.w600,
    Color color = SwissColors.zinc600,
    double letterSpacing = 0.4,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'monospace',
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Format Rupiah (contoh: Rp 180.000)
  static String formatRupiah(int amount, {bool withPrefix = true}) {
    final bool isNegative = amount < 0;
    final String digits = amount.abs().toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    final String formatted = buffer.toString();
    final String sign = isNegative ? '-' : '';
    return withPrefix ? '${sign}Rp $formatted' : '$sign$formatted';
  }
}

/// Architectural Radial Dot Grid Background (matches `.swiss-grid-bg` in style.css)
class SwissGridBackground extends StatelessWidget {
  final Widget child;
  const SwissGridBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SwissDotGridPainter(),
      child: child,
    );
  }
}

class _SwissDotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()..color = SwissColors.surface;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final Paint dotPaint = Paint()
      ..color = SwissColors.zinc300
      ..style = PaintingStyle.fill;

    const double spacing = 20.0;
    for (double x = 10; x < size.width; x += spacing) {
      for (double y = 10; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.9, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
