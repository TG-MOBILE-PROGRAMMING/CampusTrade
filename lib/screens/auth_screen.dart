import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/swiss_theme.dart';

/// ============================================================================
/// AUTH SCREEN (DEDICATED FULL-PAGE LOGIN & REGISTRATION)
/// [Anti-Slop UI Architecture & Zero-Modal Native Flow]
/// ============================================================================
class AuthScreen extends StatefulWidget {
  final CampusTradeState appState;
  final String initialTab;

  const AuthScreen({
    super.key,
    required this.appState,
    this.initialTab = 'login',
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late String _tab; // 'login' or 'register'
  bool _obscurePass = true;
  String? _errorMsg;

  // Login controllers
  final _loginIdCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();

  // Register controllers
  final _regUsernameCtrl = TextEditingController();
  final _regNimCtrl = TextEditingController();
  final _regNamaCtrl = TextEditingController();
  final _regWaCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  String _regJurusan = 'Teknik Informatika (Fasilkom)';

  static const List<String> _jurusanList = [
    'Teknik Informatika (Fasilkom)',
    'Sistem Informasi (Fasilkom)',
    'Sistem Komputer (Fasilkom)',
    'Manajemen Informatika (Fasilkom)',
    'Manajemen (FEB)',
    'Akuntansi (FEB)',
    'Teknik Sipil (Fakultas Teknik)',
    'Teknik Industri (Fakultas Teknik)',
    'Desain Komunikasi Visual (DKV)',
    'Psikologi',
  ];

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  void dispose() {
    _loginIdCtrl.dispose();
    _loginPassCtrl.dispose();
    _regUsernameCtrl.dispose();
    _regNimCtrl.dispose();
    _regNamaCtrl.dispose();
    _regWaCtrl.dispose();
    _regPassCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() => _errorMsg = null);
    final error = widget.appState.login(
      _loginIdCtrl.text.trim(),
      _loginPassCtrl.text.trim(),
    );

    if (error != null) {
      setState(() => _errorMsg = error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SwissColors.verifiedEmerald,
          content: Text('Selamat datang, ${widget.appState.currentUser?.nama}!'),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _quickLogin(String id, String pass) {
    _loginIdCtrl.text = id;
    _loginPassCtrl.text = pass;
    _handleLogin();
  }

  void _handleRegister() {
    setState(() => _errorMsg = null);
    final error = widget.appState.registerStudent(
      username: _regUsernameCtrl.text.trim(),
      nim: _regNimCtrl.text.trim(),
      nama: _regNamaCtrl.text.trim(),
      jurusan: _regJurusan,
      whatsapp: _regWaCtrl.text.trim(),
      password: _regPassCtrl.text.trim(),
      ktmFileName: 'ktm_${_regNimCtrl.text.trim()}.jpg',
    );

    if (error != null) {
      setState(() => _errorMsg = error);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: SwissColors.verifiedEmerald,
          content: Text('Pendaftaran berhasil! Akun Anda sedang dalam proses verifikasi KTM oleh Admin.'),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 960;

    return Scaffold(
      backgroundColor: SwissColors.canvasWarm,
      appBar: AppBar(
        backgroundColor: SwissColors.canvasPure,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Akun Mahasiswa CampusTrade',
          style: SwissTheme.display(size: 16, weight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SwissColors.inkPrimary),
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? (screenWidth - 540) / 2 : 20,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Brand Hero Card
              _buildBrandHeader(),
              const SizedBox(height: 20),

              // Segmented Tab Selector
              _buildSegmentedTab(),
              const SizedBox(height: 20),

              // Error display
              if (_errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: SwissColors.dangerRose.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: SwissColors.dangerRose, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMsg!,
                          style: SwissTheme.sans(size: 11, color: SwissColors.dangerRose, weight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Form Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SwissColors.canvasPure,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SwissColors.borderHairline),
                  boxShadow: const [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: _tab == 'login' ? _buildLoginForm() : _buildRegisterForm(),
              ),
              const SizedBox(height: 24),

              // Quick demo access box
              if (_tab == 'login') _buildDemoLoginBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: SwissColors.rauschCoral,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33FF385C),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'CampusTrade',
          style: SwissTheme.display(size: 20, weight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Bursa Inventaris & Perabotan Kos Mahasiswa Terverifikasi',
          textAlign: TextAlign.center,
          style: SwissTheme.sans(size: 12, color: SwissColors.inkSecondary),
        ),
      ],
    );
  }

  Widget _buildSegmentedTab() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() {
                _tab = 'login';
                _errorMsg = null;
              }),
              borderRadius: BorderRadius.circular(9),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _tab == 'login' ? SwissColors.canvasPure : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: _tab == 'login'
                      ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Masuk Akun',
                    style: SwissTheme.display(
                      size: 13,
                      weight: _tab == 'login' ? FontWeight.w700 : FontWeight.w500,
                      color: _tab == 'login' ? SwissColors.inkPrimary : SwissColors.inkSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() {
                _tab = 'register';
                _errorMsg = null;
              }),
              borderRadius: BorderRadius.circular(9),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _tab == 'register' ? SwissColors.canvasPure : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: _tab == 'register'
                      ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Daftar Mahasiswa',
                    style: SwissTheme.display(
                      size: 13,
                      weight: _tab == 'register' ? FontWeight.w700 : FontWeight.w500,
                      color: _tab == 'register' ? SwissColors.inkPrimary : SwissColors.inkSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('Username atau NIM Mahasiswa *'),
        TextField(
          controller: _loginIdCtrl,
          decoration: _inputDecoration('Contoh: iqbal_m atau 24101152610172', icon: Icons.person_outline),
        ),
        const SizedBox(height: 14),

        _buildLabel('Kata Sandi *'),
        TextField(
          controller: _loginPassCtrl,
          obscureText: _obscurePass,
          decoration: _inputDecoration('Masukkan kata sandi akun', icon: Icons.lock_outline).copyWith(
            suffixIcon: IconButton(
              icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, size: 18),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
          ),
        ),
        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: SwissColors.rauschCoral,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            'Masuk Sekarang',
            style: SwissTheme.display(size: 14, weight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('Username Pilihan (Unik) *'),
        TextField(
          controller: _regUsernameCtrl,
          decoration: _inputDecoration('Contoh: angga_upi', icon: Icons.alternate_email),
        ),
        const SizedBox(height: 12),

        _buildLabel('NIM Mahasiswa (14 Digit) *'),
        TextField(
          controller: _regNimCtrl,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration('Contoh: 24101152610172', icon: Icons.badge_outlined),
        ),
        const SizedBox(height: 12),

        _buildLabel('Nama Lengkap Mahasiswa *'),
        TextField(
          controller: _regNamaCtrl,
          decoration: _inputDecoration('Sesuai kartu identitas kampus', icon: Icons.person_outline),
        ),
        const SizedBox(height: 12),

        _buildLabel('Program Studi / Jurusan *'),
        DropdownButtonFormField<String>(
          initialValue: _regJurusan,
          decoration: _inputDecoration(null),
          items: _jurusanList.map((j) => DropdownMenuItem(value: j, child: Text(j, style: SwissTheme.sans(size: 12)))).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _regJurusan = val);
          },
        ),
        const SizedBox(height: 12),

        _buildLabel('Nomor WhatsApp Aktif *'),
        TextField(
          controller: _regWaCtrl,
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration('Contoh: 081234567890', icon: Icons.phone_outlined),
        ),
        const SizedBox(height: 12),

        _buildLabel('Kata Sandi Baru (Min. 6 Karakter) *'),
        TextField(
          controller: _regPassCtrl,
          obscureText: _obscurePass,
          decoration: _inputDecoration('Buat kata sandi aman', icon: Icons.lock_outline),
        ),
        const SizedBox(height: 14),

        // Verification Badge Notice
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SwissColors.verifiedEmerald.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_user_outlined, color: SwissColors.verifiedEmerald, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kartu Tanda Mahasiswa (KTM/KRS) akan diverifikasi otomatis oleh tim admin sebelum aktivasi penuh.',
                  style: SwissTheme.sans(size: 11, color: const Color(0xFF065F46)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: SwissColors.rauschCoral,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            'Daftar Akun Mahasiswa',
            style: SwissTheme.display(size: 14, weight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDemoLoginBox() {
    return Container(
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
              const Icon(Icons.bolt, color: SwissColors.cautionAmber, size: 16),
              const SizedBox(width: 6),
              Text(
                'AKSES CEPAT DEMO MAHASISWA & ADMIN',
                style: SwissTheme.mono(size: 10, weight: FontWeight.w700, color: SwissColors.inkPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _quickLogin('iqbal_m', 'password'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SwissColors.inkPrimary,
                    side: const BorderSide(color: SwissColors.borderHairline),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Column(
                    children: [
                      Text('Mahasiswa', style: SwissTheme.display(size: 12, weight: FontWeight.w700)),
                      Text('@iqbal_m', style: SwissTheme.mono(size: 10, color: SwissColors.inkMuted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _quickLogin('admin', 'password'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SwissColors.inkPrimary,
                    side: const BorderSide(color: SwissColors.escrowIndigo),
                    backgroundColor: SwissColors.escrowIndigo.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Column(
                    children: [
                      Text('Admin Kampus', style: SwissTheme.display(size: 12, weight: FontWeight.w700, color: SwissColors.escrowIndigo)),
                      Text('@admin', style: SwissTheme.mono(size: 10, color: SwissColors.escrowIndigo)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: SwissTheme.sans(size: 12, weight: FontWeight.w600, color: SwissColors.inkPrimary)),
    );
  }

  InputDecoration _inputDecoration(String? hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 18, color: SwissColors.inkMuted) : null,
      hintStyle: SwissTheme.sans(size: 12, color: SwissColors.inkMuted),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: SwissColors.borderHairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: SwissColors.borderHairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: SwissColors.rauschCoral, width: 1.5),
      ),
    );
  }
}
