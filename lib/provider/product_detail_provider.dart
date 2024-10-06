import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vesatogo_app/model/products_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


final productDetailProvider = StateNotifierProvider.family<ProductDetailNotifier, AsyncValue<ProductsModel>, int>((ref, productId) {
  return ProductDetailNotifier()..fetchProduct(productId);
});

class ProductDetailNotifier extends StateNotifier<AsyncValue<ProductsModel>> {
  ProductDetailNotifier() : super(const AsyncValue.loading());

  Future<void> fetchProduct(int productId) async {
    try {
      final response = await http.get(Uri.parse('https://fakestoreapi.com/products/$productId'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final product = ProductsModel.fromJson(jsonData);
        state = AsyncValue.data(product);
      } else {
        state = const AsyncValue.error('Failed to load product', StackTrace.empty);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.empty);
    }
  }
}
