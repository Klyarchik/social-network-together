import 'package:flutter/material.dart';
import 'package:frontend/pages/entrance.dart';
import 'package:frontend/pages/register.dart';
import 'package:go_router/go_router.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const Entrance(),
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const Register(),
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    ),
    GoRoute(
      path: '/entrance',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const Entrance(),
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    ),
  ],
);

void main() {
  runApp(MaterialApp.router(routerConfig: _router));
}
