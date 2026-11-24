import 'package:flutter/material.dart';
import '../models/models.dart';
import '../screens/auth_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/sell_product_screen.dart';
import '../state/app_state.dart';

/// ============================================================================
/// ZERO-MODAL NATIVE NAVIGATION ADAPTERS
/// [Anti-Slop UI Architecture: Eliminates all heavy blocking modal popups]
/// All user interactions now navigate to dedicated, full-featured native screens.
/// ============================================================================

/// Replaces modal dialog with dedicated full-screen Product Detail page.
void showProductDetailModal(
  BuildContext context,
  CampusTradeState appState,
  ProductModel product,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ProductDetailScreen(appState: appState, product: product),
    ),
  );
}

/// Replaces modal dialog with dedicated full-screen Sell Listing page.
void showSellProductModal(BuildContext context, CampusTradeState appState) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => SellProductScreen(appState: appState),
    ),
  );
}

/// Replaces modal dialog with dedicated full-screen Student Authentication page.
void showAuthModal(
  BuildContext context,
  CampusTradeState appState, {
  String initialTab = 'login',
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AuthScreen(appState: appState, initialTab: initialTab),
    ),
  );
}
