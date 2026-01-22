
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/empty_error_state_widget.dart';
import '../../../component/loader_widget.dart';
import '../../../main.dart';
import '../../../model/dashboard_model.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';
import '../../../utils/images.dart';
import '../../auth/sign_in_screen.dart';
import '../../jobRequest/my_post_request_list_screen.dart';
import '../../service/search_service_screen.dart';
import '../component/booking_confirmed_component.dart';
import '../component/category_component.dart';
import '../component/featured_service_list_component.dart';
import '../component/new_job_request_component.dart';
import '../component/service_list_component.dart';
import '../component/slider_and_location_component.dart';
import '../shimmer/dashboard_shimmer.dart';

class DashboardFragment extends StatefulWidget {
  @override
  _DashboardFragmentState createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  Future<DashboardResponse>? future;

  @override
  void initState() {
    super.initState();
    init();

    setStatusBarColor(transparentColor, delayInMilliSeconds: 800);

    LiveStream().on(LIVESTREAM_UPDATE_DASHBOARD, (p0) {
      init();
      appStore.setLoading(true);

      setState(() {});
    });
  }

  void init() async {
    future = userDashboard(
        isCurrentLocation: appStore.isCurrentLocation,
        lat: getDoubleAsync(LATITUDE),
        long: getDoubleAsync(LONGITUDE));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_UPDATE_DASHBOARD);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Stack(
          children: [
            SnapHelperWidget<DashboardResponse>(
              initialData: cachedDashboardResponse,
              future: future,
              errorBuilder: (error) {
                return NoDataWidget(
                  title: error,
                  imageWidget: ErrorStateWidget(),
                  retryText: language.reload,
                  onRetry: () {
                    appStore.setLoading(true);
                    init();

                    setState(() {});
                  },
                );
              },
              loadingWidget: DashboardShimmer(),
              onSuccess: (snap) {
                return Observer(builder: (context) {
                  return AnimatedScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    listAnimationType: ListAnimationType.FadeIn,
                    fadeInConfiguration:
                        FadeInConfiguration(duration: 2.seconds),
                    onSwipeRefresh: () async {
                      appStore.setLoading(true);

                      setValue(LAST_APP_CONFIGURATION_SYNCED_TIME, 0);
                      init();
                      setState(() {});

                      return await 2.seconds.delay;
                    },
                    children: [
                      Stack(
                        children: [
                          Image.asset(
                            splash_background,
                            height: context.height(),
                            width: context.width(),
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 40,
                            child: SingleChildScrollView(
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      SizedBox(height: context.height() * 0.19,),
                                      Container(
                                        height: context.height(),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(24),
                                            topRight: Radius.circular(24),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ), // white Curved Background

                                  Column(
                                    mainAxisSize:MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SliderLocationComponent(
                                        sliderList: snap.slider.validate(),
                                        featuredList: snap.featuredServices.validate(),
                                        callback: () async {
                                          appStore.setLoading(true);
                                          init();
                                          setState(() {});
                                        },
                                      ), // Corousal  slider main

                                      Container(
                                        color:Colors.white,
                                        child: Column(
                                          mainAxisSize:MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            PendingBookingComponent(
                                                upcomingConfirmedBooking: snap.upcomingData),
                                            /// categories
                                            CategoryComponent(categoryList: snap.category.validate()).paddingOnly(left: 16,right:16),
                                            16.height,
                                            FeaturedServiceListComponent(serviceList: snap.featuredServices.validate()),
                                            ServiceListComponent(serviceList: snap.service.validate()),
                                            16.height,
                                           /* AppButton(
                                              text: "Crash App",
                                              color: Colors.red,
                                              textColor: Colors.white,
                                              onTap: () {
                                                FirebaseCrashlytics.instance.crash();
                                                throw Exception("Test Crash from Dashboard");

                                              },
                                            ).paddingAll(16),*/
                                            16.height,
                                            /*if (appConfigurationStore.jobRequestStatus)
                                              NewJobRequestComponent(),*/
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ],
                  );
                });
              },
            ),
            if (appConfigurationStore.jobRequestStatus) // Floating button to create  bid service
           /* Positioned(
              bottom: 30, // adjust as needed
              right: 20,  // adjust as needed
              child: FloatingActionButton(
                onPressed: () async {
                  if (appStore.isLoggedIn) {
                    MyPostRequestListScreen().launch(context);
                  } else {
                    setStatusBarColor(Colors.white, statusBarIconBrightness: Brightness.dark);
                    bool? res = await SignInScreen(isFromDashboard: true).launch(context);

                    if (res ?? false) {
                      MyPostRequestListScreen().launch(context);
                    }
                  }
                },
                shape: CircleBorder(),
                backgroundColor: primaryColor,
                child: Icon(Icons.add,color: Colors.white,), // or your theme color
              ),
            ),*/
            Observer(
                builder: (context) => LoaderWidget().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
