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
  void initState() {
    super.initState();
    _searchController.text = widget.appState.searchKeyword;
    widget.appState.addListener(_syncSearch);
  }

  void _syncSearch() {
    if (_searchController.text != widget.appState.searchKeyword) {
      _searchController.text = widget.appState.searchKeyword;
    }
  }

  @override
  void dispose() {
    widget.appState.removeListener(_syncSearch);
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
      backgroundColor: SwissColors.canvasPure,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: isMobile
          ? BottomAppBar(
              elevation: 8,
              shadowColor: Colors.black26,
              color: SwissColors.canvasPure,
              surfaceTintColor: Colors.transparent,
              padding: EdgeInsets.zero,
              height: 62,
              child: _buildMobileBottomNav(),
            )
          : null,
      body: SafeArea(
        top: true,
        bottom: !isMobile,
        child: Column(
          children: [
            // 1. STICKY ANNOUNCEMENT BAR (RUNNING TEXT MARQUEE)
            _buildAnnouncementBar(isMobile),

            // 2. STICKY PRECISION NAVBAR
            _buildNavbar(screenWidth),

            // 3. SCROLLABLE CONTENT (PULL/SCROLL HANYA PADA KONTEN KATALOG)
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // FLASH NOTIFICATION BARS
                    _buildFlashNotifications(),

                    // PENDING KTM VERIFICATION BANNER
                    _buildPendingKtmBanner(),

                    // HERO BENTO SECTION
                    RepaintBoundary(
                      child: _buildHeroSection(screenWidth),
                    ),

                    // GEOSPATIAL RADAR MAP SECTION
                    RepaintBoundary(
                      child: Container(
                        key: _radarMapKey,
                        child: _buildRadarMapSection(screenWidth),
                      ),
                    ),

                    // PRODUCT CATALOG GRID SECTION
                    RepaintBoundary(
                      child: Container(
                        key: _productGridKey,
                        child: _buildCatalogSection(screenWidth),
                      ),
                    ),

                    // OFFICIAL COD SPOTS INFRASTRUCTURE SECTION
                    RepaintBoundary(
                      child: _buildCodSpotsSection(screenWidth),
                    ),

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
      color: SwissColors.inkPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
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
                        color: SwissColors.verifiedEmerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!isMobile) ...[
                      Text(
                        'SISTEM AKTIF // ',
                        style: SwissTheme.mono(
                            size: 10, color: SwissColors.inkMuted),
                      ),
                    ],
                    Expanded(
                      child: SizedBox(
                        height: 20,
                        child: SwissMarqueeText(
                          text: bannerText,
                          style: SwissTheme.sans(
                            size: 11,
                            weight: FontWeight.w500,
                            color: SwissColors.canvasWarm,
                          ),
                          speed: 36.0,
                          blankSpace: 48.0,
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
                          size: 10, color: SwissColors.inkMuted),
                    ),
                    const SizedBox(width: 10),
                    Text('|',
                        style: SwissTheme.mono(
                            size: 10, color: const Color(0xFF444444))),
                    const SizedBox(width: 10),
                    Text(
                      'VERIFIKASI KTM AKTIF',
                      style: SwissTheme.mono(
                          size: 10,
                          weight: FontWeight.w700,
                          color: SwissColors.verifiedEmerald),
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
        color: SwissColors.canvasPure,
        border: Border(bottom: BorderSide(color: SwissColors.borderHairline)),
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
                  Flexible(
                    child: InkWell(
                      onTap: () => widget.appState.resetAllFilters(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: SwissColors.rauschCoral,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33FF385C),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'CT',
                              style: SwissTheme.display(
                                  size: 14, color: SwissColors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'CampusTrade',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: SwissTheme.display(
                                            size: isDesktop ? 16 : 15,
                                            color: SwissColors.inkPrimary),
                                      ),
                                    ),
                                    if (isDesktop) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: SwissColors.canvasWarm,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          border: Border.all(
                                              color: SwissColors.borderHairline),
                                        ),
                                        child: Text(
                                          'UPI YPTK',
                                          style: SwissTheme.mono(
                                              size: 9,
                                              weight: FontWeight.w700,
                                              color: SwissColors.inkSecondary),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (isDesktop)
                                  Text(
                                    'LUBUK BEGALUNG • PADANG',
                                    style: SwissTheme.mono(
                                        size: 9, color: SwissColors.inkMuted),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Search Bar (Desktop)
                  if (isDesktop)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: _buildSearchField(),
                          ),
                        ),
                      ),
                    ),

                  // Right Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isAdmin) ...[
                        if (isDesktop)
                          OutlinedButton.icon(
                            onPressed: () =>
                                widget.appState.navigateTo('admin'),
                            icon: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: SwissColors.linearLavender,
                                shape: BoxShape.circle,
                              ),
                            ),
                            label: Text(
                              'Admin CMS',
                              style: SwissTheme.sans(
                                  size: 12,
                                  weight: FontWeight.w600,
                                  color: SwissColors.inkPrimary),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: SwissColors.canvasWarm,
                              side: const BorderSide(
                                  color: SwissColors.borderHairline),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          )
                        else
                          IconButton(
                            onPressed: () =>
                                widget.appState.navigateTo('admin'),
                            tooltip: 'Admin CMS',
                            icon: const Icon(Icons.shield_outlined,
                                size: 18, color: SwissColors.linearLavender),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                          ),
                        const SizedBox(width: 6),
                      ],

                      // Sell Button with Verification Gatekeeper
                      _buildSellButton(user, isDesktop: isDesktop),
                      const SizedBox(width: 6),

                      // User Profile or Login Button
                      if (user != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 10 : 8,
                              vertical: isDesktop ? 4 : 2),
                          decoration: BoxDecoration(
                            color: SwissColors.canvasWarm,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: SwissColors.borderHairline),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxWidth: isDesktop ? 110 : 65),
                                        child: Text(
                                          user.nama,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: SwissTheme.sans(
                                              size: 11,
                                              weight: FontWeight.w700,
                                              color: SwissColors.inkPrimary),
                                        ),
                                      ),
                                      if (isDesktop) ...[
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: user.statusVerifikasi ==
                                                    'approved'
                                                ? const Color(0xFFECFDF5)
                                                : const Color(0xFFFFFBEB),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            border: Border.all(
                                              color: user.statusVerifikasi ==
                                                      'approved'
                                                  ? const Color(0xFFA7F3D0)
                                                  : const Color(0xFFFDE68A),
                                            ),
                                          ),
                                          child: Text(
                                            user.statusVerifikasi == 'approved'
                                                ? 'VERIFIED'
                                                : 'PENDING',
                                            style: SwissTheme.mono(
                                              size: 8,
                                              weight: FontWeight.w700,
                                              color: user.statusVerifikasi ==
                                                      'approved'
                                                  ? SwissColors.verifiedEmerald
                                                  : SwissColors.cautionAmber,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (isDesktop)
                                    Text(
                                      '@${user.username}',
                                      style: SwissTheme.mono(
                                          size: 9,
                                          color: SwissColors.inkSecondary),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                onPressed: () => widget.appState.logout(),
                                icon: const Icon(Icons.logout,
                                    size: 16, color: SwissColors.inkSecondary),
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
                                  size: 15, color: SwissColors.inkPrimary),
                              label: Text(
                                'Masuk',
                                style: SwissTheme.sans(
                                    size: 12,
                                    weight: FontWeight.w600,
                                    color: SwissColors.inkPrimary),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: SwissColors.canvasPure,
                                side: const BorderSide(
                                    color: SwissColors.borderHairline),
                                padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 14 : 10,
                                    vertical: isDesktop ? 10 : 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            if (isDesktop) ...[
                              const SizedBox(width: 6),
                              IconButton(
                                onPressed: () =>
                                    widget.appState.navigateTo('admin'),
                                tooltip: 'Buka Demo Admin CMS',
                                icon: const Icon(
                                    Icons.admin_panel_settings_outlined,
                                    size: 18,
                                    color: SwissColors.linearLavender),
                              ),
                            ],
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

  Widget _buildSellButton(UserModel? user, {bool isDesktop = true}) {
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
          isDesktop ? 'Menunggu KTM' : 'Pending',
          style: SwissTheme.sans(
              size: 12,
              weight: FontWeight.w600,
              color: SwissColors.amber800),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: SwissColors.amber50,
          side: const BorderSide(color: SwissColors.amber300),
          padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 12 : 8, vertical: isDesktop ? 10 : 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      );
    }

    if (user != null && user.statusVerifikasi == 'rejected') {
      return OutlinedButton(
        onPressed: _handleSellAction,
        style: OutlinedButton.styleFrom(
          backgroundColor: SwissColors.rose50,
          side: const BorderSide(color: SwissColors.rose200),
          padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 12 : 8, vertical: isDesktop ? 10 : 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        child: Text(
          isDesktop ? 'KTM Ditolak' : 'Ditolak',
          style: SwissTheme.sans(
              size: 12, weight: FontWeight.w600, color: SwissColors.rose700),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _handleSellAction,
      icon: const Icon(Icons.add, size: 15),
      label: Text(
        isDesktop ? 'Jual Barang' : 'Jual',
        style: SwissTheme.sans(
            size: 12, weight: FontWeight.w700, color: SwissColors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: SwissColors.rauschCoral,
        foregroundColor: SwissColors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 16 : 12, vertical: isDesktop ? 10 : 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: SwissColors.canvasPure,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SwissColors.borderHairline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => widget.appState.setSearchKeyword(v),
        textAlignVertical: TextAlignVertical.center,
        style: SwissTheme.sans(size: 13, color: SwissColors.inkPrimary),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Cari kasur, dispenser, meja lipat, modul kuliah...',
          hintStyle: SwissTheme.sans(size: 12, color: SwissColors.inkMuted),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 8),
            child: Icon(Icons.search, size: 18, color: SwissColors.inkSecondary),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 46),
          suffixIconConstraints:
              const BoxConstraints(minHeight: 46),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.appState.searchKeyword.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close,
                      size: 16, color: SwissColors.inkSecondary),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(),
                  splashRadius: 18,
                  onPressed: () {
                    _searchController.clear();
                    widget.appState.setSearchKeyword('');
                  },
                ),
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: InkWell(
                  onTap: () {
                    // Trigger search action
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: SwissColors.rauschCoral,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33FF385C),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child:
                        const Icon(Icons.search, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
            textColor: SwissColors.inkPrimary,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth >= 640;
              final statusText = Row(
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
                  Expanded(
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
              );

              final actionBtn = ElevatedButton(
                onPressed: () {
                  widget.appState.approveUserKtm(user.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SwissColors.inkPrimary,
                  foregroundColor: SwissColors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                ),
                child: Text(
                  'Konfirmasi via WhatsApp / Simulasi Approve ->',
                  style: SwissTheme.sans(
                      size: 11,
                      weight: FontWeight.w600,
                      color: SwissColors.white),
                ),
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: statusText),
                    const SizedBox(width: 14),
                    actionBtn,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  statusText,
                  const SizedBox(height: 10),
                  actionBtn,
                ],
              );
            },
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
        color: SwissColors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SwissColors.borderHairline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
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
                  color: SwissColors.canvasWarm,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: SwissColors.borderHairline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: SwissColors.rauschCoral,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'HYPER-LOCAL MARKETPLACE • UPI YPTK PADANG',
                      style: SwissTheme.mono(
                          size: 10,
                          weight: FontWeight.w700,
                          color: SwissColors.inkSecondary),
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
                  color: SwissColors.inkSecondary,
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
                  backgroundColor: SwissColors.rauschCoral,
                  foregroundColor: SwissColors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _scrollToSection(_radarMapKey),
                icon: const Icon(Icons.location_on_outlined,
                    size: 15, color: SwissColors.inkPrimary),
                label: Text(
                  'Peta Radius & Titik COD',
                  style: SwissTheme.sans(
                      size: 12,
                      weight: FontWeight.w600,
                      color: SwissColors.inkPrimary),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: SwissColors.canvasPure,
                  side: const BorderSide(color: SwissColors.borderHairline),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
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
            color: SwissColors.canvasPure,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SwissColors.borderHairline),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TELEMETRI BURSA',
                          style: SwissTheme.mono(
                              size: 10, color: SwissColors.inkMuted),
                        ),
                        Text(
                          'Parameter Keamanan Transaksi',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SwissTheme.display(size: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                          'ESCROW ON',
                          style: SwissTheme.mono(
                              size: 10,
                              weight: FontWeight.w700,
                              color: SwissColors.verifiedEmerald),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: SwissColors.borderHairline),
              ),
              Row(
                children: [
                  Expanded(
                    child: _metricBox(
                      label: 'KATALOG',
                      value: '$totalApproved',
                      sub: 'Unit Terkurasi',
                      valueColor: SwissColors.inkPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _metricBox(
                      label: 'TITIK COD',
                      value: '$activeSpotsCount',
                      sub: 'Zona Resmi',
                      valueColor: SwissColors.escrowIndigo,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _metricBox(
                      label: 'VALIDASI',
                      value: '100%',
                      sub: 'Wajib KTM',
                      valueColor: SwissColors.verifiedEmerald,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Bottom Bento Card: Protocol Info (Uber High Contrast)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SwissColors.uberBlack,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF222222)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
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
                        size: 10,
                        weight: FontWeight.w700,
                        color: SwissColors.rauschCoral),
                  ),
                  Text(
                    'SOP // 01',
                    style:
                        SwissTheme.mono(size: 10, color: SwissColors.inkMuted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Pembayaran ditahan di rekening bersama (Rekber) admin atau dibayar tunai saat cek fisik di titik COD resmi (Lobi UCC, Gedung B Fasilkom, atau Pos Keamanan Gerbang Lubeg).',
                style: SwissTheme.sans(
                  size: 12,
                  color: const Color(0xFFD4D4D8),
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
        color: SwissColors.canvasWarm,
        border: Border(bottom: BorderSide(color: SwissColors.borderHairline)),
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
        color: SwissColors.canvasWarm,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SwissColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SwissTheme.mono(size: 9, color: SwissColors.inkMuted)),
          const SizedBox(height: 2),
          Text(value,
              style: SwissTheme.display(size: 20, color: valueColor)),
          Text(sub,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SwissTheme.sans(size: 10, color: SwissColors.inkSecondary)),
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
              color: SwissColors.canvasPure,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SwissColors.borderHairline),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
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
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: SwissColors.uberBlack,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'GEOSPATIAL RADAR',
                                style: SwissTheme.mono(
                                    size: 10,
                                    weight: FontWeight.w700,
                                    color: SwissColors.white),
                              ),
                            ),
                            Text(
                              'Peta Radius Kos & Titik COD Resmi',
                              style: SwissTheme.display(size: 17),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pemetaan posisi kosan penjual terhadap ${activeSpots.length} titik serah terima resmi di sekitar kampus UPI YPTK Lubuk Begalung.',
                          style: SwissTheme.sans(
                              size: 12, color: SwissColors.inkSecondary),
                        ),
                      ],
                    ),

                    // Uber Style Full-Pill Radius Chips (< 0.5 KM, < 1.0 KM, < 2.0 KM, Semua)
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ...[
                          {'id': 'all', 'label': 'Semua'},
                          {'id': '0.5', 'label': '< 0.5 KM'},
                          {'id': '1', 'label': '< 1.0 KM'},
                          {'id': '2', 'label': '< 2.0 KM'},
                        ].map((chip) {
                          final bool isSelected =
                              s.selectedRadiusKm == chip['id'];
                          return InkWell(
                            onTap: () => s.setRadiusFilter(chip['id']!),
                            borderRadius: BorderRadius.circular(999),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? SwissColors.uberBlack
                                    : SwissColors.uberGrayInactive,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isSelected
                                      ? SwissColors.uberBlack
                                      : SwissColors.uberBorder,
                                ),
                              ),
                              child: Text(
                                chip['label']!,
                                style: SwissTheme.mono(
                                  size: 11,
                                  weight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? SwissColors.white
                                      : SwissColors.inkPrimary,
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(width: 4),
                        OutlinedButton(
                          onPressed: () => s.toggleMainMapExpand(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: SwissColors.canvasPure,
                            side: const BorderSide(
                                color: SwissColors.borderHairline),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Text(
                            s.isMainMapExpanded
                                ? 'Kecilkan Peta'
                                : 'Perbesar Peta',
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
                const SizedBox(height: 16),

                // Interactive Radar Map
                GeospatialRadarMap(
                  codSpots: activeSpots,
                  products: filteredProducts,
                  selectedRadiusKm: s.selectedRadiusKm,
                  height: screenWidth < 768
                      ? (s.isMainMapExpanded ? 380 : 260)
                      : (s.isMainMapExpanded ? 480 : 320),
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
                          size: 10, color: SwissColors.inkMuted),
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
            style: SwissTheme.mono(size: 10, color: SwissColors.inkSecondary)),
      ],
    );
  }

  Widget _buildCatalogSection(double screenWidth) {
    final s = widget.appState;
    final filtered = s.filteredCatalogProducts;

    int crossAxisCount = 2;
    if (screenWidth >= 1080) {
      crossAxisCount = 4;
    } else if (screenWidth >= 768) {
      crossAxisCount = 3;
    } else {
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
                            color: SwissColors.rauschCoral),
                      ),
                      Text(
                        'Katalog Barang Kos Mahasiswa',
                        style: SwissTheme.display(
                            size: 22, color: SwissColors.inkPrimary),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'MENAMPILKAN:',
                        style: SwissTheme.mono(
                            size: 11, color: SwissColors.inkSecondary),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: SwissColors.canvasWarm,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: SwissColors.borderHairline),
                        ),
                        child: Text(
                          '${filtered.length} Barang',
                          style: SwissTheme.mono(
                            size: 11,
                            weight: FontWeight.w700,
                            color: SwissColors.inkPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Airbnb Style Full-Pill Tabs
              Container(
                decoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: SwissColors.borderHairline)),
                ),
                padding: const EdgeInsets.only(bottom: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.entries.map((entry) {
                      final bool active = s.selectedCategory == entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => s.setCategory(entry.key),
                          borderRadius: BorderRadius.circular(999),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: active
                                  ? SwissColors.inkPrimary
                                  : SwissColors.canvasPure,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: active
                                    ? SwissColors.inkPrimary
                                    : SwissColors.borderHairline,
                              ),
                              boxShadow: active
                                  ? const [
                                      BoxShadow(
                                        color: Color(0x1F000000),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Text(
                              entry.value,
                              style: SwissTheme.sans(
                                size: 12,
                                weight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: active
                                    ? SwissColors.white
                                    : SwissColors.inkSecondary,
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
                    color: SwissColors.canvasPure,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SwissColors.borderHairline),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'UNIT TIDAK DITEMUKAN',
                        style: SwissTheme.display(
                            size: 14, color: SwissColors.inkPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tidak ada inventaris kos yang cocok dengan filter kategori atau kata kunci pencarian saat ini.',
                        textAlign: TextAlign.center,
                        style: SwissTheme.sans(
                            size: 12, color: SwissColors.inkSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _searchController.clear();
                          s.resetAllFilters();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SwissColors.inkPrimary,
                          foregroundColor: SwissColors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
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
                SwissResponsiveGrid(
                  crossAxisCount: crossAxisCount,
                  spacing: screenWidth < 768 ? 10 : 18,
                  runSpacing: screenWidth < 768 ? 12 : 18,
                  children: filtered
                      .map((prod) =>
                          _buildProductCard(prod, isCompact: screenWidth < 768))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel prod, {bool isCompact = false}) {
    final s = widget.appState;
    final UserModel? user = s.currentUser;
    final bool isOwnerOrAdmin = user != null &&
        (user.role == 'admin' || user.id == prod.userId);

    return RepaintBoundary(
      child: InkWell(
        onTap: () => showProductDetailModal(context, s, prod),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: SwissColors.canvasPure,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SwissColors.borderHairline),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container
              SizedBox(
                height: isCompact ? 135 : 185,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      prod.foto,
                      fit: BoxFit.cover,
                      cacheWidth: isCompact ? 350 : 500,
                      errorBuilder: (_, __, ___) => Container(
                      color: SwissColors.canvasWarm,
                      child: Icon(Icons.inventory_2_outlined,
                          size: isCompact ? 28 : 36,
                          color: SwissColors.inkMuted),
                    ),
                  ),
                  // Top Badges
                  Positioned(
                    top: isCompact ? 6 : 10,
                    left: isCompact ? 6 : 10,
                    right: isCompact ? 6 : 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 6 : 8,
                              vertical: isCompact ? 3 : 4),
                          decoration: BoxDecoration(
                            color: const Color(0xE6000000),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: isCompact ? 5 : 6,
                                height: isCompact ? 5 : 6,
                                decoration: const BoxDecoration(
                                  color: SwissColors.verifiedEmerald,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: isCompact ? 3 : 5),
                              Text(
                                isCompact ? 'QC' : 'QC Verified',
                                style: SwissTheme.mono(
                                  size: isCompact ? 8 : 9,
                                  weight: FontWeight.w700,
                                  color: SwissColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 6 : 8,
                              vertical: isCompact ? 3 : 4),
                          decoration: BoxDecoration(
                            color: const Color(0xF2FFFFFF),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: SwissColors.borderHairline),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            '${prod.distanceToCampusKm} KM',
                            style: SwissTheme.mono(
                              size: isCompact ? 8 : 9,
                              weight: FontWeight.w700,
                              color: SwissColors.inkPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Condition Tag
                  Positioned(
                    bottom: isCompact ? 6 : 8,
                    left: isCompact ? 6 : 10,
                    right: isCompact ? 6 : 10,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 6 : 8,
                            vertical: isCompact ? 2 : 3),
                        decoration: BoxDecoration(
                          color: const Color(0xCC000000),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          prod.kondisi,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SwissTheme.mono(
                            size: isCompact ? 8 : 9,
                            color: SwissColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Body
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 10 : 14, vertical: isCompact ? 8 : 12),
              child: Column(
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
                            size: isCompact ? 8 : 10,
                            weight: FontWeight.w700,
                            color: SwissColors.inkSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 4 : 6,
                            vertical: isCompact ? 1 : 2),
                        decoration: BoxDecoration(
                          color: prod.metodePengiriman == 'kurir_admin'
                              ? SwissColors.canvasWarm
                              : const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: prod.metodePengiriman == 'kurir_admin'
                                ? SwissColors.borderHairline
                                : const Color(0xFFA7F3D0),
                          ),
                        ),
                        child: Text(
                          prod.metodePengiriman == 'kurir_admin'
                              ? 'KURIR'
                              : 'COD / KURIR',
                          style: SwissTheme.mono(
                            size: isCompact ? 7.5 : 9,
                            weight: FontWeight.w700,
                            color: prod.metodePengiriman == 'kurir_admin'
                                ? SwissColors.inkSecondary
                                : SwissColors.verifiedEmerald,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isCompact ? 4 : 6),
                  Text(
                    prod.namaBarang,
                    maxLines: isCompact ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: SwissTheme.display(
                      size: isCompact ? 13 : 15,
                      color: SwissColors.inkPrimary,
                    ),
                  ),
                  if (!isCompact) ...[
                    const SizedBox(height: 4),
                    Text(
                      prod.deskripsi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: SwissTheme.sans(
                        size: 11,
                        color: SwissColors.inkSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],

                  // Price & Action Footer
                  Divider(height: isCompact ? 10 : 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (prod.effectiveOriginalPrice > prod.harga)
                              Text(
                                SwissTheme.formatRupiah(
                                    prod.effectiveOriginalPrice),
                                style: SwissTheme.mono(
                                  size: isCompact ? 8 : 10,
                                  color: SwissColors.inkMuted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              SwissTheme.formatRupiah(prod.harga),
                              style: SwissTheme.display(
                                size: isCompact ? 14 : 18,
                                color: SwissColors.inkPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 5 : 7,
                            vertical: isCompact ? 2 : 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8EC),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFFFFBAC7),
                          ),
                        ),
                        child: Text(
                          '-${prod.savingsPercent}%',
                          style: SwissTheme.mono(
                            size: isCompact ? 8 : 10,
                            weight: FontWeight.w700,
                            color: SwissColors.rauschCoral,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isCompact ? 4 : 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'COD: ${prod.titikCod}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SwissTheme.mono(
                            size: isCompact ? 8 : 10,
                            color: SwissColors.inkSecondary,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isOwnerOrAdmin) ...[
                            IconButton(
                              onPressed: () => s.deleteProduct(prod.id),
                              icon: Icon(Icons.delete_outline,
                                  size: isCompact ? 14 : 16,
                                  color: SwissColors.dangerRose),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(2),
                              tooltip: 'Hapus Unit',
                            ),
                          ],
                          if (!isCompact) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0F2),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFFFFBAC7),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'INSPEKSI',
                                    style: SwissTheme.mono(
                                      size: 10,
                                      weight: FontWeight.w700,
                                      color: SwissColors.rauschCoral,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(Icons.arrow_forward,
                                      size: 11, color: SwissColors.rauschCoral),
                                ],
                              ),
                            ),
                          ] else ...[
                            const Icon(Icons.arrow_forward,
                                size: 12, color: SwissColors.rauschCoral),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
              color: SwissColors.canvasPure,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SwissColors.borderHairline),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
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
                            color: SwissColors.escrowIndigo,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Titik Temu COD Resmi Terverifikasi',
                          style: SwissTheme.display(
                              size: 19, color: SwissColors.inkPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dikelola secara dinamis oleh Administrator. Apabila otoritas kampus membatasi akses di area akademik, titik dialihkan ke perimeter publik.',
                          style: SwissTheme.sans(
                              size: 12, color: SwissColors.inkSecondary),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Text(
                        '${activeSpots.length} ZONA AKTIF',
                        style: SwissTheme.mono(
                          size: 10,
                          weight: FontWeight.w700,
                          color: SwissColors.verifiedEmerald,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, color: SwissColors.borderHairline),
                ),
                SwissResponsiveGrid(
                  crossAxisCount: cols,
                  spacing: 14,
                  runSpacing: 14,
                  children: activeSpots.map((spot) {
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: SwissColors.canvasWarm,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: SwissColors.borderHairline),
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
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: SwissColors.canvasPure,
                                  borderRadius: BorderRadius.circular(999),
                                  border:
                                      Border.all(color: SwissColors.borderHairline),
                                ),
                                child: Text(
                                  spot.categoryTag,
                                  style: SwissTheme.mono(
                                      size: 9,
                                      weight: FontWeight.w700,
                                      color: SwissColors.inkSecondary),
                                ),
                              ),
                              Text(
                                '${spot.latitude.toStringAsFixed(4)}, ${spot.longitude.toStringAsFixed(4)}',
                                style: SwissTheme.mono(
                                    size: 10, color: SwissColors.inkMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            spot.namaTitik,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SwissTheme.display(
                                size: 14, color: SwissColors.inkPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            spot.deskripsi,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: SwissTheme.sans(
                                size: 11, color: SwissColors.inkSecondary),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
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
        color: SwissColors.canvasPure,
        border: Border(top: BorderSide(color: SwissColors.borderHairline)),
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
                child: Divider(height: 1, color: SwissColors.borderHairline),
              ),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(
                    'TIM PENGEMBANG: MUHAMMAD IQBAL MAULANA (24101152610172) • OKTA KHAIRUL RAMADHAN (24101152610177) • TRY ANGGARA YOFA (24101152610222)',
                    style: SwissTheme.mono(size: 10, color: SwissColors.inkMuted),
                  ),
                  Text(
                    '© ${DateTime.now().year} CAMPUSTRADE UPI YPTK. ALL RIGHTS RESERVED.',
                    style: SwissTheme.mono(size: 10, color: SwissColors.inkMuted),
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
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: SwissColors.rauschCoral,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                'CT',
                style: SwissTheme.display(size: 12, color: SwissColors.white),
              ),
            ),
            Text('CampusTrade',
                style: SwissTheme.display(
                    size: 16, color: SwissColors.inkPrimary)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: SwissColors.canvasWarm,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: SwissColors.borderHairline),
              ),
              child: Text(
                'UPI YPTK PADANG',
                style: SwissTheme.mono(size: 9, color: SwissColors.inkSecondary),
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
                size: 12, color: SwissColors.inkSecondary, height: 1.5),
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
          style: SwissTheme.mono(size: 10, color: SwissColors.inkMuted),
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
                    color: SwissColors.inkSecondary),
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
          style: SwissTheme.mono(size: 10, color: SwissColors.inkMuted),
        ),
        const SizedBox(height: 8),
        Text(
          'Fakultas Ilmu Komputer (Fasilkom)',
          style: SwissTheme.sans(
              size: 12, weight: FontWeight.w700, color: SwissColors.inkPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Universitas Putra Indonesia "YPTK" Padang',
          style: SwissTheme.sans(size: 12, color: SwissColors.inkSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          'JL. RAYA LUBUK BEGALUNG, PADANG',
          style: SwissTheme.mono(size: 10, color: SwissColors.inkMuted),
        ),
      ],
    );
  }

  Widget _buildMobileBottomNav() {
    final UserModel? user = widget.appState.currentUser;
    return Container(
      decoration: const BoxDecoration(
        color: SwissColors.canvasPure,
        border: Border(top: BorderSide(color: SwissColors.borderHairline)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _mobileNavItem(
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
          ),
          Expanded(
            child: _mobileNavItem(
              icon: Icons.location_on_outlined,
              label: 'RADAR',
              onTap: () => _scrollToSection(_radarMapKey),
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                height: 38,
                child: ElevatedButton(
                  onPressed: _handleSellAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        (user != null && user.statusVerifikasi != 'approved')
                            ? SwissColors.cautionAmber
                            : SwissColors.rauschCoral,
                    foregroundColor: SwissColors.white,
                    elevation: 1,
                    shadowColor: SwissColors.rauschCoral.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
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
                          ? SwissColors.inkPrimary
                          : SwissColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _mobileNavItem(
              icon: Icons.grid_view_outlined,
              label: 'KATALOG',
              onTap: () => _scrollToSection(_productGridKey),
            ),
          ),
          Expanded(
            child: _mobileNavItem(
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minHeight: 46),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: SwissColors.inkSecondary),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SwissTheme.mono(
                size: 9,
                weight: FontWeight.w600,
                color: SwissColors.inkSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
