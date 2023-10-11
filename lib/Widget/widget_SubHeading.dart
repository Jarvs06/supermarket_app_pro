import 'package:flutter/material.dart';

class SubHeadingText extends StatelessWidget {

  final String text;
  final Color? color;
  final TextAlign? alignment;

  const SubHeadingText({Key? key, required this.text, this.color, this.alignment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
      textAlign: alignment,
      style: TextStyle(
        fontSize: 20,
        fontFamily: 'SourceSans',
        height: 1.5,
        color: color,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}