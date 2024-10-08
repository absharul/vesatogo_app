// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:vesatogo_app/model/products_model.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// final filterProductProvider = StateNotifierProvider.family<FilterProductNotifier,AsyncValue<ProductsModel>, String>((ref, productCategory){
//   return FilterProductNotifier()..fetchProduct(productCategory);
// });
//
// class FilterProductNotifier extends StateNotifier<AsyncValue<ProductsModel>> {
//   FilterProductNotifier() : super(const AsyncValue.loading());
//
//   Future<void> fetchProduct(String category) async {
//     try {
//       final response = await http.get(Uri.parse('https://fakestoreapi.com/products/category/$category'));
//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         final product = ProductsModel.fromJson(jsonData);
//         state = AsyncValue.data(product);
//       } else {
//         state = const AsyncValue.error('Failed to load product', StackTrace.empty);
//       }
//     } catch (e) {
//       state = AsyncValue.error(e, StackTrace.empty);
//     }
//   }
// }
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/products_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Define a provider that requires a category parameter
final filterProductProvider = StateNotifierProvider.family<FilterProductNotifier, AsyncValue<List<ProductsModel>>, String>((ref, category) {
 return FilterProductNotifier()..fetchProduct(category);
});

class FilterProductNotifier extends StateNotifier<AsyncValue<List<ProductsModel>>> {
  FilterProductNotifier() : super(const AsyncValue.loading());

  Future<void> fetchProduct(String category) async {
    if (category.isEmpty) {
      state = const AsyncValue.error('Category cannot be empty', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final response = await http.get(Uri.parse('https://fakestoreapi.com/products/category/$category'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final products = jsonData.map((json) => ProductsModel.fromJson(json)).toList();
        state = AsyncValue.data(products);
      } else {
        state = const AsyncValue.error('Failed to load products:', StackTrace.empty);
      }
    } catch (e) {
      state = AsyncValue.error('An error occurred: $e', StackTrace.empty);
    }
  }
}
