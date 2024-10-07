import 'package:vesatogo_app/model/cart_model.dart';

class Order {
  final String name;
  final String address;
  final String paymentMethod;
  final List<CartItem> items; // Assuming OrderItem is defined with necessary fields
  final double totalPrice;

  Order({
    required this.name,
    required this.address,
    required this.paymentMethod,
    required this.items,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'paymentMethod': paymentMethod,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      name: json['name'],
      address: json['address'],
      paymentMethod: json['paymentMethod'],
      items: List<CartItem>.from(
          json['items'].map((item) => CartItem.fromJson(item))),
      totalPrice: json['totalPrice'],
    );
  }
}
