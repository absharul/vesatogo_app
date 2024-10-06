import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vesatogo_app/provider/product_detail_provider.dart';
import '../provider/cartdata_provider.dart';
import '../utils/utils.dart';

class CartPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("CART", style: appBarHomeStyleText),
        centerTitle: true,
        backgroundColor: appBarColor,
        leading: IconButton(
          onPressed: () {
            context.go('/');
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white,size: 30,),
        ),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Cart is Empty.'))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final cartItem = cartItems[index];

          // Fetch product details for each item in the cart
          final productAsyncValue = ref.watch(productDetailProvider(cartItem.productId));

          return productAsyncValue.when(
            data: (product) {
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: double.infinity,
                    child: CachedNetworkImage(imageUrl: product.image, fit: BoxFit.cover,),
                  ),
                  title: Text(product.title),
                  subtitle: Text('Quantity: ${cartItem.quantity} \nPrice: \$${(product.price * cartItem.quantity).toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      ref.read(cartProvider.notifier).removeCartItem(cartItem.productId);
                    },
                  ),
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text("Loading..."),
                trailing: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Center(child: Text('Error fetching product details: $error')),
          );
        },
      ),
    );
  }
}
