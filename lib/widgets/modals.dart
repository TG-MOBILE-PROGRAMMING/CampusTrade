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

    // Persist order in backend state
    widget.appState.createOrder(
      productId: p.id,
      sellerId: p.userId,
      metodePenyerahan: _deliveryMethod,
      titikCod: p.titikCod,
      hargaBarang: p.harga,
      feeAdmin: p.biayaVerifikasi,
      ongkir: _ongkir,
      totalBayar: _total,
    );

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
          constraints: BoxConstraints(
            maxWidth: 440,
            maxHeight: MediaQuery.of(context).size.height * 0.55,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pesan transaksi otomatis telah disalin ke Clipboard & siap diteruskan ke WhatsApp Admin ($adminPhone):',
                  style: SwissTheme.sans(size: 11, color: SwissColors.inkSecondary),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SwissColors.canvasSubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: SwissColors.borderHairline),
                  ),
                  child: SelectableText(
                    messageText,
                    style:
                        SwissTheme.mono(size: 10, color: SwissColors.inkPrimary),
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  waUrl,
                  maxLines: 2,
                  style: SwissTheme.mono(size: 9, color: SwissColors.escrowIndigo),
                ),
              ],
            ),
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
    final double maxDialogHeight = MediaQuery.of(context).size.height * 0.88;

    return Dialog(
      backgroundColor: SwissColors.canvasPure,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: SwissColors.borderHairline),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 672, maxHeight: maxDialogHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                color: SwissColors.canvasPure,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(bottom: BorderSide(color: SwissColors.borderHairline)),
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
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: SwissColors.inkPrimary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            p.kategori.toUpperCase(),
                            style: SwissTheme.mono(
                                size: 10,
                                weight: FontWeight.w700,
                                color: SwissColors.white),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: SwissColors.verifiedEmerald,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'QC VERIFIED',
                                style: SwissTheme.mono(
                                    size: 10,
                                    weight: FontWeight.w700,
                                    color: SwissColors.verifiedEmerald),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: SwissColors.canvasWarm,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: SwissColors.borderHairline),
                          ),
                          child: Text(
                            '$dist km dr Kampus',
                            style: SwissTheme.mono(
                                size: 10,
                                weight: FontWeight.w700,
                                color: SwissColors.inkPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18, color: SwissColors.inkSecondary),
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
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: SwissColors.canvasWarm,
                              border: Border.all(color: SwissColors.borderHairline),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  p.foto,
                                  fit: BoxFit.cover,
                                  cacheWidth: 600,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.image_outlined,
                                        size: 40, color: SwissColors.inkMuted),
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
                                        color: const Color(0xCC000000),
                                        borderRadius: BorderRadius.circular(6),
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
                              style: SwissTheme.display(
                                  size: 19,
                                  height: 1.25,
                                  color: SwissColors.inkPrimary),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: SwissColors.canvasWarm,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: SwissColors.borderHairline),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HARGA BUKA UNIT',
                                    style: SwissTheme.mono(
                                        size: 10, color: SwissColors.inkMuted),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.end,
                                    spacing: 8,
                                    children: [
                                      Text(
                                        SwissTheme.formatRupiah(p.harga),
                                        style: SwissTheme.display(
                                            size: 24,
                                            color: SwissColors.inkPrimary),
                                      ),
                                      Text(
                                        SwissTheme.formatRupiah(
                                            p.effectiveOriginalPrice),
                                        style: SwissTheme.mono(
                                          size: 12,
                                          color: SwissColors.inkMuted,
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
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: SwissColors.borderHairline),
                              ),
                              child: Column(
                                children: [
                                  _specRow('PENJUAL', p.namaPenjual),
                                  const Divider(height: 1, color: SwissColors.borderHairline),
                                  _specRow('LOKASI KOS', p.lokasiKos),
                                  const Divider(height: 1, color: SwissColors.borderHairline),
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

                    // Section 2: Geospatial Route Map & Uber Pickup-Dropoff Connector
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: SwissColors.canvasWarm,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: SwissColors.borderHairline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'RUTE LOGISTIK COD GAYA UBER',
                                style: SwissTheme.mono(
                                    size: 10,
                                    weight: FontWeight.w700,
                                    color: SwissColors.inkPrimary),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.near_me, size: 11, color: SwissColors.escrowIndigo),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Jarak: $dist km ($travelMins mnt)',
                                    style: SwissTheme.mono(
                                      size: 10,
                                      weight: FontWeight.w700,
                                      color: SwissColors.escrowIndigo,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Uber Pickup-Dropoff Step Visualizer
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: SwissColors.rauschCoral,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    width: 2,
                                    height: 24,
                                    color: SwissColors.inkMuted,
                                  ),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: SwissColors.escrowIndigo,
                                      shape: BoxShape.rectangle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'PICKUP: ',
                                          style: SwissTheme.mono(
                                              size: 9,
                                              weight: FontWeight.w700,
                                              color: SwissColors.rauschCoral),
                                        ),
                                        Expanded(
                                          child: Text(
                                            p.lokasiKos,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: SwissTheme.sans(
                                              size: 11,
                                              weight: FontWeight.w600,
                                              color: SwissColors.inkPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Text(
                                          'DROPOFF: ',
                                          style: SwissTheme.mono(
                                              size: 9,
                                              weight: FontWeight.w700,
                                              color: SwissColors.escrowIndigo),
                                        ),
                                        Expanded(
                                          child: Text(
                                            p.titikCod,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: SwissTheme.sans(
                                              size: 11,
                                              weight: FontWeight.w600,
                                              color: SwissColors.inkPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DetailRouteMiniMap(product: p),
                        ],
                      ),
                    ),

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
                              Expanded(
                                child: Text(
                                  'LAPORAN INSPEKSI FISIK (QC ADMIN)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: SwissTheme.mono(
                                    size: 10,
                                    weight: FontWeight.w700,
                                    color: SwissColors.emerald800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                          size: 10,
                          weight: FontWeight.w700,
                          color: SwissColors.inkMuted),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: SwissColors.canvasWarm,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: SwissColors.borderHairline),
                      ),
                      child: Text(
                        p.deskripsi,
                        style: SwissTheme.sans(
                          size: 12,
                          color: SwissColors.inkPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Section 5: Fulfillment & Stripe Escrow Cost Breakdown
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: SwissColors.canvasWarm,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: SwissColors.borderHairline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'OPSI SERAH TERIMA & INVOICE REKBER',
                                style: SwissTheme.mono(
                                  size: 10,
                                  weight: FontWeight.w700,
                                  color: SwissColors.inkPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: const Color(0xFFC7D2FE)),
                                ),
                                child: Text(
                                  'STRIPE ESCROW',
                                  style: SwissTheme.mono(
                                    size: 9,
                                    weight: FontWeight.w700,
                                    color: SwissColors.escrowIndigo,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (ctx, c) {
                              final Widget optA = _deliveryCard(
                                value: 'jemput_admin',
                                title: 'Jemput COD di Kampus',
                                badge: 'RP 0',
                                badgeColor: SwissColors.verifiedEmerald,
                                subtitle:
                                    'Serah terima didampingi admin di titik COD resmi.',
                              );
                              final Widget optB = _deliveryCard(
                                value: 'antar_admin',
                                title: 'Kurir Admin Antar-Kos',
                                badge:
                                    '+${SwissTheme.formatRupiah(p.biayaOngkir)}',
                                badgeColor: SwissColors.escrowIndigo,
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
                          const SizedBox(height: 14),
                          // Stripe Style Escrow Cost Breakdown Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: SwissColors.escrowBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: SwissColors.escrowBorder),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x05000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _invoiceRow(
                                  'Harga Unit Inventaris',
                                  SwissTheme.formatRupiah(p.harga),
                                ),
                                const SizedBox(height: 8),
                                _invoiceRow(
                                  'Jasa Verifikasi Fisik & Rekber Admin',
                                  '+${SwissTheme.formatRupiah(p.biayaVerifikasi)}',
                                  valueColor: SwissColors.escrowIndigo,
                                ),
                                const SizedBox(height: 8),
                                _invoiceRow(
                                  'Tarif Kurir Antar-Kos',
                                  _ongkir > 0
                                      ? '+${SwissTheme.formatRupiah(_ongkir)} (Kurir Admin)'
                                      : 'Rp 0 (COD Mandiri di Kampus)',
                                  valueColor: _ongkir > 0
                                      ? SwissColors.inkPrimary
                                      : SwissColors.verifiedEmerald,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(
                                      height: 1, color: Color(0xFFE2E8F0)),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'TOTAL ESTIMASI BAYAR',
                                          style: SwissTheme.mono(
                                            size: 10,
                                            weight: FontWeight.w700,
                                            color: SwissColors.inkSecondary,
                                          ),
                                        ),
                                        Text(
                                          'Dana ditahan aman di Rekber',
                                          style: SwissTheme.sans(
                                            size: 10,
                                            color: SwissColors.inkMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      SwissTheme.formatRupiah(_total),
                                      style: SwissTheme.display(
                                        size: 18,
                                        color: SwissColors.escrowIndigo,
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

            // Modal Footer (Sticky Bottom Bar with Escrow Guarantee)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                color: SwissColors.canvasPure,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: SwissColors.borderHairline)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: SwissColors.verifiedEmerald,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ESCROW TERPROTEKSI // REKBER & KURIR RESMI UPI YPTK',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SwissTheme.mono(
                            size: 9,
                            weight: FontWeight.w700,
                            color: SwissColors.inkSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _triggerWhatsAppOrder,
                    icon: const Icon(Icons.shield_outlined, size: 16),
                    label: Text(
                      'Beli Sekarang via Rekber WhatsApp',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SwissTheme.sans(
                        size: 13,
                        weight: FontWeight.w700,
                        color: SwissColors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SwissColors.escrowIndigo,
                      foregroundColor: SwissColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: SwissTheme.mono(
              size: 10,
              weight: FontWeight.w700,
              color: highlight ? SwissColors.escrowIndigo : SwissColors.inkMuted,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SwissTheme.sans(
                size: 12,
                weight: highlight ? FontWeight.w700 : FontWeight.w600,
                color: highlight ? SwissColors.escrowIndigo : SwissColors.inkPrimary,
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SwissColors.canvasPure,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? SwissColors.escrowIndigo : SwissColors.borderHairline,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x14635BFF),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
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
                      color: SwissColors.inkPrimary,
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
              style: SwissTheme.sans(size: 11, color: SwissColors.inkSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _invoiceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: SwissTheme.sans(size: 12, color: SwissColors.inkSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          textAlign: TextAlign.right,
          style: SwissTheme.mono(
            size: 11,
            weight: FontWeight.w600,
            color: valueColor ?? SwissColors.inkPrimary,
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
    final double maxDialogHeight = MediaQuery.of(context).size.height * 0.88;

    return Dialog(
      backgroundColor: SwissColors.canvasPure,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: SwissColors.borderHairline),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 580, maxHeight: maxDialogHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                color: SwissColors.canvasPure,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: SwissColors.borderHairline)),
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
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: SwissColors.inkPrimary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'FORM LISTING',
                                style: SwissTheme.mono(
                                    size: 10,
                                    weight: FontWeight.w700,
                                    color: SwissColors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Jual Inventaris & Barang Kos',
                                style: SwissTheme.display(
                                    size: 15, color: SwissColors.inkPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Khusus mahasiswa aktif UPI YPTK Padang terverifikasi KTM',
                          style:
                              SwissTheme.sans(size: 11, color: SwissColors.inkSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18, color: SwissColors.inkSecondary),
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

                      SwissFormRow(
                        first: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('KATEGORI *'),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
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
                        second: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('HARGA BUKA (RP) *'),
                            TextFormField(
                              controller: _priceCtrl,
                              keyboardType: TextInputType.number,
                              style: SwissTheme.mono(
                                  size: 12, color: SwissColors.inkPrimary),
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
                      const SizedBox(height: 14),

                      // Net Revenue Box
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: SwissColors.canvasWarm,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: SwissColors.borderHairline),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FEE INSPEKSI QC ADMIN',
                                  style: SwissTheme.mono(
                                      size: 10,
                                      weight: FontWeight.w700,
                                      color: SwissColors.inkMuted),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Rp 3.000 – Rp 10.000 (Sesuai Kategori)',
                                  style: SwissTheme.mono(
                                      size: 11,
                                      weight: FontWeight.w600,
                                      color: SwissColors.inkPrimary),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ESTIMASI BERSIH DITERIMA',
                                  style: SwissTheme.mono(
                                      size: 10,
                                      weight: FontWeight.w700,
                                      color: SwissColors.inkMuted),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  SwissTheme.formatRupiah(_netRevenue),
                                  style: SwissTheme.display(
                                    size: 16,
                                    color: SwissColors.verifiedEmerald,
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
                        initialValue: _selectedCondition,
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

                      SwissFormRow(
                        first: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('METODE SERAH TERIMA *'),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedDelivery,
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
                        second: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('TITIK TEMU COD UTAMA *'),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCodSpot,
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
                                size: 10, color: SwissColors.inkSecondary),
                          ),
                          Text(
                            '${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}',
                            style: SwissTheme.mono(
                                size: 10, color: SwissColors.escrowIndigo),
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
                color: SwissColors.canvasPure,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: SwissColors.borderHairline)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Batal',
                        style: SwissTheme.sans(
                            size: 12, color: SwissColors.inkSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SwissColors.rauschCoral,
                      foregroundColor: SwissColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      'Publikasikan Unit',
                      style: SwissTheme.sans(
                        size: 12,
                        weight: FontWeight.w700,
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
    final double maxDialogHeight = MediaQuery.of(context).size.height * 0.88;

    return Dialog(
      backgroundColor: SwissColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      elevation: 20,
      shadowColor: Colors.black.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: SwissColors.borderHairline),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 450, maxHeight: maxDialogHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
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
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: SwissColors.inkPrimary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'CIVITAS GATE',
                                style: SwissTheme.mono(
                                    size: 9,
                                    weight: FontWeight.w700,
                                    color: SwissColors.canvasPure),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                titleText,
                                style: SwissTheme.display(
                                    size: 16,
                                    weight: FontWeight.w800,
                                    color: SwissColors.inkPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Universitas Putra Indonesia "YPTK" Padang',
                          style: SwissTheme.sans(
                              size: 11, color: SwissColors.inkSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18, color: SwissColors.inkSecondary),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: SwissColors.borderHairline),
              ),

              // Tab Switcher (Full Pill)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: SwissColors.canvasSubtle,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: SwissColors.borderHairline),
                ),
                child: Row(
                  children: [
                    _tabBtn('login', 'Masuk'),
                    _tabBtn('register', 'Registrasi KTM'),
                    _tabBtn('forgot', 'Reset Sandi'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_errorMsg != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Text(
                    _errorMsg!,
                    style: SwissTheme.sans(
                        size: 11,
                        weight: FontWeight.w600,
                        color: const Color(0xFFDC2626)),
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
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? SwissColors.canvasPure : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SwissTheme.sans(
              size: 11,
              weight: active ? FontWeight.w700 : FontWeight.w600,
              color: active ? SwissColors.inkPrimary : SwissColors.inkSecondary,
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
          style: SwissTheme.mono(size: 12, color: SwissColors.inkPrimary),
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
                    color: SwissColors.escrowIndigo),
              ),
            ),
          ],
        ),
        TextField(
          controller: _loginPassCtrl,
          obscureText: true,
          style: SwissTheme.sans(size: 12, color: SwissColors.inkPrimary),
          decoration: _inputDecoration('•••••••• (Demo: password)'),
        ),
        const SizedBox(height: 12),

        // Quick Demo Account Chips
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SwissColors.canvasSubtle,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SwissColors.borderHairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AKSES DEMO CEPAT (1-KLIK ISI OTOMATIS)',
                style: SwissTheme.mono(
                    size: 9,
                    weight: FontWeight.w700,
                    color: SwissColors.inkSecondary),
              ),
              const SizedBox(height: 8),
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
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: SwissColors.rauschCoral,
              foregroundColor: SwissColors.canvasPure,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              'Masuk ke Portal',
              style: SwissTheme.sans(
                size: 13,
                weight: FontWeight.w700,
                color: SwissColors.canvasPure,
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
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: SwissColors.canvasPure,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: SwissColors.borderHairline),
        ),
        child: Text(
          label,
          style: SwissTheme.mono(size: 9, weight: FontWeight.w600, color: SwissColors.inkPrimary),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROTOKOL ANTI-BUZZER // WAJIB KTM',
                style: SwissTheme.mono(
                    size: 10,
                    weight: FontWeight.w700,
                    color: SwissColors.verifiedEmerald),
              ),
              const SizedBox(height: 2),
              Text(
                'Setiap pendaftar wajib menggunakan Username unik, 14 digit NIM resmi, dan mengunggah foto KTM / KRS aktif UPI YPTK untuk diverifikasi Admin.',
                style: SwissTheme.sans(size: 11, color: SwissColors.inkSecondary),
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
                    style: SwissTheme.mono(size: 12, color: SwissColors.inkPrimary),
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
                    style: SwissTheme.mono(size: 12, color: SwissColors.inkPrimary),
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
          style: SwissTheme.sans(size: 12, color: SwissColors.inkPrimary),
          decoration: _inputDecoration('Muhammad Iqbal Maulana'),
        ),
        const SizedBox(height: 10),
        _fieldLabel('PROGRAM STUDI *'),
        DropdownButtonFormField<String>(
          initialValue: _regJurusan,
          isExpanded: true,
          style: SwissTheme.sans(size: 12, color: SwissColors.inkPrimary),
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
                    style: SwissTheme.mono(size: 12, color: SwissColors.inkPrimary),
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
                    style: SwissTheme.sans(size: 12, color: SwissColors.inkPrimary),
                    decoration: _inputDecoration('Min. 6 karakter'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SwissColors.canvasSubtle,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SwissColors.borderHairline),
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
                          color: SwissColors.inkPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _ktmAttached
                          ? '✓ Berkas: sample_ktm_upi_yptk.jpg siap diunggah'
                          : 'Belum ada berkas dipilih',
                      style: SwissTheme.sans(
                          size: 11,
                          weight: _ktmAttached ? FontWeight.w600 : FontWeight.w400,
                          color: _ktmAttached ? SwissColors.verifiedEmerald : SwissColors.inkSecondary),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => setState(() => _ktmAttached = true),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  side: const BorderSide(color: SwissColors.borderHairline),
                ),
                child: Text('Pilih KTM', style: SwissTheme.mono(size: 10, weight: FontWeight.w600, color: SwissColors.inkPrimary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: SwissColors.rauschCoral,
              foregroundColor: SwissColors.canvasPure,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              'Ajukan Verifikasi Akun',
              style: SwissTheme.sans(
                size: 13,
                weight: FontWeight.w700,
                color: SwissColors.canvasPure,
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFC7D2FE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PEMULIHAN SANDI MANDIRI',
                style: SwissTheme.mono(
                    size: 10,
                    weight: FontWeight.w700,
                    color: SwissColors.escrowIndigo),
              ),
              const SizedBox(height: 2),
              Text(
                'Masukkan 14 digit NIM dan Nomor WhatsApp yang terdaftar pada akun Anda untuk membuat kata sandi baru.',
                style: SwissTheme.sans(size: 11, color: SwissColors.inkSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _fieldLabel('NIM MAHASISWA *'),
        TextField(
          controller: _forgotNimCtrl,
          style: SwissTheme.mono(size: 12, color: SwissColors.inkPrimary),
          decoration: _inputDecoration('24101152610172'),
        ),
        const SizedBox(height: 10),
        _fieldLabel('NOMOR WHATSAPP TERDAFTAR *'),
        TextField(
          controller: _forgotWaCtrl,
          style: SwissTheme.mono(size: 12, color: SwissColors.inkPrimary),
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
                    style: SwissTheme.sans(size: 12, color: SwissColors.inkPrimary),
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
                    style: SwissTheme.sans(size: 12, color: SwissColors.inkPrimary),
                    decoration: _inputDecoration('Ulangi sandi'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleForgot,
            style: ElevatedButton.styleFrom(
              backgroundColor: SwissColors.rauschCoral,
              foregroundColor: SwissColors.canvasPure,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              'Perbarui Kata Sandi',
              style: SwissTheme.sans(
                size: 13,
                weight: FontWeight.w700,
                color: SwissColors.canvasPure,
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
        color: SwissColors.inkSecondary,
      ),
    ),
  );
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: SwissTheme.sans(size: 12, color: SwissColors.inkMuted),
    isDense: true,
    filled: true,
    fillColor: SwissColors.canvasPure,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: SwissColors.borderHairline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: SwissColors.borderHairline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: SwissColors.inkPrimary, width: 1.5),
    ),
  );
}
