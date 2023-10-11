import 'package:flutter/material.dart';

class TextSettingsButton extends StatelessWidget {

  final String text;
  final Function onPressed;

  const TextSettingsButton ({Key? key, required this.text, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style:
      TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 60),
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15)
      ),
      onPressed: (){onPressed();},
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
