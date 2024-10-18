import 'package:flutter_application_5/service/FirebaseService.dart';
import 'package:intl/intl.dart';

class CartScreenController {
  final FirebaseService _firebaseService =
      FirebaseService(); // Instancia de FirebaseService

  List<dynamic> getCartItems() {
    return Cart.items;
  }

  double getTotal() {
    return Cart.getTotal();
  }

  void removeItem(dynamic item) {
    Cart.removeItem(item);
  }

  Future<void> processSale() async {
    final cartItems = getCartItems();
    final total = getTotal();

    if (cartItems.isNotEmpty) {
      await _firebaseService.addVenta(
          cartItems.cast<Map<String, dynamic>>(), total);
      clearCart();
    }
  }

  String generateTicketDetails() {
    final cartItems = getCartItems();
    final total = getTotal();
    String ticketDetails = '';

    for (var item in cartItems) {
      ticketDetails +=
          '${item['name']} - \$${item['price'].toStringAsFixed(2)}\n';
    }
    ticketDetails += '\nTotal: \$${total.toStringAsFixed(2)}';

    return ticketDetails;
  }

  String getCurrentDate() {
    return DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());
  }

  void clearCart() {
    Cart.clear();
  }
}

// cart.dart
class Cart {
  static final List<Map<String, dynamic>> items = [];

  static void addItem(Map<String, dynamic> item) {
    items.add(item);
  }

  static void removeItem(Map<String, dynamic> item) {
    // Eliminar el item basado en un identificador único, por ejemplo, 'barcode'
    items.removeWhere((cartItem) => cartItem['barcode'] == item['barcode']);
  }

  static double getTotal() {
    return items.fold(0, (sum, item) => sum + (item['price'] ?? 0));
  }

  static void clear() {
    items.clear();
  }
}
