import 'package:home_service_user/component/price_widget.dart';
import 'package:home_service_user/model/service_detail_response.dart';
import 'package:home_service_user/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/colors.dart';

class AppliedTaxListBottomSheet extends StatelessWidget {
  final List<TaxData> taxes;
  final num subTotal;


  const AppliedTaxListBottomSheet({super.key, required this.taxes, required this.subTotal});

  @override
  Widget build(BuildContext context) {
    num cumlativeTaxValue = subTotal;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language.appliedTaxes, style: boldTextStyle(size: LABEL_TEXT_SIZE,color: Colors.black)).paddingSymmetric(horizontal: 16),
            8.height,
            AnimatedListView(
              itemCount: taxes.length,
              padding: EdgeInsets.all(8),
              shrinkWrap: true,
              listAnimationType: ListAnimationType.FadeIn,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (_, index) {
                TaxData data = taxes[index];

                if (data.type == TAX_TYPE_PERCENT) {
                  data.totalCalculatedValue = cumlativeTaxValue * data.value.validate() / 100;
                  cumlativeTaxValue = data.totalCalculatedValue.validate() + cumlativeTaxValue;
                } else {
                  data.totalCalculatedValue = data.value.validate();
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      data.type == TAX_TYPE_PERCENT
                          ? Row(
                              children: [
                                Text(data.title.validate(), style: primaryTextStyle(color: Colors.black)),
                                4.width,
                                Text("(${data.value.validate()}%)", style: primaryTextStyle(color: primaryColor)),
                              ],
                            ).expand()
                          : Text(data.title.validate(), style: primaryTextStyle(color: Colors.black)).expand(),
                      PriceWidget(price: data.totalCalculatedValue.validate()),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
