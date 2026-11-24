import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/swiss_theme.dart';

/// ============================================================================
/// SELL PRODUCT SCREEN (DEDICATED FULL-PAGE LISTING CREATION)
/// [Anti-Slop UI Architecture & Zero-Modal Native Flow]
/// ============================================================================
class SellProductScreen extends StatefulWidget {
  final CampusTradeState appState;

  const SellProductScreen({super.key, required this.appState});

  @override
  State<SellProductScreen> createState() => _SellProductScreenState();
}

class _SellProductScreenState extends State<SellProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _origPriceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _photoUrlCtrl = TextEditingController();

  String _selectedCategory = 'Perabotan Kos';
  String _selectedCondition = 'Mulus Terawat (Baret Halus Normal, Fungsi 100%) - 85%';
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
    'Seperti Baru (Gress 95-99%, Pemakaian < 1 Bulan)',
    'Mulus Terawat (Baret Halus Normal, Fungsi 100%) - 85%',
    'Layak Pakai Standar Mahasiswa (Fungsi Normal) - 70%',
    'Minus Estetika/Fisik (Fungsi Utama Tetap Jalan) - 50%',
  ];

  static const List<Map<String, String>> _samplePresets = [
    {'title': 'Kasur Busa Inoac Tebal 15cm', 'category': 'Perabotan Kos', 'price': '250000', 'orig': '450000'},
    {'title': 'Dispenser Miyako Panas & Normal', 'category': 'Elektronik Kos', 'price': '95000', 'orig': '160000'},
    {'title': 'Meja Belajar Lipat Kayu Kokoh', 'category': 'Perabotan Kos', 'price': '65000', 'orig': '120000'},
    {'title': 'Kipas Angin Dinding Cosmos 16 Inch', 'category': 'Elektronik Kos', 'price': '135000', 'orig': '220000'},
    {'title': 'Helm KYT DJ Maru Size L Original', 'category': 'Kendaraan & Aksesoris', 'price': '180000', 'orig': '320000'},
    {'title': 'Buku Algoritma & Pemrograman C++', 'category': 'Buku & Modul Kuliah', 'price': '35000', 'orig': '75000'},
  ];

  @override
  void initState() {
    super.initState();
    final spots = widget.appState.activeCodSpots;
    _selectedCodSpot = spots.isNotEmpty
        ? spots.first.namaTitik
        : 'Gerbang Utama UPI YPTK (Pos Satpam 24 Jam)';
    _locationCtrl.text = 'Kosan Lubuk Begalung (Dekat Kampus UPI YPTK)';
    _priceCtrl.addListener(() => setState(() {}));
    _origPriceCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _origPriceCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _photoUrlCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(Map<String, String> p) {
    setState(() {
      _titleCtrl.text = p['title']!;
      _selectedCategory = p['category']!;
      _priceCtrl.text = p['price']!;
      _origPriceCtrl.text = p['orig']!;
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final user = widget.appState.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu untuk pasang iklan!')),
      );
      return;
    }

    final int price = int.tryParse(_priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final int origPrice = int.tryParse(_origPriceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? (price * 1.4).round();

    widget.appState.createProductListing(
      namaBarang: _titleCtrl.text.trim(),
      kategori: _selectedCategory,
      harga: price,
      hargaAsli: origPrice,
      kondisi: _selectedCondition,
      lokasiKos: _locationCtrl.text.trim(),
      titikCod: _selectedCodSpot,
      latitude: _latitude,
      longitude: _longitude,
      metodePengiriman: _selectedDelivery,
      deskripsi: _descCtrl.text.trim(),
      fotoUrl: _photoUrlCtrl.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SwissColors.verifiedEmerald,
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Iklan berhasil diajukan! Menunggu verifikasi kurasi fisik oleh tim Admin.',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 960;

    final int price = int.tryParse(_priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final int origPrice = int.tryParse(_origPriceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final int fee = widget.appState.calculateAdminFeeForProduct(_selectedCategory, price);
    final int netIncome = price > fee ? price - fee : 0;

    return Scaffold(
      backgroundColor: SwissColors.canvasWarm,
      appBar: AppBar(
        backgroundColor: SwissColors.canvasPure,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Pasang Iklan Barang Kos',
          style: SwissTheme.display(size: 16, weight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SwissColors.inkPrimary),
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: SwissColors.canvasPure,
          border: Border(top: BorderSide(color: SwissColors.borderHairline)),
          boxShadow: [
            BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: ElevatedButton(
            onPressed: _submitForm,
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
                const Icon(Icons.cloud_upload_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Terbitkan Iklan Sekarang',
                  style: SwissTheme.display(size: 14, weight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? (screenWidth - 760) / 2 : 16,
            vertical: 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fast Preset Chips
                _buildPresetChipsSection(),
                const SizedBox(height: 16),

                // Section 1: Basic Information
                _buildCardSection(
                  title: '1. INFORMASI BARANG',
                  children: [
                    _buildLabel('Nama / Judul Barang *'),
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: _inputDecoration('Contoh: Kasur Busa Inoac Tebal 15cm Mulus'),
                      validator: (val) => (val == null || val.trim().length < 4)
                          ? 'Nama barang minimal 4 karakter'
                          : null,
                    ),
                    const SizedBox(height: 14),

                    _buildLabel('Kategori Barang *'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: _inputDecoration(null),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    _buildLabel('Kondisi Barang *'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCondition,
                      decoration: _inputDecoration(null),
                      items: _conditions.map((c) => DropdownMenuItem(value: c, child: Text(c, style: SwissTheme.sans(size: 11)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCondition = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    _buildLabel('Deskripsi Lengkap *'),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: _inputDecoration('Jelaskan detail barang, kelengkapan, minus pemakaian kos, dan alasan jual...'),
                      validator: (val) => (val == null || val.trim().length < 10)
                          ? 'Deskripsi minimal 10 karakter agar pembeli paham'
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Section 2: Pricing
                _buildCardSection(
                  title: '2. HARGA & PENGHEMATAN',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Harga Jual (Rp) *'),
                              TextFormField(
                                controller: _priceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration('Contoh: 150000', prefix: 'Rp '),
                                validator: (val) {
                                  final num = int.tryParse(val?.replaceAll(RegExp(r'[^0-9]'), '') ?? '');
                                  if (num == null || num < 5000) return 'Minimal Rp 5.000';
                                  return null;
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
                              _buildLabel('Harga Beli Asli (Rp)'),
                              TextFormField(
                                controller: _origPriceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration('Contoh: 250000', prefix: 'Rp '),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (origPrice > price && price > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: SwissColors.verifiedEmerald.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.savings_outlined, color: SwissColors.verifiedEmerald, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Diskon penghematan pembeli: ${((1 - (price / origPrice)) * 100).round()}%!',
                              style: SwissTheme.mono(size: 11, weight: FontWeight.w700, color: SwissColors.verifiedEmerald),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Section 3: Location & COD
                _buildCardSection(
                  title: '3. LOKASI KOS & TITIK COD KAMPUS',
                  children: [
                    _buildLabel('Lokasi Kos / Alamat Mahasiswa *'),
                    TextFormField(
                      controller: _locationCtrl,
                      decoration: _inputDecoration('Contoh: Kos Melati Putri, Jl. Lubuk Begalung'),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Lokasi kos wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),

                    _buildLabel('Pilihan Titik COD Aman Sekitar Kampus Target *'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCodSpot,
                      decoration: _inputDecoration(null),
                      items: widget.appState.activeCodSpots
                          .map((s) => DropdownMenuItem(value: s.namaTitik, child: Text(s.namaTitik, style: SwissTheme.sans(size: 12))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCodSpot = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    _buildLabel('Opsi Penyerahan Barang *'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDelivery,
                      decoration: _inputDecoration(null),
                      items: const [
                        DropdownMenuItem(value: 'semua', child: Text('Bisa Jemput Sendiri (COD) atau Diantar Kurir')),
                        DropdownMenuItem(value: 'jemput_mandiri', child: Text('Hanya Jemput Sendiri di Titik Kampus')),
                        DropdownMenuItem(value: 'kurir_admin', child: Text('Hanya Diantar Kurir Admin ke Kos')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDelivery = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Section 4: Transparent Fee Breakdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: SwissColors.escrowIndigo),
                          const SizedBox(width: 6),
                          Text(
                            'SIMULASI DANA DITERIMA PENJUAL',
                            style: SwissTheme.mono(size: 11, weight: FontWeight.w700, color: SwissColors.escrowIndigo),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Harga Barang:', style: SwissTheme.sans(size: 12)),
                          Text(SwissTheme.formatRupiah(price), style: SwissTheme.mono(size: 12, weight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Fee Verifikasi Admin & Rekber:', style: SwissTheme.sans(size: 12)),
                          Text('- ${SwissTheme.formatRupiah(fee)}', style: SwissTheme.mono(size: 12, color: SwissColors.dangerRose)),
                        ],
                      ),
                      const Divider(color: SwissColors.borderHairline, height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Estimasi Saldo Diterima:', style: SwissTheme.display(size: 13, weight: FontWeight.w800)),
                          Text(
                            SwissTheme.formatRupiah(netIncome),
                            style: SwissTheme.display(size: 15, weight: FontWeight.w900, color: SwissColors.verifiedEmerald),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '* Pembayaran akan diteruskan ke rekening/e-wallet Anda setelah pembeli memeriksa fisik barang di kampus.',
                        style: SwissTheme.sans(size: 10, color: SwissColors.inkMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChipsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SwissColors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SwissColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, size: 16, color: SwissColors.cautionAmber),
              const SizedBox(width: 6),
              Text(
                'TEMPLATE CEPAT BARANG KOS POPULER',
                style: SwissTheme.mono(size: 10, weight: FontWeight.w700, color: SwissColors.inkPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _samplePresets.map((preset) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: const Color(0xFFF1F5F9),
                    label: Text(
                      preset['title']!,
                      style: SwissTheme.sans(size: 11, weight: FontWeight.w600, color: SwissColors.inkPrimary),
                    ),
                    onPressed: () => _applyPreset(preset),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection({required String title, required List<Widget> children}) {
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
          Text(title, style: SwissTheme.mono(size: 10, weight: FontWeight.w700, color: SwissColors.inkMuted)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: SwissTheme.sans(size: 12, weight: FontWeight.w600, color: SwissColors.inkPrimary)),
    );
  }

  InputDecoration _inputDecoration(String? hint, {String? prefix}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      hintStyle: SwissTheme.sans(size: 12, color: SwissColors.inkMuted),
      prefixStyle: SwissTheme.display(size: 13, weight: FontWeight.w700),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        borderSide: const BorderSide(color: SwissColors.rauschCoral, width: 1.5),
      ),
    );
  }
}
