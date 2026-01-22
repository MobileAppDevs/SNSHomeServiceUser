import 'dart:convert';

import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/component/loader_widget.dart';
import 'package:home_service_user/main.dart';
import 'package:home_service_user/model/package_data_model.dart';
import 'package:home_service_user/model/service_detail_response.dart';
import 'package:home_service_user/network/rest_apis.dart';
import 'package:home_service_user/screens/service/service_detail_screen.dart';
import 'package:home_service_user/utils/colors.dart';
import 'package:home_service_user/utils/images.dart';
import 'package:home_service_user/utils/model_keys.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../model/booking_amount_model.dart';
import '../../../utils/app_configuration.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';
import '../../payment/payment_screen.dart';
import 'booking_confirmation_dialog.dart';

class ConfirmBookingDialog extends StatefulWidget {
  final ServiceDetailResponse data;
  final num? bookingPrice;
  final int qty;
  final String? couponCode;
  final BookingPackage? selectedPackage;
  final BookingAmountModel? bookingAmountModel;

  ConfirmBookingDialog({required this.data, required this.bookingPrice, this.qty = 1, this.couponCode, this.selectedPackage, this.bookingAmountModel});

  @override
  State<ConfirmBookingDialog> createState() => _ConfirmBookingDialogState();
}

class _ConfirmBookingDialogState extends State<ConfirmBookingDialog> {
  Map? selectedPackage;
  List<int> selectedService = [];

  bool isSelected = false;
  String serviceId = "";

