import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vesatogo_app/utils/utils.dart';
import '../model/cart_model.dart';
import '../model/order_model.dart';
import '../provider/cartdata_provider.dart';
import '../provider/order_provder.dart';
import '../provider/product_detail_provider.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _address = '';
  DateTime _orderDate = DateTime.now();

  double getTotalPrice(List<CartItem> cartItems) {
    double total = 0.0;
    for (var item in cartItems) {
      final productAsyncValue = ref.read(productDetailProvider(item.productId));
      if (productAsyncValue.hasValue) {
        total += productAsyncValue.value!.price * item.quantity;
      }
    }
    return total;
  }

  void _showCashConfirmationDialog(List<CartItem> cartItems, double totalPrice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Order"),
          content: Text("Do you want to place the order for \$${totalPrice.toStringAsFixed(2)}?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Confirm"),
              onPressed: () {
                _saveOrder("Cash", cartItems, totalPrice);
                context.go('/homepage');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final cartItems = ref.watch(cartProvider);
    final totalPrice = getTotalPrice(cartItems);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout",style: appBarStyleText,),
        centerTitle: true,
        backgroundColor: appBarColor,
        leading: IconButton(
          onPressed: () {
            context.go('/cartpage');
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        ),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = cartItems[index];
                  final productAsyncValue =
                  ref.watch(productDetailProvider(cartItem.productId));
                  return productAsyncValue.when(
                    data: (product) {
                      return ListTile(
                        title: Text(product.title),
                        subtitle: Text('Quantity: ${cartItem.quantity}'),
                        trailing: Text('\$${(product.price * cartItem.quantity).toStringAsFixed(2)}'),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, _) => Text('Error: $error'),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Total: \$${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text("Shipping Information", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value!;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _address = value!;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _showCashConfirmationDialog(cartItems, totalPrice);
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text("Cash", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final order = Order(
                        name: _name,
                        address: _address,
                        paymentMethod: "Cards/UPI",
                        items: cartItems,
                        date: _orderDate.toIso8601String(),
                        totalPrice: totalPrice,
                      );
                      context.go('/cardpayment', extra: order);
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text("Cards/UPI", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveOrder(String paymentMethod, List<CartItem> cartItems, double totalPrice) {
    final orderItems = cartItems.map((item) {
      final productAsyncValue = ref.read(productDetailProvider(item.productId));
      final product = productAsyncValue.value;
      return CartItem(
        productId: item.productId,
        quantity: item.quantity,
        price: product?.price ?? 0.0,
        title: product?.title ?? "Unknown Product",
      );
    }).toList();

    final order = Order(
      name: _name,
      address: _address,
      paymentMethod: paymentMethod,
      items: orderItems,
      date: _orderDate.toIso8601String(),
      totalPrice: totalPrice,
    );

    ref.read(orderProvider.notifier).saveOrder(order).then((_) {
      ref.read(cartProvider.notifier).clearCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: ${error.toString()}')),
      );
    });
  }

}
