import 'package:flutter/material.dart';
import 'package:home_service_user/utils/images.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../network/rest_apis.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../utils/common.dart';


  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
           // height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Red Section with Trash Icon
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                  ),
                  child: Center(
                    child: deleteReviewIcon.iconSvgImage(size: 61)
                  ),
                ),
                SizedBox(height: 10),
                // Title
                Text(
                  language.lblDeleteReview,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                // Subtitle
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    language.lblAreYouSureWant,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),
                SizedBox(height: 20),
                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // No Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: Size(100, 34),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        language.lblNo,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    // Yes Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: Size(100, 34),
                      ),
                      onPressed: () {
                        ifNotTester(() {
                          appStore.setLoading(true);

                          deleteAccountCompletely()
                              .then((value) async {
                            try {
                              await userService
                                  .removeDocument(appStore.uid);
                              await userService.deleteUser();
                            } catch (e) {
                              print(e);
                            }

                            appStore.setLoading(false);

                            await clearPreferences();
                            toast(value.message);

                            push(DashboardScreen(),
                                isNewTask: true,
                                pageRouteAnimation:
                                PageRouteAnimation.Fade);
                          }).catchError((e) {
                            appStore.setLoading(false);
                            toast(e.toString());
                          });
                        });
                        // Add delete action here
                      },
                      child: Text(
                        language.lblYes,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

