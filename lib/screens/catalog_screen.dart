import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/swiss_theme.dart';
import '../widgets/geospatial_map_widget.dart';
import '../widgets/modals.dart';

/// ============================================================================
/// CATALOG SCREEN: BURSA INVENTARIS KOS MAHASISWA UPI YPTK (INDEX.PHP PARITY)
/// ============================================================================
class CatalogScreen extends StatefulWidget {
  final CampusTradeState appState;
  const CatalogScreen({super.key, required this.appState});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _radarMapKey = GlobalKey();
  final GlobalKey _productGridKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();

  static const Map<String, String> _categories = {
    'Semua': 'Semua Unit',
    'Perabotan Kos': 'Perabotan Kos',
    'Elektronik Kos': 'Elektronik',
    'Gadget & Komputer': 'Gadget & Komputer',
    'Buku & Modul Kuliah': 'Buku & Modul',
    'Peralatan Masak & Makan': 'Alat Masak',
    'Kendaraan & Aksesoris': 'Kendaraan & Helm',
    'Fashion & Seragam Kuliah': 'Fashion Kuliah',
    'Kebutuhan Harian & Hobi': 'Harian & Hobi',
    'Lain-lain': 'Lain-lain',
  };

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final BuildContext? targetContext = key.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleSellAction() {
    final UserModel? user = widget.appState.currentUser;
    if (user == null) {
      showAuthModal(context, widget.appState);
    } else if (user.statusVerifikasi == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Akun Anda (@${user.username}) sedang dalam antrean verifikasi KTM/KRS oleh Admin UPI YPTK. Fitur jual barang aktif setelah disetujui.',
          ),
        ),
      );
    } else if (user.statusVerifikasi == 'rejected') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verifikasi KTM Anda ditolak. Silakan hubungi Admin via WhatsApp untuk validasi ulang.',
          ),
        ),
      );
    } else {
      showSellProductModal(context, widget.appState);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: SwissColors.surface,
      bottomNavigationBar: isMobile ? _buildMobileBottomNav() : null,
      body: SafeArea(
        child: Column(
          children: [
            // 1. ANNOUNCEMENT BAR
            _buildAnnouncementBar(isMobile),

            // 2. STICKY PRECISION NAVBAR
            _buildNavbar(screenWidth),

            // 3. SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    // FLASH NOTIFICATION BARS
                    _buildFlashNotifications(),

                    // PENDING KTM VERIFICATION BANNER
                    _buildPendingKtmBanner(),

                    // HERO BENTO SECTION
                    _buildHeroSection(screenWidth),

                    // GEOSPATIAL RADAR MAP SECTION
                    Container(
                      key: _radarMapKey,
                      child: _buildRadarMapSection(screenWidth),
                    ),

                    // PRODUCT CATALOG GRID SECTION
                    Container(
                      key: _productGridKey,
                      child: _buildCatalogSection(screenWidth),
                    ),

                    // OFFICIAL COD SPOTS INFRASTRUCTURE SECTION
                    _buildCodSpotsSection(screenWidth),

                    // ARCHITECTURAL FOOTER
                    _buildFooter(screenWidth),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementBar(bool isMobile) {
    final String bannerText =
        widget.appState.platformSettings['banner_pengumuman'] ??
            'Bursa inventaris & perabotan kos mahasiswa UPI YPTK Padang — Terverifikasi KTM & bebas ongkir COD kampus.';

    return Container(
      width: double.infinity,
      color: SwissColors.zinc950,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: SwissColors.emerald400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!isMobile) ...[
                      Text(
                        'SISTEM AKTIF // ',
                        style: SwissTheme.mono(
                            size: 10, color: SwissColors.zinc400),
                      ),
                    ],
                    Expanded(
                      child: Text(
                        bannerText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SwissTheme.sans(
                          size: 11,
                          weight: FontWeight.w500,
                          color: SwissColors.zinc200,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 16),
                Row(
                  children: [
                    Text(
                      'ZONA: LUBUK BEGALUNG (-0.9575, 100.3972)',
                      style: SwissTheme.mono(
                          size: 10, color: SwissColors.zinc400),
                    ),
                    const SizedBox(width: 10),
                    Text('|',
                        style: SwissTheme.mono(
                            size: 10, color: SwissColors.zinc700)),
                    const SizedBox(width: 10),
                    Text(
                      'VERIFIKASI KTM AKTIF',
                      style: SwissTheme.mono(
                          size: 10,
                          weight: FontWeight.w700,
                          color: SwissColors.emerald400),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavbar(double screenWidth) {
    final bool isDesktop = screenWidth >= 768;
    final UserModel? user = widget.appState.currentUser;
    final bool isAdmin = user != null && user.role == 'admin';

    return Container(
      decoration: const BoxDecoration(
        color: SwissColors.white,
        border: Border(bottom: BorderSide(color: SwissColors.zinc200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand Identity
                  InkWell(
                    onTap: () => widget.appState.resetAllFilters(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: SwissColors.zinc950,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'CT',
                            style: SwissTheme.display(
                                size: 14, color: SwissColors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'CampusTrade',
                                  style: SwissTheme.display(size: 16),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: SwissColors.zinc100,
                                    borderRadius: BorderRadius.circular(4),
                                    border:
                                        Border.all(color: SwissColors.zinc200),
                                  ),
                                  child: Text(
                                    'UPI YPTK',
                                    style: SwissTheme.mono(
                                        size: 9, color: SwissColors.zinc700),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'LUBUK BEGALUNG • PADANG',
                              style: SwissTheme.mono(
                                  size: 9, color: SwissColors.zinc400),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Search Bar (Desktop)
                  if (isDesktop)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: _buildSearchField(),
                        ),
                      ),
                    ),

                  // Right Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isAdmin) ...[
                        OutlinedButton.icon(
                          onPressed: () =>
                              widget.appState.navigateTo('admin'),
                          icon: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: SwissColors.indigo600,
                              shape: BoxShape.circle,
                            ),
                          ),
                          label: Text(
                            'Admin CMS',
                            style: SwissTheme.sans(
                                size: 12,
                                weight: FontWeight.w600,
                                color: SwissColors.zinc900),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: SwissColors.zinc100,
                            side: const BorderSide(color: SwissColors.zinc300),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Sell Button with Verification Gatekeeper
                      _buildSellButton(user),
                      const SizedBox(width: 8),

                      // User Profile or Login Button
                      if (user != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: SwissColors.zinc50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: SwissColors.zinc200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 110),
                                        child: Text(
                                          user.nama,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: SwissTheme.sans(
                                              size: 11,
                                              weight: FontWeight.w700,
                                              color: SwissColors.zinc900),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: user.statusVerifikasi ==
                                                  'approved'
                                              ? SwissColors.emerald50
                                              : SwissColors.amber50,
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          border: Border.all(
                                            color: user.statusVerifikasi ==
                                                    'approved'
                                                ? SwissColors.emerald200
                                                : SwissColors.amber200,
                                          ),
                                        ),
                                        child: Text(
                                          user.statusVerifikasi == 'approved'
                                              ? 'VERIFIED'
                                              : 'PENDING',
                                          style: SwissTheme.mono(
                                            size: 8,
                                            color: user.statusVerifikasi ==
                                                    'approved'
                                                ? SwissColors.emerald700
                                                : SwissColors.amber800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '@${user.username}',
                                    style: SwissTheme.mono(
                                        size: 9, color: SwissColors.zinc500),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                onPressed: () => widget.appState.logout(),
                                icon: const Icon(Icons.logout,
                                    size: 16, color: SwissColors.zinc500),
                                tooltip: 'Keluar',
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                              ),
                            ],
                          ),
                        )
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () =>
                                  showAuthModal(context, widget.appState),
                              icon: const Icon(Icons.person_outline,
                                  size: 15, color: SwissColors.zinc600),
                              label: Text(
                                'Masuk',
                                style: SwissTheme.sans(
                                    size: 12,
                                    weight: FontWeight.w600,
                                    color: SwissColors.zinc800),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: SwissColors.white,
                                side: const BorderSide(
                                    color: SwissColors.zinc200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              onPressed: () =>
                                  widget.appState.navigateTo('admin'),
                              tooltip: 'Buka Demo Admin CMS',
                              icon: const Icon(Icons.admin_panel_settings_outlined,
                                  size: 18, color: SwissColors.indigo600),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),

              // Mobile Search Bar
              if (!isDesktop) ...[
                const SizedBox(height: 8),
                _buildSearchField(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSellButton(UserModel? user) {
    if (user != null && user.statusVerifikasi == 'pending') {
      return OutlinedButton.icon(
        onPressed: _handleSellAction,
        icon: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: SwissColors.amber500,
            shape: BoxShape.circle,
          ),
        ),
        label: Text(
          'Menunggu KTM',
          style: SwissTheme.sans(
              size: 12,
              weight: FontWeight.w600,
              color: SwissColors.amber800),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: SwissColors.amber50,
          side: const BorderSide(color: SwissColors.amber300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    if (user != null && user.statusVerifikasi == 'rejected') {
      return OutlinedButton(
        onPressed: _handleSellAction,
        style: OutlinedButton.styleFrom(
          backgroundColor: SwissColors.rose50,
          side: const BorderSide(color: SwissColors.rose200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'KTM Ditolak',
          style: SwissTheme.sans(
              size: 12, weight: FontWeight.w600, color: SwissColors.rose700),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _handleSellAction,
      icon: const Icon(Icons.add, size: 15),
      label: Text(
        'Jual Barang',
        style: SwissTheme.sans(
            size: 12, weight: FontWeight.w600, color: SwissColors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: SwissColors.zinc950,
        foregroundColor: SwissColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildSearchField() {
    if (_searchController.text != widget.appState.searchKeyword) {
      _searchController.value = TextEditingValue(
        text: widget.appState.searchKeyword,
        selection: TextSelection.collapsed(
            offset: widget.appState.searchKeyword.length),
      );
    }
    return TextField(
      controller: _searchController,
      onChanged: (v) => widget.appState.setSearchKeyword(v),
      style: SwissTheme.sans(size: 12, color: SwissColors.zinc900),
      decoration: InputDecoration(
        hintText: 'Cari kasur, dispenser, meja lipat, modul kuliah...',
        hintStyle: SwissTheme.sans(size: 12, color: SwissColors.zinc400),
        prefixIcon:
            const Icon(Icons.search, size: 16, color: SwissColors.zinc400),
        suffixIcon: widget.appState.searchKeyword.isNotEmpty
            ? TextButton(
                onPressed: () {
                  _searchController.clear();
                  widget.appState.setSearchKeyword('');
                },
                child: Text('ESC',
                    style:
                        SwissTheme.mono(size: 10, color: SwissColors.zinc500)),
              )
            : null,
        isDense: true,
        filled: true,
        fillColor: SwissColors.zinc50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SwissColors.zinc200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SwissColors.zinc200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SwissColors.zinc950),
        ),
      ),
    );
  }

  Widget _buildFlashNotifications() {
    final s = widget.appState;
    return Column(
      children: [
        if (s.flashSuccess != null)
          _flashBanner(
            bg: SwissColors.emerald600,
            tagBg: SwissColors.emerald700,
            tag: 'SUKSES',
            text: s.flashSuccess!,
            textColor: SwissColors.white,
            onClose: () => s.clearFlash('success'),
          ),
        if (s.flashWarning != null)
          _flashBanner(
            bg: SwissColors.amber500,
            tagBg: SwissColors.amber600,
            tag: 'STATUS',
            text: s.flashWarning!,
            textColor: SwissColors.zinc950,
            onClose: () => s.clearFlash('warning'),
          ),
        if (s.flashError != null)
          _flashBanner(
            bg: SwissColors.rose600,
            tagBg: SwissColors.rose700,
            tag: 'PERINGATAN',
            text: s.flashError!,
            textColor: SwissColors.white,
            onClose: () => s.clearFlash('error'),
          ),
      ],
    );
  }

  Widget _flashBanner({
    required Color bg,
    required Color tagBg,
    required String tag,
    required String text,
    required Color textColor,
    required VoidCallback onClose,
  }) {
    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: SwissTheme.mono(size: 10, color: SwissColors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: SwissTheme.sans(
                    size: 12,
                    weight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: Icon(Icons.close, size: 15, color: textColor),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingKtmBanner() {
    final UserModel? user = widget.appState.currentUser;
    if (user == null || user.statusVerifikasi != 'pending') {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: SwissColors.amber50,
        border: Border(bottom: BorderSide(color: SwissColors.amber200)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: SwissColors.amber500,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'VERIFIKASI KTM PENDING // ',
                            style: SwissTheme.mono(
                                size: 10,
                                weight: FontWeight.w700,
                                color: SwissColors.amber800),
                          ),
                          TextSpan(
                            text:
                                'Akun @${user.username} sedang ditinjau Admin. Fitur pasang iklan aktif setelah disetujui.',
                            style: SwissTheme.sans(
                                size: 12, color: SwissColors.amber950),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  widget.appState.approveUserKtm(user.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SwissColors.zinc950,
                  foregroundColor: SwissColors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Konfirmasi via WhatsApp / Simulasi Approve ->',
                  style: SwissTheme.sans(
                      size: 11,
                      weight: FontWeight.w600,
                      color: SwissColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(double screenWidth) {
    final bool isDesktop = screenWidth >= 960;
    final int totalApproved = widget.appState.countApprovedProducts;
    final int activeSpotsCount = widget.appState.activeCodSpots.length;

    final Widget leftCard = Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 22),
      decoration: BoxDecoration(
        color: SwissColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SwissColors.zinc200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: SwissColors.zinc100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: SwissColors.zinc200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: SwissColors.indigo600,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'HYPER-LOCAL MARKETPLACE • UPI YPTK PADANG',
                      style: SwissTheme.mono(
                          size: 10, color: SwissColors.zinc700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Transaksi Inventaris & Perabotan Kos Mahasiswa Tanpa Risiko.',
                style: SwissTheme.display(
                  size: isDesktop ? 34 : 24,
                  height: 1.15,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Platform sirkular khusus civitas akademika Universitas Putra Indonesia "YPTK" Padang. Setiap akun penjual terverifikasi KTM/KRS, barang melewati inspeksi fisik admin, dan serah terima dilakukan di titik COD resmi Lubuk Begalung.',
                style: SwissTheme.sans(
                  size: isDesktop ? 14 : 12,
                  color: SwissColors.zinc600,
                  height: 1.55,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => _scrollToSection(_productGridKey),
                icon: const Icon(Icons.arrow_forward, size: 15),
                label: Text(
                  'Telusuri Katalog',
                  style: SwissTheme.sans(
                      size: 12,
                      weight: FontWeight.w600,
                      color: SwissColors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SwissColors.zinc950,
                  foregroundColor: SwissColors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _scrollToSection(_radarMapKey),
                icon: const Icon(Icons.location_on_outlined,
                    size: 15, color: SwissColors.indigo600),
                label: Text(
                  'Peta Radius & Titik COD',
                  style: SwissTheme.sans(
                      size: 12,
                      weight: FontWeight.w600,
                      color: SwissColors.zinc800),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: SwissColors.white,
                  side: const BorderSide(color: SwissColors.zinc200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final Widget rightColumn = Column(
      children: [
        // Top Bento Card: Live Metrics
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SwissColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SwissColors.zinc200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TELEMETRI BURSA',
                        style: SwissTheme.mono(
                            size: 10, color: SwissColors.zinc400),
                      ),
                      Text(
                        'Parameter Keamanan Transaksi',
                        style: SwissTheme.display(size: 14),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                          'ESCROW ON',
                          style: SwissTheme.mono(
                              size: 10, color: SwissColors.emerald700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  Expanded(
                    child: _metricBox(
                      label: 'KATALOG',
                      value: '$totalApproved',
                      sub: 'Unit Terkurasi',
                      valueColor: SwissColors.zinc950,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _metricBox(
                      label: 'TITIK COD',
                      value: '$activeSpotsCount',
                      sub: 'Zona Resmi',
                      valueColor: SwissColors.indigo600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _metricBox(
                      label: 'VALIDASI',
                      value: '100%',
                      sub: 'Wajib KTM',
                      valueColor: SwissColors.emerald600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Bottom Bento Card: Protocol Info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SwissColors.zinc950,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SwissColors.zinc800),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PROTOKOL ANTI-PENIPUAN',
                    style: SwissTheme.mono(
                        size: 10, color: SwissColors.indigo400),
                  ),
                  Text(
                    'SOP // 01',
                    style:
                        SwissTheme.mono(size: 10, color: SwissColors.zinc500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Pembayaran ditahan di rekening bersama (Rekber) admin atau dibayar tunai saat cek fisik di titik COD resmi (Lobi UCC, Gedung B Fasilkom, atau Pos Keamanan Gerbang Lubeg).',
                style: SwissTheme.sans(
                  size: 12,
                  color: SwissColors.zinc300,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SwissColors.zinc200)),
      ),
      child: SwissGridBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: leftCard),
                        const SizedBox(width: 24),
                        Expanded(flex: 5, child: rightColumn),
                      ],
                    )
                  : Column(
                      children: [
                        leftCard,
                        const SizedBox(height: 16),
                        rightColumn,
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricBox({
    required String label,
    required String value,
    required String sub,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: SwissColors.zinc50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SwissColors.zinc200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: SwissTheme.mono(size: 9, color: SwissColors.zinc400)),
          const SizedBox(height: 2),
          Text(value,
              style: SwissTheme.display(size: 20, color: valueColor)),
          Text(sub,
              style: SwissTheme.sans(size: 10, color: SwissColors.zinc500)),
        ],
      ),
    );
  }

  Widget _buildRadarMapSection(double screenWidth) {
    final s = widget.appState;
    final activeSpots = s.activeCodSpots;
    final filteredProducts = s.filteredCatalogProducts;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: SwissColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SwissColors.zinc200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: SwissColors.zinc100,
                                borderRadius: BorderRadius.circular(4),
                                border:
                                    Border.all(color: SwissColors.zinc200),
                              ),
                              child: Text(
                                'GEOSPATIAL RADAR',
                                style: SwissTheme.mono(
                                    size: 10, color: SwissColors.zinc700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Peta Radius Kos & Titik COD Resmi',
                                style: SwissTheme.display(size: 17),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pemetaan posisi kosan penjual terhadap ${activeSpots.length} titik serah terima resmi di sekitar kampus UPI YPTK Lubuk Begalung.',
                          style: SwissTheme.sans(
                              size: 12, color: SwissColors.zinc500),
                        ),
                      ],
                    ),

                    // Radius Filter & Expand Map Button
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Text(
                          'RADIUS:',
                          style: SwissTheme.mono(
                              size: 10, color: SwissColors.zinc500),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: SwissColors.zinc50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: SwissColors.zinc200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: s.selectedRadiusKm,
                              isDense: true,
                              style: SwissTheme.mono(
                                  size: 11, color: SwissColors.zinc800),
                              items: const [
                                DropdownMenuItem(
                                    value: 'all',
                                    child: Text('SEMUA (< 5.0 KM)')),
                                DropdownMenuItem(
                                    value: '0.5',
                                    child: Text('< 0.5 KM (JALAN KAKI)')),
                                DropdownMenuItem(
                                    value: '1',
                                    child: Text('< 1.0 KM (ZONA INTI)')),
                                DropdownMenuItem(
                                    value: '2',
                                    child: Text('< 2.0 KM (LUBEG RAYA)')),
                              ],
                              onChanged: (v) {
                                if (v != null) s.setRadiusFilter(v);
                              },
                            ),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => s.toggleMainMapExpand(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: SwissColors.zinc100,
                            side: const BorderSide(color: SwissColors.zinc200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            s.isMainMapExpanded
                                ? 'Kecilkan Peta'
                                : 'Perbesar Peta',
                            style: SwissTheme.sans(
                              size: 12,
                              weight: FontWeight.w600,
                              color: SwissColors.zinc800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Interactive Radar Map
                GeospatialRadarMap(
                  codSpots: activeSpots,
                  products: filteredProducts,
                  selectedRadiusKm: s.selectedRadiusKm,
                  height: s.isMainMapExpanded ? 460 : 300,
                  onSelectProduct: (prod) =>
                      showProductDetailModal(context, s, prod),
                ),

                const SizedBox(height: 12),

                // Map Legend
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Wrap(
                      spacing: 16,
                      runSpacing: 6,
                      children: [
                        _legendDot(SwissColors.indigo600, 'TITIK COD RESMI'),
                        _legendDot(
                            SwissColors.emerald600, 'LOKASI KOS BARANG'),
                        _legendDot(
                            SwissColors.amber500, 'TERSEDIA KURIR ADMIN'),
                      ],
                    ),
                    Text(
                      'KLIK PIN PADA PETA UNTUK RINCIAN UNIT',
                      style: SwissTheme.mono(
                          size: 10, color: SwissColors.zinc400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: SwissTheme.mono(size: 10, color: SwissColors.zinc500)),
      ],
    );
  }

  Widget _buildCatalogSection(double screenWidth) {
    final s = widget.appState;
    final filtered = s.filteredCatalogProducts;

    int crossAxisCount = 1;
    if (screenWidth >= 1080) {
      crossAxisCount = 4;
    } else if (screenWidth >= 768) {
      crossAxisCount = 3;
    } else if (screenWidth >= 520) {
      crossAxisCount = 2;
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INVENTARIS TERKURASI',
                        style: SwissTheme.mono(
                            size: 10,
                            weight: FontWeight.w700,
                            color: SwissColors.indigo600),
                      ),
                      Text(
                        'Katalog Barang Kos Mahasiswa',
                        style: SwissTheme.display(size: 22),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'MENAMPILKAN:',
                        style: SwissTheme.mono(
                            size: 11, color: SwissColors.zinc500),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: SwissColors.zinc100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: SwissColors.zinc200),
                        ),
                        child: Text(
                          '${filtered.length} Barang',
                          style: SwissTheme.mono(
                            size: 11,
                            weight: FontWeight.w700,
                            color: SwissColors.zinc950,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Architectural Tabs
              Container(
                decoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: SwissColors.zinc200)),
                ),
                padding: const EdgeInsets.only(bottom: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.entries.map((entry) {
                      final bool active = s.selectedCategory == entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => s.setCategory(entry.key),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: active
                                  ? SwissColors.zinc950
                                  : SwissColors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: active
                                    ? SwissColors.zinc950
                                    : SwissColors.zinc200,
                              ),
                            ),
                            child: Text(
                              entry.value,
                              style: SwissTheme.sans(
                                size: 12,
                                weight: active
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: active
                                    ? SwissColors.white
                                    : SwissColors.zinc600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Product Grid or Empty State
              if (filtered.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 48),
                  decoration: BoxDecoration(
                    color: SwissColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SwissColors.zinc300),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'UNIT TIDAK DITEMUKAN',
                        style: SwissTheme.display(size: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tidak ada inventaris kos yang cocok dengan filter kategori atau kata kunci pencarian saat ini.',
                        textAlign: TextAlign.center,
                        style: SwissTheme.sans(
                            size: 12, color: SwissColors.zinc500),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _searchController.clear();
                          s.resetAllFilters();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SwissColors.zinc950,
                          foregroundColor: SwissColors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Reset Filter Katalog',
                          style: SwissTheme.sans(
                              size: 12,
                              weight: FontWeight.w600,
                              color: SwissColors.white),
                        ),
                      ),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    mainAxisExtent: 392,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(filtered[index]);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel prod) {
    final s = widget.appState;
    final UserModel? user = s.currentUser;
    final bool isOwnerOrAdmin = user != null &&
        (user.role == 'admin' || user.id == prod.userId);

    return Container(
      decoration: BoxDecoration(
        color: SwissColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SwissColors.zinc200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A09090B),
            blurRadius: 4,
            offset: Offset(0, 1),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container
          GestureDetector(
            onTap: () => showProductDetailModal(context, s, prod),
            child: SizedBox(
              height: 185,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    prod.foto,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: SwissColors.zinc100,
                      child: const Icon(Icons.inventory_2_outlined,
                          size: 36, color: SwissColors.zinc400),
                    ),
                  ),
                  // Top Technical Tags
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xE609090B),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: SwissColors.emerald400,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'QC PASS',
                                style: SwissTheme.mono(
                                    size: 9, color: SwissColors.white),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xF2FFFFFF),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: SwissColors.zinc200),
                          ),
                          child: Text(
                            '${prod.distanceToCampusKm} KM',
                            style: SwissTheme.mono(
                                size: 9, color: SwissColors.zinc900),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Condition Tag
                  Positioned(
                    bottom: 8,
                    left: 10,
                    right: 10,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xCC09090B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          prod.kondisi,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SwissTheme.mono(
                              size: 9, color: SwissColors.zinc100),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Card Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              prod.kategori.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SwissTheme.mono(
                                size: 10,
                                weight: FontWeight.w700,
                                color: SwissColors.indigo600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: prod.metodePengiriman == 'kurir_admin'
                                  ? SwissColors.zinc100
                                  : SwissColors.emerald50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              prod.metodePengiriman == 'kurir_admin'
                                  ? 'KURIR'
                                  : 'COD / KURIR',
                              style: SwissTheme.mono(
                                size: 9,
                                color: prod.metodePengiriman == 'kurir_admin'
                                    ? SwissColors.zinc600
                                    : SwissColors.emerald700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      InkWell(
                        onTap: () => showProductDetailModal(context, s, prod),
                        child: Text(
                          prod.namaBarang,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SwissTheme.display(size: 15),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prod.deskripsi,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: SwissTheme.sans(
                          size: 12,
                          color: SwissColors.zinc500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),

                  // Price & Action Footer
                  Column(
                    children: [
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                SwissTheme.formatRupiah(
                                    prod.effectiveOriginalPrice),
                                style: SwissTheme.mono(
                                  size: 10,
                                  color: SwissColors.zinc400,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              Text(
                                SwissTheme.formatRupiah(prod.harga),
                                style: SwissTheme.display(size: 17),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: SwissColors.emerald50,
                              borderRadius: BorderRadius.circular(4),
                              border:
                                  Border.all(color: SwissColors.emerald200),
                            ),
                            child: Text(
                              '-${prod.savingsPercent}%',
                              style: SwissTheme.mono(
                                size: 10,
                                weight: FontWeight.w700,
                                color: SwissColors.emerald700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'COD: ${prod.titikCod}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SwissTheme.mono(
                                  size: 10, color: SwissColors.zinc500),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isOwnerOrAdmin)
                                IconButton(
                                  onPressed: () => s.deleteProduct(prod.id),
                                  icon: const Icon(Icons.delete_outline,
                                      size: 16, color: SwissColors.rose600),
                                  constraints: const BoxConstraints(),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  tooltip: 'Hapus',
                                ),
                              InkWell(
                                onTap: () =>
                                    showProductDetailModal(context, s, prod),
                                child: Text(
                                  'INSPEKSI ->',
                                  style: SwissTheme.mono(
                                    size: 10,
                                    weight: FontWeight.w700,
                                    color: SwissColors.zinc950,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodSpotsSection(double screenWidth) {
    final activeSpots = widget.appState.activeCodSpots;
    int cols = 1;
    if (screenWidth >= 960) {
      cols = 3;
    } else if (screenWidth >= 600) {
      cols = 2;
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: SwissColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SwissColors.zinc200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INFRASTRUKTUR LOGISTIK',
                          style: SwissTheme.mono(
                            size: 10,
                            weight: FontWeight.w700,
                            color: SwissColors.indigo600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Titik Temu COD Resmi Terverifikasi',
                          style: SwissTheme.display(size: 19),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dikelola secara dinamis oleh Administrator. Apabila otoritas kampus membatasi akses di area akademik, titik dialihkan ke perimeter publik.',
                          style: SwissTheme.sans(
                              size: 12, color: SwissColors.zinc500),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: SwissColors.emerald50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: SwissColors.emerald200),
                      ),
                      child: Text(
                        '${activeSpots.length} ZONA AKTIF',
                        style: SwissTheme.mono(
                          size: 10,
                          weight: FontWeight.w700,
                          color: SwissColors.emerald700,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 126,
                  ),
                  itemCount: activeSpots.length,
                  itemBuilder: (ctx, i) {
                    final spot = activeSpots[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: SwissColors.zinc50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: SwissColors.zinc200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: SwissColors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border:
                                      Border.all(color: SwissColors.zinc200),
                                ),
                                child: Text(
                                  spot.categoryTag,
                                  style: SwissTheme.mono(
                                      size: 9, color: SwissColors.zinc700),
                                ),
                              ),
                              Text(
                                '${spot.latitude.toStringAsFixed(4)}, ${spot.longitude.toStringAsFixed(4)}',
                                style: SwissTheme.mono(
                                    size: 10, color: SwissColors.zinc400),
                              ),
                            ],
                          ),
                          Text(
                            spot.namaTitik,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SwissTheme.display(size: 14),
                          ),
                          Text(
                            spot.deskripsi,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: SwissTheme.sans(
                                size: 11, color: SwissColors.zinc500),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(double screenWidth) {
    final bool isDesktop = screenWidth >= 768;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: SwissColors.white,
        border: Border(top: BorderSide(color: SwissColors.zinc200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: _footerBrand()),
                        const SizedBox(width: 24),
                        Expanded(flex: 3, child: _footerCategories()),
                        const SizedBox(width: 24),
                        Expanded(flex: 3, child: _footerAuthority()),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _footerBrand(),
                        const SizedBox(height: 20),
                        _footerCategories(),
                        const SizedBox(height: 20),
                        _footerAuthority(),
                      ],
                    ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(height: 1),
              ),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(
                    'TIM PENGEMBANG: MUHAMMAD IQBAL MAULANA (24101152610172) • OKTA KHAIRUL RAMADHAN (24101152610177) • TRY ANGGARA YOFA (24101152610222)',
                    style: SwissTheme.mono(size: 10, color: SwissColors.zinc500),
                  ),
                  Text(
                    '© ${DateTime.now().year} CAMPUSTRADE UPI YPTK. ALL RIGHTS RESERVED.',
                    style: SwissTheme.mono(size: 10, color: SwissColors.zinc400),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: SwissColors.zinc950,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                'CT',
                style: SwissTheme.display(size: 12, color: SwissColors.white),
              ),
            ),
            const SizedBox(width: 8),
            Text('CampusTrade', style: SwissTheme.display(size: 16)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: SwissColors.zinc100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: SwissColors.zinc200),
              ),
              child: Text(
                'UPI YPTK PADANG',
                style: SwissTheme.mono(size: 9, color: SwissColors.zinc700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Text(
            'Infrastruktur pasar sirkular hyper-lokal untuk mahasiswa Universitas Putra Indonesia "YPTK" Padang. Dirancang dengan verifikasi identitas KTM, inspeksi fisik kualitas unit, serta titik temu COD resmi di kawasan Lubuk Begalung.',
            style: SwissTheme.sans(
                size: 12, color: SwissColors.zinc500, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _footerCategories() {
    final cats = [
      'Semua',
      'Perabotan Kos',
      'Elektronik Kos',
      'Gadget & Komputer',
      'Buku & Modul Kuliah',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KATEGORI INVENTARIS',
          style: SwissTheme.mono(size: 10, color: SwissColors.zinc400),
        ),
        const SizedBox(height: 8),
        ...cats.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () {
                widget.appState.setCategory(c);
                _scrollToSection(_productGridKey);
              },
              child: Text(
                c == 'Semua' ? 'Semua Unit' : c,
                style: SwissTheme.sans(
                    size: 12,
                    weight: FontWeight.w500,
                    color: SwissColors.zinc600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _footerAuthority() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OTORITAS PENGEMBANG',
          style: SwissTheme.mono(size: 10, color: SwissColors.zinc400),
        ),
        const SizedBox(height: 8),
        Text(
          'Fakultas Ilmu Komputer (Fasilkom)',
          style: SwissTheme.sans(
              size: 12, weight: FontWeight.w700, color: SwissColors.zinc900),
        ),
        const SizedBox(height: 4),
        Text(
          'Universitas Putra Indonesia "YPTK" Padang',
          style: SwissTheme.sans(size: 12, color: SwissColors.zinc600),
        ),
        const SizedBox(height: 4),
        Text(
          'JL. RAYA LUBUK BEGALUNG, PADANG',
          style: SwissTheme.mono(size: 10, color: SwissColors.zinc400),
        ),
      ],
    );
  }

  Widget _buildMobileBottomNav() {
    final UserModel? user = widget.appState.currentUser;
    return Container(
      decoration: const BoxDecoration(
        color: SwissColors.white,
        border: Border(top: BorderSide(color: SwissColors.zinc200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _mobileNavItem(
            icon: Icons.home_outlined,
            label: 'BERANDA',
            onTap: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
          ),
          _mobileNavItem(
            icon: Icons.location_on_outlined,
            label: 'RADAR',
            onTap: () => _scrollToSection(_radarMapKey),
          ),
          ElevatedButton(
            onPressed: _handleSellAction,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (user != null && user.statusVerifikasi != 'approved')
                      ? SwissColors.amber500
                      : SwissColors.zinc950,
              foregroundColor: SwissColors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              (user != null && user.statusVerifikasi != 'approved')
                  ? 'PENDING'
                  : '+ JUAL',
              style: SwissTheme.mono(
                size: 10,
                weight: FontWeight.w700,
                color: (user != null && user.statusVerifikasi != 'approved')
                    ? SwissColors.zinc950
                    : SwissColors.white,
              ),
            ),
          ),
          _mobileNavItem(
            icon: Icons.grid_view_outlined,
            label: 'KATALOG',
            onTap: () => _scrollToSection(_productGridKey),
          ),
          _mobileNavItem(
            icon: user != null ? Icons.logout : Icons.person_outline,
            label: user != null ? 'KELUAR' : 'MASUK',
            onTap: () {
              if (user != null) {
                widget.appState.logout();
              } else {
                showAuthModal(context, widget.appState);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _mobileNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: SwissColors.zinc600),
            const SizedBox(height: 2),
            Text(
              label,
              style: SwissTheme.mono(size: 9, color: SwissColors.zinc600),
            ),
          ],
        ),
      ),
    );
  }
}
