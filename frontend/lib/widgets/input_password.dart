import 'package:flutter/material.dart';

class InputPassword extends StatefulWidget {
  const InputPassword({super.key, required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  State<InputPassword> createState() => _InputPasswordState();
}

class _InputPasswordState extends State<InputPassword> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextSelectionTheme(
      data: TextSelectionThemeData(
          cursorColor: Color.fromRGBO(240, 210, 71, 1),
          selectionHandleColor: Color.fromRGBO(240, 210, 71, 1),
          selectionColor: Color.fromRGBO(240, 210, 71, 0.5)
      ),
      child: TextField(
        obscureText: _isObscure,
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
              color: Colors.black12
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black12, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromRGBO(240, 210, 71, 1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _isObscure = !_isObscure;
              });
            },
            icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
          ),
        ),
      ),
    );
  }
}
