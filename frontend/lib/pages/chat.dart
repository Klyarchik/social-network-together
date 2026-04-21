import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/widgets/custom_drawer.dart';
import 'package:frontend/widgets/input.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Chat extends StatefulWidget {
  const Chat({super.key, required this.userId});

  final int userId;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _controller = TextEditingController();
  List _messages = [];
  final _storage = FlutterSecureStorage();
  late final WebSocketChannel channel;
  bool _isLoaded = false;
  late final Dio _dio;
  late final _userTo;

  Future<void> _init() async {
    String? token = await _storage.read(key: 'token');
    final responseTo = await _dio.get(
      '/api/user/user-by-id',
      queryParameters: {'id': widget.userId},
    );
    _userTo = responseTo.data['userById'];
    channel = WebSocketChannel.connect(
      Uri.parse(
        'ws://localhost:3000/chat',
      ).replace(queryParameters: {'token': token}),
    );
    channel.stream.listen((message) {
      final data = jsonDecode(message);
      print(data);
      if (data['type'] == 'message') {
        if (data['message']['from'] == widget.userId ||
            data['message']['to'] == widget.userId){
          setState(() {
            _messages.add(data);
          });
        }
      }
    });
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
            backgroundColor: Color.fromRGBO(230, 229, 229, 0.4),
            appBar: MediaQuery.of(context).size.width < 540
                ? AppBar(
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                  )
                : null,
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: 700),
                      margin: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      // padding: EdgeInsets.symmetric(5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black26,
                                width: 1,
                              )
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: Image.network(_userTo['avatar'])),
                          ),
                          SizedBox(width: 10),
                          Text(_userTo['username']),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(maxWidth: 700),
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: ListView.builder(
                          itemCount: _messages.length,
                          itemBuilder: (context, i) {
                            return Container(
                              width: double.infinity,
                              constraints: BoxConstraints(maxWidth: 700),
                              child: Row(
                                mainAxisAlignment:
                                    _messages[i]['message']['from'] ==
                                        widget.userId
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: LayoutBuilder(
                                      builder: (context, constrains) {
                                        print(constrains.maxWidth);
                                        return Container(
                                          constraints: BoxConstraints(
                                            maxWidth: constrains.maxWidth * 0.8,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                _messages[i]['message']['from'] ==
                                                    widget.userId
                                                ? Colors.white
                                                : Color.fromRGBO(
                                                    240,
                                                    210,
                                                    71,
                                                    1,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 30,
                                            vertical: 10,
                                          ),
                                          margin: EdgeInsets.symmetric(
                                            vertical: 5,
                                          ),
                                          child: Text(
                                            _messages[i]['message']['text'],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: 700),
                      margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Input(
                              controller: _controller,
                              hintText: 'Текст',
                            ),
                          ),
                          SizedBox(width: 10),
                          IconButton(
                            onPressed: () {
                              channel.sink.add(
                                jsonEncode({
                                  'text': _controller.text,
                                  'to': widget.userId,
                                }),
                              );
                            },
                            icon: Icon(Icons.send),
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
