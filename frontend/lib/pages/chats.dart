import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/widgets/custom_drawer.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  late final Dio _dio;
  bool _isLoaded = false;
  final List _users = [];
  final _storge = FlutterSecureStorage();

  Future<void> _init() async {
    final resultMe = await _dio.get('/api/user/me');
    final resultUsers = await _dio.get('/api/user/all-users');
    for (final user in resultUsers.data) {
      if (user['id'] != resultMe.data['id']) {
        _users.add(user);
      }
    }
    setState(() {
      _isLoaded = true;
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
    return _isLoaded
        ? Scaffold(
            backgroundColor: Color.fromRGBO(245, 245, 245, 1.0),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
            ),
            body: SafeArea(
              child: Center(
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                  ),
                  margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                  padding: EdgeInsets.all(20),
                  child: ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, i) {
                      return InkWell(
                        child: Center(
                          child: Row(
                            children: [
                              Container(
                                height: 70,
                                width: 70,
                                margin: EdgeInsets.only(
                                  bottom: 10
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black26, width: 1)
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(70),
                                  child: Image.network(
                                    _users[i]['avatar'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Text(_users[i]['username']),
                            ],
                          ),
                        ),
                        onTap: (){
                          Navigator.pushNamed(context, '/chat', arguments: {
                            'userId': _users[i]['id']
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            drawer: CustomDrawer(index: 1),
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
