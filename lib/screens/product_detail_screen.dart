import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/swiss_theme.dart';
import '../widgets/campus_motion.dart';
import '../widgets/campus_trust_widgets.dart';

/// ============================================================================
/// PRODUCT DETAIL SCREEN
/// Clean Minimalist Editorial-Utility + Hero Image + Live Price Micro-Interaction
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
    HapticFeedback.mediumImpact();

    setState(() {
      _orderCreated = true;
      _lastOrder = order;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: CampusColors.verifiedJade,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Pesanan dicatat! Format pesan WhatsApp ($adminPhone) disalin ke Clipboard.',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
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
        'Cek barang ini di CampusTrade (UPI YPTK): ${widget.product.namaBarang} - ${SwissTheme.formatRupiah(widget.product.harga)}. Lokasi kos ${widget.product.lokasiKos}.';
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Info produk berhasil disalin ke Clipboard!'),
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
      backgroundColor: CampusColors.canvasPaper,
      appBar: AppBar(
        backgroundColor: CampusColors.surfacePure,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text(
          'Detail Barang',
          style: SwissTheme.display(size: 16, weight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CampusColors.inkPrimary),
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          BouncyHeartButton(
            isFavorite: isFav,
            showBackdrop: false,
            onToggle: () {
              widget.appState.toggleFavorite(p.id);
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: CampusColors.inkSecondary),
            tooltip: 'Bagikan',
            onPressed: _shareProduct,
          ),
          const SizedBox(width: 6),
        ],
      ),
      bottomNavigationBar: _buildStickyBottomBar(p),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? (screenWidth - 940) / 2 : 16,
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
        StaggeredEntrance(index: 0, child: _buildPriceAndTitle(p)),
        const SizedBox(height: 14),
        StaggeredEntrance(index: 1, child: _buildQcCalloutCard(p)),
        const SizedBox(height: 14),
        StaggeredEntrance(index: 2, child: _buildSellerCard(p)),
        const SizedBox(height: 14),
        _buildEscrowTrustCard(),
        const SizedBox(height: 14),
        _buildSpecificationsCard(p),
        const SizedBox(height: 14),
        _buildDescriptionCard(p),
        const SizedBox(height: 14),
        _buildDeliverySelector(p),
        if (_orderCreated && _lastOrder != null) ...[
          const SizedBox(height: 14),
          _buildOrderSuccessCard(p),
        ],
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildDesktopLayout(ProductModel p) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageHero(p),
              const SizedBox(height: 16),
              _buildQcCalloutCard(p),
              const SizedBox(height: 16),
              _buildSellerCard(p),
              const SizedBox(height: 16),
              _buildEscrowTrustCard(),
            ],
          ),
        ),
        const SizedBox(width: 24),
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
      height: 290,
      decoration: BoxDecoration(
        color: CampusColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CampusColors.borderHairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'product-image-${p.id}',
            child: CampusProductImage(
              imageUrl: p.foto,
              category: p.kategori,
              fallbackIcon: _getCategoryIcon(p.kategori),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: CampusColors.campusForest.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified,
                    size: 14,
                    color: Color(0xFF6EE7B7),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Lolos Kurasi Tim',
                    style: SwissTheme.sans(
                      size: 11,
                      color: Colors.white,
                      weight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: ConditionBadge(rawCondition: p.kondisi),
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
        color: CampusColors.surfacePure,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CampusColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: CampusColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  p.kategori,
                  style: SwissTheme.sans(
                    size: 11.5,
                    weight: FontWeight.w600,
                    color: CampusColors.inkPrimary,
                    height: 1.1,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 14,
                    color: CampusColors.inkSecondary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${p.distanceToCampusKm} km dari kampus',
                    style: SwissTheme.sans(
                      size: 11.5,
                      color: CampusColors.inkSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            p.namaBarang,
            style: SwissTheme.display(
              size: 21,
              weight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                SwissTheme.formatRupiah(p.harga),
                style: SwissTheme.display(
                  size: 24,
                  weight: FontWeight.w900,
                  color: CampusColors.terracotta,
                ),
              ),
              if (p.effectiveOriginalPrice > p.harga) ...[
                Text(
                  SwissTheme.formatRupiah(p.effectiveOriginalPrice),
                  style: SwissTheme.sans(
                    size: 13.5,
                    color: CampusColors.inkMuted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: CampusColors.terracottaSoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Hemat ${p.savingsPercent}%',
                    style: SwissTheme.mono(
                      size: 10.5,
                      weight: FontWeight.w700,
                      color: CampusColors.terracotta,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: CampusColors.borderHairline),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.handshake_outlined,
                size: 16,
                color: CampusColors.verifiedJade,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gratis COD di ${p.titikCod}',
                  style: SwissTheme.sans(
                    size: 12.5,
                    weight: FontWeight.w700,
                    color: CampusColors.verifiedJade,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Dedicated Admin Physical QC Callout for high buyer trust.
  Widget _buildQcCalloutCard(ProductModel p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CampusColors.verifiedJadeSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CampusColors.verifiedJade.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.fact_check_outlined,
            size: 20,
            color: CampusColors.verifiedJade,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan Kurasi Fisik Tim Admin',
                  style: SwissTheme.display(
                    size: 13,
                    weight: FontWeight.w700,
                    color: CampusColors.verifiedJade,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  p.catatanQcAdmin,
                  style: SwissTheme.sans(
                    size: 12,
                    height: 1.45,
                    color: CampusColors.inkPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(ProductModel p) {
    final String initials = p.namaPenjual.trim().length >= 2
        ? p.namaPenjual.trim().substring(0, 2).toUpperCase()
        : 'MH';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CampusColors.surfacePure,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CampusColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Penjual Mahasiswa Terverifikasi',
            style: SwissTheme.label(color: CampusColors.inkMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: CampusColors.campusForestSoft,
                child: Text(
                  initials,
                  style: SwissTheme.mono(
                    size: 14,
                    weight: FontWeight.w800,
                    color: CampusColors.campusForest,
                  ),
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
                            style: SwissTheme.display(
                              size: 14.5,
                              weight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified,
                          size: 15,
                          color: CampusColors.verifiedJade,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p.jurusanPenjual} • NIM ${p.nimPenjual}',
                      style: SwissTheme.sans(
                        size: 12,
                        color: CampusColors.inkSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lokasi Kos: ${p.lokasiKos}',
                      style: SwissTheme.sans(
                        size: 12,
                        color: CampusColors.inkPrimary,
                        weight: FontWeight.w600,
                      ),
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
    return TactilePress(
      onTap: () => showEscrowExplainerSheet(context),
      borderRadius: BorderRadius.circular(16),
      pressedScale: 0.99,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CampusColors.campusForestSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CampusColors.campusForest.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: CampusColors.surfacePure,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: CampusColors.campusForest,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Dilindungi Rekber CampusTrade',
                          style: SwissTheme.display(
                            size: 13.5,
                            weight: FontWeight.w700,
                            color: CampusColors.campusForest,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: CampusColors.campusForest,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Dana pembeli disimpan aman hingga barang dicek fisik di titik COD kampus atau saat kurir tiba di kos. Ketuk untuk lihat alur lengkap.',
                    style: SwissTheme.sans(
                      size: 12,
                      height: 1.45,
                      color: CampusColors.inkSecondary,
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

  Widget _buildSpecificationsCard(ProductModel p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CampusColors.surfacePure,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CampusColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spesifikasi & Kondisi',
            style: SwissTheme.label(color: CampusColors.inkMuted),
          ),
          const SizedBox(height: 12),
          _buildSpecRow('Kondisi Fisik', p.kondisi),
          _buildSpecRow('Kategori', p.kategori),
          _buildSpecRow('Lokasi Kos', p.lokasiKos),
          _buildSpecRow('Titik COD Kampus', p.titikCod),
          _buildSpecRow(
            'Penyerahan',
            p.metodePengiriman == 'semua'
                ? 'Jemput Mandiri atau Kurir Kos'
                : p.metodePengiriman,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: SwissTheme.sans(
                size: 12,
                color: CampusColors.inkSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: SwissTheme.sans(
                size: 12,
                weight: FontWeight.w600,
                color: CampusColors.inkPrimary,
              ),
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
        color: CampusColors.surfacePure,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CampusColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catatan Penjual',
            style: SwissTheme.label(color: CampusColors.inkMuted),
          ),
          const SizedBox(height: 8),
          Text(
            p.deskripsi.trim().isNotEmpty
                ? p.deskripsi
                : 'Tidak ada deskripsi tambahan dari penjual. Barang dalam kondisi siap pakai.',
            style: SwissTheme.sans(
              size: 13,
              height: 1.55,
              color: CampusColors.inkPrimary,
            ),
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
        color: CampusColors.surfacePure,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CampusColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Cara Serah Terima',
            style: SwissTheme.label(color: CampusColors.inkMuted),
          ),
          const SizedBox(height: 12),
          _buildDeliveryOption(
            value: 'jemput_admin',
            title: 'Jemput Mandiri di Kampus (COD Gratis)',
            subtitle: 'Titik temu: ${p.titikCod} • Tanpa ongkir',
            priceText: 'GRATIS',
            priceColor: CampusColors.verifiedJade,
          ),
          const SizedBox(height: 10),
          _buildDeliveryOption(
            value: 'antar_admin',
            title: 'Diantar Kurir Admin ke Kos',
            subtitle: 'Praktis untuk kasur, meja, atau perabotan berat',
            priceText: SwissTheme.formatRupiah(p.biayaOngkir),
            priceColor: CampusColors.inkPrimary,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CampusColors.canvasPaper,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CampusColors.borderHairline),
            ),
            child: Column(
              children: [
                _buildPriceSummaryRow(
                  'Harga Barang',
                  SwissTheme.formatRupiah(p.harga),
                ),
                _buildPriceSummaryRow(
                  'Verifikasi Fisik & Rekber',
                  SwissTheme.formatRupiah(p.biayaVerifikasi),
                ),
                _buildPriceSummaryRow(
                  'Ongkos Kirim Kurir',
                  _ongkir == 0 ? 'Gratis (COD)' : SwissTheme.formatRupiah(_ongkir),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: CampusColors.borderHairline),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Total Pembayaran',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SwissTheme.display(size: 13.5, weight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedPriceText(
                      formattedPrice: SwissTheme.formatRupiah(_total),
                      style: SwissTheme.display(
                        size: 16,
                        weight: FontWeight.w900,
                        color: CampusColors.terracotta,
                      ),
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

  Widget _buildDeliveryOption({
    required String value,
    required String title,
    required String subtitle,
    required String priceText,
    required Color priceColor,
  }) {
    final bool selected = _deliveryMethod == value;
    return TactilePress(
      onTap: () => setState(() => _deliveryMethod = value),
      borderRadius: BorderRadius.circular(12),
      pressedScale: 0.99,
      child: AnimatedContainer(
        duration: CampusMotion.fast,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? CampusColors.campusForestSoft : CampusColors.surfacePure,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? CampusColors.campusForest : CampusColors.borderHairline,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? CampusColors.campusForest : CampusColors.inkMuted,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: SwissTheme.display(size: 13, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: SwissTheme.sans(
                      size: 11.5,
                      color: CampusColors.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              priceText,
              style: SwissTheme.mono(
                size: 11.5,
                weight: FontWeight.w700,
                color: priceColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SwissTheme.sans(size: 12, color: CampusColors.inkSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: SwissTheme.mono(
              size: 12,
              weight: FontWeight.w600,
              color: CampusColors.inkPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSuccessCard(ProductModel p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CampusColors.verifiedJadeSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CampusColors.verifiedJade),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: CampusColors.verifiedJade,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pesanan Dicatat (Order #${_lastOrder?.id})',
                  style: SwissTheme.display(
                    size: 13.5,
                    weight: FontWeight.w700,
                    color: CampusColors.verifiedJade,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Format pemesanan WhatsApp sudah disalin ke Clipboard. Lanjutkan konfirmasi jadwal cek fisik dengan Tim Admin CampusTrade.',
            style: SwissTheme.sans(
              size: 12,
              height: 1.45,
              color: CampusColors.inkPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(ProductModel p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: CampusColors.surfacePure,
        border: Border(top: BorderSide(color: CampusColors.borderHairline)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {
                final String text =
                    'Halo ${p.namaPenjual}, saya berminat dengan barang "${p.namaBarang}" di CampusTrade.';
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pesan chat WhatsApp disalin ke Clipboard!'),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Chat'),
              style: OutlinedButton.styleFrom(
                foregroundColor: CampusColors.inkPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TactilePress(
                onTap: _handleOrder,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: CampusColors.terracotta,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pesan • ',
                          style: SwissTheme.display(
                            size: 13.5,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        AnimatedPriceText(
                          formattedPrice: SwissTheme.formatRupiah(_total),
                          style: SwissTheme.display(
                            size: 13.5,
                            weight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
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
