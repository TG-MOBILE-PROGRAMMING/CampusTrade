import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/swiss_theme.dart';

/// ============================================================================
/// CAMPUSTRADE MOTION & MICRO-INTERACTIONS (MOTION 2)
/// Purposeful, crisp physics that respect reduced-motion accessibility settings.
/// ============================================================================
class CampusMotion {
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration standard = Duration(milliseconds: 240);
  static const Duration entrance = Duration(milliseconds: 320);
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve springPop = Curves.easeOutBack;
}

/// Editorial page transition: subtle 4% vertical slide + fade (260ms).
Route<T> buildCampusRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) {
        return child;
      }
      final CurvedAnimation curved = CurvedAnimation(
        parent: animation,
        curve: CampusMotion.easeOut,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.035),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Tactile press wrapper: subtle 0.97 scale-down on tap with hover highlight.
class TactilePress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final double pressedScale;
  final bool enableHaptics;

  const TactilePress({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.pressedScale = 0.975,
    this.enableHaptics = true,
  });

  @override
  State<TactilePress> createState() => _TactilePressState();
}

class _TactilePressState extends State<TactilePress> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final double scale = (!reduceMotion && _isPressed) ? widget.pressedScale : 1.0;

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
        onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
        onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
        onTap: widget.onTap == null
            ? null
            : () {
                if (widget.enableHaptics) {
                  HapticFeedback.selectionClick();
                }
                widget.onTap!();
              },
        child: AnimatedScale(
          scale: scale,
          duration: CampusMotion.fast,
          curve: CampusMotion.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Wishlist heart button with spring pop animation and 44x44 accessible tap target.
class BouncyHeartButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onToggle;
  final bool showBackdrop;

  const BouncyHeartButton({
    super.key,
    required this.isFavorite,
    required this.onToggle,
    this.showBackdrop = true,
  });

  @override
  State<BouncyHeartButton> createState() => _BouncyHeartButtonState();
}

class _BouncyHeartButtonState extends State<BouncyHeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.28), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.28, end: 0.92), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    if (!MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0);
    }
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.isFavorite ? 'Hapus dari wishlist' : 'Simpan ke wishlist',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Container(
                width: 34,
                height: 34,
                decoration: widget.showBackdrop
                    ? BoxDecoration(
                        color: CampusColors.surfacePure.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CampusColors.borderHairline,
                          width: 1,
                        ),
                      )
                    : null,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Icon(
                    widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: widget.isFavorite
                        ? CampusColors.terracotta
                        : CampusColors.inkSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One-shot staggered entrance for grid items and detail cards (no endless loops).
class StaggeredEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final double offsetY;

  const StaggeredEntrance({
    super.key,
    required this.child,
    required this.index,
    this.offsetY = 14.0,
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: CampusMotion.entrance,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: CampusMotion.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offsetY),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: CampusMotion.easeOut));

    final int delayMs = (widget.index * 45).clamp(0, 270);
    Future<void>.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: _slide.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Animated price display that smoothly rolls when delivery options change total.
class AnimatedPriceText extends StatelessWidget {
  final String formattedPrice;
  final TextStyle style;

  const AnimatedPriceText({
    super.key,
    required this.formattedPrice,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text(formattedPrice, style: style);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: CampusMotion.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.25),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        formattedPrice,
        key: ValueKey<String>(formattedPrice),
        style: style,
      ),
    );
  }
}

/// Minimalist warm-stone loading shimmer (stops as soon as content loads).
class CampusShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  const CampusShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  State<CampusShimmerBox> createState() => _CampusShimmerBoxState();
}

class _CampusShimmerBoxState extends State<CampusShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: CampusColors.surfaceSubtle,
          borderRadius: widget.borderRadius,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final double slide = (_controller.value * 2) - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(slide - 0.8, 0),
              end: Alignment(slide + 0.8, 0),
              colors: const [
                CampusColors.surfaceSubtle,
                CampusColors.canvasPaper,
                CampusColors.surfaceSubtle,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Product photo with smooth fade-in, warm shimmer placeholder, and clean
/// minimalist category fallback when offline or URL unavailable.
class CampusProductImage extends StatelessWidget {
  final String imageUrl;
  final String category;
  final IconData fallbackIcon;
  final BoxFit fit;

  const CampusProductImage({
    super.key,
    required this.imageUrl,
    required this.category,
    required this.fallbackIcon,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasUrl = imageUrl.trim().startsWith('http');
    if (!hasUrl) {
      return _buildFallback();
    }

    return Image.network(
      imageUrl,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0.0 : 1.0,
          duration: CampusMotion.standard,
          curve: CampusMotion.easeOut,
          child: frame == null ? const CampusShimmerBox() : child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const CampusShimmerBox(borderRadius: BorderRadius.zero);
      },
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: CampusColors.surfaceSubtle,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: CampusColors.surfacePure,
                shape: BoxShape.circle,
                border: Border.all(color: CampusColors.borderHairline),
              ),
              child: Icon(
                fallbackIcon,
                size: 26,
                color: CampusColors.campusForest,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SwissTheme.sans(
                  size: 11,
                  weight: FontWeight.w600,
                  color: CampusColors.inkMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
