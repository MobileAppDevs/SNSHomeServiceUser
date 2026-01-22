import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/back_widget.dart';
import '../../../component/cached_image_widget.dart';
import '../../../component/price_widget.dart';
import '../../../main.dart';
import '../../../model/service_data_model.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';
import '../../../utils/images.dart';
import '../../auth/sign_in_screen.dart';
import '../../gallery/gallery_component.dart';
import '../../gallery/gallery_screen.dart';

class ServiceDetailHeaderComponent extends StatefulWidget {
  final ServiceData serviceDetail;

  const ServiceDetailHeaderComponent({required this.serviceDetail, Key? key})
      : super(key: key);

  @override
  State<ServiceDetailHeaderComponent> createState() =>
      _ServiceDetailHeaderComponentState();
}

class _ServiceDetailHeaderComponentState
    extends State<ServiceDetailHeaderComponent> {
  Future<void> onTapFavourite() async {
    if (widget.serviceDetail.isFavourite == 1) {
      widget.serviceDetail.isFavourite = 0;
      setState(() {});

      await removeToWishList(serviceId: widget.serviceDetail.id.validate())
          .then((value) {
        if (!value) {
          widget.serviceDetail.isFavourite = 1;
          setState(() {});
        }
      });
    } else {
      widget.serviceDetail.isFavourite = 1;
      setState(() {});

      await addToWishList(serviceId: widget.serviceDetail.id.validate())
          .then((value) {
        if (!value) {
          widget.serviceDetail.isFavourite = 0;
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 420,
        width: context.width(),
        color: whiteF9F9F9,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (widget.serviceDetail.attachments.validate().isNotEmpty)
              SizedBox(
                height: 270,
                width: context.width(),
                child: CachedImageWidget(
                  url: widget.serviceDetail.attachments!.first,
                  fit: BoxFit.cover,
                  height: 270,
                ),
              ),
            Positioned(
              top: context.statusBarHeight + 8,
              child: Container(
                child: BackWidget(size: 45, iconColor: context.iconColor),
                // decoration: BoxDecoration(shape: BoxShape.circle, color: context.cardColor.withOpacity(0.7)),
              ),
            ),
            Positioned(
                top: 120,
                left: 16,
                right: 16,
                child: Container(
                  width: context.width(),
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                        EdgeInsets.only(left: 8, right: 8, top: 3, bottom: 3),
                        decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: orangeFB9450,
                            borderRadius: BorderRadius.all(Radius.circular(20))),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(ic_star_fill,
                                height: 10, width: 10, color: Colors.white),
                            4.width,
                            Text(
                                "${widget.serviceDetail.totalRating.validate().toStringAsFixed(1)}",
                                style: boldTextStyle(
                                    color: Colors.white,
                                    size: 11,
                                    weight: FontWeight.w500,
                                    fontFamily: GoogleFonts.mulish().fontFamily)),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text('${widget.serviceDetail.subCategoryName}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: boldTextStyle(
                              color: Colors.white,
                              size: 25,
                              weight: FontWeight.w700,
                              fontFamily: GoogleFonts.mulish().fontFamily)),
                    ],
                  ),
                )),
            /* Positioned(
              top: context.statusBarHeight + 8,
              child: Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(right: 8),
                decoration: boxDecorationWithShadow(boxShape: BoxShape.circle, backgroundColor: context.cardColor),
                child: widget.serviceDetail.isFavourite == 1 ? ic_fill_heart.iconImage(color: favouriteColor, size: 24) : ic_heart.iconImage(color: unFavouriteColor, size: 24),
              ).onTap(() async {
                if (appStore.isLoggedIn) {
                  onTapFavourite();
                } else {
                  push(SignInScreen(returnExpected: true)).then((value) {
                    setStatusBarColor(transparentColor, delayInMilliSeconds: 1000);
                    if (value) {
                      onTapFavourite();
                    }
                  });
                }
              }, highlightColor: Colors.transparent, splashColor: Colors.transparent, hoverColor: Colors.transparent),
              right: 8,
            ),*/
            Positioned(
              top: 220,
              bottom: 0,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  /*Row(
                    children: [
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: List.generate(
                          widget.serviceDetail.attachments!.take(2).length,
                          (i) => Container(
                            decoration: BoxDecoration(border: Border.all(color: white, width: 2), borderRadius: radius()),
                            child: GalleryComponent(images: widget.serviceDetail.attachments!, index: i, padding: 32, height: 60, width: 60),
                          ),
                        ),
                      ),
                      16.width,
                      if (widget.serviceDetail.attachments!.length > 2)
                        Blur(
                          borderRadius: radius(),
                          padding: EdgeInsets.zero,
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              border: Border.all(color: white, width: 2),
                              borderRadius: radius(),
                            ),
                            alignment: Alignment.center,
                            child: Text('+' '${widget.serviceDetail.attachments!.length - 2}', style: boldTextStyle(color: white)),
                          ),
                        ).onTap(() {
                          GalleryScreen(
                            serviceName: widget.serviceDetail.name.validate(),
                            attachments: widget.serviceDetail.attachments.validate(),
                          ).launch(context);
                        }),
                    ],
                  ),*/ // sample image which maintainer add other then cover image
                  16.height,
                  Container(
                    width: context.width(),
                    padding: EdgeInsets.all(16),
                    decoration: boxDecorationDefault(
                      color: context.scaffoldBackgroundColor,
                      //border: Border.all(color: context.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.serviceDetail.subCategoryName
                            .validate()
                            .isNotEmpty)
                          Marquee(
                            child: Row(
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
                                Text('${widget.serviceDetail.categoryName}',
                                    style: boldTextStyle(
                                        size: 18,
                                        color: black1A1D1F,
                                        weight: FontWeight.w600,
                                        fontFamily:
                                        GoogleFonts.mulish().fontFamily)),

                                /*Text('  >  ',
                                    style: boldTextStyle(
                                        color: textSecondaryColorGlobal)),
                                Text('${widget.serviceDetail.subCategoryName}',
                                    style: boldTextStyle(
                                        color: primaryColor, size: 12)),*/
                              ],
                            ),
                          )
                        else
                          Text('${widget.serviceDetail.categoryName}',
                              style: boldTextStyle(
                                  size: 18,
                                  weight: FontWeight.w600,
                                  fontFamily: GoogleFonts.mulish().fontFamily,
                                  color: primaryColor)),
                        8.height,
                        Marquee(
                          child: Text('${widget.serviceDetail.name.validate()}',
                              style: boldTextStyle(
                                  size: 20,
                                  color: black1A1D1F,
                                  weight: FontWeight.w700,
                                  fontFamily: GoogleFonts.mulish().fontFamily)),
                          directionMarguee: DirectionMarguee.oneDirection,
                        ),
                        5.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '${language.duration}: ',
                                    style:  primaryTextStyle(size: 14,weight: FontWeight.w600,color: Colors.black, fontFamily: GoogleFonts.mulish().fontFamily),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "${convertToHourMinute(widget.serviceDetail.duration.validate())}",
                                    style: boldTextStyle(color: primaryColor,size: 14,weight: FontWeight.w600, fontFamily: GoogleFonts.inter().fontFamily),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                PriceWidget(
                                  price: widget.serviceDetail.price.validate(),
                                  isHourlyService:
                                  widget.serviceDetail.isHourlyService,
                                  hourlyTextColor: textSecondaryColorGlobal,
                                  isFreeService:
                                  widget.serviceDetail.type.validate() ==
                                      SERVICE_TYPE_FREE,
                                  size:20,
                                ),
                                4.width,
                                if (widget.serviceDetail.discount.validate() != 0)
                                  Text(
                                    '(${widget.serviceDetail.discount.validate()}% ${language.lblOff})',
                                    style: boldTextStyle(color: Colors.green),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        20.height,
                        /*Column(
                          children: [
                            PriceWidget(
                              price: widget.serviceDetail.price.validate(),
                              isHourlyService:
                                  widget.serviceDetail.isHourlyService,
                              hourlyTextColor: textSecondaryColorGlobal,
                              isFreeService:
                                  widget.serviceDetail.type.validate() ==
                                      SERVICE_TYPE_FREE,
                            ),
                            4.width,
                            if (widget.serviceDetail.discount.validate() != 0)
                              Text(
                                '(${widget.serviceDetail.discount.validate()}% ${language.lblOff})',
                                style: boldTextStyle(color: Colors.green),
                              ),
                          ],
                        ),
                        TextIcon(
                          edgeInsets:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                          text: '${language.duration}',
                          textStyle: secondaryTextStyle(size: 14),
                          expandedText: true,
                          suffix: Text(
                            "${convertToHourMinute(widget.serviceDetail.duration.validate())}",
                            style: boldTextStyle(color: primaryColor),
                          ),
                        ),
                        TextIcon(
                          text: '${language.lblRating}',
                          textStyle: secondaryTextStyle(size: 14),
                          edgeInsets: EdgeInsets.symmetric(vertical: 4),
                          expandedText: true,
                          suffix: Row(
                            children: [
                              Image.asset(ic_star_fill,
                                  height: 18,
                                  color: getRatingBarColor(widget
                                      .serviceDetail.totalRating
                                      .validate()
                                      .toInt())),
                              4.width,
                              Text(
                                  "${widget.serviceDetail.totalRating.validate().toStringAsFixed(1)}",
                                  style: boldTextAutoStyle(context: context,commonColor: black1A1C1E)),
                            ],
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
