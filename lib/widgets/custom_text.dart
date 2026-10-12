import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;

  const CustomText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
  });

  const CustomText.title(this.text, {super.key, this.textAlign, this.color})
    : fontSize = 26,
      fontWeight = FontWeight.w900,
      maxLines = null;

  const CustomText.subtitle(this.text, {super.key, this.textAlign, this.color})
    : fontSize = null,
      fontWeight = null,
      maxLines = null;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}
