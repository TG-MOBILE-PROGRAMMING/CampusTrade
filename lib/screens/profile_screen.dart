import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/swiss_theme.dart';
import '../widgets/campus_empty_state.dart';
import '../widgets/campus_motion.dart';
import 'auth_screen.dart';
import 'orders_screen.dart';
import 'product_detail_screen.dart';
import 'sell_product_screen.dart';

/// ============================================================================
/// PROFILE SCREEN (DEDICATED FULL-PAGE USER & ACCOUNT MANAGEMENT)
/// [Anti-Slop UI Architecture & Zero-Modal Native Flow]
/// ============================================================================
class ProfileScreen extends StatefulWidget {
  final CampusTradeState appState;
  final VoidCallback? onBackToCatalog;

  const ProfileScreen({
    super.key,
    required this.appState,
    this.onBackToCatalog,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 960;
    final UserModel? user = widget.appState.currentUser;

    return Scaffold(
      backgroundColor: SwissColors.canvasWarm,
      appBar: AppBar(
        backgroundColor: SwissColors.canvasPure,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Akun & Profil Mahasiswa',
          style: SwissTheme.display(size: 16, weight: FontWeight.w700),
        ),
        leading: widget.onBackToCatalog != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: SwissColors.inkPrimary),
                onPressed: widget.onBackToCatalog,
              )
            : (Navigator.of(context).canPop()
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: SwissColors.inkPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? (screenWidth - 760) / 2 : 16,
            vertical: 16,
          ),
          child: user == null ? _buildGuestView() : _buildLoggedInView(user),
        ),
      ),
    );
  }

  Widget _buildGuestView() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: SwissColors.canvasPure,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SwissColors.borderHairline),
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: SwissColors.rauschCoral.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, size: 36, color: SwissColors.rauschCoral),
              ),
              const SizedBox(height: 16),
              Text(
                'Selamat Datang di CampusTrade',
                style: SwissTheme.display(size: 18, weight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Platform bursa inventaris & perabotan kos mahasiswa terverifikasi (Zona Target: UPI YPTK Padang & Lubeg). Masuk akun untuk pasang iklan barang, menyimpan wishlist, atau pesan barang.',
                textAlign: TextAlign.center,
                style: SwissTheme.sans(size: 12, height: 1.4, color: SwissColors.inkSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AuthScreen(appState: widget.appState),
                    ),
                  );
                },
                icon: const Icon(Icons.login, size: 18),
                label: const Text('Masuk atau Daftar Akun Mahasiswa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SwissColors.rauschCoral,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildTrustHighlights(),
      ],
    );
  }

  Widget _buildLoggedInView(UserModel user) {
    final bool isAdmin = user.role == 'admin';
    final List<ProductModel> myProducts = widget.appState.products.where((p) => p.userId == user.id).toList();
    final List<ProductModel> myWishlist = widget.appState.products
        .where((p) => widget.appState.isFavorite(p.id) && p.statusVerifikasi == 'approved')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Profile Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: SwissColors.canvasPure,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SwissColors.borderHairline),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isAdmin
                    ? SwissColors.escrowIndigo
                    : SwissColors.rauschCoral.withValues(alpha: 0.15),
                child: Text(
                  user.initials,
                  style: SwissTheme.mono(
                    size: 18,
                    weight: FontWeight.w800,
                    color: isAdmin ? Colors.white : SwissColors.rauschCoral,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.nama,
                            style: SwissTheme.display(size: 15, weight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (user.statusVerifikasi == 'approved')
                          const Icon(Icons.verified, size: 15, color: SwissColors.verifiedEmerald),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username} • NIM: ${user.nim}',
                      style: SwissTheme.sans(size: 11, color: SwissColors.inkSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.jurusan,
                      style: SwissTheme.sans(size: 11, color: SwissColors.inkMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Verification Status Badge
        _buildVerificationStatusCard(user),
        const SizedBox(height: 16),

        // Admin CMS Shortcut if user is Admin
        if (isAdmin) ...[
          InkWell(
            onTap: () {
              widget.appState.navigateTo('admin');
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SwissColors.adminVoid,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SwissColors.escrowIndigo),
              ),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings, color: SwissColors.linearLavender, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Portal Admin CMS CampusTrade',
                          style: SwissTheme.display(size: 13, weight: FontWeight.w700, color: Colors.white),
                        ),
                        Text(
                          'Kelola kurasi barang, verifikasi KTM mahasiswa, dan monitoring transaksi rekber.',
                          style: SwissTheme.sans(size: 11, color: SwissColors.adminTextLow),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white54),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Menu List
        _buildMenuCard(
          title: 'AKTIVITAS SAYA',
          items: [
            _MenuItem(
              icon: Icons.add_circle_outline,
              label: 'Pasang Iklan Barang Kos',
              subtitle: 'Jual perabotan atau inventaris kos Anda',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SellProductScreen(appState: widget.appState)),
                );
              },
            ),
            _MenuItem(
              icon: Icons.receipt_long_outlined,
              label: 'Pesanan & Transaksi (${widget.appState.orders.length})',
              subtitle: 'Pantau status pesanan dan serah terima COD',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => OrdersScreen(appState: widget.appState)),
                );
              },
            ),
            _MenuItem(
              icon: Icons.favorite_border,
              label: 'Barang Disimpan / Wishlist (${myWishlist.length})',
              subtitle: 'Daftar inventaris kos yang Anda minati',
              onTap: () => _showWishlistSheet(myWishlist),
            ),
            _MenuItem(
              icon: Icons.storefront_outlined,
              label: 'Iklan Barang Saya (${myProducts.length})',
              subtitle: 'Kelola status kurasi dan barang jualan',
              onTap: () => _showMyListingsSheet(myProducts),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildMenuCard(
          title: 'BANTUAN & PUSAT INFORMASI',
          items: [
            _MenuItem(
              icon: Icons.support_agent_outlined,
              label: 'Kontak Tim Admin WhatsApp',
              subtitle: 'Bantuan verifikasi barang atau kendala COD',
              onTap: () {
                final phone = widget.appState.platformSettings['no_wa_admin'] ?? '6281234567899';
                Clipboard.setData(ClipboardData(text: 'https://wa.me/$phone'));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Nomor WhatsApp Admin ($phone) telah disalin ke Clipboard!')),
                );
              },
            ),
            _MenuItem(
              icon: Icons.logout,
              label: 'Keluar dari Akun',
              subtitle: 'Akhiri sesi aktif Anda di perangkat ini',
              isDestructive: true,
              onTap: () {
                widget.appState.logout();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Anda telah keluar dari akun.')),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildVerificationStatusCard(UserModel user) {
    Color bg;
    Color border;
    IconData icon;
    String title;
    String desc;

    if (user.statusVerifikasi == 'approved') {
      bg = const Color(0xFFF0FDF4);
      border = SwissColors.verifiedEmerald;
      icon = Icons.verified_user;
      title = 'Akun Mahasiswa Terverifikasi Resmi';
      desc = 'Identitas KTM/KRS Anda telah disetujui. Anda bebas pasang iklan dan transaksi dengan rekber.';
    } else if (user.statusVerifikasi == 'pending') {
      bg = const Color(0xFFFFFBEB);
      border = SwissColors.cautionAmber;
      icon = Icons.hourglass_top_outlined;
      title = 'Menunggu Verifikasi KTM oleh Tim CampusTrade';
      desc = 'Tim Verifikator CampusTrade sedang memvalidasi data kartu mahasiswa target kampus Anda dalam 1x24 jam.';
    } else {
      bg = const Color(0xFFFFF1F2);
      border = SwissColors.dangerRose;
      icon = Icons.cancel_outlined;
      title = 'Verifikasi KTM Ditolak';
      desc = user.catatanPenolakan ?? 'Foto kartu identitas kurang jelas. Hubungi admin untuk validasi ulang.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: border, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: SwissTheme.display(size: 12, weight: FontWeight.w700, color: border)),
                const SizedBox(height: 2),
                Text(desc, style: SwissTheme.sans(size: 11, height: 1.35, color: SwissColors.inkPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({required String title, required List<_MenuItem> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: SwissColors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SwissColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(title, style: SwissTheme.mono(size: 10, weight: FontWeight.w700, color: SwissColors.inkMuted)),
          ),
          ...items.map((item) => _buildMenuItemTile(item)),
        ],
      ),
    );
  }

  Widget _buildMenuItemTile(_MenuItem item) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: item.isDestructive
              ? const Color(0xFFFFE4E6)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          item.icon,
          size: 18,
          color: item.isDestructive ? SwissColors.dangerRose : SwissColors.inkPrimary,
        ),
      ),
      title: Text(
        item.label,
        style: SwissTheme.display(
          size: 13,
          weight: FontWeight.w600,
          color: item.isDestructive ? SwissColors.dangerRose : SwissColors.inkPrimary,
        ),
      ),
      subtitle: Text(
        item.subtitle,
        style: SwissTheme.sans(size: 11, color: SwissColors.inkSecondary),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: SwissColors.inkMuted),
      onTap: item.onTap,
    );
  }

  void _showWishlistSheet(List<ProductModel> wishlist) {
    Navigator.of(context).push(
      buildCampusRoute(
        Scaffold(
          backgroundColor: CampusColors.canvasPaper,
          appBar: AppBar(
            backgroundColor: CampusColors.surfacePure,
            elevation: 0,
            title: Text(
              'Wishlist Saya (${wishlist.length})',
              style: SwissTheme.display(size: 16),
            ),
          ),
          body: wishlist.isEmpty
              ? Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: CampusEmptyState(
                        kind: CampusEmptyKind.wishlistEmpty,
                        title: 'Wishlist kamu masih kosong',
                        subtitle:
                            'Ketuk ikon hati di barang kos incaranmu biar tidak keburu diangkut mahasiswa lain.',
                        primaryActionLabel: 'Cari Barang di Katalog',
                        onPrimaryAction: () {
                          Navigator.of(context).pop();
                          widget.onBackToCatalog?.call();
                        },
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: wishlist.length,
                  itemBuilder: (ctx, i) {
                    final p = wishlist[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                          p.namaBarang,
                          style: SwissTheme.display(size: 13.5, weight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${p.kategori} • ${SwissTheme.formatRupiah(p.harga)}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () {
                          Navigator.of(context).push(
                            buildCampusRoute(
                              ProductDetailScreen(
                                appState: widget.appState,
                                product: p,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _showMyListingsSheet(List<ProductModel> listings) {
    Navigator.of(context).push(
      buildCampusRoute(
        Scaffold(
          backgroundColor: CampusColors.canvasPaper,
          appBar: AppBar(
            backgroundColor: CampusColors.surfacePure,
            elevation: 0,
            title: Text(
              'Iklan Barang Saya (${listings.length})',
              style: SwissTheme.display(size: 16),
            ),
          ),
          body: listings.isEmpty
              ? Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: CampusEmptyState(
                        kind: CampusEmptyKind.listingsEmpty,
                        title: 'Kamar kos masih rapi, belum ada iklan',
                        subtitle:
                            'Punya kasur, meja lipat, atau buku semester lalu yang menganggur? Oper ke mahasiswa baru biar jadi uang jajan.',
                        primaryActionLabel: 'Pasang Iklan Pertama',
                        onPrimaryAction: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            buildCampusRoute(
                              SellProductScreen(appState: widget.appState),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listings.length,
                  itemBuilder: (ctx, i) {
                    final p = listings[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                          p.namaBarang,
                          style: SwissTheme.display(size: 13.5, weight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${p.kategori} • ${SwissTheme.formatRupiah(p.harga)} • Status: ${p.statusVerifikasi.toUpperCase()}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () {
                          Navigator.of(context).push(
                            buildCampusRoute(
                              ProductDetailScreen(
                                appState: widget.appState,
                                product: p,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildTrustHighlights() {
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
            'KEUNTUNGAN MAHASISWA CAMPUSTRADE',
            style: SwissTheme.mono(size: 10, weight: FontWeight.w700, color: SwissColors.inkMuted),
          ),
          const SizedBox(height: 12),
          _buildTrustRow(Icons.verified, '100% Terverifikasi KTM', 'Penjual & pembeli terikat identitas mahasiswa kampus target.'),
          _buildTrustRow(Icons.security, 'Rekber Anti-Penipuan', 'Uang aman di escrow tim perantara sampai barang dicek fisik.'),
          _buildTrustRow(Icons.place, 'Bebas COD di Sekitar Kampus', 'Titik temu terpantau aman satpam di gerbang & lobi.'),
          _buildTrustRow(Icons.delivery_dining, 'Kurir Kos Lubeg', 'Bantuan antar untuk perabotan berat (kasur/meja).', isLast: true),
        ],
      ),
    );
  }

  Widget _buildTrustRow(IconData icon, String title, String desc, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: SwissColors.verifiedEmerald),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: SwissTheme.display(size: 12, weight: FontWeight.w700)),
                Text(desc, style: SwissTheme.sans(size: 11, color: SwissColors.inkSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });
}
