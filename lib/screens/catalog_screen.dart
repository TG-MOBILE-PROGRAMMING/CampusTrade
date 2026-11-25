import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/swiss_theme.dart';
import '../widgets/campus_bottom_nav.dart';
import '../widgets/campus_empty_state.dart';
import '../widgets/campus_motion.dart';
import '../widgets/campus_trust_widgets.dart';
import 'auth_screen.dart';
import 'orders_screen.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';
import 'radar_map_screen.dart';
import 'sell_product_screen.dart';

/// ============================================================================
/// CATALOG SCREEN (HOME SCREEN)
/// "Coastal Cobalt & Sunburst Coral" + Smooth CustomScrollView & SliverAppBar
/// + Animated Floating Pill Bottom Navigation
/// ============================================================================
class CatalogScreen extends StatefulWidget {
  final CampusTradeState appState;
  const CatalogScreen({super.key, required this.appState});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  int _currentNavIndex = 0; // 0: Katalog, 1: Radar, 3: Pesanan, 4: Akun
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchFocused = false;
  bool _showScrollToTop = false;

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Semua', 'label': 'Semua', 'icon': Icons.grid_view_rounded},
    {'name': 'Perabotan Kos', 'label': 'Perabotan Kos', 'icon': Icons.bed_outlined},
    {'name': 'Elektronik Kos', 'label': 'Elektronik', 'icon': Icons.electrical_services_outlined},
    {'name': 'Gadget & Komputer', 'label': 'Gadget & PC', 'icon': Icons.laptop_chromebook_outlined},
    {'name': 'Buku & Modul Kuliah', 'label': 'Buku & Modul', 'icon': Icons.menu_book_outlined},
    {'name': 'Peralatan Masak & Makan', 'label': 'Alat Masak', 'icon': Icons.soup_kitchen_outlined},
    {'name': 'Kendaraan & Aksesoris', 'label': 'Helm & Motor', 'icon': Icons.two_wheeler_outlined},
    {'name': 'Fashion & Seragam Kuliah', 'label': 'Fashion', 'icon': Icons.checkroom_outlined},
    {'name': 'Kebutuhan Harian & Hobi', 'label': 'Harian & Hobi', 'icon': Icons.sports_tennis_outlined},
    {'name': 'Lain-lain', 'label': 'Lain-lain', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.appState.searchKeyword;
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _scrollController.addListener(_onScrollChanged);
    widget.appState.addListener(_onStateChanged);
  }

  void _onSearchFocusChanged() {
    if (mounted) {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    }
  }

