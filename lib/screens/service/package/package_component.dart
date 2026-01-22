
import 'package:flutter/material.dart';
import 'package:home_service_user/screens/service/package/package_info_bottom_sheet.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/cached_image_widget.dart';
import '../../../component/price_widget.dart';
import '../../../component/view_all_label_component.dart';
import '../../../main.dart';
import '../../../model/package_data_model.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';

class PackageComponent extends StatefulWidget {
  final List<BookingPackage> servicePackage;
  final Function(BookingPackage?) callBack;

  PackageComponent({required this.servicePackage, required this.callBack});

  @override
  _PackageComponentState createState() => _PackageComponentState();
}

class _PackageComponentState extends State<PackageComponent> {
  int selectedIndex = -1;

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
    if (widget.servicePackage.isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
          label: language.frequentlyBoughtTogether,
          list: [],
          onTap: () {
            //
          },
        ),
        AnimatedListView(
          listAnimationType: ListAnimationType.FadeIn,
          fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
          shrinkWrap: true,
          itemCount: widget.servicePackage.length,
          padding: EdgeInsets.all(5),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (_, i) {
            BookingPackage data = widget.servicePackage[i];

            return Container(
              width: context.width(),
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
              decoration: boxDecorationWithRoundedCorners(
                borderRadius: radius(),
                backgroundColor: Colors.white,
                border: appStore.isDarkMode ? Border.all(color: geryF6F7F9) : null,
              ),
              child: Row(
                children: [
                  CachedImageWidget(
                    url: data.imageAttachments.validate().isNotEmpty ? data.imageAttachments!.first.validate() : "",
                    height: 60,
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
                            child: Text(data.name.validate(), style: boldTextAutoStyle(context: context,commonColor: black1A1C1E)),
                          ),
                          2.height,
                          PriceWidget(
                            price: data.price.validate(),
                            hourlyTextColor: Colors.white,
                            size: 12,
                          ),
                        ],
                      ),
                      if (data.endDate.validate().isNotEmpty)
                        Column(
                          children: [
                            8.height,
                            Text(
                              '${language.endOn}: ${formatDate(data.endDate.validate())}',
                              style: boldTextStyle(color: Colors.green, size: 12),
                            ),
                          ],
                        ),
                    ],
                  ).expand(),
                  16.width,
                  AppButton(
                    child: Text(
                      language.buy,
                      style: boldTextStyle(color: selectedIndex != i ? white : textPrimaryColorGlobal),
                    ),
                    color: selectedIndex != i ? primaryColor : context.scaffoldBackgroundColor,
                    onTap: () async {
                      bool? res = await showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        shape: RoundedRectangleBorder(borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
                        builder: (_) {
                          return DraggableScrollableSheet(
                            initialChildSize: 0.50,
                            minChildSize: 0.2,
                            maxChildSize: 1,
                            builder: (context, scrollController) => PackageInfoComponent(packageData: data, scrollController: scrollController, isFromServiceDetail: true),
                          );
                        },
                      );

                      if (res ?? false) {
                        widget.callBack.call(data);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        )
      ],
    ).paddingSymmetric(horizontal: 16);
  }
}
