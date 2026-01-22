
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/empty_error_state_widget.dart';
import '../../../component/loader_widget.dart';
import '../../../main.dart';
import '../../../model/booking_data_model.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/colors.dart';
import '../../../utils/constant.dart';
import '../../../utils/images.dart';
import '../../booking/booking_detail_screen.dart';
import '../../booking/component/booking_item_component.dart';
import '../../booking/component/booking_status_filter_bottom_sheet.dart';
import '../../booking/shimmer/booking_shimmer.dart';

class BookingFragment extends StatefulWidget {
  @override
  _BookingFragmentState createState() => _BookingFragmentState();
}

class _BookingFragmentState extends State<BookingFragment> {
  UniqueKey keyForList = UniqueKey();

  ScrollController scrollController = ScrollController();

  Future<List<BookingData>>? future;
  List<BookingData> bookings = [];

  int page = 1;
  bool isLastPage = false;

  String selectedValue = BOOKING_TYPE_ALL;

  @override
  void initState() {
    super.initState();
    init();

    afterBuildCreated(() {
      if (appStore.isLoggedIn) {
        setStatusBarColor(primaryColor);
      }
    });

    LiveStream().on(LIVESTREAM_UPDATE_BOOKING_LIST, (p0) {
      page = 1;
      appStore.setLoading(true);
      init();
      setState(() {});
    });
    cachedBookingStatusDropdown.validate().forEach((element) {
      element.isSelected = false;
    });
  }

  void init({String status = ''}) async {
    future = getBookingList(page, status: status, bookings: bookings,
        lastPageCallback: (b) {
      isLastPage = b;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose(LIVESTREAM_UPDATE_BOOKING_LIST);
    //scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: SafeArea(
        top: false,
        child: Scaffold(
          // appBar: appBarWidget(
          //   language.booking,
          //   textColor: white,
          //   showBack: false,
          //   textSize: APP_BAR_TEXT_SIZE,
          //   elevation: 3.0,
          //   color: primaryColor,
          //   actions: [
          //     IconButton(
          //       icon: ic_filter.iconImage(color: white, size: 20),
          //       onPressed: () async {
          //         String? res = await showModalBottomSheet(
          //           backgroundColor: Colors.transparent,
          //           context: context,
          //           isScrollControlled: true,
          //           isDismissible: true,
          //           shape: RoundedRectangleBorder(borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
          //           builder: (_) {
          //             return BookingStatusFilterBottomSheet();
          //           },
          //         );

          //         if (res.validate().isNotEmpty) {
          //           page = 1;
          //           appStore.setLoading(true);

          //           selectedValue = res!;
          //           init(status: res);

          //           if (bookings.isNotEmpty) {
          //             scrollController.animateTo(0, duration: 1.seconds, curve: Curves.easeOutQuart);
          //           } else {
          //             scrollController = ScrollController();
          //             keyForList = UniqueKey();
          //           }

          //           setState(() {});
          //         }
          //       },
          //     ),
          //   ],
          // ),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(gradient: appBarGradient),
                width: context.width(),
                height: context.height(),
              ),
              Column(
                children: [
                  18.height,
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0,bottom: 18, top: 12,right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Text(
                          language.booking,
                          style: TextStyle(
                              fontFamily: GoogleFonts.mulish().fontFamily,
                              fontWeight: FontWeight.w600,
                              color: white,
                              fontSize: 16),
                        ),
                        IconButton(
                          icon: ic_filter_icon.iconSvgImage(color: white, size: 40),
                          onPressed: () async {
                            String? res = await showModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              context: context,
                              isScrollControlled: true,
                              isDismissible: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: radiusOnly(
                                      topLeft: 16,
                                      topRight: 16)),
                              builder: (_) {
                                return BookingStatusFilterBottomSheet();
                              },
                            );

                            if (res.validate().isNotEmpty) {
                              page = 1;
                              appStore.setLoading(true);

                              selectedValue = res!;
                              init(status: res);

                              if (bookings.isNotEmpty) {
                                scrollController.animateTo(0,
                                    duration: 1.seconds,
                                    curve: Curves.easeOutQuart);
                              } else {
                                scrollController = ScrollController();
                                keyForList = UniqueKey();
                              }

                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24))),
                      child: Stack(
                        children: [
                          SnapHelperWidget<List<BookingData>>(
                            initialData: cachedBookingList,
                            future: future,
                            errorBuilder: (error) {
                              return NoDataWidget(
                                title: error,
                                imageWidget: ErrorStateWidget(),
                                retryText: language.reload,
                                onRetry: () {
                                  page = 1;
                                  appStore.setLoading(true);

                                  init();
                                  setState(() {});
                                },
                              );
                            },
                            loadingWidget: BookingShimmer(),
                            onSuccess: (list) {
                              return AnimatedListView(
                                key: keyForList,
                                controller: scrollController,
                                physics: AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.only(
                                    bottom: 60, top: 16, right: 16, left: 16),
                                itemCount: list.length,
                                shrinkWrap: false,
                                disposeScrollController: false,
                                listAnimationType: ListAnimationType.FadeIn,
                                fadeInConfiguration:
                                    FadeInConfiguration(duration: 2.seconds),
                                slideConfiguration:
                                    SlideConfiguration(verticalOffset: 400),
                                emptyWidget: NoDataWidget(
                                  title: language.lblNoBookingsFound,
                                  subTitle: language.noBookingSubTitle,
                                  imageWidget: EmptyStateWidget(),
                                ),
                                itemBuilder: (_, index) {
                                  BookingData? data = list[index];

                                  return GestureDetector(
                                    onTap: () {
                                      BookingDetailScreen(
                                              bookingId: data.id.validate())
                                          .launch(context);
                                    },
                                    child:
                                        BookingItemComponent(bookingData: data),
                                  );
                                },
                                onNextPage: () {
                                  if (!isLastPage) {
                                    page++;
                                    appStore.setLoading(true);

                                    init(status: selectedValue);
                                    setState(() {});
                                  }
                                },
                                onSwipeRefresh: () async {
                                  page = 1;
                                  appStore.setLoading(true);

                                  init(status: selectedValue);
                                  setState(() {});

                                  return await 1.seconds.delay;
                                },
                              );
                            },
                          ),
                          Observer(
                              builder: (_) =>
                                  LoaderWidget().visible(appStore.isLoading)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
