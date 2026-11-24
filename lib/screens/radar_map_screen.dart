import 'package:flutter/material.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/swiss_theme.dart';
import '../widgets/geospatial_map_widget.dart';
import 'product_detail_screen.dart';

/// ============================================================================
/// RADAR MAP SCREEN (GEOSPATIAL CAMPUS COD RADAR & KOS FINDER)
/// [Anti-Slop UI Architecture & Zero-Modal Native Flow]
/// ============================================================================
class RadarMapScreen extends StatefulWidget {
  final CampusTradeState appState;
  final VoidCallback? onBackToCatalog;

  const RadarMapScreen({
    super.key,
    required this.appState,
    this.onBackToCatalog,
  });

  @override
  State<RadarMapScreen> createState() => _RadarMapScreenState();
}

class _RadarMapScreenState extends State<RadarMapScreen> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 960;
    final String currentRadius = widget.appState.selectedRadiusKm;
    final List<ProductModel> nearbyProducts = widget.appState.filteredCatalogProducts;
    final List<CodSpotModel> spots = widget.appState.activeCodSpots;

    return Scaffold(
      backgroundColor: SwissColors.canvasWarm,
      appBar: AppBar(
        backgroundColor: SwissColors.canvasPure,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Radar Kos & Titik COD Kampus',
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
            horizontal: isDesktop ? (screenWidth - 840) / 2 : 16,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radius Filter Header
              _buildRadiusSelector(currentRadius),
              const SizedBox(height: 16),

              // Interactive Radar Map
              GeospatialRadarMap(
                height: isDesktop ? 380 : 280,
                codSpots: spots,
                products: widget.appState.products.where((p) => p.statusVerifikasi == 'approved').toList(),
                selectedRadiusKm: currentRadius,
                onSelectProduct: (product) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        appState: widget.appState,
                        product: product,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Official Safe COD Points List
              _buildCodSpotsList(spots),
              const SizedBox(height: 20),

              // Nearby Products in this Zone
              Text(
                'BARANG KOS DI AREA INI (${nearbyProducts.length} UNIT)',
                style: SwissTheme.mono(size: 11, weight: FontWeight.w700, color: SwissColors.inkPrimary),
              ),
              const SizedBox(height: 12),

              if (nearbyProducts.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: SwissColors.canvasPure,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SwissColors.borderHairline),
                  ),
                  child: Center(
                    child: Text(
                      'Tidak ada barang dalam radius ini. Coba perbesar filter radius ke 2 KM.',
                      style: SwissTheme.sans(size: 12, color: SwissColors.inkSecondary),
                    ),
                  ),
                ),
              ] else ...[
                ...nearbyProducts.take(8).map((p) => _buildProductRow(p)),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadiusSelector(String currentRadius) {
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
              const Icon(Icons.radar, color: SwissColors.rauschCoral, size: 18),
              const SizedBox(width: 8),
              Text(
                'FILTER JARAK DARI KAMPUS UPI YPTK',
                style: SwissTheme.mono(size: 10, weight: FontWeight.w700, color: SwissColors.inkPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRadiusChip('Semua Radius', 'all', currentRadius),
                _buildRadiusChip('< 500m (Dekat)', '0.5', currentRadius),
                _buildRadiusChip('< 1 KM (Kos Sekitar)', '1', currentRadius),
                _buildRadiusChip('< 2 KM (Zona Lubeg)', '2', currentRadius),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusChip(String label, String value, String current) {
    final bool active = current == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: active,
        label: Text(label),
        labelStyle: SwissTheme.sans(
          size: 11,
          weight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? Colors.white : SwissColors.inkPrimary,
        ),
        backgroundColor: const Color(0xFFF1F5F9),
        selectedColor: SwissColors.rauschCoral,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (_) {
          widget.appState.setRadiusFilter(value);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildCodSpotsList(List<CodSpotModel> spots) {
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
          Row(
            children: [
              const Icon(Icons.security, size: 16, color: SwissColors.verifiedEmerald),
              const SizedBox(width: 6),
              Text(
                'TITIK COD AMAN MAHASISWA (ZONA KAMPUS TARGET: UPI YPTK)',
                style: SwissTheme.mono(size: 10, weight: FontWeight.w700, color: SwissColors.verifiedEmerald),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...spots.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.place, size: 16, color: SwissColors.rauschCoral),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.namaTitik, style: SwissTheme.display(size: 12, weight: FontWeight.w700)),
                          Text(s.deskripsi, style: SwissTheme.sans(size: 11, color: SwissColors.inkSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildProductRow(ProductModel p) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              appState: widget.appState,
              product: p,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SwissColors.canvasPure,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SwissColors.borderHairline),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_2_outlined, color: SwissColors.rauschCoral, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.namaBarang,
                    style: SwissTheme.display(size: 12, weight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${p.lokasiKos} • ${p.distanceToCampusKm} km dari kampus',
                    style: SwissTheme.sans(size: 11, color: SwissColors.inkSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              SwissTheme.formatRupiah(p.harga),
              style: SwissTheme.display(size: 12, weight: FontWeight.w800, color: SwissColors.rauschCoral),
            ),
          ],
        ),
      ),
    );
  }
}
