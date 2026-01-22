class StripeResponse {
  String? status;
  String? stripeOnboardingUrl;

  StripeResponse({this.status, this.stripeOnboardingUrl});

  StripeResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    stripeOnboardingUrl = json['stripe_onboarding_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['stripe_onboarding_url'] = this.stripeOnboardingUrl;
    return data;
  }
}