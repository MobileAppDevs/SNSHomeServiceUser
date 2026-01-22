
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/cached_image_widget.dart';
import '../../../component/disabled_rating_bar_widget.dart';
import '../../../component/image_border_component.dart';
import '../../../component/price_widget.dart';
import '../../../main.dart';
import '../../../model/package_data_model.dart';
import '../../../model/service_data_model.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';
import '../../../utils/images.dart';
import '../../booking/provider_info_screen.dart';
import '../service_detail_screen.dart';

class ServiceComponent extends StatefulWidget {
  final ServiceData? serviceData;
  final BookingPackage? selectedPackage;
  final double? width;
  final bool? isBorderEnabled;
  final VoidCallback? onUpdate;
  final bool isFavouriteService;

  ServiceComponent({this.serviceData, this.width, this.isBorderEnabled, this.isFavouriteService = false, this.onUpdate, this.selectedPackage});

  @override
  ServiceComponentState createState() => ServiceComponentState();
}

class ServiceComponentState extends State<ServiceComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideKeyboard(context);
        ServiceDetailScreen(serviceId: widget.isFavouriteService ? widget.serviceData!.serviceId.validate().toInt() : widget.serviceData!.id.validate()).launch(context).then((value) {
          setStatusBarColor(primaryColor);
        });
      },
      child: SafeArea(
        top: false,
        child: Container(
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: radius(16),
          backgroundColor: cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: -2,
                offset: Offset(0, 2),
              ),
              /* BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: -1,
                offset: Offset(0, 2),
              ),
               BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: -3,
                offset: Offset(0, 2),
              )*/
            ],
            border: widget.isBorderEnabled.validate(value: false)
                ? appStore.isDarkMode
                    ? null /*Border.all(color: Colors.transparent)*/
                    : null
                : null,
          ),
          width: widget.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 184,
                width: context.width(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: CachedImageWidget(
                        url: widget.isFavouriteService
                            ? widget.serviceData!.serviceAttachments.validate().isNotEmpty
                            ? widget.serviceData!.serviceAttachments!.first.validate()
                            : ''
                            : widget.serviceData!.attachments.validate().isNotEmpty
                            ? widget.serviceData!.attachments!.first.validate()
                            : '',
                        fit: BoxFit.cover,
                        height: 160,
                        width: context.width(),
                        circle: false,
                      ).cornerRadiusWithClipRRectOnly(topRight: 20, topLeft: 20.toInt(),/* bottomLeft: 20.toInt(),bottomRight: 17.toInt()*/),
                    ),
                    // Positioned(
                    //   top: 12,
                    //   left: 12,
                    //   child: Container(
                    //     padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    //     constraints: BoxConstraints(maxWidth: context.width() * 0.3),
                    //     decoration: boxDecorationWithShadow(
                    //       backgroundColor: context.cardColor.withOpacity(0.9),
                    //       borderRadius: radius(24),
                    //     ),
                    //     child: Marquee(
                    //       directionMarguee: DirectionMarguee.oneDirection,
                    //       child: Text(
                    //         "${widget.serviceData!.subCategoryName.validate().isNotEmpty ? widget.serviceData!.subCategoryName.validate() : widget.serviceData!.categoryName.validate()}".toUpperCase(),
                    //         style: boldTextStyle(color: appStore.isDarkMode ? white : primaryColor, size: 12),
                    //       ).paddingSymmetric(horizontal: 8, vertical: 4),
                    //     ),
                    //   ),
                    // ),

                    if (widget.isFavouriteService)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                           padding: EdgeInsets.all(8),
                          margin: EdgeInsets.only(right: 5, top: 5),
                           decoration: boxDecorationWithShadow(boxShape: BoxShape.circle, backgroundColor: context.cardColor),
                          child: widget.serviceData!.isFavourite == 0 ? ic_heart_fill.iconSvgImage(color: favouriteColor, size: 18) : ic_heart.iconSvgImage(color: unFavouriteColor, size: 18),
                        ).onTap(() async {
                          if (widget.serviceData!.isFavourite == 0) {
                            widget.serviceData!.isFavourite = 1;
                            setState(() {});

                            await removeToWishList(serviceId: widget.serviceData!.serviceId.validate().toInt()).then((value) {
                              if (!value) {
                                widget.serviceData!.isFavourite = 0;
                                setState(() {});
                              }
                            });
                          } else {
                            widget.serviceData!.isFavourite = 0;
                            setState(() {});

                            await addToWishList(serviceId: widget.serviceData!.serviceId.validate().toInt()).then((value) {
                              if (!value) {
                                widget.serviceData!.isFavourite = 1;
                                setState(() {});
                              }
                            });
                          }
                          widget.onUpdate?.call();
                        }),
                      ),
                    if (widget.serviceData!.isOnlineService)
                      Positioned(
                        top: 20,
                        right: 11,
                        child: Icon(Icons.circle, color: Colors.green, size: 12),
                      ),

                    // amount
                    Positioned(
                      bottom: 15,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: boxDecorationWithShadow(
                          backgroundColor: /*black.withOpacity(0.05)*/primaryColor,
                          borderRadius: radius(24),
                          border: Border.all(color: context.cardColor, width: 2),
                        ),
                        child: PriceWidget(
                          price: widget.serviceData!.price.validate(),
                          isHourlyService: widget.serviceData!.isHourlyService,
                          color: Colors.white,
                          hourlyTextColor: Colors.white,
                          size: 14,
                          isFreeService: widget.serviceData!.type.validate() == SERVICE_TYPE_FREE,
                        ),
                      ),
                    ),

                    /// rating star
                    Positioned(
                      bottom: 0,
                      left: 16,
                      child: DisabledRatingBarWidget(rating: widget.serviceData!.totalRating.validate(), size: 15),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  4.height,
                  Marquee(
                    directionMarguee: DirectionMarguee.oneDirection,
                    child: Text(widget.serviceData!.name.validate(), style: boldTextStyle(size: 16, weight: FontWeight.w700, fontFamily: GoogleFonts.mulish().fontFamily, color: pureBlack)).paddingSymmetric(horizontal: 16,),
                  ),
                  2.height,
                  Text(
                    '${language.duration} (${convertToHourMinute(widget.serviceData!.duration.validate())})',
                    style: secondaryTextStyle(size: 13, weight: FontWeight.w400,color: pureBlack, fontFamily: GoogleFonts.mulish().fontFamily),
                    maxLines: 1,
                  ).paddingSymmetric(horizontal: 16).visible(widget.serviceData!.duration.validate().isNotEmpty),
                  8.height,
                  /*
                  * provider Image and it name
                  * */
                  Row(
                    children: [
                      ImageBorder(src: widget.serviceData!.providerImage.validate(), height: 30),
                      8.width,
                      if (widget.serviceData!.providerName.validate().isNotEmpty)
                        Text(
                          widget.serviceData!.providerName.validate(),
                          style: secondaryTextStyle(size: 14, weight: FontWeight.w500, fontFamily: GoogleFonts.mulish().fontFamily, color: appStore.isDarkMode ? grey636D77 : grey636D77),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ).expand()
                    ],
                  ).onTap(() async {
                    if (widget.serviceData!.providerId != appStore.userId.validate()) {
                      await ProviderInfoScreen(providerId: widget.serviceData!.providerId.validate()).launch(context);
                      setStatusBarColor(Colors.transparent);
                    } else {
                      //
                    }
                  }).paddingSymmetric(horizontal: 16),
                  16.height,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
