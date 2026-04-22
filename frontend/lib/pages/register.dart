import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../widgets/alerts.dart';
import '../widgets/input.dart';
import '../widgets/input_password.dart';
import '../widgets/primary_button.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _controllerUsername = TextEditingController();
  final _controllerPassword = TextEditingController();
  final _controllerRepeatPassword = TextEditingController();
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
      backgroundColor: Color.fromRGBO(245, 245, 245, 1.0),
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
                                    color: Colors.black12,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, '/entrance');
                                },
                              ),
                              GestureDetector(
                                child: Text(
                                  'Регистрация',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Color.fromRGBO(240, 210, 71, 1),
                                  ),
                                ),
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
                          InputPassword(
                            controller: _controllerRepeatPassword,
                            hintText: 'Повторите пароль',
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: PrimaryButton(
                              text: 'Зарегистрироваться',
                              onPressed: _can
                                  ? () async {
                                      if (_controllerPassword.text !=
                                          _controllerRepeatPassword.text) {
                                        Alerts.showError(
                                          context,
                                          'Пароли не совпадают',
                                        );
                                      } else {
                                        try {
                                          final response = await _dio.post(
                                            '/api/user/register',
                                            data: jsonEncode({
                                              'username':
                                                  _controllerUsername.text,
                                              'password':
                                                  _controllerPassword.text,
                                            }),
                                          );
                                          final storage =
                                              FlutterSecureStorage();
                                          String token = response.data['token'];
                                          await storage.write(
                                            key: 'token',
                                            value: token,
                                          );
                                          _dio
                                                  .options
                                                  .headers['Authorization'] =
                                              'Bearer $token';
                                          Navigator.pushNamed(context, '/profile');
                                        } on DioException catch (e) {
                                          Alerts.showError(
                                            context,
                                            e.response?.data['error'],
                                          );
                                        }
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
