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
  final CampusTradeState? appState;
  const CampusTradeApp({super.key, this.appState});

  @override
  State<CampusTradeApp> createState() => _CampusTradeAppState();
}

class _CampusTradeAppState extends State<CampusTradeApp> {
  late final CampusTradeState _appState;

  @override
  void initState() {
    super.initState();
    _appState = widget.appState ?? CampusTradeState();
  }

  @override
  void dispose() {
    if (widget.appState == null) {
      _appState.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusTrade: Bursa Inventaris Kos Mahasiswa (UPI YPTK Padang)',
      debugShowCheckedModeBanner: false,
      theme: SwissTheme.lightTheme,
      home: AnimatedBuilder(
        animation: _appState,
        builder: (context, _) => _buildCurrentRoute(),
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
}
