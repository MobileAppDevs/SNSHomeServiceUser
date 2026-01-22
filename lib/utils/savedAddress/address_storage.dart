import 'dart:convert';
import 'package:nb_utils/nb_utils.dart';
import 'address_model.dart';

Future<void> saveAddressList(List<AddressModel> list) async {
  await setValue('address_list', jsonEncode(list.map((e) => e.toJson()).toList()));
}

Future<List<AddressModel>> getAddressList() async {
  final jsonString = getStringAsync('address_list');
  if (jsonString.isEmpty) return [];
  final List decoded = jsonDecode(jsonString);
  return decoded.map((e) => AddressModel.fromJson(e)).toList();
}

