import 'package:flutter/material.dart';
import '../theme/swiss_theme.dart';
import 'campus_motion.dart';

/// ============================================================================
/// TRUST SIGNALS & ESCROW TRANSPARENCY WIDGETS
/// Built on real product mechanics (KTM verification, physical QC, campus COD).
/// Zero fabricated statistics or fake testimonials (R-17, R-18, R-36).
/// ============================================================================

/// Compact condition status stamp (6px radius) for product cards and detail hero.
class ConditionBadge extends StatelessWidget {
  final String rawCondition;

  const ConditionBadge({super.key, required this.rawCondition});

  String get _shortLabel {
    final String lower = rawCondition.toLowerCase();
    if (lower.contains('like new') || lower.contains('sangat mulus')) {
      return 'Like New';
    }
    if (lower.contains('mulus')) {
      return 'Mulus';
    }
    return 'Layak Pakai';
  }

  @override
  Widget build(BuildContext context) {
    final bool isTopGrade = _shortLabel == 'Like New';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isTopGrade
            ? CampusColors.campusForest
            : CampusColors.surfacePure.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isTopGrade
              ? CampusColors.campusForest
              : CampusColors.borderHairline,
        ),
      ),
      child: Text(
        _shortLabel,
        style: SwissTheme.sans(
          size: 10.5,
          weight: FontWeight.w700,
          color: isTopGrade ? Colors.white : CampusColors.inkPrimary,
          height: 1.1,
        ),
      ),
    );
  }
}

/// Interactive Trust Strip on Home Screen. Tapping opens the Escrow & KTM Guide.
class CampusTrustStrip extends StatelessWidget {
  final bool isDesktop;

  const CampusTrustStrip({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final List<_TrustSignalItem> items = const [
      _TrustSignalItem(
        icon: Icons.verified_user_outlined,
        label: 'KTM Terverifikasi',
        detail: 'Khusus mahasiswa aktif',
      ),
      _TrustSignalItem(
        icon: Icons.shield_outlined,
        label: 'Rekber Aman',
        detail: 'Dana cair pasca cek fisik',
      ),
      _TrustSignalItem(
        icon: Icons.handshake_outlined,
        label: 'COD Gratis Kampus',
        detail: 'Pos Satpam & Lobi 24J',
      ),
      _TrustSignalItem(
        icon: Icons.local_shipping_outlined,
        label: 'Kurir Antar Kos',
        detail: 'Bantu angkut kasur & meja',
      ),
    ];

    return TactilePress(
      onTap: () => showEscrowExplainerSheet(context),
      borderRadius: BorderRadius.circular(14),
      pressedScale: 0.99,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: CampusColors.surfacePure,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CampusColors.borderHairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_outlined,
                        size: 15,
                        color: CampusColors.verifiedJade,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Standar Keamanan Transaksi Kampus',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SwissTheme.sans(
                            size: 12,
                            weight: FontWeight.w700,
                            color: CampusColors.inkPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Cara kerja',
                      style: SwissTheme.sans(
                        size: 11.5,
                        weight: FontWeight.w700,
                        color: CampusColors.campusForest,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: CampusColors.campusForest,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (isDesktop)
              Row(
                children: items
                    .map(
                      (item) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _buildItem(item, expandText: true),
                        ),
                      ),
                    )
                    .toList(),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: items
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: _buildItem(item),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(_TrustSignalItem item, {bool expandText = false}) {
    final Widget textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: SwissTheme.sans(
            size: 11.5,
            weight: FontWeight.w700,
            color: CampusColors.inkPrimary,
            height: 1.2,
          ),
        ),
        Text(
          item.detail,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: SwissTheme.sans(
            size: 10.5,
            color: CampusColors.inkMuted,
            height: 1.25,
          ),
        ),
      ],
    );

    return Row(
      mainAxisSize: expandText ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: CampusColors.campusForestSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            item.icon,
            size: 16,
            color: CampusColors.campusForest,
          ),
        ),
        const SizedBox(width: 8),
        if (expandText) Expanded(child: textColumn) else textColumn,
      ],
    );
  }
}

class _TrustSignalItem {
  final IconData icon;
  final String label;
  final String detail;

  const _TrustSignalItem({
    required this.icon,
    required this.label,
    required this.detail,
  });
}

/// Interactive Bottom Sheet explaining the real 3-step CampusTrade Escrow & QC flow.
void showEscrowExplainerSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: CampusColors.surfacePure,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CampusColors.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Alur Aman CampusTrade',
                      style: SwissTheme.display(size: 18, weight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: CampusColors.inkSecondary),
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              Text(
                'Setiap penjual melewati pengecekan KTM mahasiswa, dan setiap transaksi dijaga oleh rekber tim perantara.',
                style: SwissTheme.sans(
                  size: 12.5,
                  color: CampusColors.inkSecondary,
                ),
              ),
              const SizedBox(height: 18),
              _buildFlowStep(
                step: '01',
                title: 'Verifikasi KTM & Kurasi Fisik',
                desc:
                    'Penjual wajib memverifikasi kartu mahasiswa (KTM/KRS) dan barang diperiksa kelayakannya sebelum tampil di katalog.',
              ),
              const SizedBox(height: 12),
              _buildFlowStep(
                step: '02',
                title: 'Cek Barang di Titik COD atau Antar Kos',
                desc:
                    'Temui tim di titik pantau kampus (Pos Satpam 24 Jam, Lobi Gedung B, UCC) tanpa ongkir, atau pilih kurir kos untuk perabotan berat.',
              ),
              const SizedBox(height: 12),
              _buildFlowStep(
                step: '03',
                title: 'Dana Cair Setelah Pembeli Setuju',
                desc:
                    'Dana disimpan di rekening perantara (rekber) dan baru diteruskan ke penjual setelah barang diterima sesuai deskripsi.',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CampusColors.campusForest,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Mengerti',
                    style: SwissTheme.display(
                      size: 13.5,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildFlowStep({
  required String step,
  required String title,
  required String desc,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: CampusColors.campusForestSoft,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            step,
            style: SwissTheme.mono(
              size: 11.5,
              weight: FontWeight.w800,
              color: CampusColors.campusForest,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: SwissTheme.display(size: 13.5, weight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: SwissTheme.sans(
                size: 12,
                color: CampusColors.inkSecondary,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
