import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart' as Constants;
import '../../../utils/images.dart';
import '../../../utils/savedAddress/latlong_response.dart';
import '../../../utils/savedAddress/places_response.dart';

import '../../../services/location_service.dart';

class DashboardLocationBottomSheet extends StatefulWidget {
  final VoidCallback? callback;

  DashboardLocationBottomSheet({this.callback});

  @override
  _DashboardLocationBottomSheetState createState() => _DashboardLocationBottomSheetState();
}

class _DashboardLocationBottomSheetState extends State<DashboardLocationBottomSheet> {
  TextEditingController searchController = TextEditingController();
  List<PlacesResponse> predictionList = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radiusOnly(topLeft: 20, topRight: 20),
        backgroundColor: context.cardColor,
      ),
      constraints: BoxConstraints(
        maxHeight: context.height() * 0.8,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Use Current Location",
                  style: boldTextStyle(color: primaryColor),
                ).onTap(() async {
                  await _useCurrentLocation();
                }),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    finish(context);
                  },
                ),
              ],
            ).paddingAll(16),
            AppTextField(
              controller: searchController,
              textFieldType: TextFieldType.OTHER,
              decoration: inputDecoration(context, hint: "Enter valid address"),
              title:language.address,
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
              onChanged: (value) {
                if (value.length > 2) {
                  fetchPlacesAutocomplete(value);
                } else {
                  predictionList.clear();
                  setState(() {});
                }
              },
            ).paddingSymmetric(horizontal: 16),
            if (predictionList.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: predictionList.length,
                itemBuilder: (context, index) {
                  PlacesResponse data = predictionList[index];
                  return ListTile(
                    title: Text(data.placeName.validate(), style: primaryTextStyle(color: textPrimaryColor)),
                    onTap: () async {
                      await _onPredictionSelected(data);
                    },
                  );
                },
              ),
             if (predictionList.isEmpty)
               SizedBox(height: 200).visible(searchController.text.isNotEmpty),
               
             if (predictionList.isEmpty && searchController.text.isEmpty)
               SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    appStore.setLoading(true);
    await getUserLocationPosition().then((value) async {
      await appStore.setCurrentLocation(true);
      await appStore.setLatitude(value.latitude);
      await appStore.setLongitude(value.longitude);
      await setValue(Constants.LATITUDE, value.latitude);
      await setValue(Constants.LONGITUDE, value.longitude);
      
      await getUserLocation(); // Fetch address string and update current address in store/prefs
      
      appStore.setLoading(false);
      widget.callback?.call();
      finish(context);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  Future<void> fetchPlacesAutocomplete(String input) async {
    predictionList.clear();
    final url = Uri.parse("https://places.googleapis.com/v1/places:autocomplete");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": Constants.googleApiKey,
      },
      body: jsonEncode({"input": input}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> suggestions = data['suggestions'] ?? [];
      
      predictionList = suggestions.map((suggestion) {
        return PlacesResponse(
          placeId: suggestion["placePrediction"]["placeId"],
          placeName: suggestion["placePrediction"]["text"]["text"],
        );
      }).toList();
      
      setState(() {});
    }
  }

  Future<void> _onPredictionSelected(PlacesResponse place) async {
    appStore.setLoading(true);
    final String apiKey = Constants.googleApiKey;
    final String url = "https://places.googleapis.com/v1/places/${place.placeId}";

    final response = await http.get(
      Uri.parse("$url?key=$apiKey&fields=id,displayName,formattedAddress,location"),
      headers: {"X-Goog-Api-Key": apiKey},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      LatLongResponse latLongResponse = LatLongResponse.fromJson(data);

      if (latLongResponse.location != null) {
        await appStore.setLatitude(latLongResponse.location!.latitude!);
        await appStore.setLongitude(latLongResponse.location!.longitude!);
        await setValue(Constants.LATITUDE, latLongResponse.location!.latitude!);
        await setValue(Constants.LONGITUDE, latLongResponse.location!.longitude!);

        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            latLongResponse.location!.latitude!,
            latLongResponse.location!.longitude!,
          );

          if (placemarks.isNotEmpty) {
            Placemark place = placemarks[0];
            String address = '';

            if (!place.name.isEmptyOrNull && !place.street.isEmptyOrNull && place.name != place.street) address = '${place.name.validate()}, ';
            if (!place.street.isEmptyOrNull) address = '$address${place.street.validate()}';
            if (!place.locality.isEmptyOrNull) address = '$address, ${place.locality.validate()}';
            if (!place.administrativeArea.isEmptyOrNull) address = '$address, ${place.administrativeArea.validate()}';
            if (!place.postalCode.isEmptyOrNull) address = '$address, ${place.postalCode.validate()}';
            if (!place.country.isEmptyOrNull) address = '$address, ${place.country.validate()}';

            await setValue(Constants.CURRENT_ADDRESS, address);
            
            await appStore.setCurrentLocation(false);
            await appStore.setCurrentLocation(true);
          }
        } catch (e) {
          log("Error fetching placemark: $e");
        }

        appStore.setLoading(false);
        widget.callback?.call();
        finish(context);
      }
    } else {
      appStore.setLoading(false);
      toast("Failed to fetch location details");
    }
  }
}
