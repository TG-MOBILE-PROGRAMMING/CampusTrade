import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// ============================================================================
/// STATE MANAGEMENT: CAMPUSTRADE UPI YPTK PADANG
/// ============================================================================
/// Menyimpan seluruh state aplikasi (Users, Products, COD Spots, Orders,
/// Visitor Logs, Platform Settings, Filter Katalog, Sesi Login, & Flash Message).
class CampusTradeState extends ChangeNotifier {
  // Referensi koordinat pusat kampus UPI YPTK Lubuk Begalung
  static const double campusLat = -0.9575;
  static const double campusLng = 100.3972;

  // Navigasi Layar Utama ('catalog', 'admin', 'not_found')
  String currentRoute = 'catalog';
  // Sub-halaman Admin CMS ('dashboard', 'products', 'users', 'cod_spots', 'settings')
  String currentAdminTab = 'dashboard';

  // Flash Notifications
  String? flashSuccess;
  String? flashWarning;
  String? flashError;

  // Current Logged-in User
  UserModel? currentUser;

  // Brute-force login rate limiter: identifier -> list of failed timestamps
  final Map<String, List<DateTime>> _failedLogins = {};

  // Filter Katalog Publik
  String selectedCategory = 'Semua';
  String searchKeyword = '';
  String selectedRadiusKm = 'all'; // 'all', '0.5', '1', '2'
  String sortOption = 'terbaru'; // 'terbaru', 'termurah', 'termahal', 'terdekat'
  final Set<int> favoriteProductIds = {1, 3};
  bool isMainMapExpanded = false;

  // Filter Admin CMS - Products
  String adminProductStatusFilter = 'all';
  String adminProductCategoryFilter = 'all';
  String adminProductSearch = '';

  // Filter Admin CMS - Users
  String adminUserStatusFilter = 'all';
  String adminUserRoleFilter = 'all';
  String adminUserSearch = '';

  // Filter Admin CMS - COD Spots
  String adminCodSpotSearch = '';

  // Platform Settings (Seed Data dari schema.sql)
  final Map<String, String> platformSettings = {
    'fee_verifikasi_standar': '5000',
    'fee_verifikasi_kecil': '3000',
    'fee_verifikasi_besar': '10000',
    'ongkir_dasar': '10000',
    'ongkir_per_km': '2500',
    'max_radius_km': '5.0',
    'biaya_handling_berat': '10000',
    'nama_bank': 'Bank Nagari / BSI / DANA',
    'nomor_rekening': '2100.0210.88888-9',
    'atas_nama_rekening': 'CampusTrade Indonesia',
    'no_wa_admin': '6281234567899',
    'banner_pengumuman':
        'CampusTrade — Platform bursa inventaris kos mahasiswa terpercaya (Zona Target: Kampus UPI YPTK Padang & Lubeg).',
  };

  late final List<UserModel> users;
  late final List<CodSpotModel> codSpots;
  late final List<ProductModel> products;
  late final List<OrderModel> orders;
  late final List<VisitorLogModel> visitorLogs;

  CampusTradeState() {
    _initSeedData();
  }

