import 'package:home_service_user/main.dart';
import 'package:home_service_user/utils/colors.dart';
import 'package:home_service_user/utils/configs.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

Future<Color> getMaterialYouData() async {
  if (appStore.useMaterialYouTheme && await isAndroid12Above()) {
    primaryColor = await getMaterialYouPrimaryColor() ??  Colors.teal;
  } else {
    primaryColor = defaultPrimaryColor;
  }

  return primaryColor;
}
