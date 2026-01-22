import '../main.dart';
import '../utils/colors.dart'; // Adding the colors import as it was used in the file
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/colors.dart';
import '../utils/constant.dart';

class ViewAllLabel extends StatelessWidget {
  final String label;
  final List? list;
  final VoidCallback? onTap;
  final int? labelSize;

  ViewAllLabel({required this.label, this.onTap, this.labelSize, this.list});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: GoogleFonts.mulish(
            fontSize: (labelSize ?? LABEL_TEXT_SIZE).toDouble(),
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),

        TextButton(
          onPressed: (list == null ? true : isViewAllVisible(list!))
              ? () {
                  onTap?.call();
                }
              : null,
          child: (list == null ? true : isViewAllVisible(list!)) ? Text(language.lblViewAll, style: GoogleFonts.mulish(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: black_404040,
          ),) : SizedBox(),
        )
      ],
    );
  }
}

bool isViewAllVisible(List list) => list.length >= 4;
