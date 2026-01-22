import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/images.dart';

class BackWidget extends StatelessWidget {
  final Function()? onPressed;
  final Color? iconColor;
  final double? size;

  BackWidget({this.onPressed, this.iconColor,this.size});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onPressed ??
                () {
              finish(context);
            },
        icon:   Image.asset(circle_back,height: size??55,width: size??55,) // circle_back.iconImage(color: iconColor ?? Colors.white),
    );
  }
}
