import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/swiss_theme.dart';

/// ============================================================================
/// GEOSPATIAL INTERACTIVE RADAR MAP, MINI ROUTE MAP, & PINPOINT PICKER
/// ============================================================================
/// Dirender secara native dengan CustomPainter + GestureDetector/InteractiveViewer
/// sehingga bebas error jaringan tile server dan berjalan 60fps di semua platform.

class GeospatialRadarMap extends StatefulWidget {
  final List<CodSpotModel> codSpots;
  final List<ProductModel> products;
  final String selectedRadiusKm;
  final ValueChanged<ProductModel> onSelectProduct;
  final double height;

  const GeospatialRadarMap({
    super.key,
    required this.codSpots,
    required this.products,
    required this.selectedRadiusKm,
    required this.onSelectProduct,
    this.height = 300,
  });

  @override
  State<GeospatialRadarMap> createState() => _GeospatialRadarMapState();
}

class _GeospatialRadarMapState extends State<GeospatialRadarMap> {
  CodSpotModel? _selectedSpot;
  ProductModel? _hoveredProduct;
  double _zoom = 1.0;

  // Bounding box around UPI YPTK Lubuk Begalung (-0.9575, 100.3972)
  static const double _centerLat = -0.9575;
  static const double _centerLng = 100.3972;
  static const double _baseSpan = 0.011; // ~1.2 km span at zoom 1.0

  Offset _latLngToPixel(double lat, double lng, Size size) {
    final double span = _baseSpan / _zoom;
    final double normX = ((lng - _centerLng) / span) + 0.5;
    final double normY = 0.5 - ((lat - _centerLat) / span);
    return Offset(
      (normX * size.width).clamp(16.0, size.width - 16.0),
      (normY * size.height).clamp(16.0, size.height - 16.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double radiusKm = widget.selectedRadiusKm == 'all'
        ? 2.5
        : (double.tryParse(widget.selectedRadiusKm) ?? 1.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SwissColors.borderHairline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final Size mapSize =
              Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            children: [
              // 1. Base Map Layer (Roads, River, Campus Blocks, Radius Circle)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSpot = null;
                      _hoveredProduct = null;
                    });
                  },
                  child: CustomPaint(
                    painter: _LubegCampusMapPainter(
                      radiusKm: radiusKm,
                      zoom: _zoom,
                    ),
                  ),
                ),
              ),

