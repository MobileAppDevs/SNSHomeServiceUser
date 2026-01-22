import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../auth/sign_in_screen.dart';
import '../../jobRequest/my_post_request_list_screen.dart';

class NewJobRequestComponent extends StatelessWidget {
  const NewJobRequestComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor: primaryColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(defaultRadius), topRight: Radius.circular(defaultRadius)),
      ),
      width: context.width(),
      child: Column(
        children: [
          16.height,
          Text(language.jobRequestSubtitle, style: primaryTextStyle(color: white, size: 16,weight: FontWeight.w700, fontFamily: GoogleFonts.mulish().fontFamily), textAlign: TextAlign.center),
          20.height,
          AppButton(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: appStore.isDarkMode ? primaryColor/*Colors.white*/ : primaryColor),
                4.width,
                Text(language.newPostJobRequest, style: boldTextStyle(color: appStore.isDarkMode ? primaryColor/*Colors.white*/ : primaryColor)),
              ],
            ),
            textStyle: primaryTextStyle(color: appStore.isDarkMode ? primaryColor/*textPrimaryColorGlobal*/ : primaryColor),
            onTap: () async {
              if (appStore.isLoggedIn) {
                MyPostRequestListScreen().launch(context);
              } else {
                setStatusBarColor(Colors.white, statusBarIconBrightness: Brightness.dark);
                bool? res = await SignInScreen(isFromDashboard: true).launch(context);

                if (res ?? false) {
                  MyPostRequestListScreen().launch(context);
                }
              }
            },
          ),
          16.height,
        ],
      ),
    );
  }
}
