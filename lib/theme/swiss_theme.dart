import 'dart:ui' show PointMode;
import 'package:flutter/material.dart';

/// ============================================================================
/// HYBRID DESIGN SYSTEM (Airbnb × Uber × Stripe × Linear)
/// [DESIGN.md Parity & Anti-Slop UI Architecture]
/// ============================================================================
class SwissColors {
  // --- TRACK A: PUBLIC MARKETPLACE (AIRBNB LIGHT MODE) ---
  static const Color canvasPure = Color(0xFFFFFFFF);
  static const Color canvasWarm = Color(0xFFF7F7F9);
  static const Color inkPrimary = Color(0xFF222222);
  static const Color inkSecondary = Color(0xFF6A6A6A);
  static const Color inkMuted = Color(0xFF9CA3AF);
  static const Color borderHairline = Color(0xFFEBEBEB);

  // Accents (Airbnb & Quality Indicators)
  static const Color rauschCoral = Color(0xFFFF385C); // Primary CTA (+ Jual), Search Orb, Discounts
  static const Color verifiedEmerald = Color(0xFF059669); // QC Pass, KTM Verified, COD Gratis
  static const Color cautionAmber = Color(0xFFD97706); // Pending KTM, Courier fee
  static const Color dangerRose = Color(0xFFE11D48); // Rejected KTM, Delete

  // --- TRACK B: GEOSPATIAL RADAR & COD LOGISTICS (UBER HIGH CONTRAST) ---
  static const Color uberBlack = Color(0xFF000000);
  static const Color uberGrayInactive = Color(0xFFF3F4F6);
  static const Color uberBorder = Color(0xFFE5E7EB);

  // --- TRACK C: FINTECH ESCROW & ADMIN CMS (STRIPE × LINEAR DARK MODE) ---
  static const Color escrowIndigo = Color(0xFF635BFF); // Stripe Escrow Indigo
  static const Color escrowBg = Color(0xFFF8FAFC);
  static const Color escrowBorder = Color(0xFFE2E8F0);

  // Linear Dark Console Tokens
  static const Color adminVoid = Color(0xFF0B0C10); // Main canvas
  static const Color adminPanel = Color(0xFF12141C); // Bento cards, sidebar, table rows
  static const Color adminElevated = Color(0xFF1A1D28); // Hover, active item, toolbar
  static const Color adminHairline = Color(0xFF222634); // 1px borders
  static const Color adminTextHigh = Color(0xFFF7F8F8); // Primary high-contrast text
  static const Color adminTextLow = Color(0xFF8A8F98); // Secondary text, headers
  static const Color linearLavender = Color(0xFF5E6AD2); // Lavender accent

  // Existing Swiss Legacy Compatibility Tokens
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

  static Color? get canvasSubtle => null;
}

class SwissTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: SwissColors.canvasPure,
      colorScheme: const ColorScheme.light(
        primary: SwissColors.rauschCoral,
        secondary: SwissColors.escrowIndigo,
        surface: SwissColors.canvasPure,
        error: SwissColors.dangerRose,
      ),
      dividerColor: SwissColors.borderHairline,
      cardTheme: CardThemeData(
        color: SwissColors.canvasPure,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SwissColors.borderHairline),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SwissColors.inkPrimary,
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

  static ThemeData get darkAdminTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: SwissColors.adminVoid,
      colorScheme: const ColorScheme.dark(
        primary: SwissColors.linearLavender,
        secondary: SwissColors.escrowIndigo,
        surface: SwissColors.adminPanel,
        error: SwissColors.dangerRose,
      ),
      dividerColor: SwissColors.adminHairline,
      cardTheme: CardThemeData(
        color: SwissColors.adminPanel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: SwissColors.adminHairline),
        ),
      ),
    );
  }

  static TextStyle display({
    double size = 18,
    FontWeight weight = FontWeight.w700,
    Color color = SwissColors.inkPrimary,
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
    Color color = SwissColors.inkSecondary,
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
    Color color = SwissColors.inkSecondary,
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

  /// Format Rupiah dengan Tabular Figures (contoh: Rp 180.000)
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

/// Grid responsif yang membungkus setiap baris dengan IntrinsicHeight
/// sehingga mencegah error RenderFlex overflowed dan menghapus pembatasan kaku fixed mainAxisExtent.
class SwissResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  final double runSpacing;

  const SwissResponsiveGrid({
    super.key,
    required this.children,
    required this.crossAxisCount,
    this.spacing = 18.0,
    this.runSpacing = 18.0,
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
        final int end = (i + safeCols < children.length) ? i + safeCols : children.length;
        final List<Widget> rowChildren = [];

        for (int j = i; j < end; j++) {
          rowChildren.add(Expanded(child: children[j]));
          if (j < end - 1) {
            rowChildren.add(SizedBox(width: spacing));
          }
        }

        // Isi slot kosong pada baris terakhir agar lebar kolom konsisten
        final int remaining = safeCols - (end - i);
        for (int k = 0; k < remaining; k++) {
          rowChildren.add(SizedBox(width: spacing));
          rowChildren.add(const Expanded(child: SizedBox.shrink()));
        }

        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
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

/// Header responsif adaptif yang membagi Judul/Subjudul di kiri dan Aksi/Filter di kanan,
/// otomatis membungkus (wrap) dengan rapi di layar sempit tanpa overflow.
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

/// Pembungkus dua input form bersebelahan pada layar lebar (>= breakpoint)
/// dan tersusun vertikal pada layar mobile (< breakpoint) untuk menjamin zero overflow.
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

/// Running Text (Marquee) presisi tinggi untuk banner pengumuman & ticker info,
/// dengan pergerakan konstan mulus (60 FPS) tanpa jitter dan loop tak berujung.
class SwissMarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double speed; // piksel per detik, default 38.0
  final double blankSpace; // jarak pemisah antar perulangan teks

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

/// Architectural Radial Dot Grid Background
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
    final Paint bgPaint = Paint()..color = SwissColors.canvasWarm;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final Paint dotPaint = Paint()
      ..color = SwissColors.borderHairline
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    const double spacing = 24.0;
    final List<Offset> points = [];
    for (double x = 12; x < size.width; x += spacing) {
      for (double y = 12; y < size.height; y += spacing) {
        points.add(Offset(x, y));
      }
    }
    canvas.drawPoints(PointMode.points, points, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
