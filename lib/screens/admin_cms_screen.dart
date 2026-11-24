import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/swiss_theme.dart';
import '../widgets/geospatial_map_widget.dart';

/// ============================================================================
/// ADMIN CMS CONSOLE: 5 FULL-WIDTH RESPONSIVE MODULES (LINEAR DARK MODE)
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
        return 'Kurasi & Quality Control Inventaris Kos (Platform CampusTrade)';
      case 'users':
        return 'Verifikasi Berkas KTM/KRS Mahasiswa (Platform CampusTrade)';
      case 'cod_spots':
        return 'Pemetaan Titik Temu Transaksi Aman Mahasiswa Sekitar Kampus Target';
      case 'settings':
        return 'Konfigurasi Parameter Fee Verifikasi, Ongkir & Rekber CampusTrade';
      default:
        return 'Telemetri Real-Time & Aktivitas Platform CampusTrade';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 960;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: SwissColors.adminVoid,
      drawer: isDesktop
          ? null
          : Drawer(
              backgroundColor: SwissColors.adminPanel,
              clipBehavior: Clip.antiAlias,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
              ),
              child: SafeArea(
                top: true,
                bottom: true,
                child: _buildSidebar(isDrawer: true),
              ),
            ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isDesktop)
              SizedBox(
                width: 256,
                child: Container(
                  decoration: const BoxDecoration(
                    color: SwissColors.adminPanel,
                    border: Border(right: BorderSide(color: SwissColors.adminHairline)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildSidebar(),
                ),
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
      color: SwissColors.adminPanel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Header
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: SwissColors.adminHairline)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (isDrawer) Navigator.pop(context);
                      s.setAdminTab('dashboard');
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: SwissColors.linearLavender,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x336366F1),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'CT',
                            style: SwissTheme.display(
                                size: 14, weight: FontWeight.w800, color: SwissColors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                                      'CampusTrade',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: SwissTheme.display(
                                          size: 14, weight: FontWeight.w800, color: SwissColors.adminTextHigh),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: SwissColors.linearLavender.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: SwissColors.linearLavender.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      'CMS',
                                      style: SwissTheme.mono(
                                          size: 8,
                                          weight: FontWeight.w800,
                                          color: SwissColors.linearLavender),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'PLATFORM PENGHUBUNG KAMPUS',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: SwissTheme.mono(
                                    size: 8, weight: FontWeight.w600, color: SwissColors.adminTextLow),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isDrawer)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close,
                        size: 18, color: SwissColors.adminTextLow),
                    tooltip: 'Tutup Menu',
                  ),
              ],
            ),
          ),

          // Navigation Menu
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Text(
                    'KONSOL OPERASIONAL',
                    style: SwissTheme.mono(
                        size: 9,
                        weight: FontWeight.w700,
                        color: SwissColors.adminTextLow,
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
                  child: Divider(color: SwissColors.adminHairline, height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Text(
                    'PINTASAN & SISTEM',
                    style: SwissTheme.mono(
                        size: 9,
                        weight: FontWeight.w700,
                        color: SwissColors.adminTextLow,
                        letterSpacing: 0.5),
                  ),
                ),
                _externalLinkItem(
                  icon: Icons.storefront_outlined,
                  label: 'Buka Katalog Publik',
                  color: SwissColors.adminTextHigh,
                  onTap: () {
                    if (isDrawer) Navigator.pop(context);
                    s.navigateTo('catalog');
                  },
                ),
                _externalLinkItem(
                  icon: Icons.logout,
                  label: 'Akhiri Sesi Admin',
                  color: SwissColors.dangerRose,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: SwissColors.adminPanel,
              border: Border(top: BorderSide(color: SwissColors.adminHairline)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: SwissColors.linearLavender.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: SwissColors.linearLavender.withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'CT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: SwissColors.linearLavender,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tim Verifikator CampusTrade',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SwissTheme.sans(
                          size: 12,
                          weight: FontWeight.w700,
                          color: SwissColors.adminTextHigh,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '@${s.currentUser?.username ?? 'admin'}',
                            style: SwissTheme.mono(
                                size: 10, color: SwissColors.adminTextLow),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: SwissColors.adminAccentEmerald.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'AKTIF',
                              style: SwissTheme.mono(
                                  size: 8,
                                  weight: FontWeight.w800,
                                  color: SwissColors.adminAccentEmerald),
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
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: active
                ? SwissColors.linearLavender.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: active
                ? Border.all(
                    color: SwissColors.linearLavender.withValues(alpha: 0.35))
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: active ? SwissColors.linearLavender : SwissColors.adminTextLow,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: SwissTheme.sans(
                    size: 12,
                    weight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? SwissColors.adminTextHigh : SwissColors.adminTextLow,
                  ),
                ),
              ),
              if (badgeCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: active ? SwissColors.linearLavender : SwissColors.adminElevated,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: SwissColors.adminHairline),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: SwissTheme.mono(
                      size: 10,
                      weight: FontWeight.w700,
                      color: active ? SwissColors.white : SwissColors.adminTextHigh,
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
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 12),
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
              Icon(Icons.arrow_forward_ios,
                  size: 11, color: color.withValues(alpha: 0.5)),
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
        color: SwissColors.adminPanel,
        border: Border(bottom: BorderSide(color: SwissColors.adminHairline)),
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
                        size: 22, color: SwissColors.adminTextHigh),
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
                                size: isDesktop ? 16 : 14,
                                color: SwissColors.adminTextHigh,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: SwissColors.adminElevated,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: SwissColors.adminHairline),
                            ),
                            child: Text(
                              'ADMIN',
                              style: SwissTheme.mono(
                                  size: 9,
                                  weight: FontWeight.w700,
                                  color: SwissColors.linearLavender),
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
                              size: 10, color: SwissColors.adminTextLow),
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
                  'PLATFORM PENGHUBUNG KAMPUS',
                  style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow),
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
                    backgroundColor: SwissColors.linearLavender,
                    foregroundColor: SwissColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ] else ...[
                OutlinedButton.icon(
                  onPressed: () => widget.appState.navigateTo('catalog'),
                  icon: const Icon(Icons.open_in_new,
                      size: 13, color: SwissColors.adminTextHigh),
                  label: Text(
                    'Katalog',
                    style: SwissTheme.sans(
                        size: 11,
                        weight: FontWeight.w600,
                        color: SwissColors.adminTextHigh),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: SwissColors.adminElevated,
                    side: const BorderSide(color: SwissColors.adminHairline),
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
        ? const Color(0xFF065F46)
        : s.flashWarning != null
            ? const Color(0xFF78350F)
            : const Color(0xFF881337);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SwissColors.adminHairline),
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
/// TAB 1: DASHBOARD UTAMA & ANALITIK (admin/index.php) - LINEAR DARK MODE
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
              color: const Color(0x1AD97706),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x40D97706)),
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
                      'Antrean Verifikasi: $pendingKtm Akun Mahasiswa Menunggu Validasi KTM',
                      style: SwissTheme.display(
                          size: 13, color: const Color(0xFFFDE68A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tinjau keaslian berkas KTM/KRS sebelum mengaktifkan izin pasang iklan barang kos.',
                      style: SwissTheme.sans(
                          size: 11, color: SwissColors.adminTextLow),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    appState.adminUserStatusFilter = 'pending';
                    appState.setAdminTab('users');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SwissColors.linearLavender,
                    foregroundColor: SwissColors.white,
                    elevation: 0,
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
        SwissResponsiveGrid(
          crossAxisCount: width >= 1100
              ? 4
              : width >= 640
                  ? 2
                  : 1,
          spacing: 14,
          runSpacing: 14,
          children: [
            _kpiCard(
              title: 'TRAFIK KUNJUNGAN',
              badge: 'HARI INI',
              badgeColor: SwissColors.linearLavender,
              badgeBg: SwissColors.adminElevated,
              mainValue: '${appState.todayVisits}',
              subValue: 'AKUMULATIF: ${appState.totalVisits} HITS',
            ),
            _kpiCard(
              title: 'SESI AKTIF (ONLINE)',
              badge: 'LIVE',
              badgeColor: SwissColors.verifiedEmerald,
              badgeBg: SwissColors.adminElevated,
              mainValue: '${appState.onlineUsersList.length} User',
              mainColor: SwissColors.verifiedEmerald,
              subValue: 'RENTANG 15 MENIT TERAKHIR',
            ),
            _kpiCard(
              title: 'UNIT KATALOG',
              badge: 'KELOLA ->',
              badgeColor: SwissColors.linearLavender,
              badgeBg: SwissColors.adminElevated,
              mainValue: '${appState.countApprovedProducts} Tayang',
              subValue:
                  '${appState.countPendingProducts} MENUNGGU INSPEKSI QC',
              subColor: SwissColors.cautionAmber,
              onTapBadge: () => appState.setAdminTab('products'),
            ),
            _kpiCard(
              title: 'FEE JASA VERIFIKASI',
              badge: 'REKBER',
              badgeColor: SwissColors.escrowIndigo,
              badgeBg: SwissColors.adminElevated,
              mainValue:
                  SwissTheme.formatRupiah(appState.totalAdminFeePotential),
              subValue:
                  'VALUASI: ${SwissTheme.formatRupiah(appState.totalValuation)}',
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
    Color mainColor = SwissColors.adminTextHigh,
    required String subValue,
    Color subColor = SwissColors.adminTextLow,
    VoidCallback? onTapBadge,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SwissColors.adminPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SwissColors.adminHairline),
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
                style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow),
              ),
              InkWell(
                onTap: onTapBadge,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: SwissColors.adminHairline),
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
                style: SwissTheme.display(
                  size: 21,
                  color: mainColor,
                ),
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
        color: SwissColors.adminPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SwissColors.adminHairline),
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
                          SwissTheme.mono(size: 10, color: SwissColors.adminTextLow),
                    ),
                    Text(
                      'Tren Kunjungan Harian (7 Hari Terakhir)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SwissTheme.display(
                        size: 15,
                        color: SwissColors.adminTextHigh,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: SwissColors.adminElevated,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: SwissColors.adminHairline),
                ),
                child: Text(
                  'REAL-TIME LOG',
                  style: SwissTheme.mono(size: 9, color: SwissColors.linearLavender),
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
      SwissColors.linearLavender,
      SwissColors.escrowIndigo,
      SwissColors.verifiedEmerald,
      SwissColors.cautionAmber,
      SwissColors.dangerRose,
      SwissColors.adminTextLow,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SwissColors.adminPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SwissColors.adminHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DISTRIBUSI UNIT',
            style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow),
          ),
          Text(
            'Komposisi Kategori',
            style: SwissTheme.display(
              size: 15,
              color: SwissColors.adminTextHigh,
            ),
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
                        SwissTheme.mono(size: 9, color: SwissColors.adminTextLow),
                  ),
                ],
              );
            }),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: SwissColors.adminHairline),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL INVENTARIS',
                style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow),
              ),
              Text(
                '${appState.countAllProducts} UNIT',
                style: SwissTheme.mono(
                  size: 10,
                  weight: FontWeight.w700,
                  color: SwissColors.adminTextHigh,
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
        color: SwissColors.adminPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SwissColors.adminHairline),
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
                            size: 10, color: SwissColors.verifiedEmerald),
                      ),
                      Text(
                        'Pengguna Sedang Online',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SwissTheme.display(
                          size: 15,
                          color: SwissColors.adminTextHigh,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x1F059669),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0x33059669)),
                  ),
                  child: Text(
                    '${onlineList.length} TERDETEKSI',
                    style: SwissTheme.mono(
                        size: 10, color: SwissColors.verifiedEmerald),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: SwissColors.adminHairline),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 680),
              child: Theme(
                data: ThemeData.dark(),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(SwissColors.adminElevated),
                  headingRowHeight: 38,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 54,
                  columns: [
                    DataColumn(
                        label: Text('IDENTITAS PENGGUNA',
                            style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow))),
                    DataColumn(
                        label: Text('OTORITAS',
                            style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow))),
                    DataColumn(
                        label: Text('PROGRAM STUDI / UNIT',
                            style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow))),
                    DataColumn(
                        label: Text('STATUS SESI',
                            style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow))),
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
                                      size: 12,
                                      weight: FontWeight.w600,
                                      color: SwissColors.adminTextHigh)),
                              Text('@${u.username}',
                                  style: SwissTheme.mono(
                                      size: 10, color: SwissColors.linearLavender)),
                            ],
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: u.role == 'admin'
                                  ? SwissColors.adminElevated
                                  : SwissColors.adminVoid,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: SwissColors.adminHairline),
                            ),
                            child: Text(
                              u.role.toUpperCase(),
                              style: SwissTheme.mono(
                                size: 9,
                                color: u.role == 'admin'
                                    ? SwissColors.linearLavender
                                    : SwissColors.adminTextLow,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text(u.jurusan,
                            style: SwissTheme.sans(
                                size: 12, color: SwissColors.adminTextLow))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0x1F059669),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0x33059669)),
                            ),
                            child: Text(
                              '● ONLINE',
                              style: SwissTheme.mono(
                                  size: 9, color: SwissColors.verifiedEmerald),
                            ),
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
      ),
    );
  }

  Widget _buildRecentListingsCard() {
    final recent = appState.products.take(6).toList();
    return Container(
      decoration: BoxDecoration(
        color: SwissColors.adminPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SwissColors.adminHairline),
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
                            size: 10, color: SwissColors.adminTextLow),
                      ),
                      Text(
                        'Listing Barang Terbaru',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SwissTheme.display(
                          size: 15,
                          color: SwissColors.adminTextHigh,
                        ),
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
                        size: 10, color: SwissColors.linearLavender),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: SwissColors.adminHairline),
          ...recent.map((item) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: SwissColors.adminHairline)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      item.foto,
                      width: 38,
                      height: 38,
                      cacheWidth: 100,
                      cacheHeight: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 38,
                        height: 38,
                        color: SwissColors.adminElevated,
                        child: const Icon(Icons.inventory_2_outlined,
                            size: 16, color: SwissColors.adminTextLow),
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
                              color: SwissColors.adminTextHigh),
                        ),
                        Text(
                          '${item.namaPenjual} • ${item.lokasiKos}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SwissTheme.mono(
                              size: 10, color: SwissColors.adminTextLow),
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
                        color: SwissColors.adminTextHigh),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () {
                      appState.adminProductSearch = item.namaBarang;
                      appState.setAdminTab('products');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: SwissColors.adminHairline),
                      backgroundColor: SwissColors.adminElevated,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    child: Text('INSPEKSI',
                        style: SwissTheme.mono(
                            size: 9, color: SwissColors.linearLavender)),
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
            color: SwissColors.adminPanel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SwissColors.adminHairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Distribusi Titik COD',
                      style: SwissTheme.display(
                        size: 14,
                        color: SwissColors.adminTextHigh,
                      )),
                  Text('ZONA KAMPUS TARGET',
                      style: SwissTheme.mono(
                          size: 10, color: SwissColors.adminTextLow)),
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
                                  size: 11, color: SwissColors.adminTextLow),
                            ),
                          ),
                          Text(
                            '${entry.value} ($pct%)',
                            style: SwissTheme.mono(
                                size: 10, color: SwissColors.adminTextHigh),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: (pct / 100.0).clamp(0.0, 1.0),
                          backgroundColor: SwissColors.adminElevated,
                          color: SwissColors.linearLavender,
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
            color: SwissColors.adminPanel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SwissColors.adminHairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PETA PERIMETER KAMPUS',
                style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow),
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
/// TAB 2: MANAJEMEN & KURASI PRODUK (admin/products.php) - LINEAR DARK MODE
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
          backgroundColor: SwissColors.adminPanel,
          shape:
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: SwissColors.adminHairline),
              ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Unit & Laporan QC Admin',
                  style: SwissTheme.display(
                    size: 16,
                    color: SwissColors.adminTextHigh,
                  )),
              Text('ID #${prod.id} // ${prod.namaBarang}',
                  style:
                      SwissTheme.mono(size: 10, color: SwissColors.adminTextLow)),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogFieldDark('Nama Unit *', titleCtrl),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: status,
                          dropdownColor: SwissColors.adminPanel,
                          style: SwissTheme.sans(size: 12, color: SwissColors.adminTextHigh),
                          decoration: InputDecoration(
                            labelText: 'Status Verifikasi',
                            labelStyle: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow),
                            isDense: true,
                            fillColor: SwissColors.adminElevated,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: SwissColors.adminHairline),
                            ),
                          ),
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
                          child: _dialogFieldDark('Harga Buka (Rp)', priceCtrl,
                              isNumber: true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _dialogFieldDark('Harga Baru (Rp)', origPriceCtrl,
                              isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _dialogFieldDark('Fee Verifikasi (Rp)', feeCtrl,
                              isNumber: true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _dialogFieldDark('Ongkir Kurir (Rp)', ongkirCtrl,
                              isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _dialogFieldDark('Grading Kondisi', condCtrl),
                  const SizedBox(height: 10),
                  _dialogFieldDark('Lokasi Kos', locCtrl),
                  const SizedBox(height: 10),
                  _dialogFieldDark('Titik Temu COD', codCtrl),
                  const SizedBox(height: 10),
                  _dialogFieldDark('Laporan Inspeksi QC Admin', qcCtrl),
                  const SizedBox(height: 10),
                  _dialogFieldDark('Deskripsi Lengkap', descCtrl, maxLines: 2),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: SwissTheme.sans(size: 12, color: SwissColors.adminTextLow)),
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
                backgroundColor: SwissColors.linearLavender,
                foregroundColor: SwissColors.white,
                elevation: 0,
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
                      size: 10, color: SwissColors.linearLavender),
                ),
                Text(
                  'Kurasi Fisik & Manajemen Unit',
                  style: SwissTheme.display(
                    size: 19,
                    color: SwissColors.adminTextHigh,
                  ),
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
                  activeColor: SwissColors.cautionAmber,
                  onTap: () => setState(() {
                    s.adminProductStatusFilter = 'pending';
                  }),
                ),
                _statusPill(
                  label: 'Approved (${s.countApprovedProducts})',
                  active: s.adminProductStatusFilter == 'approved',
                  activeColor: SwissColors.verifiedEmerald,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SwissColors.adminPanel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: SwissColors.adminHairline),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth >= 640;

              final Widget searchField = SizedBox(
                height: 44,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => s.adminProductSearch = v),
                  textAlignVertical: TextAlignVertical.center,
                  style: SwissTheme.sans(size: 12, color: SwissColors.adminTextHigh),
                  decoration: InputDecoration(
                    hintText:
                        'Cari nama barang, penjual, NIM, atau lokasi kos...',
                    hintStyle: SwissTheme.sans(
                        size: 12, color: SwissColors.adminTextLow),
                    isDense: true,
                    filled: true,
                    fillColor: SwissColors.adminElevated,
                    prefixIcon: const Icon(Icons.search,
                        size: 18, color: SwissColors.adminTextLow),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? SizedBox(
                            width: 40,
                            height: 44,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close,
                                  size: 16, color: SwissColors.adminTextLow),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => s.adminProductSearch = '');
                              },
                            ),
                          )
                        : null,
                    suffixIconConstraints:
                        const BoxConstraints(minWidth: 40, minHeight: 44),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: SwissColors.adminHairline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: SwissColors.linearLavender, width: 1.5),
                    ),
                  ),
                ),
              );

              final Widget categoryDropdown = Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: SwissColors.adminElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SwissColors.adminHairline),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: s.adminProductCategoryFilter,
                    dropdownColor: SwissColors.adminPanel,
                    style: SwissTheme.sans(
                        size: 12, color: SwissColors.adminTextHigh),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        size: 18, color: SwissColors.adminTextLow),
                    isExpanded: true,
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
                      DropdownMenuItem(
                          value: 'Masak', child: Text('Alat Masak')),
                      DropdownMenuItem(
                          value: 'Kendaraan', child: Text('Kendaraan & Helm')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => s.adminProductCategoryFilter = v);
                      }
                    },
                  ),
                ),
              );

              final bool hasFilter = s.adminProductSearch.isNotEmpty ||
                  s.adminProductCategoryFilter != 'all';

              final Widget resetBtn = Tooltip(
                message: 'Reset Pencarian & Filter',
                child: InkWell(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() {
                      s.adminProductSearch = '';
                      s.adminProductCategoryFilter = 'all';
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: SwissColors.adminElevated,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: SwissColors.adminHairline),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.refresh,
                        size: 18, color: SwissColors.linearLavender),
                  ),
                ),
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: searchField),
                    const SizedBox(width: 12),
                    SizedBox(width: 200, child: categoryDropdown),
                    if (hasFilter) ...[
                      const SizedBox(width: 10),
                      resetBtn,
                    ],
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  searchField,
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: categoryDropdown),
                      if (hasFilter) ...[
                        const SizedBox(width: 8),
                        resetBtn,
                      ],
                    ],
                  ),
                ],
              );
            },
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
                  color: SwissColors.adminPanel,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SwissColors.adminHairline),
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
                            cacheWidth: 150,
                            cacheHeight: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: SwissColors.adminElevated,
                              child: const Icon(Icons.inventory_2_outlined,
                                  color: SwissColors.adminTextLow),
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
                                          color: SwissColors.linearLavender),
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
                                style: SwissTheme.display(
                                  size: 14,
                                  color: SwissColors.adminTextHigh,
                                ),
                              ),
                              Text(
                                SwissTheme.formatRupiah(prod.harga),
                                style: SwissTheme.display(
                                  size: 14,
                                  color: SwissColors.adminTextHigh,
                                ),
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
                                  backgroundColor: SwissColors.verifiedEmerald,
                                  foregroundColor: SwissColors.white),
                              child: const Text('APPROVE'),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _openEditProductDialog(prod),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: SwissColors.adminHairline),
                              foregroundColor: SwissColors.adminTextHigh,
                            ),
                            child: const Text('EDIT / QC'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => s.deleteProduct(prod.id),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: SwissColors.adminHairline),
                              foregroundColor: SwissColors.dangerRose),
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
              color: SwissColors.adminPanel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SwissColors.adminHairline),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 880),
                child: Theme(
                  data: ThemeData.dark(),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(SwissColors.adminElevated),
                    columns: [
                      DataColumn(
                          label: Text('UNIT & FOTO',
                              style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow))),
                      DataColumn(
                          label: Text('KATEGORI & KONDISI',
                              style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow))),
                      DataColumn(
                          label:
                              Text('PENJUAL', style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow))),
                      DataColumn(
                          label: Text('HARGA & FEE QC',
                              style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow))),
                      DataColumn(
                          label: Text('TITIK COD',
                              style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow))),
                      DataColumn(
                          label:
                              Text('STATUS', style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow))),
                      DataColumn(
                          label:
                              Text('KONTROL', style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow))),
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
                                    cacheWidth: 100,
                                    cacheHeight: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 38,
                                      height: 38,
                                      color: SwissColors.adminElevated,
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
                                            color: SwissColors.adminTextHigh),
                                      ),
                                      Text('ID #${prod.id}',
                                          style: SwissTheme.mono(
                                              size: 10,
                                              color: SwissColors.adminTextLow)),
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
                                          color: SwissColors.linearLavender)),
                                  Text(
                                    prod.kondisi,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: SwissTheme.sans(
                                        size: 11, color: SwissColors.adminTextLow),
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
                                        size: 12,
                                        weight: FontWeight.w600,
                                        color: SwissColors.adminTextHigh)),
                                Text('NIM: ${prod.nimPenjual}',
                                    style: SwissTheme.mono(
                                        size: 10, color: SwissColors.adminTextLow)),
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
                                        color: SwissColors.adminTextHigh)),
                                Text(
                                    'Fee: ${SwissTheme.formatRupiah(prod.biayaVerifikasi)}',
                                    style: SwissTheme.mono(
                                        size: 10,
                                        color: SwissColors.verifiedEmerald)),
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
                                      style: SwissTheme.sans(
                                          size: 11, color: SwissColors.adminTextHigh)),
                                  Text(prod.lokasiKos,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: SwissTheme.sans(
                                          size: 10,
                                          color: SwissColors.adminTextLow)),
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
                                        bg: SwissColors.verifiedEmerald,
                                        fg: SwissColors.white),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                InkWell(
                                  onTap: () => _openEditProductDialog(prod),
                                  child: _actionChip('EDIT',
                                      bg: SwissColors.adminElevated,
                                      fg: SwissColors.adminTextHigh),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => s.deleteProduct(prod.id),
                                  child: _actionChip('DEL',
                                      bg: SwissColors.adminElevated,
                                      fg: SwissColors.dangerRose),
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
          ),
      ],
    );
  }
}

