import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Alerts {
  static void showError(BuildContext context, String text){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Ошибка'),
        content: Text(text),
        actions: [
          TextButton(onPressed: (){
            context.pop();
          }, child: Text('ок'),
          style: TextButton.styleFrom(
            foregroundColor: Color.fromRGBO(240, 210, 71, 1)
          ),)
        ],
      );
    });
  }
}