              // 2. COD Spot Markers
              ...widget.codSpots.map((spot) {
                final Offset pos =
                    _latLngToPixel(spot.latitude, spot.longitude, mapSize);
                final IconData spotIcon = spot.kategori == 'dalam_kampus'
                    ? Icons.account_balance
                    : spot.kategori == 'luar_kampus'
                        ? Icons.location_on
                        : Icons.storefront;
                return Positioned(
                  left: pos.dx - 16,
                  top: pos.dy - 16,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSpot = spot;
                        _hoveredProduct = null;
                      });
                    },
                    child: Tooltip(
                      message: '${spot.namaTitik} (${spot.categoryTag})',
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: SwissColors.indigo600,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: SwissColors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x3309090B),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          spotIcon,
                          size: 15,
                          color: SwissColors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // 3. Product Price Pins
              ...widget.products.map((prod) {
                final Offset pos =
                    _latLngToPixel(prod.latitude, prod.longitude, mapSize);
                final bool isSelected = _hoveredProduct?.id == prod.id;
                return Positioned(
                  left: pos.dx - 32,
                  top: pos.dy - 12,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _hoveredProduct = prod;
                        _selectedSpot = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? SwissColors.rauschCoral
                            : SwissColors.uberBlack,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? SwissColors.white
                              : const Color(0xFF333333),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'Rp ${(prod.harga / 1000).round()}k',
                        style: SwissTheme.mono(
                          size: 10,
                          weight: FontWeight.w700,
                          color: SwissColors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // 4. Zoom Controls (Top Left — Uber High Contrast)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: SwissColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SwissColors.uberBlack, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => setState(
                            () => _zoom = (_zoom + 0.25).clamp(0.6, 2.5)),
                        child: const Padding(
                          padding: EdgeInsets.all(7),
                          child: Icon(Icons.add,
                              size: 16, color: SwissColors.uberBlack),
                        ),
                      ),
                      Container(
                          height: 1, width: 26, color: const Color(0xFFE5E7EB)),
                      InkWell(
                        onTap: () => setState(
                            () => _zoom = (_zoom - 0.25).clamp(0.6, 2.5)),
                        child: const Padding(
                          padding: EdgeInsets.all(7),
                          child: Icon(Icons.remove,
                              size: 16, color: SwissColors.uberBlack),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Coordinate Telemetry Badge (Top Right — Uber High Contrast)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: SwissColors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: SwissColors.uberBlack, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
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
                      const SizedBox(width: 6),
                      Text(
                        constraints.maxWidth < 360
                            ? 'UPI YPTK LUBEG'
                            : 'UPI YPTK LUBEG (-0.9575, 100.3972)',
                        style: SwissTheme.mono(
                          size: 9,
                          weight: FontWeight.w700,
                          color: SwissColors.uberBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 6. Interactive Popup Card for Selected COD Spot
              if (_selectedSpot != null)
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: SwissColors.canvasPure,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: SwissColors.borderHairline),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            )
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedSpot!.namaTitik,
                                    style: SwissTheme.display(
                                      size: 13,
                                      color: SwissColors.inkPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _selectedSpot!.deskripsi,
                                    style: SwissTheme.sans(
                                      size: 11,
                                      color: SwissColors.inkSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                          color: const Color(0xFFA7F3D0)),
                                    ),
                                    child: Text(
                                      '✓ ${_selectedSpot!.categoryTag}',
                                      style: SwissTheme.mono(
                                        size: 9,
                                        weight: FontWeight.w700,
                                        color: SwissColors.verifiedEmerald,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _selectedSpot = null),
                              icon: const Icon(Icons.close, size: 14),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // 7. Interactive Popup Card for Selected Product Pin
              if (_hoveredProduct != null)
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: SwissColors.canvasPure,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: SwissColors.borderHairline),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _hoveredProduct!.foto,
                                width: 52,
                                height: 52,
                                cacheWidth: 120,
                                cacheHeight: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 52,
                                  height: 52,
                                  color: SwissColors.canvasWarm,
                                  child: const Icon(Icons.inventory_2_outlined,
                                      size: 20, color: SwissColors.inkMuted),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _hoveredProduct!.kategori.toUpperCase(),
                                    style: SwissTheme.mono(
                                      size: 9,
                                      weight: FontWeight.w700,
                                      color: SwissColors.rauschCoral,
                                    ),
                                  ),
                                  Text(
                                    _hoveredProduct!.namaBarang,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: SwissTheme.display(
                                      size: 12,
                                      color: SwissColors.inkPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${SwissTheme.formatRupiah(_hoveredProduct!.harga)} • ${_hoveredProduct!.distanceToCampusKm} KM',
                                    style: SwissTheme.mono(
                                      size: 10,
                                      weight: FontWeight.w700,
                                      color: SwissColors.inkPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () =>
                                  widget.onSelectProduct(_hoveredProduct!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SwissColors.rauschCoral,
                                foregroundColor: SwissColors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: Text(
                                'Detail ->',
                                style: SwissTheme.mono(
                                  size: 9,
                                  weight: FontWeight.w700,
                                  color: SwissColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // 8. OpenStreetMap Attribution Footer
              Positioned(
                bottom: 4,
                right: 6,
                child: Text(
                  '© OpenStreetMap • CampusTrade UPI',
                  style: SwissTheme.mono(size: 8, color: SwissColors.inkSecondary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Mini Route Map for Product Detail Modal (Kos Penjual <-> Titik COD Kampus)
class DetailRouteMiniMap extends StatelessWidget {
  final ProductModel product;
  const DetailRouteMiniMap({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SwissColors.borderHairline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DetailRoutePainter(),
            ),
          ),
          // Seller Kos Pin (Uber Pickup Style)
          Positioned(
            left: 16,
            top: 28,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: (MediaQuery.of(context).size.width * 0.6).clamp(140.0, 260.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: SwissColors.uberBlack,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: SwissColors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3D000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: SwissColors.rauschCoral,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Kos: ${product.lokasiKos}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SwissTheme.sans(
                        size: 10,
                        weight: FontWeight.w700,
                        color: SwissColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // COD Spot Pin (Uber Dropoff Style)
          Positioned(
            right: 16,
            bottom: 28,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: (MediaQuery.of(context).size.width * 0.6).clamp(140.0, 260.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: SwissColors.uberBlack,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: SwissColors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3D000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: SwissColors.escrowIndigo,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'COD: ${product.titikCod}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SwissTheme.sans(
                        size: 10,
                        weight: FontWeight.w700,
                        color: SwissColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive Pinpoint Coordinate Picker Map for Sell Modal
class PinpointPickerMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final void Function(double lat, double lng) onLocationChanged;

  const PinpointPickerMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onLocationChanged,
  });

  static const double _centerLat = -0.9575;
  static const double _centerLng = 100.3972;
  static const double _span = 0.010;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SwissColors.borderHairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final Size size = Size(constraints.maxWidth, constraints.maxHeight);
          final double normX = ((longitude - _centerLng) / _span) + 0.5;
          final double normY = 0.5 - ((latitude - _centerLat) / _span);
          final double px = (normX * size.width).clamp(24.0, size.width - 24.0);
          final double py =
              (normY * size.height).clamp(20.0, size.height - 20.0);

          void updateFromLocal(Offset local) {
            final double nx =
                (local.dx / size.width).clamp(0.05, 0.95) - 0.5;
            final double ny =
                0.5 - (local.dy / size.height).clamp(0.05, 0.95);
            final double newLat = _centerLat + (ny * _span);
            final double newLng = _centerLng + (nx * _span);
            onLocationChanged(newLat, newLng);
          }

          return GestureDetector(
            onTapDown: (details) => updateFromLocal(details.localPosition),
            onPanUpdate: (details) => updateFromLocal(details.localPosition),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _LubegCampusMapPainter(radiusKm: 1.0, zoom: 1.0),
                  ),
                ),
                Positioned(
                  left: (px - 56).clamp(4.0, size.width - 116.0),
                  top: (py - 14).clamp(4.0, size.height - 30.0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: SwissColors.uberBlack,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: SwissColors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3309090B),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, size: 12, color: SwissColors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Lokasi Kos Anda',
                          style: SwissTheme.sans(
                            size: 10,
                            weight: FontWeight.w700,
                            color: SwissColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  left: 8,
                  right: 8,
                  child: Text(
                    'Ketuk atau geser pin untuk menyematkan koordinat kos',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SwissTheme.mono(size: 8, color: SwissColors.inkSecondary),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LubegCampusMapPainter extends CustomPainter {
  final double radiusKm;
  final double zoom;

  _LubegCampusMapPainter({required this.radiusKm, required this.zoom});

  @override
  void paint(Canvas canvas, Size size) {
    // Background land
    final Paint landPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRect(Offset.zero & size, landPaint);

    // Subtle green campus & park zones
    final Paint parkPaint = Paint()..color = const Color(0xFFE2F2EA);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.5),
          width: size.width * 0.36,
          height: size.height * 0.42,
        ),
        const Radius.circular(12),
      ),
      parkPaint,
    );

    // Grid streets
    final Paint minorRoad = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.5;
    for (double x = 0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minorRoad);
    }
    for (double y = 0; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minorRoad);
    }

    // Main highway: Jl. Raya Lubuk Begalung
    final Paint mainRoadBorder = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    final Paint mainRoadFill = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;

    final Path roadPath = Path()
      ..moveTo(0, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.45,
        size.width,
        size.height * 0.28,
      );
    canvas.drawPath(roadPath, mainRoadBorder);
    canvas.drawPath(roadPath, mainRoadFill);

    // Radius circle around UPI YPTK Campus Center
    final Offset center = Offset(size.width * 0.5, size.height * 0.5);
    final double radiusPx =
        (size.shortestSide * 0.28 * (radiusKm / 1.5) * zoom)
            .clamp(35.0, size.longestSide * 0.48);

    final Paint circleFill = Paint()
      ..color = const Color(0x186366F1)
      ..style = PaintingStyle.fill;
    final Paint circleStroke = Paint()
      ..color = SwissColors.indigo600
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radiusPx, circleFill);
    canvas.drawCircle(center, radiusPx, circleStroke);
  }

  @override
  bool shouldRepaint(covariant _LubegCampusMapPainter oldDelegate) =>
      oldDelegate.radiusKm != radiusKm || oldDelegate.zoom != zoom;
}

class _DetailRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final _LubegCampusMapPainter basePainter =
        _LubegCampusMapPainter(radiusKm: 1.0, zoom: 1.0);
    basePainter.paint(canvas, size);

    // Draw dashed route polyline from top-left (Kos) to bottom-right (COD Spot)
    final Offset start = Offset(75, 50);
    final Offset end = Offset(size.width - 80, size.height - 45);
    final Paint dashPaint = Paint()
      ..color = SwissColors.indigo600
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const int segments = 18;
    for (int i = 0; i < segments; i += 2) {
      final double t1 = i / segments;
      final double t2 = (i + 1) / segments;
      final Offset p1 = Offset.lerp(start, end, t1)!;
      final Offset p2 = Offset.lerp(start, end, t2)!;
      canvas.drawLine(p1, p2, dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
