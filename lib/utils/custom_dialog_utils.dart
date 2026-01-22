import 'package:flutter/material.dart';
import 'package:home_service_user/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

// Assume your enums, styles, and helper functions like getIcon(), buildTitleWidget(), etc., are imported or defined properly

class CustomDialogUtils {
  static Future<bool?> showConfirmDialogCustom(
      BuildContext context, {
        required Function(BuildContext) onAccept,
        String? title,
        String? subTitle,
        String? positiveText,
        String? negativeText,
        String? centerImage,
        Widget? customCenterWidget,
        Color? primaryColor,
        Color? positiveTextColor,
        Color? negativeTextColor,
        ShapeBorder? shape,
        Function(BuildContext)? onCancel,
        bool barrierDismissible = true,
        double? height,
        double? width,
        bool cancelable = true,
        Color? barrierColor,
        DialogType dialogType = DialogType.CONFIRMATION,
        DialogAnimation dialogAnimation = DialogAnimation.DEFAULT,
        Duration? transitionDuration,
        Curve curve = Curves.easeInBack,
      }) async {
    hideKeyboard(context);

    return await showGeneralDialog(
      context: context,
      barrierColor: barrierColor ?? Colors.black54,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      barrierDismissible: barrierDismissible,
      barrierLabel: '',
      transitionDuration: transitionDuration ?? 400.milliseconds,
      transitionBuilder: (_, animation, secondaryAnimation, child) {
        return dialogAnimatedWrapperWidget(
          animation: animation,
          dialogAnimation: dialogAnimation,
          curve: curve,
          child: AlertDialog(
            shape: shape ?? dialogShape(),
            titlePadding: EdgeInsets.zero,
            backgroundColor: _.cardColor,
            elevation: defaultElevation.toDouble(),
            title: buildTitleWidget(
              _,
              dialogType,
              primaryColor,
              customCenterWidget,
              height ?? customDialogHeight,
              width ?? customDialogWidth,
              centerImage,
              shape,
            ).cornerRadiusWithClipRRectOnly(
                topLeft: defaultRadius.toInt(),
                topRight: defaultRadius.toInt()),
            content: Container(
              width: width ?? customDialogWidth,
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title ?? getTitle(dialogType),
                    style: boldTextStyle(size: 16,color: black1A1C1E),
                    textAlign: TextAlign.center,
                  ),
                  8.height.visible(subTitle.validate().isNotEmpty),
                  Text(
                    subTitle.validate(),
                    style: secondaryTextStyle(size: 16),
                    textAlign: TextAlign.center,
                  ).visible(subTitle.validate().isNotEmpty),
                  16.height,
                  Row(
                    children: [
                      AppButton(
                        elevation: 0,
                        shapeBorder: RoundedRectangleBorder(
                          borderRadius: radius(defaultAppButtonRadius),
                          side: BorderSide(color: viewLineColor),
                        ),
                        color: greyAEAEB2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.close,
                              color: textPrimaryColorGlobal,
                              size: 20,
                            ),
                            6.width,
                            Text(
                              negativeText ?? 'Cancel',
                              style: boldTextStyle(
                                  color: negativeTextColor ??
                                      textPrimaryColorGlobal),
                            ),
                          ],
                        ).fit(),
                        onTap: () {
                          if (cancelable) finish(_, false);
                          onCancel?.call(_);
                        },
                      ).expand(),
                      16.width,
                      AppButton(
                        elevation: 0,
                        color: getDialogPrimaryColor(_, dialogType, primaryColor),
                        shapeBorder: RoundedRectangleBorder(
                          borderRadius: radius(defaultAppButtonRadius),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            getIcon(dialogType),
                            6.width,
                            Text(
                              positiveText ?? getPositiveText(dialogType),
                              style: boldTextStyle(
                                  color: positiveTextColor ?? Colors.white),
                            ),
                          ],
                        ).fit(),
                        onTap: () {
                          onAccept.call(_);
                          if (cancelable) finish(_, true);
                        },
                      ).expand(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
