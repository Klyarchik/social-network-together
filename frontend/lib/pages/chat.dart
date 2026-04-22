import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _isLoaded = false;
  late final Dio _dio;
  late final _userTo;
  bool _can = false;

  Future<void> _init() async {
    String? token = await _storage.read(key: 'token');
    final responseTo = await _dio.get(
      '/api/user/user-by-id',
      queryParameters: {'id': widget.userId},
    );
    _userTo = responseTo.data['userById'];
    channel = WebSocketChannel.connect(
      Uri.parse(
        defaultTargetPlatform != TargetPlatform.android
            ? 'ws://localhost:3000/chat'
            : 'ws://10.0.2.2:3000/chat',
      ).replace(queryParameters: {'token': token}),
    );
    final responseMessages = await _dio.get(
      '/api/chat/all-mesagges',
      queryParameters: {'idChooseUser': widget.userId},
    );
    _messages = responseMessages.data['allMessages'];
    channel.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['type'] == 'message') {
        if (data['message']['user_from'] == widget.userId ||
            data['message']['user_to'] == widget.userId) {
          setState(() {
            _messages.add(data['message']);
          });
        }
      }
    });
    setState(() {
      _isLoaded = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dio = Provider.of<Dio>(context, listen: false);
    _controller.addListener(() {
      setState(() {
        _can = _controller.text.isNotEmpty;
      });
    });
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoaded
        ? Scaffold(
            backgroundColor: Color.fromRGBO(245, 245, 245, 1.0),
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
                          SizedBox(width: 10),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black26,
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.network(_userTo['avatar']),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(_userTo['username']),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        // constraints: BoxConstraints(maxWidth: 700),
                        // margin: EdgeInsets.symmetric(horizontal: 20),
                        child: ListView.builder(
                          cacheExtent: double.infinity,
                          controller: _scrollController,
                          itemCount: _messages.length,
                          itemBuilder: (context, i) {
                            final listDateTime = _messages[i]['created_at']
                                .split('T');
                            final listTime = listDateTime[1].split(':');
                            return Center(
                              child: Column(
                                children: [
                                  if (i != 0)
                                    if (_messages[i - 1]['created_at']
                                            .substring(0, 10) !=
                                        _messages[i]['created_at'].substring(
                                          0,
                                          10,
                                        ))
                                      Center(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 2.5,
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black26.withAlpha(30),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: Text(
                                            _messages[i]['created_at']
                                                .substring(0, 10),
                                          ),
                                        ),
                                      ),
                                  Container(
                                    width: double.infinity,
                                    constraints: BoxConstraints(maxWidth: 700),
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          _messages[i]['user_from'] ==
                                              widget.userId
                                          ? MainAxisAlignment.start
                                          : MainAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: LayoutBuilder(
                                            builder: (context, constrains) {
                                              return Container(
                                                constraints: BoxConstraints(
                                                  maxWidth:
                                                      constrains.maxWidth * 0.8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      _messages[i]['user_from'] ==
                                                          widget.userId
                                                      ? Colors.white
                                                      : Color.fromRGBO(
                                                          240,
                                                          210,
                                                          71,
                                                          1,
                                                        ),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 5,
                                                ),
                                                margin: EdgeInsets.symmetric(
                                                  vertical: 5,
                                                  // horizontal: 30
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(_messages[i]['text']),
                                                    Text(
                                                      '${listTime[0]}:${listTime[1]}',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
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
                            onPressed: _can
                                ? () async {
                                    channel.sink.add(
                                      jsonEncode({
                                        'text': _controller.text,
                                        'to': widget.userId,
                                      }),
                                    );
                                    _controller.text = '';
                                    await Future.delayed(
                                      Duration(milliseconds: 300),
                                    );
                                    _scrollController.jumpTo(
                                      _scrollController
                                          .position
                                          .maxScrollExtent,
                                    );
                                  }
                                : null,
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
