import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/colors.dart';

class CommonButton extends StatelessWidget {
  final  text;
  final Color? textColor;
 final double? height;
 final TextStyle? style;
 final Color? color;
  final double? width;
  final BoxBorder? border;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const CommonButton({
    Key? key,
      this.text,
      this.color,
      this.onTap,
      this.style,
      this.textColor,
      this.height,
      this.width,
      this.border,
    this.gradient = const LinearGradient(
      colors: [greyE0E0E0,greyE0E0E0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.borderRadius = 75.0,
    this.padding = const EdgeInsets.symmetric(vertical: 9.0),
    this.textStyle = const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ,
        width: width,
        decoration: BoxDecoration(
          gradient: color == null ? gradient : null,
          borderRadius: BorderRadius.circular(borderRadius??8),
          border: border,
          color: color,
        ),
        child: Center(
          child: Text(
            text,
            style: style ?? TextStyle(color: textColor?? grey),
          ),
        ),
      ),
    );
  }
}
