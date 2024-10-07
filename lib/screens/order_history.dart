import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../provider/order_provder.dart'; // Adjust the path as needed

class OrderHistoryPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History",style: TextStyle(fontWeight: FontWeight.w500),),
        centerTitle: true,
      ),
      body: orders.isEmpty
          ? const Center(child: Text('No orders found.'))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm a'); // Change format as needed
          final String formattedDate = formatter.format(DateTime.parse(order.date));
          return GestureDetector(
            onTap: (){
              context.go('/order_detail',extra: order);
            },
            child: Card(
              child: Container(
                height: 200,
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          children: [
                            Text(order.name, style: const TextStyle(fontSize: 25.0,fontWeight: FontWeight.w500),),
                            const Expanded(child: SizedBox()),
                            Text("\$${order.totalPrice.toStringAsFixed(2)}",style: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.w600),),
                            const SizedBox(width: 10.0,)
                          ]),
                      Text("Address: ${order.address}",style: const TextStyle(fontSize: 16.0,fontWeight: FontWeight.w400),),
                      Text("Payment Method: ${order.paymentMethod}",style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),),
                      Text(
                        "Order Date: $formattedDate",
                        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                      ),
                      Text(
                        "Order id: ${order.orderId}",
                        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

        },
      ),
    );
  }
}