/// ============================================================================
/// TAB 3: VERIFIKASI IDENTITAS MAHASISWA & USER (admin/users.php) - LINEAR DARK
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
        backgroundColor: SwissColors.adminPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: SwissColors.adminHairline),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('VERIFIKASI DOKUMEN KTM / KRS',
                style: SwissTheme.mono(size: 10, color: SwissColors.linearLavender)),
            Text(u.nama,
                style: SwissTheme.display(size: 16, color: SwissColors.adminTextHigh)),
            Text('NIM: ${u.nim} • @${u.username}',
                style: SwissTheme.mono(size: 11, color: SwissColors.adminTextLow)),
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
                  color: SwissColors.adminVoid,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SwissColors.adminHairline),
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
                                size: 9, color: SwissColors.linearLavender),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: SwissColors.verifiedEmerald,
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
                            color: SwissColors.adminElevated,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: SwissColors.adminHairline),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            u.initials,
                            style: SwissTheme.display(
                                size: 18, color: SwissColors.adminTextHigh),
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
                                    size: 14, color: SwissColors.adminTextHigh),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NIM: ${u.nim}',
                                style: SwissTheme.mono(
                                    size: 11, color: SwissColors.verifiedEmerald),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                u.jurusan,
                                style: SwissTheme.sans(
                                    size: 11, color: SwissColors.adminTextLow),
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
                  color: SwissColors.adminElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SwissColors.adminHairline),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PROGRAM STUDI',
                        style: SwissTheme.mono(
                            size: 10, color: SwissColors.adminTextLow)),
                    Flexible(
                      child: Text(u.jurusan,
                          style: SwissTheme.sans(
                              size: 12,
                              weight: FontWeight.w600,
                              color: SwissColors.adminTextHigh)),
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
            child: Text('Tutup', style: SwissTheme.sans(size: 12, color: SwissColors.adminTextLow)),
          ),
          if (u.statusVerifikasi != 'rejected')
            OutlinedButton(
              onPressed: () {
                widget.appState.rejectUserKtm(u.id, 'Foto KTM buram / identitas tidak terbaca jelas.');
                Navigator.pop(ctx);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: SwissColors.rose500,
                side: const BorderSide(color: SwissColors.rose500),
              ),
              child: const Text('Tolak KTM'),
            ),
          if (u.statusVerifikasi != 'approved')
            ElevatedButton(
              onPressed: () {
                widget.appState.approveUserKtm(u.id);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SwissColors.verifiedEmerald,
                foregroundColor: SwissColors.white,
                elevation: 0,
              ),
              child: const Text('Validasi & Setujui KTM'),
            ),
        ],
      ),
    );
  }

  void _openEditUserDialog(UserModel u) {
    final namaCtrl = TextEditingController(text: u.nama);
    final nimCtrl = TextEditingController(text: u.nim);
    final jurusanCtrl = TextEditingController(text: u.jurusan);
    final waCtrl = TextEditingController(text: u.noWa);
    String status = u.statusVerifikasi;
    String role = u.role;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: SwissColors.adminPanel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: SwissColors.adminHairline),
          ),
          title: Text('Edit Data User',
              style: SwissTheme.display(size: 16, color: SwissColors.adminTextHigh)),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogFieldDark('Nama Lengkap *', namaCtrl),
                  const SizedBox(height: 10),
                  _dialogFieldDark('NIM Mahasiswa *', nimCtrl),
                  const SizedBox(height: 10),
                  _dialogFieldDark('Program Studi *', jurusanCtrl),
                  const SizedBox(height: 10),
                  _dialogFieldDark('Nomor WhatsApp *', waCtrl),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: status,
                          dropdownColor: SwissColors.adminPanel,
                          style: SwissTheme.sans(size: 12, color: SwissColors.adminTextHigh),
                          decoration: InputDecoration(
                            labelText: 'Status KTM',
                            labelStyle: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow),
                            isDense: true,
                            fillColor: SwissColors.adminElevated,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: SwissColors.adminHairline),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'approved', child: Text('Approved')),
                            DropdownMenuItem(value: 'pending', child: Text('Pending')),
                            DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                          ],
                          onChanged: (v) {
                            if (v != null) setDialogState(() => status = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: role,
                          dropdownColor: SwissColors.adminPanel,
                          style: SwissTheme.sans(size: 12, color: SwissColors.adminTextHigh),
                          decoration: InputDecoration(
                            labelText: 'Role',
                            labelStyle: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow),
                            isDense: true,
                            fillColor: SwissColors.adminElevated,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: SwissColors.adminHairline),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'mahasiswa', child: Text('Mahasiswa')),
                            DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          ],
                          onChanged: (v) {
                            if (v != null) setDialogState(() => role = v);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: SwissTheme.sans(size: 12, color: SwissColors.adminTextLow)),
            ),
            ElevatedButton(
              onPressed: () {
                widget.appState.adminUpdateUser(
                  id: u.id,
                  nama: namaCtrl.text,
                  jurusan: jurusanCtrl.text,
                  whatsapp: waCtrl.text,
                  statusVerifikasi: status,
                  role: role,
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SwissColors.linearLavender,
                foregroundColor: SwissColors.white,
                elevation: 0,
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _openResetPassDialog(UserModel u) {
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SwissColors.adminPanel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: SwissColors.adminHairline),
        ),
        title: Text('Reset Password User',
            style: SwissTheme.display(size: 16, color: SwissColors.adminTextHigh)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reset password untuk @${u.username} (${u.nama}):',
                style: SwissTheme.sans(size: 12, color: SwissColors.adminTextLow)),
            const SizedBox(height: 10),
            _dialogFieldDark('Password Baru', passCtrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: SwissTheme.sans(size: 12, color: SwissColors.adminTextLow)),
          ),
          ElevatedButton(
            onPressed: () {
              if (passCtrl.text.isNotEmpty) {
                widget.appState.adminResetUserPassword(u.id, passCtrl.text);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SwissColors.linearLavender,
              foregroundColor: SwissColors.white,
            ),
            child: const Text('Update Password'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.appState;
    final users = s.filteredAdminUsers;
    final bool isDesktop = widget.width >= 1024;

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
                Text('VERIFIKASI MAHASISWA',
                    style: SwissTheme.mono(
                        size: 10, color: SwissColors.linearLavender)),
                Text('Validasi KTM & Manajemen Akun',
                    style: SwissTheme.display(
                      size: 19,
                      color: SwissColors.adminTextHigh,
                    )),
              ],
            ),
            Wrap(
              spacing: 6,
              children: [
                _statusPill(
                  label: 'Semua (${s.countAllUsers})',
                  active: s.adminUserStatusFilter == 'all',
                  onTap: () => setState(() => s.adminUserStatusFilter = 'all'),
                ),
                _statusPill(
                  label: 'Pending (${s.countPendingUsers})',
                  active: s.adminUserStatusFilter == 'pending',
                  activeColor: SwissColors.cautionAmber,
                  onTap: () => setState(() => s.adminUserStatusFilter = 'pending'),
                ),
                _statusPill(
                  label: 'Approved (${s.countApprovedUsers})',
                  active: s.adminUserStatusFilter == 'approved',
                  activeColor: SwissColors.verifiedEmerald,
                  onTap: () => setState(() => s.adminUserStatusFilter = 'approved'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SwissColors.adminPanel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: SwissColors.adminHairline),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => s.adminUserSearch = v),
                    textAlignVertical: TextAlignVertical.center,
                    style: SwissTheme.sans(
                        size: 12, color: SwissColors.adminTextHigh),
                    decoration: InputDecoration(
                      hintText:
                          'Cari nama mahasiswa, username, NIM, atau jurusan...',
                      hintStyle: SwissTheme.sans(
                          size: 12, color: SwissColors.adminTextLow),
                      isDense: true,
                      filled: true,
                      fillColor: SwissColors.adminElevated,
                      prefixIcon: const Icon(Icons.search,
                          size: 18, color: SwissColors.adminTextLow),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 44, minHeight: 44),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? SizedBox(
                              width: 40,
                              height: 44,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close,
                                    size: 16, color: SwissColors.adminTextLow),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => s.adminUserSearch = '');
                                },
                              ),
                            )
                          : null,
                      suffixIconConstraints:
                          const BoxConstraints(minWidth: 40, minHeight: 44),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: SwissColors.adminHairline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: SwissColors.adminHairline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: SwissColors.linearLavender, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
              if (s.adminUserSearch.isNotEmpty) ...[
                const SizedBox(width: 10),
                Tooltip(
                  message: 'Reset Pencarian',
                  child: InkWell(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => s.adminUserSearch = '');
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: SwissColors.adminElevated,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: SwissColors.adminHairline),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.refresh,
                          size: 18, color: SwissColors.linearLavender),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (isDesktop)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: SwissColors.adminPanel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SwissColors.adminHairline),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 880),
                child: Theme(
                  data: ThemeData.dark(),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(SwissColors.adminElevated),
                    columns: [
                      DataColumn(label: Text('MAHASISWA', style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow))),
                      DataColumn(label: Text('NIM', style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow))),
                      DataColumn(label: Text('PROGRAM STUDI', style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow))),
                      DataColumn(label: Text('WHATSAPP', style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow))),
                      DataColumn(label: Text('STATUS KTM', style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow))),
                      DataColumn(label: Text('AKSI VALIDASI', style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow))),
                    ],
                    rows: users.map((u) {
                      final bool isAdminAcc = u.role == 'admin';
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: SwissColors.adminElevated,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: SwissColors.adminHairline),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    u.initials,
                                    style: SwissTheme.mono(
                                        size: 11,
                                        weight: FontWeight.w700,
                                        color: SwissColors.linearLavender),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(u.nama,
                                        style: SwissTheme.sans(
                                            size: 12,
                                            weight: FontWeight.w600,
                                            color: SwissColors.adminTextHigh)),
                                    Text('@${u.username}',
                                        style: SwissTheme.mono(
                                            size: 10, color: SwissColors.adminTextLow)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(u.nim, style: SwissTheme.mono(size: 11, color: SwissColors.adminTextHigh))),
                          DataCell(Text(u.jurusan, style: SwissTheme.sans(size: 12, color: SwissColors.adminTextLow))),
                          DataCell(Text(u.noWa, style: SwissTheme.mono(size: 11, color: SwissColors.adminTextLow))),
                          DataCell(_statusBadge(u.statusVerifikasi)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => _openKtmInspectionModal(u),
                                  child: _actionChip('KTM',
                                      bg: SwissColors.adminElevated,
                                      fg: SwissColors.linearLavender),
                                ),
                                const SizedBox(width: 6),
                                if (u.statusVerifikasi != 'approved') ...[
                                  InkWell(
                                    onTap: () => s.approveUserKtm(u.id),
                                    child: _actionChip('APPROVE',
                                        bg: SwissColors.verifiedEmerald,
                                        fg: SwissColors.white),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                InkWell(
                                  onTap: () => _openEditUserDialog(u),
                                  child: _actionChip('EDIT',
                                      bg: SwissColors.adminElevated,
                                      fg: SwissColors.adminTextHigh),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => _openResetPassDialog(u),
                                  child: _actionChip('KEY',
                                      bg: SwissColors.adminElevated,
                                      fg: SwissColors.adminTextLow),
                                ),
                                if (!isAdminAcc) ...[
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => s.adminDeleteUser(u.id),
                                    child: _actionChip('DEL',
                                        bg: SwissColors.adminElevated,
                                        fg: SwissColors.dangerRose),
                                  ),
                                ],
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
          )
        else
          Column(
            children: users.map((u) {
              final bool isAdminAcc = u.role == 'admin';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SwissColors.adminPanel,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SwissColors.adminHairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            u.nama,
                            style: SwissTheme.display(
                              size: 14,
                              color: SwissColors.adminTextHigh,
                            ),
                          ),
                        ),
                        _statusBadge(u.statusVerifikasi),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NIM: ${u.nim} • @${u.username}',
                      style: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow),
                    ),
                    Text(
                      u.jurusan,
                      style: SwissTheme.sans(size: 11, color: SwissColors.adminTextLow),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        InkWell(
                          onTap: () => _openKtmInspectionModal(u),
                          child: _actionChip('INSPEKSI KTM',
                              bg: SwissColors.adminElevated,
                              fg: SwissColors.linearLavender),
                        ),
                        if (u.statusVerifikasi != 'approved')
                          InkWell(
                            onTap: () => s.approveUserKtm(u.id),
                            child: _actionChip('APPROVE',
                                bg: SwissColors.verifiedEmerald,
                                fg: SwissColors.white),
                          ),
                        InkWell(
                          onTap: () => _openEditUserDialog(u),
                          child: _actionChip('EDIT',
                              bg: SwissColors.adminElevated,
                              fg: SwissColors.adminTextHigh),
                        ),
                        InkWell(
                          onTap: () => _openResetPassDialog(u),
                          child: _actionChip('KEY',
                              bg: SwissColors.adminElevated,
                              fg: SwissColors.adminTextLow),
                        ),
                        if (!isAdminAcc)
                          InkWell(
                            onTap: () => s.adminDeleteUser(u.id),
                            child: _actionChip('DEL',
                                bg: SwissColors.adminElevated,
                                fg: SwissColors.dangerRose),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

/// ============================================================================
/// TAB 4: ZONA TITIK TEMU COD RESMI (admin/cod_spots.php) - LINEAR DARK MODE
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
          backgroundColor: SwissColors.adminPanel,
          shape:
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: SwissColors.adminHairline),
              ),
          title: Text(
            existing == null ? 'Tambah Titik COD Baru' : 'Edit Titik Temu COD',
            style: SwissTheme.display(
              size: 16,
              color: SwissColors.adminTextHigh,
            ),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogFieldDark('Nama Titik COD *', nameCtrl),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: kategori,
                          dropdownColor: SwissColors.adminPanel,
                          style: SwissTheme.sans(size: 12, color: SwissColors.adminTextHigh),
                          decoration: InputDecoration(
                            labelText: 'Kategori Zona',
                            labelStyle: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow),
                            isDense: true,
                            fillColor: SwissColors.adminElevated,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: SwissColors.adminHairline),
                            ),
                          ),
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
                          dropdownColor: SwissColors.adminPanel,
                          style: SwissTheme.sans(size: 12, color: SwissColors.adminTextHigh),
                          decoration: InputDecoration(
                            labelText: 'Status',
                            labelStyle: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow),
                            isDense: true,
                            fillColor: SwissColors.adminElevated,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: SwissColors.adminHairline),
                            ),
                          ),
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
                      Expanded(child: _dialogFieldDark('Latitude *', latCtrl)),
                      const SizedBox(width: 10),
                      Expanded(child: _dialogFieldDark('Longitude *', lngCtrl)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _dialogFieldDark('Deskripsi & Patokan *', descCtrl, maxLines: 2),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Batal', style: SwissTheme.sans(size: 12, color: SwissColors.adminTextLow))),
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
                backgroundColor: SwissColors.linearLavender,
                foregroundColor: SwissColors.white,
                elevation: 0,
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
                        size: 10, color: SwissColors.linearLavender)),
                Text('Konfigurasi Titik Temu COD Resmi',
                    style: SwissTheme.display(
                      size: 19,
                      color: SwissColors.adminTextHigh,
                    )),
              ],
            ),
            ElevatedButton(
              onPressed: () => _openSpotDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: SwissColors.linearLavender,
                foregroundColor: SwissColors.white,
                elevation: 0,
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
            color: SwissColors.adminPanel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SwissColors.adminHairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PROTOKOL FLEKSIBILITAS ZONA COD',
                  style: SwissTheme.mono(
                      size: 10,
                      weight: FontWeight.w700,
                      color: SwissColors.linearLavender)),
              const SizedBox(height: 4),
              Text(
                'Apabila rektorat atau satpam kampus membatasi transaksi di dalam gedung akademik (UCC / Fasilkom), klik status titik Dalam Kampus untuk menonaktifkannya dan aktifkan titik Perimeter Luar / Area Publik 24 Jam agar serah terima tetap aman.',
                style: SwissTheme.sans(size: 11, color: SwissColors.adminTextLow),
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
              color: SwissColors.adminPanel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? SwissColors.adminHairline : const Color(0xFF1E212E),
              ),
            ),
            child: widget.width >= 640
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(spot.namaTitik,
                                    style: SwissTheme.display(
                                      size: 14,
                                      color: SwissColors.adminTextHigh,
                                    )),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: SwissColors.adminElevated,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: SwissColors.adminHairline),
                                  ),
                                  child: Text(spot.categoryTag,
                                      style: SwissTheme.mono(
                                          size: 9,
                                          color: SwissColors.linearLavender)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(spot.deskripsi,
                                style: SwissTheme.sans(
                                    size: 12, color: SwissColors.adminTextLow)),
                            const SizedBox(height: 4),
                            Text(
                              'GPS: ${spot.latitude.toStringAsFixed(4)}, ${spot.longitude.toStringAsFixed(4)}',
                              style: SwissTheme.mono(
                                  size: 10, color: SwissColors.adminTextLow),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => s.toggleCodSpotStatus(spot.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0x1F059669)
                                    : SwissColors.adminElevated,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isActive
                                      ? const Color(0x33059669)
                                      : SwissColors.adminHairline,
                                ),
                              ),
                              child: Text(
                                '● ${spot.status.toUpperCase()}',
                                style: SwissTheme.mono(
                                  size: 10,
                                  weight: FontWeight.w700,
                                  color: isActive
                                      ? SwissColors.verifiedEmerald
                                      : SwissColors.adminTextLow,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _openSpotDialog(existing: spot),
                            child: _actionChip('EDIT',
                                bg: SwissColors.adminElevated,
                                fg: SwissColors.adminTextHigh),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => s.deleteCodSpot(spot.id),
                            child: _actionChip('DEL',
                                bg: SwissColors.adminElevated,
                                fg: SwissColors.dangerRose),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(spot.namaTitik,
                                style: SwissTheme.display(
                                  size: 14,
                                  color: SwissColors.adminTextHigh,
                                )),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: SwissColors.adminElevated,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: SwissColors.adminHairline),
                            ),
                            child: Text(spot.categoryTag,
                                style: SwissTheme.mono(
                                    size: 9,
                                    color: SwissColors.linearLavender)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(spot.deskripsi,
                          style: SwissTheme.sans(
                              size: 12, color: SwissColors.adminTextLow)),
                      const SizedBox(height: 4),
                      Text(
                        'GPS: ${spot.latitude.toStringAsFixed(4)}, ${spot.longitude.toStringAsFixed(4)}',
                        style: SwissTheme.mono(
                            size: 10, color: SwissColors.adminTextLow),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => s.toggleCodSpotStatus(spot.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0x1F059669)
                                    : SwissColors.adminElevated,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isActive
                                      ? const Color(0x33059669)
                                      : SwissColors.adminHairline,
                                ),
                              ),
                              child: Text(
                                '● ${spot.status.toUpperCase()}',
                                style: SwissTheme.mono(
                                  size: 10,
                                  weight: FontWeight.w700,
                                  color: isActive
                                      ? SwissColors.verifiedEmerald
                                      : SwissColors.adminTextLow,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () => _openSpotDialog(existing: spot),
                            child: _actionChip('EDIT',
                                bg: SwissColors.adminElevated,
                                fg: SwissColors.adminTextHigh),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => s.deleteCodSpot(spot.id),
                            child: _actionChip('DEL',
                                bg: SwissColors.adminElevated,
                                fg: SwissColors.dangerRose),
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
  late final TextEditingController _noWaCtrl;
  late final TextEditingController _bannerCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.appState.platformSettings;
    _feeStandarCtrl =
        TextEditingController(text: p['fee_verifikasi_standar'] ?? '5000');
    _feeKecilCtrl =
        TextEditingController(text: p['fee_verifikasi_kecil'] ?? '3000');
    _feeBesarCtrl =
        TextEditingController(text: p['fee_verifikasi_besar'] ?? '10000');
    _ongkirDasarCtrl =
        TextEditingController(text: p['ongkir_dasar'] ?? p['ongkir_dasar_kurir'] ?? '10000');
    _ongkirKmCtrl = TextEditingController(text: p['ongkir_per_km'] ?? '2500');
    _noWaCtrl = TextEditingController(text: p['no_wa_admin'] ?? '6281234567899');
    _bannerCtrl = TextEditingController(
        text: p['banner_pengumuman'] ??
            'Platform Bursa Inventaris & Perabotan Kos Mahasiswa CampusTrade (Penghubung Mahasiswa Kampus Target).');
  }

  @override
  void dispose() {
    _feeStandarCtrl.dispose();
    _feeKecilCtrl.dispose();
    _feeBesarCtrl.dispose();
    _ongkirDasarCtrl.dispose();
    _ongkirKmCtrl.dispose();
    _noWaCtrl.dispose();
    _bannerCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() {
    widget.appState.updatePlatformSettings({
      'fee_verifikasi_standar': _feeStandarCtrl.text.trim(),
      'fee_verifikasi_kecil': _feeKecilCtrl.text.trim(),
      'fee_verifikasi_besar': _feeBesarCtrl.text.trim(),
      'ongkir_dasar': _ongkirDasarCtrl.text.trim(),
      'ongkir_dasar_kurir': _ongkirDasarCtrl.text.trim(),
      'ongkir_per_km': _ongkirKmCtrl.text.trim(),
      'no_wa_admin': _noWaCtrl.text.trim(),
      'banner_pengumuman': _bannerCtrl.text.trim(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Konfigurasi tarif fee, ongkir & parameter berhasil diperbarui.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = widget.width >= 1024;

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
                Text('PARAMETER EKOSISTEM',
                    style: SwissTheme.mono(
                        size: 10, color: SwissColors.linearLavender)),
                Text('Tarif Fee Rekber, Ongkir & Banner',
                    style: SwissTheme.display(
                      size: 19,
                      color: SwissColors.adminTextHigh,
                    )),
              ],
            ),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: SwissColors.linearLavender,
                foregroundColor: SwissColors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Simpan Parameter',
                  style: SwissTheme.sans(
                      size: 12,
                      weight: FontWeight.w600,
                      color: SwissColors.white)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildFeeConfigCard()),
                  const SizedBox(width: 20),
                  Expanded(child: _buildCourierAndGeneralCard()),
                ],
              )
            : Column(
                children: [
                  _buildFeeConfigCard(),
                  const SizedBox(height: 16),
                  _buildCourierAndGeneralCard(),
                ],
              ),
      ],
    );
  }

  Widget _buildFeeConfigCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SwissColors.adminPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SwissColors.adminHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: SwissColors.adminElevated,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('ESCROW FEE',
                    style: SwissTheme.mono(
                        size: 9,
                        weight: FontWeight.w700,
                        color: SwissColors.linearLavender)),
              ),
              const SizedBox(width: 8),
              Text('Tarif Jasa Verifikasi Fisik & Rekber',
                  style: SwissTheme.display(
                    size: 14,
                    color: SwissColors.adminTextHigh,
                  )),
            ],
          ),
          const SizedBox(height: 14),
          _dialogFieldDark(
              'Fee Standar (Elektronik / Umum) (Rp) *', _feeStandarCtrl,
              isNumber: true),
          const SizedBox(height: 12),
          _dialogFieldDark(
              'Fee Kecil (Buku, Modul, Aksesoris) (Rp) *', _feeKecilCtrl,
              isNumber: true),
          const SizedBox(height: 12),
          _dialogFieldDark(
              'Fee Besar (Perabotan, Kasur, Lemari) (Rp) *', _feeBesarCtrl,
              isNumber: true),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SwissColors.adminElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SwissColors.adminHairline),
            ),
            child: Text(
              'Fee ini otomatis dipotong dari dana transaksi saat pembeli membayar via Rekber Admin, menjadi pendapatan resmi pengelola platform CampusTrade.',
              style: SwissTheme.sans(size: 11, color: SwissColors.adminTextLow),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourierAndGeneralCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SwissColors.adminPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SwissColors.adminHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: SwissColors.adminElevated,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('LOGISTIK & UMUM',
                    style: SwissTheme.mono(
                        size: 9,
                        weight: FontWeight.w700,
                        color: SwissColors.verifiedEmerald)),
              ),
              const SizedBox(width: 8),
              Text('Tarif Kurir & Gateway Admin',
                  style: SwissTheme.display(
                    size: 14,
                    color: SwissColors.adminTextHigh,
                  )),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _dialogFieldDark(
                    'Ongkir Dasar Kurir (Rp) *', _ongkirDasarCtrl,
                    isNumber: true),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dialogFieldDark('Tarif per KM (Rp) *', _ongkirKmCtrl,
                    isNumber: true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _dialogFieldDark('WhatsApp Gateway Admin (Contoh: 62812...) *', _noWaCtrl),
          const SizedBox(height: 12),
          _dialogFieldDark('Teks Banner Pengumuman Beranda *', _bannerCtrl,
              maxLines: 2),
        ],
      ),
    );
  }
}

