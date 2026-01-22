import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_service_user/utils/colors.dart';
import 'package:home_service_user/utils/savedAddress/places_response.dart';
import 'package:home_service_user/utils/string_extensions.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../network/rest_apis.dart';
import '../common.dart';
import '../constant.dart' as Constants;
import '../images.dart';
import 'address_model.dart';
import 'address_storage.dart';
import 'latlong_response.dart'; // Your model file

class AddressBottomSheetWidget extends StatefulWidget {
  final Function(String) onAddressSelected;

  const AddressBottomSheetWidget({super.key, required this.onAddressSelected});

  @override
  State<AddressBottomSheetWidget> createState() =>
      _AddressBottomSheetWidgetState();
}

class _AddressBottomSheetWidgetState extends State<AddressBottomSheetWidget> {
  TextEditingController addressController = TextEditingController();
  TextEditingController labelController = TextEditingController();

  String selectedLabel = 'Home';
  List<String> labels = ['Home', 'Office', 'Other'];
  List<AddressModel> addressList = [];
  List<AddressModel> locationPlaceList = [];
  bool showAdress = false;
  AddressModel selectedAddressModel = AddressModel();

  @override
  void initState() {
    super.initState();
    _getaddressApi();
  }

  /*Future<void> _loadAddressList() async {
   // addressList = await getAddressList();
    getAddressApi();

  }*/

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible:!showAdress ,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10, left: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select Address',
                            style: GoogleFonts.mulish(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            )),
                        GestureDetector(
                          onTap: (){
                           finish(context);
                          },
                            child: close_cross.iconImageSimple(size: 18).paddingOnly(left: 20,right: 20,top: 20,bottom: 8)),
                      ],
                    ),
                  ),// select address test and cross  Icon
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 24,vertical: 0),
                    child: Divider(color: greyE5E8E9, thickness: 1),
                  ), // Divider
                  Container(
                    height: 350,
                    padding: EdgeInsets.all(16),
                    child: addressList.isEmpty
                        ? Center(child: Text('No addresses saved yet', style: secondaryTextStyle()))
                        : ListView.builder(
                      shrinkWrap: true,
                     // physics: NeverScrollableScrollPhysics(),
                      itemCount: addressList.length,
                      itemBuilder: (context, index) {
                        final address = addressList[index];
                        return GestureDetector(
                          onTap: (){
                            widget.onAddressSelected(address.address??address.placeName??"");
                            finish(context);
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                              width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                            alignment:Alignment.topLeft,
                                  child: Text("Provide service here:",
                                    style: GoogleFonts.mulish(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    SizedBox(
                                      height:50,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          (address.label==labels[0]? u_home_alt:u_building).iconImageSimple(size: 15)

                                        ],
                                      ),
                                    ),
                                   SizedBox(width: 10,),
                                   Expanded(
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       mainAxisSize: MainAxisSize.max,
                                       children: [
                                         Text(address.label??"",
                                           style: GoogleFonts.mulish(
                                             fontSize: 14,
                                             fontWeight: FontWeight.w600,
                                             color: black494C61,
                                           ),
                                           textAlign: TextAlign.center,
                                         ),
                                         Text(address.address??"",
                                           style: GoogleFonts.mulish(
                                             fontSize: 12,
                                             fontWeight: FontWeight.w500,
                                             color: black7A869A,
                                           ),
                                           maxLines: 1,
                                           overflow: TextOverflow.ellipsis,
                                           textAlign: TextAlign.left,
                                         ),


                                       ],
                                     ),
                                   )
                                  ],
                                )
                              ],
                            )
                          ),
                        );
                      },
                    ),
                  ),
                  AppButton(
                     margin: EdgeInsets.only(left: 20,right:20,bottom: 20),
                          text: 'Add New Address',
                          color: primaryColor,
                          onTap: () async {
                            showAdress = !showAdress;
                            setState(() {

                            });

                          },
                          width: context.width(),
                        ),
                ],
              ),
            ),
            Visibility(
              visible:showAdress,
              child: Container(
                height: 450,
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Add New Address', style: boldTextStyle(fontStyle: GoogleFonts.mulish().fontStyle,
                    weight: FontWeight.w700,
                    color: black1A1C1E)),
                    8.height,
                    AppTextField(
                      textFieldType: TextFieldType.MULTILINE,
                      controller: addressController,
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
                      spacingBetweenTitleAndTextFormField:10,
                      errorThisFieldRequired: language.requiredText,
                      decoration: inputDecoration(context),
                      onChanged:  (value) =>{
                        fetchPlacesAutocomplete(value)
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return language.requiredText; // Show error if empty
                        }
                        return null; // No error
                      },
                    ),

                    8.height,
                    DropdownButtonFormField<String>(
                      value: selectedLabel,
                      items: labels
                          .map((label) =>
                          DropdownMenuItem(value: label, child: Text(label)))
                          .toList(),
                      onChanged: (val) {
                        if (val == 'Other') {
                          labelController.text = '';
                        }
                        setState(() => selectedLabel = val!);
                      },
                      decoration: inputDecoration(context,labelText: 'Label'),
                    ),
                    if (selectedLabel == 'Other')
                      AppTextField(
                        textFieldType: TextFieldType.NAME,
                        controller: labelController,
                        title:language.customlabel ,
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
                        spacingBetweenTitleAndTextFormField:10,
                        errorThisFieldRequired: language.requiredText,
                        decoration: inputDecoration(context),

                      ),

                    16.height,
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ListView.builder(
                          //physics: NeverScrollableScrollPhysics(),
                          //scrollDirection: Axis.vertical,
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: locationPlaceList.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    addressController.text=locationPlaceList[index].placeName ?? "";
                                    selectedAddressModel.placeName=locationPlaceList[index].placeName ?? "";
                                    selectedAddressModel.placeId=locationPlaceList[index].placeId ?? "";
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        // todo check
                                        /*SvgPicture.asset(
                                          Images.locationListIcon,
                                          height: 14,
                                          width: 14,
                                        ),*/
                                        const SizedBox(width: 18),
                                        Expanded(
                                          child: Text(

                                                  locationPlaceList[index]
                                                  .placeName ??
                                                  "",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xff424242),
                                                  letterSpacing: 1.0)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                  child: const Divider(
                                      color: Color(0xffEEEEEE),
                                      height: 1,
                                      thickness: 1),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    16.height,
                    AppButton(
                      text: 'Save Address',
                      color: primaryColor,
                      onTap: () async {
                        String labelToSave = selectedLabel == 'Other'
                            ? labelController.text.trim()
                            : selectedLabel;
                        if (addressController.text.trim().isEmpty ||
                            labelToSave.isEmpty) {
                          toast('Please enter both address and label');
                          return;
                        }

                        addressList.add(AddressModel(
                          label: labelToSave,
                          address: addressController.text.trim(),
                          placeId:selectedAddressModel.placeId,
                          placeName: selectedAddressModel.placeName
                        ));

                        selectedAddressModel.label=labelToSave;
                        selectedAddressModel.address=addressController.text.trim();
                        getPlaceDetails(selectedAddressModel);


                       // await saveAddressList(addressList);
                        showAdress = !showAdress;
                        setState(() {});
                        },
                      width: context.width(),
                    ),  // Save  Address Button
                  ],

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
     // Fetch place for user Enter Text
  Future fetchPlacesAutocomplete(String input) async {
    locationPlaceList.clear();
    final url =
    Uri.parse("https://places.googleapis.com/v1/places:autocomplete");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": Constants.googleApiKey,
      },
      body: jsonEncode({"input": input}),
    );

    if (response.statusCode == 200) {
      //print("Response: ${response.body}");
      final data = jsonDecode(response.body);

      // Extract place names
      final List<Map<String, dynamic>> places = (data['suggestions'] as List)
          .map((suggestion) => {
        "placeId": suggestion["placePrediction"]["placeId"],
        "text": suggestion["placePrediction"]["text"]["text"]
      }).toList();

      for (var place in places) {
        PlacesResponse placesResponse = PlacesResponse();
        placesResponse.placeId = place['placeId'];
        placesResponse.placeName = place['text'];

        AddressModel addressModel = AddressModel();
        addressModel.placeId =placesResponse.placeId;
        addressModel.placeName = placesResponse.placeName;
        locationPlaceList.add(addressModel);
        setState(() {

        });
      }
      //locationList.value = placeNames;
    } else {
      setState(() {
        locationPlaceList.clear();
      });
    }
  }
    // Fetch lat long for save address
  Future  getPlaceDetails(AddressModel addressModel) async {
    final String apiKey = Constants.googleApiKey; // Replace with your API key
    final String url = "https://places.googleapis.com/v1/places/${addressModel.placeId}";

    final response = await http.get(
      Uri.parse(
          "$url?key=$apiKey&fields=id,displayName,formattedAddress,location"),
      headers: {"X-Goog-Api-Key": apiKey},
    );

    if (response.statusCode == 200) {
      if (response.body != null) {
        final data = jsonDecode(response.body);
        LatLongResponse latLongResponse = LatLongResponse.fromJson(data);
            selectedAddressModel.latitude= latLongResponse.location?.latitude;
            selectedAddressModel.longitude= latLongResponse.location?.longitude;
            await addAddressApi( addressModel: selectedAddressModel);
      }

    } else {
      throw Exception("Failed to fetch place details");
    }

  }


  Future<void> addAddressApi({required AddressModel addressModel}) async {
    appStore.setLoading(true);

    Map<String, dynamic> req = {
      "address": addressModel.placeName,
      "label": addressModel.label,
      "latitude": addressModel.latitude,
      "longitude": addressModel.longitude,
    };

    await addAddress(req).then((value) {
      setState(() {});
      appStore.setLoading(false);
      toast(value.message.validate(), print: true);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future <void> _getaddressApi() async {
    appStore.setLoading(true);
    addressList.clear();
     try{
       addressList = await getaddressList();
       saveAddressList(addressList);
       setState(() {});
     }catch(e){
       addressList = await getAddressList(); // this fetch address  from shared prefrence
       appStore.setLoading(false);
       toast(e.toString(), print: true);
     } finally {
       appStore.setLoading(false);
     }
  }

}
/*
* This is curl for update and delete address which is not in figma so not implemented
* update :
curl --location --request PUT 'https://handymanservice.ongraph.com/api/user-addresses/2' \
--header 'Authorization: Bearer 360|jmKJTF3hLnp7BFbZnSCpGjSk5KYm7a3YvkQfvi8d' \
--header 'Content-Type: application/json' \
--data '{
    "address": "3 jain bhawan",
    "label": "other",
    "latitude": "26.912434",
    "longitude": "75.787270"
}'
Show options…
delete :
curl --location --request DELETE 'https://handymanservice.ongraph.com/api/user-addresses/2' \
--header 'Authorization: Bearer 360|jmKJTF3hLnp7BFbZnSCpGjSk5KYm7a3YvkQfvi8d' \
--header 'Content-Type: application/json'
*
*
* */