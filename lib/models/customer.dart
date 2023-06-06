import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  String? settingId;
  String? userId;
  String? id;
  String? civility;
  String? lastname;
  String? firstname;
  String? address;
  String? city;
  String? zip;
  String? phone;
  String? email;
  late DateTime dateCreated;

  Customer({
    this.settingId,
    this.userId,
    this.id,
    this.civility,
    this.lastname,
    this.firstname,
    this.address,
    this.city,
    this.zip,
    this.phone,
    this.email,
    DateTime? dateCreated
  }) {
    this.dateCreated = dateCreated ?? DateTime.now();
  }

  factory Customer.fromJson(String id, Map<String, dynamic> json) {
    return Customer(
      settingId: (json['setting_uid'] as String?) ?? "",
      userId: (json['user_uid'] as String?) ?? "",
      id: id,
      civility: (json['civility'] as String?) ?? "",
      lastname: (json['lastname'] as String?) ?? "",
      firstname: (json['firstname'] as String?) ?? "",
      address: (json['address'] as String?) ?? "",
      city:( json['city'] as String?) ?? "",
      zip: (json['zip'] as String?) ?? "",
      phone: (json['phone'] as String?) ?? "",
      email: (json['email'] as String?) ?? "",
      dateCreated: DateTime.fromMillisecondsSinceEpoch(json['date_created'] as int)
    );
  }

  Map<String, dynamic> toJson() => {
        'setting_uid': settingId,
        'user_uid': userId,
        'civility': civility,
        'lastname': lastname,
        'firstname': firstname,
        'address': address,
        'city': city,
        'zip': zip,
        'phone': phone,
        'email': email,
        'date_created': dateCreated.millisecondsSinceEpoch
      };

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Customer &&
        other.settingId == settingId &&
        other.userId == userId &&
        other.id == id &&
        other.civility == civility &&
        other.lastname == lastname &&
        other.firstname == firstname &&
        other.address == address &&
        other.city == city &&
        other.zip == zip &&
        other.phone == phone &&
        other.email == email &&
        other.dateCreated == dateCreated;
  }

  @override
  int get hashCode =>
      settingId.hashCode ^
      userId.hashCode ^
      id.hashCode ^
      civility.hashCode ^
      lastname.hashCode ^
      firstname.hashCode ^
      address.hashCode ^
      city.hashCode ^
      zip.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      dateCreated.hashCode;
    
  copyWith({
    String? settingId,
    String? userId,
    String? id,
    String? civility,
    String? lastname,
    String? firstname,
    String? address,
    String? city,
    String? zip,
    String? phone,
    String? email,
    DateTime? dateCreated
  }) {
    return Customer(
      settingId: settingId ?? this.settingId,
      userId: userId ?? this.userId,
      id: id ?? this.id,
      civility: civility ?? this.civility,
      lastname: lastname ?? this.lastname,
      firstname: firstname ?? this.firstname,
      address: address ?? this.address,
      city: city ?? this.city,
      zip: zip ?? this.zip,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      dateCreated: dateCreated ?? this.dateCreated
    );
  }
}
