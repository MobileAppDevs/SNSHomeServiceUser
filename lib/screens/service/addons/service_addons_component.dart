import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/cached_image_widget.dart';
import '../../../component/price_widget.dart';
import '../../../component/view_all_label_component.dart';
import '../../../main.dart';
import '../../../model/service_detail_response.dart';
import '../../../utils/colors.dart';
import '../../../utils/custom_dialog_utils.dart';
import '../../../utils/images.dart';
import '../service_detail_screen.dart';

class AddonComponent extends StatefulWidget {
  final List<Serviceaddon> serviceAddon;
  final Function(List<Serviceaddon>)? onSelectionChange;
  final bool isFromBookingLastStep;
  final bool isFromBookingDetails;
  final bool showDoneBtn;
  final Function(Serviceaddon)? onDoneClick;

  AddonComponent({
    required this.serviceAddon,
    this.isFromBookingLastStep = false,
    this.isFromBookingDetails = false,
    this.onSelectionChange,
    this.showDoneBtn = false,
    this.onDoneClick,
  });

  @override
  _AddonComponentState createState() => _AddonComponentState();
}

class _AddonComponentState extends State<AddonComponent> {
  List<Serviceaddon> selectedServiceAddon = [];
  double imageHeight = 60;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.serviceAddon.isEmpty) return Offstage();

    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ViewAllLabel(
            label: language.addOns,
            list: [],
            onTap: () {},
          ),
          AnimatedListView(
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            shrinkWrap: true,
            itemCount: widget.serviceAddon.length,
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) {
              Serviceaddon data = widget.serviceAddon[i];

              return Observer(builder: (context) {
                return GestureDetector(
                  onTap: () {
                    if (!widget.isFromBookingLastStep && !widget.isFromBookingDetails) {
                      handleAddRemove(data);
                    }
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Stack(
                    children: [
                      Container(
                        width: context.width(),
                        padding: EdgeInsets.only(left: 15,right: 15,top: 9,bottom: 9),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: boxDecorationWithRoundedCorners(
                          borderRadius: radius(),
                          backgroundColor: Colors.white,
                          border: Border.all(color: greyE5E8E9,width: 1) /*appStore.isDarkMode ? Border.all(color: context.dividerColor) : null*/,
                        ),
                        child: Row(
                          children: [
                            CachedImageWidget(
                              url: data.serviceAddonImage,
                              height: imageHeight,
                              fit: BoxFit.cover,
                              radius: defaultRadius,
                            ),
                            16.width,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Marquee(
                                      directionMarguee: DirectionMarguee.oneDirection,
                                      child: Text(data.name.validate(), style: boldTextStyle(color:black1A1C1E,fontFamily: GoogleFonts.mulish().fontFamily)),
                                    ),
                                    2.height,
                                    PriceWidget(
                                      price: data.price.validate(),
                                      hourlyTextColor: Colors.white,
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ],
                            ).expand(),
                          ],
                        ),
                      ),
                      Positioned(
                        height: imageHeight + 60,
                        right: 16,
                        child: widget.isFromBookingLastStep
                            ? Center(
                          child: IconButton(
                            icon: ic_delete.iconImage(size: 22),
                            onPressed: () {
                              CustomDialogUtils.showConfirmDialogCustom(
                                context,
                                title: language.deleteMessageForAddOnService,
                                primaryColor: primaryColor,
                                positiveText: language.lblYes,
                                negativeText: language.lblNo,
                                onAccept: (BuildContext context) {
                                  handleAddRemove(data);
                                },
                              );
                            },
                          ),
                        )
                            : Center(
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: boxDecorationWithRoundedCorners(
                              boxShape: BoxShape.circle,
                              backgroundColor: Colors.transparent,
                              border: Border.all(color: context.primaryColor),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: context.primaryColor,
                            ),
                          ),
                        ),
                      ).visible(!widget.isFromBookingDetails),
                      Column(
                        children: [
                          Container(
                            width: context.width(),
                            height: imageHeight + 32,
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: boxDecorationWithRoundedCorners(
                              borderRadius: radius(),
                              backgroundColor: context.primaryColor.withOpacity(0.1),
                              border: serviceAddonStore.selectedServiceAddon.contains(data) ? Border.all(color: context.primaryColor) : null,
                            ),
                          ),
                        ],
                      ).visible(serviceAddonStore.selectedServiceAddon.contains(data) && !widget.isFromBookingLastStep && !widget.isFromBookingDetails),
                      Positioned(
                        height: imageHeight + 60,
                        right: 16,
                        child: Center(
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: boxDecorationWithRoundedCorners(
                              boxShape: BoxShape.circle,
                              backgroundColor: context.primaryColor,
                              border: serviceAddonStore.selectedServiceAddon.contains(data) ? Border.all(color: context.primaryColor) : null,
                            ),
                            child: Icon(
                              Icons.done,
                              size: 16,
                              color: serviceAddonStore.selectedServiceAddon.contains(data) ? white : Colors.transparent,
                            ),
                          ),
                        ),
                      ).visible(serviceAddonStore.selectedServiceAddon.contains(data) && !widget.isFromBookingLastStep && !widget.isFromBookingDetails),
                      Positioned(
                        height: imageHeight + 68,
                        right: 35,
                        child: Center(
                          child: TextButton(
                            onPressed: () {
                              widget.onDoneClick?.call(data);
                            },
                            child: Container(
                              height: 36,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              decoration: boxDecorationWithRoundedCorners(
                                backgroundColor: transparentColor,
                                border: Border.all(color: context.primaryColor),
                              ),
                              child: Text(language.done, style: boldTextStyle(color: primaryColor)),
                            ),
                          ),
                        ),
                      ).visible(!data.status.getBoolInt() && widget.showDoneBtn),
                      Positioned(
                        height: imageHeight + 63,
                        right: 40,
                        child: Center(
                          child: Icon(
                            Icons.check_circle_outline_outlined,
                            size: 24,
                            color: Colors.green,
                          ),
                        ),
                      ).visible(data.status.getBoolInt() && widget.isFromBookingDetails)
                    ],
                  ),
                );
              });
            },
          )
        ],
      ).paddingSymmetric(horizontal: widget.isFromBookingLastStep || widget.isFromBookingDetails ? 0 : 16),
    );
  }

  void handleAddRemove(Serviceaddon data) {
    data.isSelected = !data.isSelected;
    selectedServiceAddon = widget.serviceAddon.where((p0) => p0.isSelected).toList();
    debugPrint('SELECTEDSERVICEADDON: ${selectedServiceAddon.length}');
    widget.onSelectionChange?.call(selectedServiceAddon);
    setState(() {});
  }
}
