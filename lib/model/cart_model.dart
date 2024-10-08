class CartItem {
  final int productId;
  final int quantity;
  final double price;
  final String title;

  CartItem({
    required this.productId,
    required this.quantity,
    required this.price,
    required this.title,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'title': title,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      quantity: json['quantity'],
      price: json['price'],
      title: json['title'],
    );
  }
}
