import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/screens/service/shimmer/service_detail_shimmer.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/loader_widget.dart';
import '../../component/view_all_label_component.dart';
import '../../main.dart';
import '../../model/package_data_model.dart';
import '../../model/service_data_model.dart';
import '../../model/service_detail_response.dart';
import '../../model/slot_data.dart';
import '../../model/user_data_model.dart';
import '../../network/rest_apis.dart';
import '../../store/service_addon_store.dart';
import '../../utils/colors.dart';
import '../../utils/common.dart';
import '../../utils/constant.dart';
import '../booking/book_service_screen.dart';
import '../booking/component/booking_detail_provider_widget.dart';
import '../booking/provider_info_screen.dart';
import '../review/components/review_widget.dart';
import '../review/rating_view_all_screen.dart';
import 'addons/service_addons_component.dart';
import 'component/service_availiable_bottom_sheet.dart';
import 'component/service_component.dart';
import 'component/service_detail_header_component.dart';
import 'component/service_faq_widget.dart';
import 'package/package_component.dart';

ServiceAddonStore serviceAddonStore = ServiceAddonStore();

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;
  final ServiceData? service;
  final bool isFromProviderInfo;

  ServiceDetailScreen(
      {required this.serviceId, this.service, this.isFromProviderInfo = false});

  @override
  _ServiceDetailScreenState createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen>
    with TickerProviderStateMixin {
  PageController pageController = PageController();

  Future<ServiceDetailResponse>? future;

  int selectedAddressId = 0;
  int selectedBookingAddressId = -1;
  BookingPackage? selectedPackage;

  @override
  void initState() {
    super.initState();
    serviceAddonStore.selectedServiceAddon.clear();
    setStatusBarColor(transparentColor);
    init();
  }

  void init() async {
    future = getServiceDetails(
        serviceId: widget.serviceId.validate(), customerId: appStore.userId);
  }

  //region Widgets
  Widget availableWidget({required ServiceData data}) {
    if (data.serviceAddressMapping.validate().isEmpty) return Offstage();

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Text(language.lblAvailableAt, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
          16.height,
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(
              data.serviceAddressMapping!.length,
              (index) {
                ServiceAddressMapping value =
                    data.serviceAddressMapping![index];
                if (value.providerAddressMapping == null) return Offstage();

                bool isSelected = selectedAddressId == index;
                if (selectedBookingAddressId == -1) {
                  selectedBookingAddressId = data
                      .serviceAddressMapping!.first.providerAddressId
                      .validate();
                }
                return GestureDetector(
                  onTap: () {
                    selectedAddressId = index;
                    selectedBookingAddressId =
                        value.providerAddressId.validate();
                    setState(() {});
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: boxDecorationDefault(
                        color: isSelected ? primaryColor : context.cardColor),
                    child: Text(
                      '${value.providerAddressMapping!.address.validate()}',
                      style: boldTextStyle(
                          color: isSelected
                              ? Colors.white
                              : textPrimaryColorGlobal),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget providerWidget({required UserData data}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.lblAboutProvider,
            style: boldTextStyle(
                size: 16,
                weight: FontWeight.w600,
                fontFamily: GoogleFonts.mulish().fontFamily,
                color: black1A1D1F)),
        16.height,
        BookingDetailProviderWidget(providerData: data).onTap(() async {
          await ProviderInfoScreen(providerId: data.id).launch(context);
          setStatusBarColor(Colors.transparent);
        }),
      ],
    ).paddingAll(16);
  }

  Widget serviceFaqWidget({required List<ServiceFaq> data}) {
    if (data.isEmpty) return Offstage();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ViewAllLabel(label: language.lblFaq, list: data),
          8.height,
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: data.length,
            padding: EdgeInsets.all(0),
            itemBuilder: (_, index) =>
                ServiceFaqWidget(serviceFaq: data[index]),
          ),
          8.height,
        ],
      ),
    );
  }

  Widget slotsAvailable(
      {required List<SlotData> data, required bool isSlotAvailable}) {
    if (!isSlotAvailable ||
        data.where((element) => element.slot.validate().isNotEmpty).isEmpty)
      return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*Text(language.lblAvailableOnTheseDays, style: boldTextStyle(size: LABEL_TEXT_SIZE)),*/
        16.height,
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: List.generate(
              data
                  .where((element) => element.slot.validate().isNotEmpty)
                  .length, (index) {
            SlotData value = data
                .where((element) => element.slot.validate().isNotEmpty)
                .toList()[index];
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: boxDecorationDefault(color: context.cardColor),
              child: Text('${value.day.capitalizeFirstLetter()}',
                  style: secondaryTextStyle(
                      size: LABEL_TEXT_SIZE, color: primaryColor)),
            );
          }),
        ),
      ],
    ).paddingAll(16);
  }

  Widget reviewWidget(
      {required List<RatingData> data,
      required ServiceDetailResponse serviceDetailResponse}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
          //label: language.review,
          label:
              '${language.review} (${serviceDetailResponse.serviceDetail!.totalReview})',
          list: data,
          onTap: () {
            RatingViewAllScreen(serviceId: widget.serviceId).launch(context);
          },
        ),
        data.isNotEmpty
            ? Wrap(
                children: List.generate(
                  data.length,
                  (index) => ReviewWidget(data: data[index]),
                ),
              ).paddingTop(8)
            : Text(language.lblNoReviews,
                style: secondaryTextStyle(
                  fontFamily: GoogleFonts.mulish().fontFamily,
                )),
      ],
    ).paddingSymmetric(horizontal: 16);
  }

  Widget relatedServiceWidget(
      {required List<ServiceData> serviceList, required int serviceId}) {
    if (serviceList.isEmpty) return Offstage();

    serviceList.removeWhere((element) => element.id == serviceId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.height,
        if (serviceList.isNotEmpty)
          Text(language.lblRelatedServices,
              style: boldTextStyle(
                size: LABEL_TEXT_SIZE,
                fontFamily: GoogleFonts.mulish().fontFamily,
              )).paddingSymmetric(horizontal: 16),
        if (serviceList.isNotEmpty)
          HorizontalList(
            itemCount: serviceList.length,
            padding: EdgeInsets.all(16),
            spacing: 8,
            runSpacing: 16,
            itemBuilder: (_, index) => ServiceComponent(
                    serviceData: serviceList[index],
                    width: context.width() / 2 - 26)
                .paddingOnly(right: 8),
          ),
        16.height,
      ],
    );
  }

  //endregion

  void bookNow(ServiceDetailResponse serviceDetailResponse) {
    doIfLoggedIn(context, () {
      serviceDetailResponse.serviceDetail!.bookingAddressId =
          selectedBookingAddressId;
      BookServiceScreen(
              data: serviceDetailResponse, selectedPackage: selectedPackage)
          .launch(context)
          .then((value) {
        setStatusBarColor(transparentColor);
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setStatusBarColor(
        widget.isFromProviderInfo ? primaryColor : transparentColor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBodyWidget(AsyncSnapshot<ServiceDetailResponse> snap) {
      if (snap.hasError) {
        return Text(snap.error.toString()).center();
      } else if (snap.hasData) {
        return SafeArea(
          top: false,
          child: Stack(
            children: [
              AnimatedScrollView(
                padding: EdgeInsets.only(bottom: 120),
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                onSwipeRefresh: () async {
                  appStore.setLoading(true);
                  init();
                  setState(() {});

                  return await 2.seconds.delay;
                },
                children: [
                  ServiceDetailHeaderComponent(
                      serviceDetail: snap.data!.serviceDetail!),
                  if (snap.data!.serviceDetail!.isOnlineService)
                    Container(
                      width: context.width(),
                      margin: EdgeInsets.only(left: 16, right: 16),
                      decoration: boxDecorationDefault(
                        color: whiteF9F9F9,
                        //border: Border.all(color: context.dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          8.height,
                          Text(language.serviceVisitType,
                              style: boldTextStyle(
                                  size: 18,
                                  weight: FontWeight.w700,
                                  fontFamily: GoogleFonts.mulish().fontFamily,
                                  color: Colors.black)),
                          8.height,
                          Text(language.thisServiceIsOnlineRemote,
                              style: secondaryTextStyle(
                                  size: 16,
                                  weight: FontWeight.w700,
                                  fontFamily: GoogleFonts.mulish().fontFamily)),
                        ],
                      ).paddingAll(16),
                    ), // Service Detail  card

                  Container(
                    color: whiteF9F9F9,
                    child: Container(
                      width: context.width(),
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: boxDecorationDefault(
                        color: Colors.white,
                        //border: Border.all(color: context.dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 20,
                                width: 4,
                                decoration: BoxDecoration(
                                    color: blue326A7F,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                              ),
                              SizedBox(width: 10),
                              Text(language.hintDescription,
                                  style: boldTextStyle(
                                      size: 18,
                                      weight: FontWeight.w700,
                                      color: black1A1D1F,
                                      fontFamily:
                                          GoogleFonts.mulish().fontFamily)),
                            ],
                          ),
                          8.height,
                          snap.data!.serviceDetail!.description
                                  .validate()
                                  .isNotEmpty
                              ? ReadMoreText(
                                  snap.data!.serviceDetail!.description
                                      .validate(),
                                  style: secondaryTextStyle(
                                      color: grey636D77,
                                      size: 16,
                                      weight: FontWeight.w700,
                                      fontFamily:
                                          GoogleFonts.mulish().fontFamily),
                                  colorClickableText: context.primaryColor,
                                  textAlign: TextAlign.justify,
                                )
                              : Text(language.lblNotDescription,
                                  style: secondaryTextStyle(
                                      color: grey636D77,
                                      size: 16,
                                      weight: FontWeight.w700,
                                      fontFamily:
                                          GoogleFonts.mulish().fontFamily)),
                        ],
                      ).paddingAll(16),
                    ),
                  ), // Description card

                  Container(
                    color: whiteF9F9F9,
                    child: GestureDetector(
                      onTap: () {
                        showAvailableBottomSheet(context, snap);
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white, // Change to your theme color
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              language.lblAvailableAt,
                              style: TextStyle(
                                  color: black1A1D1F,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            Icon(Icons.arrow_forward_ios,
                                color: black1A1D1F, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ), // show Availiable Bottom Sheet

                  Container(
                    color: whiteF9F9F9,
                    child: Container(
                      width: context.width(),
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      //padding: EdgeInsets.symmetric(horizontal: 16/*, vertical: 14*/),
                      decoration: boxDecorationDefault(
                        color: Colors.white,
                        //border: Border.all(color: context.dividerColor),
                      ),
                      child: slotsAvailable(
                          data: snap.data!.serviceDetail!.bookingSlots.validate(),
                          isSlotAvailable:
                              snap.data!.serviceDetail!.isSlotAvailable),
                    ),
                  ), // Slot Availiable

                  Container(
                    color: whiteF9F9F9,
                    child: Container(
                      width: context.width(),
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      //padding: EdgeInsets.symmetric(horizontal: 16/*, vertical: 14*/),
                      decoration: boxDecorationDefault(
                        color: Colors.white,
                        //border: Border.all(color: context.dividerColor),
                      ),
                      child: providerWidget(data: snap.data!.provider!),
                    ),
                  ), //  About Provider

                  /// Only active status package display
                  if (snap.data!.serviceDetail!.servicePackage
                      .validate()
                      .isNotEmpty)
                    Container(
                      color: whiteF9F9F9,
                      child: Container(
                        width: context.width(),
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        //padding: EdgeInsets.symmetric(horizontal: 16/*, vertical: 14*/),
                        decoration: boxDecorationDefault(
                          color: Colors.white,
                          //border: Border.all(color: context.dividerColor),
                        ),
                        child: PackageComponent(
                          servicePackage:
                              snap.data!.serviceDetail!.servicePackage.validate(),
                          callBack: (v) {
                            if (v != null) {
                              selectedPackage = v;
                            } else {
                              selectedPackage = null;
                            }
                            bookNow(snap.data!);
                          },
                        ),
                      ),
                    ), // Package Component

                  /// Only active status package display
                  if (snap.data!.serviceaddon.validate().isNotEmpty)
                    Container(
                      color: whiteF9F9F9,
                      child: Container(
                        width: context.width(),
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        // padding: EdgeInsets.symmetric(horizontal: 16/*, vertical: 14*/),
                        decoration: boxDecorationDefault(
                          color: Colors.white,
                          //border: Border.all(color: context.dividerColor),
                        ),
                        child: AddonComponent(
                          serviceAddon: snap.data!.serviceaddon.validate(),
                          onSelectionChange: (v) {
                            serviceAddonStore.setSelectedServiceAddon(v);
                          },
                        ),
                      ),
                    ), // add-ons

                  Container(
                    color: whiteF9F9F9,
                    child: Container(
                      width: context.width(),
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      // padding: EdgeInsets.symmetric(horizontal: 16/*, vertical: 14*/),
                      decoration: boxDecorationDefault(
                        color: Colors.white,
                        //border: Border.all(color: context.dividerColor),
                      ),
                      child: serviceFaqWidget(
                          data: snap.data!.serviceFaq.validate()),
                    ),
                  ), // Service FAQ widget

                  Container(
                    color: whiteF9F9F9,
                    child: Container(
                      width: context.width(),
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      // padding: EdgeInsets.symmetric(horizontal: 16/*, vertical: 14*/),
                      decoration: boxDecorationDefault(
                        color: Colors.white,
                        //border: Border.all(color: context.dividerColor),
                      ),
                      child: reviewWidget(
                          data: snap.data!.ratingData!,
                          serviceDetailResponse: snap.data!),
                    ),
                  ), // review Widget

                  24.height,
                  if (snap.data!.relatedService.validate().isNotEmpty)
                    Container(
                      color: whiteF9F9F9,
                      child: Container(
                        width: context.width(),
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        // padding: EdgeInsets.symmetric(horizontal: 16/*, vertical: 14*/),
                        decoration: boxDecorationDefault(
                          color: Colors.white,
                          //border: Border.all(color: context.dividerColor),
                        ),
                        child: relatedServiceWidget(
                            serviceList: snap.data!.relatedService.validate(),
                            serviceId: snap.data!.serviceDetail!.id.validate()),
                      ),
                    ),
                ],
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    (snap.data!.provider!.email != appStore.userEmail.validate())
                        ? bookNow(snap.data!)
                        : toast("you not able to book your own  service ");
                  },
                  child: Container(
                    width: context.width() - 24,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF38B2B2), Color(0xFF038D8D)],
                        // Gradient Colors
                        begin: Alignment.topCenter,
                        // Start position
                        end: Alignment.bottomCenter, // End position
                      ),
                      borderRadius: BorderRadius.circular(75),
                    ),
                    child: Center(
                      child: Text(
                        language.lblBookNow,
                        style: GoogleFonts.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }
      return ServiceDetailShimmer();
    }

    return FutureBuilder<ServiceDetailResponse>(
      initialData: listOfCachedData
          .firstWhere((element) => element?.$1 == widget.serviceId.validate(),
              orElse: () => null)
          ?.$2,
      future: future,
      builder: (context, snap) {
        return Scaffold(
          body: Stack(
            children: [
              buildBodyWidget(snap),
              Observer(
                  builder: (context) =>
                      LoaderWidget().visible(appStore.isLoading)),
            ],
          ),
        );
      },
    );
  }

  void showAvailableBottomSheet(BuildContext context, dynamic snap) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Full height usage
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)), // Rounded top corners
      ),
      builder: (context) {
        return Container(
          width: double.infinity, // Full width
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(20)), // Rounded corners
          ),
          child: SingleChildScrollView(
            // Enables scrolling
            child: Padding(
                padding: EdgeInsets.all(16),
                child: AvailableBottomSheet(
                    serviceData: snap.data!
                        .serviceDetail!) //availableWidget(data: snap.data!.serviceDetail!)
                ),
          ),
        );
      },
    );
  }
}
