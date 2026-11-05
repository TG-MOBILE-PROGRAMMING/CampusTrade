import 'dart:math' as math;

/// ============================================================================
/// DATA MODELS: CAMPUSTRADE UPI YPTK PADANG (SCHEMA.SQL PARITY)
/// ============================================================================

class UserModel {
  final int id;
  final String username;
  final String nim;
  String nama;
  String jurusan;
  String whatsapp;
  String password;
  String? fotoKtm;
  String statusVerifikasi; // 'pending', 'approved', 'rejected'
  String? catatanPenolakan;
  DateTime? verifiedAt;
  int? verifiedBy;
  String role; // 'mahasiswa', 'admin'
  DateTime lastActivity;
  DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.nim,
    required this.nama,
    required this.jurusan,
    required this.whatsapp,
    required this.password,
    this.fotoKtm,
    this.statusVerifikasi = 'pending',
    this.catatanPenolakan,
    this.verifiedAt,
    this.verifiedBy,
    this.role = 'mahasiswa',
    DateTime? lastActivity,
    DateTime? createdAt,
  })  : lastActivity = lastActivity ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  String get initials {
    final String clean = nama.trim();
    if (clean.isEmpty) return 'CT';
    if (clean.length == 1) return clean.toUpperCase();
    return clean.substring(0, 2).toUpperCase();
  }
}

class CodSpotModel {
  final int id;
  String namaTitik;
  String kategori; // 'dalam_kampus', 'luar_kampus', 'publik_terpantau'
  String deskripsi;
  double latitude;
  double longitude;
  String status; // 'aktif', 'nonaktif'
  DateTime createdAt;

  CodSpotModel({
    required this.id,
    required this.namaTitik,
    this.kategori = 'dalam_kampus',
    required this.deskripsi,
    required this.latitude,
    required this.longitude,
    this.status = 'aktif',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get categoryTag {
    switch (kategori) {
      case 'dalam_kampus':
        return 'ZONA KAMPUS';
      case 'luar_kampus':
        return 'PERIMETER GERBANG';
      case 'publik_terpantau':
        return 'AREA PUBLIK 24J';
      default:
        return kategori.toUpperCase();
    }
  }
}

class ProductModel {
  final int id;
  final int? userId;
  String namaBarang;
  String kategori;
  int harga;
  int hargaAsli;
  String kondisi;
  String lokasiKos;
  String titikCod;
  double latitude;
  double longitude;
  String metodePengiriman; // 'semua', 'jemput_mandiri', 'kurir_admin'
  int biayaVerifikasi;
  int biayaOngkir;
  String catatanQcAdmin;
  String deskripsi;
  String foto;
  String statusVerifikasi; // 'pending', 'approved', 'rejected'
  DateTime createdAt;

  // Joined Seller Details
  String namaPenjual;
  String nimPenjual;
  String jurusanPenjual;
  String waPenjual;

  static const double campusLat = -0.9575;
  static const double campusLng = 100.3972;

  ProductModel({
    required this.id,
    this.userId,
    required this.namaBarang,
    required this.kategori,
    required this.harga,
    required this.hargaAsli,
    required this.kondisi,
    required this.lokasiKos,
    required this.titikCod,
    this.latitude = campusLat,
    this.longitude = campusLng,
    this.metodePengiriman = 'semua',
    this.biayaVerifikasi = 5000,
    this.biayaOngkir = 10000,
    this.catatanQcAdmin = 'Lolos kurasi fisik tim admin.',
    required this.deskripsi,
    required this.foto,
    this.statusVerifikasi = 'approved',
    DateTime? createdAt,
    this.namaPenjual = 'Mahasiswa UPI YPTK',
    this.nimPenjual = '-',
    this.jurusanPenjual = 'Teknik Informatika (Fasilkom)',
    this.waPenjual = '6281234567890',
  }) : createdAt = createdAt ?? DateTime.now();

  int get effectiveOriginalPrice =>
      hargaAsli > harga ? hargaAsli : (harga * 1.5).round();

  int get savingsPercent {
    final int orig = effectiveOriginalPrice;
    if (orig <= 0) return 0;
    return ((1.0 - (harga / orig)) * 100).round().clamp(1, 95);
  }

  double get distanceToCampusKm =>
      calculateDistance(campusLat, campusLng, latitude, longitude);

  /// Rumus Haversine dalam Kilometer (sama persis dengan Product::calculateDistance di PHP)
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371.0;
    final double dLat = _deg2rad(lat2 - lat1);
    final double dLon = _deg2rad(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double dist = earthRadius * c;
    return (dist * 100).roundToDouble() / 100.0;
  }

  static double _deg2rad(double deg) => deg * (math.pi / 180.0);
}

class OrderModel {
  final int id;
  final int productId;
  final int? buyerId;
  final int? sellerId;
  final String metodePenyerahan; // 'jemput_admin', 'antar_admin'
  final String titikCod;
  final String? alamatAntar;
  final int hargaBarang;
  final int feeAdmin;
  final int ongkir;
  final int totalBayar;
  String status; // 'diajukan', 'verifikasi_admin', 'dijadwalkan', 'selesai', 'dibatalkan'
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.productId,
    this.buyerId,
    this.sellerId,
    required this.metodePenyerahan,
    required this.titikCod,
    this.alamatAntar,
    required this.hargaBarang,
    required this.feeAdmin,
    required this.ongkir,
    required this.totalBayar,
    this.status = 'diajukan',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class VisitorLogModel {
  final int id;
  final String ipAddress;
  final String pageUrl;
  final int? userId;
  final DateTime visitedAt;

  VisitorLogModel({
    required this.id,
    required this.ipAddress,
    required this.pageUrl,
    this.userId,
    required this.visitedAt,
  });
}
