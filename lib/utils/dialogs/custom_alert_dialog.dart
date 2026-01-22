import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_service_user/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class CustomAlertDialog extends StatelessWidget {
  final DialogType dialogType;
  final String? title;
  final String? subTitle;
  final String? positiveText;
  final String? negativeText;
  final Function(BuildContext)? onAccept;
  final Function(BuildContext)? onCancel;
  final double? height;
  final double? width;
  final double? elevation;
  final Color? backgroundColor;
  final Color? positiveTextColor;
  final Color? negativeTextColor;
  final Color? primaryColor;
  final bool cancelable;
  final ShapeBorder? shape;
  final Widget? customCenterWidget;
  final String? centerImage;

  const CustomAlertDialog({
    super.key,
    required this.dialogType,
    this.title,
    this.subTitle,
    this.positiveText,
    this.negativeText,
    this.onAccept,
    this.onCancel,
    this.height,
    this.width,
    this.elevation,
    this.backgroundColor,
    this.positiveTextColor,
    this.negativeTextColor,
    this.primaryColor,
    this.cancelable = true,
    this.shape,
    this.customCenterWidget,
    this.centerImage,
  });

  @override
  Widget build(BuildContext context) {
    final widthVal = width ?? customDialogWidth;
    final heightVal = height ?? customDialogHeight;

    return AlertDialog(
      shape: shape ?? dialogShape(),
      titlePadding: EdgeInsets.zero,
      backgroundColor: backgroundColor ?? context.cardColor,
      elevation: elevation ?? defaultElevation.toDouble(),
      title: buildTitleWidget(
        context,
        dialogType,
        primaryColor,
        customCenterWidget,
        heightVal,
        widthVal,
        centerImage,
        shape,
      ).cornerRadiusWithClipRRectOnly(
          topLeft: defaultRadius.toInt(), topRight: defaultRadius.toInt()),
      content: SafeArea(
        top: false,
        child: Container(
          width: widthVal,
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if(title!=null)
              Text(
                title ?? /*getTitle(dialogType)*/"",
                style: boldTextStyle(size: 16),
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
                    color: context.cardColor,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close,
                          color: grey636D77,
                          size: 20,
                        ),
                        6.width,
                        Text(
                          negativeText ?? 'Cancel',
                          style: boldTextStyle(
                              color: negativeTextColor ?? textPrimaryColorGlobal),
                        ),
                      ],
                    ).fit(),
                    onTap: () {
                      if (cancelable) finish(context, false);
                      onCancel?.call(context);
                    },
                  ).expand(),
                  16.width,
                  AppButton(
                    elevation: 0,
                    color: getDialogPrimaryColor(context, dialogType, primaryColor),
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
                      onAccept?.call(context);
                      if (cancelable) finish(context, true);
                    },
                  ).expand(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
