import 'dart:ui';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:home_service_user/screens/blog/model/blog_detail_response.dart';
import 'package:home_service_user/screens/blog/model/blog_response_model.dart';
import 'package:home_service_user/screens/splash_screen.dart';
import 'package:home_service_user/services/auth_services.dart';
import 'package:home_service_user/services/chat_services.dart';
import 'package:home_service_user/services/user_services.dart';
import 'package:home_service_user/store/app_configuration_store.dart';
import 'package:home_service_user/store/app_store.dart';
import 'package:home_service_user/store/filter_store.dart';
import 'package:home_service_user/utils/colors.dart';
import 'package:home_service_user/utils/common.dart';
import 'package:home_service_user/utils/configs.dart';
import 'package:home_service_user/utils/constant.dart';
import 'package:home_service_user/utils/firebase_messaging_utils.dart';
import 'package:nb_utils/nb_utils.dart';

import 'app_theme.dart';
import 'firebase_options.dart';
import 'locale/app_localizations.dart';
import 'locale/language_en.dart';
import 'locale/languages.dart';
import 'model/booking_data_model.dart';
import 'model/booking_detail_model.dart';
import 'model/booking_status_model.dart';
import 'model/category_model.dart';
import 'model/coupon_list_model.dart';
import 'model/dashboard_model.dart';
import 'model/get_my_post_job_list_response.dart';
import 'model/material_you_model.dart';
import 'model/notification_model.dart';
import 'model/provider_info_response.dart';
import 'model/remote_config_data_model.dart';
import 'model/service_data_model.dart';
import 'model/service_detail_response.dart';
import 'model/user_data_model.dart';
import 'model/user_wallet_history.dart';

//region Mobx Stores
AppStore appStore = AppStore();
FilterStore filterStore = FilterStore();
AppConfigurationStore appConfigurationStore = AppConfigurationStore();
//endregion

//region Global Variables
BaseLanguage language = LanguageEn();
//endregion

//region Services
UserService userService = UserService();
AuthService authService = AuthService();
ChatServices chatServices = ChatServices();
RemoteConfigDataModel remoteConfigDataModel = RemoteConfigDataModel();
//endregion

//region Cached Response Variables for Dashboard Tabs
DashboardResponse? cachedDashboardResponse;
List<BookingData>? cachedBookingList;
List<CategoryData>? cachedCategoryList;
List<BookingStatusResponse>? cachedBookingStatusDropdown;
List<PostJobData>? cachedPostJobList;
List<WalletDataElement>? cachedWalletHistoryList;

List<ServiceData>? cachedServiceFavList;
List<UserData>? cachedProviderFavList;
List<BlogData>? cachedBlogList;
List<RatingData>? cachedRatingList;
List<NotificationData>? cachedNotificationList;
CouponListResponse? cachedCouponListResponse;
List<(int blogId, BlogDetailResponse list)?> cachedBlogDetail = [];
List<(int serviceId, ServiceDetailResponse list)?> listOfCachedData = [];
List<(int providerId, ProviderInfoResponse list)?> cachedProviderList = [];
List<(int categoryId, List<CategoryData> list)?> cachedSubcategoryList = [];
List<(int bookingId, BookingDetailResponse list)?> cachedBookingDetailList = [];
//endregion

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  passwordLengthGlobal = 6;
  appButtonBackgroundColorGlobal = primaryColor;
  defaultAppButtonTextColorGlobal = Colors.white;
  defaultRadius = 12;
  defaultBlurRadius = 0;
  defaultSpreadRadius = 0;
  textSecondaryColorGlobal = appTextSecondaryColor;
  textPrimaryColorGlobal = /*appTextPrimaryColor*/ primaryColor;
  defaultAppButtonElevation = 0;
  pageRouteTransitionDurationGlobal = 400.milliseconds;
  textBoldSizeGlobal = 14;
  textPrimarySizeGlobal = 14;
  textSecondarySizeGlobal = 12;

  await initialize();
  localeLanguageList = languageList();

  if (kIsWeb) {
    final firebaseApp = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }else {
    await Firebase.initializeApp().then((value) async {
      /// Firebase Notification
      initFirebaseMessaging();
      FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler); // todo  recommended to register globally
      if (appConfigurationStore.fcm_token
          .isEmpty) { // this is for generate Fcm token
        /// Subscribe Firebase Topic
        await subscribeToFirebaseTopic();
      } else {
        print('FCM TOKEN ${appConfigurationStore.fcm_token}');
      }
      print('FCM TOKEN ${appConfigurationStore.fcm_token}');
      // Force enable crashlytics collection enabled if we're testing it
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      // Pass all uncaught "fatal" errors from the framework to Crashlytics
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // await FirebaseAppCheck.instance.activate(
      //   androidProvider: kDebugMode
      //       ? AndroidProvider.debug
      //       : AndroidProvider.playIntegrity,
      //   appleProvider: AppleProvider.appAttest,
      // );

      await FirebaseAppCheck.instance.activate(
        appleProvider: AppleProvider.deviceCheck, // or .deviceCheck
        androidProvider: AndroidProvider.playIntegrity,
      );
    });
  }
  int themeModeIndex =
      getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);
  if (themeModeIndex == THEME_MODE_LIGHT) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == THEME_MODE_DARK) {
    appStore.setDarkMode(false);
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    appStore.setDarkMode(false);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RestartAppWidget(
      child: Observer(
        builder: (_) => FutureBuilder<Color>(
          future: getMaterialYouData(),
          builder: (_, snap) {
            return Observer(
              builder: (_) => MaterialApp(
                debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey,
                home: SplashScreen(),
                themeMode: appStore.isDarkMode
                    ? ThemeMode.light /*ThemeMode.dark*/
                    : ThemeMode.light,
                theme: ThemeData(
                    primaryColor: primaryColor,
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: primaryColor,
                      // Cursor line color
                      selectionColor: primaryColor.withOpacity(0.4),
                      // Highlight color
                      selectionHandleColor:
                          primaryColor, // "Waterdrop" handle color
                    )),
                title: APP_NAME,
                supportedLocales: LanguageDataModel.languageLocales(),
                localizationsDelegates: [
                  AppLocalizations(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                localeResolutionCallback: (locale, supportedLocales) => locale,
                locale: Locale(appStore.selectedLanguageCode),
              ),
            );
          },
        ),
      ),
    );
  }
}