/// ============================================================================
/// REUSABLE HELPER WIDGETS & PAINTERS (LINEAR DARK MODE)
/// ============================================================================

Widget _statusPill({
  required String label,
  required bool active,
  required VoidCallback onTap,
  Color activeColor = SwissColors.linearLavender,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(999),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? activeColor.withValues(alpha: 0.18) : SwissColors.adminElevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? activeColor : SwissColors.adminHairline,
        ),
      ),
      child: Text(
        label,
        style: SwissTheme.mono(
          size: 10,
          weight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? activeColor : SwissColors.adminTextLow,
        ),
      ),
    ),
  );
}

Widget _statusBadge(String status) {
  final Color bg = status == 'approved'
      ? const Color(0x1F059669)
      : status == 'pending'
          ? const Color(0x26D97706)
          : const Color(0x26E11D48);
  final Color fg = status == 'approved'
      ? SwissColors.verifiedEmerald
      : status == 'pending'
          ? const Color(0xFFFBBF24)
          : SwissColors.dangerRose;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: fg.withValues(alpha: 0.3)),
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
      color: bg ?? SwissColors.adminElevated,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: SwissColors.adminHairline),
    ),
    child: Text(
      label,
      style: SwissTheme.mono(
        size: 10,
        weight: FontWeight.w700,
        color: fg ?? SwissColors.adminTextHigh,
      ),
    ),
  );
}

