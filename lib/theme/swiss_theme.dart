import 'dart:ui' show PointMode;
import 'package:flutter/material.dart';

/// ============================================================================
/// CAMPUSTRADE CLEAN MINIMALIST DESIGN SYSTEM ("Pure White & Ocean Teal")
/// Dial: ENERGY 2 / RHYTHM 2 / MOTION 2
/// See DESIGN.md for full color contrast, typography, and motion rationale.
/// ============================================================================
class CampusColors {
  // Core Neutral Surfaces (Pure White & Crisp Cool Mist)
  static const Color canvasPaper = Color(0xFFF8FAFC);
  static const Color surfacePure = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F5F9);
  static const Color borderHairline = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);

  // Core Ink Scale (WCAG AA verified >= 4.7:1 on white)
  static const Color inkPrimary = Color(0xFF0F172A);
  static const Color inkSecondary = Color(0xFF475569);
  static const Color inkMuted = Color(0xFF64748B);

  // Monochromatic Brand Family: Ocean Teal (Zero clashing hues)
  static const Color oceanTeal = Color(0xFF0D9488);
  static const Color oceanTealDeep = Color(0xFF0F766E); // 5.4:1 with white text
  static const Color oceanTealDark = Color(0xFF115E59); // 7.3:1 with white text
  static const Color oceanTealSoft = Color(0xFFF0FDFA);
  static const Color oceanTealBorder = Color(0xFFCCFBF1);

  // Cohesive aliases so all screens automatically stay in the Ocean Teal family
  static const Color campusCobalt = oceanTeal;
  static const Color campusCobaltDeep = oceanTealDark;
  static const Color campusCobaltSoft = oceanTealSoft;

  static const Color campusForest = oceanTealDeep;
  static const Color campusForestLight = oceanTeal;
  static const Color campusForestSoft = oceanTealSoft;

  static const Color sunburstCoral = oceanTealDeep;
  static const Color sunburstCoralLight = oceanTeal;
  static const Color sunburstCoralSoft = oceanTealSoft;

  static const Color terracotta = oceanTealDeep;
  static const Color terracottaDark = oceanTealDark;
  static const Color terracottaSoft = oceanTealSoft;

  // Semantic Status Tokens
  static const Color verifiedJade = oceanTealDeep;
  static const Color verifiedJadeSoft = oceanTealSoft;
  static const Color cautionAmber = Color(0xFFB45309);
  static const Color cautionAmberSoft = Color(0xFFFFFBEB);
  static const Color dangerCrimson = Color(0xFFBE123C);
  static const Color dangerCrimsonSoft = Color(0xFFFFF1F2);

  // Admin Console (Deep Slate & Ocean Teal Dark Mode)
  static const Color adminVoid = Color(0xFF0B1117);
  static const Color adminPanel = Color(0xFF111827);
  static const Color adminElevated = Color(0xFF1E293B);
  static const Color adminHairline = Color(0xFF293548);
  static const Color adminTextHigh = Color(0xFFF8FAFC);
  static const Color adminTextLow = Color(0xFF94A3B8);
  static const Color adminSky = Color(0xFF2DD4BF); // Bright Ocean Teal (10.8:1)
}

/// Backward-compatible alias mapping legacy SwissColors tokens to the new
/// Coastal Cobalt & Sunburst Coral palette across every screen.
class SwissColors {
  static const Color canvasPure = CampusColors.surfacePure;
  static const Color canvasWarm = CampusColors.canvasPaper;
  static const Color canvasSubtle = CampusColors.surfaceSubtle;
  static const Color inkPrimary = CampusColors.inkPrimary;
  static const Color inkSecondary = CampusColors.inkSecondary;
  static const Color inkMuted = CampusColors.inkMuted;
  static const Color borderHairline = CampusColors.borderHairline;

  static const Color rauschCoral = CampusColors.sunburstCoral;
  static const Color verifiedEmerald = CampusColors.verifiedJade;
  static const Color cautionAmber = CampusColors.cautionAmber;
  static const Color dangerRose = CampusColors.dangerCrimson;

  static const Color uberBlack = CampusColors.campusCobaltDeep;
  static const Color uberGrayInactive = CampusColors.surfaceSubtle;
  static const Color uberBorder = CampusColors.borderHairline;

  static const Color escrowIndigo = CampusColors.campusCobalt;
  static const Color escrowBg = CampusColors.campusCobaltSoft;
  static const Color escrowBorder = CampusColors.borderHairline;

