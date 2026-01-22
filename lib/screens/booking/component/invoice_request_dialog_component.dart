import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/main.dart';
import 'package:home_service_user/network/rest_apis.dart';
import 'package:home_service_user/utils/colors.dart';
import 'package:home_service_user/utils/common.dart';
import 'package:home_service_user/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class InvoiceRequestDialogComponent extends StatefulWidget {
  final int? bookingId;

  InvoiceRequestDialogComponent({required this.bookingId});

  @override
  State<InvoiceRequestDialogComponent> createState() => _InvoiceRequestDialogComponentState();
}

class _InvoiceRequestDialogComponentState extends State<InvoiceRequestDialogComponent> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailCont = TextEditingController();

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    emailCont.text = appStore.userEmail.validate();
  }

  Future<void> sentMail() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setLoading(true);

      Map req = {
        UserKeys.email: emailCont.text.validate(),
        CommonKeys.bookingId: widget.bookingId.validate(),
      };

      sentInvoiceOnMail(req).then((res) {
        appStore.setLoading(false);
        finish(context, true);

        toast(res.message.validate());
      }).catchError((e) {
        toast(e.toString(), print: true);
      }).whenComplete(() => appStore.setLoading(false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                width: context.width(),
                decoration: boxDecorationDefault(color: primaryColor, borderRadius: radiusOnly(topRight: defaultRadius, topLeft: defaultRadius)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language.requestInvoice, style: boldTextStyle(color: Colors.white)),
                    IconButton(
                      onPressed: () {
                        finish(context);
                      },
                      icon: Icon(Icons.clear, color: Colors.white, size: 20),
                    )
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.invoiceSubTitle, style: primaryTextStyle(fontStyle: GoogleFonts.mulish().fontStyle,
                      color: black1A1C1E,
                      weight: FontWeight.w400,
                      size:14,
                  )),
                  20.height,
                  Observer(
                    builder: (_) => Column(
                      children: [
                        Align(
                            alignment:Alignment.topLeft,
                            child: Text(language.hintEmailTxt,
                              style: GoogleFonts.mulish(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: black1A1C1E,
                            ),)),
                        AppTextField(
                          textFieldType: TextFieldType.EMAIL_ENHANCED,
                          controller: emailCont,
                           textStyle: GoogleFonts.mulish(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: black999999,
                        ),
                          errorThisFieldRequired: language.requiredText,
                          decoration: inputDecoration(context,),
                        ).visible(!appStore.isLoading, defaultWidget: Loader()),
                      ],
                    ),
                  ),
                  30.height,
                  AppButton(
                    text: language.send,
                    height: 40,
                    color: primaryColor,
                    textStyle: primaryTextStyle(color: white),
                    width: context.width() - context.navigationBarHeight,
                    onTap: () {
                      sentMail();
                    },
                  ),
                ],
              ).paddingAll(16),
            ],
          ),
        ),
      ),
    );
  }
}
