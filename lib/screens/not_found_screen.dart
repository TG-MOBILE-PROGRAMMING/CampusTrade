import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/swiss_theme.dart';

/// ============================================================================
/// 404 NOT FOUND SCREEN (404.PHP PARITY)
/// ============================================================================
class NotFoundScreen extends StatefulWidget {
  final CampusTradeState appState;
  const NotFoundScreen({super.key, required this.appState});

  @override
  State<NotFoundScreen> createState() => _NotFoundScreenState();
}

class _NotFoundScreenState extends State<NotFoundScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SwissColors.canvasWarm,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: SwissColors.canvasPure,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SwissColors.borderHairline),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: SwissColors.dangerRose.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: SwissColors.dangerRose.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: SwissColors.dangerRose,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'HTTP STATUS // 404 NOT FOUND',
                          style: SwissTheme.mono(
                              size: 10,
                              weight: FontWeight.w700,
                              color: SwissColors.dangerRose),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('404.', style: SwissTheme.display(size: 46, color: SwissColors.inkPrimary)),
                  const SizedBox(height: 6),
                  Text(
                    'Halaman atau Unit Inventaris Tidak Ditemukan',
                    style: SwissTheme.display(size: 17, color: SwissColors.inkPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tautan yang Anda akses kemungkinan telah ditarik dari katalog karena unit sudah terjual, atau alamat URL tidak terdaftar pada platform CampusTrade.',
                    style: SwissTheme.sans(
                        size: 12, color: SwissColors.inkSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: TextField(
                            controller: _searchCtrl,
                            textAlignVertical: TextAlignVertical.center,
                            style: SwissTheme.sans(size: 12, color: SwissColors.inkPrimary),
                            decoration: InputDecoration(
                              hintText: 'Cari kasur, dispenser, meja lipat...',
                              hintStyle: SwissTheme.sans(size: 12, color: SwissColors.inkMuted),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 0),
                              filled: true,
                              fillColor: SwissColors.canvasWarm,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(999),
                                borderSide: const BorderSide(color: SwissColors.borderHairline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(999),
                                borderSide: const BorderSide(color: SwissColors.inkPrimary, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          widget.appState.setSearchKeyword(_searchCtrl.text);
                          widget.appState.navigateTo('catalog');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SwissColors.rauschCoral,
                          foregroundColor: SwissColors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999)),
                        ),
                        child: Text(
                          'Cari',
                          style: SwissTheme.sans(size: 12, weight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => widget.appState.navigateTo('catalog'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SwissColors.inkPrimary,
                        side: const BorderSide(color: SwissColors.borderHairline),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)),
                      ),
                      child: Text(
                        'Kembali ke Katalog Utama',
                        style: SwissTheme.sans(size: 13, weight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: SwissColors.borderHairline),
                  ),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text('CAMPUSTRADE // BURSA MAHASISWA',
                          style: SwissTheme.mono(
                              size: 10, color: SwissColors.inkMuted)),
                      Text('HARDENED SERVER',
                          style: SwissTheme.mono(
                              size: 10, color: SwissColors.inkMuted)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
