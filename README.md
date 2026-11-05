# CampusTrade UPI YPTK Padang — Flutter Edition (v8 Full-Width Responsive)

Hasil konversi penuh dari aplikasi web **CampusTrade UPI YPTK Padang (`campustrade_upi_yptk_fullwidth_responsive_v8`)** ke **Flutter** (mendukung Android, iOS, Web, Windows, macOS, dan Linux) dengan arsitektur **Anti-Slop Swiss Editorial Design System** dan **Zero External Plugin Conflict**.

## Fitur Lengkap yang Dikonversi (100% Parity)

### 1. Etalase Publik & Katalog Mahasiswa (`CatalogScreen`)
- **Announcement Status Bar**: Menampilkan teks pengumuman dinamis dari pengaturan Admin CMS serta koordinat referensi Lubuk Begalung (`-0.9575, 100.3972`).
- **Sticky Precision Header & Navbar**: Pencarian real-time (Desktop & Mobile), indikator status verifikasi akun (`VERIFIED`, `PENDING`, `REJECTED`), tombol akses cepat ke **Admin CMS** (khusus role Admin), dan tombol **Jual Barang** dengan *Verification Gatekeeper*.
- **Flash Notification Bar & Pending KTM Banner**: Notifikasi sukses/peringatan/error yang dapat ditutup serta banner konfirmasi WhatsApp bagi akun yang sedang menunggu validasi KTM.
- **Swiss Editorial Hero & Telemetry Bento Grid**: Menampilkan statistik katalog terkurasi, jumlah titik COD aktif, status `ESCROW ON`, dan SOP Protokol Anti-Penipuan.
- **Geospatial Radar Map Interaktif (`GeospatialMapWidget`)**:
  - Pemetaan posisi kosan penjual terhadap titik COD resmi di sekitar kampus UPI YPTK Lubuk Begalung.
  - Filter radius jarak real-time (`SEMUA (< 5.0 KM)`, `< 0.5 KM (JALAN KAKI)`, `< 1.0 KM (ZONA INTI)`, `< 2.0 KM (LUBEG RAYA)`).
  - Tombol **Perbesar Peta / Kecilkan Peta**, fitur *zoom/pan*, pin titik COD resmi (`🏛️`, `📍`, `🏪`), serta pin harga unit kos (`Rp 180k`, dll.) yang menampilkan popup interaktif dan membuka modal detail.
- **Filter Kategori Architectural Tabs & Product Grid**:
  - 10 tab kategori (`Semua Unit`, `Perabotan Kos`, `Elektronik`, `Gadget & Komputer`, `Buku & Modul`, `Alat Masak`, `Kendaraan & Helm`, `Fashion Kuliah`, `Harian & Hobi`, `Lain-lain`).
  - Kartu produk dengan tag `QC PASS`, jarak Haversine (`KM` dari kampus), kondisi fisik, persentase penghematan (`-60%`), opsi hapus untuk pemilik/admin, dan tombol `INSPEKSI ->`.
- **Zona Titik Temu COD Resmi & Mobile Bottom Navigation Bar**: Daftar titik temu COD aktif beserta navigasi bawah responsif untuk perangkat mobile.

### 2. Modal Interaktif (`Modals`)
- **Modal Detail Produk (`ProductDetailModal`)**:
  - Spesifikasi lengkap, perbandingan harga buka vs harga baru, dan badge jarak.
  - **Peta Mini Rute Kos Penjual <-> Titik COD Kampus** dengan garis rute putus-putus.
  - **Laporan Inspeksi Fisik (QC Admin)**.
  - **Kalkulator Biaya Transparan**: Pilihan *Jemput COD di Kampus (Rp 0)* atau *Kurir Admin Antar-Kos (+Ongkir)* lengkap dengan rincian Harga Unit + Jasa Verifikasi Fisik & Rekber Admin + Ongkir Kurir.
  - **Integrasi Pesan WhatsApp Otomatis**: Menghasilkan format pesan transaksi lengkap dan siap dikirim ke WhatsApp Admin.
