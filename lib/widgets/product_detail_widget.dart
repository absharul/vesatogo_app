import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vesatogo_app/provider/product_detail_provider.dart';
import 'package:vesatogo_app/utils/utils.dart';
import '../model/cart_model.dart';
import '../provider/cartdata_provider.dart';

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
  void initState() {
    super.initState();
    ref.read(cartProvider.notifier).loadCart();
  }

  int _calculateTotalQuantity(List<CartItem> cartItems) {
    return cartItems.fold(0, (total, item) => total + item.quantity);
  }


  @override
  Widget build(BuildContext context) {
    final productAsyncValue = ref.watch(productDetailProvider(widget.productId));
    final cartItems = ref.watch(cartProvider);
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
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  context.go('/cartpage');
                },
                icon: const Icon(Icons.shopping_cart, size: 30),
                color: Colors.white,
              ),
              if (cartItems.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        '${_calculateTotalQuantity(cartItems)}', // Total quantity of items
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
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
                              ref.read(cartProvider.notifier).addCartItem(CartItem(productId: product.id, quantity: 1));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart!')));
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
