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
      backgroundColor: SwissColors.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: SwissColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SwissColors.zinc200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: SwissColors.zinc100,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: SwissColors.zinc200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: SwissColors.rose500,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'HTTP STATUS // 404 NOT FOUND',
                          style: SwissTheme.mono(
                              size: 10, color: SwissColors.zinc700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('404.', style: SwissTheme.display(size: 46)),
                  const SizedBox(height: 6),
                  Text(
                    'Halaman atau Unit Inventaris Tidak Ditemukan',
                    style: SwissTheme.display(size: 17),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tautan yang Anda akses kemungkinan telah ditarik dari katalog karena unit sudah terjual, atau alamat URL tidak terdaftar pada server CampusTrade UPI YPTK.',
                    style: SwissTheme.sans(
                        size: 12, color: SwissColors.zinc500, height: 1.5),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          style: SwissTheme.sans(size: 12),
                          decoration: InputDecoration(
                            hintText: 'Cari kasur, dispenser, meja lipat...',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 11),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
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
                          backgroundColor: SwissColors.zinc950,
                          foregroundColor: SwissColors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Cari'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => widget.appState.navigateTo('catalog'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SwissColors.zinc950,
                        foregroundColor: SwissColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Kembali ke Katalog Utama'),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('CAMPUSTRADE // UPI YPTK',
                          style: SwissTheme.mono(
                              size: 10, color: SwissColors.zinc400)),
                      Text('HARDENED SERVER',
                          style: SwissTheme.mono(
                              size: 10, color: SwissColors.zinc400)),
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
