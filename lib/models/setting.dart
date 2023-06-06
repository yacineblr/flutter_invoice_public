import 'package:cloud_firestore/cloud_firestore.dart';

class Setting {
  String? id;
  String? companyName;
  String? email;
  String? logo;
  String? phone;
  String? address;
  String? city;
  String? zip;
  String? rcs;
  String? siren;
  String? siret;
  String? userId;
  String? website;
  Setting({
    this.companyName,
    this.email,
    this.id,
    this.logo,
    this.phone,
    this.address,
    this.city,
    this.zip,
    this.rcs,
    this.siren,
    this.siret,
    this.userId,
    this.website,
  });

  factory Setting.fromJson(String id, Map<String, dynamic> json) {
    return Setting(
        companyName: json['company_name'],
        email: json['email'],
        id: id,
        logo: json['logo'],
        phone: json['phone'],
        address: json['address'],
        city: json['city'],
        zip: json['zip'],
        rcs: json['rcs'],
        siren: json['siren'],
        siret: json['siret'],
        userId: json['user_uid'],
        website: json['website']);
  }

  Map<String, dynamic> toJson() {
    return {
      "company_name": companyName,
      "email": email,
      "id": id,
      "logo": logo,
      "phone": phone,
      "address": address,
      "city": city,
      "zip": zip,
      "rcs": rcs,
      "siren": siren,
      "siret": siret,
      "user_uid": userId,
      "website": website
    };
  }

  copyWith() {
    return Setting(
        companyName: companyName,
        email: email,
        id: id,
        logo: logo,
        phone: phone,
        address: address,
        city: city,
        zip: zip,
        rcs: rcs,
        siren: siren,
        siret: siret,
        userId: userId,
        website: website);
  }
}
