import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/base_scaffold_widget.dart';
import '../../component/cached_image_widget.dart';
import '../../main.dart';
import '../../model/city_list_model.dart';
import '../../model/country_list_model.dart';
import '../../model/login_model.dart';
import '../../model/state_list_model.dart';
import '../../network/network_utils.dart';
import '../../network/rest_apis.dart';
import '../../utils/colors.dart';
import '../../utils/common.dart';
import '../../utils/constant.dart';
import '../../utils/images.dart';
import '../../utils/model_keys.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  File? imageFile;
  XFile? pickedFile;

  List<CountryListResponse> countryList = [];
  List<StateListResponse> stateList = [];
  List<CityListResponse> cityList = [];

  CountryListResponse? selectedCountry;
  StateListResponse? selectedState;
  CityListResponse? selectedCity;

  TextEditingController fNameCont = TextEditingController();
  TextEditingController lNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController userNameCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController addressCont = TextEditingController();

  FocusNode fNameFocus = FocusNode();
  FocusNode lNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();

  int countryId = 0;
  int stateId = 0;
  int cityId = 0;

  bool isEmailVerified = getBoolAsync(IS_EMAIL_VERIFIED);

  bool showRefresh = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    afterBuildCreated(() {
      appStore.setLoading(true);
    });

    countryId = getIntAsync(COUNTRY_ID);
    stateId = getIntAsync(STATE_ID);
    cityId = getIntAsync(CITY_ID);

    fNameCont.text = appStore.userFirstName;
    lNameCont.text = appStore.userLastName;
    emailCont.text = appStore.userEmail;
    userNameCont.text = appStore.userName;
    mobileCont.text = appStore.userContactNumber;
    countryId = appStore.countryId;
    stateId = appStore.stateId;
    cityId = appStore.cityId;
    addressCont.text = appStore.address;

    userDetailAPI();

    if (getIntAsync(COUNTRY_ID) != 0) {
      await getCountry();

      setState(() {});
    } else {
      await getCountry();
    }
  }

  Future<void> userDetailAPI() async {
    await getUserDetail(appStore.userId).then((value) {
      isEmailVerified = value.emailVerified.validate().getBoolInt();
      setValue(IS_EMAIL_VERIFIED, isEmailVerified);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  Future<void> getCountry() async {
    await getCountryList().then((value) async {
      countryList.clear();
      countryList.addAll(value);

      if (value.any((element) => element.id == getIntAsync(COUNTRY_ID))) {
        selectedCountry = value.firstWhere((element) => element.id == getIntAsync(COUNTRY_ID));
      }

      setState(() {});
      await getStates(getIntAsync(COUNTRY_ID));
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  Future<void> getStates(int countryId) async {
    appStore.setLoading(true);
    await getStateList({UserKeys.countryId: countryId}).then((value) async {
      stateList.clear();
      stateList.addAll(value);

      if (value.any((element) => element.id == getIntAsync(STATE_ID))) {
        selectedState = value.firstWhere((element) => element.id == getIntAsync(STATE_ID));
      }

      setState(() {});
      if (getIntAsync(STATE_ID) != 0) {
        await getCity(getIntAsync(STATE_ID));
      }
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  Future<void> getCity(int stateId) async {
    appStore.setLoading(true);

    await getCityList({UserKeys.stateId: stateId}).then((value) async {
      cityList.clear();
      cityList.addAll(value);

      if (value.any((element) => element.id == getIntAsync(CITY_ID))) {
        selectedCity = value.firstWhere((element) => element.id == getIntAsync(CITY_ID));
      }

      setState(() {});
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  Future<void> update() async {
    hideKeyboard(context);

    MultipartRequest multiPartRequest = await getMultiPartRequest('update-profile');
    multiPartRequest.fields[UserKeys.id] = appStore.userId.toString();
    multiPartRequest.fields[UserKeys.firstName] = fNameCont.text;
    multiPartRequest.fields[UserKeys.lastName] = lNameCont.text;
    multiPartRequest.fields[UserKeys.userName] = userNameCont.text;
    multiPartRequest.fields[UserKeys.userType] = /*appStore.loginType*/LOGIN_TYPE_USER;
    multiPartRequest.fields[UserKeys.contactNumber] = mobileCont.text;
    multiPartRequest.fields[UserKeys.email] = emailCont.text;
    multiPartRequest.fields[UserKeys.countryId] = countryId.toString();
    multiPartRequest.fields[UserKeys.stateId] = stateId.toString();
    multiPartRequest.fields[UserKeys.cityId] = cityId.toString();
    multiPartRequest.fields[CommonKeys.address] = addressCont.text;
    multiPartRequest.fields[UserKeys.displayName] = '${fNameCont.text.validate() + " " + lNameCont.text.validate()}';
    if (imageFile != null) {
      multiPartRequest.files.add(await MultipartFile.fromPath(UserKeys.profileImage, imageFile!.path));
    }

    multiPartRequest.headers.addAll(buildHeaderTokens());
    print("test Multipart reponse${multiPartRequest.toString()}");
    appStore.setLoading(true);

    sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        appStore.setLoading(false);
        if (data != null) {
          if ((data as String).isJson()) {
            LoginResponse res = LoginResponse.fromJson(jsonDecode(data));

            if (FirebaseAuth.instance.currentUser != null) {
              userService.updateDocument({
                'profile_image': res.userData!.profileImage.validate(),
                'updated_at': Timestamp.now().toDate().toString(),
              }, FirebaseAuth.instance.currentUser!.uid);
            }

            saveUserData(res.userData!);
            finish(context);
            toast(res.message.validate().capitalizeFirstLetter());
          }
        }
      },
      onError: (error) {
        toast(error.toString(), print: true);
        appStore.setLoading(false);
      },
    ).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  void _getFromGallery() async {
    pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      imageFile = File(pickedFile!.path);
      setState(() {});
    }
  }

  _getFromCamera() async {
    pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      imageFile = File(pickedFile!.path);
      setState(() {});
    }
  }

  Future<void> verifyEmail() async {
    appStore.setLoading(true);

    await verifyUserEmail(emailCont.text).then((value) async {
      isEmailVerified = value.isEmailVerified.validate().getBoolInt();

      toast(value.message);

      await setValue(IS_EMAIL_VERIFIED, isEmailVerified);
      setState(() {});
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: context.cardColor,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SettingItemWidget(
              title: language.lblGallery,
              titleTextStyle:boldTextStyle(size: 15, fontFamily: GoogleFonts.mulish().fontFamily,color: black1A1D1F),
              leading: Icon(Icons.image, color: primaryColor),
              onTap: () {
                _getFromGallery();
                finish(context);
              },
            ),
            Divider(color: context.dividerColor),
            SettingItemWidget(
              title: language.camera,
              titleTextStyle:boldTextStyle(size: 15, fontFamily: GoogleFonts.mulish().fontFamily,color: black1A1D1F),
              leading: Icon(Icons.camera, color: primaryColor),
              onTap: () {
                _getFromCamera();
                finish(context);
              },
            ),
          ],
        ).paddingAll(16.0);
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.editProfile,

      child: RefreshIndicator(
        onRefresh: () async {
          return await userDetailAPI();
        },
        child: SingleChildScrollView(

          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            color: cardColor,
            padding: EdgeInsets.all(16),
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: boxDecorationDefault(
                          border: Border.all(color: context.scaffoldBackgroundColor, width: 4),
                          shape: BoxShape.circle,
                        ),
                        child: imageFile != null
                            ? Image.file(
                                imageFile!,
                                width: 85,
                                height: 85,
                                fit: BoxFit.cover,
                              ).cornerRadiusWithClipRRect(40)
                            : Observer(
                                builder: (_) => CachedImageWidget(
                                  url: appStore.userProfileImage,
                                  height: 85,
                                  width: 85,
                                  fit: BoxFit.cover,
                                  radius: 43,
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: boxDecorationWithRoundedCorners(
                            boxShape: BoxShape.circle,
                            backgroundColor: primaryColor,
                            border: Border.all(color: Colors.white),
                          ),
                          child: Icon(AntDesign.camera, color: Colors.white, size: 12),
                        ).onTap(() async {
                          _showBottomSheet(context);
                        }),
                      ).visible(/*!isLoginTypeGoogle && !isLoginTypeApple*/true)
                    ],
                  ),
                  16.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: fNameCont,
                    focus: fNameFocus,
                    title: language.hintFirstNameTxt,
                    titleTextStyle: GoogleFonts.mulish(fontSize: 15, fontWeight: FontWeight.w500, color: grey6C7278,),
                    cursorColor: primaryColor,
                    textStyle: GoogleFonts.mulish(fontSize:14, fontWeight:FontWeight.w500, color:black1A1C1E),
                    errorThisFieldRequired: language.requiredText,
                    nextFocus: lNameFocus,
                    enabled: !isLoginTypeApple,
                    decoration: inputDecoration(context,),
                    suffix: ic_profile2.iconImage(size: 10).paddingAll(14),
                  ),
                  16.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: lNameCont,
                    title: language.hintLastNameTxt,
                    titleTextStyle: GoogleFonts.mulish(fontSize: 15, fontWeight: FontWeight.w500, color: grey6C7278,),
                    cursorColor: primaryColor,
                    textStyle: GoogleFonts.mulish(fontSize:14, fontWeight:FontWeight.w500, color:black1A1C1E),
                    focus: lNameFocus,
                    errorThisFieldRequired: language.requiredText,
                    nextFocus: userNameFocus,
                    enabled: !isLoginTypeApple,
                    decoration: inputDecoration(context,),
                    suffix: ic_profile2.iconImage(size: 10).paddingAll(14),
                  ),
                  16.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: userNameCont,
                    focus: userNameFocus,
                    title: language.hintUserNameTxt,
                    titleTextStyle: GoogleFonts.mulish(fontSize: 15, fontWeight: FontWeight.w500, color: grey6C7278,),
                    cursorColor: primaryColor,
                    textStyle: GoogleFonts.mulish(fontSize:14, fontWeight:FontWeight.w500, color:black1A1C1E),
                    enabled: false,
                    errorThisFieldRequired: language.requiredText,
                    nextFocus: emailFocus,
                    decoration: inputDecoration(context,),
                    suffix: ic_profile2.iconImage(size: 10).paddingAll(14),
                  ),
                  16.height,
                  AppTextField(
                    textFieldType: TextFieldType.EMAIL_ENHANCED,
                    controller: emailCont,
                    focus: emailFocus,
                    title: language.hintEmailTxt,
                    titleTextStyle: GoogleFonts.mulish(fontSize: 15, fontWeight: FontWeight.w500, color: grey6C7278,),
                    cursorColor: primaryColor,
                    textStyle: GoogleFonts.mulish(fontSize:14, fontWeight:FontWeight.w500, color:black1A1C1E),
                    nextFocus: mobileFocus,
                    errorThisFieldRequired: language.requiredText,
                    decoration: inputDecoration(context,),
                    suffix: ic_message.iconImage(size: 10).paddingAll(14),
                    autoFillHints: [AutofillHints.email],
                    onFieldSubmitted: (email) async {
                      if (emailCont.text.isNotEmpty) await verifyEmail();
                    },
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Wrap(
                      spacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          isEmailVerified ? language.verified : language.verifyEmail,
                          style: isEmailVerified ? secondaryTextStyle(color: Colors.green) : secondaryTextStyle(),
                        ),
                        if (!isEmailVerified && !showRefresh)
                          ic_pending.iconImage(color: Colors.amber, size: 14)
                        else
                          Icon(
                            isEmailVerified ? Icons.check_circle : Icons.refresh,
                            color: isEmailVerified ? Colors.green : Colors.grey,
                            size: 16,
                          )
                      ],
                    ).paddingSymmetric(horizontal: 6, vertical: 2).onTap(
                      () {
                        verifyEmail();
                      },
                      borderRadius: radius(),
                    ),
                  ).paddingSymmetric(vertical: 4),
                  10.height,
                  AppTextField(
                    textFieldType: isAndroid ? TextFieldType.PHONE : TextFieldType.NAME,
                    controller: mobileCont,
                    focus: mobileFocus,
                    title: language.hintContactNumberTxt,
                    titleTextStyle: GoogleFonts.mulish(fontSize: 15, fontWeight: FontWeight.w500, color: grey6C7278,),
                    cursorColor: primaryColor,
                    textStyle: GoogleFonts.mulish(fontSize:14, fontWeight:FontWeight.w500, color:black999999),
                    maxLength: 15,
                    buildCounter: (_, {required int currentLength, required bool isFocused, required int? maxLength}) {
                      return Offstage();
                    },
                    enabled: !isLoginTypeOTP,
                    errorThisFieldRequired: language.requiredText,
                    decoration: inputDecoration(context,),
                    suffix: ic_calling.iconImage(size: 10).paddingAll(14),
                    validator: (mobileCont) {
                      if (mobileCont!.isEmpty) return language.phnRequiredText;
                      if (isIOS && !RegExp(r"^([0-9]{1,5})-([0-9]{1,10})$").hasMatch(mobileCont)) {
                        return language.inputMustBeNumberOrDigit;
                      }
                      if (!mobileCont.trim().contains('-')) return '"-" ${language.requiredAfterCountryCode}';
                      return null;
                    },
                  ),
                  4.height,
                  Align(
                    alignment: Alignment.topRight,
                    child: RichTextWidget(
                      list: [
                        TextSpan(text: language.addYourCountryCode, style: secondaryTextStyle()),
                        TextSpan(text: ' "91-", "236-" ', style: boldTextStyle(size: 12,fontFamily: GoogleFonts.mulish().fontFamily,color: black1A1C1E)),
                        TextSpan(
                          text: ' (${language.help})',
                          style: boldTextStyle(size: 12, color: primaryColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrlCustomTab("https://countrycode.org/");
                            },
                        ),
                      ],
                    ),
                  ),
                  16.height,
                  Row(
                    children: [
                      Column(
                        children: [
                          Align(alignment: Alignment.topLeft, child: Text(language.selectCountry,style: GoogleFonts.mulish(fontSize: 15, fontWeight: FontWeight.w500, color: grey6C7278,),)),
                          4.height,
                          DropdownButtonFormField<CountryListResponse>(
                            decoration: inputDecoration(context,),
                            isExpanded: true,
                            value: selectedCountry,
                            dropdownColor: context.cardColor,
                            style: secondaryTextStyle(size: 14,weight: FontWeight.w500, fontFamily: GoogleFonts.mulish().fontFamily,color: black999999),
                            items: countryList.map((CountryListResponse e) {
                              return DropdownMenuItem<CountryListResponse>(
                                value: e,
                                child: Text(
                                  e.name!,
                                  style: primaryTextStyle(size: 14,weight: FontWeight.w500, fontFamily: GoogleFonts.mulish().fontFamily,color: black999999),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (CountryListResponse? value) async {
                              hideKeyboard(context);
                              countryId = value!.id!;
                              selectedCountry = value;
                              selectedState = null;
                              selectedCity = null;
                              getStates(value.id!);

                              setState(() {});
                            },
                          ),
                        ],
                      ).expand(),
                      8.width.visible(stateList.isNotEmpty),
                      if (stateList.isNotEmpty)
                        Column(
                          children: [
                            Align(alignment: Alignment.topLeft, child: Text(language.selectState,style: GoogleFonts.mulish(fontSize: 15, fontWeight: FontWeight.w500, color: grey6C7278,),)),
                            4.height,
                            DropdownButtonFormField<StateListResponse>(
                              decoration: inputDecoration(context,),
                              isExpanded: true,
                              dropdownColor: context.cardColor,
                              value: selectedState,
                              items: stateList.map((StateListResponse e) {
                                return DropdownMenuItem<StateListResponse>(
                                  value: e,
                                  child: Text(
                                    e.name!,
                                    style: primaryTextStyle(size: 14,weight: FontWeight.w500, fontFamily: GoogleFonts.mulish().fontFamily,color: black999999),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (StateListResponse? value) async {
                                hideKeyboard(context);
                                selectedCity = null;
                                selectedState = value;
                                stateId = value!.id!;
                                await getCity(value.id!);
                                setState(() {});
                              },
                            ),
                          ],
                        ).expand(),
                    ],
                  ),
                  16.height,
                  if (cityList.isNotEmpty)
                    Align(alignment: Alignment.topLeft, child: Text(language.selectCity,style: GoogleFonts.mulish(fontSize: 15, fontWeight: FontWeight.w500, color: grey6C7278,),)),
                    4.height,
                  if (cityList.isNotEmpty)
                    DropdownButtonFormField<CityListResponse>(
                      decoration: inputDecoration(context),
                      isExpanded: true,
                      value: selectedCity,
                      dropdownColor: context.cardColor,
                      items: cityList.map((CityListResponse e) {
                        return DropdownMenuItem<CityListResponse>(
                          value: e,
                          child: Text(e.name!, style: primaryTextStyle(size: 14,weight: FontWeight.w500, fontFamily: GoogleFonts.mulish().fontFamily,color: black999999), maxLines: 1, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (CityListResponse? value) async {
                        hideKeyboard(context);
                        selectedCity = value;
                        cityId = value!.id!;
                        setState(() {});
                      },
                    ),
                  16.height,
                  AppTextField(
                    controller: addressCont,
                    textFieldType: TextFieldType.MULTILINE,
                    maxLines: 5,
                    title:language.hintAddress ,
                    titleTextStyle: GoogleFonts.mulish(fontSize: 15, fontWeight: FontWeight.w500, color: grey6C7278,),
                    cursorColor: primaryColor,
                    textStyle: secondaryTextStyle(size: 14,weight: FontWeight.w500, fontFamily: GoogleFonts.mulish().fontFamily,color: black999999),
                    decoration: inputDecoration(context),
                   // suffix: IconButton(onPressed: (){}, icon: Image.asset(ic_location,color: grey6C7278,height:20,width:20,fit: BoxFit.contain,)) /*ic_location.iconImage(size: 9).paddingAll(14)*/,
                    isValidationRequired: false,

                  ),
                  40.height,
                  AppButton(
                    text: language.save,
                    color: primaryColor,
                    textColor: white,
                    width: context.width() - context.navigationBarHeight,
                    onTap: () {
                      ifNotTester(() {
                        update();
                      });
                    },
                  ),
                  24.height,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
