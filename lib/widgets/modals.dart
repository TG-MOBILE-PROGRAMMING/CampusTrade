import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/swiss_theme.dart';
import 'geospatial_map_widget.dart';

/// ============================================================================
/// 1. MODAL DETAIL PRODUK (SPECIFICATION SHEET + COST BREAKDOWN + WHATSAPP)
/// ============================================================================
void showProductDetailModal(
  BuildContext context,
  CampusTradeState appState,
  ProductModel product,
) {
  showDialog(
    context: context,
    barrierColor: const Color(0x9909090B),
    builder: (ctx) => _ProductDetailDialog(
      appState: appState,
      product: product,
    ),
  );
}

class _ProductDetailDialog extends StatefulWidget {
  final CampusTradeState appState;
  final ProductModel product;

  const _ProductDetailDialog({
    required this.appState,
    required this.product,
  });

  @override
  State<_ProductDetailDialog> createState() => _ProductDetailDialogState();
}

class _ProductDetailDialogState extends State<_ProductDetailDialog> {
  String _deliveryMethod = 'jemput_admin'; // 'jemput_admin' or 'antar_admin'

  int get _ongkir =>
      _deliveryMethod == 'antar_admin' ? widget.product.biayaOngkir : 0;

  int get _total =>
      widget.product.harga + widget.product.biayaVerifikasi + _ongkir;

