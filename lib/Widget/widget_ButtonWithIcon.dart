import 'package:flutter/material.dart';

class ButtonIcon extends StatelessWidget {

  final Function onPressed;
  final IconData icon;
  final String text;

  const ButtonIcon({Key? key, required this.onPressed, required this.icon, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: (){onPressed();},
      icon: Icon(icon, size: 25,),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
        child: Text(text, style: const TextStyle(
          fontSize: 18,
          fontFamily: 'SourceSans',
        ),
        ),
      ),
    );
  }
}