  void _initSeedData() {
    final DateTime now = DateTime.now();

    // 1. Seed Users (sesuai schema.sql)
    users = [
      UserModel(
        id: 1,
        username: 'iqbal_m',
        nim: '24101152610172',
        nama: 'Muhammad Iqbal Maulana',
        jurusan: 'Teknik Informatika (Fasilkom)',
        whatsapp: '6281234567890',
        password: 'password',
        fotoKtm: 'sample_ktm.jpg',
        statusVerifikasi: 'approved',
        role: 'mahasiswa',
        lastActivity: now,
      ),
      UserModel(
        id: 2,
        username: 'okta_kr',
        nim: '24101152610177',
        nama: 'Okta Khairul Ramadhan',
        jurusan: 'Sistem Informasi (Fasilkom)',
        whatsapp: '6281234567891',
        password: 'password',
        fotoKtm: 'sample_ktm.jpg',
        statusVerifikasi: 'approved',
        role: 'mahasiswa',
        lastActivity: now.subtract(const Duration(minutes: 2)),
      ),
      UserModel(
        id: 3,
        username: 'anggara_y',
        nim: '24101152610222',
        nama: 'Try Anggara Yofa',
        jurusan: 'Teknik Informatika (Fasilkom)',
        whatsapp: '6281234567892',
        password: 'password',
        fotoKtm: 'sample_ktm.jpg',
        statusVerifikasi: 'approved',
        role: 'mahasiswa',
        lastActivity: now.subtract(const Duration(minutes: 5)),
      ),
      UserModel(
        id: 4,
        username: 'admin',
        nim: 'admin',
        nama: 'Tim Verifikator CampusTrade',
        jurusan: 'Operasional Platform CampusTrade',
        whatsapp: '6281234567899',
        password: 'password',
        fotoKtm: null,
        statusVerifikasi: 'approved',
        role: 'admin',
        lastActivity: now,
      ),
      UserModel(
        id: 5,
        username: 'fajar_pratama',
        nim: '24101152610999',
        nama: 'Fajar Pratama',
        jurusan: 'Sistem Informasi (Fasilkom)',
        whatsapp: '6281234567895',
        password: 'password',
        fotoKtm: 'sample_ktm.jpg',
        statusVerifikasi: 'pending',
        role: 'mahasiswa',
        lastActivity: now.subtract(const Duration(minutes: 20)),
      ),
    ];

    // 2. Seed COD Spots (sesuai schema.sql)
    codSpots = [
      CodSpotModel(
        id: 1,
        namaTitik: 'Lobi UPI Convention Center (UCC)',
        kategori: 'dalam_kampus',
        deskripsi:
            'Area terbuka luas, cocok untuk transaksi perabotan kasur atau dispenser.',
        latitude: -0.9570,
        longitude: 100.3975,
        status: 'aktif',
      ),
      CodSpotModel(
        id: 2,
        namaTitik: 'Lobi Gedung B (Fasilkom)',
        kategori: 'dalam_kampus',
        deskripsi:
            'Pusat mahasiswa komputer & elektronik kos, strategis di jam kuliah.',
        latitude: -0.9578,
        longitude: 100.3968,
        status: 'aktif',
      ),
      CodSpotModel(
        id: 3,
        namaTitik: 'Kantin Pusat Kampus UPI YPTK',
        kategori: 'dalam_kampus',
        deskripsi:
            'Titik temu santai dan ramai, ada colokan listrik untuk tes alat elektronik.',
        latitude: -0.9582,
        longitude: 100.3970,
        status: 'aktif',
      ),
      CodSpotModel(
        id: 4,
        namaTitik: 'Lobi Perpustakaan UPI YPTK',
        kategori: 'dalam_kampus',
        deskripsi:
            'Tempat tenang untuk transaksi buku paket kuliah dan diktat.',
        latitude: -0.9572,
        longitude: 100.3965,
        status: 'aktif',
      ),
      CodSpotModel(
        id: 5,
        namaTitik: 'Pos Satpam Gerbang Depan Lubeg',
        kategori: 'luar_kampus',
        deskripsi:
            'Pengawasan perimeter keamanan 24 jam di pinggir jalan raya utama Lubeg.',
        latitude: -0.9565,
        longitude: 100.3980,
        status: 'aktif',
      ),
      CodSpotModel(
        id: 6,
        namaTitik: 'Minimarket 24 Jam Simpang Lubeg',
        kategori: 'publik_terpantau',
        deskripsi:
            'Titik alternatif jika kampus melarang/tutup, terang, CCTV 24 jam & parkir luas.',
        latitude: -0.9550,
        longitude: 100.3995,
        status: 'aktif',
      ),
      CodSpotModel(
        id: 7,
        namaTitik: 'Kafe Mahasiswa Depan Gerbang UPI',
        kategori: 'luar_kampus',
        deskripsi:
            'Titik kumpul santai di luar area akademik, nyaman untuk cek fisik barang.',
        latitude: -0.9562,
        longitude: 100.3985,
        status: 'aktif',
      ),
    ];

    // 3. Seed Products (sesuai schema.sql)
    products = [
      ProductModel(
        id: 1,
        userId: 1,
        namaBarang: 'Kasur Busa Inoac Single 90x200',
        kategori: 'Perabotan Kos',
        harga: 180000,
        hargaAsli: 450000,
        kondisi: 'Mulus Terawat (Baret Halus Normal, Fungsi 100%)',
        lokasiKos: 'Kos Melati (200m dr UCC)',
        titikCod: 'Lobi UPI Convention Center (UCC)',
        latitude: -0.9555,
        longitude: 100.3985,
        metodePengiriman: 'semua',
        biayaVerifikasi: 5000,
        biayaOngkir: 15000,
        catatanQcAdmin:
            'Busa dicek langsung: kepadatan 85%, cover bersih tanpa noda basah, cocok diantar pakai bentor/motor pick-up admin.',
        deskripsi:
            'Dijual karena wisuda di UCC dan siap pulang kampung. Busa masih empuk dan padat, tidak kempes di tengah. Selalu dilapisi sprei anti-air. Bonus sprei motif abu-abu.',
        foto:
            'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=600&auto=format&fit=crop&q=80',
        statusVerifikasi: 'approved',
        namaPenjual: 'Muhammad Iqbal Maulana',
        nimPenjual: '24101152610172',
        jurusanPenjual: 'Teknik Informatika (Fasilkom)',
        waPenjual: '6281234567890',
      ),
      ProductModel(
        id: 2,
        userId: 2,
        namaBarang: 'Dispenser Miyako Panas & Normal',
        kategori: 'Elektronik Kos',
        harga: 85000,
        hargaAsli: 195000,
        kondisi: 'Like New / Sangat Mulus (Pemakaian < 1 Bulan)',
        lokasiKos: 'Wisma Cendrawasih Lubeg',
        titikCod: 'Lobi Gedung B (Fasilkom)',
        latitude: -0.9580,
        longitude: 100.3990,
        metodePengiriman: 'semua',
        biayaVerifikasi: 5000,
        biayaOngkir: 10000,
        catatanQcAdmin:
            'Elemen pemanas dites di colokan kampus: berfungsi normal mendidih dalam 7 menit. Kran rapat tidak bocor.',
        deskripsi:
            'Fungsi pemanas sangat cepat, cocok untuk seduh mi instan dan kopi anak kos. Pemakaian terawat, dibersihkan rutin tiap bulan. Colokan asli.',
        foto:
            'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&auto=format&fit=crop&q=80',
        statusVerifikasi: 'approved',
        namaPenjual: 'Okta Khairul Ramadhan',
        nimPenjual: '24101152610177',
        jurusanPenjual: 'Sistem Informasi (Fasilkom)',
        waPenjual: '6281234567891',
      ),
      ProductModel(
        id: 3,
        userId: 3,
        namaBarang: 'Meja Belajar Kayu Minimalis Lipat',
        kategori: 'Perabotan Kos',
        harga: 95000,
        hargaAsli: 220000,
        kondisi: 'Mulus Terawat (Baret Halus Normal, Fungsi 100%)',
        lokasiKos: 'Gg. Kancil Jl. Raya Lubuk Begalung',
        titikCod: 'Kantin Pusat Kampus UPI YPTK',
        latitude: -0.9590,
        longitude: 100.3960,
        metodePengiriman: 'semua',
        biayaVerifikasi: 5000,
        biayaOngkir: 10000,
        catatanQcAdmin:
            'Engsel lipat kokoh, permukaan meja mulus tanpa goresan dalam.',
        deskripsi:
            'Bisa dilipat rapat saat tidak dipakai sehingga kamar kos sempit tetap lega. Bahan kayu jati belanda tebal, muat laptop 15 inch + tumpukan buku catatan.',
        foto:
            'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=600&auto=format&fit=crop&q=80',
        statusVerifikasi: 'approved',
        namaPenjual: 'Try Anggara Yofa',
        nimPenjual: '24101152610222',
        jurusanPenjual: 'Teknik Informatika (Fasilkom)',
        waPenjual: '6281234567892',
      ),
      ProductModel(
        id: 4,
        userId: 1,
        namaBarang: 'Kipas Angin Berdiri Miyoshi 16 Inch',
        kategori: 'Elektronik Kos',
        harga: 110000,
        hargaAsli: 240000,
        kondisi: 'Layak Pakai (Tanda Pemakaian Wajar, Fungsi Normal)',
        lokasiKos: 'Kos Pondok Gurun Laweh',
        titikCod: 'Pos Satpam Gerbang Depan Lubeg',
        latitude: -0.9540,
        longitude: 100.3950,
        metodePengiriman: 'semua',
        biayaVerifikasi: 5000,
        biayaOngkir: 10000,
        catatanQcAdmin:
            'Motor putaran 3 level kecepatan normal, swing kiri-kanan lancar, kabel utuh tanpa isolasi sambungan.',
        deskripsi:
            'Solusi kamar kos Lubeg yang gerah. 3 tingkat kecepatan angin normal semua. Baling-baling bersih sudah dicuci sebelum dijual.',
        foto:
            'https://images.unsplash.com/photo-1585338107529-13afc5f02586?w=600&auto=format&fit=crop&q=80',
        statusVerifikasi: 'approved',
        namaPenjual: 'Muhammad Iqbal Maulana',
        nimPenjual: '24101152610172',
        jurusanPenjual: 'Teknik Informatika (Fasilkom)',
        waPenjual: '6281234567890',
      ),
      ProductModel(
        id: 5,
        userId: 2,
        namaBarang: 'Buku Paket Algoritma & Diktat C++',
        kategori: 'Buku & Modul Kuliah',
        harga: 45000,
        hargaAsli: 150000,
        kondisi: 'Mulus Terawat (Baret Halus Normal, Fungsi 100%)',
        lokasiKos: 'Kos Dahlia Jl. Aru',
        titikCod: 'Lobi Perpustakaan UPI YPTK',
        latitude: -0.9605,
        longitude: 100.3980,
        metodePengiriman: 'jemput_mandiri',
        biayaVerifikasi: 3000,
        biayaOngkir: 0,
        catatanQcAdmin:
            'Buku disortir: tidak ada halaman robek/hilang, catatan pensil rapi.',
        deskripsi:
            'Sangat direkomendasikan untuk mahasiswa baru Fasilkom semester 1 & 2. Lengkap dengan latihan soal logika pemrograman dari dosen pengampu.',
        foto:
            'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=600&auto=format&fit=crop&q=80',
        statusVerifikasi: 'approved',
        namaPenjual: 'Okta Khairul Ramadhan',
        nimPenjual: '24101152610177',
        jurusanPenjual: 'Sistem Informasi (Fasilkom)',
        waPenjual: '6281234567891',
      ),
      ProductModel(
        id: 6,
        userId: 3,
        namaBarang: 'Rice Cooker Philips Mini 0.8 Liter',
        kategori: 'Peralatan Masak & Makan',
        harga: 130000,
        hargaAsli: 310000,
        kondisi: 'Mulus Terawat (Baret Halus Normal, Fungsi 100%)',
        lokasiKos: 'Kos Pondok Sakinah Pitameh',
        titikCod: 'Lobi Gedung B (Fasilkom)',
        latitude: -0.9620,
        longitude: 100.4000,
        metodePengiriman: 'semua',
        biayaVerifikasi: 5000,
        biayaOngkir: 10000,
        catatanQcAdmin:
            'Thermostat warm & cook berfungsi, panci teflon 90% mulus.',
        deskripsi:
            'Panci tebal ProCeramic, masak nasi hemat daya untuk 1-2 porsi anak kos. Sangat awet, kabel power dan centong asli masih lengkap.',
        foto:
            'https://images.unsplash.com/photo-1544816155-12df9643f363?w=600&auto=format&fit=crop&q=80',
        statusVerifikasi: 'approved',
        namaPenjual: 'Try Anggara Yofa',
        nimPenjual: '24101152610222',
        jurusanPenjual: 'Teknik Informatika (Fasilkom)',
        waPenjual: '6281234567892',
      ),
      ProductModel(
        id: 7,
        userId: 1,
        namaBarang: 'Keyboard Mechanical RGB Gaming & Coding',
        kategori: 'Gadget & Komputer',
        harga: 165000,
        hargaAsli: 380000,
        kondisi: 'Like New / Sangat Mulus (Pemakaian < 1 Bulan)',
        lokasiKos: 'Kos Mahasiswa Fasilkom',
        titikCod: 'Lobi Gedung B (Fasilkom)',
        latitude: -0.9578,
        longitude: 100.3968,
        metodePengiriman: 'semua',
        biayaVerifikasi: 5000,
        biayaOngkir: 10000,
        catatanQcAdmin:
            'Switch blue clicky empuk, semua tombol berfungsi normal 100%, lampu LED menyala terang.',
        deskripsi:
            'Cocok untuk tugas praktikum pemrograman dan coding skripsi anak informatika. Blue switch responsif, kabel braided awet.',
        foto:
            'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600&auto=format&fit=crop&q=80',
        statusVerifikasi: 'approved',
        namaPenjual: 'Muhammad Iqbal Maulana',
        nimPenjual: '24101152610172',
        jurusanPenjual: 'Teknik Informatika (Fasilkom)',
        waPenjual: '6281234567890',
      ),
      ProductModel(
        id: 8,
        userId: 2,
        namaBarang: 'Helm Bogo Retro SNI Kaca Datar',
        kategori: 'Kendaraan & Aksesoris',
        harga: 75000,
        hargaAsli: 160000,
        kondisi: 'Layak Pakai (Tanda Pemakaian Wajar, Fungsi Normal)',
        lokasiKos: 'Kos Simpang Lubeg',
        titikCod: 'Pos Satpam Gerbang Depan Lubeg',
        latitude: -0.9565,
        longitude: 100.3980,
        metodePengiriman: 'jemput_mandiri',
        biayaVerifikasi: 3000,
        biayaOngkir: 0,
        catatanQcAdmin:
            'Busa dalam bersih sudah dicuci, tali pengunci klik kokoh, kaca anti-silau.',
        deskripsi:
            'Helm kuliah harian. Standar SNI aman razia polantas. Busa masih tebal nyaman di kepala.',
        foto:
            'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=600&auto=format&fit=crop&q=80',
        statusVerifikasi: 'approved',
        namaPenjual: 'Okta Khairul Ramadhan',
        nimPenjual: '24101152610177',
        jurusanPenjual: 'Sistem Informasi (Fasilkom)',
        waPenjual: '6281234567891',
      ),
    ];

    // 4. Seed Orders
    orders = [
      OrderModel(
        id: 1,
        productId: 2,
        buyerId: 1,
        sellerId: 2,
        metodePenyerahan: 'jemput_admin',
        titikCod: 'Lobi Gedung B (Fasilkom)',
        hargaBarang: 85000,
        feeAdmin: 5000,
        ongkir: 0,
        totalBayar: 90000,
        status: 'selesai',
      ),
      OrderModel(
        id: 2,
        productId: 1,
        buyerId: 3,
        sellerId: 1,
        metodePenyerahan: 'antar_admin',
        titikCod: 'Lobi UPI Convention Center (UCC)',
        hargaBarang: 180000,
        feeAdmin: 5000,
        ongkir: 15000,
        totalBayar: 200000,
        status: 'dijadwalkan',
      ),
    ];

    // 5. Seed Visitor Logs (19 logs across 7 days)
    final List<int> dayOffsets = [
      6, 6, 5, 5, 5, 4, 4, 3, 3, 3, 2, 2, 2, 1, 1, 0, 0, 0, 0
    ];
    visitorLogs = List.generate(dayOffsets.length, (i) {
      return VisitorLogModel(
        id: i + 1,
        ipAddress: '182.1.20.${10 + i}',
        pageUrl: '/campustrade/index.php',
        userId: (i % 3 == 0) ? 1 : null,
        visitedAt: now.subtract(Duration(days: dayOffsets[i])),
      );
    });
  }

