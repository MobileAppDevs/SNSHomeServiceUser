import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/service_data_model.dart';
import '../../../utils/colors.dart';

class AvailableBottomSheet extends StatefulWidget {
  final ServiceData serviceData;

  AvailableBottomSheet({required this.serviceData});

  @override
  _AvailableBottomSheetState createState() => _AvailableBottomSheetState();
}

class _AvailableBottomSheetState extends State<AvailableBottomSheet> {
  int selectedAddressId = -1;
  int selectedBookingAddressId = -1;

  @override
  void initState() {
    super.initState();
    if ((widget.serviceData.serviceAddressMapping ?? []).isNotEmpty) {
      selectedBookingAddressId = widget.serviceData.serviceAddressMapping!.first.providerAddressId.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: List.generate(
                    (widget.serviceData.serviceAddressMapping ?? []).length,  // ✅ Safe Access
                        (index) {
                      ServiceAddressMapping value = widget.serviceData.serviceAddressMapping![index];  // ✅ Safe Access
                      if (value.providerAddressMapping == null) return Offstage();

                      bool isSelected = selectedAddressId == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedAddressId = index;
                            selectedBookingAddressId = value.providerAddressId.validate();
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: boxDecorationDefault(color: isSelected ? primaryColor : Colors.white,
                              border: Border.all(color: chipD4D4D4,width: 1)),
                          child: Text(
                            '${value.providerAddressMapping!.address.validate()}',
                            style: boldTextStyle(color: isSelected ? Colors.white :white949494,fontFamily: GoogleFonts.mulish().fontFamily,weight: FontWeight.w400,size: 13),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}