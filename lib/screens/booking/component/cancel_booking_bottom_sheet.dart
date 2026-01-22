import 'package:home_service_user/component/chat_gpt_loder.dart';
import 'package:home_service_user/component/common_button.dart';
import 'package:home_service_user/component/loader_widget.dart';
import 'package:home_service_user/utils/common.dart';
import 'package:home_service_user/utils/images.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
 
import '../../../model/booking_detail_model.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/colors.dart';
import '../../../utils/constant.dart';
import '../../../utils/model_keys.dart';
class CancelBookingBottomSheet extends StatefulWidget {
  final Function(String reason)? onSubmit;
  final BookingDetailResponse status;
  const CancelBookingBottomSheet({Key? key,this.onSubmit,required this.status}) : super(key: key);

  @override
  State<CancelBookingBottomSheet> createState() => _CancelBookingBottomSheetState();
}

class _CancelBookingBottomSheetState extends State<CancelBookingBottomSheet> {
 // Future<List<BookingStatusResponse>>? future;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController _textFieldReason = TextEditingController();
  // Widget itemWidget(BookingStatusResponse res) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
  //     decoration: boxDecorationDefault(
  //       color: appStore.isDarkMode
  //           ? res.isSelected
  //               ? lightPrimaryColor
  //               : context.scaffoldBackgroundColor
  //           : res.isSelected
  //               ? lightPrimaryColor
  //               : context.scaffoldBackgroundColor,
  //       borderRadius: radius(100),
  //       border: Border.all(color: appStore.isDarkMode ? Colors.white54 : lightPrimaryColor),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         if (res.isSelected)
  //           Container(
  //             padding: EdgeInsets.all(2),
  //             margin: EdgeInsets.only(right: 1),
  //             child: Icon(Icons.done, size: 16, color: primaryColor),
  //           ),
  //         Text(
  //           res.value.validate().toBookingStatus(),
  //           style: primaryTextStyle(
  //               color: appStore.isDarkMode
  //                   ? res.isSelected
  //                       ? primaryColor
  //                       : Colors.white54
  //                   : res.isSelected
  //                       ? primaryColor
  //                       : Colors.black38,
  //               size: 13, fontFamily: GoogleFonts.mulish().fontFamily),
  //         ),
  //       ],
  //     ),
  //   ).onTap(() {
  //     res.isSelected = !res.isSelected;

  //     setState(() {});
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: boxDecorationWithRoundedCorners(borderRadius: radiusOnly(topLeft: 16, topRight: 16), backgroundColor: context.cardColor),
        padding: EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
             /* Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                SizedBox(),
                  IconButton(
                    padding: EdgeInsets.all(0),
                    icon: *//*ic_clear.iconSvgImage()*//* Icon(Icons.close, color:  primaryColor, size: 20),  //         Icon(Icons.close, color: appStore.isDarkMode ? lightPrimaryColor : primaryColor, size: 20),
                    visualDensity: VisualDensity.compact,
                    onPressed: () async {
                      finish(context);
                    },
                  ),
                ],
              ),
              8.height,
              Container(width: context.width() - 16, height: 1, color: gray.withOpacity(0.1)).center(),*/
              24.height,
              Text(language.lblCancelReason, style: primaryTextStyle(size: 20,color: black1A1C1E, fontFamily: GoogleFonts.mulish().fontFamily, weight: FontWeight.w700)),
              24.height,
             Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: context.width(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          Align(
                      alignment:Alignment.topLeft,
                            child: Text(language.enterReason,style:  GoogleFonts.mulish(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),),
                          ),
                          10.height,
                          AppTextField(
                            controller: _textFieldReason,
                            textFieldType: TextFieldType.MULTILINE,
                            decoration: inputDecoration(context,),
                            enableChatGPT: /*appConfigurationStore.chatGPTStatus*/false,
                            promptFieldInputDecorationChatGPT: inputDecoration(context).copyWith(
                              hintText: language.writeHere,
                              fillColor: context.scaffoldBackgroundColor,
                              filled: true,
                            ),
                            textStyle: GoogleFonts.mulish(
                                fontSize:16,
                                fontWeight:FontWeight.w600,
                                color:black1A1C1E
                            ),
                            testWithoutKeyChatGPT: appConfigurationStore.testWithoutKey,
                            loaderWidgetForChatGPT: const ChatGPTLoadingWidget(),
                            minLines: 4,
                            maxLines: 10,
                          ),
                        ],
                      ),
                    ),
                    24.height,
                    AppButton(
                      color: primaryColor,
                      height: 40,
                      text: language.btnSubmit,
                      textStyle: boldTextStyle(color: Colors.white),
                      width: context.width() - context.navigationBarHeight,
                      onTap: () async {
                        if (_textFieldReason.text.trim().isEmpty) {
                          toast(language.enterReason);
                          return;
                        }

                        widget.onSubmit?.call(_textFieldReason.text.trim()); // <-- invoke callback

                        Map request = {
                          CommonKeys.id: widget.status.bookingDetail!.id.validate(),
                          BookingUpdateKeys.startAt: widget.status.bookingDetail!.date.validate(),
                          BookingUpdateKeys.endAt: formatBookingDate(DateTime.now().toString(), format: BOOKING_SAVE_FORMAT, isLanguageNeeded: false),
                          BookingUpdateKeys.durationDiff: widget.status.bookingDetail!.durationDiff.validate(),
                          BookingUpdateKeys.reason: _textFieldReason.text,
                          CommonKeys.status: BookingStatusKeys.cancelled,
                          CommonKeys.advancePaidAmount: widget.status.bookingDetail!.paidAmount,
                          BookingUpdateKeys.paymentStatus: widget.status.bookingDetail!.isAdvancePaymentDone ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID : widget.status.bookingDetail!.paymentStatus.validate(),
                        };

                        appStore.setLoading(true);

                        await updateBooking(request).then((res) async {
                          toast(res.message!);
                          finish(context, true);
                        }).catchError((e) {
                          toast(e.toString(), print: true);
                        });

                        appStore.setLoading(false);




                        finish(context);
                      },
                    ),
                    8.height,
                  ],
                ).paddingAll(16)
              ],
            ),
          ),
          Observer(
            builder: (context) => LoaderWidget().withSize(height: 80, width: 80).visible(appStore.isLoading),
          )
        ],
      ),
              24.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppButton(
                    color: primaryColor,
                    height: 40,
                    text: language.clearFilter,
                    textStyle: boldTextStyle(color: Colors.white),
                    width: context.width() - context.navigationBarHeight,
                    onTap: () {
                      finish(context);
                      //     init();
                      LiveStream().emit(LIVESTREAM_UPDATE_BOOKING_LIST);
                    },
                  ).expand(),

                /*  CommonButton(
                    height: 48,
                    text: language.clearFilter,
                    color: greyAEAEB2*//*appStore.isDarkMode ? grey636D77*//**//*context.scaffoldBackgroundColor*//**//* : grey636D77*//*,
                    textColor: appStore.isDarkMode ? white : white,
                    width: context.width() - context.navigationBarHeight,
                    onTap: () {
                      finish(context);
                 //     init();
                      LiveStream().emit(LIVESTREAM_UPDATE_BOOKING_LIST);
                    },
                  ).expand(),*/


                ],
              ).paddingOnly(left: 16, right: 16, bottom: 16),
            ],
          ),
        ),
      ),
    );
  }
}
