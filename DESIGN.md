# DESIGN.md — CampusTrade UPI YPTK Padang (Hybrid Airbnb × Uber × Stripe/Linear)

> Curated hybrid design system combining [Airbnb](https://getdesign.md/airbnb/design-md) (warm consumer marketplace discovery), [Uber](https://getdesign.md/uber/design-md) (hyper-local geospatial radar & COD logistics), and [Stripe](https://getdesign.md/stripe/design-md) / [Linear](https://getdesign.md/linear.app/design-md) (fintech escrow invoice & dark-mode administrative telemetry).

## 1. Visual Theme & Atmosphere

- **Dual-Polarity Experience**:
  - **Public Student Marketplace (Light Mode — Airbnb × Uber)**: Warm, approachable, photography-driven canvas (`#FFFFFF` over `#F7F7F9` secondary bands). Rounded geometry (`16px` cards, `9999px` pill search and filter chips) replaces stiff technical boxes so student dorm listings feel welcoming and trustworthy.
  - **Admin CMS Console (Dark Mode — Linear × Stripe)**: Ultra-minimal dark craft (`#0B0C10` canvas, `#12141C` charcoal panels, `1px` `#222634` hairline borders, `#5E6AD2` lavender-indigo accents) engineered for high-density telemetry, KTM document inspection, and traffic analytics.
- **Density & Philosophy**: Generous whitespace and image-first hierarchy in the public catalog; compact, high-signal tabular precision in escrow invoices and admin tables.

## 2. Color Palette & Roles

### Public Marketplace Track (Light)
| Token Name | Hex Value | Functional Role |
| :--- | :--- | :--- |
| `Canvas Pure` | `#FFFFFF` | Primary page background, elevated cards, modal surfaces, pill search bar |
| `Canvas Warm` | `#F7F7F9` | Secondary section bands, input fills, subtle card containers |
| `Ink Primary` | `#222222` | Primary headings, product titles, active navigation labels, Uber-style active pills |
| `Ink Secondary` | `#6A6A6A` | Descriptions, kos locations, seller metadata, inactive category tabs |
| `Ink Muted` | `#9CA3AF` | Strikethrough original prices, coordinate hints, placeholders |
| `Border Hairline` | `#EBEBEB` | `1px` card borders, section dividers, input outlines |
| `Rausch Coral` | `#FF385C` | Primary marketplace CTA (`+ Jual Barang`), search orb, savings discount badge |
| `Escrow Indigo` | `#635BFF` | Stripe-style escrow protection box, route polylines, COD spot pins |
| `Verified Emerald` | `#059669` | `QC Pass` badge, `KTM Verified` tag, free campus COD indicator |
| `Caution Amber` | `#D97706` | Pending KTM verification banner, courier fee indicator |
| `Danger Rose` | `#E11D48` | Rejected KTM state, destructive delete actions |

### Admin CMS Track (Dark — Linear Shell)
| Token Name | Hex Value | Functional Role |
| :--- | :--- | :--- |
| `Admin Void` | `#0B0C10` | Main Admin CMS background canvas |
| `Admin Panel` | `#12141C` | KPI bento cards, chart containers, data table rows, sidebar |
| `Admin Elevated` | `#1A1D28` | Hover states, active sidebar item, filter toolbar |
| `Admin Hairline` | `#222634` | `1px` structural borders across all dark panels and tables |
| `Admin Text High` | `#F7F8F8` | Primary metrics, table primary cells, modal titles |
| `Admin Text Low` | `#8A8F98` | Table headers, timestamps, NIM/coordinate metadata |
| `Linear Lavender` | `#5E6AD2` | Primary admin actions, chart line accent, active tab highlight |

## 3. Typography Rules

- **Display & Headings (`Plus Jakarta Sans` / `Airbnb Cereal` style)**:
  - `Hero Display`: `28px–38px`, weight `700`, line-height `1.15`, letter-spacing `-0.6px`.
  - `Section Title`: `20px–24px`, weight `600`, letter-spacing `-0.4px`.
  - `Card Title`: `15px–16px`, weight `600`, line-height `1.3`, `maxLines: 1` with ellipsis.
- **Body & UI (`Plus Jakarta Sans` / `Inter`)**:
  - `Body Default`: `13px–14px`, weight `400–500`, line-height `1.5`, color `#6A6A6A`.
  - `Button Label`: `13px`, weight `600`, letter-spacing `-0.1px`.
- **Numeric, Price & Telemetry (`JetBrains Mono` / Tabular Figures)**:
  - Mandatory `FontFeature.tabularFigures()` (`tabular-nums`) on all Rupiah prices (`Rp 180.000`), distances (`0.42 KM`), GPS coordinates (`-0.9575, 100.3972`), and 14-digit student NIMs (`24101152610172`).

## 4. Component Stylings

1. **Pill Global Search Bar (Airbnb Signature)**:
   - `9999px` full-pill radius, white surface (`#FFFFFF`), `1px` border (`#DDDDDD`), soft floating shadow (`0 6px 20px rgba(0,0,0,0.06)`), trailing circular `#FF385C` search button.
2. **Product Listing Card (Airbnb × mydealz)**:
   - `16px` border radius, `185px` top image container with `14px` inner rounding or flush top clip.
   - Frosted glass top-left badge (`● QC Verified`) and top-right distance pill (`0.3 KM`).
   - Bottom row displays strikethrough original price, bold tabular current price, and soft coral/emerald savings pill (`-60%`).
3. **Geospatial Radar & Pickup–Dropoff Card (Uber Signature)**:
   - Map container framed with `16px` radius.
   - Radius selector rendered as horizontal `999px` pill chips (`#000000` fill when active, `#F3F4F6` when inactive).
   - Route summary inside Product Detail displays a vertical connector linking Seller Kos (`● Kos Melati`) to Campus COD Spot (`■ Lobi UCC`).
4. **Escrow Cost Breakdown Card (Stripe Signature)**:
   - Tinted surface (`#F8FAFC`), `12px` radius, `1px` border (`#E2E8F0`), itemized lines for *Harga Unit*, *Jasa Verifikasi Fisik & Rekber Admin*, and *Tarif Kurir Antar-Kos*, culminating in a bold `#635BFF` total row and a sticky bottom reservation bar.
5. **Admin CMS Cards & Tables (Linear Signature)**:
   - Dark `#12141C` cards with `12px` radius and `1px` `#222634` border.
   - Dual-responsive data presentation: touch-friendly stacked cards below `840px` and proportional flex-column tables at `>= 840px`.

## 5. Layout Principles

- **4px Base Spacing Unit**: Micro-gaps at `4px` and `8px`; card padding at `16px–20px`; section rhythm at `28px–40px`.
- **Max Container Width**: `1240px` centered for the public marketplace; `1360px` fluid workspace for the Admin CMS.
- **Zero Rigid Grid Heights**: All multi-column grids must size vertically by intrinsic content height per row (`IntrinsicHeight`), never by fixed pixel `mainAxisExtent`.

## 6. Depth & Elevation

- **Tier 1 (Resting Card)**: `1px` solid `#EBEBEB` with subtle ambient shadow (`0 2px 6px rgba(0,0,0,0.03)`).
- **Tier 2 (Floating Search / Sticky Bar)**: `0 8px 24px rgba(0,0,0,0.08)` with `1px` border.
- **Tier 3 (Modal Sheet)**: `0 24px 48px rgba(0,0,0,0.18)` with `20px` rounded corners.

## 7. Do's and Don'ts

- **DO** use `Rausch Coral (#FF385C)` exclusively for primary marketplace CTAs and discount highlights so action points pop immediately against the white canvas.
- **DO** use `isExpanded: true` on all dropdown fields and wrap all row text in `Expanded` or `Flexible` to guarantee zero `RenderFlex` overflow.
- **DON'T** use fixed-height `GridView` cells for cards containing variable-length text.
- **DON'T** mix the dark Linear palette into the public student catalog; keep the public catalog bright and welcoming, and reserve the dark shell strictly for the Admin CMS.

## 8. Responsive Behavior

| Breakpoint | Width Range | Layout & Navigation Adaptation |
| :--- | :--- | :--- |
| **Mobile** | `< 540px` | 1-column product feed, 2-row compact top header with full-width pill search, 5-slot `Expanded` bottom navigation bar, stacked form rows, and mobile cards in Admin CMS. |
| **Tablet** | `540px – 959px` | 2-to-3 column product feed, drawer sidebar in Admin CMS, 2-column KPI grid. |
| **Desktop** | `>= 960px` | 4-column product feed, single-row header with inline centered pill search, 7:5 split Hero & Map panels, persistent `256px` dark sidebar + full-width proportional tables in Admin CMS. |

## 9. Agent Prompt Guide

- **Quick Reference**: `"Apply the Hybrid DESIGN.md (Airbnb warm white + #FF385C pill marketplace, Uber black/white 999px geospatial COD radar, Stripe #635BFF tabular escrow invoice, and Linear #0B0C10 dark Admin CMS) with strict zero-overflow responsive primitives."`
