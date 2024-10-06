import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vesatogo_app/screens/home_screen.dart';
import 'package:vesatogo_app/screens/login_screen.dart';

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

  ],
);
