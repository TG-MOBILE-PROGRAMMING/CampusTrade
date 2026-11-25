import 'package:flutter/material.dart';
import '../theme/swiss_theme.dart';
import 'campus_motion.dart';

enum CampusEmptyKind {
  searchEmpty,
  ordersEmpty,
  wishlistEmpty,
  listingsEmpty,
}

/// ============================================================================
/// RELATABLE STUDENT EMPTY STATE
/// Custom minimalist geometric illustrations + student-friendly Indonesian copy
/// + clear actionable next step (R-27 compliant).
/// ============================================================================
class CampusEmptyState extends StatelessWidget {
  final CampusEmptyKind kind;
  final String title;
  final String subtitle;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final List<String> suggestionChips;
  final ValueChanged<String>? onSuggestionTap;
  final bool isDark;

  const CampusEmptyState({
    super.key,
    required this.kind,
    required this.title,
    required this.subtitle,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.suggestionChips = const [],
    this.onSuggestionTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBg =
        isDark ? CampusColors.adminPanel : CampusColors.surfacePure;
    final Color borderColor =
        isDark ? CampusColors.adminHairline : CampusColors.borderHairline;
    final Color titleColor =
        isDark ? CampusColors.adminTextHigh : CampusColors.inkPrimary;
    final Color subtitleColor =
        isDark ? CampusColors.adminTextLow : CampusColors.inkSecondary;
    final Color chipBg =
        isDark ? CampusColors.adminElevated : CampusColors.surfaceSubtle;
    final Color btnBg =
        isDark ? CampusColors.campusForestLight : CampusColors.campusForest;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 112,
            height: 96,
            child: CustomPaint(
              painter: _CampusEmptyIllustrationPainter(
                kind: kind,
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: SwissTheme.display(
              size: 16.5,
              weight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: SwissTheme.sans(
                size: 12.5,
                height: 1.5,
                color: subtitleColor,
              ),
            ),
          ),
          if (suggestionChips.isNotEmpty && onSuggestionTap != null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestionChips.map((term) {
                return TactilePress(
                  onTap: () => onSuggestionTap!(term),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      term,
                      style: SwissTheme.sans(
                        size: 12,
                        weight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (primaryActionLabel != null && onPrimaryAction != null) ...[
            const SizedBox(height: 20),
            TactilePress(
              onTap: onPrimaryAction,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: btnBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  primaryActionLabel!,
                  style: SwissTheme.display(
                    size: 13,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Minimalist editorial line-and-shape illustration tailored to student kos life.
class _CampusEmptyIllustrationPainter extends CustomPainter {
  final CampusEmptyKind kind;
  final bool isDark;

  const _CampusEmptyIllustrationPainter({
    required this.kind,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Soft backdrop circle
    final Paint bgCircle = Paint()
      ..color = isDark ? CampusColors.adminElevated : CampusColors.surfaceSubtle;
    canvas.drawCircle(center, 42, bgCircle);

    final Paint strokeForest = Paint()
      ..color = isDark ? CampusColors.adminSky : CampusColors.campusCobalt
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint fillPaper = Paint()
      ..color = isDark ? CampusColors.adminPanel : CampusColors.surfacePure;
    final Paint accentFill = Paint()
      ..color = isDark
          ? CampusColors.adminSky.withValues(alpha: 0.18)
          : CampusColors.oceanTealSoft;
    final Paint accentStroke = Paint()
      ..color = isDark ? CampusColors.adminSky : CampusColors.oceanTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    switch (kind) {
      case CampusEmptyKind.searchEmpty:
        // Open cardboard kos moving box + magnifying lens
        final RRect box = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(center.dx - 4, center.dy + 10), width: 46, height: 32),
          const Radius.circular(6),
        );
        canvas.drawRRect(box, fillPaper);
        canvas.drawRRect(box, strokeForest);
        // Box flaps
        final Path leftFlap = Path()
          ..moveTo(center.dx - 27, center.dy - 6)
          ..lineTo(center.dx - 34, center.dy - 16)
          ..lineTo(center.dx - 6, center.dy - 16)
          ..lineTo(center.dx - 4, center.dy - 6);
        final Path rightFlap = Path()
          ..moveTo(center.dx + 19, center.dy - 6)
          ..lineTo(center.dx + 26, center.dy - 16)
          ..lineTo(center.dx - 2, center.dy - 16)
          ..lineTo(center.dx - 4, center.dy - 6);
        canvas.drawPath(leftFlap, fillPaper);
        canvas.drawPath(rightFlap, fillPaper);
        canvas.drawPath(leftFlap, strokeForest);
        canvas.drawPath(rightFlap, strokeForest);
        // Terracotta magnifying glass badge
        final Offset lensCenter = Offset(center.dx + 22, center.dy + 14);
        canvas.drawCircle(lensCenter, 12, accentFill);
        canvas.drawCircle(lensCenter, 12, accentStroke);
        canvas.drawLine(
          Offset(lensCenter.dx + 8, lensCenter.dy + 8),
          Offset(lensCenter.dx + 15, lensCenter.dy + 15),
          accentStroke,
        );
        break;

      case CampusEmptyKind.ordersEmpty:
        // Minimalist escrow ticket / receipt
        final RRect ticket = RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: 44, height: 54),
          const Radius.circular(8),
        );
        canvas.drawRRect(ticket, fillPaper);
        canvas.drawRRect(ticket, strokeForest);
        // Receipt lines
        canvas.drawLine(
          Offset(center.dx - 12, center.dy - 12),
          Offset(center.dx + 12, center.dy - 12),
          strokeForest,
        );
        canvas.drawLine(
          Offset(center.dx - 12, center.dy - 2),
          Offset(center.dx + 6, center.dy - 2),
          strokeForest,
        );
        canvas.drawLine(
          Offset(center.dx - 12, center.dy + 8),
          Offset(center.dx + 10, center.dy + 8),
          strokeForest,
        );
        // Terracotta stamp circle
        canvas.drawCircle(Offset(center.dx + 18, center.dy + 16), 11, accentFill);
        canvas.drawCircle(Offset(center.dx + 18, center.dy + 16), 11, accentStroke);
        break;

      case CampusEmptyKind.wishlistEmpty:
        // Minimalist bookmark card + outline heart
        final RRect card = RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: 48, height: 54),
          const Radius.circular(10),
        );
        canvas.drawRRect(card, fillPaper);
        canvas.drawRRect(card, strokeForest);
        final Path heart = Path()
          ..moveTo(center.dx, center.dy + 10)
          ..cubicTo(
            center.dx - 16,
            center.dy,
            center.dx - 14,
            center.dy - 14,
            center.dx,
            center.dy - 5,
          )
          ..cubicTo(
            center.dx + 14,
            center.dy - 14,
            center.dx + 16,
            center.dy,
            center.dx,
            center.dy + 10,
          );
        canvas.drawPath(heart, accentFill);
        canvas.drawPath(heart, accentStroke);
        break;

      case CampusEmptyKind.listingsEmpty:
        // Minimalist dorm shelf / lamp icon
        final RRect shelf = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(center.dx, center.dy + 16), width: 56, height: 10),
          const Radius.circular(4),
        );
        canvas.drawRRect(shelf, fillPaper);
        canvas.drawRRect(shelf, strokeForest);
        // Lamp shade
        final Path shade = Path()
          ..moveTo(center.dx - 14, center.dy - 2)
          ..lineTo(center.dx - 8, center.dy - 20)
          ..lineTo(center.dx + 8, center.dy - 20)
          ..lineTo(center.dx + 14, center.dy - 2)
          ..close();
        canvas.drawPath(shade, accentFill);
        canvas.drawPath(shade, accentStroke);
        // Lamp stand
        canvas.drawLine(
          Offset(center.dx, center.dy - 2),
          Offset(center.dx, center.dy + 11),
          strokeForest,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _CampusEmptyIllustrationPainter oldDelegate) =>
      oldDelegate.kind != kind || oldDelegate.isDark != isDark;
}
