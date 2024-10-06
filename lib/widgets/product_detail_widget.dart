import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vesatogo_app/provider/product_detail_provider.dart';
import 'package:vesatogo_app/utils/utils.dart';

class ProductDetailWidget extends ConsumerWidget {
  final int productId;

  const ProductDetailWidget({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsyncValue = ref.watch(productDetailProvider(productId)); // Fetch product using provider

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          productAsyncValue.when(
            data: (product) => SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      product.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const SizedBox(width: 20.0),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                        ),
                        const Expanded(child: SizedBox()),
                        Container(
                          height: 40,
                          width: 150,
                          decoration: containerButton,
                          child: TextButton(
                            onPressed: () {
                              // Add your cart logic here
                            },
                            child: const Center(
                              child: Text("Add to Cart", style: buttonText),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20.0),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      product.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Rating: ${product.rating.rate} (${product.rating.count} reviews)',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              onPressed: () {
                context.go('/');
              },
              icon: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