  // ===========================================================================
  // NAVIGATION & FLASH HELPERS
  // ===========================================================================

  void navigateTo(String route, {String? adminTab}) {
    currentRoute = route;
    if (adminTab != null) {
      currentAdminTab = adminTab;
    }
    recordVisit('/campustrade/$route');
    notifyListeners();
  }

  void setAdminTab(String tab) {
    currentAdminTab = tab;
    notifyListeners();
  }

  void clearFlash(String type) {
    if (type == 'success') flashSuccess = null;
    if (type == 'warning') flashWarning = null;
    if (type == 'error') flashError = null;
    notifyListeners();
  }

  void recordVisit(String url) {
    visitorLogs.add(
      VisitorLogModel(
        id: visitorLogs.length + 1,
        ipAddress: '127.0.0.1',
        pageUrl: url,
        userId: currentUser?.id,
        visitedAt: DateTime.now(),
      ),
    );
    if (currentUser != null) {
      currentUser!.lastActivity = DateTime.now();
    }
  }

  // ===========================================================================
  // FILTERING & SEARCH (KATALOG PUBLIK)
  // ===========================================================================

  void setCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void setSearchKeyword(String keyword) {
    searchKeyword = keyword;
    notifyListeners();
  }

  void setRadiusFilter(String radiusKm) {
    selectedRadiusKm = radiusKm;
    notifyListeners();
  }

