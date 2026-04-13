import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/alerts.dart';
import '../widgets/input.dart';
import '../widgets/input_password.dart';
import '../widgets/primary_button.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                            context.go('/entrance');
                          },
                        ),
                        GestureDetector(
                          child: Text(
                            'Регистрация',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Input(controller: _controllerUsername, hintText: 'Логин'),
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
                            ? () {
                                if (_controllerPassword.text !=
                                    _controllerRepeatPassword.text) {
                                  Alerts.showError(context, 'Пароли не совпадают');
                                }
                              }
                            : null,
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
