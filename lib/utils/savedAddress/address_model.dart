class AddressModel {
  String? label;
  String? address;
  String? placeId;
  String? placeName;
  double? latitude;
  double? longitude;
  int? id;
  int? userId;
  String? createdAt;
  String? updatedAt;

  AddressModel({ this.label,
    this.address,
    this.placeId,
    this.placeName,
    this.latitude,
    this.longitude,
    this.id,
    this.userId,
    this.createdAt,
    this.updatedAt});

  Map<String, dynamic> toJson() => {
    'label': label,
    'address': address,
    'placeId': placeId,
    'placeName': placeName,
    'latitude': latitude,
    'longitude': longitude,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'id': id,
    'user_id': userId,

  };

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      AddressModel(
          label: json['label'],
          address: json['address'],
          placeId: json['placeId'],
          placeName: json['placeName'],
          /*latitude: json['latitude'],
          longitude: json['longitude'],*/
          latitude: double.tryParse(json['latitude'].toString()),
          longitude: double.tryParse(json['longitude'].toString()),
          createdAt: json['created_at'],
          updatedAt: json['updated_at'],
          id: json['id'],
          userId: json['user_id'],
      );


}
