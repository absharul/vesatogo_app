import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vesatogo_app/provider/product_detail_provider.dart';
import '../provider/cartdata_provider.dart';
import '../utils/utils.dart';

class CartPage extends ConsumerStatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  late Map<int, int> localQuantities;

  @override
  void initState() {
    super.initState();
    final cartItems = ref.read(cartProvider);
    localQuantities = {for (var item in cartItems) item.productId: item.quantity};
  }

  double getTotalPrice(List cartItems) {
    double total = 0.0;
    for (var item in cartItems) {
      final productAsyncValue = ref.read(productDetailProvider(item.productId));
      if (productAsyncValue.hasValue) {
        total += productAsyncValue.value!.price * localQuantities[item.productId]!;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("CART", style: appBarHomeStyleText),
        centerTitle: true,
        backgroundColor: appBarColor,
        leading: IconButton(
          onPressed: () {
            context.go('/homepage');
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        ),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Cart is Empty.'))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final cartItem = cartItems[index];
          final productAsyncValue = ref.watch(productDetailProvider(cartItem.productId));

          return productAsyncValue.when(
            data: (product) {
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  child: Row(
                    children: [
                      Container(
                        height: double.maxFinite,
                        width: 100,
                        decoration: const BoxDecoration(color: Colors.white),
                        child: CachedNetworkImage(imageUrl: product.image, fit: BoxFit.contain),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10.0),
                            Text(
                              product.title,
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10.0),
                            Text('Quantity: ${localQuantities[cartItem.productId]}'),
                            const SizedBox(height: 10.0),
                            Text(
                              'Price: \$${(product.price * localQuantities[cartItem.productId]!).toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 20.0),
                            ),
                            const SizedBox(height: 20.0),
                            Padding(
                              padding: const EdgeInsets.only(left: 140),
                              child: Container(
                                height: 40,
                                width: 130.15,
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (localQuantities[cartItem.productId]! > 1) {
                                          // Update locally
                                          setState(() {
                                            localQuantities[cartItem.productId] = localQuantities[cartItem.productId]! - 1;
                                          });
                                          // Update in provider
                                          ref.read(cartProvider.notifier).updateQuantity(
                                            cartItem.productId,
                                            localQuantities[cartItem.productId]!,
                                          );
                                        } else {
                                          ref.read(cartProvider.notifier).removeItem(cartItem.productId);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('${product.title} removed from cart')),
                                          );
                                        }
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '-',
                                            style: TextStyle(fontSize: 25.0, color: Colors.blueAccent),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Text(
                                      '${localQuantities[cartItem.productId]}',
                                      style: const TextStyle(fontSize: 16.0, color: Colors.white),
                                    ),
                                    const SizedBox(width: 20),
                                    GestureDetector(
                                      onTap: () {
                                        // Update locally
                                        setState(() {
                                          localQuantities[cartItem.productId] = localQuantities[cartItem.productId]! + 1;
                                        });
                                        // Update in provider
                                        ref.read(cartProvider.notifier).updateQuantity(
                                          cartItem.productId,
                                          localQuantities[cartItem.productId]!,
                                        );
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '+',
                                            style: TextStyle(fontSize: 24, color: Colors.blueAccent),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text("Loading..."),
              ),
            ),
            error: (error, _) => Center(child: Text('Error fetching product details: $error')),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: \$${getTotalPrice(cartItems).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: (){
                context.go('/checkout');
              },
              child: Container(
                height: 40,
                width: 150,
                decoration: containerButton,
                child: const Center(
                  child: Text("Checkout",style: buttonText,),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
