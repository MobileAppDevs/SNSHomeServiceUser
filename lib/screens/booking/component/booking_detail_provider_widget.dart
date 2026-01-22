import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/component/disabled_rating_bar_widget.dart';
import 'package:home_service_user/component/image_border_component.dart';
import 'package:home_service_user/main.dart';
import 'package:home_service_user/model/user_data_model.dart';
import 'package:home_service_user/utils/colors.dart';
import 'package:home_service_user/utils/common.dart';
import 'package:home_service_user/utils/images.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../chat/user_chat_screen.dart';

class BookingDetailProviderWidget extends StatefulWidget {
  final UserData providerData;
  final bool canCustomerContact;
  final bool providerIsHandyman;

  BookingDetailProviderWidget({required this.providerData, this.canCustomerContact = false, this.providerIsHandyman = false});

  @override
  BookingDetailProviderWidgetState createState() => BookingDetailProviderWidgetState();
}

class BookingDetailProviderWidgetState extends State<BookingDetailProviderWidget> {
  UserData userData = UserData();

  int? flag;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    userData = widget.providerData;

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.only(left: 15,right: 15,top: 9,bottom: 9),
        decoration: boxDecorationDefault(color: /*context.cardColor*/Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: greyE5E8E9,width: 1)),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ImageBorder(src: widget.providerData.profileImage.validate(), height: 40),
                16.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(widget.providerData.displayName.validate(), style:  boldTextAutoStyle(context:context,commonColor: black1A1D1F,fontFamily: GoogleFonts.mulish().fontFamily)).flexible(),
                        16.width,
                        ic_info.iconImage(size: 20),
                      ],
                    ),
                    4.height,
                    DisabledRatingBarWidget(rating: widget.providerData.providersServiceRating.validate()),
                  ],
                ).expand(),
                Image.asset(ic_verified, height: 24, width: 24, color: verifyAcColor).visible(widget.providerData.isVerifyProvider == 1),
              ],
            ),
            if (widget.canCustomerContact)
              Column(
                children: [
                  16.height,
                  TextIcon(
                    spacing: 10,
                    onTap: () {
                      launchMail("${widget.providerData.email.validate()}");
                    },
                    prefix: Image.asset(ic_message, width: 20, height: 20, color: appStore.isDarkMode ? black999999 : black999999),
                    text: widget.providerData.email.validate(),
                    textStyle:  GoogleFonts.mulish(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: black999999,
                  ),
                    expandedText: true,
                  ),
                  if (widget.providerData.address.validate().isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        8.height,
                        TextIcon(
                          spacing: 10,
                          onTap: () {
                            launchMap("${widget.providerData.address.validate()}");
                          },
                          textStyle:  GoogleFonts.mulish(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: black999999,
                          ),
                          expandedText: true,
                          prefix: Image.asset(ic_location, width: 20, height: 20, color: appStore.isDarkMode ? black999999 : Colors.black),
                          text: '${widget.providerData.address.validate()}',
                        ),
                      ],
                    ),
                  8.height,
                  TextIcon(
                    spacing: 10,
                    onTap: () {
                      if (!widget.providerIsHandyman) {
                        launchCall(widget.providerData.contactNumber.validate());
                      }
                    },
                    textStyle:  GoogleFonts.mulish(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: black999999,
                    ),
                    prefix: Image.asset(ic_calling, width: 20, height: 20, color: appStore.isDarkMode ? black999999 : Colors.black),
                    text: '${widget.providerData.contactNumber.validate()}',
                    expandedText: true,
                  ),
                ],
              ),
            if (widget.providerIsHandyman)
              Row(
                children: [
                  if (widget.providerData.contactNumber.validate().isNotEmpty)
                    AppButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ic_calling.iconImage(size: 18, color: Colors.white),
                          8.width,
                          Text(language.lblCall, style: boldTextStyle(color: white)),
                        ],
                      ).fit(),
                      width: context.width(),
                      color: primaryColor,
                      elevation: 0,
                      onTap: () {
                        launchCall(widget.providerData.contactNumber.validate());
                      },
                    ).expand(),
                  16.width,
                  AppButton(
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: radius(defaultAppButtonRadius),
                      side: BorderSide(color: viewLineColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ic_chat.iconSvgImage(size: 18,color:black999999),
                        8.width,
                        Text(language.lblChat, style: boldTextAutoStyle(context: context,commonColor: black1A1C1E)),
                      ],
                    ).fit(),
                    width: context.width(),
                    elevation: 0,
                    color: /*context.scaffoldBackgroundColor*/Colors.white,

                    onTap: () async {
                      toast(language.pleaseWaitWhileWeLoadChatDetails);
                      UserData? user = await userService.getUserNull(email: widget.providerData.email.validate());
                      if (user != null) {
                        Fluttertoast.cancel();
                        UserChatScreen(receiverUser: user).launch(context);
                      } else {
                        Fluttertoast.cancel();
                        toast("${widget.providerData.firstName} ${language.isNotAvailableForChat}");
                      }
                    },
                  ).expand(),
                  16.width,
                  AppButton(
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: radius(defaultAppButtonRadius),
                      side: BorderSide(color: viewLineColor),
                    ),
                    child: Image.asset(ic_whatsapp, height: 18,),
                    elevation: 0,
                    color: /*context.scaffoldBackgroundColor*/Colors.white,
                    onTap: () async {
                      String phoneNumber = "";
                      if (widget.providerData.contactNumber.validate().contains('+')) {
                        phoneNumber = "${widget.providerData.contactNumber.validate().replaceAll('-', '')}";
                      } else {
                        phoneNumber = "+${widget.providerData.contactNumber.validate().replaceAll('-', '')}";
                      }
                      launchUrl(Uri.parse('${getSocialMediaLink(LinkProvider.WHATSAPP)}$phoneNumber'), mode: LaunchMode.externalApplication);
                    },
                  ),
                ],
              ).paddingTop(8),
          ],
        ),
      ),
    );
  }
}
