import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/component/app_common_dialog.dart';
import 'package:home_service_user/component/cached_image_widget.dart';
import 'package:home_service_user/component/dotted_line.dart';
import 'package:home_service_user/component/price_widget.dart';
import 'package:home_service_user/main.dart';
import 'package:home_service_user/model/booking_data_model.dart';
import 'package:home_service_user/screens/booking/component/edit_booking_service_dialog.dart';
import 'package:home_service_user/utils/colors.dart';
import 'package:home_service_user/utils/common.dart';
import 'package:home_service_user/utils/constant.dart';
import 'package:home_service_user/utils/extensions/num_extenstions.dart';
import 'package:home_service_user/utils/images.dart';
import 'package:home_service_user/utils/model_keys.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/service_detail_response.dart';
import '../../../network/rest_apis.dart';
import 'booking_slots.dart';

class BookingItemComponent extends StatefulWidget {
  final BookingData bookingData;

  BookingItemComponent({required this.bookingData});

  @override
  State<BookingItemComponent> createState() => _BookingItemComponentState();
}

class _BookingItemComponentState extends State<BookingItemComponent> {
  @override
  Widget build(BuildContext context) {
    Widget _buildEditBookingWidget() {
      // if (bookingData.isSlotBooking) return Offstage();
      if (widget.bookingData.status == BookingStatusKeys.pending &&
          isDateTimeAfterNow) {
        return IconButton(
          icon: ic_edit_square_png.iconImage(size: 18),
          visualDensity: VisualDensity.compact,
          onPressed: () async {
            ServiceDetailResponse res = await getServiceDetails(
                serviceId: widget.bookingData.serviceId.validate(),
                customerId: appStore.userId,
                fromBooking: true);
            if (widget.bookingData.isSlotBooking) {
              showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                isScrollControlled: true,
                isDismissible: true,
                shape: RoundedRectangleBorder(
                    borderRadius: radiusOnly(
                        topLeft: defaultRadius, topRight: defaultRadius)),
                builder: (_) {
                  return DraggableScrollableSheet(
                    initialChildSize: 0.65,
                    minChildSize: 0.65,
                    maxChildSize: 1,
                    builder: (context, scrollController) =>
                        BookingSlotsComponent(
                      data: res,
                      bookingData: widget.bookingData,
                      showAppbar: true,
                      scrollController: scrollController,
                      onApplyClick: () {
                        setState(() {});
                      },
                    ),
                  );
                },
              );
            } else {
              showInDialog(
                context,
                contentPadding: EdgeInsets.zero,
                hideSoftKeyboard: true,
                backgroundColor: context.cardColor,
                builder: (p0) {
                  return AppCommonDialog(
                    title: language.lblUpdateDateAndTime,
                    child: EditBookingServiceDialog(data: widget.bookingData),
                  );
                },
              );
            }
          },
        );
      }
      return Offstage();
    }

    String buildTimeWidget({required BookingData bookingDetail}) {
      if (bookingDetail.bookingSlot == null) {
        return formatDate(bookingDetail.date.validate(), isTime: true);
      }
      return formatDate(
          getSlotWithDate(
              date: bookingDetail.date.validate(),
              slotTime: bookingDetail.bookingSlot.validate()),
          isTime: true);
    }

