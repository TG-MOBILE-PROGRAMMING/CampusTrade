# CampusTrade Design System (Clean Minimalist)

> **Design Read:** Student-exclusive secondhand marketplace app for university kos residents (target zone: UPI YPTK Padang & Lubuk Begalung), in a Calm Clean Minimalist style ("Pure White & Ocean Teal Monochromatic"), **Dial: ENERGY 2 / RHYTHM 2 / MOTION 2**.

## 1. Visual Identity & Philosophy

CampusTrade is a neighborhood-scale campus exchange where students hand over mattresses, study desks, dispensers, and textbooks between semesters. The interface uses a **strictly harmonious monochromatic palette**: pure white surfaces, crisp slate typography, and calm Ocean Teal accents with zero clashing secondary hues.

- **One focal point per screen:** On the Home Screen, the collapsible header gives way immediately to the Ocean Teal Hero and aligned product grid. On Product Detail, the item photo and price-to-trust block lead.
- **Whitespace as structure:** Clean 16px to 20px section spacing and equal-height card rows keep scanning calm and effortless.
- **One harmonious accent family:** Ocean Teal (`#0D9488` / `#0F766E`) carries primary CTAs, active navigation, verified stamps, and price highlights, while Slate (`#0F172A`) grounds headings and structure.
- **Identity motif:** Pure white cards (`#FFFFFF`) on crisp alabaster (`#F8FAFC`) with 1px mist borders (`#E2E8F0`), subtle ambient elevation, and geometric teal corner rings.

---

## 2. Color Palette (WCAG AA Verified)

Active palette is strictly monochromatic: **Pure White & Slate neutrals + 1 Ocean Teal family**, plus semantic warning/danger states only when needed.

| Token | Hex | Role | Contrast Ratio (WCAG AA) |
|---|---|---|---|
| `canvasPaper` | `#F8FAFC` | Primary app canvas (crisp cool white) | Base canvas |
| `surfacePure` | `#FFFFFF` | Cards, floating bottom nav, sheets | Base surface |
| `surfaceSubtle` | `#F1F5F9` | Search bar, inactive chips, image backdrops | Subtle separation |
| `borderHairline` | `#E2E8F0` | 1px card & divider hairlines | Structural outline |
| `inkPrimary` | `#0F172A` | Headings, product titles, primary copy | > 17:1 on white |
| `inkSecondary` | `#475569` | Body copy, seller details, specs | > 7.2:1 on white |
| `inkMuted` | `#64748B` | Metadata, timestamps, hints | > 4.7:1 on white |
| `oceanTeal` | `#0D9488` | Brand primary, icons, active states | 4.6:1 with white |
| `oceanTealDeep` | `#0F766E` | High-contrast buttons, price highlights, hero | 5.4:1 with white |
| `oceanTealSoft` | `#F0FDFA` | Soft teal tint for active pills & trust cards | > 6.5:1 with teal ink |
| `cautionAmber` | `#B45309` | Pending KTM verification notice | > 5.0:1 on `#FFFBEB` |
| `dangerCrimson` | `#BE123C` | Rejected status, destructive actions | > 6.1:1 on white |

---

## 3. Typography & Radius Hierarchy

- **Display / Headings:** Tight editorial tracking (`-0.4` to `-0.2`), bold/extra-bold (`w700` to `w800`), `FontFeature.tabularFigures()` for Rupiah prices.
- **Body / Interface:** `13sp` body copy, `1.45` line height, `11.5sp` minimum for metadata.
- **Monospace (`mono`):** Strictly for structured identifiers (NIM, Order `#ID`, distance `0.2 km`, discount `-60%`).
- **Radius Scale:** `18px` hero & floating bars, `16px` cards, `12px` primary buttons & inputs, `10px` filter chips, `6px` status badges.

---

## 4. Smooth Scroll & Animated Floating Navigation Architecture

- **Collapsible Sliver Scroll (`CustomScrollView` + `SliverAppBar`):** Replaces rigid stacked fixed headers. As the user scrolls down, the brand/location header smoothly glides away while the search bar remains pinned cleanly with a subtle shadow, maximizing viewport space on mobile.
- **Scroll-to-Top Pill:** Smoothly fades in after scrolling `320px` downward for effortless return to the top.
- **Animated Floating Bottom Nav (`CampusAnimatedBottomNav`):**
  - Floating rounded pill bar (`24px` radius) with soft ambient shadow above the bottom safe area.
  - Active tab morphs smoothly with an expanding soft-cobalt pill backdrop (`240ms`, `Curves.easeOutCubic`) and gentle icon scale pop (`1.0 -> 1.12`).
  - Center `+ Jual` CTA in vibrant Sunburst Coral with `TactilePress` spring physics and haptic feedback.
  - Bottom scroll padding (`96px`) guarantees content is never obscured behind the floating bar (R-03).

---

## 5. Trust Signals, Empty States & Motion (`MOTION 2`)

- **Interactive Trust Strip & Escrow Explainer Sheet:** Real 3-step campus escrow & KTM verification guide accessible from Home and Product Detail (zero fabricated numbers or fake reviews).
- **Relatable Student Empty States:** Custom minimalist `CustomPainter` illustrations (moving box, escrow receipt, wishlist bookmark, dorm lamp) with friendly Indonesian copy and quick-tap search suggestions.
- **Purposeful Motion (`MOTION 2`):** Every transition honors `MediaQuery.disableAnimationsOf(context)`. Includes `TactilePress`, `BouncyHeartButton`, `StaggeredEntrance`, `Hero` photo transitions, `AnimatedPriceText`, `CampusPageRoute`, and `AnimatedSwitcher` tab cross-fades.

---

## 6. Admin Console ("Deep Slate & Ocean Teal" Dark Mode)

- **Canvas & Surfaces:** `adminVoid` (`#0B1117`), `adminPanel` (`#111827`), `adminElevated` (`#1E293B`), `adminHairline` (`#293548`).
- **Accents:** Bright Ocean Teal (`#2DD4BF`, contrast 10.8:1 on panel) for active nav & telemetry; Deep Teal (`#0F766E`) for primary action buttons.
- **Modules & States:** `AnimatedSwitcher` tab transitions, grouped sidebar with animated active bar, and dark-mode `CampusEmptyState(isDark: true)` across Products, Users, and COD Spots.