- **Modal Jual Barang (`SellProductModal`)**:
  - Formulir listing barang kos dengan **Kalkulator Estimasi Bersih Diterima Penjual** secara otomatis berdasarkan kategori & rentang harga (`fee_verifikasi_kecil`, `fee_verifikasi_standar`, `fee_verifikasi_besar`).
  - **Pinpoint Coordinate Picker Map**: Geser atau ketuk peta untuk menyematkan koordinat GPS lokasi kos secara presisi.
- **Modal Otentikasi Civitas (`AuthModal`)**:
  - **Tab Masuk**: Login dengan NIM atau Username unik + proteksi *Rate Limiting Anti-Brute Force* (maks 5x gagal per 15 menit).
  - **Tab Registrasi KTM**: Pendaftaran akun mahasiswa baru dengan validasi format username, keunikan NIM, dan simulasi unggah berkas KTM/KRS (`status_verifikasi = pending`).
  - **Tab Reset Sandi**: Pemulihan kata sandi mandiri menggunakan validasi kecocokan 14 digit NIM dan nomor WhatsApp terdaftar.

### 3. Konsol Administrator (`AdminCmsScreen`) — Dual Responsive
- **1. Ringkasan & Trafik (`Dashboard`)**:
  - Alert antrean verifikasi KTM, 4 KPI Bento Cards (Trafik Kunjungan, Sesi Online Real-time, Unit Katalog & Antrean QC, Potensi Fee Verifikasi & Valuasi Bursa).
  - Grafik **Tren Kunjungan Harian (7 Hari Terakhir)** & **Donut Chart Komposisi Kategori**.
  - Tabel **Pengguna Sedang Online**, tabel **Listing Barang Terbaru**, **Distribusi Titik COD**, dan **Peta Perimeter Kampus**.
- **2. Inventaris & QC Barang (`Products`)**:
  - Dual Responsive (Kartu Mobile `< 1024px` & Tabel Swiss Desktop `>= 1024px`).
  - Filter status (`Semua`, `Pending`, `Approved`), kategori, dan kata kunci.
  - Aksi 1-klik `APPROVE`, modal **Edit Unit & Laporan QC Admin**, serta `DEL`.
- **3. Verifikasi KTM & User (`Users`)**:
  - Dual Responsive (Kartu Mobile `< 1024px` & Tabel Swiss Desktop `>= 1024px`).
  - Modal **Inspeksi Dokumen KTM/KRS**, tombol **Setujui KTM**, modal **Tolak Verifikasi KTM** dengan template alasan penolakan, modal **Registrasi Akun Manual**, **Edit Profil Pengguna**, **Reset Sandi Cepat (`KEY`)**, dan hapus akun.
- **4. Zona Titik COD Resmi (`COD Spots`)**:
  - Protokol fleksibilitas zona COD, metrik titik aktif/cadangan, toggle status 1-klik (`AKTIF` / `NONAKTIF`), modal **Tambah Titik COD Baru**, **Edit Titik COD**, dan hapus titik.
- **5. Tarif Fee & Ongkir (`Settings`)**:
  - Pengaturan dinamis Fee Verifikasi (`Standar`, `Unit Kecil`, `Unit Besar`), Tarif Ekspedisi (`Ongkir Dasar`, `Tarif per KM`, `Handling Berat`, `Max Radius`), Rekening Rekber, WhatsApp Admin, dan Teks Pengumuman Status Bar, ditambah panel **Telemetri Server & Keamanan (OWASP Hardened)**.

## Akun Demo Bawaan (Seed Data `schema.sql`)

| Peran | Username | NIM | Kata Sandi | Status KTM |
| :--- | :--- | :--- | :--- | :--- |
| **Administrator** | `admin` | `admin` | `password` (atau `admin123`) | `approved` |
| **Mahasiswa (Verified)** | `iqbal_m` | `24101152610172` | `password` | `approved` |
| **Mahasiswa (Verified)** | `okta_kr` | `24101152610177` | `password` | `approved` |
| **Mahasiswa (Verified)** | `anggara_y` | `24101152610222` | `password` | `approved` |
| **Mahasiswa (Pending KTM)** | `fajar_pratama` | `24101152610999` | `password` | `pending` |

## Cara Menjalankan

1. Ekstrak folder proyek ini, lalu jalankan:
   ```bash
   flutter pub get
   flutter run
   ```
2. Untuk menjalankan di browser (Web):
   ```bash
   flutter run -d chrome
   ```
