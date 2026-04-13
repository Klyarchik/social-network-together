import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late final Dio _dio;
  String _username = '';

  Future<void> _init() async {
    final response = await _dio.get('/api/user/me');
    setState(() {
      _username = response.data['username'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dio = Provider.of<Dio>(context, listen: false);
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(230, 229, 229, 0.4),
      body: SafeArea(
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    GestureDetector(
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Color.fromRGBO(240, 210, 71, 1),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Профиль',
                            style: TextStyle(
                              color: Color.fromRGBO(240, 210, 71, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble, color: Colors.black12),
                          SizedBox(width: 10),
                          Text('Чаты', style: TextStyle(color: Colors.black12)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                Container(
                  width: 700,
                  height: 500,
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(child: Text('Выйти'), onTap: () async {
                        final storage = FlutterSecureStorage();
                        await storage.delete(key: 'token');
                        context.go('/entrance');
                      }),
                      Text(_username),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
