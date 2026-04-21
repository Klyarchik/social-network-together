import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/widgets/input.dart';
import 'package:frontend/widgets/input_password.dart';
import 'package:frontend/widgets/primary_button.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import '../widgets/alerts.dart';

class Entrance extends StatefulWidget {
  const Entrance({super.key});

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> {
  final _controllerUsername = TextEditingController();
  final _controllerPassword = TextEditingController();
  bool _can = false;
  late final Dio _dio;

  void _check() {
    if (_controllerUsername.text.isNotEmpty &&
        _controllerPassword.text.isNotEmpty) {
      setState(() {
        _can = true;
      });
    } else {
      setState(() {
        _can = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controllerUsername.addListener(() {
      _check();
    });
    _controllerPassword.addListener(() {
      _check();
    });
    _dio = Provider.of<Dio>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(230, 229, 229, 0.4),
      body: SafeArea(
        child: ListView(
          children: [
            Center(
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                constraints: BoxConstraints(maxWidth: 400),
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12, width: 1),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                child: Text(
                                  'Вход',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Color.fromRGBO(240, 210, 71, 1),
                                  ),
                                ),
                                onTap: () {},
                              ),
                              GestureDetector(
                                child: Text(
                                  'Регистрация',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.black12,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Input(
                            controller: _controllerUsername,
                            hintText: 'Username',
                          ),
                          SizedBox(height: 20),
                          InputPassword(
                            controller: _controllerPassword,
                            hintText: 'Пароль',
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: PrimaryButton(
                              text: 'Войти',
                              onPressed: _can
                                  ? () async {
                                      try {
                                        final response = await _dio.post(
                                          '/api/user/entrance',
                                          data: jsonEncode({
                                            'username':
                                                _controllerUsername.text,
                                            'password':
                                                _controllerPassword.text,
                                          }),
                                        );
                                        final storage = FlutterSecureStorage();
                                        String token = response.data['token'];
                                        await storage.write(
                                          key: 'token',
                                          value: token,
                                        );
                                        _dio.options.headers['Authorization'] =
                                            'Bearer $token';
                                        Navigator.pushNamed(context, '/profile');
                                      } on DioException catch (e) {
                                        Alerts.showError(
                                          context,
                                          'Неверный логин или пароль',
                                        );
                                      }
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