    return SafeArea(
      top:false,
      child: Container(
        // padding: EdgeInsets.all(8),
        margin: EdgeInsets.only(bottom: 16),
        width: context.width(),
        decoration: BoxDecoration(
            border: Border.all(color: greyF1F1F1), borderRadius: radius(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.bookingData.isPackageBooking)
                  CachedImageWidget(
                    url: widget.bookingData.bookingPackage!.imageAttachments
                            .validate()
                            .isNotEmpty
                        ? widget.bookingData.bookingPackage!.imageAttachments
                            .validate()
                            .first
                            .validate()
                        : "",
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    radius: defaultRadius,
                  )
                else
                  CachedImageWidget(
                    url: widget.bookingData.serviceAttachments
                            .validate()
                            .isNotEmpty
                        ? widget.bookingData.serviceAttachments!.first.validate()
                        : '',
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                    radius: defaultRadius,
                  ),
                16.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: Wrap(
                            runAlignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: widget.bookingData.status
                                      .validate()
                                      .getPaymentStatusBackgroundColor
                                      .withOpacity(0.1),
                                  borderRadius: radius(8),
                                ),
                                child: Marquee(
                                  child: Text(
                                    widget.bookingData.status
                                        .validate()
                                        .toBookingStatus(),
                                    style: boldTextStyle(
                                        color: widget.bookingData.status
                                            .validate()
                                            .getPaymentStatusBackgroundColor,
                                        size: 14,
                                        fontFamily:
                                        GoogleFonts.mulish().fontFamily),
                                  ),
                                ),
                              ) /*.flexible()*/,
                              if (widget.bookingData.isPostJob)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  margin: EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: radius(8),
                                  ),
                                  child: Text(
                                    language.postJob,
                                    style: boldTextStyle(
                                        color: primaryColor,
                                        size: 12,
                                        fontFamily:
                                        GoogleFonts.mulish().fontFamily),
                                  ),
                                ),
                              if (widget.bookingData.isPackageBooking)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  margin: EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: radius(8),
                                  ),
                                  child: Text(
                                    language.package,
                                    style: boldTextStyle(
                                        color: primaryColor,
                                        size: 12,
                                        fontFamily:
                                        GoogleFonts.mulish().fontFamily),
                                  ),
                                ),

                              /// booking no show
                            ],
                          ),
                        ).expand(),
                        Container(
                          alignment: Alignment.topRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildEditBookingWidget(),
                              Text('#${widget.bookingData.id.validate()}',
                                  style: boldTextStyle(
                                      color: primaryColor,
                                      fontFamily: GoogleFonts.mulish().fontFamily)),
                            ],
                          ),
                        ).expand(),
                      ],
                    ),
                    8.height,
                    Marquee(
                      child: Text(
                        widget.bookingData.isPackageBooking
                            ? '${widget.bookingData.bookingPackage!.name.validate()}'
                            : '${widget.bookingData.serviceName.validate()}',
                        style: boldTextStyle(
                            size: 17,
                            fontFamily: GoogleFonts.mulish().fontFamily,
                            color: black,
                            weight: FontWeight.w800),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    8.height,
                    if (widget.bookingData.bookingPackage != null)
                      PriceWidget(
                        price: widget.bookingData.totalAmount.validate(),
                        color: primaryColor,
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PriceWidget(
                            isFreeService:
                                widget.bookingData.type == SERVICE_TYPE_FREE,
                            price: widget.bookingData.totalAmount.validate(),
                            color: primaryColor,
                          ),
                          if (widget.bookingData.isHourlyService)
                            Row(
                              children: [
                                4.width,
                                Text(
                                    '${widget.bookingData.amount.validate().toPriceFormat()}/${language.lblHr}',
                                    style: secondaryTextStyle(
                                        fontFamily:
                                            GoogleFonts.mulish().fontFamily)),
                              ],
                            ),
                          if (widget.bookingData.discount.validate() != 0)
                            Row(
                              children: [
                                4.width,
                                Text('(${widget.bookingData.discount!}%',
                                    style: boldTextStyle(
                                        size: 12,
                                        color: Colors.green,
                                        fontFamily:
                                            GoogleFonts.mulish().fontFamily)),
                                Text(' ${language.lblOff})',
                                    style: boldTextStyle(
                                        size: 12,
                                        color: Colors.green,
                                        fontFamily:
                                            GoogleFonts.mulish().fontFamily)),
                              ],
                            ),
                        ],
                      ),
                  ],
                ).expand(),
              ],
            ).paddingAll(16),
            Container(
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// dotted line
                  DottedLine(
                    direction: Axis.horizontal,
                    lineLength: double.infinity,
                    lineThickness: 2,
                    dashLength: 6,
                    dashColor: cardLightColor,
                    dashGapLength: 4,
                  ),

                  /// time
                  11.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text('${language.lblDate} & ${language.lblTime}',
                      //     style: secondaryTextStyle()),

                      Text(
                        "${formatDate(widget.bookingData.date.validate())} ${language.at} " +
                            buildTimeWidget(bookingDetail: widget.bookingData),
                        style: boldTextStyle(
                            size: 13,
                            fontFamily: GoogleFonts.mulish().fontFamily,
                            weight: FontWeight.w500,
                            color: black212121),
                        maxLines: 2,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ).paddingOnly(left: 8),
                  // address
                  9.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Text(language.lblYourAddress, style: secondaryTextStyle()),
                      // 8.width,
                      Marquee(
                        child: Text(
                          widget.bookingData.address != null
                              ? widget.bookingData.address.validate()
                              : language.notAvailable,
                          style: boldTextStyle(
                              size: 15,
                              fontFamily: GoogleFonts.mulish().fontFamily,
                              weight: FontWeight.w600,
                              color: pureBlack),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ).flexible(),
                    ],
                  ).paddingOnly(left: 8),
                  //   Divider(height: 0, color: context.dividerColor),
                  10.height,
                  if (widget.bookingData.providerName.validate().isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("${language.textProvider}:",
                            style: secondaryTextStyle(
                                fontFamily: GoogleFonts.mulish().fontFamily,
                                size: 14,
                                weight: FontWeight.w400)),
                        8.width,
                        Text(widget.bookingData.providerName.validate(),
                                style: boldTextStyle(
                                    fontFamily: GoogleFonts.mulish().fontFamily,
                                    size: 15,
                                    weight: FontWeight.w500,
                                    color: pureBlack),
                                textAlign: TextAlign.right)
                            .flexible(),
                      ],
                    ).paddingOnly(left: 8),
                  if (widget.bookingData.handyman.validate().isNotEmpty &&
                      widget.bookingData.providerId !=
                          widget.bookingData.handyman!.first.handymanId! &&
                      widget.bookingData.handyman!.first.handyman != null)
                    Column(
                      children: [
                        Divider(height: 0, color: cardColor),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.textHandyman,
                                style: secondaryTextStyle()),
                            Text(
                                    widget.bookingData.handyman!
                                        .validate()
                                        .first
                                        .handyman!
                                        .displayName
                                        .validate(),
                                    style: boldTextStyle(size: 12))
                                .flexible(),
                          ],
                        ).paddingAll(8),
                      ],
                    ),
                  if (widget.bookingData.paymentStatus != null &&
                      (widget.bookingData.status == BookingStatusKeys.complete ||
                          widget.bookingData.paymentStatus ==
                              SERVICE_PAYMENT_STATUS_ADVANCE_PAID ||
                          widget.bookingData.paymentStatus ==
                              SERVICE_PAYMENT_STATUS_PAID))
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(height: 0, color: cardColor).paddingOnly(top: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(language.paymentStatus,
                                style: secondaryTextStyle()),
                          ).expand(),
                          Text(
                            buildPaymentStatusWithMethod(
                                widget.bookingData.paymentStatus.validate(),
                                widget.bookingData.paymentMethod.validate()),
                            style: boldTextStyle(
                                size: 12,
                                color: widget.bookingData.paymentStatus ==
                                            SERVICE_PAYMENT_STATUS_ADVANCE_PAID ||
                                        (widget.bookingData.paymentStatus ==
                                                SERVICE_PAYMENT_STATUS_PAID ||
                                            widget.bookingData.paymentStatus ==
                                                PENDING_BY_ADMIN)
                                    ? Colors.green
                                    : Colors.red),
                          ),
                        ],
                      ).paddingOnly(right: 14, top: 4),
                    ],
                  ),
                ],
              ).paddingOnly(bottom: 8),
            ).flexible(),
          ],
        ),
      ),
    );
  }

  bool get isDateTimeAfterNow {
    try {
      if (widget.bookingData.bookingSlot != null) {
        final bookingDateTimeForTimeSlots =
            widget.bookingData.date.validate().split(" ").isNotEmpty
                ? widget.bookingData.date.validate().split(" ").first
                : "";
        final bookingTimeForTimeSlots =
            widget.bookingData.bookingSlot.validate();
        return DateTime.parse(
                bookingDateTimeForTimeSlots + " " + bookingTimeForTimeSlots)
            .isAfter(DateTime.now());
      } else {
        return DateTime.parse(widget.bookingData.date.validate())
            .isAfter(DateTime.now());
      }
    } catch (e) {
      log('E: $e');
    }
    return false;
  }
}