  void toggleMainMapExpand() {
    isMainMapExpanded = !isMainMapExpanded;
    notifyListeners();
  }

  void setSortOption(String option) {
    sortOption = option;
    notifyListeners();
  }

  bool isFavorite(int productId) => favoriteProductIds.contains(productId);

  void toggleFavorite(int productId) {
    if (favoriteProductIds.contains(productId)) {
      favoriteProductIds.remove(productId);
    } else {
      favoriteProductIds.add(productId);
    }
    notifyListeners();
  }

  void resetAllFilters() {
    selectedCategory = 'Semua';
    searchKeyword = '';
    selectedRadiusKm = 'all';
    sortOption = 'terbaru';
    notifyListeners();
  }

  List<CodSpotModel> get activeCodSpots =>
      codSpots.where((s) => s.status == 'aktif').toList();

  List<ProductModel> get filteredCatalogProducts {
    final String term = searchKeyword.trim().toLowerCase();
    final double maxDist = selectedRadiusKm == 'all'
        ? 999.0
        : (double.tryParse(selectedRadiusKm) ?? 999.0);

    final list = products.where((p) {
      if (p.statusVerifikasi != 'approved') return false;

      // Category match
      final bool matchesCategory = selectedCategory == 'Semua' ||
          p.kategori.toLowerCase() == selectedCategory.toLowerCase() ||
          p.kategori.toLowerCase().contains(selectedCategory.toLowerCase());

      // Search match
      final bool matchesSearch = term.isEmpty ||
          p.namaBarang.toLowerCase().contains(term) ||
          p.kategori.toLowerCase().contains(term) ||
          p.namaPenjual.toLowerCase().contains(term) ||
          p.lokasiKos.toLowerCase().contains(term) ||
          p.titikCod.toLowerCase().contains(term) ||
          p.deskripsi.toLowerCase().contains(term);

      // Radius match
      final bool matchesRadius = p.distanceToCampusKm <= maxDist;

      return matchesCategory && matchesSearch && matchesRadius;
    }).toList();

    switch (sortOption) {
      case 'termurah':
        list.sort((a, b) => a.harga.compareTo(b.harga));
        break;
      case 'termahal':
        list.sort((a, b) => b.harga.compareTo(a.harga));
        break;
      case 'terdekat':
        list.sort((a, b) => a.distanceToCampusKm.compareTo(b.distanceToCampusKm));
        break;
      case 'terbaru':
      default:
        list.sort((a, b) => b.id.compareTo(a.id));
        break;
    }

    return list;
  }

  // ===========================================================================
  // AUTHENTICATION (LOGIN, REGISTER KTM, FORGOT PASSWORD, LOGOUT)
  // ===========================================================================

  bool _isRateLimited(String identifier) {
    final String key = identifier.trim().toLowerCase();
    final List<DateTime>? attempts = _failedLogins[key];
    if (attempts == null) return false;
    final DateTime cutoff = DateTime.now().subtract(const Duration(minutes: 15));
    attempts.removeWhere((t) => t.isBefore(cutoff));
    return attempts.length >= 5;
  }

  void _recordFailedLogin(String identifier) {
    final String key = identifier.trim().toLowerCase();
    _failedLogins.putIfAbsent(key, () => []).add(DateTime.now());
  }

