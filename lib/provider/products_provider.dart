import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vesatogo_app/model/products_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final getProductsProvider = StateNotifierProvider<GetProducts, AsyncValue<List<ProductsModel>>>((ref) {
  return GetProducts();
});

class GetProducts extends StateNotifier<AsyncValue<List<ProductsModel>>> {
  GetProducts() : super(const AsyncValue.loading());

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final products = jsonData.map((json) => ProductsModel.fromJson(json)).toList();
        state = AsyncValue.data(products);
      } else {
        state = const AsyncValue.error('Failed to load products', StackTrace.empty);
      }
    } catch (e) {
      state = AsyncValue.error(e,StackTrace.empty);
    }
  }
}



