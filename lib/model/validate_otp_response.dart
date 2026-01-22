
import 'messegeModel.dart';

class ValidateOtpResponse {
  MessageModel? message;

  ValidateOtpResponse({this.message});

  factory ValidateOtpResponse.fromJson(Map<String, dynamic> json) {
    return ValidateOtpResponse(
      message: json['message'] != null
          ? MessageModel.fromJson(json['message'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (message != null) {
      data['message'] = message!.toJson();
    }
    return data;
  }
}