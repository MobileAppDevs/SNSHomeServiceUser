
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/cached_image_widget.dart';
import '../../../component/disabled_rating_bar_widget.dart';
import '../../../component/price_widget.dart';
import '../../../main.dart';
import '../../../model/get_my_post_job_list_response.dart';
import '../../../model/post_job_detail_response.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/colors.dart';
import '../../../utils/constant.dart';
import '../../../utils/custom_dialog_utils.dart';
import '../../../utils/model_keys.dart';
import '../book_post_job_request_screen.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';

class BidderItemComponent extends StatefulWidget {
  final BidderData data;
  final int? postRequestId;
  final PostJobData postJobData;
  final PostJobDetailResponse? postJobDetailResponse;

  BidderItemComponent({required this.data, required this.postRequestId, required this.postJobData, this.postJobDetailResponse});

  @override
  _BidderItemComponentState createState() => _BidderItemComponentState();
}

class _BidderItemComponentState extends State<BidderItemComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  Future<void> savePostJobReq() async {
    CustomDialogUtils.showConfirmDialogCustom(
      context,
      negativeText: language.lblNo,
      dialogType: DialogType.CONFIRMATION,
      primaryColor: primaryColor,
      title: '${language.doYouWantToAssign} ${widget.data.provider!.displayName.validate()}?',
      positiveText: language.lblYes,
      onAccept: (c) async {
        List<int> serviceList = [];

        if (widget.postJobData.service.validate().isNotEmpty) {
          widget.postJobData.service.validate().forEach((element) {
            serviceList.add(element.id.validate());
          });
        }

        Map request = {
          CommonKeys.id: widget.postRequestId.validate(),
          PostJob.providerId: widget.data.providerId.validate(),
          PostJob.jobPrice: widget.data.price.validate(),
          PostJob.status: JOB_REQUEST_STATUS_ASSIGNED,
          PostJob.serviceId: serviceList,
        };

        appStore.setLoading(true);

        await savePostJob(request).then((value) {
          appStore.setLoading(false);
          toast(value.message.validate());

          finish(context);
          LiveStream().emit(LIVESTREAM_UPDATE_BIDER);

          widget.postJobDetailResponse!.postRequestDetail!.jobPrice = widget.data.price.validate();

          BookPostJobRequestScreen(
            postJobDetailResponse: widget.postJobDetailResponse!,
            providerId: widget.data.providerId.validate(),
            jobPrice: widget.data.price.validate(),
          ).launch(context);
        }).catchError((e) {
          appStore.setLoading(false);
          log(e.toString());
        });
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor, borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Row(
        children: [
          CachedImageWidget(
            url: widget.data.provider!.profileImage.validate(),
            fit: BoxFit.cover,
            height: 60,
            width: 60,
            circle: true,
          ),
          8.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Marquee(
                directionMarguee: DirectionMarguee.oneDirection,
                child: Text(widget.data.provider!.displayName.validate(), style: boldTextAutoStyle(context: context,commonColor: black1A1C1E)),
              ),
              4.height,
              if (widget.data.provider!.designation.validate().isNotEmpty)
                Marquee(
                  directionMarguee: DirectionMarguee.oneDirection,
                  child: Text(widget.data.provider!.designation.validate(), style: primaryTextStyle(size: 12,color: black1A1C1E)),
                ),
              4.height,
              DisabledRatingBarWidget(
                rating: widget.data.provider!.providersServiceRating.validate(),
                size: 14,
              ),
              4.height,
              Marquee(
                directionMarguee: DirectionMarguee.oneDirection,
                child: Row(
                  children: [
                    Text('${language.bidPrice}: ', style: secondaryTextStyle(color: primaryColor)),
                    PriceWidget(
                      price: widget.data.price.validate(),
                      isHourlyService: false,
                      color: primaryColor,
                      isFreeService: false,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ).expand(),
          8.width,
          if (widget.postJobData.providerId == null)
            AppButton(
              padding: EdgeInsets.zero,

              child: Row(
                children: [
                  Icon(Icons.check, color: Colors.white, size: 16),
                  4.width,
                  Text(language.accept, style: boldTextStyle(color: Colors.white, size: 12)),
                ],
              ),
              color: primaryColor,
              onTap: () {
                savePostJobReq();
              },
            ),
        ],
      ),
    );
  }
}
