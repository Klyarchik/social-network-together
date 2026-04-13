import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.text, this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Color.fromRGBO(240, 210, 71, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
        )
      ),
      child: Text(text),
    );
  }
}
