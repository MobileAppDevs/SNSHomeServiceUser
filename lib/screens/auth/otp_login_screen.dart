import 'dart:convert';

import 'package:home_service_user/component/back_widget.dart';
import 'package:home_service_user/component/base_scaffold_body.dart';
import 'package:home_service_user/main.dart';
import 'package:home_service_user/screens/auth/sign_up_screen.dart';
import 'package:home_service_user/store/app_store.dart';
import 'package:home_service_user/utils/colors.dart';
import 'package:home_service_user/utils/common.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../network/rest_apis.dart';
import '../../utils/configs.dart';
import '../../utils/constant.dart';
import '../../utils/images.dart';
import '../dashboard/dashboard_screen.dart';
import 'change_password_screen.dart';

class OTPLoginScreen extends StatefulWidget {
  OTPLoginScreen({
    this.otpTargetEmail="",
    this.isEmailVerification = false,
    this.isCodeSent = false,
    this.verifyFor="",
    Key? key}) : super(key: key);

  bool isCodeSent = false;
  bool isEmailVerification = false;
  String otpTargetEmail="";
  String verifyFor="";
  @override
  State<OTPLoginScreen> createState() => _OTPLoginScreenState();
}

class _OTPLoginScreenState extends State<OTPLoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController numberController = TextEditingController();

  Country selectedCountry = defaultCountry();

  String otpCode = '';
  String verificationId = '';

  

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() => init());
  }

  Future<void> init() async {
    appStore.setLoading(false);
  }

  //region Methods
  Future<void> changeCountry() async {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        textStyle: secondaryTextStyle(color: textSecondaryColorGlobal),
        searchTextStyle: primaryTextStyle(color:black1A1C1E),
        inputDecoration: InputDecoration(
          labelText: language.search,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
      showPhoneCode: true, // optional. Shows phone code before the country name.
      onSelect: (Country country) {
        selectedCountry = country;
        log(jsonEncode(selectedCountry.toJson()));
        setState(() {});
      },
    );
  }

  Future<void> sendOTP() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);

      appStore.setLoading(true);

      toast(language.sendingOTP);

      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: "+${selectedCountry.phoneCode}${numberController.text.trim()}",
          verificationCompleted: (PhoneAuthCredential credential) async {
            toast(language.verified);

            if (isAndroid) {
              await FirebaseAuth.instance.signInWithCredential(credential);
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            appStore.setLoading(false);
            if (e.code == 'invalid-phone-number') {
              toast(language.theEnteredCodeIsInvalidPleaseTryAgain, print: true);
            } else {
              toast(e.toString(), print: true);
            }
          },
          codeSent: (String _verificationId, int? resendToken) async {
            toast(language.otpCodeIsSentToYourMobileNumber);

            appStore.setLoading(false);

            verificationId = _verificationId;

            if (verificationId.isNotEmpty) {
             widget.isCodeSent = true;
              setState(() {});
            } else {
              //Handle
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            FirebaseAuth.instance.signOut();
            widget.isCodeSent = false;
            setState(() {});
          },
        );
      } on Exception catch (e) {
        log(e);
        appStore.setLoading(false);

        toast(e.toString(), print: true);
      }
    }
  }

  Future<void> submitOtp() async {
    log(otpCode);
    if (otpCode.validate().isNotEmpty) {
      if (otpCode.validate().length >= OTP_TEXT_FIELD_LENGTH) {
        hideKeyboard(context);
        appStore.setLoading(true);

       /* try {
          PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpCode);
          UserCredential credentials = await FirebaseAuth.instance.signInWithCredential(credential);

          Map<String, dynamic> request = {
            'username': numberController.text.trim(),
            'password': numberController.text.trim(),
            'login_type': LOGIN_TYPE_OTP,
            "uid": credentials.user!.uid.validate(),
          };

          try {       
            await loginUser(request, isSocialLogin: true).then((loginResponse) async {
              if (loginResponse.isUserExist.validate(value: true)) {
                await saveUserData(loginResponse.userData!);
                await appStore.setLoginType(LOGIN_TYPE_OTP);
                DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
              } else {
                appStore.setLoading(false);
                finish(context);

                SignUpScreen(     
                  isOTPLogin: true,
                  phoneNumber: numberController.text.trim(),
                  countryCode: selectedCountry.countryCode,
                  uid: credentials.user!.uid.validate(),
                  tokenForOTPCredentials: credential.token,
                ).launch(context);
              }
            }).catchError((e) {
              finish(context);
              toast(e.toString());
              appStore.setLoading(false);
            });
          } catch (e) {
            appStore.setLoading(false);
            toast(e.toString(), print: true);
          }
        } *//*on FirebaseAuthException catch (e) {
          appStore.setLoading(false);
          if (e.code.toString() == 'invalid-verification-code') {
            toast(language.theEnteredCodeIsInvalidPleaseTryAgain, print: true);
          } else {
            toast(e.message.toString(), print: true);
          }
        }*//* on Exception catch (e) {
          appStore.setLoading(false);
          toast(e.toString(), print: true);
        }*/
          /*try{
            PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpCode);
            UserCredential credentials = await FirebaseAuth.instance.signInWithCredential(credential);
          }on FirebaseException (Exception e){
            e.
            toast(language.theEnteredCodeIsInvalidPleaseTryAgain, print: true);
          }*/

        Map<String, dynamic> req = {
          'email': widget.otpTargetEmail,
          'otp': otpCode,
          'type':widget.verifyFor,
         'country_code':"",
         'login_type': USER_TYPE_USER,//provider
        };
        validateOtp(req).then((res) async {
          appStore.setLoading(false);
         // finish(context);
          if(widget.verifyFor=="forgot"){
            ChangePasswordScreen(changePwdTargetEmail: widget.otpTargetEmail,).launch(context,isNewTask:true);// for now only Email verified is came to this Screen on sucess that why no condition added
          }else if(widget.verifyFor=="register")  {
            print("register response :- $res");
            if (res.message?.apiToken.validate().isNotEmpty == true) {
              await appStore.setToken(res.message!.apiToken.validate());
              appStore.isLoggedIn = true;
            }
            DashboardScreen().launch(context,
                isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);

          }
          toast(res.message?.message.validate());
        }).catchError((e) {
          toast(e.toString(), print: true);
        }).whenComplete(() {
          appStore.setLoading(false);

        });


      } else {
        toast(language.pleaseEnterValidOTP);
      }
    } else {
      toast(language.pleaseEnterValidOTP);
    }
  }

  // endregion

  Widget _buildMainWidget() {
    if (widget.isCodeSent) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            Center(
              child: Text(
                textAlign: TextAlign.center,
                language.otpHeading,
                style: GoogleFonts.mulish(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color:blue326A7F ),
              ),
            ),
            (context.height() * 0.01).toInt().height,
            Text(
              textAlign: TextAlign.center,
              widget.isEmailVerification?'${language.otpSubHeading } ${widget.otpTargetEmail}'
                  :'${language.otpSubHeading } +${selectedCountry.phoneCode}${numberController.text}',
              style: GoogleFonts.mulish(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:grey636D77),
            ),
            (context.height() * 0.03).toInt().height,//26
            32.height,
            Center(
              child: OTPTextField(
                pinLength: OTP_TEXT_FIELD_LENGTH,
                fieldWidth: 53,
                cursorColor:Colors.white,
                textStyle: GoogleFonts.mulish(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
                decoration: inputDecoration(context).copyWith(
                  counter: Offstage(),
                ),
                boxDecoration: BoxDecoration(),
        
                onChanged: (s) {
                  otpCode = s;
                  log(otpCode);
                },
                onCompleted: (pin) {
                  otpCode = pin;
                  submitOtp();
                },
              ).fit(),
            ),
            30.height,
            GestureDetector(
              onTap: (){
                submitOtp();
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
                    language.verify,
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
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            Text(
              textAlign: TextAlign.center,
              language.lblEnterPhnNumber,
              style: GoogleFonts.mulish(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color:blue326A7F ),
            ),
            (context.height() * 0.01).toInt().height,
            Text(
              textAlign: TextAlign.start,
              language.lblEnterPhnNumberSubheading,
              style: GoogleFonts.mulish(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:grey636D77),
            ),
            (context.height() * 0.03).toInt().height,//26
           
            Form(
              key: formKey,
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    language.country,
                    style: GoogleFonts.mulish(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: grey6C7278,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Country Code Container
                      Container(
                        width: 80,
                        height: 48, // Match AppTextField height
                        decoration: BoxDecoration(
                          border: Border.all(color: context.dividerColor),
                          borderRadius: radius(),
                        ),
                        child: InkWell(
                          onTap: () => changeCountry(),
                          child:  Center(
                            child: Text(
                              '+${selectedCountry.phoneCode}',
                              style: GoogleFonts.mulish(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: black1A1C1E,
                              ),
                            ),
                          ),
                        ),
                      ),
                      10.width,
                      // Phone Number Field
                      Expanded(
                        child: Padding(
                          padding:EdgeInsets.only(top: 15),
                          child: AppTextField(
                            textFieldType: isAndroid ? TextFieldType.PHONE : TextFieldType.NAME,
                            controller: numberController,
                            textStyle: GoogleFonts.mulish(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: black1A1C1E
                            ),
                            decoration: inputDecoration(
                              context,
                              hint: '${selectedCountry.example}',
                              hintStyle: GoogleFonts.mulish(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: grey636D77,
                              ),
                            ),
                            maxLength: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              /*AppTextField(
                controller: numberController,
                textFieldType: TextFieldType.PHONE,
                decoration: inputDecoration(context).copyWith(
                  prefixText: '+${selectedCountry.phoneCode} ',
                  hintText: '${language.lblExample}: ${selectedCountry.example}',
                  hintStyle: secondaryTextStyle(),
                ),
                autoFocus: true,
                onFieldSubmitted: (s) {
                  sendOTP();
                },
              ),*/
            ),
            30.height,
            GestureDetector(
              onTap: (){
                //sendOTP();
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
                    language.btnSendOtp,
                    style:GoogleFonts.mulish(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),




           /* AppButton(
              onTap: () {
                sendOTP();
              },
              text: language.btnSendOtp,
              color: primaryColor,
              textColor: Colors.white,
              width: context.width(),
            ),*/
           /* 16.height,*/
            /*AppButton(
              onTap: () {
                changeCountry();
              },
              text: language.lblChangeCountry,
              textStyle: boldTextStyle(),
              width: context.width(),
            ),*/
          ],
        ),
      );
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top:false,
      child: Scaffold(
        body: Body(
          child:Stack(
            children: [
              Image.asset(
                splash_background ,
                height: context.height(),
                width: context.width(),
                fit: BoxFit.cover,
              ),
              Image.asset(
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
                   widget.isCodeSent ? verified_tick: mobile_icon,
                 height: context.height()*.12,// height 93
                 width: context.width()*.12, // width  93
                 fit: BoxFit.scaleDown,
               ),),
               Positioned(
                 top: 47,
                 left: 13,
                 child: GestureDetector(
                   onTap: (){
                     Navigator.of(context).canPop();
                   },
                   child: Image.asset(
                   back_icon,
                   height: context.height()*.055,
                   width: context.height()*.055,
                   fit: BoxFit.fill,
                                ),
                 ),),
               Positioned(
                 top: context.height()*.34,
                 left: 0,
                 right: 0,
                 bottom: 0,
                 child:  Container(
                   padding: EdgeInsets.only(left: 16,right: 16,top: 16),
                   decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.only(
                         topLeft: Radius.circular(24), // Rounded corner top-left
                         topRight: Radius.circular(24), // Rounded corner top-right
                       )),
                   child: _buildMainWidget()

               ),)
            ]
          ),
        ),
      ),
    );
  }
}


