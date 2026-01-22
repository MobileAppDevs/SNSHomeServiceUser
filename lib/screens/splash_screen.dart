
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../component/loader_widget.dart';
import '../main.dart';
import '../network/rest_apis.dart';
import '../utils/colors.dart';
import '../utils/common.dart';
import '../utils/configs.dart';
import '../utils/constant.dart';
import '../utils/custom_dialog_utils.dart';
import '../utils/images.dart';
import '../utils/savedAddress/address_bottom_sheet_widget.dart';
import 'dashboard/dashboard_screen.dart';
import 'maintenance_mode_screen.dart';
import 'walk_through_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool appNotSynced = false;

  @override
  void initState()  {
    super.initState();
    afterBuildCreated(() {
      setStatusBarColor(Colors.transparent, statusBarBrightness: Brightness.dark, statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : /*Brightness.dark*/Brightness.light);

      init();
    });


  }

  Future<void> init() async {


    await appStore.setLanguage(getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: DEFAULT_LANGUAGE));

    ///Set app configurations
    await getAppConfigurations().then((value) {}).catchError((e) async {
      if (!await isNetworkAvailable()) {
        toast(errorInternetNotAvailable);
      }
      log(e);
    });

    appStore.setLoading(false);
    if (!getBoolAsync(IS_APP_CONFIGURATION_SYNCED_AT_LEAST_ONCE)) {
      appNotSynced = true;
      setState(() {});
    } else {
      int themeModeIndex = getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);
      if (themeModeIndex == THEME_MODE_SYSTEM) {
        appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.dark);
      }

      if (appConfigurationStore.maintenanceModeStatus) {
        MaintenanceModeScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
      } else {
        if (getBoolAsync(IS_FIRST_TIME, defaultValue: true)) {
          WalkThroughScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        } else {
          DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        }
      }
    }
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
           /* Image.asset(
              splash_background ,
              height: context.height(),
              width: context.width(),
              fit: BoxFit.cover,
            ),*/
            Image.asset(
              splash_forground,
              height: context.height(),
              width: context.width(),
              fit: BoxFit.cover,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               // Image.asset(appLogo, height: 120, width: 120),
               // 32.height,
                Image.asset(
                  splash_icon,
                  height: 170,
                  width: 170,
                  fit: BoxFit.cover,
                ),

                16.height,
                if (appNotSynced)
                  Observer(
                    builder: (_) => appStore.isLoading
                        ? LoaderWidget().center()
                        :/* TextButton(

                      child: Text(language.reload, style: boldTextStyle()),
                            onPressed: () {
                              appStore.setLoading(true);
                              init();
                            },
                          )*/SizedBox(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
