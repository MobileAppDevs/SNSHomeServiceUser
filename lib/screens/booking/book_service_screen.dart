import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/component/base_scaffold_body.dart';
import 'package:home_service_user/component/cached_image_widget.dart';
import 'package:home_service_user/component/price_widget.dart';
import 'package:home_service_user/main.dart';
import 'package:home_service_user/model/package_data_model.dart';
import 'package:home_service_user/model/service_detail_response.dart';
import 'package:home_service_user/screens/booking/component/confirm_booking_dialog.dart';
import 'package:home_service_user/screens/map/map_screen.dart';
import 'package:home_service_user/screens/service/package/package_info_bottom_sheet.dart';
import 'package:home_service_user/screens/service/service_detail_screen.dart';
import 'package:home_service_user/utils/colors.dart';
import 'package:home_service_user/utils/common.dart';
import 'package:home_service_user/utils/constant.dart';
import 'package:home_service_user/utils/images.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/wallet_balance_component.dart';
import '../../../model/booking_amount_model.dart';
import '../../../utils/booking_calculations_logic.dart';
import '../../app_theme.dart';
import '../../component/back_widget.dart';
import '../../component/disabled_rating_bar_widget.dart';
import '../../network/rest_apis.dart';
import '../../services/location_service.dart';
import '../../utils/app_configuration.dart';
import '../../utils/dialogs/custom_alert_dialog.dart';
import '../../utils/model_keys.dart';
import '../../utils/permissions.dart';
import '../../utils/savedAddress/address_bottom_sheet_widget.dart';
import '../payment/payment_screen.dart';
import '../service/addons/service_addons_component.dart';
import 'component/applied_tax_list_bottom_sheet.dart';
import 'component/booking_confirmation_dialog.dart';
import 'component/booking_slots.dart';
import 'component/coupon_list_screen.dart';
import 'component/date_time_picker_bottomsheet.dart';

class BookServiceScreen extends StatefulWidget {
  final ServiceDetailResponse data;
  final BookingPackage? selectedPackage;

  BookServiceScreen({required this.data, this.selectedPackage});

  @override
  _BookServiceScreenState createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  CouponData? appliedCouponData;

  BookingAmountModel bookingAmountModel = BookingAmountModel();
  num advancePaymentAmount = 0;

  int itemCount = 1;

  //Service add-on
  double imageHeight = 60;

  // handle address change click  toggle variable
  bool isShowingMapButton = false;

  TextEditingController addressCont = TextEditingController();
  TextEditingController descriptionCont = TextEditingController();

