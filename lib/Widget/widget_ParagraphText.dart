import 'dart:io';

import 'package:flutter/material.dart';

class ParagraphText extends StatelessWidget {

  final String text;
  final Color? color;
  final TextAlign? alignment;

  const ParagraphText({Key? key, required this.text, this.color, this.alignment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
      textAlign: alignment,
      style: TextStyle(
        fontSize: 18,
        fontFamily: Platform.isAndroid ? 'Gotham' : null,
        height: Platform.isAndroid ? 1.5 : null,
        color: color,
      ),
    );
  }
}