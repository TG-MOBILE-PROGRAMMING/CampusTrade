import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/swiss_theme.dart';

/// ============================================================================
/// ORDERS SCREEN (DEDICATED FULL-PAGE TRANSACTION & ESCROW TRACKER)
/// [Anti-Slop UI Architecture & Zero-Modal Native Flow]
/// ============================================================================
class OrdersScreen extends StatefulWidget {
  final CampusTradeState appState;
  final VoidCallback? onBackToCatalog;

  const OrdersScreen({
    super.key,
    required this.appState,
    this.onBackToCatalog,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedStatusFilter = 'all'; // 'all', 'diajukan', 'dijadwalkan', 'selesai'

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 960;

    final List<OrderModel> orders = widget.appState.orders.where((o) {
      if (_selectedStatusFilter == 'all') return true;
      return o.status == _selectedStatusFilter;
    }).toList();

    return Scaffold(
      backgroundColor: SwissColors.canvasWarm,
      appBar: AppBar(
        backgroundColor: SwissColors.canvasPure,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Pesanan & Transaksi Saya',
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
        child: Column(
          children: [
            // Filter Bar
            Container(
              color: SwissColors.canvasPure,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Semua Status', 'all'),
                    _buildFilterChip('Menunggu Verifikasi', 'diajukan'),
                    _buildFilterChip('Dijadwalkan COD', 'dijadwalkan'),
                    _buildFilterChip('Selesai', 'selesai'),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: SwissColors.borderHairline),

            // Order List or Empty State
            Expanded(
              child: orders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? (screenWidth - 760) / 2 : 16,
                        vertical: 16,
                      ),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(orders[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final bool isSelected = _selectedStatusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: SwissTheme.sans(
          size: 11,
          weight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : SwissColors.inkPrimary,
        ),
        backgroundColor: const Color(0xFFF1F5F9),
        selectedColor: SwissColors.rauschCoral,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (_) => setState(() => _selectedStatusFilter = value),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_outlined, size: 36, color: SwissColors.inkMuted),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Transaksi Aktif',
              style: SwissTheme.display(size: 16, weight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Pesanan barang kos yang Anda beli atau ajukan rekber admin akan muncul di sini secara real-time.',
              textAlign: TextAlign.center,
              style: SwissTheme.sans(size: 12, color: SwissColors.inkSecondary),
            ),
            const SizedBox(height: 20),
            if (widget.onBackToCatalog != null)
              ElevatedButton.icon(
                onPressed: widget.onBackToCatalog,
                icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                label: const Text('Mulai Belanja di Katalog'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SwissColors.rauschCoral,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    // Find matching product
    ProductModel? product;
    for (final p in widget.appState.products) {
      if (p.id == order.productId) {
        product = p;
        break;
      }
    }

    final String title = product?.namaBarang ?? 'Barang Inventaris Mahasiswa #${order.productId}';
    final String seller = product?.namaPenjual ?? 'Penjual Mahasiswa UPI YPTK';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SwissColors.canvasPure,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SwissColors.borderHairline),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ORDER #${order.id}',
                      style: SwissTheme.mono(size: 10, weight: FontWeight.w700, color: SwissColors.inkPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                    style: SwissTheme.sans(size: 11, color: SwissColors.inkMuted),
                  ),
                ],
              ),
              _buildStatusBadge(order.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: SwissColors.borderHairline),
          const SizedBox(height: 12),

          // Product Summary Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inventory_2_outlined, color: SwissColors.rauschCoral, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: SwissTheme.display(size: 13, weight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Penjual: $seller',
                      style: SwissTheme.sans(size: 11, color: SwissColors.inkSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.metodePenyerahan == 'antar_admin'
                          ? '🛵 Diantar Kurir Admin ke Kos Mahasiswa'
                          : '📍 COD di Kampus (${order.titikCod})',
                      style: SwissTheme.sans(size: 11, weight: FontWeight.w600, color: SwissColors.escrowIndigo),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Total Price and Action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Transaksi:', style: SwissTheme.sans(size: 11)),
                Text(
                  SwissTheme.formatRupiah(order.totalBayar),
                  style: SwissTheme.display(size: 13, weight: FontWeight.w800, color: SwissColors.rauschCoral),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final String receipt = 'CampusTrade Order #${order.id}\n'
                        'Barang: $title\n'
                        'Total: ${SwissTheme.formatRupiah(order.totalBayar)}\n'
                        'Status: ${order.status.toUpperCase()}';
                    Clipboard.setData(ClipboardData(text: receipt));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rincian transaksi disalin ke Clipboard!')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 14),
                  label: const Text('Salin Rincian'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SwissColors.inkPrimary,
                    side: const BorderSide(color: SwissColors.borderHairline),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final String msg = 'Halo Admin CampusTrade, saya ingin konfirmasi status pesanan Order #${order.id} ($title).';
                    Clipboard.setData(ClipboardData(text: msg));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pesan konfirmasi siap diteruskan ke WhatsApp Admin!')),
                    );
                  },
                  icon: const Icon(Icons.chat_outlined, size: 14),
                  label: const Text('Chat Admin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SwissColors.verifiedEmerald,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case 'diajukan':
        bg = const Color(0xFFFEF3C7);
        fg = SwissColors.cautionAmber;
        text = 'Menunggu Verifikasi';
        break;
      case 'verifikasi_admin':
        bg = const Color(0xFFE0E7FF);
        fg = SwissColors.escrowIndigo;
        text = 'Dicek Admin';
        break;
      case 'dijadwalkan':
        bg = const Color(0xFFD1FAE5);
        fg = SwissColors.verifiedEmerald;
        text = 'Dijadwalkan COD';
        break;
      case 'selesai':
        bg = const Color(0xFFECFDF5);
        fg = SwissColors.verifiedEmerald;
        text = 'Selesai';
        break;
      case 'dibatalkan':
      default:
        bg = const Color(0xFFFFE4E6);
        fg = SwissColors.dangerRose;
        text = 'Dibatalkan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: SwissTheme.mono(size: 10, weight: FontWeight.w700, color: fg)),
    );
  }
}