  TextEditingController dateTimeCont = TextEditingController();
  DateTime currentDateTime = DateTime.now();
  DateTime? selectedDate;
  DateTime? finalDate;
  TimeOfDay? pickedTime;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setPrice();
    try {
      if (widget.data.serviceDetail != null) {
        if (widget.data.serviceDetail!.dateTimeVal != null) {
          if (widget.data.serviceDetail!.isSlotAvailable.validate()) {
            dateTimeCont.text = formatBookingDate(
                widget.data.serviceDetail!.dateTimeVal.validate(),
                format: DATE_FORMAT_1);
            selectedDate = DateTime.parse(
                widget.data.serviceDetail!.dateTimeVal.validate());
            pickedTime = TimeOfDay.fromDateTime(selectedDate!);
          }
          addressCont.text = widget.data.serviceDetail!.address.validate();
        }
      }
    } catch (e) {}
  }

  void _handleSetLocationClick() {
    Permissions.cameraFilesAndLocationPermissionsGranted().then((value) async {
      await setValue(PERMISSION_STATUS, value);

      if (value) {
        String? res = await MapScreen(
                latitude: getDoubleAsync(LATITUDE),
                latLong: getDoubleAsync(LONGITUDE))
            .launch(context);

        addressCont.text = res.validate();
        setState(() {});
      }
    });
  }

  void _handleCurrentLocationClick() {
    Permissions.cameraFilesAndLocationPermissionsGranted().then((value) async {
      await setValue(PERMISSION_STATUS, value);

      if (value) {
        appStore.setLoading(true);

        await getUserLocation().then((value) {
          addressCont.text = value;
          widget.data.serviceDetail!.address = value.toString();
          setState(() {});
        }).catchError((e) {
          log(e);
          toast(e.toString());
        });

        appStore.setLoading(false);
      }
    }).catchError((e) {
      //
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void setPrice() {
    bookingAmountModel = finalCalculations(
      servicePrice: widget.data.serviceDetail!.price.validate(),
      appliedCouponData: appliedCouponData,
      serviceAddons: serviceAddonStore.selectedServiceAddon,
      discount: widget.data.serviceDetail!.discount.validate(),
      taxes: widget.data.taxes,
      quantity: itemCount,
      selectedPackage: widget.selectedPackage,
    );

    if (bookingAmountModel.finalSubTotal.isNegative) {
      appliedCouponData = null;
      setPrice();

      toast(language.youCannotApplyThisCoupon);
    } else {
      advancePaymentAmount = (bookingAmountModel.finalGrandTotalAmount *
          (widget.data.serviceDetail!.advancePaymentPercentage.validate() / 100)
              .toStringAsFixed(appConfigurationStore.priceDecimalPoint)
              .toDouble());
    }
    setState(() {});
  }

  void applyCoupon({bool isApplied = false}) async {
    hideKeyboard(context);
    if (widget.data.serviceDetail != null &&
        widget.data.serviceDetail!.id != null) {
      var value = await CouponsScreen(
              serviceId: widget.data.serviceDetail!.id!.toInt(),
              servicePrice: bookingAmountModel.finalTotalServicePrice,
              appliedCouponData: appliedCouponData)
          .launch(context);
      if (value != null) {
        if (value is bool && !value) {
          appliedCouponData = null;
        } else if (value is CouponData) {
          appliedCouponData = value;
        } else {
          appliedCouponData = null;
        }
        setPrice();
      }
    }
  }

  void selectDateAndTime(BuildContext context) async {
    await showDatePicker(
      context: context,
      initialDate: selectedDate ?? currentDateTime,
      firstDate: currentDateTime,
      lastDate: currentDateTime.add(30.days),
      locale: Locale(appStore.selectedLanguageCode),
      cancelText: language.lblCancel,
      confirmText: language.lblOk,
      helpText: language.lblSelectDate,
      builder: (_, child) {
        return Theme(
          data: appStore.isDarkMode
              ? AppTheme.lightTheme() /*ThemeData.dark()*/
              : AppTheme.lightTheme(),
          child: child!,
        );
      },
    ).then((date) async {
      if (date != null) {
        await showTimePicker(
          context: context,
          initialTime: pickedTime ?? TimeOfDay.now(),
          cancelText: language.lblCancel,
          confirmText: language.lblOk,
          builder: (_, child) {
            return Theme(
              data: appStore.isDarkMode
                  ? AppTheme.lightTheme() /*ThemeData.dark()*/
                  : AppTheme.lightTheme(),
              child: child!,
            );
          },
        ).then((time) {
          if (time != null) {
            finalDate = DateTime(
                date.year, date.month, date.day, time.hour, time.minute);

            DateTime now = DateTime.now().subtract(1.minutes);
            if (date.isToday &&
                finalDate!.millisecondsSinceEpoch <
                    now.millisecondsSinceEpoch) {
              return toast(language.selectedOtherBookingTime);
            }

            selectedDate = date;
            pickedTime = time;
            widget.data.serviceDetail!.dateTimeVal = finalDate.toString();
            dateTimeCont.text =
                "${formatBookingDate(selectedDate.toString(), format: DATE_FORMAT_3)} ${pickedTime!.format(context).toString()}";
          }
          setState(() {});
        }).catchError((e) {
          toast(e.toString());
        });
      }
    });
  }

  void handleDateTimePick() {
    hideKeyboard(context);
    if (widget.data.serviceDetail!.isSlot == 1) {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        shape: RoundedRectangleBorder(
            borderRadius:
                radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
        builder: (_) {
          return DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 1,
            builder: (context, scrollController) => BookingSlotsComponent(
              data: widget.data,
              showAppbar: true,
              scrollController: scrollController,
              onApplyClick: () {
                setState(() {});
              },
            ),
          );
        },
      );
    } else {
     // selectDateAndTime(context);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          return AppointmentBottomSheet(
            onDateTimeSelected: (millis,date,time) {
              print("Selected millis: $millis");

              finalDate = DateTime(
                  date.year, date.month, date.day, time!.hour, time.minute);

              DateTime now = DateTime.now().subtract(1.minutes);
              if (date.isToday &&
                  finalDate!.millisecondsSinceEpoch <
                      now.millisecondsSinceEpoch) {
                return toast(language.selectedOtherBookingTime);
              }

              selectedDate = date;
              pickedTime = time;
              widget.data.serviceDetail!.dateTimeVal = finalDate.toString();
              dateTimeCont.text =
              "${formatBookingDate(selectedDate.toString(), format: DATE_FORMAT_3)} ${pickedTime!.format(context).toString()}";
              // Pass this to backend or use as needed
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: appBarWidget(
          language.bookingSummary,
          // textColor: Colors.white,
          titleTextStyle: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          color: primaryColor,

          backWidget: BackWidget(),
        ),
        backgroundColor: Colors.white,
        body: Body(
          showLoader: true,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.selectedPackage == null)
                  Text(language.service,
                      style: boldTextStyle(
                          size: LABEL_TEXT_SIZE,
                          fontStyle: GoogleFonts.mulish().fontStyle,
                          weight: FontWeight.w700,
                          color: black1A1C1E)),
                if (widget.selectedPackage == null) 8.height,
                if (widget.selectedPackage == null) serviceWidget(context),
                // Service widget
                packageWidget(),

                /* Text("${language.hintDescription}", style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                8.height,
                AppTextField(
                  textFieldType: TextFieldType.MULTILINE,
                  controller: descriptionCont,
                  maxLines: 10,
                  minLines: 3,
                  isValidationRequired: false,
                  enableChatGPT: */ /*appConfigurationStore.chatGPTStatusfalse*/ /*false,
                  promptFieldInputDecorationChatGPT: inputDecoration(context).copyWith(
                    hintText: language.writeHere,
                    fillColor: context.scaffoldBackgroundColor,
                    filled: true,
                    hintStyle: primaryTextStyle(),
                  ),
                  testWithoutKeyChatGPT: appConfigurationStore.testWithoutKey,
                  loaderWidgetForChatGPT: const ChatGPTLoadingWidget(),
                  onFieldSubmitted: (s) {
                    widget.data.serviceDetail!.bookingDescription = s;
                  },
                  onChanged: (s) {
                    widget.data.serviceDetail!.bookingDescription = s;
                  },
                  decoration: inputDecoration(context).copyWith(
                    fillColor: context.cardColor,
                    filled: true,
                    hintText: language.lblEnterDescription,
                    hintStyle: secondaryTextStyle(),
                  ),
                ),*/
                // Description Widget this is not in ui so comment

                /// Only active status package display
                if (serviceAddonStore.selectedServiceAddon.validate().isNotEmpty)
                  AddonComponent(
                    isFromBookingLastStep: true,
                    serviceAddon: serviceAddonStore.selectedServiceAddon,
                    onSelectionChange: (v) {
                      serviceAddonStore.setSelectedServiceAddon(v);
                      setPrice();
                    },
                  ),

                priceWidget(),
                16.height,
                buildBookingSummaryWidget(), // Price Total and Booking date and slot
                16.height,
                addressAndDescriptionWidget(context), // Address Widget

                16.height,

                /* priceWidget(),*/

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ // wallet component  which show wallet balance  of user
                    /*Observer(builder: (context) {
                      return WalletBalanceComponent().visible(
                          appConfigurationStore.isEnableUserWallet &&
                              widget.data.serviceDetail!.isFixedService);
                    }),
                     16.height,
                    */
                    Text(language.disclaimer,
                        style: boldTextStyle(size: LABEL_TEXT_SIZE,weight: FontWeight.w700, fontFamily: GoogleFonts.mulish().fontFamily,color:black404040)),
                    Text(language.disclaimerContent, style: secondaryTextStyle()),
                  ],
                ).paddingSymmetric(vertical: 16), // wallet  balance widget

                36.height,

                Row(
                  children: [
                    AppButton(
                      color: primaryColor,
                      text: widget.data.serviceDetail!.isAdvancePayment
                          ? language.advancePayment
                          : language.confirm,
                      textColor: Colors.white,
                      onTap: () {
                        if (widget.data.serviceDetail!.isOnSiteService &&
                            addressCont.text.isEmpty &&
                            dateTimeCont.text.isEmpty) {
                          toast(language.pleaseEnterAddressAnd);
                        } else if (widget.data.serviceDetail!.isOnSiteService &&
                            addressCont.text.isEmpty) {
                          toast(language.pleaseEnterYourAddress);
                        } else if ((widget.data.serviceDetail!.isSlot != 1 &&
                                dateTimeCont.text.isEmpty) ||
                            (widget.data.serviceDetail!.isSlot == 1 &&
                                (widget.data.serviceDetail!.bookingSlot == null ||
                                    widget.data.serviceDetail!.bookingSlot
                                        .validate()
                                        .isEmpty))) {
                          toast(language.pleaseSelectBookingDate);
                        } else {
                          widget.data.serviceDetail!.address = addressCont.text;

                          //showBookingConfirmedBottomSheet(context);

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            backgroundColor: Colors.transparent,
                            builder: (context) => Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: ConfirmBookingDialog(
                                data: widget.data,
                                bookingPrice: bookingAmountModel.finalGrandTotalAmount,
                                selectedPackage: widget.selectedPackage,
                                qty: itemCount,
                                couponCode: appliedCouponData?.code,
                                bookingAmountModel: bookingAmountModel
                                /*bookingAmountModel: BookingAmountModel(
                                  finalCouponDiscountAmount: bookingAmountModel.finalCouponDiscountAmount,
                                  finalDiscountAmount: bookingAmountModel.finalDiscountAmount,
                                  finalSubTotal: bookingAmountModel.finalSubTotal,
                                  finalTotalServicePrice: bookingAmountModel.finalTotalServicePrice,
                                  finalTotalTax: bookingAmountModel.finalTotalTax,
                                )*/,
                              ),
                            ),
                          );

                          /* showInDialog(
                            context,
                            builder: (p0) {
                              return ConfirmBookingDialog(
                                data: widget.data,
                                bookingPrice:
                                    bookingAmountModel.finalGrandTotalAmount,
                                selectedPackage: widget.selectedPackage,
                                qty: itemCount,
                                couponCode: appliedCouponData?.code,
                                bookingAmountModel: BookingAmountModel(
                                  finalCouponDiscountAmount: bookingAmountModel
                                      .finalCouponDiscountAmount,
                                  finalDiscountAmount:
                                      bookingAmountModel.finalDiscountAmount,
                                  finalSubTotal: bookingAmountModel.finalSubTotal,
                                  finalTotalServicePrice:
                                      bookingAmountModel.finalTotalServicePrice,
                                  finalTotalTax: bookingAmountModel.finalTotalTax,
                                ),
                              );
                            },
                          );*/
                        }
                      },
                    ).expand(),
                  ],
                ), // Confirm Button
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget addressAndDescriptionWidget(BuildContext context) {
    return Column(
      children: [
        if (widget.data.serviceDetail!.isOnSiteService)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              /*Text(language.lblYourAddress,
                  style: boldTextStyle(size: LABEL_TEXT_SIZE,color: Colors.orange)),
              8.height,*/
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: (){
                      showAddressBottomSheet(context, (selectedAddress) {
                        addressCont.text = selectedAddress;
                      });
                    },
                    child: Container(
                        decoration: boxDecorationDefault(
                          color: blueE1FFFF.withAlpha(180),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: locationIconBlue
                            .iconImage(size: 15, color: primaryColor)
                            .paddingAll(6)),
                  ),// location icon
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        showAddressBottomSheet(context, (selectedAddress) {
                          addressCont.text = selectedAddress;
                        });
                      },
                      child: AppTextField(
                        textFieldType: TextFieldType.MULTILINE,
                        controller: addressCont,
                        maxLines: 3,
                        minLines: 1,
                        onFieldSubmitted: (s) {
                          widget.data.serviceDetail!.address = s;
                        },
                        textStyle: GoogleFonts.mulish(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: black404040),
                        decoration: inputDecoration(
                          context,
                          // prefixIcon: locationIconBlue.iconImage(size: 22).paddingOnly(top: 0),

                          /*Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                locationIconBlue.iconImage(size: 22).paddingOnly(top: 0),
                              ],
                            ),*/
                        ).copyWith(
                          fillColor: /*context.cardColor*/ Colors.white,
                          filled: true,
                          hintText: language.lblEnterYourAddress,
                          hintStyle: secondaryTextStyle(),
                          enabledBorder: OutlineInputBorder(
                            // Disable state border
                            borderRadius: radius(0),
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: radius(0),
                            borderSide:
                                BorderSide(color: Colors.transparent, width: 1.0),
                          ),
                        ),
                      ),
                    ),
                  ), //add address to service
                  GestureDetector(
                    onTap: () {
                      isShowingMapButton = !isShowingMapButton;
                      setState(() {});
                      },
                    child: Text(
                      language.change,
                      style: GoogleFonts.mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                  ) // change button
                ],
              ),
              if (isShowingMapButton)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   /* TextButton(
                      child: Text(language.lblChooseFromMap,
                          style: boldTextStyle(color: primaryColor, size: 13)),
                      onPressed: () {
                        _handleSetLocationClick();
                      },
                    ).flexible(),*/
                    TextButton(
                      onPressed: _handleCurrentLocationClick,
                      child: Text(language.lblUseCurrentLocation,
                          style: boldTextStyle(color: primaryColor, size: 13),
                          textAlign: TextAlign.right),
                    ).flexible(),
                  ],
                ), // Below button Row
            ],
          ),
        16.height.visible(!widget.data.serviceDetail!.isOnSiteService),
      ],
    );
  }

  Widget serviceWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: boxDecorationDefault(
          color: Colors.white,
          /*context.cardColor*/
          border: Border.all(
            color: greyF1F1F1,
            width: 1,
          )),
      width: context.width(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedImageWidget(
            url: widget.data.serviceDetail!.attachments.validate().isNotEmpty
                ? widget.data.serviceDetail!.attachments!.first.validate()
                : '',
            height: 90,
            width: 90,
            fit: BoxFit.cover,
          ).cornerRadiusWithClipRRect(defaultRadius),
          10.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.data.serviceDetail!.name.validate(),
                  style: boldTextAutoStyle(
                      context: context,
                      commonColor: pureBlack,
                      fontStyle: GoogleFonts.mulish().fontStyle,
                      weight: FontWeight.w800,
                      size: 17)),
              4.height,
              if (widget.data.serviceDetail != null &&
                  widget.data.serviceDetail!.totalRating != null)
                Row(
                  children: [
                    DisabledRatingBarWidget(
                        rating:
                            widget.data.serviceDetail!.totalRating!.validate()),
                    10.width,
                    Text(
                      "(${widget.data.serviceDetail!.totalRating})",
                      style: GoogleFonts.mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: grey636D77,
                      ),
                    ),
                  ],
                ),
              if (widget.data.serviceDetail != null &&
                  widget.data.serviceDetail!.totalRating != null)
                4.height,
              // Text('${language.duration} (${convertToHourMinute(widget.data.serviceDetail!.duration.validate())})', style: secondaryTextStyle()),
              4.height,
              if (widget.data.serviceDetail!.isFixedService)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "\$${bookingAmountModel.finalGrandTotalAmount}",
                        style: GoogleFonts.mulish(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: pureBlack,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Container(
                      height: 40,
                      padding: EdgeInsets.all(8),
                      decoration: boxDecorationWithRoundedCorners(
                          backgroundColor: whiteECFFFF,
                          border: Border.all(color: blue35B4B4, width: 1)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                              onTap: () {
                                if (itemCount != 1) itemCount--;
                                setPrice();
                              },
                              child: subtractIcon
                                  .iconImage(
                                      size: 8,
                                      color: pureBlack,
                                      fit: BoxFit.scaleDown)
                                  .paddingAll(5)),
                          16.width,
                          Text(itemCount.toString(),
                              style: primaryTextStyle(
                                  fontStyle: GoogleFonts.mulish().fontStyle,
                                  color: pureBlack,
                                  size: 14)),
                          16.width,
                          GestureDetector(
                              onTap: () {
                                itemCount++;
                                setPrice();
                              },
                              child: addIcon
                                  .iconImage(
                                      size: 8,
                                      color: pureBlack,
                                      fit: BoxFit.scaleDown)
                                  .paddingAll(5)),
                        ],
                      ),
                    ),
                  ],
                )
            ],
          ).expand(),
        ],
      ),
    );
  }

  Widget priceWidget() {
    if (!widget.data.serviceDetail!.isFreeService) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // View All Coupons
          if (widget.selectedPackage == null)
            Container(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 0),
              decoration: boxDecorationDefault(color: Colors.white),
              child: Column(
                children: [
                  Row(
                    children: [
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ic_coupon_prefix.iconImage(
                              color: primaryColor, size: 13),
                          Text(language.lblCoupon,
                              style: primaryTextStyle(
                                fontStyle: GoogleFonts.mulish().fontStyle,
                                size: 15,
                                weight: FontWeight.w400,
                                color: Colors.black,
                              )),
                        ],
                      ).expand(),
                      16.width,
                      TextButton(
                        onPressed: () {
                          if (appliedCouponData != null) {
                            showDialog(
                              context: context,
                              builder: (context) => CustomAlertDialog(
                                dialogType: DialogType.DELETE,
                                // title: "",
                                subTitle: language.doYouWantTo,
                                positiveText: language.lblDelete,
                                negativeText: language.lblCancel,
                                negativeTextColor: grey636D77,
                                onAccept: (ctx) {
                                  appliedCouponData = null;
                                  setPrice();
                                  setState(() {});
                                },
                                onCancel: (ctx) {
                                  // Cancel logic
                                },
                              ),
                            );
                          } else {
                            applyCoupon();
                          }
                        },
                        child: appliedCouponData != null
                            ? Text(
                                language.lblRemoveCoupon,
                                style: primaryTextStyle(color: primaryColor),
                              )
                            : Icon(Icons.arrow_forward_ios,
                                color: black1A1D1F, size: 15),
                      )
                    ],
                  ),
                  Divider(height: 1, color: greyE5E8E9), // view Cupons
                ],
              ),
            ),
          //24.height,
          /* Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.priceDetail, style: boldTextStyle(size: LABEL_TEXT_SIZE,color: primaryColor)),
            ],
          ),
          16.height,*/
          Container(
            padding: EdgeInsets.all(16),
            width: context.width(),
            decoration: boxDecorationDefault(color: Colors.white),
            child: Column(
              children: [
                /// Service or Package Price
                Row(
                  children: [
                    Text(language.servicePrice,
                            style: secondaryTextStyle(
                                color: black404040,
                                size: 14,
                                fontStyle: GoogleFonts.mulish().fontStyle,
                                weight: FontWeight.w600))
                        .expand(),
                    16.width,
                    if (widget.selectedPackage != null)
                      PriceWidget(
                          price: bookingAmountModel.finalTotalServicePrice,
                          color: textPrimaryColorGlobal,
                          isBoldText: true)
                    else if (!widget.data.serviceDetail!.isHourlyService)
                      Marquee(
                        child: Row(
                          children: [
                            PriceWidget(
                                price:
                                    widget.data.serviceDetail!.price.validate(),
                                size: 12,
                                isBoldText: false,
                                color: textSecondaryColorGlobal),
                            Text(' * $itemCount  = ',
                                style: secondaryTextStyle()),
                            PriceWidget(
                              price: bookingAmountModel.finalTotalServicePrice,
                              color: black404040,
                              size: 14,
                            ),
                          ],
                        ),
                      )
                    else
                      PriceWidget(
                          price: bookingAmountModel.finalTotalServicePrice,
                          color: textPrimaryColorGlobal,
                          isBoldText: true)
                  ],
                ),

                /// Fix Discount on Base Price
                if (widget.data.serviceDetail!.discount.validate() != 0 &&
                    widget.selectedPackage == null)
                  Column(
                    children: [
                      Divider(height: 26, thickness: 1, color: greyE5E8E9),
                      Row(
                        children: [
                          Text(language.lblDiscount,
                              style: secondaryTextStyle(
                                  size: 14,
                                  fontStyle: GoogleFonts.mulish().fontStyle,
                                  weight: FontWeight.w600,
                                  color: black404040)),
                          Text(
                            " (${widget.data.serviceDetail!.discount.validate()}% ${language.lblOff.toLowerCase()})",
                            style: boldTextStyle(color: Colors.green),
                          ).expand(),
                          16.width,
                          PriceWidget(
                            price: bookingAmountModel.finalDiscountAmount,
                            color: Colors.green,
                            isDiscountedPrice:true,
                            isBoldText: true,
                          ),
                        ],
                      ),
                    ],
                  ),

                /// Coupon Discount on Base Price
                if (widget.selectedPackage == null)
                  Column(
                    children: [
                      if (appliedCouponData != null)
                        // Divider(height: 26, color:greyE5E8E9),
                        16.height.visible(appliedCouponData != null),
                      if (appliedCouponData != null)
                        Row(
                          children: [
                            Row(
                              children: [
                                Text(language.lblCoupon,
                                    style: secondaryTextStyle(
                                        size: 14,
                                        fontStyle:
                                            GoogleFonts.mulish().fontStyle,
                                        weight: FontWeight.w600,
                                        color: black404040)),
                                Text(
                                  " (${appliedCouponData!.code})",
                                  style: boldTextStyle(
                                      color: primaryColor, size: 14),
                                ).onTap(() {
                                  applyCoupon(
                                      isApplied: appliedCouponData!.code
                                          .validate()
                                          .isNotEmpty);
                                }).expand(),
                              ],
                            ).expand(),
                            PriceWidget(
                              price:
                                  bookingAmountModel.finalCouponDiscountAmount,
                              color: Colors.green,
                              isBoldText: true,
                            ),
                          ],
                        ),
                    ],
                  ),

                /// Show Service Add-on Price
                if (serviceAddonStore.selectedServiceAddon
                    .validate()
                    .isNotEmpty)
                  Column(
                    children: [
                      // Divider(height: 1, color: greyE5E8E9),
                      16.height.visible(serviceAddonStore.selectedServiceAddon
                          .validate()
                          .isNotEmpty),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.serviceAddOns,
                                  style: secondaryTextStyle(
                                      size: 14,
                                      fontStyle: GoogleFonts.mulish().fontStyle,
                                      weight: FontWeight.w600,
                                      color: black404040))
                              .flexible(fit: FlexFit.loose),
                          16.width,
                          PriceWidget(
                              price: bookingAmountModel.finalServiceAddonAmount,
                              color: textPrimaryColorGlobal)
                        ],
                      ),
                    ],
                  ),

                /// Show Subtotal, Total Amount and Apply Discount, Coupon if service is Fixed or Hourly
                if (widget.selectedPackage == null)
                Column(
                    children: [
                      // Divider(height: 1, color: greyE5E8E9),
                      16.height.visible(widget.selectedPackage == null),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.discountedPricelabel,
                                  style: secondaryTextStyle(
                                      size: 14,
                                      fontStyle: GoogleFonts.mulish().fontStyle,
                                      weight: FontWeight.w600,
                                      color: black404040))
                              .flexible(fit: FlexFit.loose),
                          16.width,
                          PriceWidget(
                              price: bookingAmountModel.finalSubTotal,
                              color: /*textPrimaryColorGlobal*/ black404040),
                        ],
                      ),
                    ],
                  ),
                 // Service Fee Amount
                Column(
                  children: [
                    // Divider(height: 1, color: greyE5E8E9),
                    16.height.visible(widget.selectedPackage == null),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${language.serviceFee} (${bookingAmountModel.serviceFeeTaxPercentage??0}%)",
                            style: secondaryTextStyle(
                                size: 14,
                                fontStyle: GoogleFonts.mulish().fontStyle,
                                weight: FontWeight.w600,
                                color: black404040))
                            .flexible(fit: FlexFit.loose),
                        16.width,
                        PriceWidget(
                            price: bookingAmountModel.serviceFee??0.0,
                            color: /*textPrimaryColorGlobal*/ black404040),
                      ],
                    ),
                  ],
                ),
                // subtotal Amount i.e Amount after service fee Add
                Column(
                  children: [
                    // Divider(height: 1, color: greyE5E8E9),
                    16.height.visible(widget.selectedPackage == null),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${language.lblSubTotal}",
                            style: secondaryTextStyle(
                                size: 14,
                                fontStyle: GoogleFonts.mulish().fontStyle,
                                weight: FontWeight.w600,
                                color: black404040))
                            .flexible(fit: FlexFit.loose),
                        16.width,
                        PriceWidget(
                            price: bookingAmountModel.priceAfterServiceFee??0.0,
                            color: /*textPrimaryColorGlobal*/ black404040),
                      ],
                    ),
                  ],
                ),

                /// Tax Amount Applied on Price
                Column(
                  children: [
                    // Divider(height: 1, color: greyE5E8E9),
                    16.height,
                    Row(
                      children: [
                        Row(
                          children: [
                            Text(language.lblTax,
                                    style: secondaryTextStyle(
                                        size: 14,
                                        fontStyle:
                                            GoogleFonts.mulish().fontStyle,
                                        weight: FontWeight.w600,
                                        color: black404040))
                                .expand(),
                            /*Icon(Icons.info_outline_rounded,
                                    size: 20, color: context.primaryColor)
                                .onTap(
                              () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) {
                                    return AppliedTaxListBottomSheet(
                                        taxes: widget.data.taxes.validate(),
                                        subTotal:
                                            bookingAmountModel.finalSubTotal);
                                  },
                                );
                              },
                            ),*/
                          ],
                        ).expand(),
                        16.width,
                        PriceWidget(
                            price: bookingAmountModel.taxFeeAmount??0,
                            color: Colors.red,
                            isBoldText: true),
                      ],
                    ),
                  ],
                ),
                /// Final Amount
                Column(
                  children: [
                    Divider(height: 26, color: greyE5E8E9),
                    // 16.height,
                    Row(
                      children: [
                        Text(language.priceTotal,
                                style: secondaryTextStyle(
                                    size: 18,
                                    fontStyle: GoogleFonts.mulish().fontStyle,
                                    weight: FontWeight.w700,
                                    color: black404040))
                            .expand(),
                        PriceWidget(
                          price: bookingAmountModel.finalGrandTotalAmount,
                          color: black404040,
                          size: 18,
                        )
                      ],
                    ),
                  ],
                ),

                /// Advance Payable Amount if it is required by Service Provider
                if (widget.data.serviceDetail!.isAdvancePayment)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(height: 1, color: greyE5E8E9),
                      Row(
                        children: [
                          Row(
                            children: [
                              Text(language.advancePayAmount,
                                  style: secondaryTextStyle(
                                      size: 14,
                                      fontStyle: GoogleFonts.mulish().fontStyle,
                                      weight: FontWeight.w600,
                                      color: black404040)),
                              Text(
                                  " (${widget.data.serviceDetail!.advancePaymentPercentage.validate().toString()}%)  ",
                                  style: boldTextStyle(color: Colors.green)),
                            ],
                          ).expand(),
                          PriceWidget(
                              price: advancePaymentAmount, color: primaryColor),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          )
        ],
      );
    }

    return Offstage();
  }

  Widget buildDateWidget() {
    if (widget.data.serviceDetail!.isSlotAvailable) {
      return Text(widget.data.serviceDetail!.dateTimeVal.validate(),
          style: boldTextStyle(size: 12, color: Colors.black));
    }
    return Text(
        formatBookingDate(widget.data.serviceDetail!.dateTimeVal.validate(),
            format: DATE_FORMAT_3),
        style: boldTextStyle(size: 12, color: Colors.black));
  }

  Widget buildTimeWidget() {
    if (widget.data.serviceDetail!.bookingSlot == null) {
      return Text(
          formatBookingDate(widget.data.serviceDetail!.dateTimeVal.validate(),
              format: HOUR_12_FORMAT),
          style: boldTextStyle(size: 12, color: Colors.black));
    }
    return Text(
        TimeOfDay(
          hour: widget.data.serviceDetail!.bookingSlot
              .validate()
              .splitBefore(':')
              .split(":")
              .first
              .toInt(),
          minute: widget.data.serviceDetail!.bookingSlot
              .validate()
              .splitBefore(':')
              .split(":")
              .last
              .toInt(),
        ).format(context),
        style: boldTextStyle(size: 12, color: Colors.black));
  }

  Widget buildBookingSummaryWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*Text(language.bookingDateAndSlot,
            style: boldTextStyle(size: LABEL_TEXT_SIZE,color:Colors.black)),
        16.height,*/
        widget.data.serviceDetail!.dateTimeVal == null
            ? /*widget show when date is not set */ Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(language.priceTotal,
                          style: boldTextStyle(
                              size: 14,
                              color: black404040,
                              weight: FontWeight.w600,
                              fontFamily: GoogleFonts.mulish().fontFamily)),
                      PriceWidget(
                        price: bookingAmountModel.finalGrandTotalAmount,
                        color: black404040,
                        size: 18,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      handleDateTimePick();
                      },
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 30, right: 30, top: 10, bottom: 10),
                      decoration: boxDecorationWithShadow(
                          backgroundColor: primaryColor,
                          borderRadius: radius(8)),
                      child: Text(language.selectSlot,
                          style: boldTextStyle(
                              size: 16,
                              color: Colors.white,
                              weight: FontWeight.w800,
                              fontFamily: GoogleFonts.mulish().fontFamily)),
                    ),
                  )
                ],
              )
            : /*container show when date set */ Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      decoration: boxDecorationDefault(
                        color: blueE1FFFF.withAlpha(180),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: clock
                          .iconImage(size: 15, color: primaryColor)
                          .paddingAll(6)),
                  10.width,
                  Expanded(
                    child: Row(
                      children: [
                        buildDateWidget(),
                        buildTimeWidget()
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      handleDateTimePick();
                    },
                    child: Text(
                      language.change,
                      style: GoogleFonts.mulish(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                  )
                ],
              )
        /*Container(

                padding: EdgeInsets.all(16),
                decoration: boxDecorationDefault(color: context.cardColor),
                width: context.width(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("${language.lblDate}: ",
                                style: secondaryTextStyle(color:Colors.black)),
                            buildDateWidget(),
                          ],
                        ),
                        8.height,
                        Row(
                          children: [
                            Text("${language.lblTime}: ",
                                style: secondaryTextStyle(color:Colors.black)),
                            buildTimeWidget(),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: ic_edit_square.iconSvgImage(size: 18,color: Colors.orange),
                      visualDensity: VisualDensity.compact,
                      onPressed: () async {
                        handleDateTimePick();
                      },
                    )
                  ],
                ),
              )*/
        ,
      ],
    );
  }

  Widget packageWidget() {
    if (widget.selectedPackage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.package, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
          16.height,
          Container(
            padding: EdgeInsets.all(16),
            decoration: boxDecorationDefault(color: context.cardColor),
            width: context.width(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Marquee(
                            child: Text(widget.selectedPackage!.name.validate(),
                                style: boldTextAutoStyle(
                                    context: context,
                                    commonColor: black1A1C1E))),
                        4.height,
                        Row(
                          children: [
                            Text(language.includedServices,
                                style: secondaryTextStyle()),
                            8.width,
                            ic_info.iconImage(size: 20),
                          ],
                        ),
                      ],
                    ).expand(),
                    16.width,
                    CachedImageWidget(
                      url: widget.selectedPackage!.imageAttachments
                          .validate()
                          .isNotEmpty
                          ? widget.selectedPackage!.imageAttachments!.first
                          .validate()
                          : '',
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ).cornerRadiusWithClipRRect(defaultRadius),
                  ],
                ).onTap(
                      () {
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      isScrollControlled: true,
                      isDismissible: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: radiusOnly(
                              topLeft: defaultRadius, topRight: defaultRadius)),
                      builder: (_) {
                        return DraggableScrollableSheet(
                          initialChildSize: 0.50,
                          minChildSize: 0.2,
                          maxChildSize: 1,
                          builder: (context, scrollController) =>
                              PackageInfoComponent(
                                  packageData: widget.selectedPackage!,
                                  scrollController: scrollController),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Offstage();
  }


  Future<void> showAddressBottomSheet(BuildContext context, Function(String) onAddressSelected) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => AddressBottomSheetWidget(onAddressSelected: onAddressSelected),
    );
  }

  /*void showBookingConfirmedBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 30),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green.shade100,
                  child: Icon(Icons.check, color: Colors.green, size: 50),
                ),
                SizedBox(height: 25),
                Text(
                  "Booking Confirmed\nSuccessfully",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Congratulations\nyour booking has been confirmed",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Color(0xFF00B0B9), // custom gradient-style teal
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Done",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }*/
}
