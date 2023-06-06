import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_invoice/document-form.dart';
import 'package:flutter_invoice/models/customer.dart';
import 'package:flutter_invoice/models/document.dart';
import 'package:flutter_invoice/models/line.dart';
import 'package:intl/intl.dart';

class Quotation {
  String? settingId;
  String? userId;
  String? id;
  String? customerId;
  DateTime? date;
  List<Line>? lines;
  String? service;
  int? tva;
  String? totalHt;

  Quotation({
    this.userId,
    this.id,
    this.customerId,
    this.date,
    this.lines,
    this.tva,
    this.service,
    this.totalHt
  });

  @override
  String toString() {
    return 'Quotation(userId: $userId, id: $id, customerId: $customerId, date: $date,, lines: $lines, tva: $tva, service: $service, totalHt: $totalHt)';
  }

  factory Quotation.fromJson(String id, Map<String, dynamic> json) {
    return Quotation(
      userId: (json['user_uid'] as String),
      id: id,
      customerId: json['customer_id'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
      lines: (json['lines'] as List<dynamic>)
          .map((e) => Line.fromJson(e as Map<String, dynamic>))
          .toList(),
      tva: json['tva'] as int? ?? 0,
      service: json['service'] as String?,
      totalHt: json['total_ht'] as String? ?? "0",
    );
  }

  Map<String, dynamic> toJson() => {
        'user_uid': userId,
        'id': id,
        'customer_id': customerId,
        'date': date?.millisecondsSinceEpoch,
        'lines': (lines ?? []).map((e) => e.toJson()).toList(),
        'tva': tva,
        'service': service,
        'total_ht': totalHt
      };

  Future<Quotation?> openForm(BuildContext context, Customer customer) async {
    final doc = Document(
      invoiceDate: this.date,
      tax: this.tva != null ? this.tva! / 100 : null,
      type: DocumentType.quotes,
      products: (this.lines ?? []).map((e) => DocumentProduct(
        productName: e.description,
        price: e.prixHt,
        quantity: e.qte
      )).toList()
    );
    final newDoc = await Navigator.push<Document>(context, CupertinoPageRoute(builder: (_) => DocumentForm(title: "Modification devis", customer: customer, document: doc)));
    if (newDoc != null) {
      this.date = newDoc.date;
      this.tva = int.parse((newDoc.tax! * 100).toString());
      this.lines = newDoc.convertProductsToLines();
      return this;
    } else return null;
  }

  double get totalTtc {
    if (totalHt == null || totalHt == "" || tva == null) return 0.0;
    final ht = double.tryParse(totalHt!);
    return (ht! * (tva! / 100)) + ht;
  }

  String getDateFormated() {
    if (this.date == null) return "";
    return DateFormat.yMMMd('fr').format(this.date!);
  }

  List<DocumentProduct> convertLinesToProducts() {
    return (this.lines ?? []).map((e) => DocumentProduct(
      productName: e.description,
      price: e.prixHt,
      quantity: e.qte
    )).toList();
  }
}