  void _triggerWhatsAppOrder() {
    final ProductModel p = widget.product;
    final String adminPhone =
        widget.appState.platformSettings['no_wa_admin'] ?? '6281234567899';
    final String methodText = _deliveryMethod == 'antar_admin'
        ? 'Diantar Langsung ke Kosan oleh Kurir Admin CampusTrade'
        : 'Jemput Sendiri di Kampus (${p.titikCod})';

    final String messageText = 'Halo Admin CampusTrade UPI YPTK Padang,\n\n'
        'Saya mahasiswa berminat transaksi barang terverifikasi anti-penipuan:\n'
        '• *Barang:* ${p.namaBarang}\n'
        '• *Penjual:* ${p.namaPenjual} (Kos: ${p.lokasiKos})\n'
        '• *Opsi Penyerahan:* $methodText\n\n'
        '*Rincian Biaya Transparan:*\n'
        '- Harga Barang: ${SwissTheme.formatRupiah(p.harga)}\n'
        '- Jasa Verifikasi Fisik & Rekber Admin: ${SwissTheme.formatRupiah(p.biayaVerifikasi)}\n'
        '- Ongkir Kurir: ${SwissTheme.formatRupiah(_ongkir)}\n'
        '- *Total Pembayaran:* ${SwissTheme.formatRupiah(_total)}\n\n'
        'Mohon bantuan verifikasi fisik barang dan penjadwalan serah terima. Terima kasih!';

    final String waUrl =
        'https://wa.me/$adminPhone?text=${Uri.encodeComponent(messageText)}';

    Clipboard.setData(ClipboardData(text: messageText));

    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: SwissColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: SwissColors.emerald600,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'WHATSAPP GATEWAY',
                style: SwissTheme.mono(size: 9, color: SwissColors.white),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Format Transaksi Siap Dikirim',
                style: SwissTheme.display(size: 14),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pesan transaksi otomatis telah disalin ke Clipboard & siap diteruskan ke WhatsApp Admin ($adminPhone):',
                style: SwissTheme.sans(size: 11, color: SwissColors.zinc600),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SwissColors.zinc50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SwissColors.zinc200),
                ),
                child: SelectableText(
                  messageText,
                  style: SwissTheme.mono(size: 10, color: SwissColors.zinc800),
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                waUrl,
                maxLines: 2,
                style: SwissTheme.mono(size: 9, color: SwissColors.indigo600),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text('Tutup', style: SwissTheme.sans(size: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProductModel p = widget.product;
    final double dist = p.distanceToCampusKm;
    final int travelMins = (dist * 10).round().clamp(2, 45);

    return Dialog(
      backgroundColor: SwissColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: SwissColors.zinc200),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 672, maxHeight: 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                color: SwissColors.zinc50,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(bottom: BorderSide(color: SwissColors.zinc200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: SwissColors.zinc950,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            p.kategori.toUpperCase(),
                            style: SwissTheme.mono(
                                size: 10, color: SwissColors.white),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: SwissColors.emerald50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: SwissColors.emerald200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: SwissColors.emerald500,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'QC VERIFIED',
                                style: SwissTheme.mono(
                                    size: 10, color: SwissColors.emerald700),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: SwissColors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: SwissColors.zinc200),
                          ),
                          child: Text(
                            '$dist km dr Kampus',
                            style: SwissTheme.mono(
                                size: 10, color: SwissColors.zinc700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            // Modal Scrollable Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Image & Technical Specs
                    LayoutBuilder(
                      builder: (ctx, c) {
                        final bool wide = c.maxWidth >= 500;
                        final Widget imageBox = ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: SwissColors.zinc100,
                              border: Border.all(color: SwissColors.zinc200),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  p.foto,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.image_outlined,
                                        size: 40, color: SwissColors.zinc400),
                                  ),
                                ),
                                Positioned(
                                  left: 8,
                                  bottom: 8,
                                  right: 8,
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xD909090B),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        p.kondisi,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: SwissTheme.mono(
                                            size: 9, color: SwissColors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );

                        final Widget specsBox = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.namaBarang,
                              style: SwissTheme.display(size: 19, height: 1.25),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: SwissColors.zinc50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: SwissColors.zinc200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HARGA BUKA UNIT',
                                    style: SwissTheme.mono(
                                        size: 10, color: SwissColors.zinc400),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.end,
                                    spacing: 8,
                                    children: [
                                      Text(
                                        SwissTheme.formatRupiah(p.harga),
                                        style: SwissTheme.display(size: 24),
                                      ),
                                      Text(
                                        SwissTheme.formatRupiah(
                                            p.effectiveOriginalPrice),
                                        style: SwissTheme.mono(
                                          size: 12,
                                          color: SwissColors.zinc400,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: SwissColors.zinc200),
                              ),
                              child: Column(
                                children: [
                                  _specRow('PENJUAL', p.namaPenjual),
                                  const Divider(height: 1),
                                  _specRow('LOKASI KOS', p.lokasiKos),
                                  const Divider(height: 1),
                                  Container(
                                    color: const Color(0x66EEF2FF),
                                    child: _specRow(
                                      'TITIK COD',
                                      p.titikCod,
                                      highlight: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );

                        if (wide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: imageBox),
                              const SizedBox(width: 18),
                              Expanded(child: specsBox),
                            ],
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            imageBox,
                            const SizedBox(height: 14),
                            specsBox,
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Section 2: Geospatial Route Map
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PETA LOKASI KOS & RUTE TITIK COD',
                          style: SwissTheme.mono(
                              size: 10, color: SwissColors.zinc500),
                        ),
                        Text(
                          '📍 Jarak: $dist km ($travelMins menit jalan/motor)',
                          style: SwissTheme.mono(
                              size: 10, color: SwissColors.indigo600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DetailRouteMiniMap(product: p),

                    const SizedBox(height: 18),

                    // Section 3: Admin QC Inspection Report
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: SwissColors.emerald50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: SwissColors.emerald200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'LAPORAN INSPEKSI FISIK (QC ADMIN)',
                                style: SwissTheme.mono(
                                  size: 10,
                                  weight: FontWeight.w700,
                                  color: SwissColors.emerald800,
                                ),
                              ),
                              Text(
                                'VERIFIED',
                                style: SwissTheme.mono(
                                    size: 9, color: SwissColors.emerald700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p.catatanQcAdmin,
                            style: SwissTheme.sans(
                              size: 12,
                              color: SwissColors.emerald950,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Section 4: Full Description
                    Text(
                      'DESKRIPSI & RIWAYAT PEMAKAIAN',
                      style: SwissTheme.mono(
                          size: 10, color: SwissColors.zinc500),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: SwissColors.zinc50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: SwissColors.zinc200),
                      ),
                      child: Text(
                        p.deskripsi,
                        style: SwissTheme.sans(
                          size: 12,
                          color: SwissColors.zinc700,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Section 5: Fulfillment & Transparent Cost Breakdown
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: SwissColors.zinc50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: SwissColors.zinc200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OPSI SERAH TERIMA & KALKULASI BIAYA TRANSPARAN',
                            style: SwissTheme.mono(
                              size: 10,
                              weight: FontWeight.w700,
                              color: SwissColors.zinc900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (ctx, c) {
                              final Widget optA = _deliveryCard(
                                value: 'jemput_admin',
                                title: 'Jemput COD di Kampus',
                                badge: 'RP 0',
                                badgeColor: SwissColors.emerald700,
                                subtitle:
                                    'Serah terima didampingi admin di titik COD resmi.',
                              );
                              final Widget optB = _deliveryCard(
                                value: 'antar_admin',
                                title: 'Kurir Admin Antar-Kos',
                                badge:
                                    '+${SwissTheme.formatRupiah(p.biayaOngkir)}',
                                badgeColor: SwissColors.indigo600,
                                subtitle:
                                    'Dijemput dari kos penjual & diantar ke kos Anda.',
                              );
                              if (c.maxWidth >= 460) {
                                return Row(
                                  children: [
                                    Expanded(child: optA),
                                    const SizedBox(width: 10),
                                    Expanded(child: optB),
                                  ],
                                );
                              }
                              return Column(
                                children: [
                                  optA,
                                  const SizedBox(height: 8),
                                  optB,
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: SwissColors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: SwissColors.zinc200),
                            ),
                            child: Column(
                              children: [
                                _invoiceRow(
                                  'Harga Unit Inventaris',
                                  SwissTheme.formatRupiah(p.harga),
                                ),
                                const SizedBox(height: 8),
                                _invoiceRow(
                                  'Jasa Verifikasi Fisik & Rekber Admin (PROTEKSI)',
                                  '+${SwissTheme.formatRupiah(p.biayaVerifikasi)}',
                                  valueColor: SwissColors.indigo600,
                                ),
                                const SizedBox(height: 8),
                                _invoiceRow(
                                  'Tarif Pengantaran Kurir Admin',
                                  _ongkir > 0
                                      ? '+${SwissTheme.formatRupiah(_ongkir)} (Kurir Admin)'
                                      : 'Rp 0 (Jemput Mandiri di Kampus)',
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(height: 1),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Estimasi Transaksi',
                                      style: SwissTheme.display(size: 13),
                                    ),
                                    Text(
                                      SwissTheme.formatRupiah(_total),
                                      style: SwissTheme.display(
                                        size: 16,
                                        color: SwissColors.indigo600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Modal Footer (Sticky CTA)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                color: SwissColors.white,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border(top: BorderSide(color: SwissColors.zinc200)),
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  Text(
                    'ESCROW PROTECTION // DANA DITERUSKAN SETELAH CEK FISIK',
                    style: SwissTheme.mono(size: 10, color: SwissColors.zinc500),
                  ),
                  ElevatedButton.icon(
                    onPressed: _triggerWhatsAppOrder,
                    icon: const Icon(Icons.arrow_forward, size: 15),
                    label: Text(
                      'Proses Transaksi via WhatsApp Admin',
                      style: SwissTheme.sans(
                        size: 12,
                        weight: FontWeight.w600,
                        color: SwissColors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SwissColors.zinc950,
                      foregroundColor: SwissColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: SwissTheme.mono(
              size: 10,
              color: highlight ? SwissColors.indigo700 : SwissColors.zinc500,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: SwissTheme.sans(
                size: 12,
                weight: highlight ? FontWeight.w700 : FontWeight.w600,
                color: highlight ? SwissColors.indigo700 : SwissColors.zinc900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryCard({
    required String value,
    required String title,
    required String badge,
    required Color badgeColor,
    required String subtitle,
  }) {
    final bool selected = _deliveryMethod == value;
    return InkWell(
      onTap: () => setState(() => _deliveryMethod = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SwissColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? SwissColors.zinc950 : SwissColors.zinc200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: SwissTheme.sans(
                      size: 12,
                      weight: FontWeight.w700,
                      color: SwissColors.zinc950,
                    ),
                  ),
                ),
                Text(
                  badge,
                  style: SwissTheme.mono(
                    size: 10,
                    weight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: SwissTheme.sans(size: 11, color: SwissColors.zinc500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _invoiceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: SwissTheme.sans(size: 12, color: SwissColors.zinc600),
          ),
        ),
        Text(
          value,
          style: SwissTheme.mono(
            size: 11,
            weight: FontWeight.w600,
            color: valueColor ?? SwissColors.zinc900,
          ),
        ),
      ],
    );
  }
}

/// ============================================================================
/// 2. MODAL SELL ITEM (FORM LISTING + NET REVENUE CALCULATOR + MAP PICKER)
/// ============================================================================
void showSellProductModal(BuildContext context, CampusTradeState appState) {
  showDialog(
    context: context,
    barrierColor: const Color(0x9909090B),
    builder: (ctx) => _SellProductDialog(appState: appState),
  );
}

class _SellProductDialog extends StatefulWidget {
  final CampusTradeState appState;
  const _SellProductDialog({required this.appState});

  @override
  State<_SellProductDialog> createState() => _SellProductDialogState();
}

class _SellProductDialogState extends State<_SellProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _photoUrlCtrl = TextEditingController();

  String _selectedCategory = 'Perabotan Kos';
  String _selectedCondition =
      'Mulus Terawat (Baret Halus Normal, Fungsi 100%) - 85%';
  String _selectedDelivery = 'semua';
  late String _selectedCodSpot;
  double _latitude = -0.9575;
  double _longitude = 100.3972;

  static const List<String> _categories = [
    'Perabotan Kos',
    'Elektronik Kos',
    'Gadget & Komputer',
    'Buku & Modul Kuliah',
    'Peralatan Masak & Makan',
    'Kendaraan & Aksesoris',
    'Fashion & Seragam Kuliah',
    'Kebutuhan Harian & Hobi',
    'Lain-lain',
  ];

  static const List<String> _conditions = [
    'Baru / Segel (Belum Pernah Dipakai) - 100%',
    'Like New / Sangat Mulus (Pemakaian < 1 Bulan) - 95%',
    'Mulus Terawat (Baret Halus Normal, Fungsi 100%) - 85%',
    'Layak Pakai (Tanda Pemakaian Wajar, Fungsi Normal) - 70%',
    'Minus Ringan (Fungsi Normal, Cacat Kosmetik) - 50%',
    'Butuh Perbaikan / Kanibalan (Untuk Servis / Part) - <50%',
  ];

  @override
  void initState() {
    super.initState();
    final spots = widget.appState.activeCodSpots;
    _selectedCodSpot = spots.isNotEmpty
        ? spots.first.namaTitik
        : 'Lobi UPI Convention Center (UCC)';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _photoUrlCtrl.dispose();
    super.dispose();
  }

  int get _rawPrice => int.tryParse(_priceCtrl.text.trim()) ?? 0;

  int get _netRevenue {
    final int fee = widget.appState
        .calculateAdminFeeForProduct(_selectedCategory, _rawPrice);
    final int net = _rawPrice - fee;
    return net > 0 ? net : 0;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.appState.createProductListing(
      namaBarang: _titleCtrl.text,
      kategori: _selectedCategory,
      harga: _rawPrice,
      kondisi: _selectedCondition,
      metodePengiriman: _selectedDelivery,
      titikCod: _selectedCodSpot,
      lokasiKos: _locationCtrl.text,
      latitude: _latitude,
      longitude: _longitude,
      deskripsi: _descCtrl.text,
      fotoUrl: _photoUrlCtrl.text,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final activeSpots = widget.appState.activeCodSpots;
    return Dialog(
      backgroundColor: SwissColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: SwissColors.zinc200),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                color: SwissColors.zinc50,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(bottom: BorderSide(color: SwissColors.zinc200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: SwissColors.zinc950,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'FORM LISTING',
                                style: SwissTheme.mono(
                                    size: 10, color: SwissColors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Jual Inventaris & Barang Kos',
                                style: SwissTheme.display(size: 15),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Khusus mahasiswa aktif UPI YPTK Padang terverifikasi KTM',
                          style:
                              SwissTheme.sans(size: 11, color: SwissColors.zinc500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),

            // Body Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('NAMA UNIT / BARANG *'),
                      TextFormField(
                        controller: _titleCtrl,
                        style: SwissTheme.sans(size: 12),
                        decoration: _inputDecoration(
                            'Contoh: Kasur Busa Single Inoac 90x200'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama barang wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel('KATEGORI *'),
                                DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  isExpanded: true,
                                  style: SwissTheme.sans(size: 12),
                                  decoration: _inputDecoration(''),
                                  items: _categories
                                      .map((c) => DropdownMenuItem(
                                          value: c, child: Text(c)))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _selectedCategory = v);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel('HARGA BUKA (RP) *'),
                                TextFormField(
                                  controller: _priceCtrl,
                                  keyboardType: TextInputType.number,
                                  style: SwissTheme.mono(
                                      size: 12, color: SwissColors.zinc900),
                                  decoration: _inputDecoration('180000'),
                                  onChanged: (_) => setState(() {}),
                                  validator: (v) {
                                    final n = int.tryParse(v?.trim() ?? '');
                                    if (n == null || n <= 0) {
                                      return 'Masukkan harga valid';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Net Revenue Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: SwissColors.zinc50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: SwissColors.zinc200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FEE INSPEKSI QC ADMIN',
                                  style: SwissTheme.mono(
                                      size: 10, color: SwissColors.zinc500),
                                ),
                                Text(
                                  'Rp 3.000 – Rp 10.000 (Sesuai Kategori)',
                                  style: SwissTheme.mono(
                                      size: 11, color: SwissColors.zinc800),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'ESTIMASI BERSIH DITERIMA',
                                  style: SwissTheme.mono(
                                      size: 10, color: SwissColors.zinc500),
                                ),
                                Text(
                                  SwissTheme.formatRupiah(_netRevenue),
                                  style: SwissTheme.display(
                                    size: 15,
                                    color: SwissColors.emerald600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      _fieldLabel('GRADING KONDISI FISIK *'),
                      DropdownButtonFormField<String>(
                        value: _selectedCondition,
                        isExpanded: true,
                        style: SwissTheme.sans(size: 12),
                        decoration: _inputDecoration(''),
                        items: _conditions
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedCondition = v);
                        },
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel('METODE SERAH TERIMA *'),
                                DropdownButtonFormField<String>(
                                  value: _selectedDelivery,
                                  isExpanded: true,
                                  style: SwissTheme.sans(size: 12),
                                  decoration: _inputDecoration(''),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'semua',
                                      child: Text(
                                          'Fleksibel (COD & Kurir Admin)'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'jemput_mandiri',
                                      child: Text('Hanya COD di Titik Resmi'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'kurir_admin',
                                      child: Text('Wajib Diantar Kurir Admin'),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _selectedDelivery = v);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel('TITIK TEMU COD UTAMA *'),
                                DropdownButtonFormField<String>(
                                  value: _selectedCodSpot,
                                  isExpanded: true,
                                  style: SwissTheme.sans(size: 12),
                                  decoration: _inputDecoration(''),
                                  items: activeSpots
                                      .map((s) => DropdownMenuItem(
                                            value: s.namaTitik,
                                            child: Text(s.namaTitik),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _selectedCodSpot = v);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      _fieldLabel(
                          'NAMA KOS / PATOKAN JALAN DI LUBUK BEGALUNG *'),
                      TextFormField(
                        controller: _locationCtrl,
                        style: SwissTheme.sans(size: 12),
                        decoration: _inputDecoration(
                            'Contoh: Kos Melati Gg. Kancil (200m dari UCC)'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Lokasi kos wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TITIK KOORDINAT KOS (GESER PIN)',
                            style: SwissTheme.mono(
                                size: 10, color: SwissColors.zinc700),
                          ),
                          Text(
                            '${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}',
                            style: SwissTheme.mono(
                                size: 10, color: SwissColors.indigo600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      PinpointPickerMap(
                        latitude: _latitude,
                        longitude: _longitude,
                        onLocationChanged: (lat, lng) {
                          setState(() {
                            _latitude = lat;
                            _longitude = lng;
                          });
                        },
                      ),
                      const SizedBox(height: 14),

                      _fieldLabel('URL FOTO BARANG (OPSIONAL / OTOMATIS)'),
                      TextFormField(
                        controller: _photoUrlCtrl,
                        style: SwissTheme.sans(size: 12),
                        decoration: _inputDecoration(
                            'Kosongkan untuk memakai foto kategori standar'),
                      ),
                      const SizedBox(height: 14),

                      _fieldLabel('SPESIFIKASI & RIWAYAT PEMAKAIAN *'),
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 3,
                        style: SwissTheme.sans(size: 12),
                        decoration: _inputDecoration(
                            'Jelaskan kondisi fungsi, kelengkapan, minus jika ada, serta alasan dijual...'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Deskripsi wajib diisi'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                color: SwissColors.white,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border(top: BorderSide(color: SwissColors.zinc200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Batal',
                        style: SwissTheme.sans(
                            size: 12, color: SwissColors.zinc600)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SwissColors.zinc950,
                      foregroundColor: SwissColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Publikasikan Unit',
                      style: SwissTheme.sans(
                        size: 12,
                        weight: FontWeight.w600,
                        color: SwissColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// 3. MODAL AUTH (LOGIN / REGISTRASI KTM / RESET SANDI)
/// ============================================================================
void showAuthModal(
  BuildContext context,
  CampusTradeState appState, {
  String initialTab = 'login',
}) {
  showDialog(
    context: context,
    barrierColor: const Color(0x9909090B),
    builder: (ctx) => _AuthDialog(appState: appState, initialTab: initialTab),
  );
}

class _AuthDialog extends StatefulWidget {
  final CampusTradeState appState;
  final String initialTab;

  const _AuthDialog({required this.appState, required this.initialTab});

  @override
  State<_AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<_AuthDialog> {
  late String _tab; // 'login', 'register', 'forgot'
  String? _errorMsg;

  // Login controllers
  final _loginIdCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();

  // Register controllers
  final _regUsernameCtrl = TextEditingController();
  final _regNimCtrl = TextEditingController();
  final _regNamaCtrl = TextEditingController();
  final _regWaCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  String _regJurusan = 'Teknik Informatika (Fasilkom)';
  bool _ktmAttached = true;

  // Forgot controllers
  final _forgotNimCtrl = TextEditingController();
  final _forgotWaCtrl = TextEditingController();
  final _forgotNewPassCtrl = TextEditingController();
  final _forgotConfirmPassCtrl = TextEditingController();

  static const List<String> _prodiList = [
    'Teknik Informatika (Fasilkom)',
    'Sistem Informasi (Fasilkom)',
    'Sistem Komputer (Fasilkom)',
    'Manajemen (FEB)',
    'Akuntansi (FEB)',
    'Teknik Sipil / Industri (FTI)',
    'Psikologi',
    'Desain Komunikasi Visual (DKV)',
  ];

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  void dispose() {
    _loginIdCtrl.dispose();
    _loginPassCtrl.dispose();
    _regUsernameCtrl.dispose();
    _regNimCtrl.dispose();
    _regNamaCtrl.dispose();
    _regWaCtrl.dispose();
    _regPassCtrl.dispose();
    _forgotNimCtrl.dispose();
    _forgotWaCtrl.dispose();
    _forgotNewPassCtrl.dispose();
    _forgotConfirmPassCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final err =
        widget.appState.login(_loginIdCtrl.text, _loginPassCtrl.text);
    if (err != null) {
      setState(() => _errorMsg = err);
    } else {
      Navigator.pop(context);
    }
  }

  void _handleRegister() {
    final err = widget.appState.registerStudent(
      username: _regUsernameCtrl.text,
      nim: _regNimCtrl.text,
      nama: _regNamaCtrl.text,
      jurusan: _regJurusan,
      whatsapp: _regWaCtrl.text,
      password: _regPassCtrl.text,
      ktmFileName: _ktmAttached ? 'sample_ktm.jpg' : '',
    );
    if (err != null) {
      setState(() => _errorMsg = err);
    } else {
      Navigator.pop(context);
    }
  }

  void _handleForgot() {
    final err = widget.appState.resetStudentPassword(
      nim: _forgotNimCtrl.text,
      whatsapp: _forgotWaCtrl.text,
      newPassword: _forgotNewPassCtrl.text,
      confirmPassword: _forgotConfirmPassCtrl.text,
    );
    if (err != null) {
      setState(() => _errorMsg = err);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String titleText = _tab == 'login'
        ? 'Masuk Akun Mahasiswa'
        : _tab == 'register'
            ? 'Daftar Akun Mahasiswa Baru'
            : 'Pemulihan Kata Sandi';

    return Dialog(
      backgroundColor: SwissColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: SwissColors.zinc200),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 740),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: SwissColors.zinc950,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'CIVITAS GATE',
                                style: SwissTheme.mono(
                                    size: 9, color: SwissColors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                titleText,
                                style: SwissTheme.display(size: 15),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Universitas Putra Indonesia "YPTK" Padang',
                          style:
                              SwissTheme.sans(size: 11, color: SwissColors.zinc500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),

              // Tab Switcher
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: SwissColors.zinc100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SwissColors.zinc200),
                ),
                child: Row(
                  children: [
                    _tabBtn('login', 'Masuk'),
                    _tabBtn('register', 'Registrasi KTM'),
                    _tabBtn('forgot', 'Reset Sandi'),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              if (_errorMsg != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SwissColors.rose50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SwissColors.rose200),
                  ),
                  child: Text(
                    _errorMsg!,
                    style: SwissTheme.sans(
                        size: 11,
                        weight: FontWeight.w600,
                        color: SwissColors.rose700),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (_tab == 'login') _buildLoginForm(),
              if (_tab == 'register') _buildRegisterForm(),
              if (_tab == 'forgot') _buildForgotForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabBtn(String key, String label) {
    final bool active = _tab == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _tab = key;
          _errorMsg = null;
        }),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? SwissColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: SwissTheme.sans(
              size: 11,
              weight: active ? FontWeight.w700 : FontWeight.w600,
              color: active ? SwissColors.zinc950 : SwissColors.zinc500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('NIM ATAU USERNAME *'),
        TextField(
          controller: _loginIdCtrl,
          style: SwissTheme.mono(size: 12, color: SwissColors.zinc900),
          decoration: _inputDecoration('24101152610172 atau iqbal_m / admin'),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _fieldLabel('KATA SANDI *'),
            InkWell(
              onTap: () => setState(() => _tab = 'forgot'),
              child: Text(
                'Lupa sandi?',
                style: SwissTheme.mono(
                    size: 10,
                    weight: FontWeight.w700,
                    color: SwissColors.indigo600),
              ),
            ),
          ],
        ),
        TextField(
          controller: _loginPassCtrl,
          obscureText: true,
          style: SwissTheme.sans(size: 12),
          decoration: _inputDecoration('•••••••• (Demo: password)'),
        ),
        const SizedBox(height: 12),

        // Quick Demo Account Chips
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: SwissColors.zinc50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SwissColors.zinc200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AKSES DEMO CEPAT (1-KLIK ISI OTOMATIS)',
                style: SwissTheme.mono(
                    size: 9,
                    weight: FontWeight.w700,
                    color: SwissColors.zinc700),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _demoChip('Mahasiswa Verified (@iqbal_m)', 'iqbal_m'),
                  _demoChip('Admin CMS (@admin)', 'admin'),
                  _demoChip('Pending KTM (@fajar_pratama)', 'fajar_pratama'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: SwissColors.zinc950,
              foregroundColor: SwissColors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Masuk ke Portal',
              style: SwissTheme.sans(
                size: 12,
                weight: FontWeight.w600,
                color: SwissColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _demoChip(String label, String username) {
    return InkWell(
      onTap: () {
        setState(() {
          _loginIdCtrl.text = username;
          _loginPassCtrl.text = 'password';
        });
      },
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: SwissColors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: SwissColors.zinc300),
        ),
        child: Text(
          label,
          style: SwissTheme.mono(size: 9, color: SwissColors.zinc800),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: SwissColors.zinc50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SwissColors.zinc200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROTOKOL ANTI-BUZZER // WAJIB KTM',
                style: SwissTheme.mono(
                    size: 10,
                    weight: FontWeight.w700,
                    color: SwissColors.indigo600),
              ),
              const SizedBox(height: 2),
              Text(
                'Setiap pendaftar wajib menggunakan Username unik, 14 digit NIM resmi, dan mengunggah foto KTM / KRS aktif UPI YPTK untuk diverifikasi Admin.',
                style: SwissTheme.sans(size: 11, color: SwissColors.zinc700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('USERNAME UNIK *'),
                  TextField(
                    controller: _regUsernameCtrl,
                    style: SwissTheme.mono(size: 12, color: SwissColors.zinc900),
                    decoration: _inputDecoration('iqbal_upi'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('NIM MAHASISWA *'),
                  TextField(
                    controller: _regNimCtrl,
                    style: SwissTheme.mono(size: 12, color: SwissColors.zinc900),
                    decoration: _inputDecoration('24101152610177'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _fieldLabel('NAMA LENGKAP (SESUAI KTM) *'),
        TextField(
          controller: _regNamaCtrl,
          style: SwissTheme.sans(size: 12),
          decoration: _inputDecoration('Muhammad Iqbal Maulana'),
        ),
        const SizedBox(height: 10),
        _fieldLabel('PROGRAM STUDI *'),
        DropdownButtonFormField<String>(
          value: _regJurusan,
          isExpanded: true,
          style: SwissTheme.sans(size: 12),
          decoration: _inputDecoration(''),
          items: _prodiList
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _regJurusan = v);
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('NO. WHATSAPP AKTIF *'),
                  TextField(
                    controller: _regWaCtrl,
                    style: SwissTheme.mono(size: 12, color: SwissColors.zinc900),
                    decoration: _inputDecoration('081234567890'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('KATA SANDI PRIBADI *'),
                  TextField(
                    controller: _regPassCtrl,
                    obscureText: true,
                    style: SwissTheme.sans(size: 12),
                    decoration: _inputDecoration('Min. 6 karakter'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: SwissColors.zinc50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SwissColors.zinc200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UNGGAH BUKTI KTM / KRS AKTIF *',
                      style: SwissTheme.mono(
                          size: 10,
                          weight: FontWeight.w700,
                          color: SwissColors.zinc900),
                    ),
                    Text(
                      _ktmAttached
                          ? '✓ Berkas: sample_ktm_upi_yptk.jpg siap diunggah'
                          : 'Belum ada berkas dipilih',
                      style: SwissTheme.sans(
                          size: 11, color: SwissColors.emerald700),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => setState(() => _ktmAttached = true),
                child: Text('Pilih KTM', style: SwissTheme.mono(size: 10)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: SwissColors.zinc950,
              foregroundColor: SwissColors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Ajukan Verifikasi Akun',
              style: SwissTheme.sans(
                size: 12,
                weight: FontWeight.w600,
                color: SwissColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: SwissColors.zinc50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SwissColors.zinc200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PEMULIHAN SANDI MANDIRI',
                style: SwissTheme.mono(
                    size: 10,
                    weight: FontWeight.w700,
                    color: SwissColors.indigo600),
              ),
              const SizedBox(height: 2),
              Text(
                'Masukkan 14 digit NIM dan Nomor WhatsApp yang terdaftar pada akun Anda untuk membuat kata sandi baru.',
                style: SwissTheme.sans(size: 11, color: SwissColors.zinc700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _fieldLabel('NIM MAHASISWA *'),
        TextField(
          controller: _forgotNimCtrl,
          style: SwissTheme.mono(size: 12, color: SwissColors.zinc900),
          decoration: _inputDecoration('24101152610172'),
        ),
        const SizedBox(height: 10),
        _fieldLabel('NOMOR WHATSAPP TERDAFTAR *'),
        TextField(
          controller: _forgotWaCtrl,
          style: SwissTheme.mono(size: 12, color: SwissColors.zinc900),
          decoration: _inputDecoration('081234567890'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('SANDI BARU *'),
                  TextField(
                    controller: _forgotNewPassCtrl,
                    obscureText: true,
                    style: SwissTheme.sans(size: 12),
                    decoration: _inputDecoration('Min. 6 karakter'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('KONFIRMASI SANDI *'),
                  TextField(
                    controller: _forgotConfirmPassCtrl,
                    obscureText: true,
                    style: SwissTheme.sans(size: 12),
                    decoration: _inputDecoration('Ulangi sandi'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleForgot,
            style: ElevatedButton.styleFrom(
              backgroundColor: SwissColors.zinc950,
              foregroundColor: SwissColors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Perbarui Kata Sandi',
              style: SwissTheme.sans(
                size: 12,
                weight: FontWeight.w600,
                color: SwissColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _fieldLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      text,
      style: SwissTheme.mono(
        size: 10,
        weight: FontWeight.w600,
        color: SwissColors.zinc600,
      ),
    ),
  );
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: SwissTheme.sans(size: 12, color: SwissColors.zinc400),
    isDense: true,
    filled: true,
    fillColor: SwissColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: SwissColors.zinc300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: SwissColors.zinc300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: SwissColors.zinc950, width: 1.5),
    ),
  );
}
