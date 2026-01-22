import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/component/base_scaffold_body.dart';
import 'package:home_service_user/main.dart';
import 'package:home_service_user/screens/auth/forgot_password_screen.dart';
import 'package:home_service_user/screens/auth/sign_up_screen.dart';
import 'package:home_service_user/screens/dashboard/dashboard_screen.dart';
import 'package:home_service_user/utils/colors.dart';
import 'package:home_service_user/utils/common.dart';
import 'package:home_service_user/utils/constant.dart';
import 'package:home_service_user/utils/images.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../network/rest_apis.dart';
import 'otp_login_screen.dart';

class SignInScreen extends StatefulWidget {
  final bool? isFromDashboard;
  final bool? isFromServiceBooking;
  final bool returnExpected;

  SignInScreen(
      {this.isFromDashboard,
      this.isFromServiceBooking,
      this.returnExpected = false});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  bool isRemember = true;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      setStatusBarColor(primaryColor.withAlpha(8),
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: appStore.isDarkMode
              ? Brightness.light
              : /*Brightness.dark*/ Brightness.light);
      init();
    });
  }

  void init() async {
    isRemember = getBoolAsync(IS_REMEMBERED);
    if (isRemember) {
      emailCont.text = getStringAsync(USER_EMAIL);
      passwordCont.text = getStringAsync(USER_PASSWORD);
    }

    /// For Demo Purpose
    if (await isIqonicProduct) {
      emailCont.text = DEFAULT_EMAIL;
      passwordCont.text = DEFAULT_PASS;
    }
  }

  //region Methods

  void _handleLogin() {
    hideKeyboard(context);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      _handleLoginUsers();
    }
  }

  void _handleLoginUsers() async {
    hideKeyboard(context);
    Map<String, dynamic> request = {
      'email': emailCont.text.trim(),
      'password': passwordCont.text.trim(),
      'login_type': LOGIN_TYPE_USER,
      'fcm_token': appConfigurationStore.fcm_token
    };

    appStore.setLoading(true);
    try {
      final loginResponse = await loginUser(request, isSocialLogin: false);

      await saveUserData(loginResponse.userData!);

      await setValue(USER_PASSWORD, passwordCont.text);
      await setValue(IS_REMEMBERED, isRemember);
      await appStore.setLoginType(LOGIN_TYPE_USER);

      authService.verifyFirebaseUser();
      TextInput.finishAutofillContext();

      onLoginSuccessRedirection();
    } catch (e) {
      appStore.setLoading(false);
      toast(e.toString());
      if(e.toString()=="Please verify your email before logging in"){
        // Provider Direct to the Otp Screen for Verif y Email
        OTPLoginScreen(
          otpTargetEmail:emailCont.text
          ,isEmailVerification:true,
          isCodeSent: true,
          verifyFor:"register",
        ).launch(context);
      }
    }
  }

  void googleSignIn() async {
    appStore.setLoading(true);
    await authService.signInWithGoogle(context).then((googleUser) async {
      String firstName = '';
      String lastName = '';
      if (googleUser.displayName.validate().split(' ').length >= 1)
        firstName = googleUser.displayName.splitBefore(' ');
      if (googleUser.displayName.validate().split(' ').length >= 2)
        lastName = googleUser.displayName.splitAfter(' ');

      Map<String, dynamic> request = {
        'first_name': firstName,
        'last_name': lastName,
        'email': googleUser.email,
        'username': googleUser.email.splitBefore('@').replaceAll('.', '').toLowerCase(),
        'password': passwordCont.text.trim(),
        'social_image': googleUser.photoURL,
        'login_type': LOGIN_TYPE_GOOGLE,
        'fcm_token': appConfigurationStore.fcm_token,
        'user_type': LOGIN_TYPE_USER
      };

      var loginResponse = await loginUser(request, isSocialLogin: true);

      loginResponse.userData!.profileImage = googleUser.photoURL.validate();

      await saveUserData(loginResponse.userData!); // save data to app store and >>configurations?is_authenticated=>>> api call
      appStore.setLoginType(LOGIN_TYPE_GOOGLE);

      authService.verifyFirebaseUser();

      onLoginSuccessRedirection();
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      print('Google login erroe:- ${e}');
      toast(e.toString());
    });
  }

  void appleSign() async {
    appStore.setLoading(true);

    await authService.appleSignIn(context).then((req) async {
      await loginUser(req, isSocialLogin: true).then((value) async {
        await saveUserData(value.userData!);
        appStore.setLoginType(LOGIN_TYPE_APPLE);

        appStore.setLoading(false);
        authService.verifyFirebaseUser();

        onLoginSuccessRedirection();
      }).catchError((e) {
        appStore.setLoading(false);
        log(e.toString());
        throw e;
      });
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  /*void otpSignIn() async {
    hideKeyboard(context);

    OTPLoginScreen().launch(context);
  }*/

  void onLoginSuccessRedirection() {
    afterBuildCreated(() {
      appStore.setLoading(false);
      if (widget.isFromServiceBooking.validate() ||
          widget.isFromDashboard.validate() ||
          widget.returnExpected.validate()) {
        if (widget.isFromDashboard.validate()) {
          setStatusBarColor(primaryColor);
        }

        finish(context, true);
      } else {
        DashboardScreen().launch(context,
            isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
      }
    });
  }

//endregion

//region Widgets
  Widget _buildTopWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.lblLoginTitle,
            style: GoogleFonts.mulish(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: blue326A7F,
            ),
          ),
          4.height,
          Text(language.lblLoginSubTitle,
              style: GoogleFonts.mulish(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: grey636D77,
              ),
              textAlign: TextAlign.center),
          26.height,
        ],
      ),
    );
  }

  Widget _buildRememberWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /* RoundedCheckBox(
              borderColor: primaryColor,
              checkedColor: primaryColor,
              isChecked: isRemember,
              text: language.rememberMe,
              textStyle: secondaryTextStyle(),
              size: 20,
              onTap: (value) async {
                await setValue(IS_REMEMBERED, isRemember);
                isRemember = !isRemember;
                setState(() {});
              },
            ),*/
            SizedBox(),
            TextButton(
              onPressed: () {
                hideKeyboard(context);
                ForgotPasswordScreen().launch(context);
                /* showInDialog(
                  context,
                  contentPadding: EdgeInsets.zero,
                  dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM,
                  builder: (_) => ForgotPasswordScreen(),
                );*/
              },
              child: Text(
                language.forgotPassword,
                style: GoogleFonts.mulish(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: blue4D81E7,
                ),
                textAlign: TextAlign.right,
              ),
            ).flexible(), // forgot password
          ],
        ),
        24.height,
        GestureDetector(
          onTap: () {
            _handleLogin();
          },
          child: Container(
            width: context.width() - 24,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF38B2B2),
                  Color(0xFF038D8D)
                ], // Gradient Colors
                begin: Alignment.topCenter, // Start position
                end: Alignment.bottomCenter, // End position
              ),
              borderRadius: BorderRadius.circular(75),
            ),
            child: Center(
              child: Text(
                language.signIn,
                style: GoogleFonts.mulish(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ), // LoginButton
        16.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              language.doNotHaveAccount,
              style: GoogleFonts.mulish(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: grey636D77,
              ),
            ),
            5.width,
            GestureDetector(
              onTap: () {
                hideKeyboard(context);
                SignUpScreen().launch(context);
              },
              child: Text(
                language.signUp,
                style: GoogleFonts.mulish(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: blue326A7F,
                  height: .8,
                ),
              ),
            ),
          ],
        ), // You have not account? text with Sign up
        /*  TextButton(
          onPressed: () {
            if (isAndroid) {
              if (getStringAsync(PROVIDER_PLAY_STORE_URL).isNotEmpty) {
                launchUrl(Uri.parse(getStringAsync(PROVIDER_PLAY_STORE_URL)),
                    mode: LaunchMode.externalApplication);
              } else {
                launchUrl(
                    Uri.parse(
                        '${getSocialMediaLink(LinkProvider.PLAY_STORE)}$PROVIDER_PACKAGE_NAME'),
                    mode: LaunchMode.externalApplication);
              }
            } else if (isIOS) {
              if (getStringAsync(PROVIDER_APPSTORE_URL).isNotEmpty) {
                commonLaunchUrl(getStringAsync(PROVIDER_APPSTORE_URL));
              } else {
                commonLaunchUrl(IOS_LINK_FOR_PARTNER);
              }
            }
          },
          child: Text(language.lblRegisterAsPartner,
              style: boldTextStyle(color: primaryColor)),
        )*/
      ],
    );
  }

  Widget _buildSocialWidget() {
    if (appConfigurationStore.socialLoginStatus) {
      return Column(
        children: [
         /* 20.height,
          Text(
            language.registerAsPartner,
            style: GoogleFonts.mulish(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
          ),*/

          if ((appConfigurationStore.googleLoginStatus ||
                  appConfigurationStore.otpLoginStatus) ||
              (isIOS && appConfigurationStore.appleLoginStatus))
            22.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /*Divider(color: context.dividerColor, thickness: 2).expand(),
                16.width,*/
              Text(
                language.lblOrContinueWith,
                style: GoogleFonts.mulish(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: black505050,
                ),
              ),
              /* 16.width,
                Divider(color: context.dividerColor, thickness: 2).expand(),*/
            ],
          ),
          34.height,

          /// sign in with google button coment
          if (isAndroid)
          if (appConfigurationStore.googleLoginStatus)
            GestureDetector(
              onTap: googleSignIn,
              child: Container(
                width: context.width() - 24,
                height: 48,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(75),
                    border: Border.all(color: whiteDEDADA, width: 1)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GoogleLogoWidget(size: 16),
                    16.width,
                    Text(language.lblSignInWithGoogle,
                        style: GoogleFonts.mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: black505050,
                        ),
                        textAlign: TextAlign.center)
                  ],
                ),
              ),
            ),

          //if (appConfigurationStore.googleLoginStatus) 16.height,
          // if (appConfigurationStore.otpLoginStatus)
          //   GestureDetector(
          //     onTap: otpSignIn,
          //     child: Container(
          //       width: context.width() - 24,
          //       height:48 ,
          //       decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(75),
          //           border: Border.all(color: whiteDEDADA,width: 1)
          //       ),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Container(
          //             padding: EdgeInsets.all(8),
          //             decoration: boxDecorationWithRoundedCorners(
          //               backgroundColor: primaryColor.withOpacity(0.1),
          //               boxShape: BoxShape.circle,
          //             ),
          //             child: ic_calling
          //                 .iconImage(size: 18, color: primaryColor)
          //                 .paddingAll(4),
          //           ),
          //           16.width,
          //           Text(language.lblSignInWithOTP,
          //               style: GoogleFonts.mulish(
          //                 fontSize: 16,
          //                 fontWeight: FontWeight.w700,
          //                 color: black505050,
          //               ),
          //               textAlign: TextAlign.center)
          //
          //         ],
          //       ),
          //     ),
          //   ),
          // if (appConfigurationStore.otpLoginStatus) 16.height,
          if (isIOS)
            if (appConfigurationStore.appleLoginStatus)
              GestureDetector(
                onTap: appleSign,
                child: Container(
                  width: context.width() - 24,
                  height: 48,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(75),
                      border: Border.all(color: whiteDEDADA, width: 1)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          boxShape: BoxShape.circle,
                        ),
                        child: Icon(Icons.apple),
                      ),
                      16.width,
                      Text(language.lblSignInWithApple,
                          style: GoogleFonts.mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: black505050,
                          ),
                          textAlign: TextAlign.center)
                    ],
                  ),
                ),
              ),
        ],
      );
    } else {
      return Offstage();
    }
  }

//endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (widget.isFromServiceBooking.validate()) {
      setStatusBarColor(Colors.transparent,
          statusBarIconBrightness: Brightness.dark);
    } else if (widget.isFromDashboard.validate()) {
      setStatusBarColor(Colors.transparent,
          statusBarIconBrightness: Brightness.light);
    } else {
      setStatusBarColor(primaryColor,
          statusBarIconBrightness: Brightness.light);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
    ));
    return SafeArea(
      top:false,
      child: Scaffold(
        /* appBar: AppBar(
          elevation: 0,
          backgroundColor: context.scaffoldBackgroundColor,
          leading: Navigator.of(context).canPop()
              ? BackWidget(iconColor: context.iconColor)
              : null,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarIconBrightness:
                  appStore.isDarkMode ? Brightness.light : Brightness.dark,
              statusBarColor: context.scaffoldBackgroundColor),
        ),*/
        body: Body(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  // Colored background green color
                  splash_background,
                  height: context.height(),
                  width: context.width(),
                  fit: BoxFit.cover,
                ),
                Image.asset(
                  //  check box white color overlay
                  splash_forground,
                  height: context.height(),
                  width: context.width(),
                  fit: BoxFit.cover,
                ),
                Positioned(
                    top: /*80*/ context.height() * .10,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      splash_icon,
                      height: context.height() * .123,
                      width: context.width() * .123,
                      fit: BoxFit.scaleDown,
                    )),

                Positioned(
                  top: /*179*/ context.height() * .24,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Observer(builder: (context) {
                    return Container(
                      padding: EdgeInsets.only(
                          left: 24, right: 24, top: 10, bottom: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24), // Rounded corner top-left
                          topRight:
                              Radius.circular(24), // Rounded corner top-right
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (context.height() * 0.05).toInt().height,
                            _buildTopWidget(),
                            AutofillGroup(
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x24E4E5E7),
                                          blurRadius: 2,
                                          offset: Offset(0, 1),
                                          spreadRadius: 0,
                                        )
                                      ],
                                    ),
                                    child: AppTextField(
                                      textFieldType: TextFieldType.EMAIL_ENHANCED,
                                      controller: emailCont,
                                      focus: emailFocus,
                                      nextFocus: passwordFocus,
                                      title: language.email,
                                      cursorColor: primaryColor,
                                      titleTextStyle: GoogleFonts.mulish(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: grey6C7278,
                                      ),
                                      textStyle: GoogleFonts.mulish(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: black1A1C1E),
                                      spacingBetweenTitleAndTextFormField: 10,
                                      errorThisFieldRequired:
                                          language.requiredText,
                                      decoration: inputDecoration(
                                        context,
                                      ),
                                      autoFillHints: [AutofillHints.email],
                                    ),
                                  ), //Email
                                  16.height,
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: grey24E5E73D,
                                          blurRadius: 2,
                                          offset: Offset(0, 1),
                                          spreadRadius: 0,
                                        )
                                      ],
                                    ),
                                    child: AppTextField(
                                      textFieldType: TextFieldType.PASSWORD,
                                      controller: passwordCont,
                                      focus: passwordFocus,
                                      title: language.password,
                                      cursorColor: primaryColor,
                                      titleTextStyle: GoogleFonts.mulish(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: grey6C7278,
                                      ),
                                      textStyle: GoogleFonts.mulish(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: black1A1C1E),
                                      obscureText: true,
                                      obscuringCharacter: '*',
                                      spacingBetweenTitleAndTextFormField: 10,
                                      suffixPasswordVisibleWidget: ic_show
                                          .iconImage(size: 10)
                                          .paddingAll(14),
                                      suffixPasswordInvisibleWidget: ic_hide
                                          .iconImage(size: 10)
                                          .paddingAll(14),
                                      decoration: inputDecoration(
                                        context,
                                      ),
                                      autoFillHints: [AutofillHints.password],
                                      onFieldSubmitted: (s) {
                                        _handleLogin();
                                      },
                                    ),
                                  ), // Password
                                ],
                              ),
                            ),
                            _buildRememberWidget(),
                            if (!getBoolAsync(HAS_IN_REVIEW))
                              _buildSocialWidget(),
                            //  30.height,
                          ],
                        ),
                      ),
                    );
                  }),
                ), // curved overlay on top
              ],
            ),
          ),
        ),
      ),
    );
  }
}
