import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/swiss_theme.dart';
import 'auth_screen.dart';
import 'orders_screen.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';
import 'radar_map_screen.dart';
import 'sell_product_screen.dart';

/// ============================================================================
/// CATALOG SCREEN (CENTRAL MARKETPLACE EXPERIENCE FOR UPI YPTK PADANG)
/// [Anti-Slop UI & Layoutmobile Architecture — Zero-Modal Proper Marketplace]
/// ============================================================================
class CatalogScreen extends StatefulWidget {
  final CampusTradeState appState;
  const CatalogScreen({super.key, required this.appState});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  int _currentNavIndex = 0; // 0: Beranda, 1: Radar Kos, 2: Jual, 3: Pesanan, 4: Akun
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final PageController _bannerController = PageController();
  int _activeBannerIndex = 0;

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Semua', 'label': 'Semua Unit', 'icon': Icons.apps},
    {'name': 'Perabotan Kos', 'label': 'Perabotan Kos', 'icon': Icons.bed_outlined},
    {'name': 'Elektronik Kos', 'label': 'Elektronik', 'icon': Icons.electrical_services_outlined},
    {'name': 'Gadget & Komputer', 'label': 'Gadget & PC', 'icon': Icons.laptop_chromebook_outlined},
    {'name': 'Buku & Modul Kuliah', 'label': 'Buku & Modul', 'icon': Icons.menu_book_outlined},
    {'name': 'Peralatan Masak & Makan', 'label': 'Alat Masak', 'icon': Icons.soup_kitchen_outlined},
    {'name': 'Kendaraan & Aksesoris', 'label': 'Kendaraan & Helm', 'icon': Icons.two_wheeler_outlined},
    {'name': 'Fashion & Seragam Kuliah', 'label': 'Fashion Kuliah', 'icon': Icons.checkroom_outlined},
    {'name': 'Kebutuhan Harian & Hobi', 'label': 'Harian & Hobi', 'icon': Icons.sports_tennis_outlined},
    {'name': 'Lain-lain', 'label': 'Lain-lain', 'icon': Icons.more_horiz},
  ];

  static const List<Map<String, String>> _promoBanners = [
    {
      'title': 'CampusTrade — Bursa Inventaris Kos Mahasiswa',
      'subtitle': 'Platform perantara jual beli kasur, meja, dispenser & perlengkapan kos mahasiswa.',
      'badge': 'VERIFIKASI MAHASISWA',
      'accent': 'emerald',
    },
    {
      'title': 'Bebas Biaya COD di Titik Temu Kampus Target',
      'subtitle': 'Titik temu terpantau aman di Gerbang Utama Pos Satpam 24 Jam & Lobi Kampus UPI YPTK.',
      'badge': 'GRATIS COD KAMPUS',
      'accent': 'coral',
    },
    {
      'title': 'Jaminan Rekber Tim CampusTrade',
      'subtitle': 'Uang pembeli aman di rekening perantara tim hingga barang diperiksa fisik.',
      'badge': 'ESCROW REKBER AMAN',
      'accent': 'indigo',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.appState.searchKeyword;
    widget.appState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onStateChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  void _handleSellAction() {
    final user = widget.appState.currentUser;
    if (user == null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AuthScreen(appState: widget.appState)),
      );
    } else if (user.statusVerifikasi == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun Anda masih dalam antrean verifikasi KTM. Fitur jual aktif setelah disetujui.'),
        ),
      );
    } else if (user.statusVerifikasi == 'rejected') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verifikasi KTM Anda ditolak. Silakan hubungi admin di tab Akun untuk validasi.'),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SellProductScreen(appState: widget.appState)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 960;

    // Handle tab switching
    if (_currentNavIndex == 1) {
      return RadarMapScreen(
        appState: widget.appState,
        onBackToCatalog: () => setState(() => _currentNavIndex = 0),
      );
    } else if (_currentNavIndex == 3) {
      return OrdersScreen(
        appState: widget.appState,
        onBackToCatalog: () => setState(() => _currentNavIndex = 0),
      );
    } else if (_currentNavIndex == 4) {
      return ProfileScreen(
        appState: widget.appState,
        onBackToCatalog: () => setState(() => _currentNavIndex = 0),
      );
    }

    // Default Tab 0: Main Marketplace Catalog
    return Scaffold(
      backgroundColor: SwissColors.canvasWarm,
      bottomNavigationBar: isDesktop ? null : _buildMobileBottomNav(),
      body: SafeArea(
        top: true,
        bottom: !isDesktop,
        child: Column(
          children: [
            // Sticky Top Marketplace Bar
            _buildMarketplaceTopBar(screenWidth),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Pending KTM Notice Banner if any
                    _buildPendingKtmNotice(),

                    // Max Width Content Container
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sliding Promo Banners
                              _buildPromoCarousel(screenWidth),
                              const SizedBox(height: 16),

                              // Trust Guarantee Row
                              _buildTrustHighlightRow(isDesktop),
                              const SizedBox(height: 18),

                              // Categories Horizontal Bar
                              _buildCategorySelector(),
                              const SizedBox(height: 18),

                              // Filter and Sort Control Row
                              _buildFilterAndSortRow(screenWidth),
                              const SizedBox(height: 16),

                              // Product Grid
                              _buildProductGrid(screenWidth),
                              const SizedBox(height: 32),

                              // Safe COD spots preview & Campus Footer
                              _buildCampusFooter(screenWidth),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildMarketplaceTopBar(double screenWidth) {
    final bool isDesktop = screenWidth >= 960;
    final UserModel? user = widget.appState.currentUser;
    final int favCount = widget.appState.favoriteProductIds.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: SwissColors.canvasPure,
        border: Border(bottom: BorderSide(color: SwissColors.borderHairline)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Location Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: SwissColors.rauschCoral),
                      const SizedBox(width: 4),
                      Text(
                        'Target Kampus: UPI YPTK Padang • Lubuk Begalung',
                        style: SwissTheme.mono(size: 11, weight: FontWeight.w700, color: SwissColors.inkPrimary),
                      ),
                    ],
                  ),
                  if (user != null && user.role == 'admin') ...[
                    InkWell(
                      onTap: () => widget.appState.navigateTo('admin'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: SwissColors.escrowIndigo,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PORTAL ADMIN CMS',
                          style: SwissTheme.mono(size: 9, weight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Search Row + Desktop Nav Links
              Row(
                children: [
                  // Brand Logo
                  InkWell(
                    onTap: () {
                      widget.appState.resetAllFilters();
                      setState(() => _currentNavIndex = 0);
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: SwissColors.rauschCoral,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(Icons.swap_horiz, color: Colors.white, size: 22),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CampusTrade',
                              style: SwissTheme.display(size: 15, weight: FontWeight.w800),
                            ),
                            Text(
                              'BURSA MAHASISWA',
                              style: SwissTheme.mono(size: 8, weight: FontWeight.w700, color: SwissColors.inkMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Search Bar Input (Symmetric 42px Centered Target)
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: SwissColors.borderHairline),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => widget.appState.setSearchKeyword(val),
                        textAlignVertical: TextAlignVertical.center,
                        style: SwissTheme.sans(size: 12.5, color: SwissColors.inkPrimary),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          hintText: 'Cari kasur, dispenser, meja kos, modul...',
                          hintStyle: SwissTheme.sans(size: 12, color: SwissColors.inkMuted),
                          prefixIcon: const Icon(Icons.search, size: 18, color: SwissColors.inkSecondary),
                          prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 42),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? SizedBox(
                                  width: 36,
                                  height: 42,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.clear, size: 16, color: SwissColors.inkSecondary),
                                    onPressed: () {
                                      _searchController.clear();
                                      widget.appState.setSearchKeyword('');
                                    },
                                  ),
                                )
                              : null,
                          suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 42),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Wishlist Icon with badge
                  IconButton(
                    icon: Badge(
                      isLabelVisible: favCount > 0,
                      label: Text('$favCount', style: const TextStyle(fontSize: 10)),
                      child: const Icon(Icons.favorite_border, color: SwissColors.inkPrimary, size: 22),
                    ),
                    tooltip: 'Wishlist Saya',
                    onPressed: () {
                      setState(() => _currentNavIndex = 4);
                    },
                  ),

                  // Desktop sell CTA & User profile
                  if (isDesktop) ...[
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      onPressed: _handleSellAction,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Pasang Iklan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SwissColors.rauschCoral,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        if (user == null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => AuthScreen(appState: widget.appState)),
                          );
                        } else {
                          setState(() => _currentNavIndex = 4);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SwissColors.inkPrimary,
                        side: const BorderSide(color: SwissColors.borderHairline),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      child: Text(
                        user != null ? '@${user.username}' : 'Masuk / Daftar',
                        style: SwissTheme.display(size: 12, weight: FontWeight.w700),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoCarousel(double screenWidth) {
    final bool isMobile = screenWidth < 768;

    return Container(
      height: isMobile ? 130 : 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: _promoBanners.length,
            onPageChanged: (idx) => setState(() => _activeBannerIndex = idx),
            itemBuilder: (context, idx) {
              final b = _promoBanners[idx];
              Color startColor;
              Color endColor;
              if (b['accent'] == 'coral') {
                startColor = const Color(0xFFE11D48);
                endColor = const Color(0xFFFF5A5F);
              } else if (b['accent'] == 'indigo') {
                startColor = const Color(0xFF4F46E5);
                endColor = const Color(0xFF6366F1);
              } else {
                startColor = const Color(0xFF0F766E);
                endColor = const Color(0xFF059669);
              }

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [startColor, endColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              b['badge']!,
                              style: SwissTheme.mono(size: 9, weight: FontWeight.w800, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            b['title']!,
                            style: SwissTheme.display(
                              size: isMobile ? 15 : 18,
                              weight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            b['subtitle']!,
                            style: SwissTheme.sans(
                              size: isMobile ? 11 : 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      idx == 0
                          ? Icons.inventory_2_outlined
                          : (idx == 1 ? Icons.handshake_outlined : Icons.shield_outlined),
                      size: isMobile ? 48 : 64,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ],
                ),
              );
            },
          ),

          // Dots Indicator
          Positioned(
            bottom: 8,
            right: 16,
            child: Row(
              children: List.generate(
                _promoBanners.length,
                (i) => Container(
                  width: _activeBannerIndex == i ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: _activeBannerIndex == i ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustHighlightRow(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: SwissColors.canvasPure,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SwissColors.borderHairline),
      ),
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTrustItem(Icons.verified, 'Verifikasi KTM Mahasiswa'),
                _buildTrustItem(Icons.security, 'Rekber Anti-Penipuan'),
                _buildTrustItem(Icons.place, 'Gratis COD Kampus UPI YPTK'),
                _buildTrustItem(Icons.delivery_dining, 'Layanan Kurir Antar Kos'),
              ],
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTrustItem(Icons.verified, 'Verifikasi KTM'),
                  const SizedBox(width: 16),
                  _buildTrustItem(Icons.security, 'Rekber Admin'),
                  const SizedBox(width: 16),
                  _buildTrustItem(Icons.place, 'Bebas COD Kampus'),
                  const SizedBox(width: 16),
                  _buildTrustItem(Icons.delivery_dining, 'Kurir Kos Lubeg'),
                ],
              ),
            ),
    );
  }

  Widget _buildTrustItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: SwissColors.verifiedEmerald),
        const SizedBox(width: 6),
        Text(
          text,
          style: SwissTheme.sans(size: 11, weight: FontWeight.w600, color: SwissColors.inkPrimary),
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
            child: InkWell(
              onTap: () => widget.appState.setCategory(c['name']!),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? SwissColors.inkPrimary : SwissColors.canvasPure,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? SwissColors.inkPrimary : SwissColors.borderHairline,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      c['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : SwissColors.inkSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      c['label']!,
                      style: SwissTheme.sans(
                        size: 11,
                        weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : SwissColors.inkPrimary,
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
            child: Row(
              children: [
                _buildRadiusChip('Semua ($productCount)', 'all', currentRadius),
                _buildRadiusChip('< 500m', '0.5', currentRadius),
                _buildRadiusChip('< 1 KM', '1', currentRadius),
                _buildRadiusChip('< 2 KM', '2', currentRadius),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Sort Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: SwissColors.canvasPure,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SwissColors.borderHairline),
          ),
          child: DropdownButton<String>(
            value: currentSort,
            underline: const SizedBox.shrink(),
            icon: const Icon(Icons.sort, size: 16, color: SwissColors.inkSecondary),
            style: SwissTheme.sans(size: 11, weight: FontWeight.w600, color: SwissColors.inkPrimary),
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
      ],
    );
  }

  Widget _buildRadiusChip(String label, String value, String current) {
    final bool active = current == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        selected: active,
        label: Text(label),
        labelStyle: SwissTheme.sans(
          size: 10,
          weight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? Colors.white : SwissColors.inkPrimary,
        ),
        backgroundColor: SwissColors.canvasPure,
        selectedColor: SwissColors.rauschCoral,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: active ? SwissColors.rauschCoral : SwissColors.borderHairline),
        onSelected: (_) => widget.appState.setRadiusFilter(value),
      ),
    );
  }

  Widget _buildProductGrid(double screenWidth) {
    final List<ProductModel> products = widget.appState.filteredCatalogProducts;

    if (products.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: SwissColors.canvasPure,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SwissColors.borderHairline),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off, size: 32, color: SwissColors.inkMuted),
            ),
            const SizedBox(height: 14),
            Text(
              'Tidak Ditemukan Barang yang Sesuai',
              style: SwissTheme.display(size: 15, weight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Coba gunakan kata kunci lain atau ubah filter kategori dan radius jarak kos Anda.',
              textAlign: TextAlign.center,
              style: SwissTheme.sans(size: 12, color: SwissColors.inkSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => widget.appState.resetAllFilters(),
              style: ElevatedButton.styleFrom(
                backgroundColor: SwissColors.inkPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Reset Semua Filter'),
            ),
          ],
        ),
      );
    }

    // Responsive Column Count
    int crossAxisCount = 2;
    if (screenWidth >= 1200) {
      crossAxisCount = 4;
    } else if (screenWidth >= 768) {
      crossAxisCount = 3;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: crossAxisCount == 2 ? 0.65 : 0.72,
      ),
      itemBuilder: (context, index) {
        return _buildProductCard(products[index]);
      },
    );
  }

  Widget _buildProductCard(ProductModel p) {
    final bool isFav = widget.appState.isFavorite(p.id);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(appState: widget.appState, product: p),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: SwissColors.canvasPure,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: SwissColors.borderHairline),
          boxShadow: const [
            BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Container with category & favorite heart
            AspectRatio(
              aspectRatio: 1.15,
              child: Container(
                color: const Color(0xFFF1F5F9),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: Icon(
                        _getCategoryIcon(p.kategori),
                        size: 40,
                        color: SwissColors.rauschCoral.withValues(alpha: 0.8),
                      ),
                    ),
                    // KTM badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: SwissColors.inkPrimary.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified, size: 10, color: SwissColors.verifiedEmerald),
                            const SizedBox(width: 3),
                            Text(
                              'KTM VERIF',
                              style: SwissTheme.mono(size: 8, weight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Favorite button
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFav ? SwissColors.rauschCoral : SwissColors.inkMuted,
                        ),
                        onPressed: () => widget.appState.toggleFavorite(p.id),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          p.namaBarang,
                          style: SwissTheme.display(size: 12, weight: FontWeight.w700, height: 1.25),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Location
                        Row(
                          children: [
                            const Icon(Icons.place_outlined, size: 11, color: SwissColors.inkMuted),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                '${p.lokasiKos} • ${p.distanceToCampusKm}km',
                                style: SwissTheme.sans(size: 10, color: SwissColors.inkMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Price & Savings
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              SwissTheme.formatRupiah(p.harga),
                              style: SwissTheme.display(
                                size: 14,
                                weight: FontWeight.w900,
                                color: SwissColors.rauschCoral,
                              ),
                            ),
                          ],
                        ),
                        if (p.effectiveOriginalPrice > p.harga) ...[
                          Row(
                            children: [
                              Text(
                                SwissTheme.formatRupiah(p.effectiveOriginalPrice),
                                style: SwissTheme.sans(
                                  size: 10,
                                  color: SwissColors.inkMuted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '-${p.savingsPercent}%',
                                style: SwissTheme.mono(size: 9, weight: FontWeight.w700, color: SwissColors.dangerRose),
                              ),
                            ],
                          ),
                        ],
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
    if (user == null || user.statusVerifikasi != 'pending') return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: const Color(0xFFFEF3C7),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: SwissColors.cautionAmber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Akun (@${user.username}) sedang menunggu verifikasi berkas KTM oleh Tim Verifikator CampusTrade (Target: UPI YPTK).',
                  style: SwissTheme.sans(size: 11, color: const Color(0xFF78350F), weight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampusFooter(double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              const Icon(Icons.school_outlined, size: 20, color: SwissColors.rauschCoral),
              const SizedBox(width: 8),
              Text(
                'CampusTrade — Platform Bursa Mahasiswa',
                style: SwissTheme.display(size: 14, weight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Platform independen penghubung bursa inventaris & perabotan kos mahasiswa (Zona Target Operasional: UPI YPTK Padang & Lubuk Begalung). Tim CampusTrade memfasilitasi verifikasi fisik, serah terima COD aman, dan sistem rekber antar mahasiswa.',
            style: SwissTheme.sans(size: 11, height: 1.4, color: SwissColors.inkSecondary),
          ),
          const SizedBox(height: 12),
          const Divider(color: SwissColors.borderHairline),
          const SizedBox(height: 8),
          Text(
            '© 2026 CampusTrade • Rekber Tim Verifikator Mahasiswa (Target: UPI YPTK)',
            style: SwissTheme.mono(size: 10, color: SwissColors.inkMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomNav() {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: SwissColors.canvasPure,
        border: Border(top: BorderSide(color: SwissColors.borderHairline)),
        boxShadow: [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(0, Icons.storefront_outlined, Icons.storefront, 'Katalog'),
          _buildBottomNavItem(1, Icons.radar_outlined, Icons.radar, 'Radar Kos'),
          _buildBottomSellButton(),
          _buildBottomNavItem(3, Icons.receipt_long_outlined, Icons.receipt_long, 'Pesanan'),
          _buildBottomNavItem(4, Icons.person_outline, Icons.person, 'Akun'),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData unselectedIcon, IconData selectedIcon, String label) {
    final bool active = _currentNavIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentNavIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? selectedIcon : unselectedIcon,
              color: active ? SwissColors.rauschCoral : SwissColors.inkSecondary,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: SwissTheme.sans(
                size: 10,
                weight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? SwissColors.rauschCoral : SwissColors.inkSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSellButton() {
    return InkWell(
      onTap: _handleSellAction,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: SwissColors.rauschCoral,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Color(0x33FF385C), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Text(
              'Jual',
              style: SwissTheme.display(size: 12, weight: FontWeight.w700, color: Colors.white),
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
        return Icons.inventory_2_outlined;
    }
  }
}
