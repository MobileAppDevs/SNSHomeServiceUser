
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/base_scaffold_widget.dart';
import '../../component/cached_image_widget.dart';
import '../../component/chat_gpt_loder.dart';
import '../../component/empty_error_state_widget.dart';
import '../../main.dart';
import '../../model/service_data_model.dart';
import '../../network/rest_apis.dart';
import '../../utils/colors.dart';
import '../../utils/common.dart';
import '../../utils/constant.dart';
import '../../utils/custom_dialog_utils.dart';
import '../../utils/images.dart';
import '../../utils/model_keys.dart';
import 'createService/create_service_screen.dart';

class CreatePostRequestScreen extends StatefulWidget {
  @override
  _CreatePostRequestScreenState createState() => _CreatePostRequestScreenState();
}

class _CreatePostRequestScreenState extends State<CreatePostRequestScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController postTitleCont = TextEditingController();
  TextEditingController descriptionCont = TextEditingController();
  TextEditingController priceCont = TextEditingController();

  FocusNode descriptionFocus = FocusNode();
  FocusNode priceFocus = FocusNode();

  List<ServiceData> myServiceList = [];
  List<ServiceData> selectedServiceList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setLoading(true);

    await getMyServiceList().then((value) {
      appStore.setLoading(false);

      if (value.userServices != null) {
        myServiceList = value.userServices.validate();
      }
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });

    setState(() {});
  }

  void createPostJobClick() {
    appStore.setLoading(true);
    List<int> serviceList = [];

    if (selectedServiceList.isNotEmpty) {
      selectedServiceList.forEach((element) {
        serviceList.add(element.id.validate());
      });
    }

    Map request = {
      PostJob.postTitle: postTitleCont.text.validate(),
      PostJob.description: descriptionCont.text.validate(),
      PostJob.serviceId: serviceList,
      PostJob.price: priceCont.text.validate(),
      PostJob.status: JOB_REQUEST_STATUS_REQUESTED,
      PostJob.latitude: appStore.latitude,
      PostJob.longitude: appStore.longitude,
    };

    savePostJob(request).then((value) {
      appStore.setLoading(false);
      toast(value.message.validate());

      finish(context, true);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  void deleteService(ServiceData data) {
    appStore.setLoading(true);

    deleteServiceRequest(data.id.validate()).then((value) {
      appStore.setLoading(false);
      toast(value.message.validate());
      init();
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: language.newPostJobRequest,
      child: Stack(
        children: [
          AnimatedScrollView(
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            padding: EdgeInsets.only(bottom: 60),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        16.height,
                        AppTextField(
                          controller: postTitleCont,
                          textFieldType: TextFieldType.NAME,
                          errorThisFieldRequired: language.requiredText,
                          nextFocus: descriptionFocus,
                          decoration: inputDecoration(context,),
                          title:language.postJobTitle,
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
                        ),
                        16.height,
                        AppTextField(
                          controller: descriptionCont,
                          textFieldType: TextFieldType.MULTILINE,
                          errorThisFieldRequired: language.requiredText,
                          maxLines: 2,
                          focus: descriptionFocus,
                          nextFocus: priceFocus,
                          enableChatGPT:/* appConfigurationStore.chatGPTStatus*/false,
                          promptFieldInputDecorationChatGPT: inputDecoration(context).copyWith(
                            hintText: language.writeHere,
                            fillColor: context.scaffoldBackgroundColor,
                            filled: true,
                          ),
                          testWithoutKeyChatGPT: appConfigurationStore.testWithoutKey,
                          loaderWidgetForChatGPT: const ChatGPTLoadingWidget(),
                          decoration: inputDecoration(context,),
                          title:language.hintFirstNameTxt,
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


                        ),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.PHONE,
                          controller: priceCont,
                          focus: priceFocus,
                          errorThisFieldRequired: language.requiredText,
                          decoration: inputDecoration(context,),
                          title:language.price,
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
                          keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                          validator: (s) {
                            if (s!.isEmpty) return errorThisFieldRequired;

                            if (s.toDouble() <= 0) return language.priceAmountValidationMessage;
                            return null;
                          },
                        )
                      ],
                    ).paddingAll(16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(language.services, style: boldTextStyle(size: LABEL_TEXT_SIZE,color: black1A1C1E)),
                      AppButton(
                        child: Text(language.addNewService, style: boldTextStyle(color: Colors.white)),
                        color: primaryColor,
                        onTap: () async {
                          hideKeyboard(context);

                          bool? res = await CreateServiceScreen().launch(context);
                          if (res ?? false) init();
                        },
                      ),
                    ],
                  ).paddingOnly(right: 8, left: 16),
                  if (myServiceList.isNotEmpty)
                    AnimatedListView(
                      itemCount: myServiceList.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(8),
                      listAnimationType: ListAnimationType.FadeIn,
                      itemBuilder: (_, i) {
                        ServiceData data = myServiceList[i];

                        return Container(
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.all(8),
                          width: context.width(),
                          decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor),
                          child: Row(
                            children: [
                              CachedImageWidget(
                                url: data.attachments.validate().isNotEmpty ? data.attachments!.first.validate() : "",
                                fit: BoxFit.cover,
                                height: 60,
                                width: 60,
                                radius: defaultRadius,
                              ),
                              16.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data.name.validate(), style: boldTextAutoStyle(context: context,commonColor: black1A1C1E)),
                                  4.height,
                                  Text(data.categoryName.validate(), style: secondaryTextStyle()),
                                ],
                              ).expand(),
                              Column(
                                children: [
                                  IconButton(
                                    icon: ic_edit_square_png.iconImage(size: 14),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () async {
                                      bool? res = await CreateServiceScreen(data: data).launch(context);
                                      if (res ?? false) init();
                                    },
                                  ),
                                  IconButton(
                                    icon: ic_delete_png.iconImage(size: 14),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () {
                                      CustomDialogUtils.showConfirmDialogCustom(
                                        context,
                                        dialogType: DialogType.DELETE,
                                        positiveText: language.lblDelete,
                                        negativeText: language.lblCancel,
                                        onAccept: (p0) {
                                          // ifNotTester(() {
                                          deleteService(data);
                                          //});
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              selectedServiceList.any((e) => e.id == data.id)
                                  ? AppButton(
                                      child: Text(language.remove, style: boldTextStyle(color: redColor, size: 14)),
                                      color: Colors.white,
                                      onTap: () {
                                        selectedServiceList.remove(data);
                                        setState(() {});
                                      },
                                    )
                                  : AppButton(
                                      child: Text(language.add, style: boldTextStyle(size: 14, color: Colors.white)),
                                      onTap: () {
                                        selectedServiceList.add(data);
                                        setState(() {});
                                      },
                                color:primaryColor ,
                                    ),
                            ],
                          ),
                        );
                      },
                    ),  // Service list
                  if (myServiceList.isEmpty && !appStore.isLoading)
                    NoDataWidget(
                      imageWidget: EmptyStateWidget(),
                      title: language.noServiceAdded,
                      imageSize: Size(90, 90),
                    ).paddingOnly(top: 16),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: AppButton(
              child: Text(language.save, style: boldTextStyle(color: white)),
              color: primaryColor,
              width: context.width(),
              onTap: () {
                hideKeyboard(context);

                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();

                  if (selectedServiceList.isNotEmpty) {
                    createPostJobClick();
                  } else {
                    toast(language.createPostJobWithoutSelectService);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
