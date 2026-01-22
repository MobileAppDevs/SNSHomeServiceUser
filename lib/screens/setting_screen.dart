import 'package:flutter/material.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../component/app_common_dialog.dart';
import '../component/base_scaffold_widget.dart';
import '../component/delete_dialog.dart';
import '../component/theme_selection_dialog.dart';
import '../main.dart';
import '../network/rest_apis.dart';
import '../utils/colors.dart';
import '../utils/common.dart';
import '../utils/constant.dart';
import '../utils/images.dart';
import 'auth/change_password_screen.dart';
import 'booking/component/reason_dialog.dart';
import 'language_screen.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.lblAppSetting,
      child: AnimatedScrollView(
        padding: EdgeInsets.symmetric(vertical: 8),
        listAnimationType: ListAnimationType.FadeIn,
        fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
        children: [
          if (isLoginTypeUser)
            SettingItemWidget(
              leading: ic_lock.iconImage(size: SETTING_ICON_SIZE),
              title: language.changePassword,
              titleTextColor: black,
              trailing: trailing,
              onTap: () {
                doIfLoggedIn(context, () {
                  ChangePasswordScreen(changePwdTargetEmail:appStore.userEmail).launch(context);
                });
              },
            ),
          /// laguage chage
          // SettingItemWidget(
          //   leading: ic_language.iconImage(size: 17).paddingOnly(left: 2),
          //   paddingAfterLeading: 16,
          //   titleTextColor: black,
          //   title: language.language,
          //   trailing: trailing,
          //   onTap: () {
          //     LanguagesScreen().launch(context).then((value) {
          //       setState(() {});
          //     });
          //   },
          // ),

          // SettingItemWidget(
          //   leading: ic_dark_mode.iconImage(size: 22),
          //   title: language.appTheme,
          //   paddingAfterLeading: 12,
          //   trailing: trailing,
          //   onTap: () async {
          //     await showInDialog(
          //       context,
          //       builder: (context) => ThemeSelectionDaiLog(),
          //       contentPadding: EdgeInsets.zero,
          //     );
          //   },
          // ),
          SettingItemWidget(
            leading: ic_slider_status.iconImage(size: SETTING_ICON_SIZE),
            title: language.lblAutoSliderStatus,
            titleTextColor: black,
            trailing: Transform.scale(
              scale: 0.8,
              child: Switch.adaptive(
                activeColor: primaryColor,
                value: getBoolAsync(AUTO_SLIDER_STATUS, defaultValue: true),
                onChanged: (v) {
                  setValue(AUTO_SLIDER_STATUS, v);
                  setState(() {});
                },
              ).withHeight(24),
            ),
          ),
          SettingItemWidget(
            leading: ic_check_update.iconImage(size: SETTING_ICON_SIZE),
            title: language.lblOptionalUpdateNotify,
            titleTextColor: black,
            trailing: Transform.scale(
              scale: 0.8,
              child: Switch.adaptive(
                activeColor: primaryColor,
                value: getBoolAsync(UPDATE_NOTIFY, defaultValue: true),
                onChanged: (v) {
                  setValue(UPDATE_NOTIFY, v);
                  setState(() {});
                },
              ).withHeight(24),
            ),
          ),

          /// enable material theme commented
          // SnapHelperWidget<bool>(
          //   future: isAndroid12Above(),
          //   onSuccess: (data) {
          //     if (data) {
          //       return SettingItemWidget(
          //         leading: ic_android_12.iconImage(size: SETTING_ICON_SIZE),
          //         title: language.lblMaterialTheme,
          //         titleTextColor: black,
          //         trailing: Transform.scale(
          //           scale: 0.8,
          //           child: Switch.adaptive(
          //             //activeColor: primaryColor,
          //             value: appStore.useMaterialYouTheme,
          //             onChanged: (v) {
          //               showInDialog(context, contentPadding: EdgeInsets.zero,
          //                   builder: (context) {
          //                 return AppCommonDialog(
          //                     title: language.lblCancelReason,
          //                     child: Container(
          //                       child: Column(
          //                         spacing: 32,
          //                         children: [
          //                           SizedBox(
          //                             height: 32,
          //                           ),
          //                           Text(language.lblAndroid12Support),
          //                           Row(
          //                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //                             children: [
          //                               ElevatedButton(
          //                                 style: ElevatedButton.styleFrom(
          //                                   backgroundColor: Colors.grey.shade300,
          //                                 ),
          //                                 onPressed: () {
          //                                   Navigator.pop(context);
          //
          //                                 },
          //                                 child: Text(
          //                                   language.lblCancel,
          //                                   style: TextStyle(color: Colors.black),
          //                                 ),
          //                               ),
          //                               ElevatedButton(
          //                                 style: ElevatedButton.styleFrom(
          //                                   backgroundColor: primaryColor,
          //                                 ),
          //                                 onPressed: () {
          //                                   Navigator.pop(context);
          //                                   appStore.setUseMaterialYouTheme(v.validate());
          //                                 },
          //                                 child: Text(
          //                                   language.lblYes,
          //                                   style: TextStyle(color: Colors.white),
          //                                 ),
          //                               ),
          //                             ],
          //                           ),
          //                           SizedBox(
          //                             height: 32,
          //                           )
          //                         ],
          //                       ),
          //                     ));
          //               });
          //               // showConfirmDialogCustom(
          //               //   context,
          //               //   onAccept: (_) {
          //               //     appStore.setUseMaterialYouTheme(v.validate());
          //               //
          //               //     RestartAppWidget.init(context);
          //               //   },
          //               //   title: language.lblAndroid12Support,
          //               //
          //               //    primaryColor: primaryColor,
          //               //   positiveText: language.lblYes,
          //               //   negativeText: language.lblCancel,
          //               //   negativeTextColor: primaryColor,
          //               //
          //               //
          //               // );
          //             },
          //           ).withHeight(24),
          //         ),
          //         onTap: null,
          //       );
          //     }
          //     return Offstage();
          //   },
          // ),


          /// Danger Zone
          SettingSection(
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
          ).visible(appStore.isLoggedIn),

        ],
      ),
    );
  }
}