  void _onScrollChanged() {
    if (!_scrollController.hasClients) return;
    final bool shouldShow = _scrollController.offset > 320;
    if (shouldShow != _showScrollToTop && mounted) {
      setState(() => _showScrollToTop = shouldShow);
    }
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onStateChanged);
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _scrollController.removeListener(_onScrollChanged);
    _searchFocusNode.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSellAction() {
    final user = widget.appState.currentUser;
    if (user == null) {
      Navigator.of(context).push(
        buildCampusRoute(AuthScreen(appState: widget.appState)),
      );
    } else if (user.statusVerifikasi == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Akun kamu masih menunggu verifikasi KTM. Fitur pasang iklan aktif setelah disetujui.',
          ),
        ),
      );
    } else if (user.statusVerifikasi == 'rejected') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verifikasi KTM ditolak. Silakan hubungi admin di tab Akun untuk validasi ulang.',
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        buildCampusRoute(SellProductScreen(appState: widget.appState)),
      );
    }
  }

  void _applyQuickSearch(String term) {
    widget.appState.resetAllFilters();
    _searchController.text = term;
    widget.appState.setSearchKeyword(term);
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 380),
      curve: CampusMotion.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 960;
    final int activeOrders = widget.appState.orders
        .where((o) => o.status != 'selesai' && o.status != 'dibatalkan')
        .length;

    return Scaffold(
      backgroundColor: CampusColors.canvasPaper,
      extendBody: !isDesktop,
      bottomNavigationBar: isDesktop
          ? null
          : CampusAnimatedBottomNav(
              currentIndex: _currentNavIndex,
              pendingOrdersCount: activeOrders,
              onSelectTab: (idx) => setState(() => _currentNavIndex = idx),
              onSellTap: _handleSellAction,
            ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: CampusMotion.easeOut,
        transitionBuilder: (child, animation) {
          if (MediaQuery.disableAnimationsOf(context)) return child;
          return FadeTransition(opacity: animation, child: child);
        },
        child: _buildCurrentTabBody(screenWidth, isDesktop),
      ),
    );
  }

  Widget _buildCurrentTabBody(double screenWidth, bool isDesktop) {
    if (_currentNavIndex == 1) {
      return KeyedSubtree(
        key: const ValueKey<int>(1),
        child: RadarMapScreen(
          appState: widget.appState,
          onBackToCatalog: () => setState(() => _currentNavIndex = 0),
        ),
      );
    } else if (_currentNavIndex == 3) {
      return KeyedSubtree(
        key: const ValueKey<int>(3),
        child: OrdersScreen(
          appState: widget.appState,
          onBackToCatalog: () => setState(() => _currentNavIndex = 0),
        ),
      );
    } else if (_currentNavIndex == 4) {
      return KeyedSubtree(
        key: const ValueKey<int>(4),
        child: ProfileScreen(
          appState: widget.appState,
          onBackToCatalog: () => setState(() => _currentNavIndex = 0),
        ),
      );
    }

    return KeyedSubtree(
      key: const ValueKey<int>(0),
      child: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildSliverTopBar(screenWidth, isDesktop),
              if (widget.appState.currentUser?.statusVerifikasi == 'pending')
                SliverToBoxAdapter(child: _buildPendingKtmNotice()),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isDesktop ? 24 : 16,
                        isDesktop ? 20 : 14,
                        isDesktop ? 24 : 16,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCampusHeroCard(screenWidth),
                          const SizedBox(height: 16),
                          CampusTrustStrip(isDesktop: isDesktop),
                          const SizedBox(height: 22),
                          _buildSectionHeader(
                            title: 'Kategori Kebutuhan Kos',
                            trailingText:
                                widget.appState.selectedCategory == 'Semua'
                                    ? null
                                    : 'Reset',
                            onTrailingTap: () {
                              _searchController.clear();
                              widget.appState.resetAllFilters();
                            },
                          ),
                          const SizedBox(height: 10),
                          _buildCategorySelector(),
                          const SizedBox(height: 16),
                          _buildFilterAndSortRow(screenWidth),
                          const SizedBox(height: 16),
                          _buildProductGrid(screenWidth),
                          const SizedBox(height: 28),
                          _buildCampusFooter(),
                          // Reserve clear scroll room above floating bottom nav
                          SizedBox(height: isDesktop ? 32 : 104),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating Scroll-to-Top Pill
          Positioned(
            right: 16,
            bottom: isDesktop ? 24 : 92,
            child: IgnorePointer(
              ignoring: !_showScrollToTop,
              child: AnimatedOpacity(
                opacity: _showScrollToTop ? 1.0 : 0.0,
                duration: CampusMotion.standard,
                child: AnimatedScale(
                  scale: _showScrollToTop ? 1.0 : 0.85,
                  duration: CampusMotion.standard,
                  curve: CampusMotion.easeOut,
                  child: TactilePress(
                    onTap: _scrollToTop,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: CampusColors.inkPrimary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x280F172A),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_upward_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ke atas',
                            style: SwissTheme.sans(
                              size: 11.5,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Smooth collapsible SliverAppBar: top brand/location bar glides away on scroll
  /// while the search bar remains pinned cleanly for effortless browsing.
  SliverAppBar _buildSliverTopBar(double screenWidth, bool isDesktop) {
    final UserModel? user = widget.appState.currentUser;
    final int favCount = widget.appState.favoriteProductIds.length;

    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: true,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: const Color(0x140F172A),
      backgroundColor: CampusColors.surfacePure,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: 58,
      titleSpacing: 0,
      title: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TactilePress(
                      onTap: () {
                        _searchController.clear();
                        widget.appState.resetAllFilters();
                        _scrollToTop();
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  CampusColors.campusCobaltDeep,
                                  CampusColors.campusCobalt,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.swap_horiz_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'CampusTrade',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: SwissTheme.display(
                                    size: 16,
                                    weight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.place_rounded,
                                      size: 11,
                                      color: CampusColors.campusCobalt,
                                    ),
                                    const SizedBox(width: 2),
                                    Flexible(
                                      child: Text(
                                        'UPI YPTK • Lubeg',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: SwissTheme.sans(
                                          size: 10.5,
                                          weight: FontWeight.w600,
                                          color: CampusColors.inkMuted,
                                          height: 1.1,
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
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                if (user != null && user.role == 'admin') ...[
                  TactilePress(
                    onTap: () => widget.appState.navigateTo('admin'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: CampusColors.inkPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Admin CMS',
                        style: SwissTheme.sans(
                          size: 11,
                          weight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],

                // Wishlist shortcut
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(
                    icon: Badge(
                      isLabelVisible: favCount > 0,
                      backgroundColor: CampusColors.sunburstCoral,
                      label: Text(
                        '$favCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: CampusColors.inkPrimary,
                        size: 22,
                      ),
                    ),
                    tooltip: 'Wishlist Saya',
                    onPressed: () => setState(() => _currentNavIndex = 4),
                  ),
                ),

                if (isDesktop) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _handleSellAction,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Pasang Iklan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CampusColors.sunburstCoral,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      if (user == null) {
                        Navigator.of(context).push(
                          buildCampusRoute(AuthScreen(appState: widget.appState)),
                        );
                      } else {
                        setState(() => _currentNavIndex = 4);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CampusColors.inkPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                    ),
                    child: Text(
                      user != null ? '@${user.username}' : 'Masuk / Daftar',
                      style: SwissTheme.display(size: 12.5, weight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 24 : 16,
            4,
            isDesktop ? 24 : 16,
            12,
          ),
          decoration: const BoxDecoration(
            color: CampusColors.surfacePure,
            border: Border(
              bottom: BorderSide(color: CampusColors.borderHairline),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: AnimatedContainer(
                duration: CampusMotion.fast,
                height: 44,
                decoration: BoxDecoration(
                  color: _isSearchFocused
                      ? CampusColors.surfacePure
                      : CampusColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isSearchFocused
                        ? CampusColors.campusCobalt
                        : CampusColors.borderHairline,
                    width: _isSearchFocused ? 1.5 : 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (val) => widget.appState.setSearchKeyword(val),
                  textAlignVertical: TextAlignVertical.center,
                  style: SwissTheme.sans(
                    size: 13,
                    color: CampusColors.inkPrimary,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 0,
                    ),
                    hintText: 'Cari kasur, meja lipat, dispenser, buku...',
                    hintStyle: SwissTheme.sans(
                      size: 12.5,
                      color: CampusColors.inkMuted,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 19,
                      color: _isSearchFocused
                          ? CampusColors.campusCobalt
                          : CampusColors.inkSecondary,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 42,
                      minHeight: 44,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? SizedBox(
                            width: 40,
                            height: 44,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              tooltip: 'Hapus pencarian',
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 17,
                                color: CampusColors.inkSecondary,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                widget.appState.setSearchKeyword('');
                              },
                            ),
                          )
                        : null,
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 44,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Vibrant Coastal Cobalt Hero Card with subtle architectural rings & Sunburst Coral CTA.
  Widget _buildCampusHeroCard(double screenWidth) {
    final bool isCompact = screenWidth < 680;
    final int approvedCount = widget.appState.products
        .where((p) => p.statusVerifikasi == 'approved')
        .length;
    final int activeCodCount = widget.appState.activeCodSpots.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            CampusColors.inkPrimary,
            CampusColors.oceanTealDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1E0F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _HeroRingsPainter()),
          ),
          Padding(
            padding: EdgeInsets.all(isCompact ? 20 : 26),
            child: isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroCopy(approvedCount, activeCodCount, isCompact),
                      const SizedBox(height: 18),
                      _buildHeroActions(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildHeroCopy(
                          approvedCount,
                          activeCodCount,
                          isCompact,
                        ),
                      ),
                      const SizedBox(width: 24),
                      _buildHeroActions(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCopy(int approvedCount, int activeCodCount, bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bursa Barang Kos Khusus Mahasiswa',
          style: SwissTheme.display(
            size: isCompact ? 20 : 25,
            weight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Oper kasur, meja belajar, dispenser, hingga buku kuliah langsung dari sesama mahasiswa terverifikasi KTM di sekitar Lubuk Begalung.',
          style: SwissTheme.sans(
            size: isCompact ? 12.5 : 13.5,
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _buildHeroFact(
              Icons.inventory_2_outlined,
              '$approvedCount barang siap angkut',
            ),
            _buildHeroFact(
              Icons.place_outlined,
              '$activeCodCount titik COD kampus',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroFact(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.5, color: const Color(0xFFBAE6FD)),
          const SizedBox(width: 5),
          Text(
            text,
            style: SwissTheme.sans(
              size: 11.5,
              weight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroActions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        TactilePress(
          onTap: _handleSellAction,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: CampusColors.oceanTeal,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x330D9488),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'Jual Barang Kos',
                  style: SwissTheme.display(
                    size: 13,
                    weight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        TactilePress(
          onTap: () => showEscrowExplainerSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Alur Rekber',
              style: SwissTheme.display(
                size: 13,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    String? trailingText,
    VoidCallback? onTrailingTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: SwissTheme.display(size: 16, weight: FontWeight.w800),
        ),
        if (trailingText != null && onTrailingTap != null)
          TextButton(
            onPressed: onTrailingTap,
            style: TextButton.styleFrom(
              foregroundColor: CampusColors.sunburstCoral,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(44, 36),
            ),
            child: Text(
              trailingText,
              style: SwissTheme.sans(
                size: 12,
                weight: FontWeight.w700,
                color: CampusColors.sunburstCoral,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final String currentCategory = widget.appState.selectedCategory;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((c) {
          final bool isSelected = currentCategory == c['name'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TactilePress(
              onTap: () => widget.appState.setCategory(c['name'] as String),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: CampusMotion.easeOut,
                constraints: const BoxConstraints(minHeight: 40),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected
                      ? CampusColors.campusCobalt
                      : CampusColors.surfacePure,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? CampusColors.campusCobalt
                        : CampusColors.borderHairline,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      c['icon'] as IconData,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : CampusColors.campusCobalt,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      c['label'] as String,
                      style: SwissTheme.sans(
                        size: 12,
                        weight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : CampusColors.inkPrimary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterAndSortRow(double screenWidth) {
    final String currentRadius = widget.appState.selectedRadiusKm;
    final String currentSort = widget.appState.sortOption;
    final int productCount = widget.appState.filteredCatalogProducts.length;

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildRadiusChip('Semua ($productCount)', 'all', currentRadius),
                _buildRadiusChip('< 500m', '0.5', currentRadius),
                _buildRadiusChip('< 1 km', '1', currentRadius),
                _buildRadiusChip('< 2 km', '2', currentRadius),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: CampusColors.surfacePure,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: CampusColors.borderHairline),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentSort,
              icon: const Icon(
                Icons.swap_vert_rounded,
                size: 16,
                color: CampusColors.campusCobalt,
              ),
              style: SwissTheme.sans(
                size: 12,
                weight: FontWeight.w600,
                color: CampusColors.inkPrimary,
              ),
              items: const [
                DropdownMenuItem(value: 'terbaru', child: Text('Terbaru')),
                DropdownMenuItem(value: 'termurah', child: Text('Termurah')),
                DropdownMenuItem(value: 'termahal', child: Text('Termahal')),
                DropdownMenuItem(value: 'terdekat', child: Text('Terdekat')),
              ],
              onChanged: (val) {
                if (val != null) widget.appState.setSortOption(val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadiusChip(String label, String value, String current) {
    final bool active = current == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TactilePress(
        onTap: () => widget.appState.setRadiusFilter(value),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: CampusMotion.fast,
          constraints: const BoxConstraints(minHeight: 38),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? CampusColors.sunburstCoralSoft
                : CampusColors.surfacePure,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? CampusColors.sunburstCoral
                  : CampusColors.borderHairline,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: SwissTheme.sans(
                size: 11.5,
                weight: active ? FontWeight.w700 : FontWeight.w500,
                color: active
                    ? CampusColors.sunburstCoral
                    : CampusColors.inkPrimary,
                height: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(double screenWidth) {
    final List<ProductModel> products = widget.appState.filteredCatalogProducts;

    if (products.isEmpty) {
      final bool hasKeyword = widget.appState.searchKeyword.trim().isNotEmpty;
      return CampusEmptyState(
        kind: CampusEmptyKind.searchEmpty,
        title: hasKeyword
            ? 'Barang "${widget.appState.searchKeyword.trim()}" belum ada di kos sekitar'
            : 'Belum ada barang kos di filter ini',
        subtitle:
            'Coba perluas radius jarak kos, ganti kategori, atau cek kata kunci populer yang sering dioper mahasiswa.',
        suggestionChips: const ['Kasur', 'Meja', 'Dispenser', 'Buku', 'Kipas'],
        onSuggestionTap: _applyQuickSearch,
        primaryActionLabel: 'Reset Semua Filter',
        onPrimaryAction: () {
          _searchController.clear();
          widget.appState.resetAllFilters();
        },
      );
    }

    int crossAxisCount = 2;
    if (screenWidth >= 1120) {
      crossAxisCount = 4;
    } else if (screenWidth >= 740) {
      crossAxisCount = 3;
    } else if (screenWidth < 340) {
      crossAxisCount = 1;
    }

    return SwissResponsiveGrid(
      crossAxisCount: crossAxisCount,
      spacing: 12,
      runSpacing: 14,
      children: List.generate(products.length, (index) {
        return StaggeredEntrance(
          key: ValueKey<int>(products[index].id),
          index: index,
          child: _buildProductCard(products[index]),
        );
      }),
    );
  }

  Widget _buildProductCard(ProductModel p) {
    final bool isFav = widget.appState.isFavorite(p.id);
    final String sellerInitials = p.namaPenjual.trim().length >= 2
        ? p.namaPenjual.trim().substring(0, 2).toUpperCase()
        : 'MH';

    return TactilePress(
      onTap: () {
        Navigator.of(context).push(
          buildCampusRoute(
            ProductDetailScreen(appState: widget.appState, product: p),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: CampusColors.surfacePure,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CampusColors.borderHairline),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A0F172A),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.18,
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
                    top: 10,
                    left: 10,
                    child: ConditionBadge(rawCondition: p.kondisi),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: BouncyHeartButton(
                      isFavorite: isFav,
                      onToggle: () => widget.appState.toggleFavorite(p.id),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.namaBarang,
                          style: SwissTheme.display(
                            size: 13.5,
                            weight: FontWeight.w700,
                            height: 1.28,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          SwissTheme.formatRupiah(p.harga),
                          style: SwissTheme.display(
                            size: 15.5,
                            weight: FontWeight.w800,
                            color: CampusColors.sunburstCoral,
                          ),
                        ),
                        if (p.effectiveOriginalPrice > p.harga) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  SwissTheme.formatRupiah(
                                    p.effectiveOriginalPrice,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: SwissTheme.sans(
                                    size: 11,
                                    color: CampusColors.inkMuted,
                                    decoration: TextDecoration.lineThrough,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: CampusColors.sunburstCoralSoft,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '-${p.savingsPercent}%',
                                  style: SwissTheme.mono(
                                    size: 10,
                                    weight: FontWeight.w700,
                                    color: CampusColors.sunburstCoral,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),

                    Column(
                      children: [
                        const SizedBox(height: 10),
                        const Divider(
                          height: 1,
                          color: CampusColors.borderHairline,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: CampusColors.campusCobaltSoft,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  sellerInitials,
                                  style: SwissTheme.mono(
                                    size: 9.5,
                                    weight: FontWeight.w800,
                                    color: CampusColors.campusCobalt,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          p.namaPenjual.split(' ').first,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: SwissTheme.sans(
                                            size: 11,
                                            weight: FontWeight.w700,
                                            color: CampusColors.inkPrimary,
                                            height: 1.15,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      const Icon(
                                        Icons.verified_rounded,
                                        size: 12.5,
                                        color: CampusColors.verifiedJade,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${p.distanceToCampusKm} km • ${p.lokasiKos}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: SwissTheme.sans(
                                      size: 10.5,
                                      color: CampusColors.inkMuted,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
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
      ),
    );
  }

  Widget _buildPendingKtmNotice() {
    final user = widget.appState.currentUser;
    if (user == null || user.statusVerifikasi != 'pending') {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: CampusColors.cautionAmberSoft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Row(
            children: [
              const Icon(
                Icons.hourglass_top_outlined,
                size: 16,
                color: CampusColors.cautionAmber,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Akun (@${user.username}) sedang menunggu verifikasi KTM oleh tim CampusTrade (Target: UPI YPTK).',
                  style: SwissTheme.sans(
                    size: 12,
                    color: const Color(0xFF78350F),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampusFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CampusColors.surfacePure,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CampusColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.school_outlined,
                size: 18,
                color: CampusColors.campusCobalt,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'CampusTrade: Bursa Inventaris Mahasiswa',
                  style: SwissTheme.display(size: 14, weight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Platform independen untuk jual beli perabotan dan perlengkapan kos antar mahasiswa di sekitar UPI YPTK Padang dan Lubuk Begalung. Dilengkapi verifikasi KTM, kurasi fisik, dan titik temu COD aman.',
            style: SwissTheme.sans(
              size: 12,
              height: 1.5,
              color: CampusColors.inkSecondary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: CampusColors.borderHairline),
          const SizedBox(height: 8),
          Text(
            '© 2026 CampusTrade • Rekber Tim Verifikator Mahasiswa (UPI YPTK Padang)',
            style: SwissTheme.sans(
              size: 11,
              color: CampusColors.inkMuted,
            ),
          ),
        ],
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
        return Icons.inventory_2_outlined;
    }
  }
}

/// Subtle architectural concentric corner rings for the Cobalt Hero Card.
class _HeroRingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final Offset anchor = Offset(size.width - 28, 22);
    canvas.drawCircle(anchor, 56, ringPaint);
    canvas.drawCircle(anchor, 98, ringPaint);
    canvas.drawCircle(anchor, 142, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
