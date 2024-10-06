import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vesatogo_app/provider/products_provider.dart';
import 'package:vesatogo_app/widgets/products_widget.dart';
import '../utils/utils.dart';


class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  bool _isSearch = false;

  @override
  void initState() {
    super.initState();
    ref.read(getProductsProvider.notifier).fetchProducts();
  }


  @override
  Widget build(BuildContext context) {

    final products = ref.watch(getProductsProvider) ;

    return Scaffold(
      appBar: AppBar(
        title: const Text("VESATOGO", style: appBarHomeStyleText,),
        backgroundColor: appBarColor,
        actions:  [
          if(_isSearch)
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
          IconButton(onPressed: () {
            setState(() {
              _isSearch = !_isSearch;
            });
          }, icon: const Icon(Icons.search_outlined,size: 30,),color: Colors.white,),
          const SizedBox(width: 15.0,)
        ],
      ),
      body: products.when(
        data: (products) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of cards per row
              childAspectRatio: 0.5,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2
            ),
            itemCount: products.length,
            itemBuilder: (BuildContext context, index) {
              final product = products[index];
              return ProductCard(product: product);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

