
import 'package:home_service_user/model/strip_response.dart';

class MessageModel {
  String? message;
  StripeResponse? stripeResponse;
  String? apiToken;

  MessageModel({this.message, this.stripeResponse,this.apiToken});

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      message: json['message'],
      apiToken: json['api_token'],
      stripeResponse: json['stripe_response'] != null
          ? StripeResponse.fromJson(json['stripe_response'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = this.message;
    data['api_token'] = this.apiToken;
    if (stripeResponse != null) {
      data['stripe_response'] = stripeResponse!.toJson();
    }
    return data;
  }
}
