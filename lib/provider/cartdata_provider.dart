import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/cart_model.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]) {
    loadCart();
  }

  Future<void> loadCart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cartJson = prefs.getString('cart');

    if (cartJson != null && cartJson.isNotEmpty) {
      print('Loading cart data: $cartJson');
      final List<dynamic> decodedData = jsonDecode(cartJson);
      state = decodedData.map((item) => CartItem.fromJson(item)).toList();
      print('Loaded cart items: $state');
    } else {
      print('No cart data found.');
    }
  }

  Future<void> addCartItem(CartItem item) async {
    final existingItemIndex = state.indexWhere((cartItem) => cartItem.productId == item.productId);

    if (existingItemIndex != -1) {
      final existingItem = state[existingItemIndex];
      final updatedItem = CartItem(
        productId: existingItem.productId,
        quantity: existingItem.quantity + item.quantity,
        price: existingItem.price,
        title: existingItem.title,

      );

      state[existingItemIndex] = updatedItem;
    } else {
      state = [...state, item];
    }

    await saveCart();
  }

  void removeItem(int productId) {
    state = state.where((item) => item.productId != productId).toList();
    saveCart();
  }

  Future<void> updateQuantity(int productId, int newQuantity) async {
    final existingItemIndex = state.indexWhere((item) => item.productId == productId);

    if (existingItemIndex != -1) {
      final existingItem = state[existingItemIndex];
      final updatedItem = CartItem(
        productId: existingItem.productId,
        quantity: newQuantity,
        price: existingItem.price,
        title: existingItem.title,
      );


      if (newQuantity <= 0) {
        removeItem(productId);
      } else {
        state[existingItemIndex] = updatedItem;
      }
      await saveCart();
    }
  }

  Future<void> saveCart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> cartJsonList = state.map((item) => item.toJson()).toList();
    await prefs.setString('cart', jsonEncode(cartJsonList));
  }

  Future<void> clearCart() async {
    state = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart');
  }
}