Widget _dialogFieldDark(
  String label,
  TextEditingController ctrl, {
  bool isNumber = false,
  int maxLines = 1,
}) {
  return TextField(
    controller: ctrl,
    maxLines: maxLines,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    style: SwissTheme.sans(size: 12, color: SwissColors.adminTextHigh),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: SwissTheme.mono(size: 10, color: SwissColors.adminTextLow),
      isDense: true,
      filled: true,
      fillColor: SwissColors.adminElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: SwissColors.adminHairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: SwissColors.adminHairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: SwissColors.linearLavender),
      ),
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

    // Dark Grid lines
    final Paint gridPaint = Paint()
      ..color = SwissColors.adminHairline
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final double y = topPad + (chartH * (i / 4));
      canvas.drawLine(Offset(leftPad, y), Offset(size.width - rightPad, y),
          gridPaint);
    }

    // Points
    final List<Offset> points = [];
    final double stepX = chartW / (series.length - 1);
    for (int i = 0; i < series.length; i++) {
      final double x = leftPad + (i * stepX);
      final double normY = (series[i].value / maxY).clamp(0.0, 1.0);
      final double y = topPad + chartH - (normY * chartH);
      points.add(Offset(x, y));
    }

    // Shaded Area Under Curve with Lavender
    final Path areaPath = Path()..moveTo(points.first.dx, topPad + chartH);
    for (final p in points) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath.lineTo(points.last.dx, topPad + chartH);
    areaPath.close();

    final Paint areaPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x335E6AD2), Color(0x005E6AD2)],
      ).createShader(Rect.fromLTWH(leftPad, topPad, chartW, chartH));
    canvas.drawPath(areaPath, areaPaint);

    // Line Path with Linear Lavender
    final Path linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    final Paint linePaint = Paint()
      ..color = SwissColors.linearLavender
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(linePath, linePaint);

    // Data dots
    final Paint dotPaint = Paint()..color = SwissColors.white;
    final Paint dotBorder = Paint()
      ..color = SwissColors.linearLavender
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final p in points) {
      canvas.drawCircle(p, 3.5, dotPaint);
      canvas.drawCircle(p, 3.5, dotBorder);
    }

    // Bottom X-Axis Labels
    final TextPainter tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < series.length; i++) {
      tp.text = TextSpan(
        text: series[i].key,
        style: const TextStyle(
          color: SwissColors.adminTextLow,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      );
      tp.layout();
      final double x = points[i].dx - (tp.width / 2);
      tp.paint(canvas, Offset(x, size.height - bottomPad + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
        ..strokeWidth = 22;
      canvas.drawArc(rect, startAngle, sweep, false, segPaint);
      startAngle += sweep;
    }

    // Inner Hole background
    final Paint innerHole = Paint()..color = SwissColors.adminPanel;
    canvas.drawCircle(center, radius - 12, innerHole);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
