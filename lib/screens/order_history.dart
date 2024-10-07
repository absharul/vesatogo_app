import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/order_provder.dart'; // Adjust the path as needed

class OrderHistoryPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch the list of orders from the OrderProvider
    final orders = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        centerTitle: true,
      ),
      body: orders.isEmpty
          ? const Center(child: Text('No orders found.'))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(order.name),
              subtitle: Text("Total: \$${order.totalPrice.toStringAsFixed(2)}"),
              trailing: Text(order.paymentMethod),
              onTap: () {
                // Navigate to order details page if needed
                // You can pass the order details to another page
                // context.go('/orderDetails', extra: order);
              },
            ),
          );
        },
      ),
    );
  }
}
