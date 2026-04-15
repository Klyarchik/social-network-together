import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/widgets/alerts.dart';
import 'package:frontend/widgets/input.dart';
import 'package:frontend/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late final Dio _dio;
  final _controllerUsername = TextEditingController();
  String _imageSrc = '';
  bool _isLoaded = false;
  bool _isCan = true;
  final _picker = ImagePicker();
  var _bytes;

  Future<void> _init() async {
    final response = await _dio.get('/api/user/me');
    setState(() {
      _controllerUsername.text = response.data['username'];
      _imageSrc = response.data['avatar'];
      _isLoaded = true;
    });
  }

  void _check() {
    if (_controllerUsername.text.isNotEmpty) {
      setState(() {
        _isCan = true;
      });
    } else {
      setState(() {
        _isCan = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dio = Provider.of<Dio>(context, listen: false);
    _controllerUsername.addListener(() => _check());
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoaded
        ? Scaffold(
            backgroundColor: Color.fromRGBO(230, 229, 229, 0.4),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
            ),
            drawer: Drawer(
              backgroundColor: Colors.white,
              child: Container(
                margin: EdgeInsets.only(left: 20),
                child: Column(
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
              ),
            ),
            body:
            SafeArea(
              child: SizedBox(
                child: ListView(
                  children: [
                    SizedBox(
                      height:
                          MediaQuery.of(context).size.height -
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
                            child: SizedBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // SizedBox(height: 50),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        onPressed: () async {},
                                        icon: Icon(
                                          Icons.exit_to_app,
                                          color: Colors.white,
                                        ),
                                      ),
                                      GestureDetector(
                                        child: SizedBox(
                                          width: 150,
                                          height: 150,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              150,
                                            ),
                                            child: _bytes != null
                                                ? Image.memory(
                                                    _bytes,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.network(
                                                    _imageSrc,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                        onTap: () async {
                                          XFile? file = await _picker.pickImage(
                                            source: ImageSource.gallery,
                                          );
                                          if (file != null) {
                                            var newBytes = await file
                                                .readAsBytes();
                                            setState(() {
                                              _bytes = newBytes;
                                            });
                                          }
                                        },
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          final storage =
                                              FlutterSecureStorage();
                                          await storage.delete(key: 'token');
                                          context.go('/entrance');
                                        },
                                        icon: Icon(
                                          Icons.exit_to_app,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Input(
                                      controller: _controllerUsername,
                                      hintText: 'Username',
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  TextButton(
                                    onPressed: () {
                                      context.push('/change_password');
                                    },
                                    child: Text('Изменить пароль'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Color.fromRGBO(
                                        240,
                                        210,
                                        71,
                                        1,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  SizedBox(
                                    height: 50,
                                    width: double.infinity,
                                    child: PrimaryButton(
                                      text: 'Сохранить',
                                      onPressed: _isCan
                                          ? () async {
                                              try {
                                                await _dio.put(
                                                  '/api/user/changeData',
                                                  data: FormData.fromMap({
                                                    'username':
                                                        _controllerUsername
                                                            .text,
                                                    'avatar': _bytes != null
                                                        ? MultipartFile.fromBytes(
                                                            _bytes,
                                                            filename:
                                                                'image.png',
                                                          )
                                                        : null,
                                                  }),
                                                );
                                              } on DioException catch (e) {
                                                Alerts.showError(
                                                  context,
                                                  e.response?.data['error'],
                                                );
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
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Color.fromRGBO(230, 229, 229, 0.4),
            body: Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(240, 210, 71, 1),
              ),
            ),
          );
  }
}
