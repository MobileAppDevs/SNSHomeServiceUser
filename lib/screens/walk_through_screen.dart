import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/colors.dart';
import '../utils/configs.dart';
import '../utils/constant.dart';
import '../utils/images.dart';
import 'dashboard/dashboard_screen.dart';

class WalkThroughScreen extends StatefulWidget {
  @override
  _WalkThroughScreenState createState() => _WalkThroughScreenState();
}

class _WalkThroughScreenState extends State<WalkThroughScreen> {
  List<WalkThroughModelClass> pages = [];
  int currentPosition = 0;
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    init();

    afterBuildCreated(() async {
      pages.add(WalkThroughModelClass(
          title: language.lblWelcomeToHandyman,
          image: walk_Img1,
          subTitle: language.lblWalkThrough0));
      pages.add(WalkThroughModelClass(
          title: language.walkTitle1,
          image: walk_Img2,
          subTitle: language.walkThrough1));
      pages.add(WalkThroughModelClass(
          title: language.walkTitle2,
          image: walk_Img3,
          subTitle: language.walkThrough2));
      pages.add(WalkThroughModelClass(
          title: language.walkTitle3,
          image: walk_Img4,
          subTitle: language.walkThrough3));

      setState(() {});
    });
  }

  init() async {
    pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
          backgroundColor: context.scaffoldBackgroundColor,
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16, top: 30),
                child: SizedBox(
                  width: context.width(),
                  height: context.height(),
                  child: PageView.builder(
                    itemCount: pages.length,
                    itemBuilder: (BuildContext context, int index) {
                      WalkThroughModelClass page = pages[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: context.height() * .48,
                              child: Center(
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      walk_thr_bg,
                                      height: context.height() * .45,
                                      width: context.width(),
                                    ),
                                    Positioned(
                                        top: 10,
                                        right: 0,
                                        left: 0,
                                        child: Container(
                                          height: context.height() * .44 / 1,
                                          width: context.width() / 1.1,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.asset(
                                            page.image.validate(),
                                            fit: BoxFit.contain,
                                            // height: context.height() * .43 / 1,
                                            // width: context.width() / 1.1,
                                          ),
                                        )),
                                  ],
                                ),
                              )),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          // 40.height,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Text(
                              page.title.toString(),
                              style: GoogleFonts.mulish(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: blue326A7F,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          29.height,
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Text(
                              page.subTitle.toString(),
                              style: GoogleFonts.mulish(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: grey636D77,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                    controller: pageController,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (num) {
                      currentPosition = num + 1;
                      setState(() {});
                    },
                  ),
                ),
              ),
              Positioned(
                top: context.height() * 0.53, // Adjust this value as needed
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: DotIndicator(
                    pageController: pageController,
                    pages: pages,
                    indicatorColor: primaryColor,
                    unselectedIndicatorColor: primaryColor.withOpacity(0.5),
                    currentBoxShape: BoxShape.rectangle,
                    currentDotSize: 23,
                    currentDotWidth: 8,
                    currentBorderRadius: BorderRadius.circular(8),
                    boxShape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                    // borderRadius: radius(8),

                    dotSize: 6,
                  ),
                ),
              ), // dot indicator
              Positioned(
                top: context.height() *
                    0.85, // 620, // Adjust this value as needed
                left: 0,
                right: 0,
                child: currentPosition == 4
                    ? Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () async {
                            if (currentPosition == 4) {
                              await setValue(IS_FIRST_TIME, false);
                              DashboardScreen().launch(context,
                                  isNewTask: true,
                                  pageRouteAnimation: PageRouteAnimation.Fade);
                            }
                          },
                          child: Container(
                              margin: EdgeInsets.only(left: 74, right: 64),
                              width: context.width(),
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: primaryGradient,
                            //    color: defaultPrimaryColor, // Backg
                                shape: BoxShape
                                    .rectangle, // Adjust based on the icon
                                borderRadius: BorderRadius.circular(75),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x16D6D6D6),
                                    blurRadius: 40,
                                    offset: Offset(0, 10),
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      8), // child par padding  ayegi es par
                              child: Center(
                                  child: Text(
                                language.getStarted,
                                style: GoogleFonts.mulish(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white),
                              ))),
                        ),
                      )
                    : SizedBox(),
              ), // getStarted button
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: currentPosition != 4
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            style: ButtonStyle(
                                padding:
                                    MaterialStateProperty.all(EdgeInsets.zero)),
                            onPressed: () async {
                              await setValue(IS_FIRST_TIME, false);
                              DashboardScreen().launch(context,
                                  isNewTask: true,
                                  pageRouteAnimation: PageRouteAnimation.Fade);
                            },
                            child: Text(language.lblSkip,
                                style: GoogleFonts.mulish(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                )),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (currentPosition < 4) {
                                pageController.nextPage(
                                    duration: 500.milliseconds,
                                    curve: Curves.linearToEaseOut);
                              }
                            },
                            child: Image.asset(
                              next_btn,
                              height: 66,
                              width: 66,
                              fit: BoxFit.cover,
                            ),
                          ),

                          /*TextButton(
                    style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
                    onPressed: () async {
                      if (currentPosition == 4) {
                        await setValue(IS_FIRST_TIME, false);
                        DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                      } else {
                        pageController.nextPage(duration: 500.milliseconds, curve: Curves.linearToEaseOut);
                      }
                    },
                    child: Text(currentPosition == 4 ? language.getStarted : language.btnNext, style: boldTextStyle(color: primaryColor)),
                  ),*/
                        ],
                      )
                    : SizedBox(),
              ), // skip and next  button
            ],
          )),
    );
  }
}
