import 'package:flutter/material.dart';

class NavigationItemTitle extends StatelessWidget {

  final String text;
  final Color? color;
  final TextAlign? alignment;

  const NavigationItemTitle({Key? key, required this.text, this.color, this.alignment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
      textAlign: alignment,
      style: const TextStyle(
        fontSize: 18,
        fontFamily: 'SourceSans',
        fontWeight: FontWeight.w500,
      ),
    );
  }
}