import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/input_password.dart';
import 'package:frontend/widgets/primary_button.dart';
import 'package:provider/provider.dart';

import '../widgets/alerts.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _controllerOldPassword = TextEditingController();
  final _controllerNewPassword = TextEditingController();
  bool _can = false;
  late final Dio _dio;

  void _check(){
    if (_controllerOldPassword.text.isNotEmpty && _controllerNewPassword.text.isNotEmpty){
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
    _dio = Provider.of<Dio>(context, listen: false);
    _controllerOldPassword.addListener(() => _check());
    _controllerNewPassword.addListener(() => _check());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 245, 245, 1.0),
      appBar: MediaQuery.of(context).size.width < 540 ? AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ) : null,
      body: SafeArea(
        child: ListView(
          children: [
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.only(left: 20, right: 20),
                      constraints: BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Изменение пароля', style: TextStyle(
                            fontSize: 24
                          ),),
                          SizedBox(height: 20),
                          InputPassword(
                            controller: _controllerOldPassword,
                            hintText: 'Старый пароль',
                          ),
                          SizedBox(height: 20),
                          InputPassword(
                            controller: _controllerNewPassword,
                            hintText: 'Новый пароль',
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: PrimaryButton(
                              text: 'Изменить',
                              onPressed: _can ? () async {
                                try {
                                  await _dio.put('/api/user/changePassword', data: {
                                    'oldPassword': _controllerOldPassword.text,
                                    'newPassword': _controllerNewPassword.text
                                  });
                                  Navigator.pop(context);
                                } on DioException catch (e){
                                  Alerts.showError(context, e.response?.data['error']);
                                }
                              } : null,
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
        )
      ),
    );
  }
}
