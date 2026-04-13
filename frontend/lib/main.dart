import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/pages/entrance.dart';
import 'package:frontend/pages/profile.dart';
import 'package:frontend/pages/register.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

String? token;

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: token == null ?  Entrance() : Profile(),
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
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const Profile(),
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    ),
  ],
);

void main() async {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
  final storage = FlutterSecureStorage();
  token = await storage.read(key: 'token');
  runApp(
    Provider(
      create: (context) => dio,
      child: MaterialApp.router(routerConfig: _router),
    ),
  );
}
