import 'package:flutter/material.dart';

class HeadingText extends StatelessWidget {

  final String text;
  final Color? color;
  final TextAlign? alignment;

  const HeadingText({Key? key, required this.text, this.color, this.alignment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
      textAlign: alignment,
      style: TextStyle(
        fontSize: 32,
        fontFamily: 'SourceSans',
        color: color,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}