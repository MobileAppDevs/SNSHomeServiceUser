class LatLongResponse {
  String? id;
  String? formattedAddress;
  Location? location;
  DisplayName? displayName;

  LatLongResponse(
      {this.id, this.formattedAddress, this.location, this.displayName});

  LatLongResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    formattedAddress = json['formattedAddress'];
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    displayName = json['displayName'] != null
        ? new DisplayName.fromJson(json['displayName'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['formattedAddress'] = this.formattedAddress;
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    if (this.displayName != null) {
      data['displayName'] = this.displayName!.toJson();
    }
    return data;
  }
}

class Location {
  double? latitude;
  double? longitude;

  Location({this.latitude, this.longitude});

  Location.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}

class DisplayName {
  String? text;
  String? languageCode;

  DisplayName({this.text, this.languageCode});

  DisplayName.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    languageCode = json['languageCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['languageCode'] = this.languageCode;
    return data;
  }
}