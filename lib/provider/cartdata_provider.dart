// import 'dart:convert';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../model/cart_model.dart';
//
// final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
//   return CartNotifier();
// });
//
// class CartNotifier extends StateNotifier<List<CartItem>> {
//   CartNotifier() : super([]) {
//     loadCart();
//   }
//
//   Future<void> loadCart() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final String? cartJson = prefs.getString('cart');
//
//     if (cartJson != null && cartJson.isNotEmpty) {
//       print('Loading cart data: $cartJson'); // Debugging statement
//       final List<dynamic> decodedData = jsonDecode(cartJson);
//       state = decodedData.map((item) => CartItem.fromJson(item)).toList();
//       print('Loaded cart items: $state'); // Debugging statement
//     } else {
//       print('No cart data found.'); // Debugging statement
//     }
//   }
//
//
//
//   Future<void> addCartItem(CartItem item) async {
//     final existingItemIndex = state.indexWhere((cartItem) => cartItem.productId == item.productId);
//
//     if (existingItemIndex != -1) {
//       // If the item already exists, increase the quantity
//       final existingItem = state[existingItemIndex];
//       final updatedItem = CartItem(
//         productId: existingItem.productId,
//         quantity: existingItem.quantity + item.quantity,
//       );
//
//       // Update the cart state
//       state[existingItemIndex] = updatedItem;
//     } else {
//       // If the item does not exist, add it to the cart
//       state = [...state, item];
//     }
//
//     // Save the updated cart to SharedPreferences
//     await saveCart();
//   }
//
//   void removeCartItem(int productId) {
//     state = state.where((item) => item.productId != productId).toList();
//     saveCart(); // Save updated cart to SharedPreferences
//   }
//
//
//   Future<void> saveCart() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final List<Map<String, dynamic>> cartJsonList = state.map((item) => item.toJson()).toList(); // Use toJson directly
//     await prefs.setString('cart', jsonEncode(cartJsonList)); // Store as a JSON string
//   }
//
//
//   Future<void> clearCart() async {
//     state = [];
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('cart'); // Clear cart data in SharedPreferences
//   }
// }
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
      print('Loading cart data: $cartJson'); // Debugging statement
      final List<dynamic> decodedData = jsonDecode(cartJson);
      state = decodedData.map((item) => CartItem.fromJson(item)).toList();
      print('Loaded cart items: $state'); // Debugging statement
    } else {
      print('No cart data found.'); // Debugging statement
    }
  }

  Future<void> addCartItem(CartItem item) async {
    final existingItemIndex = state.indexWhere((cartItem) => cartItem.productId == item.productId);

    if (existingItemIndex != -1) {
      // If the item already exists, increase the quantity
      final existingItem = state[existingItemIndex];
      final updatedItem = CartItem(
        productId: existingItem.productId,
        quantity: existingItem.quantity + item.quantity,
      );

      // Update the cart state
      state[existingItemIndex] = updatedItem;
    } else {
      // If the item does not exist, add it to the cart
      state = [...state, item];
    }

    // Save the updated cart to SharedPreferences
    await saveCart();
  }

  void removeItem(int productId) {
    state = state.where((item) => item.productId != productId).toList();
    saveCart(); // Save updated cart to SharedPreferences
  }

  Future<void> updateQuantity(int productId, int newQuantity) async {
    final existingItemIndex = state.indexWhere((item) => item.productId == productId);

    if (existingItemIndex != -1) {
      // Update the quantity
      final existingItem = state[existingItemIndex];
      final updatedItem = CartItem(
        productId: existingItem.productId,
        quantity: newQuantity,
      );

      // If the new quantity is zero, remove the item
      if (newQuantity <= 0) {
        removeItem(productId);
      } else {
        state[existingItemIndex] = updatedItem; // Update the item in the state
      }

      // Save the updated cart to SharedPreferences
      await saveCart();
    }
  }

  Future<void> saveCart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> cartJsonList = state.map((item) => item.toJson()).toList();
    await prefs.setString('cart', jsonEncode(cartJsonList)); // Store as a JSON string
  }

  Future<void> clearCart() async {
    state = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart'); // Clear cart data in SharedPreferences
  }
}
