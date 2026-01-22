import 'package:home_service_user/component/common_button.dart';
import 'package:home_service_user/utils/images.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../model/booking_status_model.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';

class BookingStatusFilterBottomSheet extends StatefulWidget {
  const BookingStatusFilterBottomSheet({Key? key}) : super(key: key);

  @override
  State<BookingStatusFilterBottomSheet> createState() => _BookingStatusFilterBottomSheetState();
}

class _BookingStatusFilterBottomSheetState extends State<BookingStatusFilterBottomSheet> {
  Future<List<BookingStatusResponse>>? future;

  List<BookingStatusResponse> list = [];
  BookingStatusResponse? selectedData;

  @override
  void initState() {
    if (cachedBookingStatusDropdown.validate().isEmpty) {
      init();
    }
    super.initState();
  }

  void init() async {
    future = bookingStatus(list: list);
  }

  Widget itemWidget(BookingStatusResponse res) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: boxDecorationDefault(
        color:  res.isSelected
                ? primaryColor
                : white,

        borderRadius: radius(100),
        border: Border.all(color:chipD4D4D4 ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (res.isSelected)
            Container(
              padding: EdgeInsets.all(2),
              margin: EdgeInsets.only(right: 1),
              child: Icon(Icons.done, size: 16, color: Colors.white),
            ),
          Text(
            res.value.validate().toBookingStatus(),
            style: primaryTextStyle(
                color:   res.isSelected
                        ? Colors.white
                        : chipD4D4D4,
                size: 13, fontFamily: GoogleFonts.mulish().fontFamily),
          ),
        ],
      ),
    ).onTap(() {
      res.isSelected = !res.isSelected;

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(

        decoration: boxDecorationWithRoundedCorners(borderRadius: radiusOnly(topLeft: 16, topRight: 16), backgroundColor: Colors.white),
        padding: EdgeInsets.only(left: 25,right: 20,top: 12),
        // decoration: boxDecorationWithRoundedCorners(borderRadius: radiusOnly(topLeft: 16, topRight: 16), backgroundColor: context.cardColor),
        // padding: EdgeInsets.all(25),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(language.lblFilterBy, style: boldTextStyle(fontFamily: GoogleFonts.mulish().fontFamily, size: 20, weight: FontWeight.w700,color: black080A24)),
                  ),
                  IconButton(
                    padding: EdgeInsets.all(0),
                    icon: ic_clear.iconSvgImage(color: grey636D77),  //         Icon(Icons.close, color: appStore.isDarkMode ? lightPrimaryColor : primaryColor, size: 20),
                    color: Colors.red,
                    visualDensity: VisualDensity.standard,
                    onPressed: () async {
                      finish(context);
                    },
                  ),
                ],
              ),
              8.height,
              Container(width: context.width() - 16, height: 1, color: gray.withOpacity(0.3)).center(),
              24.height,
              Text(language.bookingStatus, style: primaryTextStyle(size: 16, fontFamily: GoogleFonts.mulish().fontFamily, weight: FontWeight.w500,color: black080A24)),
              24.height,
              FutureBuilder<List<BookingStatusResponse>>(
                initialData: cachedBookingStatusDropdown,
                future: future,
                builder: (context, snap) {
                  if (snap.hasData) {
                    return Wrap(
                      runSpacing: 16,
                      spacing: 16,
                      children: List.generate(snap.data!.length, (index) => itemWidget(snap.data![index])),
                    );
                  }

                  return snapWidgetHelper(snap, defaultErrorMessage: "", loadingWidget: Offstage());
                },
              ),
              24.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonButton(
                    height: 48,
                    text: language.clearFilter,
                    color: greyAEAEB2,
                    border: Border.all(color: greyAEAEB2),
                    textColor:  black1A1C1E,
                    textStyle:  boldTextAutoStyle(context: context,commonColor: black1A1C1E),
                    width: context.width() - context.navigationBarHeight,
                    onTap: () {
                      finish(context);
                      init();
                      LiveStream().emit(LIVESTREAM_UPDATE_BOOKING_LIST);
                    },
                  ).expand(),
                  16.width,
                  CommonButton(
                    height: 48,
                    text: language.lblApply,
                    color: primaryColor,
                    gradient: primaryGradient,
                    textColor: white,
                    width: context.width() - context.navigationBarHeight,
                    onTap: () {
                      int selectedCount = cachedBookingStatusDropdown.validate().where((element) => element.isSelected).length;
                      if (selectedCount >= 1) {
                        finish(context, cachedBookingStatusDropdown!.where((element) => element.isSelected).map((e) => e.value).join(','));
                      } else {
                        toast(language.serviceStatusPicMessage);
                      }
                    },
                  ).expand(),
                ],
              ).paddingOnly(left: 16, right: 16, bottom: 16),
            ],
          ),
        ),
      ),
    );
  }
}
