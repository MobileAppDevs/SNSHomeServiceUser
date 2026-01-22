import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/image_border_component.dart';
import '../../main.dart';
import '../../utils/app_configuration.dart';
import '../../utils/colors.dart';
import '../../utils/common.dart';
import '../../utils/constant.dart';
import '../../utils/firebase_messaging_utils.dart';
import '../../utils/images.dart';
import '../auth/sign_in_screen.dart';
import '../category/category_screen.dart';
import '../chat/chat_list_screen.dart';
import 'fragment/booking_fragment.dart';
import 'fragment/dashboard_fragment.dart';
import 'fragment/profile_fragment.dart';

class DashboardScreen extends StatefulWidget {
  final bool? redirectToBooking;

  DashboardScreen({this.redirectToBooking});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.redirectToBooking.validate(value: false)) {
      currentIndex = 1;
    }

    afterBuildCreated(() async {
      /// Changes System theme when changed
      if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
        appStore.setDarkMode(context.platformBrightness() == Brightness.dark);
      }

      View.of(context).platformDispatcher.onPlatformBrightnessChanged =
          () async {
        if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
          appStore.setDarkMode(
              MediaQuery.of(context).platformBrightness == Brightness.light);
        }
      };
    });

    /// Handle Firebase Notification click and redirect to that Service & BookDetail screen
    LiveStream().on(LIVESTREAM_FIREBASE, (value) {
      if (value == 3) {
        currentIndex = 3;
        setState(() {});
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      //Handle onClick Notification
      log("data 1 ==> ${message.data}");
      handleNotificationClick(message);
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      //Handle onClick Notification
      if (message != null) {
        log("data 2 ==> ${message.data}");
        handleNotificationClick(message);
      }
    });

    /*Firebase.initializeApp().then((value) {
      //When the app is in the background and opened directly from the push notification.
      FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        //Handle onClick Notification
        log("data 1 ==> ${message.data}");
        handleNotificationClick(message);
      });

      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        //Handle onClick Notification
        if (message != null) {
          log("data 2 ==> ${message.data}");
          handleNotificationClick(message);
        }
      });
    }).catchError(onError);*/

    init();
  }

  void init() async {
    if (isMobile && appStore.isLoggedIn) {
      /// Handle Notification click and redirect to that Service & BookDetail screen
      ///
      /// TODO check if handled with firebase
      /*OneSignal.Notifications.addClickListener((notification) async {
        if (notification.notification.additionalData == null) return;

        if (notification.notification.additionalData!.containsKey('id')) {
          String? notId = notification.notification.additionalData!["id"].toString();
          if (notId.validate().isNotEmpty) {
            BookingDetailScreen(bookingId: notId.toString().toInt()).launch(context);
          }
        } else if (notification.notification.additionalData!.containsKey('service_id')) {
          String? notId = notification.notification.additionalData!["service_id"];
          if (notId.validate().isNotEmpty) {
            ServiceDetailScreen(serviceId: notId.toInt()).launch(context);
          }
        } else if (notification.notification.additionalData!.containsKey('sender_uid')) {
          String? notId = notification.notification.additionalData!["sender_uid"];
          if (notId.validate().isNotEmpty) {
            currentIndex = 3;
            setState(() {});
          }
        }
      });*/
    }

    await 3.seconds.delay;
    if (getIntAsync(FORCE_UPDATE_USER_APP).getBoolInt()) {
      showForceUpdateDialog(context);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_FIREBASE);
  }

  @override
  Widget build(BuildContext context) {
    return DoublePressBackWidget(
      message: language.lblBackPressMsg,
      child: SafeArea(
        top: false,
        child: Scaffold(
          body: [
            DashboardFragment(),
            Observer(
                builder: (context) => appStore.isLoggedIn
                    ? BookingFragment()
                    : SignInScreen(isFromDashboard: true)),
            CategoryScreen(),
            Observer(
                builder: (context) => appStore.isLoggedIn
                    ? ChatListScreen()
                    : SignInScreen(isFromDashboard: true)),
            ProfileFragment(),
          ][currentIndex],
          bottomNavigationBar: SafeArea(
            top: false,
            child: Blur(
              blur: 30,
              borderRadius: radius(0),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: Colors.white,
                  indicatorColor: Colors.transparent,
                  labelTextStyle: MaterialStateProperty.all(
                      primaryTextStyle(size: 12, color: black)),
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  height: 65,
                ),
                child: NavigationBar(
                  selectedIndex: currentIndex,
                  destinations: [
                    NavigationDestination(
                      icon: ic_home.iconSvgImage(
                          color: appTextSecondaryColor, size: 18),
                      selectedIcon: ic_home_select.iconSvgImage(
                          color: primaryColor, size: 18),
                      label: language.home,
                    ),
                    NavigationDestination(
                      icon: ic_ticket.iconSvgImage(
                          color: appTextSecondaryColor, size: 18),
                      selectedIcon: ic_ticket_select.iconSvgImage(
                          color: primaryColor, size: 18),
                      label: language.booking,
                    ),
                    NavigationDestination(
                      icon: ic_category.iconSvgImage(
                          color: appTextSecondaryColor, size: 18),
                      selectedIcon: ic_category_select.iconSvgImage(
                          color: primaryColor, size: 18),
                      label: language.category,
                    ),
                    NavigationDestination(
                      icon: ic_chat.iconSvgImage(
                          color: appTextSecondaryColor, size: 18),
                      selectedIcon:
                          ic_chat.iconSvgImage(color: primaryColor, size: 18),
                      label: language.lblChat,
                    ),
                    Observer(builder: (context) {
                      return NavigationDestination(
                        icon: (appStore.isLoggedIn &&
                                appStore.userProfileImage.isNotEmpty)
                            ? IgnorePointer(
                                ignoring: true,
                                child: ImageBorder(
                                    src: appStore.userProfileImage, height: 26))
                            : ic_profile2.iconImage(color: appTextSecondaryColor),
                        selectedIcon: (appStore.isLoggedIn &&
                                appStore.userProfileImage.isNotEmpty)
                            ? IgnorePointer(
                                ignoring: true,
                                child: ImageBorder(
                                    src: appStore.userProfileImage, height: 26))
                            : ic_profile2.iconImage(color: primaryColor),
                        label: language.profile,
                      );
                    }),
                  ],
                  onDestinationSelected: (index) {
                    currentIndex = index;
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
