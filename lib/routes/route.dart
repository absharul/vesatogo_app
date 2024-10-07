import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vesatogo_app/screens/cart_screen.dart';
import 'package:vesatogo_app/screens/checkout_screen.dart';
import 'package:vesatogo_app/screens/home_screen.dart';
import 'package:vesatogo_app/screens/login_screen.dart';
import 'package:vesatogo_app/screens/order_detail.dart';
import 'package:vesatogo_app/screens/payments_cards.dart';
import 'package:vesatogo_app/screens/signup_screen.dart';
import 'package:vesatogo_app/widgets/product_detail_widget.dart';

import '../model/order_model.dart';

final GoRouter approuter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/signup',
      builder: (BuildContext context, GoRouterState state) {
        return const SignUpScreen();
      },
    ),
    GoRoute(
      path: '/homepage',
      builder: (BuildContext context, GoRouterState state) {
        return const MyHomePage();
      },
    ),
    GoRoute(
      path: '/productdetail/:productId',
      builder: (BuildContext context, GoRouterState state) {
        final String productId = state.pathParameters['productId']!;
        return ProductDetailWidget(productId: int.parse(productId));
      },
    ),

    GoRoute(
      path: '/cartpage',
      builder: (BuildContext context, GoRouterState state) {
        return  CartPage();
      },
    ),
    GoRoute(
      path: '/checkout',
      builder: (BuildContext context, GoRouterState state) {
        return  CheckoutPage();
      },
    ),
    GoRoute(
      path: '/order_detail',
      builder: (BuildContext context, GoRouterState state) {
        final order = state.extra as Order;
        return  OrderDetailPage(order: order);
      },
    ),
    GoRoute(
      path: '/cardpayment',
      builder: (BuildContext context, GoRouterState state) {
        final order = state.extra as Order;
        return PaymentGatewayPage(order: order);
      },
    ),

  ],
);
