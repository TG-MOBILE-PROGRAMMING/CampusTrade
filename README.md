# CampusTrade UPI YPTK Padang

Platform bursa barang bekas dan logistik mikro berbasis komunitas kampus yang dirancang khusus untuk civitas akademika Universitas Putra Indonesia "YPTK" Padang. Sistem ini menggabungkan kurasi fisik (Quality Control), transaksi aman berbasis titik temu (COD Geospasial), dan verifikasi identitas resmi mahasiswa (NIM/KTM).

## Tim Pengembang

| No | Nama Lengkap | NIM |
| :--- | :--- | :--- |
| 1 | **Muhammad Iqbal Maulana** | `24101152610172` |
| 2 | **Okta Khairul Ramadhan** | `24101152610177` |
| 3 | **Try Anggara Yofa** | `24101152610222` |

## Latar Belakang & Masalah

Setiap siklus semester baru atau kelulusan, mahasiswa kos di sekitar Lubuk Begalung menghadapi kendala klasik:

1. **Tingginya Resiko Penipuan**: Transaksi jual-beli di forum media sosial umum minim akuntabilitas dan rawan penipuan identitas.
2. **Kondisi Fisik Barang Tidak Akurat**: Deskripsi penjual kerap tidak sesuai dengan kondisi riil barang bekas (elektronik, perabotan, buku).
3. **Kendala Transportasi & Jarak**: Mahasiswa kesulitan memperkirakan jarak kosan penjual dan menentukan titik temu yang aman di area kampus.

**CampusTrade** dirancang sebagai solusi terpadu untuk menyelesaikan masalah tersebut dengan membatasi ekosistem transaksi hanya untuk mahasiswa terverifikasi, didukung inspeksi fisik barang, serta penentuan rute transaksi berbasis koordinat presisi.

## Arsitektur Sistem & Fitur Utama

Aplikasi dibangun menggunakan **Flutter Multiplatform** dengan pendekatan *clean architecture* dan prinsip desain *Swiss Editorial* (fungsional, tipografi tegas, minim ornamen visual yang tidak perlu).

### 1. Verifikasi Identitas Civitas Akademika (Zero-Trust Gatekeeper)
- Pendaftaran akun mewajibkan validasi 14 digit NIM aktif dan bukti identitas mahasiswa (KTM/KRS).
- Hak akses bertingkat (*Role-Based Access Control*):
  - **Tamu / Publik**: Hanya dapat meninjau katalog barang dan zona perimeter COD.
  - **Mahasiswa Pending**: Dapat melihat rincian barang, namun fitur listing dibatasi hingga KTM disetujui.
  - **Mahasiswa Terverifikasi**: Akses penuh untuk memasang iklan dan melakukan transaksi.
  - **Administrator**: Memegang otoritas penuh terhadap verifikasi identitas dan moderasi listing.

### 2. Modul Geospasial & Radius Logistik Lubuk Begalung
- **Titik Referensi Inti**: Koordinat kampus UPI YPTK Padang (`-0.9575, 100.3972`).
- **Kalkulasi Jarak Real-Time (Formula Haversine)**: Mengukur jarak presisi antara titik kos penjual dengan perimeter kampus.
- **Filter Radius Transaksi**:
  - `< 0.5 KM`: Zona Jalan Kaki (Area terdekat gerbang utama).
  - `< 1.0 KM`: Zona Inti Kampus & Pemukiman Mahasiswa.
  - `< 2.0 KM`: Area Lubuk Begalung Raya.
- **Pinpoint Coordinate Picker**: Penjual dapat menandai titik penjemputan barang langsung melalui peta interaktif saat membuat listing.

### 3. Protokol Transaksi & Quality Control (QC)
- **Laporan Inspeksi Fisik**: Setiap unit melewati status validasi sebelum tayang di katalog utama untuk memastikan kejujuran deskripsi.
- **Kalkulator Biaya Transparan**:
  - Opsi 1: *Jemput Mandiri di Titik COD Kampus* (Rp 0 ongkir).
  - Opsi 2: *Antar Kurir Mahasiswa* (Kalkulasi otomatis berdasarkan jarak per kilometer dan beban handling barang).
- **Format Order Otomatis ke WhatsApp**: Mengonversi rincian invoice transaksi, identitas pembeli, dan rute penjemputan menjadi format pesan WhatsApp terstruktur ke admin/penjual.

### 4. Konsol Kendali Administrator (Admin CMS)
Panel terintegrasi untuk kebutuhan operasional platform:
- **Dashboard Telemetri**: Grafik tren kunjungan, distribusi kategori barang, dan antrean verifikasi aktif.
- **Manajemen Inventaris**: Verifikasi, penolakan, atau penyuntingan catatan QC barang.
- **Manajemen Pengguna & KTM**: Panel inspeksi dokumen KTM/KRS dengan fitur persetujuan dan penolakan berulang.
- **Zona Titik Temu Resmi**: Penambahan dan pembaruan titik COD aman (misal: Perpustakaan, Halte Utama, Kantin Pusat).
- **Pengaturan Tarif**: Penyesuaian fleksibel untuk biaya administrasi, formula ongkir, serta rekening bersama.

## Struktur Direktori Proyek

```
campustrade_upi/
├── lib/
│   ├── config/             # Konfigurasi konstanta, tema Swiss Editorial, & rute
│   ├── models/             # Data model (User, Product, CodSpot, Logistik)
│   ├── modules/
│   │   ├── admin/          # Panel konsol CMS, dashboard metrik, & manajemen user
│   │   ├── auth/           # Formulir login, pendaftaran KTM, & validasi NIM
│   │   ├── catalog/        # Tampilan katalog produk, filter bento grid, & detail modal
│   │   ├── geospatial/     # Komponen peta interaktif, radar jarak, & penanda koordinat
│   │   └── sell/           # Alur pasang iklan barang & kalkulator estimasi pendapatan
│   ├── services/           # Logika kalkulasi Haversine, simulasi API, & state management
│   └── main.dart           # Titik masuk utama aplikasi (Main Runner)
├── pubspec.yaml            # Konfigurasi dependensi proyek Flutter
└── README.md
```

## Kredensial Pengujian (Data Demo)

Aplikasi telah dilengkapi basis data awal untuk simulasi alur kerja pengujian:

| Peran Akun | Username | Identifikasi / NIM | Sandi | Status Akses |
| :--- | :--- | :--- | :--- | :--- |
| **Administrator** | `admin` | `admin` | `admin123` | Otoritas Penuh CMS |
| **Mahasiswa 1** | `iqbal_m` | `24101152610172` | `password` | Mahasiswa Terverifikasi |
| **Mahasiswa 2** | `okta_kr` | `24101152610177` | `password` | Mahasiswa Terverifikasi |
| **Mahasiswa 3** | `anggara_y` | `24101152610222` | `password` | Mahasiswa Terverifikasi |
| **Mahasiswa Baru** | `fajar_pratama` | `24101152610999` | `password` | Menunggu Validasi KTM |

## Panduan Menjalankan Aplikasi

Pastikan lingkungan pengembangan telah terpasang **Flutter SDK** (versi stable) dan dependensi platform target.

1. **Unduh dependensi proyek**:
   ```bash
   flutter pub get
   ```

2. **Jalankan di perangkat yang terhubung (Desktop/Mobile)**:
   ```bash
   flutter run
   ```

3. **Jalankan pada browser (Web)**:
   ```bash
   flutter run -d chrome
   ```