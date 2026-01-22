import 'extra_charges_model.dart';

class BookingAmountModel {
  num finalTotalServicePrice;
  num finalTotalTax;
  num finalSubTotal;
  num finalServiceAddonAmount;
  num finalDiscountAmount;
  num finalCouponDiscountAmount;
  num finalGrandTotalAmount;
  num? discountedPrice;
  num? serviceFee;
  num? serviceFeeTaxPercentage;
  num? priceAfterServiceFee;
  num? taxFeeAmount;


  BookingAmountModel({
    this.finalTotalServicePrice = 0,
    this.finalTotalTax = 0,
    this.finalSubTotal = 0,
    this.finalServiceAddonAmount = 0,
    this.finalDiscountAmount = 0,
    this.finalCouponDiscountAmount = 0,
    this.finalGrandTotalAmount = 0,
    this.discountedPrice = 0,
    this.serviceFee = 0,
    this.priceAfterServiceFee = 0,
    this.taxFeeAmount = 0,
    this.serviceFeeTaxPercentage = 0,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['final_total_service_price'] = this.finalTotalServicePrice;
    data['final_total_tax'] = this.finalTotalTax;
    data['final_sub_total'] = this.finalSubTotal;
    data['final_discount_amount'] = this.finalDiscountAmount;
    data['final_coupon_discount_amount'] = this.finalCouponDiscountAmount;
    return data;
  }

  Map<String, dynamic> toBookingUpdateJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['final_total_service_price'] = this.finalTotalServicePrice;
    data['final_total_tax'] = this.finalTotalTax;
    data['final_sub_total'] = this.finalSubTotal;
    data['final_discount_amount'] = this.finalDiscountAmount;
    data['final_coupon_discount_amount'] = this.finalCouponDiscountAmount;
    data['total_amount'] = this.finalGrandTotalAmount;
    return data;
  }
}
