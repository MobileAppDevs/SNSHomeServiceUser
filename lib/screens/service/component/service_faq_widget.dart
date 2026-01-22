
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/service_detail_response.dart';
import '../../../utils/colors.dart';

class ServiceFaqWidget extends StatelessWidget {
  const ServiceFaqWidget({Key? key, required this.serviceFaq}) : super(key: key);

  final ServiceFaq serviceFaq;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(serviceFaq.title.validate(), style: primaryTextStyle(color:black1A1C1E,fontFamily: GoogleFonts.mulish().fontFamily,)),
      tilePadding: EdgeInsets.symmetric(horizontal: 0),
      children: [
        ListTile(
          title: Text(serviceFaq.description.validate(), style: secondaryTextStyle( color:grey404040,fontFamily: GoogleFonts.mulish().fontFamily)),
          contentPadding: EdgeInsets.only(bottom: 16),
        ),
      ],
    );
  }
}
