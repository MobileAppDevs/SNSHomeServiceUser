import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/component/loader_widget.dart';
import 'package:home_service_user/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../model/service_detail_response.dart';
import '../network/rest_apis.dart';
import '../utils/colors.dart';
import '../utils/custom_dialog_utils.dart';
import '../utils/images.dart';
import 'chat_gpt_loder.dart';
import 'common_button.dart';

class AddReviewDialog extends StatefulWidget {
  final RatingData? customerReview;
  final int? bookingId;
  final int? serviceId;
  final int? handymanId;
  final bool? isCustomerRating;

  AddReviewDialog(
      {this.customerReview,
      this.bookingId,
      this.serviceId,
      this.handymanId,
      this.isCustomerRating});

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  double selectedRating = 0;

  TextEditingController reviewCont = TextEditingController();

  bool isUpdate = false;
  bool isHandymanUpdate = false;

  @override
  void initState() {
    isUpdate = widget.customerReview != null;
    isHandymanUpdate =
        widget.customerReview != null && widget.handymanId != null;

    if (isUpdate) {
      selectedRating = widget.customerReview!.rating.validate().toDouble();
      reviewCont.text = widget.customerReview!.review.validate();
    }

    super.initState();
  }

  void submit() async {
    hideKeyboard(context);
    Map<String, dynamic> req = {};
    if (isUpdate) {
      req = {
        "id": widget.customerReview!.id.validate(),
        "booking_id": widget.customerReview!.bookingId.validate(),
        "service_id": widget.customerReview!.serviceId.validate(),
        "customer_id": appStore.userId.validate(),
        "rating": selectedRating.validate(),
        "review": reviewCont.text.validate(),
      };
      if (widget.handymanId != null) {
        req.putIfAbsent("handyman_id", () => widget.handymanId);
      }
      appStore.setLoading(true);

      if (widget.handymanId == null) {
        await updateReview(req).then((value) {
          toast(value.message);
          if (widget.isCustomerRating.validate(value: false)) {
            finish(context, req);
          } else {
            finish(context, true);
          }
        }).catchError((e) {
          toast(e.toString());
          finish(context, false);
        });
      } else {
        await handymanRating(req).then((value) {
          finish(context, true);
          toast(value.message);
        }).catchError((e) {
          toast(e.toString());
          finish(context, false);
        });
      }

      appStore.setLoading(false);

      return;
    }
    req = {
      "id": "",
      "booking_id": widget.bookingId.validate(),
      "service_id": widget.serviceId.validate(),
      "customer_id": appStore.userId.validate(),
      "rating": selectedRating.validate(),
      "review": reviewCont.text.validate(),
    };
    if (widget.handymanId != null) {
      req.putIfAbsent("handyman_id", () => widget.handymanId);
    }
    appStore.setLoading(true);

    if (widget.handymanId == null) {
      await updateReview(req).then((value) {
        finish(context, true);
        toast(value.message);
      }).catchError((e) {
        toast(e.toString());
        finish(context, false);
      });
    } else {
      await handymanRating(req).then((value) {
        finish(context, true);
        toast(value.message);
      }).catchError((e) {
        toast(e.toString());
        finish(context, false);
      });
    }

    appStore.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.width(),
                  padding: EdgeInsets.only(left: 16, top: 4, bottom: 4),
                  decoration: boxDecorationDefault(
                    color: primaryColor,
                    gradient: primaryGradient,
                    borderRadius: radiusOnly(topRight: 8, topLeft: 8),
                  ),
                  child: Row(
                    children: [
                      Text(language.yourReview,
                              style: boldTextStyle(
                                  size: 16,
                                  weight: FontWeight.w600,
                                  fontFamily: GoogleFonts.mulish().fontFamily,
                                  color: Colors.white))
                          .expand(),
                      IconButton(
                        icon: SvgPicture.asset(
                          ic_clear,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          finish(context);
                        },
                      )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //  Text("*", style: secondaryTextStyle(color: Colors.red)),
                    Text(language.lblYourRating,
                        style: secondaryTextStyle(
                            size: 14,
                            weight: FontWeight.w500,
                            fontFamily: GoogleFonts.mulish().fontFamily)),
                    7.height,
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: boxDecorationDefault(color: geryF6F7F9),
                      child: Row(
                        children: [
                          12.width,
                          RatingBarWidget(
                            onRatingChanged: (rating) {
                              selectedRating = rating;
                              setState(() {});
                            },
                            activeColor:
                                getRatingBarColor(selectedRating.toInt()),
                            inActiveColor: ratingBarColor,
                            rating: selectedRating,
                            size: 18,
                          ).expand(),
                        ],
                      ),
                    ),
                    9.height,
      
                    Text(language.lblEnterReview,
                        style: secondaryTextStyle(
                            size: 14,
                            weight: FontWeight.w500,
                            fontFamily: GoogleFonts.mulish().fontFamily)),
                    9.height,
                    AppTextField(
                      controller: reviewCont,
                      textFieldType: TextFieldType.OTHER,
                      minLines: 5,
                      maxLines: 10,
                      enableChatGPT: /*appConfigurationStore.chatGPTStatus*/false,// this i do purposly because text fiel is not visible as theme disable
                      promptFieldInputDecorationChatGPT:
                          inputDecoration(context, ).copyWith(
                        hintText: language.writeHere,
                        fillColor: /*context.scaffoldBackgroundColor*/greyAEAEB2,
                        filled: true,
      
                      ),
      
                      textStyle: GoogleFonts.mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      testWithoutKeyChatGPT: appConfigurationStore.testWithoutKey,
                      loaderWidgetForChatGPT: const ChatGPTLoadingWidget(),
                      textCapitalization: TextCapitalization.sentences,
                      decoration: inputDecoration(
                        context,
                        //   labelText: language.lblEnterReview,
                      ).copyWith(fillColor: context.cardColor, filled: true),
                    ),
                    32.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        /// canced and delete button
                        CommonButton(
                          width: context.width() * .30,
                          height: 34,
                          text: isHandymanUpdate
                              ? language.lblDelete
                              : language.lblCancel,
                          textStyle: TextStyle(
                              color: isHandymanUpdate ? Colors.red : greyAEAEB2),
                          border: Border.all(color: greyBFBFBF),
                          onTap: () {
                            if (isHandymanUpdate) {
                              CustomDialogUtils.showConfirmDialogCustom(
                                context,
                                primaryColor: primaryColor,
                                title: language.lblDeleteRatingMsg,
                                positiveText: language.lblYes,
                                negativeText: language.lblCancel,
                                onAccept: (c) async {
                                  appStore.setLoading(true);
      
                                  await deleteHandymanReview(
                                          id: widget.customerReview!.id
                                              .validate()
                                              .toInt())
                                      .then((value) {
                                    toast(value.message);
                                    finish(context, true);
                                  }).catchError((e) {
                                    toast(e.toString());
                                  });
      
                                  setState(() {});
      
                                  appStore.setLoading(false);
                                },
                              );
                            } else {
                              finish(context);
                            }
                          },
                        ),
      
                        /// submit button
                        16.width,
                        CommonButton(
                          width: context.width() * .30,
                          height: 34,
                          text: language.btnSubmit,
                          textColor: Colors.white,
                          gradient: primaryGradient,
                          onTap: () {
                            if (selectedRating == 0) {
                              toast(language.lblSelectRating);
                            } else {
                              submit();
                            }
                          },
                        ),
                        // AppButton(
                        //   textColor: Colors.white,
                        //   text: language.btnSubmit,
                        //   color: primaryColor,
                        //   onTap: () {
                        //     if (selectedRating == 0) {
                        //       toast(language.lblSelectRating);
                        //     } else {
                        //       submit();
                        //     }
                        //   },
                        // ).expand(),
                      ],
                    )
                  ],
                ).paddingAll(16)
              ],
            ),
          ),
          Observer(
              builder: (context) => LoaderWidget()
                  .visible(appStore.isLoading)
                  .withSize(height: 80, width: 80))
        ],
      ),
    );
  }
}