  Future<void> bookServices() async {
    if (widget.selectedPackage != null) {
      if (widget.selectedPackage!.serviceList != null) {
        widget.selectedPackage!.serviceList!.forEach((element) {
          selectedService.add(element.id.validate());
        });

        for (var i in selectedService) {
          if (i == selectedService.last) {
            serviceId = serviceId + i.toString();
          } else {
            serviceId = serviceId + i.toString() + ",";
          }
        }
      }

      selectedPackage = {
        PackageKey.packageId: widget.selectedPackage!.id.validate(),
        PackageKey.categoryId: widget.selectedPackage!.categoryId != -1 ? widget.selectedPackage!.categoryId.validate() : null,
        PackageKey.name: widget.selectedPackage!.name.validate(),
        PackageKey.price: widget.selectedPackage!.price.validate(),
        PackageKey.serviceId: serviceId,
        PackageKey.startDate: widget.selectedPackage!.startDate.validate(),
        PackageKey.endDate: widget.selectedPackage!.endDate.validate(),
        PackageKey.isFeatured: widget.selectedPackage!.isFeatured == 1 ? '1' : '0',
        PackageKey.packageType: widget.selectedPackage!.packageType.validate(),
      };
    }

    log("selectedPackage: ${[selectedPackage]}");

    Map request = {
      CommonKeys.id: "",
      CommonKeys.serviceId: widget.data.serviceDetail!.id.toString(),
      CommonKeys.providerId: widget.data.provider!.id.validate().toString(),
      CommonKeys.customerId: appStore.userId.toString().toString(),
      BookingServiceKeys.description: widget.data.serviceDetail!.bookingDescription.validate().toString(),
      CommonKeys.address: widget.data.serviceDetail!.address.validate().toString(),
      CommonKeys.date: widget.data.serviceDetail!.dateTimeVal.validate().toString(),
      BookingServiceKeys.couponId: widget.couponCode.validate(),
      BookService.amount: widget.data.serviceDetail!.price,
      BookService.quantity: '${widget.qty}',
      BookingServiceKeys.totalAmount: widget.bookingPrice.validate().toStringAsFixed(getIntAsync(PRICE_DECIMAL_POINTS)),
      CouponKeys.discount: widget.data.serviceDetail!.discount != null ? widget.data.serviceDetail!.discount.toString() : "",
      BookService.bookingAddressId: widget.data.serviceDetail!.bookingAddressId != -1 ? widget.data.serviceDetail!.bookingAddressId : null,
      BookingServiceKeys.type: BOOKING_TYPE_SERVICE,
      BookingServiceKeys.bookingPackage: widget.selectedPackage != null ? selectedPackage : null,
      BookingServiceKeys.serviceAddonId: serviceAddonStore.selectedServiceAddon.map((e) => e.id).toList(),
    };
    if (widget.bookingAmountModel != null) {
     // request.addAll(widget.bookingAmountModel!.toJson());

      request['final_total_service_price'] = widget.bookingAmountModel?.finalTotalServicePrice ?? 0;
      request['final_total_tax'] = widget.bookingAmountModel?.taxFeeAmount ?? 0;
      request['final_sub_total'] = widget.bookingAmountModel?.finalSubTotal ?? 0;
      request['final_discount_amount'] = widget.bookingAmountModel?.finalDiscountAmount ?? 0;
      request['final_coupon_discount_amount'] = widget.bookingAmountModel?.finalCouponDiscountAmount ?? 0;
      request['total_admin_fee'] =widget.bookingAmountModel?.serviceFee??0;

    }

    if (widget.data.serviceDetail!.isSlotAvailable) {
      request.putIfAbsent('booking_date', () => widget.data.serviceDetail!.bookingDate.validate().toString());
      request.putIfAbsent('booking_slot', () => widget.data.serviceDetail!.bookingSlot.validate().toString());
      request.putIfAbsent('booking_day', () => widget.data.serviceDetail!.bookingDay.validate().toString());
    }

    if (widget.data.taxes.validate().isNotEmpty) {
      request.putIfAbsent('tax', () => widget.data.taxes);
    }
    if (widget.data.serviceDetail != null && widget.data.serviceDetail!.isAdvancePayment) {
      request.putIfAbsent(CommonKeys.status, () => BookingStatusKeys.waitingAdvancedPayment);
    }

    appStore.setLoading(true);

    saveBooking(request).then((bookingDetailResponse) async {
      appStore.setLoading(false);
      finish(context);
      PaymentScreen(bookings: bookingDetailResponse, isForAdvancePayment: true,
          bookingAmountModel:widget.bookingAmountModel).launch(context);
     /* if (widget.data.serviceDetail != null && widget.data.serviceDetail!.isAdvancePayment) {
        finish(context);
        PaymentScreen(bookings: bookingDetailResponse, isForAdvancePayment: true).launch(context);
      }
      else{
        finish(context);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: BookingConfirmationDialog(
                data: widget.data,
                bookingId: bookingDetailResponse.bookingDetail!.id,
                bookingPrice: widget.bookingPrice,
                selectedPackage: widget.selectedPackage,
                bookingDetailResponse: bookingDetailResponse,
              ),
            );
          },
        );
        *//* showInDialog(
          context,
          builder: (BuildContext context) => BookingConfirmationDialog(
            data: widget.data,
            bookingId: bookingDetailResponse.bookingDetail!.id,
            bookingPrice: widget.bookingPrice,
            selectedPackage: widget.selectedPackage,
            bookingDetailResponse: bookingDetailResponse,
          ),
          backgroundColor: transparentColor,
          contentPadding: EdgeInsets.zero,
        );*//*
      }*/
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return SingleChildScrollView(
          child: SafeArea(
            top: false,
            child: Container(
              width: context.width(),
              padding: EdgeInsets.fromLTRB(16, 24, 16, 32),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 30),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.green.shade100,
                    child: confirmTick.iconImageSimple(size: 115).paddingAll(0),//Icon(Icons.check, color: Colors.green, size: 50),
                  ),
                  SizedBox(height: 25),

                 // Image.asset(ic_confirm_check, height: 100, width: 100, color: primaryColor),
                  /*14.height,*/
                  Text(language.lblConfirmBooking, style: boldTextStyle(size: 20,color: pureBlack,weight: FontWeight.w700, fontFamily: GoogleFonts.mulish().fontFamily)),
                  16.height,
                  Text(language.lblConfirmMsg, style: primaryTextStyle(color: pureBlack,weight: FontWeight.w700, fontFamily: GoogleFonts.mulish().fontFamily), textAlign: TextAlign.center),
                  16.height,
                  // terms and checkbox
                  ExcludeSemantics(
                    child: CheckboxListTile(
                      checkboxShape: RoundedRectangleBorder(borderRadius: radius(4)),
                      activeColor: primaryColor,
                      checkColor: context.cardColor,
                      value: isSelected,
                      onChanged: (val) {
                        isSelected = val!;
                        setState(() {});
                      },
                      title: RichTextWidget(
                        list: [
                          TextSpan(text: '${language.lblAgree} ', style: secondaryTextStyle(size: 14)),
                          TextSpan(
                            text: language.lblTermsOfService,
                            style: boldTextStyle(color: primaryColor, size: 14),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                commonLaunchUrl(appConfigurationStore.termConditions);
                              },
                          ),
                          TextSpan(text: ' & ', style: secondaryTextStyle()),
                          TextSpan(
                            text: language.privacyPolicy,
                            style: boldTextStyle(color: primaryColor, size: 14),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                commonLaunchUrl(appConfigurationStore.privacyPolicy);
                              },
                          ),
                        ],
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  32.height,
                  Row(
                    children: [
                      AppButton(
                        onTap: () => Navigator.pop(context),
                        text: language.lblCancel,
                        textColor: black1A1C1E,
                        color: greyAEAEB2,
                      ).expand(),
                      16.width,
                      AppButton(
                        text: language.confirm,
                        textColor: Colors.white,
                        color: primaryColor,
                        onTap: () {
                          if (isSelected) {
                            bookServices();
                          } else {
                            toast(language.termsConditionsAccept);
                          }
                        },
                      ).expand(),
                    ],
                  ),
                ],
              ).visible(
                !appStore.isLoading,
                defaultWidget: LoaderWidget().withSize(width: 250, height: 280),
              ),
            ),
          ),
        );
      },
    );
  }



