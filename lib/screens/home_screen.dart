import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vesatogo_app/provider/cartdata_provider.dart';
import 'package:vesatogo_app/provider/products_provider.dart';
import 'package:vesatogo_app/screens/order_history.dart';
import 'package:vesatogo_app/screens/user_tab.dart';
import 'package:vesatogo_app/widgets/products_widget.dart';
import '../model/cart_model.dart';
import '../provider/filter_provider.dart';
import '../utils/utils.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  bool _isSearch = false;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  String? _selectedCategory;

  final List<String> _categories = [
    'Electronics',
    'Jewelery',
    "Men's Clothing",
    "Women's Clothing",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category == "Show All"? null : category;
    });
  }

  @override
  void initState() {
    super.initState();
    ref.read(getProductsProvider.notifier).fetchProducts(_searchController.text.trim());
    ref.read(cartProvider.notifier).loadCart();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _calculateTotalQuantity(List<CartItem> cartItems) {
    return cartItems.fold(0, (total, item) => total + item.quantity);
  }

  @override
  Widget build(BuildContext context) {
    final products = _selectedCategory != null
        ? ref.watch(filterProductProvider(_selectedCategory!))
        : ref.watch(getProductsProvider);

    final cartItems = ref.watch(cartProvider);

    return Scaffold(
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
                child: SearchBar(
                  onChanged: (value){
                    _searchController.text = value;
                    if(value.length > 4 || value.isEmpty) {
                      ref.read(getProductsProvider.notifier).fetchProducts(
                          _searchController.text
                              .trim());   // Retry fetching products
                    }
                  },
                  hintText: 'Search',
                ),
              ),
            ),
          IconButton(
            onPressed: () {
              setState(() {
                _isSearch = !_isSearch;
                if (!_isSearch) {
                  _searchController.clear();
                }
              });
            },
            icon: const Icon(Icons.search_outlined, size: 30),
            color: Colors.white,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt_outlined, size: 30, color: Colors.white),
            itemBuilder: (BuildContext context) {
              return _categories.map((String category) {
                return PopupMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList()..add(
                const PopupMenuItem<String>(
                  value: "Show All",
                  child: Text('Show All'),
                ),
              );
            },
            onSelected: _onCategorySelected,
          ),
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
                        '${_calculateTotalQuantity(cartItems)}',
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
      ),
      body: _selectedIndex == 0
          ? products.when(
        data: (products) {
          return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.5,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: products.length,
              itemBuilder: (BuildContext context, index) {
                final product = products[index];
                return ProductCard(product: product);
              },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              TextButton(
                onPressed: () {
                  ref.read(getProductsProvider.notifier).fetchProducts(_searchController.text.trim());
                },
                child: const Text('Retry'),
              ),
            ],
          ),

        ),
      )
          : _selectedIndex == 1
          ?  OrderHistoryPage()
          :  const UserTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
      ),
    );
  }

}
