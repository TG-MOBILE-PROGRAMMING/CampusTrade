import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/swiss_theme.dart';
import '../widgets/geospatial_map_widget.dart';

/// ============================================================================
/// ADMIN CMS CONSOLE: 5 FULL-WIDTH RESPONSIVE MODULES
/// ============================================================================
/// 1. Ringkasan & Trafik (admin/index.php)
/// 2. Inventaris & QC Barang (admin/products.php)
/// 3. Verifikasi KTM & User (admin/users.php)
/// 4. Zona Titik COD Resmi (admin/cod_spots.php)
/// 5. Tarif Fee & Ongkir (admin/settings.php)
class AdminCmsScreen extends StatefulWidget {
  final CampusTradeState appState;
  const AdminCmsScreen({super.key, required this.appState});

  @override
  State<AdminCmsScreen> createState() => _AdminCmsScreenState();
}

class _AdminCmsScreenState extends State<AdminCmsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String get _currentTabLabel {
    switch (widget.appState.currentAdminTab) {
      case 'products':
        return 'Inventaris & QC Barang';
      case 'users':
        return 'Verifikasi KTM & User';
      case 'cod_spots':
        return 'Zona Titik COD Resmi';
      case 'settings':
        return 'Tarif Fee & Ongkir';
      default:
        return 'Ringkasan & Trafik';
    }
  }

  String get _currentTabSubtitle {
    switch (widget.appState.currentAdminTab) {
      case 'products':
        return 'Manajemen Kurasi & Quality Control Unit Kos';
      case 'users':
        return 'Validasi Identitas Mahasiswa Kampus UPI YPTK';
      case 'cod_spots':
        return 'Pemetaan Titik Temu Transaksi Aman Lubuk Begalung';
      case 'settings':
        return 'Konfigurasi Parameter Biaya, Ongkir & Rekber';
      default:
        return 'Telemetri Real-Time & Analitik Ekosistem Kampus';
    }
  }

  String get _headerTitle => _currentTabLabel;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 960;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: SwissColors.surface,
      drawer: isDesktop
          ? null
          : Drawer(
              backgroundColor: SwissColors.white,
              child: SafeArea(
                child: _buildSidebar(isDrawer: true),
              ),
            ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop)
              Container(
                width: 256,
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: SwissColors.zinc200)),
                ),
                child: _buildSidebar(),
              ),
            Expanded(
              child: Column(
                children: [
                  _buildAdminNavbar(isDesktop),
                  _buildFlashBanner(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isDesktop ? 28 : 16),
                      child: _buildActiveTabContent(width),
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

  Widget _buildSidebar({bool isDrawer = false}) {
    final s = widget.appState;
    final int pendingProd = s.countPendingProducts;
    final int pendingKtm = s.countPendingUsers;

    return Container(
      color: SwissColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Header
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: SwissColors.zinc200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    if (isDrawer) Navigator.pop(context);
                    s.setAdminTab('dashboard');
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: SwissColors.zinc950,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'CT',
                          style: SwissTheme.display(
                              size: 13, color: SwissColors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'CampusTrade',
                                style: SwissTheme.display(
                                    size: 14, color: SwissColors.zinc950),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: SwissColors.indigo50,
                                  borderRadius: BorderRadius.circular(4),
                                  border:
                                      Border.all(color: SwissColors.indigo200),
                                ),
                                child: Text(
                                  'CMS',
                                  style: SwissTheme.mono(
                                      size: 9,
                                      weight: FontWeight.w700,
                                      color: SwissColors.indigo600),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'UPI YPTK PADANG',
                            style: SwissTheme.mono(
                                size: 9, color: SwissColors.zinc400),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isDrawer)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close,
                        size: 18, color: SwissColors.zinc500),
                    tooltip: 'Tutup Menu',
                  ),
              ],
            ),
          ),

          // Navigation Menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Text(
                    'KONSOL OPERASIONAL',
                    style: SwissTheme.mono(
                        size: 9,
                        weight: FontWeight.w700,
                        color: SwissColors.zinc400,
                        letterSpacing: 0.5),
                  ),
                ),
                _sidebarItem(
                  tab: 'dashboard',
                  icon: Icons.dashboard_outlined,
                  label: 'Ringkasan & Trafik',
                  isDrawer: isDrawer,
                ),
                _sidebarItem(
                  tab: 'products',
                  icon: Icons.inventory_2_outlined,
                  label: 'Inventaris & QC Barang',
                  badgeCount: pendingProd,
                  isDrawer: isDrawer,
                ),
                _sidebarItem(
                  tab: 'users',
                  icon: Icons.verified_user_outlined,
                  label: 'Verifikasi KTM & User',
                  badgeCount: pendingKtm,
                  isDrawer: isDrawer,
                ),
                _sidebarItem(
                  tab: 'cod_spots',
                  icon: Icons.location_on_outlined,
                  label: 'Zona Titik COD Resmi',
                  isDrawer: isDrawer,
                ),
                _sidebarItem(
                  tab: 'settings',
                  icon: Icons.tune_outlined,
                  label: 'Tarif Fee & Ongkir',
                  isDrawer: isDrawer,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(color: SwissColors.zinc200, height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Text(
                    'PINTASAN & SISTEM',
                    style: SwissTheme.mono(
                        size: 9,
                        weight: FontWeight.w700,
                        color: SwissColors.zinc400,
                        letterSpacing: 0.5),
                  ),
                ),
                _externalLinkItem(
                  icon: Icons.storefront_outlined,
                  label: 'Buka Katalog Publik',
                  color: SwissColors.zinc800,
                  onTap: () {
                    if (isDrawer) Navigator.pop(context);
                    s.navigateTo('catalog');
                  },
                ),
                _externalLinkItem(
                  icon: Icons.logout,
                  label: 'Akhiri Sesi Admin',
                  color: SwissColors.rose600,
                  onTap: () {
                    if (isDrawer) Navigator.pop(context);
                    s.logout();
                  },
                ),
              ],
            ),
          ),

          // Admin Profile Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: SwissColors.zinc50,
              border: Border(top: BorderSide(color: SwissColors.zinc200)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: SwissColors.zinc900,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'AD',
                    style: SwissTheme.mono(
                        size: 11,
                        weight: FontWeight.w700,
                        color: SwissColors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.currentUser?.nama ??
                            'Tim Admin & Verifikator UPI YPTK',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SwissTheme.sans(
                          size: 12,
                          weight: FontWeight.w600,
                          color: SwissColors.zinc900,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '@${s.currentUser?.username ?? 'admin'}',
                            style: SwissTheme.mono(
                                size: 10, color: SwissColors.zinc500),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: SwissColors.emerald50,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: SwissColors.emerald200),
                            ),
                            child: Text(
                              'ONLINE',
                              style: SwissTheme.mono(
                                  size: 8,
                                  weight: FontWeight.w700,
                                  color: SwissColors.emerald700),
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
    );
  }

  Widget _sidebarItem({
    required String tab,
    required IconData icon,
    required String label,
    int badgeCount = 0,
    bool isDrawer = false,
  }) {
    final bool active = widget.appState.currentAdminTab == tab;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          widget.appState.setAdminTab(tab);
          if (isDrawer) Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active ? SwissColors.zinc950 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? SwissColors.white : SwissColors.zinc500,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: SwissTheme.sans(
                    size: 12,
                    weight: active ? FontWeight.w600 : FontWeight.w500,
                    color: active ? SwissColors.white : SwissColors.zinc700,
                  ),
                ),
              ),
              if (badgeCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        active ? SwissColors.amber400 : SwissColors.amber100,
                    borderRadius: BorderRadius.circular(4),
                    border: active
                        ? null
                        : Border.all(color: SwissColors.amber300),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: SwissTheme.mono(
                      size: 10,
                      weight: FontWeight.w700,
                      color:
                          active ? SwissColors.zinc950 : SwissColors.amber900,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _externalLinkItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: SwissTheme.sans(
                    size: 12,
                    weight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward,
                  size: 12, color: color.withOpacity(0.4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminNavbar(bool isDesktop) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 20 : 12),
      decoration: const BoxDecoration(
        color: SwissColors.white,
        border: Border(bottom: BorderSide(color: SwissColors.zinc200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (!isDesktop) ...[
                  IconButton(
                    onPressed: () =>
                        _scaffoldKey.currentState?.openDrawer(),
                    icon: const Icon(Icons.menu,
                        size: 22, color: SwissColors.zinc900),
                    tooltip: 'Buka Menu',
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              _currentTabLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SwissTheme.display(
                                  size: isDesktop ? 16 : 14),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: SwissColors.zinc100,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: SwissColors.zinc200),
                            ),
                            child: Text(
                              'ADMIN',
                              style: SwissTheme.mono(
                                  size: 9,
                                  weight: FontWeight.w700,
                                  color: SwissColors.indigo600),
                            ),
                          ),
                        ],
                      ),
                      if (isDesktop)
                        Text(
                          _currentTabSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SwissTheme.mono(
                              size: 10, color: SwissColors.zinc400),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDesktop) ...[
                Text(
                  'PADANG // UPI YPTK',
                  style: SwissTheme.mono(size: 10, color: SwissColors.zinc400),
                ),
                const SizedBox(width: 14),
                ElevatedButton.icon(
                  onPressed: () => widget.appState.navigateTo('catalog'),
                  icon: const Icon(Icons.open_in_new, size: 13),
                  label: Text(
                    'Katalog Publik',
                    style: SwissTheme.sans(
                        size: 11,
                        weight: FontWeight.w600,
                        color: SwissColors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SwissColors.zinc950,
                    foregroundColor: SwissColors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ] else ...[
                OutlinedButton.icon(
                  onPressed: () => widget.appState.navigateTo('catalog'),
                  icon: const Icon(Icons.open_in_new,
                      size: 13, color: SwissColors.zinc800),
                  label: Text(
                    'Katalog',
                    style: SwissTheme.sans(
                        size: 11,
                        weight: FontWeight.w600,
                        color: SwissColors.zinc800),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: SwissColors.white,
                    side: const BorderSide(color: SwissColors.zinc200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlashBanner() {
    final s = widget.appState;
    if (s.flashSuccess == null &&
        s.flashWarning == null &&
        s.flashError == null) {
      return const SizedBox.shrink();
    }
    final String msg =
        s.flashSuccess ?? s.flashWarning ?? s.flashError ?? '';
    final Color bg = s.flashSuccess != null
        ? SwissColors.emerald600
        : s.flashWarning != null
            ? SwissColors.amber500
            : SwissColors.rose600;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              msg,
              style: SwissTheme.sans(
                  size: 12,
                  weight: FontWeight.w600,
                  color: SwissColors.white),
            ),
          ),
          IconButton(
            onPressed: () {
              s.clearFlash('success');
              s.clearFlash('warning');
              s.clearFlash('error');
            },
            icon: const Icon(Icons.close, size: 15, color: SwissColors.white),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent(double width) {
    switch (widget.appState.currentAdminTab) {
      case 'products':
        return _AdminProductsView(appState: widget.appState, width: width);
      case 'users':
        return _AdminUsersView(appState: widget.appState, width: width);
      case 'cod_spots':
        return _AdminCodSpotsView(appState: widget.appState, width: width);
      case 'settings':
        return _AdminSettingsView(appState: widget.appState, width: width);
      default:
        return _AdminDashboardView(appState: widget.appState, width: width);
    }
  }
}

/// ============================================================================
/// TAB 1: DASHBOARD UTAMA & ANALITIK (admin/index.php)
/// ============================================================================
class _AdminDashboardView extends StatelessWidget {
  final CampusTradeState appState;
  final double width;

  const _AdminDashboardView({required this.appState, required this.width});

  @override
  Widget build(BuildContext context) {
    final int pendingKtm = appState.countPendingUsers;
    final bool isWide = width >= 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Alert Verifikasi KTM
        if (pendingKtm > 0) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SwissColors.amber50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SwissColors.amber300),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 10,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Antrean Verifikasi Identitas: $pendingKtm Akun Mahasiswa Menunggu Validasi KTM',
                      style: SwissTheme.display(
                          size: 13, color: SwissColors.amber950),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tinjau keaslian berkas KTM/KRS sebelum mengaktifkan izin pasang iklan barang kos.',
                      style: SwissTheme.sans(
                          size: 11, color: SwissColors.amber800),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    appState.adminUserStatusFilter = 'pending';
                    appState.setAdminTab('users');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SwissColors.zinc950,
                    foregroundColor: SwissColors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Tinjau Antrean KTM ($pendingKtm) ->',
                    style: SwissTheme.sans(
                        size: 12,
                        weight: FontWeight.w600,
                        color: SwissColors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 2. KPI Metric Bento Cards
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: width >= 1100
              ? 4
              : width >= 640
                  ? 2
                  : 1,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          mainAxisExtent: 122,
          children: [
            _kpiCard(
              title: 'TRAFIK KUNJUNGAN',
              badge: 'HARI INI',
              badgeColor: SwissColors.indigo600,
              badgeBg: SwissColors.indigo50,
              mainValue: '${appState.todayVisits}',
              subValue: 'AKUMULATIF: ${appState.totalVisits} HITS',
            ),
            _kpiCard(
              title: 'SESI AKTIF (ONLINE)',
              badge: 'LIVE',
              badgeColor: SwissColors.emerald700,
              badgeBg: SwissColors.emerald50,
              mainValue: '${appState.onlineUsersList.length} User',
              mainColor: SwissColors.emerald600,
              subValue: 'RENTANG 15 MENIT TERAKHIR',
            ),
            _kpiCard(
              title: 'UNIT KATALOG',
              badge: 'KELOLA ->',
              badgeColor: SwissColors.zinc700,
              badgeBg: SwissColors.zinc100,
              mainValue: '${appState.countApprovedProducts} Tayang',
              subValue:
                  '${appState.countPendingProducts} MENUNGGU INSPEKSI QC',
              subColor: SwissColors.amber600,
              onTapBadge: () => appState.setAdminTab('products'),
            ),
            _kpiCard(
              title: 'FEE JASA VERIFIKASI',
              badge: 'REKBER',
              badgeColor: SwissColors.zinc600,
              badgeBg: SwissColors.zinc100,
              mainValue:
                  SwissTheme.formatRupiah(appState.totalAdminFeePotential),
              subValue:
                  'VALUASI BURSA: ${SwissTheme.formatRupiah(appState.totalValuation)}',
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 3. Analytics Charts (Weekly Visits Line Chart + Category Donut Chart)
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 8, child: _buildWeeklyChartCard()),
                  const SizedBox(width: 20),
                  Expanded(flex: 4, child: _buildCategoryDonutCard()),
                ],
              )
            : Column(
                children: [
                  _buildWeeklyChartCard(),
                  const SizedBox(height: 16),
                  _buildCategoryDonutCard(),
                ],
              ),
        const SizedBox(height: 20),

        // 4. Live Online Users Table
        _buildOnlineUsersTable(),
        const SizedBox(height: 20),

        // 5. Recent Listings & COD Spot Distribution
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 8, child: _buildRecentListingsCard()),
                  const SizedBox(width: 20),
                  Expanded(flex: 4, child: _buildCodDistributionCard()),
                ],
              )
            : Column(
                children: [
                  _buildRecentListingsCard(),
                  const SizedBox(height: 16),
                  _buildCodDistributionCard(),
                ],
              ),
      ],
    );
  }

  Widget _kpiCard({
    required String title,
    required String badge,
    required Color badgeColor,
    required Color badgeBg,
    required String mainValue,
    Color mainColor = SwissColors.zinc950,
    required String subValue,
    Color subColor = SwissColors.zinc500,
    VoidCallback? onTapBadge,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SwissColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SwissColors.zinc200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: SwissTheme.mono(size: 10, color: SwissColors.zinc400),
              ),
              InkWell(
                onTap: onTapBadge,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: SwissTheme.mono(size: 9, color: badgeColor),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mainValue,
                style: SwissTheme.display(size: 21, color: mainColor),
              ),
              const SizedBox(height: 3),
              Text(
                subValue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SwissTheme.mono(size: 10, color: subColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChartCard() {
    final series = appState.weeklyVisitSeries;
    return Container(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ANALITIK TRAFIK',
                      style:
                          SwissTheme.mono(size: 10, color: SwissColors.zinc400),
                    ),
                    Text(
                      'Tren Kunjungan Harian (7 Hari Terakhir)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SwissTheme.display(size: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: SwissColors.zinc100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: SwissColors.zinc200),
                ),
                child: Text(
                  'REAL-TIME LOG',
                  style: SwissTheme.mono(size: 9, color: SwissColors.zinc600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: _WeeklyLineChartPainter(series: series),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDonutCard() {
    final series = appState.categoryChartSeries;
    const List<Color> palette = [
      SwissColors.zinc950,
      SwissColors.indigo600,
      SwissColors.emerald500,
      SwissColors.amber500,
      SwissColors.rose500,
      SwissColors.zinc500,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SwissColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SwissColors.zinc200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DISTRIBUSI UNIT',
            style: SwissTheme.mono(size: 10, color: SwissColors.zinc400),
          ),
          Text(
            'Komposisi Kategori',
            style: SwissTheme.display(size: 15),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: _CategoryDonutPainter(
                values: series.map((e) => e.value).toList(),
                colors: palette,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: List.generate(series.length, (i) {
              final e = series[i];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: palette[i % palette.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${e.key} (${e.value})',
                    style:
                        SwissTheme.mono(size: 9, color: SwissColors.zinc600),
                  ),
                ],
              );
            }),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL INVENTARIS',
                style: SwissTheme.mono(size: 10, color: SwissColors.zinc500),
              ),
              Text(
                '${appState.countAllProducts} UNIT',
                style: SwissTheme.mono(
                  size: 10,
                  weight: FontWeight.w700,
                  color: SwissColors.zinc950,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineUsersTable() {
    final onlineList = appState.onlineUsersList;
    return Container(
      decoration: BoxDecoration(
        color: SwissColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SwissColors.zinc200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACTIVE SESSIONS',
                        style: SwissTheme.mono(
                            size: 10, color: SwissColors.emerald600),
                      ),
                      Text(
                        'Pengguna Sedang Online',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SwissTheme.display(size: 15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: SwissColors.emerald50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: SwissColors.emerald200),
                  ),
                  child: Text(
                    '${onlineList.length} TERDETEKSI',
                    style: SwissTheme.mono(
                        size: 10, color: SwissColors.emerald700),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 680),
              child: DataTable(
                headingRowHeight: 38,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 54,
                columns: [
                  DataColumn(
                      label: Text('IDENTITAS PENGGUNA',
                          style: SwissTheme.mono(size: 10))),
                  DataColumn(
                      label: Text('OTORITAS',
                          style: SwissTheme.mono(size: 10))),
                  DataColumn(
                      label: Text('PROGRAM STUDI / UNIT',
                          style: SwissTheme.mono(size: 10))),
                  DataColumn(
                      label: Text('STATUS SESI',
                          style: SwissTheme.mono(size: 10))),
                ],
                rows: onlineList.map((u) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(u.nama,
                                style: SwissTheme.sans(
                                    size: 12, weight: FontWeight.w600)),
                            Text('@${u.username}',
                                style: SwissTheme.mono(
                                    size: 10, color: SwissColors.indigo600)),
                          ],
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: u.role == 'admin'
                                ? SwissColors.zinc900
                                : SwissColors.zinc100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            u.role.toUpperCase(),
                            style: SwissTheme.mono(
                              size: 9,
                              color: u.role == 'admin'
                                  ? SwissColors.white
                                  : SwissColors.zinc700,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(u.jurusan,
                          style: SwissTheme.sans(
                              size: 12, color: SwissColors.zinc600))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: SwissColors.emerald50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: SwissColors.emerald200),
                          ),
                          child: Text(
                            '● ONLINE',
                            style: SwissTheme.mono(
                                size: 9, color: SwissColors.emerald700),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentListingsCard() {
    final recent = appState.products.take(6).toList();
    return Container(
      decoration: BoxDecoration(
        color: SwissColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SwissColors.zinc200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MODUL INVENTARIS',
                        style: SwissTheme.mono(
                            size: 10, color: SwissColors.zinc400),
                      ),
                      Text(
                        'Listing Barang Terbaru',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SwissTheme.display(size: 15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => appState.setAdminTab('products'),
                  child: Text(
                    'LIHAT SEMUA ->',
                    style: SwissTheme.mono(
                        size: 10, color: SwissColors.indigo600),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...recent.map((item) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: SwissColors.zinc100)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      item.foto,
                      width: 38,
                      height: 38,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 38,
                        height: 38,
                        color: SwissColors.zinc100,
                        child: const Icon(Icons.inventory_2_outlined, size: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.namaBarang,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SwissTheme.sans(
                              size: 12,
                              weight: FontWeight.w600,
                              color: SwissColors.zinc900),
                        ),
                        Text(
                          '${item.namaPenjual} • ${item.lokasiKos}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SwissTheme.mono(
                              size: 10, color: SwissColors.zinc400),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    SwissTheme.formatRupiah(item.harga),
                    style: SwissTheme.mono(
                        size: 11,
                        weight: FontWeight.w700,
                        color: SwissColors.zinc900),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () {
                      appState.adminProductSearch = item.namaBarang;
                      appState.setAdminTab('products');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    child: Text('INSPEKSI',
                        style: SwissTheme.mono(
                            size: 9, color: SwissColors.zinc800)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCodDistributionCard() {
    final dist = appState.codSpotDistribution;
    final int totalApproved = appState.countApprovedProducts;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
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
                  Text('Distribusi Titik COD',
                      style: SwissTheme.display(size: 14)),
                  Text('UPI YPTK',
                      style: SwissTheme.mono(
                          size: 10, color: SwissColors.zinc400)),
                ],
              ),
              const SizedBox(height: 14),
              ...dist.entries.map((entry) {
                final int pct = totalApproved > 0
                    ? ((entry.value / totalApproved) * 100).round()
                    : 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SwissTheme.sans(
                                  size: 11, color: SwissColors.zinc700),
                            ),
                          ),
                          Text(
                            '${entry.value} ($pct%)',
                            style: SwissTheme.mono(
                                size: 10, color: SwissColors.zinc900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: (pct / 100.0).clamp(0.0, 1.0),
                          backgroundColor: SwissColors.zinc100,
                          color: SwissColors.zinc950,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SwissColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SwissColors.zinc200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PETA PERIMETER KAMPUS',
                style: SwissTheme.mono(size: 10, color: SwissColors.zinc400),
              ),
              const SizedBox(height: 8),
              GeospatialRadarMap(
                codSpots: appState.activeCodSpots,
                products: appState.filteredCatalogProducts,
                selectedRadiusKm: '1',
                height: 190,
                onSelectProduct: (_) {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ============================================================================
/// TAB 2: MANAJEMEN & KURASI PRODUK (admin/products.php)
/// ============================================================================
class _AdminProductsView extends StatefulWidget {
  final CampusTradeState appState;
  final double width;

  const _AdminProductsView({required this.appState, required this.width});

  @override
  State<_AdminProductsView> createState() => _AdminProductsViewState();
}

class _AdminProductsViewState extends State<_AdminProductsView> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = widget.appState.adminProductSearch;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openEditProductDialog(ProductModel prod) {
    final titleCtrl = TextEditingController(text: prod.namaBarang);
    final priceCtrl = TextEditingController(text: prod.harga.toString());
    final origPriceCtrl =
        TextEditingController(text: prod.hargaAsli.toString());
    final feeCtrl =
        TextEditingController(text: prod.biayaVerifikasi.toString());
    final ongkirCtrl = TextEditingController(text: prod.biayaOngkir.toString());
    final condCtrl = TextEditingController(text: prod.kondisi);
    final locCtrl = TextEditingController(text: prod.lokasiKos);
    final codCtrl = TextEditingController(text: prod.titikCod);
    final qcCtrl = TextEditingController(text: prod.catatanQcAdmin);
    final descCtrl = TextEditingController(text: prod.deskripsi);
    String category = prod.kategori;
    String status = prod.statusVerifikasi;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: SwissColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Unit & Laporan QC Admin',
                  style: SwissTheme.display(size: 16)),
              Text('ID #${prod.id} // ${prod.namaBarang}',
                  style:
                      SwissTheme.mono(size: 10, color: SwissColors.zinc500)),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField('Nama Unit *', titleCtrl),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: status,
                          decoration: const InputDecoration(
                              labelText: 'Status Verifikasi', isDense: true),
                          items: const [
                            DropdownMenuItem(
                                value: 'approved',
                                child: Text('Approved (Tayang)')),
                            DropdownMenuItem(
                                value: 'pending',
                                child: Text('Pending (Antrean)')),
                            DropdownMenuItem(
                                value: 'rejected',
                                child: Text('Rejected (Ditolak)')),
                          ],
                          onChanged: (v) {
                            if (v != null) setDialogState(() => status = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _dialogField('Harga Buka (Rp)', priceCtrl,
                              isNumber: true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _dialogField('Harga Baru (Rp)', origPriceCtrl,
                              isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _dialogField('Fee Verifikasi (Rp)', feeCtrl,
                              isNumber: true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _dialogField('Ongkir Kurir (Rp)', ongkirCtrl,
                              isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _dialogField('Grading Kondisi', condCtrl),
                  const SizedBox(height: 10),
                  _dialogField('Lokasi Kos', locCtrl),
                  const SizedBox(height: 10),
                  _dialogField('Titik Temu COD', codCtrl),
                  const SizedBox(height: 10),
                  _dialogField('Laporan Inspeksi QC Admin', qcCtrl),
                  const SizedBox(height: 10),
                  _dialogField('Deskripsi Lengkap', descCtrl, maxLines: 2),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.appState.adminUpdateProduct(
                  id: prod.id,
                  namaBarang: titleCtrl.text,
                  kategori: category,
                  statusVerifikasi: status,
                  harga: int.tryParse(priceCtrl.text) ?? prod.harga,
                  hargaAsli:
                      int.tryParse(origPriceCtrl.text) ?? prod.hargaAsli,
                  biayaVerifikasi:
                      int.tryParse(feeCtrl.text) ?? prod.biayaVerifikasi,
                  biayaOngkir:
                      int.tryParse(ongkirCtrl.text) ?? prod.biayaOngkir,
                  kondisi: condCtrl.text,
                  lokasiKos: locCtrl.text,
                  titikCod: codCtrl.text,
                  catatanQcAdmin: qcCtrl.text,
                  deskripsi: descCtrl.text,
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SwissColors.zinc950,
                foregroundColor: SwissColors.white,
              ),
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;
    final list = s.filteredAdminProducts;
    final bool isDesktop = widget.width >= 1024;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & Status Filter Pills
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KONTROL KATALOG',
                  style: SwissTheme.mono(
                      size: 10, color: SwissColors.indigo600),
                ),
                Text(
                  'Kurasi Fisik & Manajemen Unit',
                  style: SwissTheme.display(size: 19),
                ),
              ],
            ),
            Wrap(
              spacing: 6,
              children: [
                _statusPill(
                  label: 'Semua (${s.countAllProducts})',
                  active: s.adminProductStatusFilter == 'all',
                  onTap: () => setState(() {
                    s.adminProductStatusFilter = 'all';
                  }),
                ),
                _statusPill(
                  label: 'Pending (${s.countPendingProducts})',
                  active: s.adminProductStatusFilter == 'pending',
                  activeColor: SwissColors.amber500,
                  onTap: () => setState(() {
                    s.adminProductStatusFilter = 'pending';
                  }),
                ),
                _statusPill(
                  label: 'Approved (${s.countApprovedProducts})',
                  active: s.adminProductStatusFilter == 'approved',
                  activeColor: SwissColors.emerald600,
                  onTap: () => setState(() {
                    s.adminProductStatusFilter = 'approved';
                  }),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Search & Category Filter Bar
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SwissColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SwissColors.zinc200),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => s.adminProductSearch = v),
                  style: SwissTheme.sans(size: 12),
                  decoration: InputDecoration(
                    hintText:
                        'Cari nama barang, penjual, NIM, atau lokasi kos...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              DropdownButton<String>(
                value: s.adminProductCategoryFilter,
                items: const [
                  DropdownMenuItem(
                      value: 'all', child: Text('Semua Kategori')),
                  DropdownMenuItem(
                      value: 'Perabotan', child: Text('Perabotan Kos')),
                  DropdownMenuItem(
                      value: 'Elektronik', child: Text('Elektronik Kos')),
                  DropdownMenuItem(
                      value: 'Gadget', child: Text('Gadget & PC')),
                  DropdownMenuItem(
                      value: 'Buku', child: Text('Buku & Modul')),
                  DropdownMenuItem(value: 'Masak', child: Text('Alat Masak')),
                  DropdownMenuItem(
                      value: 'Kendaraan', child: Text('Kendaraan & Helm')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() => s.adminProductCategoryFilter = v);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Dual Responsive View
        if (!isDesktop)
          Column(
            children: list.map((prod) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SwissColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SwissColors.zinc200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            prod.foto,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: SwissColors.zinc100,
                              child: const Icon(Icons.inventory_2_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      prod.kategori.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: SwissTheme.mono(
                                          size: 9,
                                          color: SwissColors.indigo600),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  _statusBadge(prod.statusVerifikasi),
                                ],
                              ),
                              Text(
                                prod.namaBarang,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: SwissTheme.display(size: 14),
                              ),
                              Text(
                                SwissTheme.formatRupiah(prod.harga),
                                style: SwissTheme.display(size: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (prod.statusVerifikasi != 'approved') ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => s.approveProduct(prod.id),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: SwissColors.zinc950,
                                  foregroundColor: SwissColors.white),
                              child: const Text('APPROVE'),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _openEditProductDialog(prod),
                            child: const Text('EDIT / QC'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => s.deleteProduct(prod.id),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: SwissColors.rose600),
                          child: const Text('DEL'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          )
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: SwissColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SwissColors.zinc200),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 880),
                child: DataTable(
                  columns: [
                    DataColumn(
                        label: Text('UNIT & FOTO',
                            style: SwissTheme.mono(size: 10))),
                    DataColumn(
                        label: Text('KATEGORI & KONDISI',
                            style: SwissTheme.mono(size: 10))),
                    DataColumn(
                        label:
                            Text('PENJUAL', style: SwissTheme.mono(size: 10))),
                    DataColumn(
                        label: Text('HARGA & FEE QC',
                            style: SwissTheme.mono(size: 10))),
                    DataColumn(
                        label: Text('TITIK COD',
                            style: SwissTheme.mono(size: 10))),
                    DataColumn(
                        label:
                            Text('STATUS', style: SwissTheme.mono(size: 10))),
                    DataColumn(
                        label:
                            Text('KONTROL', style: SwissTheme.mono(size: 10))),
                  ],
                  rows: list.map((prod) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  prod.foto,
                                  width: 38,
                                  height: 38,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 38,
                                    height: 38,
                                    color: SwissColors.zinc100,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 170),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prod.namaBarang,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: SwissTheme.sans(
                                          size: 12,
                                          weight: FontWeight.w600,
                                          color: SwissColors.zinc950),
                                    ),
                                    Text('ID #${prod.id}',
                                        style: SwissTheme.mono(
                                            size: 10,
                                            color: SwissColors.zinc400)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 160),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(prod.kategori.toUpperCase(),
                                    style: SwissTheme.mono(
                                        size: 10,
                                        color: SwissColors.indigo600)),
                                Text(
                                  prod.kondisi,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: SwissTheme.sans(
                                      size: 11, color: SwissColors.zinc500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(prod.namaPenjual,
                                  style: SwissTheme.sans(
                                      size: 12, weight: FontWeight.w600)),
                              Text('NIM: ${prod.nimPenjual}',
                                  style: SwissTheme.mono(
                                      size: 10, color: SwissColors.zinc400)),
                            ],
                          ),
                        ),
                        DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(SwissTheme.formatRupiah(prod.harga),
                                  style: SwissTheme.mono(
                                      size: 11,
                                      weight: FontWeight.w700,
                                      color: SwissColors.zinc950)),
                              Text(
                                  'Fee: ${SwissTheme.formatRupiah(prod.biayaVerifikasi)}',
                                  style: SwissTheme.mono(
                                      size: 10,
                                      color: SwissColors.emerald700)),
                            ],
                          ),
                        ),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(prod.titikCod,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: SwissTheme.sans(size: 11)),
                                Text(prod.lokasiKos,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: SwissTheme.sans(
                                        size: 10,
                                        color: SwissColors.zinc400)),
                              ],
                            ),
                          ),
                        ),
                        DataCell(_statusBadge(prod.statusVerifikasi)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (prod.statusVerifikasi != 'approved') ...[
                                InkWell(
                                  onTap: () => s.approveProduct(prod.id),
                                  child: _actionChip('APPROVE',
                                      bg: SwissColors.zinc950,
                                      fg: SwissColors.white),
                                ),
                                const SizedBox(width: 6),
                              ],
                              InkWell(
                                onTap: () => _openEditProductDialog(prod),
                                child: _actionChip('EDIT'),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () => s.deleteProduct(prod.id),
                                child: _actionChip('DEL',
                                    fg: SwissColors.rose600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// ============================================================================
/// TAB 3: VERIFIKASI IDENTITAS MAHASISWA & USER (admin/users.php)
/// ============================================================================
class _AdminUsersView extends StatefulWidget {
  final CampusTradeState appState;
  final double width;

  const _AdminUsersView({required this.appState, required this.width});

  @override
  State<_AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<_AdminUsersView> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openKtmInspectionModal(UserModel u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SwissColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('VERIFIKASI DOKUMEN KTM / KRS',
                style: SwissTheme.mono(size: 10, color: SwissColors.indigo600)),
            Text(u.nama, style: SwissTheme.display(size: 16)),
            Text('NIM: ${u.nim} • @${u.username}',
                style: SwissTheme.mono(size: 11, color: SwissColors.zinc500)),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simulated Official UPI YPTK Student ID Card (KTM)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SwissColors.zinc950,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SwissColors.zinc700),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'KARTU TANDA MAHASISWA // UPI YPTK PADANG',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: SwissTheme.mono(
                                size: 9, color: SwissColors.indigo400),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: SwissColors.emerald600,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'AKTIF',
                            style: SwissTheme.mono(
                                size: 8, color: SwissColors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 64,
                          decoration: BoxDecoration(
                            color: SwissColors.zinc800,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: SwissColors.zinc600),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            u.initials,
                            style: SwissTheme.display(
                                size: 18, color: SwissColors.white),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                u.nama.toUpperCase(),
                                style: SwissTheme.display(
                                    size: 14, color: SwissColors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NIM: ${u.nim}',
                                style: SwissTheme.mono(
                                    size: 11, color: SwissColors.emerald400),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                u.jurusan,
                                style: SwissTheme.sans(
                                    size: 11, color: SwissColors.zinc300),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                    Text('PROGRAM STUDI',
                        style: SwissTheme.mono(
                            size: 10, color: SwissColors.zinc500)),
                    Flexible(
                      child: Text(u.jurusan,
                          style: SwissTheme.sans(
                              size: 12, weight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          if (u.statusVerifikasi != 'approved')
            ElevatedButton(
              onPressed: () {
                widget.appState.approveUserKtm(u.id);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SwissColors.emerald600,
                foregroundColor: SwissColors.white,
              ),
              child: const Text('Setujui & Aktifkan Akun'),
            ),
        ],
      ),
    );
  }

  void _openRejectDialog(UserModel u) {
    final reasonCtrl = TextEditingController(
      text:
          'Foto kartu KTM buram, nama dan NIM tidak dapat terbaca dengan jelas.',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SwissColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Tolak Verifikasi KTM (@${u.username})',
            style: SwissTheme.display(size: 15)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(
                    labelText: 'Template Alasan Penolakan', isDense: true),
                items: const [
                  DropdownMenuItem(
                    value:
                        'Foto kartu KTM buram, nama dan NIM tidak dapat terbaca dengan jelas.',
                    child: Text('Foto KTM Buram / Tidak Jelas'),
                  ),
                  DropdownMenuItem(
                    value:
                        'NIM tidak terdaftar sebagai mahasiswa aktif pada pangkalan data kampus.',
                    child: Text('NIM Tidak Terdaftar di UPI YPTK'),
                  ),
                  DropdownMenuItem(
                    value:
                        'Foto yang diunggah bukan merupakan kartu identitas mahasiswa UPI YPTK Padang.',
                    child: Text('Bukan Kartu Mahasiswa UPI YPTK'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) reasonCtrl.text = v;
                },
              ),
              const SizedBox(height: 10),
              _dialogField('Alasan Penolakan *', reasonCtrl, maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              widget.appState.rejectUserKtm(u.id, reasonCtrl.text);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SwissColors.rose600,
              foregroundColor: SwissColors.white,
            ),
            child: const Text('Tolak Berkas'),
          ),
        ],
      ),
    );
  }

  void _openAddUserDialog() {
    final usernameCtrl = TextEditingController();
    final nimCtrl = TextEditingController();
    final namaCtrl = TextEditingController();
    final waCtrl = TextEditingController();
    final passCtrl = TextEditingController(text: 'password');
    String jurusan = 'Teknik Informatika (Fasilkom)';
    String role = 'mahasiswa';
    String status = 'approved';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: SwissColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Registrasi Akun Manual',
              style: SwissTheme.display(size: 16)),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField('Username Unik *', usernameCtrl),
                  const SizedBox(height: 8),
                  _dialogField('NIM Mahasiswa *', nimCtrl),
                  const SizedBox(height: 8),
                  _dialogField('Nama Lengkap *', namaCtrl),
                  const SizedBox(height: 8),
                  _dialogField('No. WhatsApp *', waCtrl),
                  const SizedBox(height: 8),
                  _dialogField('Kata Sandi *', passCtrl),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                widget.appState.adminCreateUser(
                  username: usernameCtrl.text,
                  nim: nimCtrl.text,
                  nama: namaCtrl.text,
                  jurusan: jurusan,
                  whatsapp: waCtrl.text,
                  role: role,
                  statusVerifikasi: status,
                  password: passCtrl.text,
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SwissColors.zinc950,
                foregroundColor: SwissColors.white,
              ),
              child: const Text('Simpan Akun'),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditUserDialog(UserModel u) {
    final namaCtrl = TextEditingController(text: u.nama);
    final jurusanCtrl = TextEditingController(text: u.jurusan);
    final waCtrl = TextEditingController(text: u.whatsapp);
    final passCtrl = TextEditingController();
    String status = u.statusVerifikasi;
    String role = u.role;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: SwissColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Edit Profil Pengguna (@${u.username})',
              style: SwissTheme.display(size: 15)),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField('Nama Lengkap *', namaCtrl),
                  const SizedBox(height: 8),
                  _dialogField('Program Studi *', jurusanCtrl),
                  const SizedBox(height: 8),
                  _dialogField('No. WhatsApp *', waCtrl),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(
                        labelText: 'Status Verifikasi', isDense: true),
                    items: const [
                      DropdownMenuItem(
                          value: 'approved', child: Text('Approved')),
                      DropdownMenuItem(
                          value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(
                          value: 'rejected', child: Text('Rejected')),
                    ],
                    onChanged: (v) {
                      if (v != null) setDialogState(() => status = v);
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration:
                        const InputDecoration(labelText: 'Role', isDense: true),
                    items: const [
                      DropdownMenuItem(
                          value: 'mahasiswa', child: Text('Mahasiswa')),
                      DropdownMenuItem(
                          value: 'admin', child: Text('Administrator')),
                    ],
                    onChanged: (v) {
                      if (v != null) setDialogState(() => role = v);
                    },
                  ),
                  const SizedBox(height: 8),
                  _dialogField('Sandi Baru (Opsional)', passCtrl),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                widget.appState.adminUpdateUser(
                  id: u.id,
                  nama: namaCtrl.text,
                  jurusan: jurusanCtrl.text,
                  whatsapp: waCtrl.text,
                  statusVerifikasi: status,
                  role: role,
                  newPassword: passCtrl.text,
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SwissColors.zinc950,
                foregroundColor: SwissColors.white,
              ),
              child: const Text('Perbarui'),
            ),
          ],
        ),
      ),
    );
  }

  void _openResetPassDialog(UserModel u) {
    final passCtrl = TextEditingController(text: 'upi2026aman');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SwissColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Reset Sandi: ${u.nama}',
            style: SwissTheme.display(size: 15)),
        content: _dialogField('Sandi Baru *', passCtrl),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              widget.appState.adminResetUserPassword(u.id, passCtrl.text);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SwissColors.zinc950,
              foregroundColor: SwissColors.white,
            ),
            child: const Text('Reset Sekarang'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;
    final users = s.filteredAdminUsers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & Add Manual User Button
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OTORISASI CIVITAS',
                    style: SwissTheme.mono(
                        size: 10, color: SwissColors.indigo600)),
                Text('Manajemen & Verifikasi Kartu Mahasiswa',
                    style: SwissTheme.display(size: 19)),
              ],
            ),
            ElevatedButton(
              onPressed: _openAddUserDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: SwissColors.zinc950,
                foregroundColor: SwissColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('+ Registrasi Manual',
                  style: SwissTheme.sans(
                      size: 12,
                      weight: FontWeight.w600,
                      color: SwissColors.white)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Filter Status & Search Bar
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SwissColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SwissColors.zinc200),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _statusPill(
                    label: 'Semua (${s.countTotalUsers})',
                    active: s.adminUserStatusFilter == 'all',
                    onTap: () =>
                        setState(() => s.adminUserStatusFilter = 'all'),
                  ),
                  _statusPill(
                    label: 'Menunggu KTM (${s.countPendingUsers})',
                    active: s.adminUserStatusFilter == 'pending',
                    activeColor: SwissColors.amber500,
                    onTap: () =>
                        setState(() => s.adminUserStatusFilter = 'pending'),
                  ),
                  _statusPill(
                    label: 'Approved (${s.countApprovedUsers})',
                    active: s.adminUserStatusFilter == 'approved',
                    activeColor: SwissColors.emerald600,
                    onTap: () =>
                        setState(() => s.adminUserStatusFilter = 'approved'),
                  ),
                  _statusPill(
                    label: 'Rejected (${s.countRejectedUsers})',
                    active: s.adminUserStatusFilter == 'rejected',
                    activeColor: SwissColors.rose600,
                    onTap: () =>
                        setState(() => s.adminUserStatusFilter = 'rejected'),
                  ),
                ],
              ),
              SizedBox(
                width: 260,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => s.adminUserSearch = v),
                  style: SwissTheme.sans(size: 12),
                  decoration: InputDecoration(
                    hintText: 'Cari username, NIM, nama...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 9),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // User Cards / Table
        ...users.map((u) {
          final bool isPending = u.statusVerifikasi == 'pending';
          final bool isAdminAcc = u.role == 'admin';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPending ? SwissColors.amber50 : SwissColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isPending ? SwissColors.amber400 : SwissColors.zinc200,
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 14,
              runSpacing: 12,
              children: [
                // Identity
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: (widget.width - 64).clamp(180.0, 480.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: SwissColors.zinc900,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          u.initials,
                          style:
                              SwissTheme.mono(size: 12, color: SwissColors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    u.nama,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: SwissTheme.display(size: 14),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _statusBadge(u.statusVerifikasi),
                              ],
                            ),
                            Text(
                              '@${u.username} • NIM: ${u.nim} • ${u.jurusan}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SwissTheme.mono(
                                  size: 10, color: SwissColors.zinc500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (u.fotoKtm != null)
                      InkWell(
                        onTap: () => _openKtmInspectionModal(u),
                        child: _actionChip('LIHAT KTM',
                            bg: SwissColors.indigo50,
                            fg: SwissColors.indigo700),
                      ),
                    if (u.statusVerifikasi != 'approved')
                      InkWell(
                        onTap: () => s.approveUserKtm(u.id),
                        child: _actionChip('APPROVE',
                            bg: SwissColors.zinc950, fg: SwissColors.white),
                      ),
                    if (u.statusVerifikasi != 'rejected' && !isAdminAcc)
                      InkWell(
                        onTap: () => _openRejectDialog(u),
                        child: _actionChip('TOLAK',
                            bg: SwissColors.rose50, fg: SwissColors.rose700),
                      ),
                    InkWell(
                      onTap: () => _openEditUserDialog(u),
                      child: _actionChip('EDIT'),
                    ),
                    InkWell(
                      onTap: () => _openResetPassDialog(u),
                      child: _actionChip('KEY'),
                    ),
                    if (!isAdminAcc)
                      InkWell(
                        onTap: () => s.adminDeleteUser(u.id),
                        child: _actionChip('DEL', fg: SwissColors.rose600),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// ============================================================================
/// TAB 4: ZONA TITIK TEMU COD RESMI (admin/cod_spots.php)
/// ============================================================================
class _AdminCodSpotsView extends StatefulWidget {
  final CampusTradeState appState;
  final double width;

  const _AdminCodSpotsView({required this.appState, required this.width});

  @override
  State<_AdminCodSpotsView> createState() => _AdminCodSpotsViewState();
}

class _AdminCodSpotsViewState extends State<_AdminCodSpotsView> {
  void _openSpotDialog({CodSpotModel? existing}) {
    final nameCtrl = TextEditingController(text: existing?.namaTitik ?? '');
    final latCtrl = TextEditingController(
        text: (existing?.latitude ?? -0.9570).toString());
    final lngCtrl = TextEditingController(
        text: (existing?.longitude ?? 100.3975).toString());
    final descCtrl = TextEditingController(text: existing?.deskripsi ?? '');
    String kategori = existing?.kategori ?? 'dalam_kampus';
    String status = existing?.status ?? 'aktif';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: SwissColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            existing == null ? 'Tambah Titik COD Baru' : 'Edit Titik Temu COD',
            style: SwissTheme.display(size: 16),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField('Nama Titik COD *', nameCtrl),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: kategori,
                          decoration: const InputDecoration(
                              labelText: 'Kategori Zona', isDense: true),
                          items: const [
                            DropdownMenuItem(
                                value: 'dalam_kampus',
                                child: Text('Dalam Kampus')),
                            DropdownMenuItem(
                                value: 'luar_kampus',
                                child: Text('Luar Gerbang')),
                            DropdownMenuItem(
                                value: 'publik_terpantau',
                                child: Text('Publik 24 Jam')),
                          ],
                          onChanged: (v) {
                            if (v != null) setDialogState(() => kategori = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: status,
                          decoration: const InputDecoration(
                              labelText: 'Status', isDense: true),
                          items: const [
                            DropdownMenuItem(
                                value: 'aktif', child: Text('Aktif')),
                            DropdownMenuItem(
                                value: 'nonaktif', child: Text('Nonaktif')),
                          ],
                          onChanged: (v) {
                            if (v != null) setDialogState(() => status = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _dialogField('Latitude *', latCtrl)),
                      const SizedBox(width: 10),
                      Expanded(child: _dialogField('Longitude *', lngCtrl)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _dialogField('Deskripsi & Patokan *', descCtrl, maxLines: 2),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final double lat = double.tryParse(latCtrl.text) ?? -0.9570;
                final double lng = double.tryParse(lngCtrl.text) ?? 100.3975;
                if (existing == null) {
                  widget.appState.createCodSpot(
                    namaTitik: nameCtrl.text,
                    kategori: kategori,
                    status: status,
                    latitude: lat,
                    longitude: lng,
                    deskripsi: descCtrl.text,
                  );
                } else {
                  widget.appState.updateCodSpot(
                    id: existing.id,
                    namaTitik: nameCtrl.text,
                    kategori: kategori,
                    status: status,
                    latitude: lat,
                    longitude: lng,
                    deskripsi: descCtrl.text,
                  );
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SwissColors.zinc950,
                foregroundColor: SwissColors.white,
              ),
              child: Text(existing == null ? 'Simpan Titik' : 'Perbarui'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;
    final spots = s.filteredAdminCodSpots;

    return Column(
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
                Text('LOGISTIK KAMPUS',
                    style: SwissTheme.mono(
                        size: 10, color: SwissColors.indigo600)),
                Text('Konfigurasi Titik Temu COD Resmi',
                    style: SwissTheme.display(size: 19)),
              ],
            ),
            ElevatedButton(
              onPressed: () => _openSpotDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: SwissColors.zinc950,
                foregroundColor: SwissColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('+ Tambah Titik COD',
                  style: SwissTheme.sans(
                      size: 12,
                      weight: FontWeight.w600,
                      color: SwissColors.white)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Policy Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SwissColors.zinc50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SwissColors.zinc200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PROTOKOL FLEKSIBILITAS ZONA COD',
                  style: SwissTheme.mono(
                      size: 10,
                      weight: FontWeight.w700,
                      color: SwissColors.indigo600)),
              const SizedBox(height: 4),
              Text(
                'Apabila rektorat atau satpam kampus membatasi transaksi di dalam gedung akademik (UCC / Fasilkom), klik status titik Dalam Kampus untuk menonaktifkannya dan aktifkan titik Perimeter Luar / Area Publik 24 Jam agar serah terima tetap aman.',
                style: SwissTheme.sans(size: 11, color: SwissColors.zinc600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Spots List
        ...spots.map((spot) {
          final bool isActive = spot.status == 'aktif';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? SwissColors.white : SwissColors.zinc50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SwissColors.zinc200),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 14,
              runSpacing: 10,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(spot.namaTitik,
                              style: SwissTheme.display(size: 14)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: SwissColors.zinc100,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: SwissColors.zinc200),
                            ),
                            child: Text(spot.categoryTag,
                                style: SwissTheme.mono(
                                    size: 9, color: SwissColors.zinc700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(spot.deskripsi,
                          style: SwissTheme.sans(
                              size: 12, color: SwissColors.zinc600)),
                      const SizedBox(height: 4),
                      Text(
                        'GPS: ${spot.latitude.toStringAsFixed(4)}, ${spot.longitude.toStringAsFixed(4)}',
                        style: SwissTheme.mono(
                            size: 10, color: SwissColors.zinc400),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => s.toggleCodSpotStatus(spot.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isActive
                              ? SwissColors.emerald50
                              : SwissColors.zinc100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isActive
                                ? SwissColors.emerald200
                                : SwissColors.zinc300,
                          ),
                        ),
                        child: Text(
                          '● ${spot.status.toUpperCase()}',
                          style: SwissTheme.mono(
                            size: 10,
                            weight: FontWeight.w700,
                            color: isActive
                                ? SwissColors.emerald700
                                : SwissColors.zinc500,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _openSpotDialog(existing: spot),
                      child: _actionChip('EDIT'),
                    ),
                    InkWell(
                      onTap: () => s.deleteCodSpot(spot.id),
                      child: _actionChip('DEL', fg: SwissColors.rose600),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// ============================================================================
/// TAB 5: PENGATURAN PLATFORM, TARIF FEE ADMIN & ONGKIR (admin/settings.php)
/// ============================================================================
class _AdminSettingsView extends StatefulWidget {
  final CampusTradeState appState;
  final double width;

  const _AdminSettingsView({required this.appState, required this.width});

  @override
  State<_AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<_AdminSettingsView> {
  late final TextEditingController _feeStandarCtrl;
  late final TextEditingController _feeKecilCtrl;
  late final TextEditingController _feeBesarCtrl;
  late final TextEditingController _ongkirDasarCtrl;
  late final TextEditingController _ongkirKmCtrl;
  late final TextEditingController _handlingBeratCtrl;
  late final TextEditingController _maxRadiusCtrl;
  late final TextEditingController _bankCtrl;
  late final TextEditingController _rekCtrl;
  late final TextEditingController _atasNamaCtrl;
  late final TextEditingController _waAdminCtrl;
  late final TextEditingController _bannerCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.appState.platformSettings;
    _feeStandarCtrl =
        TextEditingController(text: p['fee_verifikasi_standar']);
    _feeKecilCtrl = TextEditingController(text: p['fee_verifikasi_kecil']);
    _feeBesarCtrl = TextEditingController(text: p['fee_verifikasi_besar']);
    _ongkirDasarCtrl = TextEditingController(text: p['ongkir_dasar']);
    _ongkirKmCtrl = TextEditingController(text: p['ongkir_per_km']);
    _handlingBeratCtrl =
        TextEditingController(text: p['biaya_handling_berat']);
    _maxRadiusCtrl = TextEditingController(text: p['max_radius_km']);
    _bankCtrl = TextEditingController(text: p['nama_bank']);
    _rekCtrl = TextEditingController(text: p['nomor_rekening']);
    _atasNamaCtrl = TextEditingController(text: p['atas_nama_rekening']);
    _waAdminCtrl = TextEditingController(text: p['no_wa_admin']);
    _bannerCtrl = TextEditingController(text: p['banner_pengumuman']);
  }

  @override
  void dispose() {
    _feeStandarCtrl.dispose();
    _feeKecilCtrl.dispose();
    _feeBesarCtrl.dispose();
    _ongkirDasarCtrl.dispose();
    _ongkirKmCtrl.dispose();
    _handlingBeratCtrl.dispose();
    _maxRadiusCtrl.dispose();
    _bankCtrl.dispose();
    _rekCtrl.dispose();
    _atasNamaCtrl.dispose();
    _waAdminCtrl.dispose();
    _bannerCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() {
    widget.appState.updatePlatformSettings({
      'fee_verifikasi_standar': _feeStandarCtrl.text.trim(),
      'fee_verifikasi_kecil': _feeKecilCtrl.text.trim(),
      'fee_verifikasi_besar': _feeBesarCtrl.text.trim(),
      'ongkir_dasar': _ongkirDasarCtrl.text.trim(),
      'ongkir_per_km': _ongkirKmCtrl.text.trim(),
      'biaya_handling_berat': _handlingBeratCtrl.text.trim(),
      'max_radius_km': _maxRadiusCtrl.text.trim(),
      'nama_bank': _bankCtrl.text.trim(),
      'nomor_rekening': _rekCtrl.text.trim(),
      'atas_nama_rekening': _atasNamaCtrl.text.trim(),
      'no_wa_admin': _waAdminCtrl.text.trim(),
      'banner_pengumuman': _bannerCtrl.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = widget.width >= 1080;

    final Widget leftCol = Column(
      children: [
        // Modul 01: Monetisasi Fee
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
              Text('MODUL 01 // MONETISASI',
                  style: SwissTheme.mono(size: 10, color: SwissColors.zinc400)),
              Text('Struktur Fee Jasa Verifikasi Fisik & Rekber',
                  style: SwissTheme.display(size: 15)),
              const SizedBox(height: 14),
              if (widget.width < 600) ...[
                _dialogField('Fee Standar (Rp)', _feeStandarCtrl,
                    isNumber: true),
                const SizedBox(height: 10),
                _dialogField('Fee Unit Kecil (Rp)', _feeKecilCtrl,
                    isNumber: true),
                const SizedBox(height: 10),
                _dialogField('Fee Unit Besar (Rp)', _feeBesarCtrl,
                    isNumber: true),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                        child: _dialogField(
                            'Fee Standar (Rp)', _feeStandarCtrl,
                            isNumber: true)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _dialogField(
                            'Fee Unit Kecil (Rp)', _feeKecilCtrl,
                            isNumber: true)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _dialogField(
                            'Fee Unit Besar (Rp)', _feeBesarCtrl,
                            isNumber: true)),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Modul 02: Logistik
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
              Text('MODUL 02 // LOGISTIK LUBUK BEGALUNG',
                  style: SwissTheme.mono(size: 10, color: SwissColors.zinc400)),
              Text('Tarif Ekspedisi & Kurir Antar-Kos Admin',
                  style: SwissTheme.display(size: 15)),
              const SizedBox(height: 14),
              if (widget.width < 600) ...[
                _dialogField('Ongkir Dasar (Rp)', _ongkirDasarCtrl,
                    isNumber: true),
                const SizedBox(height: 10),
                _dialogField('Tarif per KM (Rp)', _ongkirKmCtrl,
                    isNumber: true),
                const SizedBox(height: 10),
                _dialogField('Handling Berat (Rp)', _handlingBeratCtrl,
                    isNumber: true),
                const SizedBox(height: 10),
                _dialogField('Max Radius (KM)', _maxRadiusCtrl),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                        child: _dialogField(
                            'Ongkir Dasar (Rp)', _ongkirDasarCtrl,
                            isNumber: true)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _dialogField('Tarif per KM (Rp)', _ongkirKmCtrl,
                            isNumber: true)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _dialogField(
                            'Handling Berat (Rp)', _handlingBeratCtrl,
                            isNumber: true)),
                    const SizedBox(width: 10),
                    Expanded(
                        child:
                            _dialogField('Max Radius (KM)', _maxRadiusCtrl)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );

    final Widget rightCol = Column(
      children: [
        // Modul 03: Escrow & Kontak
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
              Text('MODUL 03 // ESCROW & KONTAK',
                  style: SwissTheme.mono(size: 10, color: SwissColors.zinc400)),
              Text('Rekening Rekber & Hotline WhatsApp Mediasi',
                  style: SwissTheme.display(size: 15)),
              const SizedBox(height: 14),
              _dialogField('Bank / E-Wallet *', _bankCtrl),
              const SizedBox(height: 10),
              if (widget.width < 600) ...[
                _dialogField('Nomor Rekening *', _rekCtrl),
                const SizedBox(height: 10),
                _dialogField('Atas Nama *', _atasNamaCtrl),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                        child: _dialogField('Nomor Rekening *', _rekCtrl)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _dialogField('Atas Nama *', _atasNamaCtrl)),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              _dialogField('No. WhatsApp Admin Verifikator *', _waAdminCtrl),
              const SizedBox(height: 10),
              _dialogField('Teks Pengumuman Status Bar', _bannerCtrl),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Submit Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: SwissColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SwissColors.zinc200),
          ),
          child: widget.width < 500
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Terapkan Parameter Sistem',
                        style: SwissTheme.display(size: 13)),
                    Text('Sinkronisasi instan ke seluruh transaksi baru.',
                        style: SwissTheme.sans(
                            size: 11, color: SwissColors.zinc500)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SwissColors.zinc950,
                        foregroundColor: SwissColors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Simpan Konfigurasi',
                          style: SwissTheme.sans(
                              size: 12,
                              weight: FontWeight.w600,
                              color: SwissColors.white)),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Terapkan Parameter Sistem',
                              style: SwissTheme.display(size: 13)),
                          Text('Sinkronisasi instan ke seluruh transaksi baru.',
                              style: SwissTheme.sans(
                                  size: 11, color: SwissColors.zinc500)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SwissColors.zinc950,
                        foregroundColor: SwissColors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Simpan Konfigurasi',
                          style: SwissTheme.sans(
                              size: 12,
                              weight: FontWeight.w600,
                              color: SwissColors.white)),
                    ),
                  ],
                ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: leftCol),
                  const SizedBox(width: 20),
                  Expanded(flex: 5, child: rightCol),
                ],
              )
            : Column(
                children: [
                  leftCol,
                  const SizedBox(height: 18),
                  rightCol,
                ],
              ),
        const SizedBox(height: 20),

        // Hardened Server Telemetry Box
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
                  Text('TELEMETRI SERVER & KEAMANAN',
                      style: SwissTheme.mono(
                          size: 10, color: SwissColors.zinc400)),
                  Text('HARDENED // OWASP',
                      style: SwissTheme.mono(
                          size: 10, color: SwissColors.emerald400)),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _telemetryCell('BERKAS UNGGAHAN', '9 File', SwissColors.white),
                  _telemetryCell(
                      'KAPASITAS DISK', '1.42 MB', SwissColors.indigo400),
                  _telemetryCell(
                      'PROTEKSI RCE', 'ENGINE OFF', SwissColors.emerald400),
                  _telemetryCell(
                      'TOKEN CSRF', 'ACTIVE 256-BIT', SwissColors.amber400),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _telemetryCell(String label, String val, Color color) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SwissColors.zinc900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SwissColors.zinc800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: SwissTheme.mono(size: 9, color: SwissColors.zinc500)),
          const SizedBox(height: 4),
          Text(val, style: SwissTheme.display(size: 14, color: color)),
        ],
      ),
    );
  }
}

/// ============================================================================
/// SHARED ADMIN UI HELPERS & CHART PAINTERS
/// ============================================================================
Widget _statusPill({
  required String label,
  required bool active,
  Color activeColor = SwissColors.zinc950,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? activeColor : SwissColors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: active ? activeColor : SwissColors.zinc200,
        ),
      ),
      child: Text(
        label,
        style: SwissTheme.sans(
          size: 12,
          weight: FontWeight.w600,
          color: active ? SwissColors.white : SwissColors.zinc600,
        ),
      ),
    ),
  );
}

Widget _statusBadge(String status) {
  final Color bg = status == 'approved'
      ? SwissColors.emerald50
      : status == 'pending'
          ? SwissColors.amber100
          : SwissColors.rose50;
  final Color fg = status == 'approved'
      ? SwissColors.emerald700
      : status == 'pending'
          ? SwissColors.amber900
          : SwissColors.rose700;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      status.toUpperCase(),
      style: SwissTheme.mono(size: 9, weight: FontWeight.w700, color: fg),
    ),
  );
}

Widget _actionChip(String label, {Color? bg, Color? fg}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: bg ?? SwissColors.zinc100,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      label,
      style: SwissTheme.mono(
        size: 10,
        weight: FontWeight.w700,
        color: fg ?? SwissColors.zinc800,
      ),
    ),
  );
}

Widget _dialogField(
  String label,
  TextEditingController ctrl, {
  bool isNumber = false,
  int maxLines = 1,
}) {
  return TextField(
    controller: ctrl,
    maxLines: maxLines,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    style: SwissTheme.sans(size: 12),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: SwissTheme.mono(size: 10, color: SwissColors.zinc600),
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

class _WeeklyLineChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> series;
  _WeeklyLineChartPainter({required this.series});

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    const double leftPad = 28;
    const double bottomPad = 24;
    const double topPad = 12;
    const double rightPad = 12;

    final double chartW = size.width - leftPad - rightPad;
    final double chartH = size.height - topPad - bottomPad;

    final int maxVal =
        series.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final double maxY = (maxVal * 1.2).clamp(10.0, 9999.0);

    // Grid lines
    final Paint gridPaint = Paint()
      ..color = SwissColors.zinc100
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final double y = topPad + (chartH * (i / 4));
      canvas.drawLine(Offset(leftPad, y), Offset(size.width - rightPad, y),
          gridPaint);
    }

    // Points
    final List<Offset> points = [];
    for (int i = 0; i < series.length; i++) {
      final double x =
          leftPad + (chartW * (i / math.max(1, series.length - 1)));
      final double y =
          topPad + chartH - ((series[i].value / maxY) * chartH);
      points.add(Offset(x, y));
    }

    // Fill Path
    final Path fillPath = Path()..moveTo(points.first.dx, topPad + chartH);
    for (final pt in points) {
      fillPath.lineTo(pt.dx, pt.dy);
    }
    fillPath.lineTo(points.last.dx, topPad + chartH);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()..color = const Color(0x1209090B),
    );

    // Line Path
    final Path linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = SwissColors.zinc950
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke,
    );

    // Dots & X labels
    for (int i = 0; i < points.length; i++) {
      final Offset pt = points[i];
      canvas.drawCircle(pt, 4.5, Paint()..color = SwissColors.white);
      canvas.drawCircle(pt, 3.5, Paint()..color = SwissColors.indigo600);

      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: series[i].key.split(' ').first,
          style: SwissTheme.mono(size: 9, color: SwissColors.zinc500),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pt.dx - (tp.width / 2), topPad + chartH + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyLineChartPainter oldDelegate) => true;
}

class _CategoryDonutPainter extends CustomPainter {
  final List<int> values;
  final List<Color> colors;

  _CategoryDonutPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final int total = values.fold(0, (a, b) => a + b);
    if (total <= 0) return;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) * 0.42;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2;
    for (int i = 0; i < values.length; i++) {
      final double sweep = (values[i] / total) * 2 * math.pi;
      final Paint segPaint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20;
      canvas.drawArc(rect, startAngle, sweep - 0.04, false, segPaint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _CategoryDonutPainter oldDelegate) => true;
}
