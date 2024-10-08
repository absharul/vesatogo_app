import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/order_model.dart';
import '../utils/utils.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;

  OrderDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Detail",style: appBarStyleText,),
        centerTitle: true,
        backgroundColor: appBarColor,
        leading: IconButton(
          onPressed: () {
            context.go('/homepage');
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black
                )
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Shipping Address: ${order.address}", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text("Payment Method: ${order.paymentMethod}", style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text("Products:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              width: double.maxFinite,
              height: 300,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.black
                  )
              ),
              child: ListView.builder(
                  itemCount: order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return ListTile(
                      title: Text(item.title), // Product name
                      subtitle: Text("Quantity: ${item.quantity}"),
                      trailing: Text("\$${(item.price * item.quantity).toStringAsFixed(2)}"), // Total for each product
                    );
                  },
                ),
            ),
            const SizedBox(height: 20),
            Center(child: Text("Grand Total: \$${order.totalPrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
