import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/utils/extensions/num_extenstions.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/cached_image_widget.dart';
import '../../../component/delete_dialog.dart';
import '../../../component/loader_widget.dart';
import '../../../main.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';
import '../../../utils/configs.dart';
import '../../../utils/constant.dart';
import '../../../utils/images.dart';
import '../../about_screen.dart';
import '../../auth/edit_profile_screen.dart';
import '../../auth/sign_in_screen.dart';
import '../../blog/view/blog_list_screen.dart';
import '../../favourite_provider_screen.dart';
import '../../service/favourite_service_screen.dart';
import '../../setting_screen.dart';
import '../../wallet/user_wallet_balance_screen.dart';
import '../component/wallet_history.dart';
import '../customer_rating_screen.dart';
import '../dashboard_screen.dart';

class ProfileFragment extends StatefulWidget {
  @override
  ProfileFragmentState createState() => ProfileFragmentState();
}

class ProfileFragmentState extends State<ProfileFragment> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<num>? futureWalletBalance;

  @override
  void initState() {
    super.initState();
    init();
    afterBuildCreated(() {
      appStore.setLoading(false);
      setStatusBarColor(primaryColor);
    });
  }

  Future<void> init() async {
    if (appStore.isLoggedIn) {
      appStore.setUserWalletAmount();
      userDetailAPI();
    }
  }

  Future<void> userDetailAPI() async {
    await getUserDetail(appStore.userId).then((value) async {
      await saveUserData(value, forceSyncAppConfigurations: false);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // ya dark based on theme
      ),
      child: SafeArea(
        top: false,
        child: Scaffold(
          body: Stack(
            children: [
              Image.asset(
                splash_background,
                height: context.height(),
                width: context.width(),
                fit: BoxFit.cover,
              ),
              Positioned(
                top: (context.height() * .06),
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        language.profile,
                        style: (boldTextStyle(
                            color: white,
                            size: APP_BAR_TEXT_SIZE,
                            fontFamily: GoogleFonts.mulish().fontFamily)),
                      ),
                      IconButton(
                        icon: ic_setting.iconSvgImage(color: white, size: 36),
                        onPressed: () async {
                          SettingScreen().launch(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: (appStore.isLoggedIn)
                    ? (context.height() * .25)
                    : (context.height() * .20),
                right: 0,
                left: 0,
                bottom: 0,
                child: Container(
                  //    padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: whiteBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24), // Rounded corner top-left
                        topRight: Radius.circular(24), // Rounded corner top-right
                      )),
                  child: Observer(
                    builder: (BuildContext context) {
                      return Stack(
                        children: [
                          Positioned(
                            top: (appStore.isLoggedIn)
                                ? (context.height() * .15)
                                : 0,
                            right: 0,
                            left: 0,
                            bottom: 0,
                            child: AnimatedScrollView(
                              listAnimationType: ListAnimationType.FadeIn,
                              fadeInConfiguration:
                                  FadeInConfiguration(duration: 2.seconds),
                              padding: EdgeInsets.only(bottom: 32),
                              crossAxisAlignment: CrossAxisAlignment.center,
                              onSwipeRefresh: () {
                                init();
                                setState(() {});
                                return 1.seconds.delay;
                              },
                              children: [
                                /*if (appStore.isLoggedIn)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: context.height() * 0.12,
                                      ),
                                      24.height,
                                      Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          Container(
                                            decoration: boxDecorationDefault(
                                              border: Border.all(
                                                  color: primaryColor, width: 3),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Container(
                                              decoration: boxDecorationDefault(
                                                border: Border.all(
                                                    color:
                                                    context.scaffoldBackgroundColor,
                                                    width: 4),
                                                shape: BoxShape.circle,
                                              ),
                                              child: CachedImageWidget(
                                                url: appStore.userProfileImage,
                                                height: 90,
                                                width: 90,
                                                fit: BoxFit.cover,
                                                radius: 60,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 8,
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.all(6),
                                              decoration: boxDecorationDefault(
                                                shape: BoxShape.circle,
                                                color: primaryColor,
                                                border: Border.all(
                                                    color: context.cardColor, width: 2),
                                              ),
                                              child: Icon(AntDesign.edit,
                                                  color: white, size: 18),
                                            ).onTap(() {
                                              EditProfileScreen().launch(context);
                                            }),
                                          ),
                                        ],
                                      ),
                                      16.height,
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(appStore.userFullName,
                                              style: boldTextStyle(
                                                  color: primaryColor, size: 16)),
                                          Text(appStore.userEmail,
                                              style: secondaryTextStyle()),
                                        ],
                                      ),
                                      24.height,
                                    ],
                                  ).center(),*/

                                Observer(builder: (context) {
                                  return SettingSection(
                                    title: Text(language.lblGENERAL,
                                        style: boldTextStyle(
                                            color: primaryColor,
                                            size: 20,
                                            fontFamily:
                                                GoogleFonts.mulish().fontFamily,
                                            weight: FontWeight.w700)),
                                    headingDecoration: BoxDecoration(
                                        color: context.primaryColor
                                            .withOpacity(0.1)),
                                    divider: Offstage(),
                                    items: [
                                      /*if (appStore.isLoggedIn &&
                                          appConfigurationStore
                                              .isEnableUserWallet)
                                        SettingItemWidget(
                                          leading: ic_un_fill_wallet.iconSvgImage(
                                              size: SETTING_ICON_SIZE,
                                              color: context.primaryColor),
                                          title: language.walletBalance,
                                          titleTextColor: black1A1C1E,
                                          onTap: () {
                                            if (appConfigurationStore
                                                .onlinePaymentStatus) {
                                              UserWalletBalanceScreen()
                                                  .launch(context);
                                            }
                                          },
                                          trailing: Text(
                                            appStore.userWalletAmount
                                                .toPriceFormat(),
                                            style: boldTextStyle(
                                                color: balanceColor,
                                                size: 16,
                                                fontFamily: GoogleFonts.mulish()
                                                    .fontFamily),
                                          ),
                                        ),
                                      16.height,*/ // wallet Balance
                                      /*if (appStore.isLoggedIn &&
                                          appConfigurationStore
                                              .isEnableUserWallet)
                                        SettingItemWidget(
                                          leading: ic_document.iconSvgImage(
                                              size: SETTING_ICON_SIZE,
                                              color: primaryColor),
                                          title: language.walletHistory,
                                          titleTextColor: black1A1C1E,
                                          trailing: trailing,
                                          onTap: () {
                                            UserWalletHistoryScreen()
                                                .launch(context);
                                          },
                                        ),*/ // Wallet history
                                      if (appStore.isLoggedIn)
                                      SettingItemWidget(
                                        leading: /*ic_document.iconSvgImage(
                                            size: SETTING_ICON_SIZE,
                                            color: primaryColor)*/Icon(AntDesign.edit, color: primaryColor, size: SETTING_ICON_SIZE),
                                        title: language.editProfile,
                                        titleTextColor: black1A1C1E,
                                        trailing: trailing,
                                        onTap: () {
                                          EditProfileScreen().launch(context);
                                        },
                                      ),
                                      // favourite service
                                      SettingItemWidget(
                                        leading: ic_heart.iconSvgImage(
                                            size: SETTING_ICON_SIZE,
                                            color: primaryColor),
                                        title: language.lblFavorite,
                                        titleTextColor: black1A1C1E,
                                        trailing: trailing,
                                        onTap: () {
                                          doIfLoggedIn(context, () {
                                            FavouriteServiceScreen()
                                                .launch(context);
                                          });
                                        },
                                      ),
                                      SettingItemWidget(
                                        leading: ic_provider.iconSvgImage(
                                            size: SETTING_ICON_SIZE,
                                            color: primaryColor),
                                        title: language.favouriteProvider,
                                        titleTextColor: black1A1C1E,
                                        trailing: trailing,
                                        onTap: () {
                                          doIfLoggedIn(context, () {
                                            FavouriteProviderScreen()
                                                .launch(context);
                                          });
                                        },
                                      ),
                                      if (appConfigurationStore.blogStatus)
                                      SettingItemWidget(
                                          leading: ic_blogs.iconSvgImage(
                                              size: SETTING_ICON_SIZE,
                                              color: primaryColor),
                                          title: language.blogs,
                                          titleTextColor: black1A1C1E,
                                          trailing: trailing,
                                          onTap: () {
                                            BlogListScreen().launch(context);
                                          },
                                        ),
                                      SettingItemWidget(
                                        leading: ic_star.iconImage(
                                            size: SETTING_ICON_SIZE,
                                            color: primaryColor),
                                        title: language.rateUs,
                                        titleTextColor: black1A1C1E,
                                        trailing: trailing,
                                        onTap: () async {
                                          // if (isAndroid) {
                                          //   if (getStringAsync(CUSTOMER_PLAY_STORE_URL).isNotEmpty) {
                                          //     commonLaunchUrl(getStringAsync(CUSTOMER_PLAY_STORE_URL), launchMode: LaunchMode.externalApplication);
                                          //   } else {
                                          //     commonLaunchUrl('${getSocialMediaLink(LinkProvider.PLAY_STORE)}${await getPackageName()}', launchMode: LaunchMode.externalApplication);
                                          //   }
                                          // } else if (isIOS) {
                                          //   if (getStringAsync(CUSTOMER_APP_STORE_URL).isNotEmpty) {
                                          //     commonLaunchUrl(getStringAsync(CUSTOMER_APP_STORE_URL), launchMode: LaunchMode.externalApplication);
                                          //   } else {
                                          //     commonLaunchUrl(IOS_LINK_FOR_USER, launchMode: LaunchMode.externalApplication);
                                          //   }
                                          // }
                                        },
                                      ),// Rate us
                                      SettingItemWidget(
                                        leading: ic_review.iconSvgImage(
                                            size: SETTING_ICON_SIZE,
                                            color: primaryColor),
                                        title: language.myReviews,
                                        titleTextColor: black1A1C1E,
                                        trailing: trailing,
                                        onTap: () async {
                                          doIfLoggedIn(context, () {
                                            CustomerRatingScreen()
                                                .launch(context);
                                          });
                                        },
                                      ),
                                    ],
                                  );
                                }),
                                SettingSection(
                                  title: Text(language.lblAboutApp.toUpperCase(),
                                      style: boldTextStyle(
                                          color: primaryColor,
                                          fontFamily:
                                              GoogleFonts.mulish().fontFamily,
                                          size: 20)),
                                  headingDecoration: BoxDecoration(
                                      color:
                                          primaryColor.withOpacity(0.1)),
                                  divider: Offstage(),
                                  items: [
                                    8.height,
                                    /// about section comment
                                    // SettingItemWidget(
                                    //   leading: ic_about_us.iconImage(
                                    //       size: SETTING_ICON_SIZE,
                                    //       color: primaryColor),
                                    //   title: language.lblAboutApp,
                                    //   titleTextColor: black1A1C1E,
                                    //   onTap: () {
                                    //     AboutScreen().launch(context);
                                    //   },
                                    // ),
                                    SettingItemWidget(
                                      leading: ic_shield_done.iconImage(
                                          size: SETTING_ICON_SIZE,
                                          color: primaryColor),
                                      title: language.privacyPolicy,
                                      titleTextColor: black1A1C1E,
                                      onTap: () {
                                        checkIfLink(context,
                                            appConfigurationStore.privacyPolicy,
                                            title: language.privacyPolicy);
                                      },
                                    ),
                                    SettingItemWidget(
                                      leading: ic_document.iconSvgImage(
                                          size: SETTING_ICON_SIZE,
                                          color: primaryColor),
                                      title: language.termsCondition,
                                      titleTextColor: black1A1C1E,
                                      onTap: () {
                                        checkIfLink(context,
                                            appConfigurationStore.termConditions,
                                            title: language.termsCondition);
                                      },
                                    ),
                                    SettingItemWidget(
                                      leading: ic_document.iconSvgImage(
                                          size: SETTING_ICON_SIZE,
                                          color: primaryColor),
                                      title: language.refundPolicy,
                                      titleTextColor: black1A1C1E,
                                      onTap: () {
                                        checkIfLink(context,
                                            appConfigurationStore.refundPolicy,
                                            title: language.termsCondition);
                                      },
                                    ),
                                    if (appConfigurationStore
                                        .inquiryEmail.isNotEmpty)
                                      SettingItemWidget(
                                        leading: ic_helpAndSupport.iconImage(
                                            size: SETTING_ICON_SIZE,
                                            color: primaryColor),
                                        title: language.helpSupport,
                                        titleTextColor: black1A1C1E,
                                        onTap: () {
                                          checkIfLink(
                                              context,
                                              appConfigurationStore.inquiryEmail
                                                  .validate(),
                                              title: language.helpSupport);
                                        },
                                      ),
                                    if (appConfigurationStore
                                        .helplineNumber.isNotEmpty)
                                      SettingItemWidget(
                                        leading: ic_calling.iconImage(
                                            size: SETTING_ICON_SIZE,
                                            color: primaryColor),
                                        title: language.lblHelplineNumber,
                                        titleTextColor: black1A1C1E,
                                        onTap: () {
                                          launchCall(appConfigurationStore
                                              .helplineNumber
                                              .validate());
                                        },
                                      ),
                                    SettingItemWidget(
                                      leading: Icon(MaterialCommunityIcons.logout,
                                          color: context.iconColor,
                                          size: SETTING_ICON_SIZE),
                                      title: language.signIn,
                                      titleTextColor: black1A1C1E,
                                      onTap: () {
                                        SignInScreen().launch(context);
                                      },
                                    ).visible(!appStore.isLoggedIn),
                                  ],
                                ),
                               /* SettingSection(
                                  title: Text(
                                      language.lblDangerZone.toUpperCase(),
                                      style: boldTextStyle(color: redColor)),
                                  headingDecoration: BoxDecoration(
                                      color: redColor.withOpacity(0.08)),
                                  divider: Offstage(),
                                  items: [
                                    8.height,
                                    SettingItemWidget(
                                      leading: ic_delete_account.iconImage(
                                          size: SETTING_ICON_SIZE,
                                          color: primaryColor),
                                      paddingBeforeTrailing: 4,
                                      title: language.lblDeleteAccount,
                                      titleTextColor: black1A1C1E,
                                      onTap: () {
                                        showDeleteDialog(context);
                                        // showConfirmDialogCustom(
                                        //   positiveTextColor: pureBlack,
                                        //   negativeTextColor: pureBlack,
                                        //   primaryColor: Colors.red,
                                        //   context,
                                        //   negativeText: language.lblCancel,
                                        //   positiveText: language.lblDelete,
                                        //
                                        //   onAccept: (_) {
                                        //     ifNotTester(() {
                                        //       appStore.setLoading(true);
                                        //
                                        //       deleteAccountCompletely()
                                        //           .then((value) async {
                                        //         try {
                                        //           await userService
                                        //               .removeDocument(appStore.uid);
                                        //           await userService.deleteUser();
                                        //         } catch (e) {
                                        //           print(e);
                                        //         }
                                        //
                                        //         appStore.setLoading(false);
                                        //
                                        //         await clearPreferences();
                                        //         toast(value.message);
                                        //
                                        //         push(DashboardScreen(),
                                        //             isNewTask: true,
                                        //             pageRouteAnimation:
                                        //                 PageRouteAnimation.Fade);
                                        //       }).catchError((e) {
                                        //         appStore.setLoading(false);
                                        //         toast(e.toString());
                                        //       });
                                        //     });
                                        //   },
                                        //   dialogType: DialogType.DELETE,
                                        //   title:
                                        //       language.lblDeleteAccountConformation,
                                        // );
                                      },
                                    ).paddingOnly(left: 4), // Delete Account
                                    64.height,
                                    TextButton(
                                      child: Text(language.logout,
                                          style: boldTextStyle(
                                              color: primaryColor, size: 16)),
                                      onPressed: () {
                                        logout(context);
                                      },
                                    ).center(),// logout text
                                  ],
                                ).visible(appStore.isLoggedIn),*/
                                30.height.visible(!appStore.isLoggedIn),

                                /// version information commented
                                // SnapHelperWidget<PackageInfoData>(
                                //   future: getPackageInfo(),
                                //   onSuccess: (data) {
                                //     return TextButton(
                                //       child: VersionInfoWidget(
                                //           prefixText: 'v',
                                //           textStyle: secondaryTextStyle()),
                                //       onPressed: () {
                                //         showAboutDialog(
                                //           context: context,
                                //           applicationName: APP_NAME,
                                //           applicationVersion: data.versionName,
                                //           applicationIcon:
                                //               Image.asset(appLogo, height: 50),
                                //         );
                                //       },
                                //     ).center();
                                //   },
                                // ),
                              ],
                            ),
                          ),
                          Observer(
                              builder: (context) =>
                                  LoaderWidget().visible(appStore.isLoading)),
                        ],
                      );
                    },
                  ),
                ),
              ),
              if (appStore.isLoggedIn)
                Positioned(
                  top: (context.height() * .16),
                  right: 0,
                  left: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: boxDecorationDefault(
                              border: Border.all(color: primaryColor, width: 3),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              decoration: boxDecorationDefault(
                                border: Border.all(
                                    color: context.scaffoldBackgroundColor,
                                    width: 4),
                                shape: BoxShape.circle,
                              ),
                              child: CachedImageWidget(
                                url: appStore.userProfileImage,
                                height: 90,
                                width: 90,
                                fit: BoxFit.cover,
                                radius: 60,
                              ),
                            ),
                          ),
                          /*Positioned(
                            bottom: 0,
                            right: 8,
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(6),
                              decoration: boxDecorationDefault(
                                shape: BoxShape.circle,
                                color: primaryColor,
                                border: Border.all(
                                    color: context.cardColor, width: 2),
                              ),
                              child: Icon(AntDesign.edit, color: white, size: 18),
                            ).onTap(() {
                              EditProfileScreen().launch(context);
                            }),
                          ),*/
                        ],
                      ),
                      16.height,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(appStore.userFullName,
                              style: boldTextStyle(
                                  color: primaryColor,
                                  size: 22,
                                  fontFamily: GoogleFonts.mulish().fontFamily)),
                          // Text(appStore.userEmail, style: secondaryTextStyle()),
                        ],
                      ),
                      24.height,
                    ],
                  ).center(),
                ),

              /* Column(
                children: [
                  SizedBox(
                    height: context.height() * .072,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 24.0),
                        child: Text(
                          language.profile,
                          style: (boldTextStyle(
                            color: white,
                            size: APP_BAR_TEXT_SIZE,
                          )),
                        ),
                      ),
                      IconButton(
                        icon: ic_setting.iconSvgImage(color: white, size: 36),
                        onPressed: () async {
                          SettingScreen().launch(context);
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: context.height() * 0.09,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24), // Rounded corner top-left
                            topRight:
                                Radius.circular(24), // Rounded corner top-right
                          )),
                    ),
                  ),
                ],
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
