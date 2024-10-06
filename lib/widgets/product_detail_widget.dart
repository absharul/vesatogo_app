import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vesatogo_app/provider/product_detail_provider.dart';
import 'package:vesatogo_app/utils/utils.dart';

class ProductDetailWidget extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailWidget({Key? key, required this.productId}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProductDetailWidgetState();
}

class _ProductDetailWidgetState extends ConsumerState<ProductDetailWidget> {
  bool _isSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final productAsyncValue = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("VESATOGO", style: appBarHomeStyleText),
        backgroundColor: appBarColor,
        actions: [
          if (_isSearch)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: const SearchBar(
                    hintText: 'Search',
                  )
              ),
            ),
          IconButton(
            onPressed: () {
              setState(() {
                _isSearch = !_isSearch;
                if (!_isSearch) {
                  _searchController.clear(); // Clear search on close
                }
              });
            },
            icon: const Icon(Icons.search_outlined, size: 30),
            color: Colors.white,
          ),
          const SizedBox(width: 15.0),
          IconButton(
            onPressed: () {
              // Handle cart action
            },
            icon: const Icon(Icons.shopping_cart, size: 30),
            color: Colors.white,
          ),
          const SizedBox(width: 15.0),
        ],
        leading: IconButton(
          onPressed: () {
            context.go('/');
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: productAsyncValue.when(
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
                    Text(product.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(width: 20.0),
                        Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Container(
                          height: 40,
                          width: 150,
                          decoration: containerButton,
                          child: TextButton(
                            onPressed: () {
                              // Add to cart logic here
                            },
                            child: const Center(child: Text("Add to Cart", style: buttonText)),
                          ),
                        ),
                        const SizedBox(width: 20.0),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(product.description, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    Text('Rating: ${product.rating.rate} (${product.rating.count} reviews)', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
    );
  }
}