  String? login(String identifier, String password) {
    final String idClean = identifier.trim().replaceAll('@', '');
    final String passClean = password.trim();

    if (idClean.isEmpty || passClean.isEmpty) {
      flashError = 'Username/NIM dan kata sandi wajib diisi!';
      notifyListeners();
      return flashError;
    }

    if (_isRateLimited(idClean)) {
      flashError =
          'Terlalu banyak percobaan kata sandi yang salah! Akses dibatasi sementara selama 15 menit untuk mencegah serangan brute-force.';
      notifyListeners();
      return flashError;
    }

    UserModel? matched;
    for (final u in users) {
      final bool idMatch = u.nim.toLowerCase() == idClean.toLowerCase() ||
          u.username.toLowerCase() == idClean.toLowerCase();
      // Support both user's custom password and default 'password' / 'admin123'
      final bool passMatch = u.password == passClean ||
          passClean == 'password' ||
          (u.role == 'admin' && passClean == 'admin123');
      if (idMatch && passMatch) {
        matched = u;
        break;
      }
    }

    if (matched == null) {
      _recordFailedLogin(idClean);
      flashError =
          'Username / NIM atau kata sandi tidak cocok. Pastikan data akun Anda benar (Gunakan sandi: password).';
      notifyListeners();
      return flashError;
    }

    _failedLogins.remove(idClean.toLowerCase());
    matched.lastActivity = DateTime.now();
    currentUser = matched;
    flashError = null;
    flashWarning = null;
    flashSuccess = null;

    if (matched.role == 'admin') {
      flashSuccess = 'Selamat datang Administrator: ${matched.nama}';
      currentRoute = 'admin';
      currentAdminTab = 'dashboard';
    } else if (matched.statusVerifikasi == 'pending') {
      flashWarning =
          'Akun Anda (@${matched.username}) sedang MENUNGGU VERIFIKASI kartu identitas mahasiswa oleh Tim Verifikator CampusTrade (Target: UPI YPTK). Fitur pasang iklan aktif setelah disetujui.';
      currentRoute = 'catalog';
    } else if (matched.statusVerifikasi == 'rejected') {
      final String alasan = (matched.catatanPenolakan?.isNotEmpty ?? false)
          ? matched.catatanPenolakan!
          : 'Foto KTM buram atau data NIM tidak sesuai';
      flashError =
          "Pendaftaran akun (@${matched.username}) DITOLAK oleh Tim Verifikator CampusTrade. Alasan: '$alasan'. Silakan hubungi admin untuk verifikasi ulang.";
      currentRoute = 'catalog';
    } else {
      flashSuccess =
          'Selamat datang, ${matched.nama} (@${matched.username}) di Platform CampusTrade!';
      currentRoute = 'catalog';
    }

    notifyListeners();
    return null;
  }

  void logout() {
    currentUser = null;
    currentRoute = 'catalog';
    flashSuccess = 'Sesi Anda telah diakhiri dengan aman.';
    flashWarning = null;
    flashError = null;
    notifyListeners();
  }

  String? registerStudent({
    required String username,
    required String nim,
    required String nama,
    required String jurusan,
    required String whatsapp,
    required String password,
    required String ktmFileName,
  }) {
    final String uClean = username.trim().toLowerCase().replaceAll('@', '');
    final String nimClean = nim.trim();
    final String namaClean = nama.trim();
    final String waClean = _normalizePhone(whatsapp);

    if (uClean.isEmpty ||
        nimClean.isEmpty ||
        namaClean.isEmpty ||
        waClean.isEmpty ||
        password.length < 6) {
      return 'Semua kolom wajib diisi lengkap dan sandi minimal 6 karakter!';
    }

    final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,30}$');
    if (!usernameRegex.hasMatch(uClean)) {
      return 'Username hanya boleh berisi huruf, angka, dan garis bawah (_) tanpa spasi (3-30 karakter).';
    }

    if (!RegExp(r'^[0-9]{8,18}$').hasMatch(nimClean)) {
      return 'NIM harus berupa angka valid (8-18 digit)!';
    }

    if (waClean.length < 10) {
      return 'Nomor WhatsApp tidak valid (minimal 10 digit angka)!';
    }

    if (users.any((u) => u.username.toLowerCase() == uClean)) {
      return "Username '@$uClean' sudah digunakan oleh pengguna lain. Silakan pilih username unik lain!";
    }

    if (users.any((u) => u.nim.toLowerCase() == nimClean.toLowerCase())) {
      return "NIM '$nimClean' sudah terdaftar dalam sistem CampusTrade. Silakan login atau hubungi admin.";
    }

    final int nextId =
        users.isEmpty ? 1 : (users.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);

    final UserModel newUser = UserModel(
      id: nextId,
      username: uClean,
      nim: nimClean,
      nama: namaClean,
      jurusan: jurusan,
      whatsapp: waClean,
      password: password,
      fotoKtm: ktmFileName.isNotEmpty ? ktmFileName : 'sample_ktm.jpg',
      statusVerifikasi: 'pending',
      role: 'mahasiswa',
    );

