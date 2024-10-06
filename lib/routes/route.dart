import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vesatogo_app/screens/home_screen.dart';
import 'package:vesatogo_app/screens/login_screen.dart';
import 'package:vesatogo_app/widgets/product_detail_widget.dart';

final GoRouter approuter = GoRouter(
  routes: <RouteBase>[
    // GoRoute(
    //   path: '/',
    //   builder: (BuildContext context, GoRouterState state) {
    //     return const LoginScreen();
    //   },
    // ),
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const MyHomePage();
      },
    ),
    GoRoute(
      path: '/productdetail/:productId', // Define a route with a productId parameter
      builder: (BuildContext context, GoRouterState state) {
        final String productId = state.pathParameters['productId']!; // Use 'productId' here
        return ProductDetailWidget(productId: int.parse(productId));
      },
    ),
  ],
);
