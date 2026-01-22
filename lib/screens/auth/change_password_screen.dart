
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/screens/auth/sign_in_screen.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/base_scaffold_body.dart';
import '../../component/base_scaffold_widget.dart';
import '../../main.dart';
import '../../network/rest_apis.dart';
import '../../utils/colors.dart';
import '../../utils/common.dart';
import '../../utils/constant.dart';
import '../../utils/images.dart';
import '../../utils/model_keys.dart';
import '../dashboard/dashboard_screen.dart';

class ChangePasswordScreen extends StatefulWidget {

  ChangePasswordScreen({this.changePwdTargetEmail="", Key? key}) : super(key: key);
  String changePwdTargetEmail="";
  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController oldPasswordCont = TextEditingController();
  TextEditingController newPasswordCont = TextEditingController();
  TextEditingController reenterPasswordCont = TextEditingController();

  FocusNode oldPasswordFocus = FocusNode();
  FocusNode newPasswordFocus = FocusNode();
  FocusNode reenterPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> changePassword() async {
    if (formKey.currentState!.validate()) {
     /* if (oldPasswordCont.text.trim() != getStringAsync(USER_PASSWORD)) {
        return toast(language.provideValidCurrentPasswordMessage);
      }*/

      String pwd = newPasswordCont.text;
      if (pwd.length <= 6 ||
          !pwd.contains(RegExp(r'[a-zA-Z]')) ||
          !pwd.contains(RegExp(r'[0-9]')) ||
          !pwd.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
        reenterPasswordCont.text="";
        newPasswordCont.text="";
        showPasswordRequirementDialog(context);
        return;
      }

      formKey.currentState!.save();
      hideKeyboard(context);



      Map<String, dynamic> request = {
        'email': widget.changePwdTargetEmail,
        'new_password': newPasswordCont.text,
        'new_password_confirmation': reenterPasswordCont.text,
      };
      appStore.setLoading(true);

      await changeUserPassword(request).then((res) async {
        toast(res.message.validate());
        await setValue(USER_PASSWORD, newPasswordCont.text);
       // DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        SignInScreen().launch(context,isNewTask: true);
      }).catchError((e) {
        toast(e.toString(), print: true);
      });
      appStore.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child:  Body(
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
                   verified_tick,
                  height: context.height()*.12,// height 93
                  width: context.width()*.12, // width  93
                  fit: BoxFit.scaleDown,
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
                    child: _buildMainWidget(context)

                ),)
            ]
        ),
      ),
    );
  }

  Widget _buildMainWidget(BuildContext context){
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           /* Text(language.lblChangePwdTitle, style: secondaryTextStyle()),
            24.height,*/
            /*AppTextField(
              textFieldType: TextFieldType.PASSWORD,
              controller: oldPasswordCont,
              focus: oldPasswordFocus,
              title:language.hintOldPasswordTxt,
              titleTextStyle:GoogleFonts.mulish(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: grey6C7278,
              ) ,
              textStyle: GoogleFonts.mulish(
                  fontSize:16,
                  fontWeight:FontWeight.w600,
                  color:black1A1C1E
              ),
              spacingBetweenTitleAndTextFormField:10,
              nextFocus: newPasswordFocus,
              suffixPasswordVisibleWidget: ic_show.iconImage(size: 10).paddingAll(14),
              suffixPasswordInvisibleWidget: ic_hide.iconImage(size: 10).paddingAll(14),
              decoration: inputDecoration(
                context,
              ),
            ),
            16.height,*/
            AppTextField(
              textFieldType: TextFieldType.PASSWORD,
              controller: newPasswordCont,
              focus: newPasswordFocus,
              nextFocus: reenterPasswordFocus,
              title:language.hintNewPasswordTxt,
              titleTextStyle:GoogleFonts.mulish(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: grey6C7278,
              ) ,
              textStyle: GoogleFonts.mulish(
                  fontSize:16,
                  fontWeight:FontWeight.w600,
                  color:black1A1C1E
              ),
              spacingBetweenTitleAndTextFormField:10,
              suffixPasswordVisibleWidget: ic_show.iconImage(size: 10).paddingAll(14),
              suffixPasswordInvisibleWidget: ic_hide.iconImage(size: 10).paddingAll(14),
              decoration: inputDecoration(context),
            ),
            16.height,
            AppTextField(
              textFieldType: TextFieldType.PASSWORD,
              controller: reenterPasswordCont,
              focus: reenterPasswordFocus,
              title:language.hintReenterPasswordTxt,
              titleTextStyle:GoogleFonts.mulish(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: grey6C7278,
              ) ,
              textStyle: GoogleFonts.mulish(
                  fontSize:16,
                  fontWeight:FontWeight.w600,
                  color:black1A1C1E
              ),
              spacingBetweenTitleAndTextFormField:10,
              suffixPasswordVisibleWidget: ic_show.iconImage(size: 10).paddingAll(14),
              suffixPasswordInvisibleWidget: ic_hide.iconImage(size: 10).paddingAll(14),

              validator: (v) {
                if (newPasswordCont.text != v) {
                  return language.passwordNotMatch;
                } else if (reenterPasswordCont.text.isEmpty) {
                  return errorThisFieldRequired;
                }
                return null;
              },
              onFieldSubmitted: (s) {
                ifNotTester(() {
                  changePassword();
                });
              },
              decoration: inputDecoration(context,),
            ),
            24.height,
            AppButton(
              text: language.confirm,
              color: primaryColor,
              textColor: Colors.white,
              width: context.width() - context.navigationBarHeight,
              onTap: () {
                ifNotTester(() {
                  changePassword();
                });
              },
            ),
            24.height,
          ],
        ),
      ),
    );
  }


}