/*@override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Container(
          width: context.width(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(ic_confirm_check, height: 100, width: 100, color: primaryColor),
              24.height,
              Text(language.lblConfirmBooking, style: boldTextStyle(size: 20)),
              16.height,
              Text(language.lblConfirmMsg, style: primaryTextStyle(), textAlign: TextAlign.center),
              16.height,
              ExcludeSemantics(
                child: CheckboxListTile(
                  checkboxShape: RoundedRectangleBorder(borderRadius: radius(4)),
                  autofocus: false,
                  activeColor: primaryColor,
                  checkColor: appStore.isDarkMode ? context.cardColor*//*context.iconColor*//* : context.cardColor,
                  value: isSelected,
                  onChanged: (val) async {
                    isSelected = !isSelected;
                    setState(() {});
                  },
                  title: RichTextWidget(
                    list: [
                      TextSpan(text: '${language.lblAgree} ', style: secondaryTextStyle(size: 14)),
                      TextSpan(
                        text: language.lblTermsOfService,
                        style: boldTextStyle(color: primaryColor, size: 14),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            commonLaunchUrl(appConfigurationStore.termConditions, launchMode: LaunchMode.externalApplication);
                          },
                      ),
                      TextSpan(text: ' & ', style: secondaryTextStyle()),
                      TextSpan(
                        text: language.privacyPolicy,
                        style: boldTextStyle(color: primaryColor, size: 14),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            commonLaunchUrl(appConfigurationStore.privacyPolicy, launchMode: LaunchMode.externalApplication);
                          },
                      ),
                    ],
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              32.height,
              Row(
                children: [
                  AppButton(
                    onTap: () {
                      finish(context);
                    },
                    text: language.lblCancel,
                    textColor: textPrimaryColorGlobal,
                  ).expand(),
                  16.width,
                  AppButton(
                    text: language.confirm,
                    textColor: Colors.white,
                    color: primaryColor,
                    onTap: () {
                      if (isSelected) {
                        bookServices();
                      } else {
                        toast(language.termsConditionsAccept);
                      }
                    },
                  ).expand(),
                ],
              )
            ],
          ).visible(
            !appStore.isLoading,
            defaultWidget: LoaderWidget().withSize(width: 250, height: 280),
          ),
        );
      },
    );
  }*/

}
