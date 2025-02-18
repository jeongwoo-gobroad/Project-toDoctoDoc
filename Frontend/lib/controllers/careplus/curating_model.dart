
class Address {
  final int postcode;
  final String address;
  final String detailAddress;
  final String extraAddress;
  final double longitude;
  final double latitude;
  final String id;

  Address({
    required this.postcode,
    required this.address,
    required this.detailAddress,
    required this.extraAddress,
    required this.longitude,
    required this.latitude,
    required this.id,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      postcode: json['postcode'] is int
          ? json['postcode']
          : int.parse(json['postcode'].toString()),
      address: json['address'] ?? '',
      detailAddress: json['detailAddress'] ?? '',
      extraAddress: json['extraAddress'] ?? '',
      longitude: json['longitude'].toDouble(),
      latitude: json['latitude'].toDouble(),
      id: json['_id'] ?? '',
    );
  }
}

class MyPsyID {
  final String id;
  final String name;
  final bool isPremiumPsy;
  final int placeId;
  final Address address;
  final double stars;
  final List<dynamic> times;

  MyPsyID({
    required this.id,
    required this.name,
    required this.isPremiumPsy,
    required this.placeId,
    required this.address,
    required this.stars,
    required this.times,
  });

  factory MyPsyID.fromJson(Map<String, dynamic> json) {
    return MyPsyID(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      isPremiumPsy: json['isPremiumPsy'] ?? false,
      placeId: json['place_id'] is int
          ? json['place_id']
          : int.parse(json['place_id'].toString()),
      address: Address.fromJson(json['address']),
      stars: json['stars'] is double ? json['stars'] : double.parse(json['stars'].toString()),
      times: json['times'] != null ? List<dynamic>.from(json['times']) : [],
    );
  }
}

class Content {
  final String id;
  final String name;
  final MyPsyID myPsyID;
  final String? myProfileImage;
  final DateTime leastTime;
  final String distance;

  Content({
    required this.id,
    required this.name,
    required this.myPsyID,
    this.myProfileImage,
    required this.leastTime,
    required this.distance,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content( 
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      myPsyID: MyPsyID.fromJson(json['myPsyID']),
      myProfileImage: json['myProfileImage'], //null일 수 있으므로 String? 처리
      leastTime: DateTime.parse(json['leastTime'] as String).toLocal(),
       distance: json['distance'] is String ? json['distance'] : json['distance'].toString(),
    );
  }
}
