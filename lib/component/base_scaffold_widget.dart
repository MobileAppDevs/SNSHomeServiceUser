 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/constant.dart';
import 'back_widget.dart';
import 'base_scaffold_body.dart';

class AppScaffold extends StatelessWidget {
  final String? appBarTitle;
  final List<Widget>? actions;

  final Widget child;
  final Color? scaffoldBackgroundColor;
  final Widget? bottomNavigationBar;
  final bool showLoader;

  AppScaffold({
    this.appBarTitle,
    required this.child,
    this.actions,
    this.scaffoldBackgroundColor,
    this.bottomNavigationBar,
    this.showLoader = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: appBarTitle != null
              ? AppBar(
                  title: Text(appBarTitle.validate(), style: boldTextStyle(color: Colors.white, size: APP_BAR_TEXT_SIZE,
                  fontFamily: GoogleFonts.mulish().fontFamily,
                  weight: FontWeight.w700
                  ),
                  ),
                  elevation: 0.0,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light,
                    statusBarBrightness: Brightness.dark,
                  ),
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF38B2B2),
                          Color(0xFF038D8D),
                        ],
                      ),
                    ),
                  ),
                  leading: context.canPop ? BackWidget() : null,
                  actions: actions,
                )
              : null,
            backgroundColor: scaffoldBackgroundColor,
            body: Body(child: child, showLoader: showLoader),
            bottomNavigationBar: bottomNavigationBar,
        ),
      ),
    );
  }
}
