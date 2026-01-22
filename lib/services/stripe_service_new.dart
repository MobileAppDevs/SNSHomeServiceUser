import 'dart:convert';

//import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../model/payment_gateway_response.dart';
import '../model/stripe_pay_model.dart';
import '../network/network_utils.dart';
import '../utils/colors.dart';
import '../utils/common.dart';
import '../utils/configs.dart';

class StripeServiceNew {
  late PaymentSetting paymentSetting;
  num totalAmount = 0;
  int bookingId=0;
  late Function(Map<String, dynamic>) onComplete;

  StripeServiceNew({
    required PaymentSetting paymentSetting,
    required num totalAmount,
    required Function(Map<String, dynamic>) onComplete,
    required int bookingId,
  }) {
    this.paymentSetting = paymentSetting;
    this.totalAmount = totalAmount;
    this.onComplete = onComplete;
    this.bookingId = bookingId;
  }

  //StripPayment

  /*Future<dynamic> stripePay() async {
    String stripePaymentKey = '';
    String stripeURL = '';
    String stripePaymentPublishKey = '';

    log("stripe--------------${paymentSetting.testValue?.stripeKey ?? ""}");

    if (paymentSetting.isTest == 1) {
      stripePaymentKey = paymentSetting.testValue?.stripeKey ?? "";
      stripeURL = paymentSetting.testValue?.stripeUrl ?? "";
      stripePaymentPublishKey = paymentSetting.testValue?.stripePublickey ?? "";
    } else {
      stripePaymentKey = paymentSetting.liveValue?.stripeKey ?? "";
      stripeURL = paymentSetting.liveValue?.stripeUrl ?? "";
      stripePaymentPublishKey = paymentSetting.liveValue?.stripePublickey ?? "";
    }

    if (stripePaymentKey.isEmpty || stripeURL.isEmpty || stripePaymentPublishKey.isEmpty) {
      throw language.accessDeniedContactYourAdmin;
    }

    try {
      Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
      Stripe.publishableKey = stripePaymentPublishKey;

      await Stripe.instance.applySettings();

      var request = http.Request(HttpMethodType.POST.name, Uri.parse(stripeURL));
      request.bodyFields = {
        'amount': '${(totalAmount * 100).toInt()}',
        'currency': await isIqonicProduct
            ? STRIPE_CURRENCY_CODE
            : '${appConfigurationStore.currencyCode}',
        'description': 'Name: ${appStore.userFullName} - Email: ${appStore.userEmail}',
        'booking_id': bookingId.toString(),
      };
      request.headers.addAll(buildHeaderForStripe(stripePaymentKey));

      log('URL: ${request.url}');
      log('Header: ${request.headers}');
      log('Request: ${request.bodyFields}');

      appStore.setLoading(true);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 *//* or your custom isSuccessful()*//* ) {
        StripePayModel res = StripePayModel.fromJson(jsonDecode(response.body));

        var setupPaymentSheetParameters = SetupPaymentSheetParameters(
          paymentIntentClientSecret: res.clientSecret.validate(),
          style: appThemeMode,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(primary: primaryColor),
          ),
          applePay: PaymentSheetApplePay(merchantCountryCode: STRIPE_MERCHANT_COUNTRY_CODE),
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: STRIPE_MERCHANT_COUNTRY_CODE,
            testEnv: paymentSetting.isTest == 1,
          ),
          merchantDisplayName: APP_NAME,
          customerId: appStore.userId.toString(),
          customerEphemeralKeySecret: isAndroid ? res.clientSecret.validate() : null, // validate backend
          setupIntentClientSecret: res.clientSecret.validate(),
          billingDetails: BillingDetails(
            name: appStore.userFullName,
            email: appStore.userEmail,
          ),
        );

        await Stripe.instance.initPaymentSheet(paymentSheetParameters: setupPaymentSheetParameters);
        await Stripe.instance.presentPaymentSheet();
        onComplete.call({'transaction_id': res.id});
      } else {
        throw errorSomethingWentWrong;
      }
    } catch (e) {
      toast(e.toString(), print: true);
      throw errorSomethingWentWrong;
    } finally {
      appStore.setLoading(false);
    }
  }*/

  Future<void> stripePay() async {
    // 1. Fetch Stripe keys from settings
    final stripeSecretKey = paymentSetting.isTest == 1
        ? paymentSetting.testValue?.stripeKey
        : paymentSetting.liveValue?.stripeKey;

    final stripePublishableKey = paymentSetting.isTest == 1
        ? paymentSetting.testValue?.stripePublickey
        : paymentSetting.liveValue?.stripePublickey;

    final stripeURL = paymentSetting.isTest == 1
        ? paymentSetting.testValue?.stripeUrl??""
        : paymentSetting.liveValue?.stripeUrl??"";                               ;


    if (stripeSecretKey == null || stripePublishableKey == null) {
      throw "Stripe keys not configured";
    }

    // 2. Initialize Stripe with publishable key
    Stripe.publishableKey = stripePublishableKey;
    await Stripe.instance.applySettings();

    try {
      // 3. Call YOUR BACKEND to create PaymentIntent
      final response = await http.post(
       // Uri.parse('https://handymanservice.ongraph.com/api/create-ideal-payment'),
        Uri.parse(stripeURL), // Replace with your endpoint
        headers: {
          'Authorization':'Bearer ${appStore.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'total_amount': (totalAmount * 100).toInt(),//12070
          'amount': (totalAmount),//120 // Amount in cents
          'currency': appConfigurationStore.currencyCode ?? 'EUR',
          'booking_id': bookingId.toString(),
        }),
      );
      print(response.body.toString());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(response.body.toString());
        final clientSecret = data['client_secret'] as String; // Get PaymentIntent secret
        final paymentIntentId = data['payment_intent_id'] as String; // Get PaymentIntent secret
        // 4. Initialize Payment Sheet with CORRECT clientSecret
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret, // ✅ Use the PaymentIntent secret
            merchantDisplayName: APP_NAME,
            /*applePay: PaymentSheetApplePay(
              merchantCountryCode: STRIPE_MERCHANT_COUNTRY_CODE,
            ),
            googlePay: PaymentSheetGooglePay(
              merchantCountryCode: STRIPE_MERCHANT_COUNTRY_CODE,
              testEnv: paymentSetting.isTest == 1,
            ),*/
          ),
        );

        // 5. Show payment sheet
        await Stripe.instance.presentPaymentSheet();
        onComplete.call({'transaction_id': paymentIntentId}); // Replace with actual ID
      } else {
        throw "Failed to create PaymentIntent";
      }
    } catch (e) {
      print('Payment Error: $e');
      //showErrorDialog(context, e.toString());
      toast("Payment failed: ${e.toString()}");
      rethrow;
    } finally {
      appStore.setLoading(false);
    }
  }
}
