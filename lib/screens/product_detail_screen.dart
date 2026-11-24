import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/swiss_theme.dart';

/// ============================================================================
/// PRODUCT DETAIL SCREEN (DEDICATED FULL-PAGE MARKETPLACE EXPERIENCE)
/// [Anti-Slop UI Architecture & Zero-Modal Native Flow]
/// ============================================================================
class ProductDetailScreen extends StatefulWidget {
  final CampusTradeState appState;
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.appState,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _deliveryMethod = 'jemput_admin'; // 'jemput_admin' or 'antar_admin'
  bool _orderCreated = false;
  OrderModel? _lastOrder;

  int get _ongkir =>
      _deliveryMethod == 'antar_admin' ? widget.product.biayaOngkir : 0;

  int get _total =>
      widget.product.harga + widget.product.biayaVerifikasi + _ongkir;

  void _handleOrder() {
    final ProductModel p = widget.product;
    final String adminPhone =
        widget.appState.platformSettings['no_wa_admin'] ?? '6281234567899';
    final String methodText = _deliveryMethod == 'antar_admin'
        ? 'Diantar Kurir Admin ke Kos Mahasiswa'
        : 'Jemput Mandiri di Titik Kampus (${p.titikCod})';

    final String messageText = 'Halo Tim Admin CampusTrade,\n\n'
        'Saya mahasiswa berminat transaksi barang terverifikasi (Target: UPI YPTK):\n'
        '• Barang: ${p.namaBarang}\n'
        '• Penjual: ${p.namaPenjual} (Kos: ${p.lokasiKos})\n'
        '• Penyerahan: $methodText\n\n'
        'Rincian Biaya:\n'
        '- Harga: ${SwissTheme.formatRupiah(p.harga)}\n'
        '- Verifikasi Fisik & Rekber: ${SwissTheme.formatRupiah(p.biayaVerifikasi)}\n'
        '- Ongkir Kurir: ${SwissTheme.formatRupiah(_ongkir)}\n'
        '- Total Bayar: ${SwissTheme.formatRupiah(_total)}\n\n'
        'Mohon bantuan jadwal verifikasi fisik dan serah terima. Terima kasih!';

    final order = widget.appState.createOrder(
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

    setState(() {
      _orderCreated = true;
      _lastOrder = order;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SwissColors.verifiedEmerald,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Pesanan berhasil dicatat! Format pesan WhatsApp ($adminPhone) telah disalin ke Clipboard.',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _shareProduct() {
    final String shareText =
        'Cek barang ini di CampusTrade (Target: UPI YPTK): ${widget.product.namaBarang} - ${SwissTheme.formatRupiah(widget.product.harga)}. Lokasi kos ${widget.product.lokasiKos}.';
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tautan dan informasi produk berhasil disalin ke Clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 960;
    final ProductModel p = widget.product;
    final bool isFav = widget.appState.isFavorite(p.id);

    return Scaffold(
      backgroundColor: SwissColors.canvasWarm,
      appBar: AppBar(
        backgroundColor: SwissColors.canvasPure,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Detail Produk',
          style: SwissTheme.display(size: 16, weight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SwissColors.inkPrimary),
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? SwissColors.rauschCoral : SwissColors.inkSecondary,
            ),
            tooltip: isFav ? 'Hapus dari Wishlist' : 'Tambah ke Wishlist',
            onPressed: () {
              widget.appState.toggleFavorite(p.id);
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: SwissColors.inkSecondary),
            tooltip: 'Bagikan',
            onPressed: _shareProduct,
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: _buildStickyBottomBar(p),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? (screenWidth - 920) / 2 : 16,
            vertical: 16,
          ),
          child: isDesktop ? _buildDesktopLayout(p) : _buildMobileLayout(p),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(ProductModel p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageHero(p),
        const SizedBox(height: 16),
        _buildPriceAndTitle(p),
        const SizedBox(height: 16),
        _buildSellerCard(p),
        const SizedBox(height: 16),
        _buildEscrowTrustCard(),
        const SizedBox(height: 16),
        _buildSpecificationsCard(p),
        const SizedBox(height: 16),
        _buildDescriptionCard(p),
        const SizedBox(height: 16),
        _buildDeliverySelector(p),
        if (_orderCreated && _lastOrder != null) ...[
          const SizedBox(height: 16),
          _buildOrderSuccessCard(p),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildDesktopLayout(ProductModel p) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Image, Seller Card, Map
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageHero(p),
              const SizedBox(height: 16),
              _buildSellerCard(p),
              const SizedBox(height: 16),
              _buildEscrowTrustCard(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right Column: Price, Specifications, Delivery & Checkout
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPriceAndTitle(p),
              const SizedBox(height: 16),
              _buildSpecificationsCard(p),
              const SizedBox(height: 16),
              _buildDescriptionCard(p),
              const SizedBox(height: 16),
              _buildDeliverySelector(p),
              if (_orderCreated && _lastOrder != null) ...[
                const SizedBox(height: 16),
                _buildOrderSuccessCard(p),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageHero(ProductModel p) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: SwissColors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SwissColors.borderHairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Simulated Product Photo using high aesthetic placeholder styling
          Container(
            color: const Color(0xFFF1F5F9),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: SwissColors.canvasPure,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getCategoryIcon(p.kategori),
                      size: 36,
                      color: SwissColors.rauschCoral,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    p.namaBarang,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SwissTheme.display(size: 13, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.kategori,
                    style: SwissTheme.sans(size: 11, color: SwissColors.inkSecondary),
                  ),
                ],
              ),
            ),
          ),

          // Badges overlay
          Positioned(
            top: 12,
            left: 12,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: SwissColors.inkPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, size: 13, color: SwissColors.verifiedEmerald),
                      const SizedBox(width: 5),
                      Text(
                        'VERIFIKASI CAMPUSTRADE',
                        style: SwissTheme.mono(size: 10, color: Colors.white, weight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: SwissColors.canvasPure,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: SwissColors.borderHairline),
              ),
              child: Text(
                p.kondisi.split(' ').first,
                style: SwissTheme.sans(size: 11, weight: FontWeight.w700, color: SwissColors.inkPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndTitle(ProductModel p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SwissColors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SwissColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category and Distance Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  p.kategori,
                  style: SwissTheme.sans(size: 11, weight: FontWeight.w600, color: SwissColors.inkPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.location_on_outlined, size: 14, color: SwissColors.inkSecondary),
              const SizedBox(width: 2),
              Text(
                '${p.distanceToCampusKm} km dari kampus',
                style: SwissTheme.sans(size: 11, color: SwissColors.inkSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            p.namaBarang,
            style: SwissTheme.display(size: 20, weight: FontWeight.w800, height: 1.25),
          ),
          const SizedBox(height: 12),

          // Price block
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                SwissTheme.formatRupiah(p.harga),
                style: SwissTheme.display(
                  size: 24,
                  weight: FontWeight.w900,
                  color: SwissColors.rauschCoral,
                ),
              ),
              const SizedBox(width: 10),
              if (p.effectiveOriginalPrice > p.harga) ...[
                Text(
                  SwissTheme.formatRupiah(p.effectiveOriginalPrice),
                  style: SwissTheme.sans(
                    size: 13,
                    color: SwissColors.inkMuted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '-${p.savingsPercent}%',
                    style: SwissTheme.mono(size: 10, weight: FontWeight.w700, color: SwissColors.dangerRose),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: SwissColors.borderHairline),
          const SizedBox(height: 8),

          // COD Tag Info
          Row(
            children: [
              const Icon(Icons.handshake_outlined, size: 16, color: SwissColors.verifiedEmerald),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Bebas COD & serah terima di: ${p.titikCod}',
                  style: SwissTheme.sans(
                    size: 12,
                    weight: FontWeight.w600,
                    color: SwissColors.verifiedEmerald,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(ProductModel p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwissColors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SwissColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INFORMASI PENJUAL MAHASISWA',
            style: SwissTheme.mono(size: 10, weight: FontWeight.w700, color: SwissColors.inkMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: SwissColors.escrowIndigo.withValues(alpha: 0.15),
                child: Text(
                  p.namaPenjual.isNotEmpty ? p.namaPenjual.substring(0, p.namaPenjual.length > 2 ? 2 : p.namaPenjual.length).toUpperCase() : 'M',
                  style: SwissTheme.mono(size: 15, weight: FontWeight.w800, color: SwissColors.escrowIndigo),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            p.namaPenjual,
                            style: SwissTheme.display(size: 14, weight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, size: 14, color: SwissColors.verifiedEmerald),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p.jurusanPenjual} • NIM: ${p.nimPenjual}',
                      style: SwissTheme.sans(size: 11, color: SwissColors.inkSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kos: ${p.lokasiKos}',
                      style: SwissTheme.sans(size: 11, color: SwissColors.inkPrimary, weight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEscrowTrustCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SwissColors.verifiedEmerald.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined, color: SwissColors.verifiedEmerald, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Garansi Rekber & Verifikasi Tim CampusTrade',
                  style: SwissTheme.display(size: 13, weight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Transaksi Anda dijaga oleh Rekber Tim CampusTrade. Uang aman di rekening perantara hingga barang dicek fisik dan diserahterimakan di titik COD aman sekitar kampus.',
                  style: SwissTheme.sans(size: 11, height: 1.4, color: SwissColors.inkSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsCard(ProductModel p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwissColors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SwissColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SPESIFIKASI & KONDISI BARANG',
            style: SwissTheme.mono(size: 10, weight: FontWeight.w700, color: SwissColors.inkMuted),
          ),
          const SizedBox(height: 12),
          _buildSpecRow('Kondisi Fisik', p.kondisi),
          _buildSpecRow('Kategori', p.kategori),
          _buildSpecRow('Lokasi Kos', p.lokasiKos),
          _buildSpecRow('Titik COD Kampus', p.titikCod),
          _buildSpecRow('Metode Penyerahan', p.metodePengiriman == 'semua' ? 'Bisa Jemput / Diantar' : p.metodePengiriman),
          _buildSpecRow('Catatan Kurasi QC', p.catatanQcAdmin, isLast: true),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: SwissTheme.sans(size: 11, color: SwissColors.inkSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: SwissTheme.sans(size: 11, weight: FontWeight.w600, color: SwissColors.inkPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(ProductModel p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwissColors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SwissColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DESKRIPSI LENGKAP PENJUAL',
            style: SwissTheme.mono(size: 10, weight: FontWeight.w700, color: SwissColors.inkMuted),
          ),
          const SizedBox(height: 10),
          Text(
            p.deskripsi.trim().isNotEmpty
                ? p.deskripsi
                : 'Tidak ada deskripsi tambahan dari penjual. Barang dalam kondisi siap pakai.',
            style: SwissTheme.sans(size: 12, height: 1.5, color: SwissColors.inkPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySelector(ProductModel p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwissColors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SwissColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OPSI PENYERAHAN & RINCIAN BIAYA',
            style: SwissTheme.mono(size: 10, weight: FontWeight.w700, color: SwissColors.inkMuted),
          ),
          const SizedBox(height: 12),

          // Option 1: Jemput Mandiri
          InkWell(
            onTap: () => setState(() => _deliveryMethod = 'jemput_admin'),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _deliveryMethod == 'jemput_admin' ? const Color(0xFFF0FDF4) : SwissColors.canvasPure,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _deliveryMethod == 'jemput_admin' ? SwissColors.verifiedEmerald : SwissColors.borderHairline,
                  width: _deliveryMethod == 'jemput_admin' ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _deliveryMethod == 'jemput_admin' ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: _deliveryMethod == 'jemput_admin' ? SwissColors.verifiedEmerald : SwissColors.inkMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jemput Mandiri di Kampus (COD Gratis)',
                          style: SwissTheme.display(size: 12, weight: FontWeight.w700),
                        ),
                        Text(
                          'Titik temu resmi: ${p.titikCod} • Tanpa ongkir kurir',
                          style: SwissTheme.sans(size: 11, color: SwissColors.inkSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'GRATIS',
                    style: SwissTheme.mono(size: 11, weight: FontWeight.w700, color: SwissColors.verifiedEmerald),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Option 2: Diantar Kurir Kos
          InkWell(
            onTap: () => setState(() => _deliveryMethod = 'antar_admin'),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _deliveryMethod == 'antar_admin' ? const Color(0xFFF0FDF4) : SwissColors.canvasPure,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _deliveryMethod == 'antar_admin' ? SwissColors.verifiedEmerald : SwissColors.borderHairline,
                  width: _deliveryMethod == 'antar_admin' ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _deliveryMethod == 'antar_admin' ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: _deliveryMethod == 'antar_admin' ? SwissColors.verifiedEmerald : SwissColors.inkMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Diantar Kurir Admin ke Kos Mahasiswa',
                          style: SwissTheme.display(size: 12, weight: FontWeight.w700),
                        ),
                        Text(
                          'Cocok untuk kasur, meja, atau perabotan kos berat',
                          style: SwissTheme.sans(size: 11, color: SwissColors.inkSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    SwissTheme.formatRupiah(p.biayaOngkir),
                    style: SwissTheme.mono(size: 11, weight: FontWeight.w700, color: SwissColors.inkPrimary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Price Calculation breakdown
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildPriceSummaryRow('Harga Barang', SwissTheme.formatRupiah(p.harga)),
                _buildPriceSummaryRow('Verifikasi Fisik & Rekber Admin', SwissTheme.formatRupiah(p.biayaVerifikasi)),
                _buildPriceSummaryRow('Ongkos Kirim Kurir', _ongkir == 0 ? 'Gratis (COD)' : SwissTheme.formatRupiah(_ongkir)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Divider(color: SwissColors.borderHairline),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Pembayaran', style: SwissTheme.display(size: 13, weight: FontWeight.w800)),
                    Text(
                      SwissTheme.formatRupiah(_total),
                      style: SwissTheme.display(size: 15, weight: FontWeight.w900, color: SwissColors.rauschCoral),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: SwissTheme.sans(size: 11, color: SwissColors.inkSecondary)),
          Text(value, style: SwissTheme.mono(size: 11, weight: FontWeight.w600, color: SwissColors.inkPrimary)),
        ],
      ),
    );
  }

  Widget _buildOrderSuccessCard(ProductModel p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SwissColors.verifiedEmerald),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: SwissColors.verifiedEmerald, size: 20),
              const SizedBox(width: 8),
              Text(
                'Pesanan Berhasil Dicatat (Order #${_lastOrder?.id})',
                style: SwissTheme.display(size: 13, weight: FontWeight.w700, color: SwissColors.verifiedEmerald),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Format pemesanan WhatsApp sudah otomatis disalin ke Clipboard Anda. Silakan lanjutkan konfirmasi dengan Tim Admin CampusTrade.',
            style: SwissTheme.sans(size: 11, height: 1.4, color: const Color(0xFF065F46)),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(ProductModel p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: SwissColors.canvasPure,
        border: Border(top: BorderSide(color: SwissColors.borderHairline)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Chat Penjual / Admin WhatsApp
            OutlinedButton.icon(
              onPressed: () {
                final String text = 'Halo ${p.namaPenjual}, saya berminat dengan barang "${p.namaBarang}" di Platform CampusTrade.';
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pesan chat WhatsApp telah disalin ke Clipboard!')),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Chat'),
              style: OutlinedButton.styleFrom(
                foregroundColor: SwissColors.inkPrimary,
                side: const BorderSide(color: SwissColors.borderHairline),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(width: 12),

            // Primary Buy CTA
            Expanded(
              child: ElevatedButton(
                onPressed: _handleOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SwissColors.rauschCoral,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Pesan Sekarang • ${SwissTheme.formatRupiah(_total)}',
                      style: SwissTheme.display(size: 13, weight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Perabotan Kos':
        return Icons.bed_outlined;
      case 'Elektronik Kos':
        return Icons.electrical_services_outlined;
      case 'Gadget & Komputer':
        return Icons.laptop_chromebook_outlined;
      case 'Buku & Modul Kuliah':
        return Icons.menu_book_outlined;
      case 'Peralatan Masak & Makan':
        return Icons.soup_kitchen_outlined;
      case 'Kendaraan & Aksesoris':
        return Icons.two_wheeler_outlined;
      case 'Fashion & Seragam Kuliah':
        return Icons.checkroom_outlined;
      case 'Kebutuhan Harian & Hobi':
        return Icons.sports_tennis_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }
}
