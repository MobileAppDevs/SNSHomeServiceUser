 
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:home_service_user/component/back_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/colors.dart';
import '../utils/constant.dart';

const FONT_SIZE = "FONT_SIZE";

class HtmlWidget extends StatelessWidget {
  final String? postContent;
  final Color? color;
  final String? title;

  HtmlWidget({this.postContent, this.color, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        title.validate(),
        elevation: 0,
        backWidget: BackWidget(),
        color: primaryColor,
        textColor: Colors.white,
        textSize: APP_BAR_TEXT_SIZE,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        //padding: EdgeInsets.all(16.0),
        child: Html(data: postContent!),
      ),
    );
  }
}
