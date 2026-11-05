import 'package:flutter/material.dart';
import 'screens/admin_cms_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/not_found_screen.dart';
import 'state/app_state.dart';
import 'theme/swiss_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CampusTradeApp());
}

class CampusTradeApp extends StatefulWidget {
  const CampusTradeApp({super.key});

  @override
  State<CampusTradeApp> createState() => _CampusTradeAppState();
}

class _CampusTradeAppState extends State<CampusTradeApp> {
  final CampusTradeState _appState = CampusTradeState();
  bool _showPreloader = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) {
        setState(() => _showPreloader = false);
      }
    });
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusTrade — Bursa Inventaris & Perabotan Kos UPI YPTK Padang',
      debugShowCheckedModeBanner: false,
      theme: SwissTheme.lightTheme,
      home: AnimatedBuilder(
        animation: _appState,
        builder: (context, _) {
          return Stack(
            children: [
              _buildCurrentRoute(),
              if (_showPreloader) _buildEditorialPreloader(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentRoute() {
    switch (_appState.currentRoute) {
      case 'admin':
        return AdminCmsScreen(appState: _appState);
      case 'not_found':
        return NotFoundScreen(appState: _appState);
      default:
        return CatalogScreen(appState: _appState);
    }
  }

  Widget _buildEditorialPreloader() {
    return Material(
      color: const Color(0xCCFFFFFF),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: SwissColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SwissColors.zinc200),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1409090B),
                blurRadius: 24,
                offset: Offset(0, 8),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 34,
                height: 34,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: SwissColors.zinc950,
                    ),
                    Text('CT', style: SwissTheme.display(size: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('CAMPUSTRADE', style: SwissTheme.display(size: 12)),
                      const SizedBox(width: 6),
                      Text('v2.4',
                          style: SwissTheme.mono(
                              size: 10, color: SwissColors.zinc400)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'UPI YPTK PADANG // LUBUK BEGALUNG',
                    style:
                        SwissTheme.mono(size: 10, color: SwissColors.zinc500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
