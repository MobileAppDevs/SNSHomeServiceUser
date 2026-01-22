import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../model/booking_amount_model.dart';
import '../model/extra_charges_model.dart';
import '../model/package_data_model.dart';
import '../model/service_data_model.dart';
import '../model/service_detail_response.dart';
import 'constant.dart';

BookingAmountModel finalCalculations({
  num servicePrice = 0,
  int durationDiff = 0,
  int quantity = 1,
  List<TaxData>? taxes,
  CouponData? appliedCouponData,
  List<ExtraChargesModel>? extraCharges,
  List<Serviceaddon>? serviceAddons,
  BookingPackage? selectedPackage,
  num discount = 0,
  String serviceType = SERVICE_TYPE_FIXED,
  String bookingType = BOOKING_TYPE_SERVICE,
}) {
  if (quantity == 0) quantity = 1;
  BookingAmountModel data = BookingAmountModel();

  if (selectedPackage != null) {
    data.finalTotalServicePrice = selectedPackage.price
        .validate()
        .toStringAsFixed(appConfigurationStore.priceDecimalPoint)
        .toDouble();
  } else {
    if (serviceType == SERVICE_TYPE_HOURLY) {
      data.finalTotalServicePrice = hourlyCalculation(
          price: servicePrice.validate(),
          secTime: durationDiff.validate().toInt());
    } else {
      data.finalTotalServicePrice = (servicePrice * quantity)
          .toStringAsFixed(appConfigurationStore.priceDecimalPoint)
          .toDouble();
    }
  }

  data.finalDiscountAmount = selectedPackage == null && discount != 0
      ? ((data.finalTotalServicePrice / 100) * discount)
          .toStringAsFixed(appConfigurationStore.priceDecimalPoint)
          .toDouble()
      : 0;

  data.finalCouponDiscountAmount = appliedCouponData != null
      ? calculateCouponDiscount(
          couponData: appliedCouponData, price: data.finalTotalServicePrice)
      : 0;

  data.finalServiceAddonAmount =
      serviceAddons.validate().sumByDouble((e) => e.price);

  data.finalSubTotal = (data.finalTotalServicePrice -
          data.finalDiscountAmount -
          data.finalCouponDiscountAmount +
          data.finalServiceAddonAmount)
      .toStringAsFixed(appConfigurationStore.priceDecimalPoint)
      .toDouble();

  num totalExtraCharges = extraCharges
      .validate()
      .sumByDouble((e) => e.price.validate() * e.qty.validate(value: 1));

  data.finalTotalTax =
      calculateTotalTaxAmount(taxes, data.finalSubTotal + totalExtraCharges);

  data.finalGrandTotalAmount =
      (data.finalSubTotal + data.finalTotalTax + totalExtraCharges)
          .toStringAsFixed(appConfigurationStore.priceDecimalPoint)
          .toDouble();
  // changes required for representaion ask by client

  num serviceFee = calculateServiceFeeAmount(taxes, data.finalSubTotal);
  data.serviceFee = serviceFee;
  data.serviceFeeTaxPercentage = calculateserviceFeeTaxPercentage(taxes);
  num priceAfterServiceFee = data.finalSubTotal + serviceFee;
  data.priceAfterServiceFee = priceAfterServiceFee;

  data.taxFeeAmount = calculateTaxFeeAmount(taxes, priceAfterServiceFee);

  return data;
}

num calculateCouponDiscount(
    {CouponData? couponData, num price = 0, ServiceData? detail}) {
  num couponAmount = 0.0;

  if (couponData != null) {
    if (couponData.discountType.validate() == COUPON_TYPE_FIXED) {
      couponAmount = couponData.discount.validate();
    } else {
      couponAmount = (price * couponData.discount.validate()) / 100;
    }
  }

  return couponAmount
      .toStringAsFixed(appConfigurationStore.priceDecimalPoint)
      .toDouble();
}

num calculateTotalTaxAmount(List<TaxData>? taxes, num subTotal) {
  num taxAmount = 0.0;
  num cumlativeTaxOnsubTotal = subTotal;
  taxes.validate().forEach((element) {
    if (element.type == TAX_TYPE_PERCENT) {
      element.totalCalculatedValue =
          cumlativeTaxOnsubTotal * element.value.validate() / 100;
      cumlativeTaxOnsubTotal =
          element.totalCalculatedValue.validate() + cumlativeTaxOnsubTotal;
    } else {
      element.totalCalculatedValue = element.value.validate();
    }
    taxAmount += element.totalCalculatedValue
        .validate()
        .toStringAsFixed(appConfigurationStore.priceDecimalPoint)
        .toDouble();
  });

  return taxAmount
      .toStringAsFixed(appConfigurationStore.priceDecimalPoint)
      .toDouble();
}

num calculateServiceFeeAmount(List<TaxData>? taxes, num subTotal) {
  num serviceFee = 0.0;
  num subTotalAmount = subTotal;
  taxes.validate().forEach((element) {
    if (element.type == TAX_TYPE_PERCENT &&
        element.title! /*.toLowerCase()*/ == "Service Fee") {
      serviceFee += subTotalAmount * element.value.validate() / 100;
    }
  });

  return serviceFee;
}

num calculateserviceFeeTaxPercentage(List<TaxData>? taxes) {
  num serviceFeePercentage = 0.0;
  taxes.validate().forEach((element) {
    if (element.type == TAX_TYPE_PERCENT &&
        element.title! /*.toLowerCase()*/ == "Service Fee") {
      serviceFeePercentage += element.value.validate();
    }
  });
  return serviceFeePercentage;
}

num calculateTaxFeeAmount(List<TaxData>? taxes, num subTotal) {
  num taxFee = 0.0;
  num subTotalAmount = subTotal;
  taxes.validate().forEach((element) {
    if (element.type == TAX_TYPE_PERCENT &&
        element.title!.toLowerCase() != "service tax") {
      taxFee += subTotalAmount * element.value.validate() / 100;
    }
  });
  return taxFee;
}

num hourlyCalculation({required int secTime, required num price}) {
  int totalOneHourSeconds = 3600;
  num totalMinutes = 0;

  /// Calculating per minute charge for the price [Price is Dynamic].
  num perMinuteCharge = price / 60;

  /// Check if booking time is less than one hour
  if (secTime <= totalOneHourSeconds) {
    totalMinutes = totalOneHourSeconds / 60;
  } else {
    /// Calculate total minutes including hours
    totalMinutes = secTime / 60;
  }

  return (totalMinutes * perMinuteCharge)
      .toStringAsFixed(appConfigurationStore.priceDecimalPoint)
      .toDouble();
}
