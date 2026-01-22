import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/model/package_data_model.dart';
import 'package:home_service_user/screens/booking/booking_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/price_widget.dart';
import '../../../main.dart';
import '../../../model/booking_detail_model.dart';
import '../../../model/service_detail_response.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';
import '../../../utils/images.dart';
import '../../dashboard/dashboard_screen.dart';

class BookingConfirmationDialog extends StatefulWidget {
  final ServiceDetailResponse data;
  final int? bookingId;
  final num? bookingPrice;
  final BookingPackage? selectedPackage;
  final BookingDetailResponse? bookingDetailResponse;

  BookingConfirmationDialog({
    required this.data,
    required this.bookingId,
    this.bookingPrice,
    this.selectedPackage,
    this.bookingDetailResponse,
  });

  @override
  State<BookingConfirmationDialog> createState() => _BookingConfirmationDialogState();
}

class _BookingConfirmationDialogState extends State<BookingConfirmationDialog> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  Widget buildDateWidget() {
    if (widget.data.serviceDetail!.isSlotAvailable) {
      return Text(formatBookingDate(widget.data.serviceDetail!.bookingDate.validate(), format: DATE_FORMAT_2), style: boldTextAutoStyle(context: context,commonColor: black1A1C1E));
    }
    return Text(formatBookingDate(widget.data.serviceDetail!.dateTimeVal.validate(), format: DATE_FORMAT_2), style: boldTextAutoStyle(context: context,commonColor: black1A1C1E));
  }

  Widget buildTimeWidget() {
    if (widget.data.serviceDetail!.bookingSlot == null) {
      return Text(formatBookingDate(widget.data.serviceDetail!.dateTimeVal.validate(), format: HOUR_12_FORMAT), style: boldTextAutoStyle(size: 14,context: context,commonColor: black1A1C1E), textAlign: TextAlign.end);
    }
    return Text(
      TimeOfDay(
        hour: widget.data.serviceDetail!.bookingSlot.validate().splitBefore(':').split(":").first.toInt(),
        minute: widget.data.serviceDetail!.bookingSlot.validate().splitBefore(':').split(":").last.toInt(),
      ).format(context),
      style: boldTextAutoStyle(context: context,commonColor: black1A1C1E),
      textAlign: TextAlign.end,
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        width: context.width(),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: radius(),
              ),
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(top: 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  50.height,
                  Text(language.thankYou, style: boldTextStyle(size: 20,color: pureBlack,weight: FontWeight.w700, fontFamily: GoogleFonts.mulish().fontFamily)),
                  8.height,
                  Text(language.bookingConfirmedMsg, style: secondaryTextStyle()),
                  24.height,
                  DottedBorderWidget(
                    color: primaryColor.withOpacity(0.6),
                    strokeWidth: 1,
                    gap: 6,
                    padding: EdgeInsets.all(16),
                    radius: 12,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(language.lblDate, style: secondaryTextStyle()),
                            Text(language.lblTime, style: secondaryTextStyle()),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildDateWidget().expand(flex: 2),
                            buildTimeWidget().expand(flex: 1),
                          ],
                        ),
                      ],
                    ).center(),
                  ),
                  16.height,
                  if (!widget.data.serviceDetail!.isFreeService)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language.totalAmount, style: secondaryTextStyle(size: 14,color: pureBlack,weight: FontWeight.w700, fontFamily: GoogleFonts.mulish().fontFamily)),
                            8.height,
                            PriceWidget(
                              price: widget.bookingPrice.validate(),
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  16.height,
                  Row(
                    children: [
                      AppButton(
                        padding: EdgeInsets.zero,
                        text: language.goToHome,
                        textStyle: boldTextStyle(size: 14, color: Colors.white),
                        color: primaryColor,
                        onTap: () {
                          DashboardScreen().launch(context, isNewTask: true);
                        },
                      ).expand(),
                      16.width,
                      AppButton(
                        padding: EdgeInsets.zero,
                        text: language.goToReview,
                        textStyle: boldTextStyle(size: 12),
                        shapeBorder: RoundedRectangleBorder(borderRadius: radius(), side: BorderSide(color: greyAEAEB2)),
                        color: greyAEAEB2,
                        onTap: () {
                          DashboardScreen(redirectToBooking: true).launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                          BookingDetailScreen(bookingId: widget.bookingId.validate()).launch(context);
                        },
                      ).expand(),
                    ],
                  ),
                  16.height,
                ],
              ),
            ),
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
                border: Border.all(width: 5, color: context.cardColor, style: BorderStyle.solid, strokeAlign: BorderSide.strokeAlignOutside),
              ),
              child:CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green.shade100,
                child: confirmTick.iconImageSimple(size: 115).paddingAll(0),
              ),// Icon(Icons.check, color: context.cardColor, size: 40),
            ),
          ],
        ),
      ),
    );
  }
}
