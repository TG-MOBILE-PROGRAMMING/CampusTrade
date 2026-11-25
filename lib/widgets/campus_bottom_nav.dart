import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/swiss_theme.dart';
import 'campus_motion.dart';

/// ============================================================================
/// ANIMATED FLOATING BOTTOM NAVIGATION BAR
/// - Floating rounded pill bar with soft ambient elevation
/// - Smooth expanding Cobalt pill indicator + animated icon scale pop
/// - Tactile Sunburst Coral center "+ Jual" action button
/// - Respects reduced motion & 44px+ accessible tap targets
/// ============================================================================
class CampusAnimatedBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onSellTap;
  final int pendingOrdersCount;

  const CampusAnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
    required this.onSellTap,
    this.pendingOrdersCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: CampusColors.surfacePure,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: CampusColors.borderHairline),
            boxShadow: const [
              BoxShadow(
                color: Color(0x160F172A),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x080F172A),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _AnimatedNavTab(
                  active: currentIndex == 0,
                  icon: Icons.storefront_outlined,
                  activeIcon: Icons.storefront_rounded,
                  label: 'Katalog',
                  onTap: () => onSelectTab(0),
                ),
              ),
              Expanded(
                child: _AnimatedNavTab(
                  active: currentIndex == 1,
                  icon: Icons.radar_outlined,
                  activeIcon: Icons.radar_rounded,
                  label: 'Radar',
                  onTap: () => onSelectTab(1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _CenterSellPill(onTap: onSellTap),
              ),
              Expanded(
                child: _AnimatedNavTab(
                  active: currentIndex == 3,
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'Pesanan',
                  badgeCount: pendingOrdersCount,
                  onTap: () => onSelectTab(3),
                ),
              ),
              Expanded(
                child: _AnimatedNavTab(
                  active: currentIndex == 4,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Akun',
                  onTap: () => onSelectTab(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedNavTab extends StatelessWidget {
  final bool active;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badgeCount;
  final VoidCallback onTap;

  const _AnimatedNavTab({
    required this.active,
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 240),
            curve: CampusMotion.easeOut,
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: active
                  ? CampusColors.campusCobaltSoft
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: active && !reduceMotion ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 220),
                  curve: CampusMotion.springPop,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        active ? activeIcon : icon,
                        size: 21,
                        color: active
                            ? CampusColors.campusCobalt
                            : CampusColors.inkMuted,
                      ),
                      if (badgeCount > 0)
                        Positioned(
                          top: -3,
                          right: -6,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: CampusColors.sunburstCoral,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  style: SwissTheme.sans(
                    size: 10,
                    weight: active ? FontWeight.w800 : FontWeight.w500,
                    color: active
                        ? CampusColors.campusCobalt
                        : CampusColors.inkMuted,
                    height: 1.1,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedContainer(
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 240),
                  curve: CampusMotion.easeOut,
                  width: active ? 16 : 0,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: CampusColors.campusCobalt,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterSellPill extends StatelessWidget {
  final VoidCallback onTap;

  const _CenterSellPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TactilePress(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      pressedScale: 0.93,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              CampusColors.oceanTealDeep,
              CampusColors.oceanTeal,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x330D9488),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 19),
            const SizedBox(width: 3),
            Text(
              'Jual',
              style: SwissTheme.display(
                size: 12.5,
                weight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
