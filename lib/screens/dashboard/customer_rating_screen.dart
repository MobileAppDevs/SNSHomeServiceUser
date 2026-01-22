
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/add_review_dialog.dart';
import '../../component/base_scaffold_widget.dart';
import '../../component/cached_image_widget.dart';
import '../../component/disabled_rating_bar_widget.dart';
import '../../component/dotted_line.dart';
import '../../component/empty_error_state_widget.dart';
import '../../component/loader_widget.dart';
import '../../main.dart';
import '../../model/service_detail_response.dart';
import '../../network/rest_apis.dart';
import '../../utils/colors.dart';
import '../../utils/constant.dart';
import '../../utils/custom_dialog_utils.dart';
import '../../utils/images.dart';
import '../review/shimmer/ratting_shimmer.dart';
import '../service/service_detail_screen.dart';

class CustomerRatingScreen extends StatefulWidget {
  @override
  State<CustomerRatingScreen> createState() => _CustomerRatingScreenState();
}

class _CustomerRatingScreenState extends State<CustomerRatingScreen> {
  ScrollController scrollController = ScrollController();

  Future<List<RatingData>>? future;

  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    future = customerReviews();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.myReviews,
      child: Stack(
        children: [
          SnapHelperWidget<List<RatingData>>(
            future: future,
            initialData: cachedRatingList,
            loadingWidget: RattingShimmer(),
            onSuccess: (snap) {
              return AnimatedListView(
                padding: EdgeInsets.fromLTRB(8, 16, 8, 50),
                slideConfiguration: sliderConfigurationGlobal,
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                itemCount: snap.length,
                onSwipeRefresh: () async {
                  init();
                  setState(() {});

                  return await 2.seconds.delay;
                },
                itemBuilder: (context, index) {
                  RatingData data = snap[index];

                  return Container(
                  //  padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(8),
                    decoration: boxDecorationDefault(
                      color: greyF1F1F1,
                     
                      borderRadius: radius(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 22.0, left: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CachedImageWidget(
                                      url: data.attachments.validate().isNotEmpty ? data.attachments!.first : '',
                                      height: 84,
                                      width: 84,
                                      fit: BoxFit.cover,
                                      radius: defaultRadius,
                                    ),
                                    16.width,
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${data.serviceName.validate()}', style: boldTextStyle(size:17, weight: FontWeight.w800, color:pureBlack,fontFamily: GoogleFonts.mulish().fontFamily), maxLines: 3, overflow: TextOverflow.ellipsis),
                                        TextButton(
                                          style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.all(0))),
                                          onPressed: () {
                                            ServiceDetailScreen(serviceId: data.serviceId.validate()).launch(context);
                                          },
                                          child: Text(language.viewDetail, style: secondaryTextStyle(size:12, weight: FontWeight.w600, fontFamily: GoogleFonts.mulish().fontFamily, color: grey404040)),
                                        ),
                                      ],
                                    ).flexible()
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        16.height,
                      DottedLine(
                        direction: Axis.horizontal,
                        lineLength: double.infinity,
                        lineThickness: 2,
                        dashLength: 4,
                        dashColor: greyF1F1F1,
                      ),
                        Container(
                          decoration: BoxDecoration(color: context.scaffoldBackgroundColor,
                           border: Border.all(color: Color(0xFFF3F3F3)),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight:Radius.circular(16), ),),
                          padding: EdgeInsets.only(left: 12, right: 31,bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(language.lblYourComment, style: boldTextStyle(size:14, weight: FontWeight.w700, color: pureBlack,fontFamily: GoogleFonts.mulish().fontFamily)).expand(),
                                  SvgPicture.asset(ic_edit_square).paddingAll(8).onTap(() async {
                                    Map<String, dynamic>? dialogData = await showInDialog(
                                      context,
                                      contentPadding: EdgeInsets.zero,
                                      builder: (p0) {
                                        return AddReviewDialog(
                                          customerReview: RatingData(
                                            bookingId: data.bookingId,
                                            createdAt: data.createdAt,
                                            customerId: data.customerId,
                                            id: data.id,
                                            profileImage: data.profileImage,
                                            rating: data.rating,
                                            review: data.review,
                                            serviceId: data.serviceId,
                                            customerName: data.customerName,
                                          ),
                                          isCustomerRating: true,
                                        );
                                      },
                                    );

                                    if (dialogData != null) {
                                      data.rating = dialogData['rating'];
                                      data.review = dialogData['review'];

                                      setState(() {});

                                      LiveStream().emit(LIVESTREAM_UPDATE_DASHBOARD);
                                    }
                                  }),
                                  SvgPicture.asset(ic_delete).paddingAll(8).onTap(() {
                                    CustomDialogUtils.showConfirmDialogCustom(
                                      context,
                                      title: language.lblDeleteReview,
                                      subTitle: language.lblConfirmReviewSubTitle,
                                      positiveText: language.lblYes,
                                      negativeText: language.lblNo,
                                      dialogType: DialogType.DELETE,
                                      onAccept: (p0) async {
                                        appStore.setLoading(true);

                                        if (getStringAsync(USER_EMAIL) != DEFAULT_EMAIL) {
                                          await deleteReview(id: data.id.validate()).then((value) {
                                            toast(value.message);
                                            init();
                                          }).catchError((e) {
                                            toast(e.toString(), print: true);
                                          });
                                        } else {
                                          toast(language.lblUnAuthorized);
                                        }
                                        appStore.setLoading(false);

                                        setState(() {});
                                      },
                                    );
                                    return;
                                  }),
                                ],
                              ),
                             // Divider(color: context.dividerColor),
                              DisabledRatingBarWidget(rating: data.rating.validate().toDouble()),
                              8.height,
                              Row(
                                children: [
                                  SizedBox(
                                    width: context.width()*0.7,
                                    child: Text(data.review.validate(), style: secondaryTextStyle(size:14, weight: FontWeight.w400, fontFamily: GoogleFonts.mulish().fontFamily), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  SvgPicture.asset(ic_partying_face)
                                ],
                              ),

                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
                emptyWidget: NoDataWidget(
                  title: language.lblNoRateYet,
                  image: no_rating_bar,
                  subTitle: language.customerRatingMessage,
                ),
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: ErrorStateWidget(),
                retryText: language.reload,
                onRetry: () {
                  appStore.setLoading(true);

                  init();
                  setState(() {});
                },
              );
            },
          ),
          Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
