import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  const Input({super.key, required this.controller, required this.hintText});
  final String hintText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextSelectionTheme(
      data: TextSelectionThemeData(
        cursorColor: Color.fromRGBO(240, 210, 71, 1),
        selectionHandleColor: Color.fromRGBO(240, 210, 71, 1),
        selectionColor: Color.fromRGBO(240, 210, 71, 0.5)
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black12,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromRGBO(240, 210, 71, 1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          )
        ),
      ),
    );
  }
}
