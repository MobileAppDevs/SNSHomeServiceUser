import 'package:home_service_user/model/booking_detail_model.dart';
import 'package:home_service_user/utils/common.dart';
import 'package:home_service_user/utils/dashed_rect.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/colors.dart';

class BookingHistoryListWidget extends StatelessWidget {
  const BookingHistoryListWidget({Key? key, required this.data, required this.index, required this.length}) : super(key: key);

  final BookingActivity data;
  final int index;
  final int length;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              data.datetime.validate().toString().isNotEmpty
                  ? Text(
                      formatDate(data.datetime..validate().toString()),
                      style: secondaryTextStyle(color: grey757575),
                    )
                  : SizedBox(),
              8.height,
              data.datetime.validate().toString().isNotEmpty
                  ? Text(
                      formatDate(data.datetime..validate().toString(), isTime: true),
                      style: primaryTextStyle(size: 12,color: grey757575),
                    )
                  : SizedBox(),
            ],
          ).withWidth(55),
          16.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(
                  color: data.activityType.validate().getBookingActivityStatusColor,
                  borderRadius: radius(16),
                ),
              ),
              SizedBox(
                height: 65,
                child: DashedRect(
                  gap: 3,
                  color: data.activityType.validate().getBookingActivityStatusColor,
                  strokeWidth: 1.5,
                ),
              ).visible(index != length - 1),
            ],
          ),
          16.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextIcon(
                expandedText: true,
                edgeInsets: EdgeInsets.only(right: 4, left: 4, bottom: 4),
                textStyle:secondaryTextStyle(size: 12,color: black1A1C1E) ,
                text: data.activityType.validate().replaceAll('_', ' ').capitalizeFirstLetter(),
              ),
              Text(
                data.activityMessage.validate().replaceAll('_', ' ').capitalizeFirstLetter(),
                style: secondaryTextStyle(size: 12,color: grey757575),
              ).paddingOnly(left: 4),
            ],
          ).paddingOnly(bottom: 18).expand()
        ],
      ),
    );
  }
}
