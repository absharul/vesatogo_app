import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/order_model.dart'; // Import your Order model

class OrderProvider extends StateNotifier<List<Order>> {
  OrderProvider() : super([]) {
    loadOrders();
  }

  // Load orders from SharedPreferences
  Future<void> loadOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ordersJson = prefs.getString('orders');

    if (ordersJson != null) {
      List<dynamic> decodedOrders = jsonDecode(ordersJson);
      state = decodedOrders.map((order) => Order.fromJson(order)).toList();
    }
  }

  // Save order to SharedPreferences
  Future<void> saveOrder(Order order) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = [...state, order]; // Add new order to the list
    await prefs.setString('orders', jsonEncode(state.map((o) => o.toJson()).toList()));
  }

  // Clear orders from SharedPreferences
  Future<void> clearOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('orders');
    state = []; // Clear the state
  }
}

// Provider instance
final orderProvider = StateNotifierProvider<OrderProvider, List<Order>>((ref) {
  return OrderProvider();
});
