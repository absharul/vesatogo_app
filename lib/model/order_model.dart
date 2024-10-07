import 'cart_model.dart';

class Order {
  final String orderId; // New property for Order ID
  final String name;
  final String address;
  final String paymentMethod;
  final List<CartItem> items;
  final double totalPrice;
  final String date; // Date property

  Order({
    required this.orderId, // Update constructor
    required this.name,
    required this.address,
    required this.paymentMethod,
    required this.items,
    required this.totalPrice,
    required this.date,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'], // Include orderId here
      name: json['name'],
      address: json['address'],
      paymentMethod: json['paymentMethod'],
      items: (json['items'] as List).map((item) => CartItem.fromJson(item)).toList(),
      totalPrice: json['totalPrice'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId, // Include orderId here
      'name': name,
      'address': address,
      'paymentMethod': paymentMethod,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'date': date,
    };
  }
}
