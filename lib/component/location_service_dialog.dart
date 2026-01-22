 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/colors.dart';

class LocationServiceDialog extends StatefulWidget {
  final Function()? onAccept;

  LocationServiceDialog({this.onAccept});

  @override
  State<LocationServiceDialog> createState() => _LocationServiceDialogState();
}

class _LocationServiceDialogState extends State<LocationServiceDialog> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: context.width(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(appStore.isCurrentLocation ? language.msgForLocationOn : language.msgForLocationOff, style: primaryTextStyle(fontFamily: GoogleFonts.mulish().fontFamily,color: black1A1C1E)).paddingAll(16),
            16.height,
            AppButton(
              text: appStore.isCurrentLocation ? language.turnOff : language.turnOn,
              width: context.width(),
              margin: EdgeInsets.all(16),
              color: primaryColor,
              textColor: Colors.white,
              onTap: () async {
                finish(context, true);
              },
            ),
            8.height,
          ],
        ),
      ),
    );
  }
}
