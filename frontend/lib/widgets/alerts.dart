import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Alerts {
  static void showError(BuildContext context, String text){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Ошибка'),
        content: Text(text),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: Text('ок'),
          style: TextButton.styleFrom(
            foregroundColor: Color.fromRGBO(240, 210, 71, 1)
          ),)
        ],
      );
    });
  }
}