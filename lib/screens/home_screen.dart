import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vesatogo_app/provider/cartdata_provider.dart';
import 'package:vesatogo_app/provider/products_provider.dart';
import 'package:vesatogo_app/screens/order_history.dart';
import 'package:vesatogo_app/widgets/products_widget.dart';
import '../model/cart_model.dart';
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


  final List<Widget> _widgetOptions = <Widget>[
    Text('Home Screen'),
    Text('Search Screen'),
    OrderHistoryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  void initState() {
    super.initState();
    ref.read(getProductsProvider.notifier).fetchProducts();
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
    final products = ref.watch(getProductsProvider);
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
                child: const SearchBar(
                  hintText: 'Search',
                ),
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
                  ref.read(getProductsProvider.notifier).fetchProducts(); // Retry fetching products
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      )
          : _selectedIndex == 1
          ? const Center(child: Text('Search Screen')) // Replace with your Search Widget
          : OrderHistoryPage(), // For the Orders tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Set the current index
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Orders',
          ),
        ],
      ),
    );
  }

}
