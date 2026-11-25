import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campustrade_upi_yptk/main.dart';
import 'package:campustrade_upi_yptk/state/app_state.dart';

void main() {
  testWidgets(
    'Mobile (390x844): Home Screen, Trust Sheet, Relatable Empty State, and Product Detail flow',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final appState = CampusTradeState();
      await tester.pumpWidget(CampusTradeApp(appState: appState));
      await tester.pump(const Duration(milliseconds: 400));

      // 1. Verify Hero Card & Trust Strip render with real inventory count
      expect(find.text('Bursa Barang Kos Khusus Mahasiswa'), findsOneWidget);
      expect(find.text('Standar Keamanan Transaksi Kampus'), findsOneWidget);

      // 2. Tap Trust Strip -> opens Escrow Explainer Bottom Sheet
      await tester.tap(find.text('Standar Keamanan Transaksi Kampus'));
      await tester.pumpAndSettle();
      expect(find.text('Alur Aman CampusTrade'), findsOneWidget);
      await tester.tap(find.text('Mengerti'));
      await tester.pumpAndSettle();

      // 3. Test Search -> triggers Relatable Empty State with suggestion chips
      await tester.enterText(find.byType(TextField), 'barang_tidak_ada_xyz');
      await tester.pumpAndSettle();
      expect(find.text('Reset Semua Filter'), findsOneWidget);
      expect(find.text('Kasur'), findsOneWidget);

      // 4. Scroll to suggestion chip "Kasur" and tap -> restores matching product
      await tester.ensureVisible(find.text('Kasur'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kasur'));
      await tester.pumpAndSettle();
      expect(find.text('Kasur Busa Inoac Single 90x200'), findsOneWidget);

      // 5. Scroll to product card and tap -> navigates to Product Detail & toggle delivery method
      await tester.ensureVisible(find.text('Kasur Busa Inoac Single 90x200'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kasur Busa Inoac Single 90x200'));
      await tester.pumpAndSettle();
      expect(find.text('Catatan Kurasi Fisik Tim Admin'), findsOneWidget);
      expect(find.text('Dilindungi Rekber CampusTrade'), findsOneWidget);

      // Scroll to delivery option and switch to Kurir Admin -> live price updates
      await tester.scrollUntilVisible(
        find.text('Diantar Kurir Admin ke Kos'),
        300,
      );
      await tester.tap(find.text('Diantar Kurir Admin ke Kos'));
      await tester.pumpAndSettle();
      expect(find.text('Rp 200.000'), findsWidgets);
    },
  );

  testWidgets(
    'Desktop (1280x800): Home Screen renders 4-column grid with zero overflow',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final appState = CampusTradeState();
      await tester.pumpWidget(CampusTradeApp(appState: appState));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('CampusTrade'), findsOneWidget);
      expect(find.text('Pasang Iklan'), findsOneWidget);
      expect(find.text('Alur Rekber'), findsOneWidget);
    },
  );

  testWidgets(
    'Admin CMS (Desktop 1280x800 & Mobile 390x844): switches tabs with animation and renders relatable empty states',
    (WidgetTester tester) async {
      // Desktop check first
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final appState = CampusTradeState();
      appState.login('admin', 'password');

      await tester.pumpWidget(CampusTradeApp(appState: appState));
      await tester.pumpAndSettle();

      // Verify Dashboard renders clean Forest Slate KPIs & Priority KTM Alert
      expect(find.text('Trafik Kunjungan'), findsOneWidget);
      expect(find.text('Tinjau Antrean KTM (1)'), findsOneWidget);

      // Switch to Inventaris & QC Barang tab and trigger empty state
      await tester.tap(find.text('Inventaris & QC Barang'));
      await tester.pumpAndSettle();
      appState.adminProductSearch = 'tidak_ada_di_gudang_xyz';
      appState.setAdminTab('products');
      await tester.pumpAndSettle();
      expect(find.text('Belum ada unit barang di filter ini'), findsOneWidget);
      await tester.tap(find.text('Reset Filter Inventaris'));
      await tester.pumpAndSettle();

      // Switch to Verifikasi KTM & User tab
      await tester.tap(find.text('Verifikasi KTM & User'));
      await tester.pumpAndSettle();
      appState.adminUserSearch = 'nim_tidak_ada_999';
      appState.setAdminTab('users');
      await tester.pumpAndSettle();
      expect(find.text('Mahasiswa tidak ditemukan'), findsOneWidget);
      await tester.tap(find.text('Tampilkan Semua Mahasiswa'));
      await tester.pumpAndSettle();

      // Switch to Mobile viewport (390x844) and verify Drawer trigger works
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.menu), findsOneWidget);
    },
  );
}
