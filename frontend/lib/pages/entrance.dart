import 'package:flutter/material.dart';
import 'package:frontend/widgets/input.dart';
import 'package:frontend/widgets/input_password.dart';
import 'package:frontend/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';

class Entrance extends StatefulWidget {
  const Entrance({super.key});

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> {
  final _controllerUsername = TextEditingController();
  final _controllerPassword = TextEditingController();
  bool _can = false;

  void _check(){
    if (_controllerUsername.text.isNotEmpty && _controllerPassword.text.isNotEmpty){
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
    _controllerUsername.addListener((){
      _check();
    });
    _controllerPassword.addListener((){
      _check();
    });
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
                        color: Colors.white
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                child: Text('Вход', style: TextStyle(fontSize: 24)),
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
                                onTap: (){
                                  context.go('/register');
                                },
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
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: PrimaryButton(
                              text: 'Войти',
                              onPressed: _can ? () {} : null,
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