    users.add(newUser);
    currentUser = newUser;
    flashWarning =
        'Pendaftaran berhasil! Akun @$uClean sedang menunggu verifikasi berkas KTM oleh Tim Verifikator CampusTrade (Target: UPI YPTK).';
    notifyListeners();
    return null;
  }

  String? resetStudentPassword({
    required String nim,
    required String whatsapp,
    required String newPassword,
    required String confirmPassword,
  }) {
    if (newPassword != confirmPassword) {
      return 'Konfirmasi kata sandi baru tidak cocok!';
    }
    if (newPassword.length < 6) {
      return 'Kata sandi baru minimal harus 6 karakter!';
    }

    final String cleanNim = nim.trim();
    UserModel? target;
    for (final u in users) {
      if (u.nim == cleanNim) {
        target = u;
        break;
      }
    }

    if (target == null) {
      return "NIM '$cleanNim' tidak terdaftar di sistem CampusTrade.";
    }

    final String inputWa = _normalizePhone(whatsapp);
    final String dbWa = _normalizePhone(target.whatsapp);
    if (inputWa != dbWa) {
      return 'Nomor WhatsApp tidak cocok dengan nomor terdaftar untuk NIM ini.';
    }

    target.password = newPassword;
    flashSuccess =
        'Kata sandi untuk ${target.nama} (@${target.username}) berhasil diperbarui! Silakan masuk.';
    notifyListeners();
    return null;
  }

  String _normalizePhone(String raw) {
    String clean = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.startsWith('0')) {
      clean = '62${clean.substring(1)}';
    }
    return clean;
  }

  // ===========================================================================
  // PRODUCT LISTING & ADMIN PRODUCT CRUD
  // ===========================================================================

  int calculateAdminFeeForProduct(String category, int price) {
    final int feeKecil =
        int.tryParse(platformSettings['fee_verifikasi_kecil'] ?? '3000') ?? 3000;
    final int feeBesar =
        int.tryParse(platformSettings['fee_verifikasi_besar'] ?? '10000') ??
            10000;
    final int feeStandar =
        int.tryParse(platformSettings['fee_verifikasi_standar'] ?? '5000') ??
            5000;

    if (category.contains('Buku') || price < 50000) {
      return feeKecil;
    } else if (category.contains('Perabotan') ||
        category.contains('Gadget') ||
        price > 250000) {
      return feeBesar;
    }
    return feeStandar;
  }

  int calculateShippingFee(String category, double distanceKm) {
    final int baseFee =
        int.tryParse(platformSettings['ongkir_dasar'] ?? '10000') ?? 10000;
    final int perKm =
        int.tryParse(platformSettings['ongkir_per_km'] ?? '2500') ?? 2500;
    final int heavyHandling =
        int.tryParse(platformSettings['biaya_handling_berat'] ?? '5000') ?? 5000;

    int total = baseFee + (distanceKm * perKm).round();
    if (category.contains('Perabotan') ||
        category.contains('Kasur') ||
        category.contains('Meja')) {
      total += heavyHandling;
    }
    return total;
  }

  void createProductListing({
    required String namaBarang,
    required String kategori,
    required int harga,
    int? hargaAsli,
    required String kondisi,
    required String metodePengiriman,
    required String titikCod,
    required String lokasiKos,
    required double latitude,
    required double longitude,
    required String deskripsi,
    String? fotoUrl,
  }) {
    if (currentUser == null) {
      flashError = 'Silakan login terlebih dahulu untuk memasang iklan!';
      notifyListeners();
      return;
    }
    if (currentUser!.role != 'admin' &&
        currentUser!.statusVerifikasi != 'approved') {
      flashWarning =
          'Akun Anda belum diverifikasi KTM/KRS oleh Admin. Iklan tidak dapat dipasang.';
      notifyListeners();
      return;
    }

    final int nextId = products.isEmpty
        ? 1
        : (products.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
    final int feeAdmin = calculateAdminFeeForProduct(kategori, harga);
    final double dist = ProductModel.calculateDistance(
        campusLat, campusLng, latitude, longitude);
    final int ongkirAdmin = calculateShippingFee(kategori, dist);

    final String defaultPhoto = _defaultPhotoForCategory(kategori);

    final ProductModel newProd = ProductModel(
      id: nextId,
      userId: currentUser!.id,
      namaBarang: namaBarang.trim(),
      kategori: kategori,
      harga: harga,
      hargaAsli: hargaAsli != null && hargaAsli > harga ? hargaAsli : (harga * 1.5).round(),
      kondisi: kondisi,
      lokasiKos: lokasiKos.trim(),
      titikCod: titikCod,
      latitude: latitude,
      longitude: longitude,
      metodePengiriman: metodePengiriman,
      biayaVerifikasi: feeAdmin,
      biayaOngkir: ongkirAdmin,
      catatanQcAdmin:
          'Lolos verifikasi awal sistem & dalam pengawasan tim QC Admin kampus.',
      deskripsi: deskripsi.trim(),
      foto: (fotoUrl != null && fotoUrl.trim().isNotEmpty)
          ? fotoUrl.trim()
          : defaultPhoto,
      statusVerifikasi: 'approved',
      namaPenjual: currentUser!.nama,
      nimPenjual: currentUser!.nim,
      jurusanPenjual: currentUser!.jurusan,
      waPenjual: currentUser!.whatsapp,
    );

    products.insert(0, newProd);
    flashSuccess =
        'Unit "${newProd.namaBarang}" berhasil dipublikasikan ke katalog CampusTrade!';
    notifyListeners();
  }

  String _defaultPhotoForCategory(String category) {
    if (category.contains('Perabotan')) {
      return 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=600&auto=format&fit=crop&q=80';
    } else if (category.contains('Elektronik')) {
      return 'https://images.unsplash.com/photo-1585338107529-13afc5f02586?w=600&auto=format&fit=crop&q=80';
    } else if (category.contains('Gadget')) {
      return 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600&auto=format&fit=crop&q=80';
    } else if (category.contains('Buku')) {
      return 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=600&auto=format&fit=crop&q=80';
    } else if (category.contains('Masak')) {
      return 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=600&auto=format&fit=crop&q=80';
    } else if (category.contains('Kendaraan')) {
      return 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=600&auto=format&fit=crop&q=80';
    }
    return 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=600&auto=format&fit=crop&q=80';
  }

  void deleteProduct(int id) {
    final int idx = products.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final p = products[idx];
    if (currentUser != null &&
        currentUser!.role != 'admin' &&
        currentUser!.id != p.userId) {
      flashError = 'Anda tidak memiliki otoritas untuk menghapus unit ini!';
      notifyListeners();
      return;
    }
    products.removeAt(idx);
    flashSuccess = 'Unit "${p.namaBarang}" (#$id) berhasil dihapus dari katalog.';
    notifyListeners();
  }

  void approveProduct(int id) {
    for (final p in products) {
      if (p.id == id) {
        p.statusVerifikasi = 'approved';
        flashSuccess = 'Unit "${p.namaBarang}" telah disetujui (APPROVED).';
        break;
      }
    }
    notifyListeners();
  }

  void rejectProduct(int id, String reason) {
    for (final p in products) {
      if (p.id == id) {
        p.statusVerifikasi = 'rejected';
        p.catatanQcAdmin = reason.trim().isNotEmpty
            ? reason.trim()
            : 'Tidak lolos standar kelayakan fisik/deskripsi admin.';
        flashWarning =
            'Unit "${p.namaBarang}" ditolak QC: "${p.catatanQcAdmin}".';
        break;
      }
    }
    notifyListeners();
  }

  OrderModel createOrder({
    required int productId,
    int? buyerId,
    int? sellerId,
    required String metodePenyerahan,
    required String titikCod,
    String? alamatAntar,
    required int hargaBarang,
    required int feeAdmin,
    required int ongkir,
    required int totalBayar,
  }) {
    final int nextId = orders.isEmpty
        ? 1
        : (orders.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);

    final newOrder = OrderModel(
      id: nextId,
      productId: productId,
      buyerId: buyerId ?? currentUser?.id,
      sellerId: sellerId,
      metodePenyerahan: metodePenyerahan,
      titikCod: titikCod,
      alamatAntar: alamatAntar,
      hargaBarang: hargaBarang,
      feeAdmin: feeAdmin,
      ongkir: ongkir,
      totalBayar: totalBayar,
      status: 'diajukan',
    );

    orders.insert(0, newOrder);
    notifyListeners();
    return newOrder;
  }

  void updateOrderStatus(int orderId, String newStatus) {
    for (final o in orders) {
      if (o.id == orderId) {
        o.status = newStatus;
        flashSuccess =
            'Status pesanan #$orderId diubah menjadi ${newStatus.toUpperCase()}.';
        break;
      }
    }
    notifyListeners();
  }

  void adminUpdateProduct({
    required int id,
    required String namaBarang,
    required String kategori,
    required String statusVerifikasi,
    required int harga,
    required int hargaAsli,
    required int biayaVerifikasi,
    required int biayaOngkir,
    required String kondisi,
    required String lokasiKos,
    required String titikCod,
    required String catatanQcAdmin,
    required String deskripsi,
  }) {
    for (final p in products) {
      if (p.id == id) {
        p.namaBarang = namaBarang.trim();
        p.kategori = kategori;
        p.statusVerifikasi = statusVerifikasi;
        p.harga = harga;
        p.hargaAsli = hargaAsli > 0 ? hargaAsli : (harga * 1.5).round();
        p.biayaVerifikasi = biayaVerifikasi;
        p.biayaOngkir = biayaOngkir;
        p.kondisi = kondisi.trim();
        p.lokasiKos = lokasiKos.trim();
        p.titikCod = titikCod.trim();
        p.catatanQcAdmin = catatanQcAdmin.trim();
        p.deskripsi = deskripsi.trim();
        flashSuccess = 'Data unit #$id (${p.namaBarang}) berhasil diperbarui.';
        break;
      }
    }
    notifyListeners();
  }

  // ===========================================================================
  // ADMIN CMS: METRICS, USERS, COD SPOTS, & SETTINGS
  // ===========================================================================

  int get countAllProducts => products.length;
  int get countApprovedProducts =>
      products.where((p) => p.statusVerifikasi == 'approved').length;
  int get countPendingProducts =>
      products.where((p) => p.statusVerifikasi == 'pending').length;

  int get totalValuation => products
      .where((p) => p.statusVerifikasi == 'approved')
      .fold(0, (sum, p) => sum + p.harga);

  int get totalAdminFeePotential => products
      .where((p) => p.statusVerifikasi == 'approved')
      .fold(0, (sum, p) => sum + p.biayaVerifikasi);

  int get countTotalUsers => users.length;
  int get countPendingUsers =>
      users.where((u) => u.statusVerifikasi == 'pending').length;
  int get countApprovedUsers =>
      users.where((u) => u.statusVerifikasi == 'approved').length;
  int get countRejectedUsers =>
      users.where((u) => u.statusVerifikasi == 'rejected').length;

  int get totalVisits => visitorLogs.length;

  int get todayVisits {
    final DateTime now = DateTime.now();
    return visitorLogs
        .where((v) =>
            v.visitedAt.year == now.year &&
            v.visitedAt.month == now.month &&
            v.visitedAt.day == now.day)
        .length;
  }

  List<UserModel> get onlineUsersList {
    final DateTime cutoff =
        DateTime.now().subtract(const Duration(minutes: 15));
    return users
        .where((u) => u.lastActivity.isAfter(cutoff))
        .toList()
      ..sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
  }

  Map<String, int> get codSpotDistribution {
    final Map<String, int> map = {};
    for (final p in products.where((p) => p.statusVerifikasi == 'approved')) {
      map[p.titikCod] = (map[p.titikCod] ?? 0) + 1;
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in entries) e.key: e.value};
  }

  List<MapEntry<String, int>> get weeklyVisitSeries {
    final DateTime now = DateTime.now();
    const List<String> dayNames = [
      'Sen',
      'Sel',
      'Rab',
      'Kam',
      'Jum',
      'Sab',
      'Min'
    ];
    final List<int> baseline = [18, 24, 21, 29, 26, 32, 35];
    final List<MapEntry<String, int>> result = [];

    for (int i = 6; i >= 0; i--) {
      final DateTime d = now.subtract(Duration(days: i));
      final String dayLabel = dayNames[(d.weekday - 1).clamp(0, 6)];
      final String dateStr =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
      final int loggedCount = visitorLogs
          .where((v) =>
              v.visitedAt.year == d.year &&
              v.visitedAt.month == d.month &&
              v.visitedAt.day == d.day)
          .length;
      final int displayCount = loggedCount + baseline[6 - i];
      result.add(MapEntry('$dayLabel ($dateStr)', displayCount));
    }
    return result;
  }

  List<MapEntry<String, int>> get categoryChartSeries {
    final Map<String, int> counts = {};
    for (final p in products) {
      counts[p.kategori] = (counts[p.kategori] ?? 0) + 1;
    }
    final list = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  List<ProductModel> get filteredAdminProducts {
    final String q = adminProductSearch.trim().toLowerCase();
    return products.where((p) {
      final bool statusMatch = adminProductStatusFilter == 'all' ||
          p.statusVerifikasi == adminProductStatusFilter;
      final bool catMatch = adminProductCategoryFilter == 'all' ||
          p.kategori
              .toLowerCase()
              .contains(adminProductCategoryFilter.toLowerCase());
      final bool searchMatch = q.isEmpty ||
          p.namaBarang.toLowerCase().contains(q) ||
          p.lokasiKos.toLowerCase().contains(q) ||
          p.titikCod.toLowerCase().contains(q) ||
          p.namaPenjual.toLowerCase().contains(q) ||
          p.nimPenjual.toLowerCase().contains(q);
      return statusMatch && catMatch && searchMatch;
    }).toList();
  }

  List<UserModel> get filteredAdminUsers {
    final String q = adminUserSearch.trim().toLowerCase();
    final List<UserModel> list = users.where((u) {
      final bool roleMatch =
          adminUserRoleFilter == 'all' || u.role == adminUserRoleFilter;
      final bool statusMatch = adminUserStatusFilter == 'all' ||
          u.statusVerifikasi == adminUserStatusFilter;
      final bool searchMatch = q.isEmpty ||
          u.username.toLowerCase().contains(q) ||
          u.nim.toLowerCase().contains(q) ||
          u.nama.toLowerCase().contains(q) ||
          u.jurusan.toLowerCase().contains(q) ||
          u.whatsapp.toLowerCase().contains(q);
      return roleMatch && statusMatch && searchMatch;
    }).toList();

    list.sort((a, b) {
      int rank(String s) => s == 'pending'
          ? 1
          : s == 'approved'
              ? 2
              : 3;
      final int cmp = rank(a.statusVerifikasi).compareTo(rank(b.statusVerifikasi));
      if (cmp != 0) return cmp;
      return b.id.compareTo(a.id);
    });
    return list;
  }

  List<CodSpotModel> get filteredAdminCodSpots {
    final String q = adminCodSpotSearch.trim().toLowerCase();
    return codSpots.where((s) {
      if (q.isEmpty) return true;
      return s.namaTitik.toLowerCase().contains(q) ||
          s.deskripsi.toLowerCase().contains(q) ||
          s.kategori.toLowerCase().contains(q);
    }).toList();
  }

  int get countAllUsers => users.length;

  void approveUserKtm(int userId) {
    for (final u in users) {
      if (u.id == userId) {
        u.statusVerifikasi = 'approved';
        u.catatanPenolakan = null;
        u.verifiedAt = DateTime.now();
        u.verifiedBy = currentUser?.id ?? 4;
        flashSuccess =
            'Akun mahasiswa ${u.nama} (@${u.username}) telah DISETUJUI dan aktif!';
        break;
      }
    }
    notifyListeners();
  }

  void rejectUserKtm(int userId, String reason) {
    for (final u in users) {
      if (u.id == userId) {
        u.statusVerifikasi = 'rejected';
        u.catatanPenolakan = reason.trim();
        u.verifiedAt = DateTime.now();
        u.verifiedBy = currentUser?.id ?? 4;
        flashWarning =
            'Berkas KTM @${u.username} ditolak dengan alasan: "${reason.trim()}".';
        break;
      }
    }
    notifyListeners();
  }

  String? adminCreateUser({
    required String username,
    required String nim,
    required String nama,
    required String jurusan,
    required String whatsapp,
    required String role,
    required String statusVerifikasi,
    required String password,
  }) {
    final String uClean = username.trim().toLowerCase().replaceAll('@', '');
    final String nimClean = nim.trim();
    if (users.any((u) => u.username.toLowerCase() == uClean)) {
      return 'Username sudah terdaftar!';
    }
    if (users.any((u) => u.nim.toLowerCase() == nimClean.toLowerCase())) {
      return 'NIM sudah terdaftar!';
    }
    final int nextId =
        users.isEmpty ? 1 : (users.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
    users.add(
      UserModel(
        id: nextId,
        username: uClean,
        nim: nimClean,
        nama: nama.trim(),
        jurusan: jurusan.trim(),
        whatsapp: _normalizePhone(whatsapp),
        password: password,
        fotoKtm: 'sample_ktm.jpg',
        statusVerifikasi: statusVerifikasi,
        role: role,
      ),
    );
    flashSuccess = 'Akun @$uClean berhasil ditambahkan secara manual.';
    notifyListeners();
    return null;
  }

  void adminUpdateUser({
    required int id,
    required String nama,
    required String jurusan,
    required String whatsapp,
    required String statusVerifikasi,
    required String role,
    String? newPassword,
  }) {
    for (final u in users) {
      if (u.id == id) {
        u.nama = nama.trim();
        u.jurusan = jurusan.trim();
        u.whatsapp = _normalizePhone(whatsapp);
        u.statusVerifikasi = statusVerifikasi;
        u.role = role;
        if (newPassword != null && newPassword.trim().isNotEmpty) {
          u.password = newPassword.trim();
        }
        flashSuccess = 'Profil @${u.username} berhasil diperbarui.';
        break;
      }
    }
    notifyListeners();
  }

  void adminResetUserPassword(int id, String newPass) {
    for (final u in users) {
      if (u.id == id) {
        u.password = newPass.trim();
        flashSuccess =
            'Kata sandi untuk ${u.nama} (@${u.username}) berhasil direset.';
        break;
      }
    }
    notifyListeners();
  }

  void adminDeleteUser(int id) {
    if (currentUser?.id == id) {
      currentUser = null;
    }
    users.removeWhere((u) => u.id == id && u.role != 'admin');
    flashSuccess = 'Akun pengguna berhasil dihapus.';
    notifyListeners();
  }

  // COD Spot CRUD
  void toggleCodSpotStatus(int id) {
    for (final s in codSpots) {
      if (s.id == id) {
        s.status = (s.status == 'aktif') ? 'nonaktif' : 'aktif';
        flashSuccess =
            'Status titik COD "${s.namaTitik}" diubah menjadi ${s.status.toUpperCase()}.';
        break;
      }
    }
    notifyListeners();
  }

  void createCodSpot({
    required String namaTitik,
    required String kategori,
    required String status,
    required double latitude,
    required double longitude,
    required String deskripsi,
  }) {
    final int nextId = codSpots.isEmpty
        ? 1
        : (codSpots.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
    codSpots.add(
      CodSpotModel(
        id: nextId,
        namaTitik: namaTitik.trim(),
        kategori: kategori,
        deskripsi: deskripsi.trim(),
        latitude: latitude,
        longitude: longitude,
        status: status,
      ),
    );
    flashSuccess = 'Titik COD "${namaTitik.trim()}" berhasil ditambahkan.';
    notifyListeners();
  }

  void updateCodSpot({
    required int id,
    required String namaTitik,
    required String kategori,
    required String status,
    required double latitude,
    required double longitude,
    required String deskripsi,
  }) {
    for (final s in codSpots) {
      if (s.id == id) {
        s.namaTitik = namaTitik.trim();
        s.kategori = kategori;
        s.status = status;
        s.latitude = latitude;
        s.longitude = longitude;
        s.deskripsi = deskripsi.trim();
        flashSuccess = 'Titik COD "${s.namaTitik}" berhasil diperbarui.';
        break;
      }
    }
    notifyListeners();
  }

  void deleteCodSpot(int id) {
    codSpots.removeWhere((s) => s.id == id);
    flashSuccess = 'Titik COD berhasil dihapus.';
    notifyListeners();
  }

  void updatePlatformSettings(Map<String, String> updated) {
    platformSettings.addAll(updated);
    flashSuccess =
        'Konfigurasi tarif fee, ongkir, & rekber berhasil disimpan secara instan.';
    notifyListeners();
  }
}
