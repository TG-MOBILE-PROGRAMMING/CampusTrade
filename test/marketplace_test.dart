import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campustrade_upi_yptk/main.dart';
import 'package:campustrade_upi_yptk/state/app_state.dart';
import 'package:campustrade_upi_yptk/screens/product_detail_screen.dart';
import 'package:campustrade_upi_yptk/screens/sell_product_screen.dart';
import 'package:campustrade_upi_yptk/screens/auth_screen.dart';
import 'package:campustrade_upi_yptk/screens/admin_cms_screen.dart';
import 'package:campustrade_upi_yptk/theme/swiss_theme.dart';

void main() {
  testWidgets('Marketplace smoke test: renders Catalog and brand elements', (tester) async {
    final state = CampusTradeState();
    await tester.pumpWidget(CampusTradeApp(appState: state));
    await tester.pumpAndSettle();

    expect(find.text('CampusTrade'), findsWidgets);
    expect(find.text('Semua Unit'), findsWidgets);
  });

  testWidgets('Navigation: opens dedicated ProductDetailScreen on card tap without modal', (tester) async {
    final state = CampusTradeState();
    await tester.pumpWidget(CampusTradeApp(appState: state));
    await tester.pumpAndSettle();

    final firstProduct = state.filteredCatalogProducts.first;
    final itemFinder = find.text(firstProduct.namaBarang);
    expect(itemFinder, findsWidgets);

    await tester.tap(itemFinder.first);
    await tester.pumpAndSettle();

    // Verify we are now on ProductDetailScreen
    expect(find.byType(ProductDetailScreen), findsOneWidget);
    expect(find.text('Detail Produk'), findsOneWidget);
    expect(find.text('Pesan Sekarang', skipOffstage: false), findsWidgets);
  });

  testWidgets('Wishlist: toggles favorite status cleanly', (tester) async {
    final state = CampusTradeState();
    expect(state.isFavorite(999), isFalse);
    state.toggleFavorite(999);
    expect(state.isFavorite(999), isTrue);
    state.toggleFavorite(999);
    expect(state.isFavorite(999), isFalse);
  });

  testWidgets('Auth: login works and updates current user state', (tester) async {
    final state = CampusTradeState();
    expect(state.currentUser, isNull);

    final err = state.login('iqbal_m', 'password');
    expect(err, isNull);
    expect(state.currentUser, isNotNull);
    expect(state.currentUser?.username, 'iqbal_m');

    state.logout();
    expect(state.currentUser, isNull);
  });

  testWidgets('Screens instantiate cleanly', (tester) async {
    final state = CampusTradeState();
    final product = state.products.first;

    // Test SellProductScreen pump
    await tester.pumpWidget(MaterialApp(home: SellProductScreen(appState: state)));
    expect(find.text('Pasang Iklan Barang Kos'), findsOneWidget);

    // Test AuthScreen pump
    await tester.pumpWidget(MaterialApp(home: AuthScreen(appState: state)));
    expect(find.text('Akun Mahasiswa UPI YPTK'), findsOneWidget);

    // Test ProductDetailScreen pump
    await tester.pumpWidget(MaterialApp(home: ProductDetailScreen(appState: state, product: product)));
    expect(find.text('Detail Produk'), findsOneWidget);
  });

  testWidgets('Admin CMS Screen instantiates and displays CampusTrade console', (tester) async {
    final state = CampusTradeState();
    state.login('admin', 'password');

    await tester.pumpWidget(MaterialApp(
      theme: SwissTheme.darkAdminTheme,
      home: AdminCmsScreen(appState: state),
    ));
    expect(find.text('CampusTrade'), findsWidgets);
    expect(find.text('Ringkasan & Trafik'), findsWidgets);
  });
}