  static const Color adminVoid = CampusColors.adminVoid;
  static const Color adminPanel = CampusColors.adminPanel;
  static const Color adminElevated = CampusColors.adminElevated;
  static const Color adminHairline = CampusColors.adminHairline;
  static const Color adminTextHigh = CampusColors.adminTextHigh;
  static const Color adminTextLow = CampusColors.adminTextLow;
  static const Color linearLavender = CampusColors.adminSky;
  static const Color adminAccentCyan = Color(0xFF38BDF8);
  static const Color adminAccentEmerald = Color(0xFF14B8A6);
  static const Color adminAccentAmber = Color(0xFFF59E0B);

  static const Color surface = CampusColors.canvasPaper;
  static const Color obsidian = CampusColors.inkPrimary;
  static const Color white = CampusColors.surfacePure;

  static const Color zinc50 = Color(0xFFF8FAFC);
  static const Color zinc100 = Color(0xFFF1F5F9);
  static const Color zinc200 = Color(0xFFE2E8F0);
  static const Color zinc300 = Color(0xFFCBD5E1);
  static const Color zinc400 = Color(0xFF94A3B8);
  static const Color zinc500 = Color(0xFF64748B);
  static const Color zinc600 = Color(0xFF475569);
  static const Color zinc700 = Color(0xFF334155);
  static const Color zinc800 = Color(0xFF1E293B);
  static const Color zinc900 = Color(0xFF0F172A);
  static const Color zinc950 = Color(0xFF0B1120);

  static const Color indigo50 = Color(0xFFEFF6FF);
  static const Color indigo100 = Color(0xFFDBEAFE);
  static const Color indigo200 = Color(0xFFBFDBFE);
  static const Color indigo400 = Color(0xFF60A5FA);
  static const Color indigo500 = Color(0xFF3B82F6);
  static const Color indigo600 = Color(0xFF2563EB);
  static const Color indigo700 = Color(0xFF1D4ED8);
  static const Color indigo800 = Color(0xFF1E40AF);
  static const Color indigo950 = Color(0xFF172554);

  static const Color emerald50 = Color(0xFFF0FDFA);
  static const Color emerald100 = Color(0xFFCCFBF1);
  static const Color emerald200 = Color(0xFF99F6E4);
  static const Color emerald400 = Color(0xFF2DD4BF);
  static const Color emerald500 = Color(0xFF14B8A6);
  static const Color emerald600 = Color(0xFF0D9488);
  static const Color emerald700 = Color(0xFF0F766E);
  static const Color emerald800 = Color(0xFF115E59);
  static const Color emerald900 = Color(0xFF134E4A);
  static const Color emerald950 = Color(0xFF042F2E);

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

  static const Color rose50 = Color(0xFFFFF1F2);
  static const Color rose100 = Color(0xFFFFE4E6);
  static const Color rose200 = Color(0xFFFECDD3);
  static const Color rose400 = Color(0xFFFB7185);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose600 = Color(0xFFE11D48);
  static const Color rose700 = Color(0xFFBE123C);

  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E40AF);
}

class SwissTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: CampusColors.canvasPaper,
      colorScheme: const ColorScheme.light(
        primary: CampusColors.campusCobalt,
        secondary: CampusColors.sunburstCoral,
        surface: CampusColors.surfacePure,
        error: CampusColors.dangerCrimson,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: CampusColors.inkPrimary,
      ),
      dividerColor: CampusColors.borderHairline,
      appBarTheme: const AppBarTheme(
        backgroundColor: CampusColors.surfacePure,
        foregroundColor: CampusColors.inkPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: CampusColors.surfacePure,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CampusColors.borderHairline),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(44, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 46),
          side: const BorderSide(color: CampusColors.borderHairline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CampusColors.inkPrimary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get darkAdminTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: CampusColors.adminVoid,
      colorScheme: const ColorScheme.dark(
        primary: CampusColors.adminSky,
        secondary: CampusColors.sunburstCoralLight,
        surface: CampusColors.adminPanel,
        error: CampusColors.dangerCrimson,
      ),
      dividerColor: CampusColors.adminHairline,
      cardTheme: CardThemeData(
        color: CampusColors.adminPanel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: CampusColors.adminHairline),
        ),
      ),
    );
  }

  static TextStyle display({
    double size = 18,
    FontWeight weight = FontWeight.w700,
    Color color = CampusColors.inkPrimary,
    double? height,
    double letterSpacing = -0.35,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height ?? 1.25,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle sans({
    double size = 13,
    FontWeight weight = FontWeight.w500,
    Color color = CampusColors.inkSecondary,
    double? height,
    TextDecoration? decoration,
    double letterSpacing = 0.0,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height ?? 1.45,
      decoration: decoration,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle label({
    double size = 11.5,
    FontWeight weight = FontWeight.w700,
    Color color = CampusColors.inkMuted,
    double letterSpacing = 0.2,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: 1.2,
    );
  }

  static TextStyle mono({
    double size = 11,
    FontWeight weight = FontWeight.w600,
    Color color = CampusColors.inkSecondary,
    double letterSpacing = 0.2,
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

/// ============================================================================
/// ZERO-OVERFLOW RESPONSIVE PRIMITIVES
/// ============================================================================

class SwissResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  final double runSpacing;

  const SwissResponsiveGrid({
    super.key,
    required this.children,
    required this.crossAxisCount,
    this.spacing = 14.0,
    this.runSpacing = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final List<Widget> rows = [];
    final int safeCols = crossAxisCount.clamp(1, 12);

    for (int i = 0; i < children.length; i += safeCols) {
      if (safeCols == 1) {
        rows.add(children[i]);
      } else {
        final int end =
            (i + safeCols < children.length) ? i + safeCols : children.length;
        final List<Widget> rowChildren = [];

        for (int j = i; j < end; j++) {
          rowChildren.add(Expanded(child: children[j]));
          if (j < end - 1) {
            rowChildren.add(SizedBox(width: spacing));
          }
        }

        final int remaining = safeCols - (end - i);
        for (int k = 0; k < remaining; k++) {
          rowChildren.add(SizedBox(width: spacing));
          rowChildren.add(const Expanded(child: SizedBox.shrink()));
        }

        rows.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rowChildren,
            ),
          ),
        );
      }

      if (i + safeCols < children.length) {
        rows.add(SizedBox(height: runSpacing));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

class SwissSplitHeader extends StatelessWidget {
  final Widget title;
  final Widget? trailing;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;

  const SwissSplitHeader({
    super.key,
    required this.title,
    this.trailing,
    this.spacing = 12.0,
    this.runSpacing = 10.0,
    this.alignment = WrapAlignment.spaceBetween,
    this.crossAxisAlignment = WrapCrossAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        title,
        if (trailing != null) trailing!,
      ],
    );
  }
}

class SwissFormRow extends StatelessWidget {
  final Widget first;
  final Widget second;
  final double spacing;
  final double breakpoint;

  const SwissFormRow({
    super.key,
    required this.first,
    required this.second,
    this.spacing = 12.0,
    this.breakpoint = 540.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              SizedBox(width: spacing),
              Expanded(child: second),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            first,
            SizedBox(height: spacing),
            second,
          ],
        );
      },
    );
  }
}

class SwissMarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double speed;
  final double blankSpace;

  const SwissMarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.speed = 38.0,
    this.blankSpace = 60.0,
  });

  @override
  State<SwissMarqueeText> createState() => _SwissMarqueeTextState();
}

class _SwissMarqueeTextState extends State<SwissMarqueeText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _textWidth = 0.0;
  double _totalLoopWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  void _calculateMetrics() {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    _textWidth = textPainter.width;
    _totalLoopWidth = _textWidth + widget.blankSpace;

    if (_totalLoopWidth > 0 && widget.speed > 0) {
      final int durationMs =
          ((_totalLoopWidth / widget.speed) * 1000).toInt().clamp(1000, 120000);
      final newDuration = Duration(milliseconds: durationMs);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_controller.duration != newDuration) {
          _controller.duration = newDuration;
        }
        if (!_controller.isAnimating) {
          _controller.repeat();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant SwissMarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.speed != widget.speed ||
        oldWidget.style != widget.style) {
      _calculateMetrics();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _calculateMetrics();

        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            minWidth: 0.0,
            maxWidth: double.infinity,
            minHeight: 0.0,
            maxHeight: double.infinity,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double offset = -(_controller.value * _totalLoopWidth);
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.text, style: widget.style, maxLines: 1),
                  SizedBox(width: widget.blankSpace),
                  Text(widget.text, style: widget.style, maxLines: 1),
                  SizedBox(width: widget.blankSpace),
                  Text(widget.text, style: widget.style, maxLines: 1),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

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
    final Paint bgPaint = Paint()..color = CampusColors.canvasPaper;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final Paint dotPaint = Paint()
      ..color = CampusColors.borderHairline.withValues(alpha: 0.65)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    const double spacing = 28.0;
    final List<Offset> points = [];
    for (double x = 14; x < size.width; x += spacing) {
      for (double y = 14; y < size.height; y += spacing) {
        points.add(Offset(x, y));
      }
    }
    canvas.drawPoints(PointMode.points, points, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
