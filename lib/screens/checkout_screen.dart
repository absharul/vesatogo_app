import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vesatogo_app/utils/utils.dart';
import '../model/cart_model.dart';
import '../model/order_model.dart'; // Ensure to import your Order model
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

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final totalPrice = getTotalPrice(cartItems);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout", style: appBarStyleText),
        centerTitle: true,
        backgroundColor: appBarColor,
        leading: IconButton(
          onPressed: () {
            context.go('/cartpage');
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                      _saveOrder("Cash", cartItems, totalPrice);
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 150,
                    decoration: containerButton,
                    child: const Center(
                      child: Text("Cash", style: buttonText),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _saveOrder("Cards/UPI", cartItems, totalPrice);
                      context.go('/cardpayment');
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 150,
                    decoration: containerButton,
                    child: const Center(
                      child: Text("Cards/UPI", style: buttonText),
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
    // Create the order using CartItems
    final order = Order(
      name: _name,
      address: _address,
      paymentMethod: paymentMethod,
      items: cartItems, // Directly use the CartItem list
      totalPrice: totalPrice,
    );

    // Save the order using the OrderProvider
    ref.read(orderProvider.notifier).saveOrder(order).then((_) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed for $_name at $_address')),
      );

      // Clear cart after checkout
      ref.read(cartProvider.notifier).clearCart();

      // Delay navigation to ensure the state is updated
      Future.delayed(Duration(seconds: 1), () {
        if (paymentMethod == "Cards/UPI") {
          context.go('/cardpayment');
        } else {
          Navigator.pop(context); // Go back to the previous page
        }
      });
    }).catchError((error) {
      // Handle any errors that occur during saving
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $error')),
      );
    });
  }

}
