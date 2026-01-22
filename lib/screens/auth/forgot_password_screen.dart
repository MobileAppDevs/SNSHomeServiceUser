import 'package:home_service_user/network/rest_apis.dart';
import 'package:home_service_user/store/app_store.dart';
import 'package:home_service_user/utils/colors.dart';
import 'package:home_service_user/utils/common.dart';
import 'package:home_service_user/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../network/rest_apis.dart';
import '../../utils/images.dart';
import '../../utils/model_keys.dart';
import 'otp_login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailCont = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    init();

  }

  Future<void> init() async {
    emailCont.text = appStore.userEmail;
  }

  Future<void> forgotPwd() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setLoading(true);
      Map req = {UserKeys.email: emailCont.text.validate(),};
      forgotPassword(req).then((res) {
        appStore.setLoading(false);
        finish(context);
        hideKeyboard(context);
        OTPLoginScreen(
          otpTargetEmail:emailCont.text,
          isEmailVerification:true,
          isCodeSent: true,
          verifyFor:"forgot",
        ).launch(context);
        toast(res.message.validate());
      }).catchError((e) {
        toast(e.toString(), print: true);
      }).whenComplete(() {
        appStore.setLoading(false);

      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: formKey,
          child: Stack(

            children: [
              Image.asset(   // Colored background green color
                splash_background ,
                height: context.height(),
                width: context.width(),
                fit: BoxFit.cover,
              ),
              Image.asset(    //  check box white color overlay
                splash_forground,
                height: context.height(),
                width: context.width(),
                fit: BoxFit.cover,
              ),
              Positioned(
                top: context.height()*.15,
                left: 0,
                right: 0,
                child: Image.asset(
                  lock_icon,
                  height: context.height()*.12,// height 93
                  width: context.width()*.12, // width  93
                  fit: BoxFit.scaleDown,
                ),),
              Positioned(
                top: 47,
                left: 13,
                child: GestureDetector(
                  onTap: (){
                    /*Navigator.of(context).canPop();*/
                    finish(context);
                  },
                  child: Image.asset(
                    back_icon,
                    height: context.height()*.055,
                    width: context.height()*.055,
                    fit: BoxFit.fill,
                  ),
                ),),
              Positioned(
                top: context.height()*.32,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.only(left: 24,right: 24,top:10,bottom: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24), // Rounded corner top-left
                      topRight: Radius.circular(24), // Rounded corner top-right
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                      Text(
                      textAlign: TextAlign.center,
                      language.forgotPwd,
                      style: GoogleFonts.mulish(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color:blue326A7F ),
                    ),

                  (context.height() * 0.01).toInt().height,
                  Text(
                    textAlign: TextAlign.center,
                    language.forgotPwdSubHeading ,
                    style: GoogleFonts.mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:grey636D77),
                  ),
                  (context.height() * 0.02).toInt().height,

                        Observer(
                          builder: (_) =>
                              AppTextField(
                                textFieldType: TextFieldType.EMAIL_ENHANCED,
                                controller: emailCont,
                                title:language.email,
                                autoFocus: true,
                                cursorColor: primaryColor,
                                titleTextStyle: GoogleFonts.mulish(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: grey6C7278,
                                ),
                                textStyle: GoogleFonts.mulish(
                                    fontSize:16,
                                    fontWeight:FontWeight.w600,
                                    color:black1A1C1E
                                ),
                                spacingBetweenTitleAndTextFormField:10,
                                errorThisFieldRequired: language.requiredText,
                                decoration: inputDecoration(context,

                                ),
                                autoFillHints: [AutofillHints.email],
                              ).visible(!appStore.isLoading, defaultWidget: Loader())),
                        40.height,
                        GestureDetector(
                          onTap: (){
                            forgotPwd();
                          },
                          child: Container(
                            width: context.width() - 24,
                            height:48 ,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF38B2B2), Color(0xFF038D8D)], // Gradient Colors
                                begin: Alignment.topCenter,  // Start position
                                end: Alignment.bottomCenter, // End position
                              ),
                              borderRadius: BorderRadius.circular(75),
                            ),
                            child: Center(
                              child: Text(
                                language.resetPassword,
                                style:GoogleFonts.mulish(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
