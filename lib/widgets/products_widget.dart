import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vesatogo_app/model/products_model.dart';

class ProductCard extends StatelessWidget {
  final ProductsModel product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/productdetail/${product.id}');
      },
      child: Container(
        width: MediaQuery.of(context).devicePixelRatio,
        decoration: BoxDecoration(
          border: Border.all(
            width: 0.2,
          ),
         color: Colors.white
        ),
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.cover,
                ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(
                  product.title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                  Text('\$${product.price.toStringAsFixed(2)}',style: const TextStyle(fontSize: 20.0),),
                ]
              ),
            ),

          ],
        ),
      ),
    );
  }
}
