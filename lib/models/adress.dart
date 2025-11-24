class Address {
  final String location;
  final String districtName;
  final String streetName;

  Address({
    required this.location,
    required this.districtName,
    required this.streetName,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      location: json['location'],
      districtName: json['district_name'],
      streetName: json['street_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'district_name': districtName,
      'street_name': streetName,
    };
  }
}
