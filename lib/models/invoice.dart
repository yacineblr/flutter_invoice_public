import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_invoice/document-form.dart';
import 'package:flutter_invoice/models/customer.dart';
import 'package:flutter_invoice/models/document.dart';
import 'package:flutter_invoice/models/line.dart';
import 'package:flutter_invoice/models/quotation.dart';
import 'package:intl/intl.dart';

enum InvoicePaidMethod { CB, Cash, Check, Other }

class Invoice extends Quotation {
  bool? hasBeenPayed;
  InvoicePaidMethod? paidMethod;

  Invoice({
    super.userId,
    super.id,
    super.customerId,
    super.date,
    super.lines,
    super.tva,
    super.service,
    super.totalHt,
    this.hasBeenPayed,
    this.paidMethod
  });

  @override
  String toString() {
    return 'Invoice(userId: $userId, id: $id, customerId: $customerId, date: $date, lines: $lines, tva: $tva, service: $service, totalHt: $totalHt, hasBeenPayed: $customerId, paidMethod: $paidMethod)';
  }

  factory Invoice.fromJson(String id, Map<String, dynamic> json) {
    InvoicePaidMethod? invoicePaidMethod;
    if (json['paidMethod'] != null) {
      switch (json['paidMethod']) {
        case 'cb':
          invoicePaidMethod = InvoicePaidMethod.CB;
          break;
        case 'cach':
          invoicePaidMethod = InvoicePaidMethod.Cash;
          break;
        case 'check':
          invoicePaidMethod = InvoicePaidMethod.Check;
          break;
        case 'other':
          invoicePaidMethod = InvoicePaidMethod.Other;
          break;
        default:
        invoicePaidMethod = null;
      }
    }
    return Invoice(
        userId: (json['user_uid'] as String?) ?? "",
        id: id,
        customerId: json['customer_id'] as String?,
        date: DateTime.fromMillisecondsSinceEpoch(json['date']),
        lines: (json['lines'] as List<dynamic>)
            .map((e) => Line.fromJson(e as Map<String, dynamic>))
            .toList(),
        tva: json['tva'] as int? ?? 0,
        service: json['service'] as String?,
        totalHt: json['total_ht'] as String,
        hasBeenPayed: json['hasBeenPayed'] as bool? ?? false,
        paidMethod: invoicePaidMethod
      );
  }

  Map<String, dynamic> toJson() {
    String? invoicePaidMethod;
    switch (paidMethod) {
      case InvoicePaidMethod.CB:
        invoicePaidMethod = 'cb';
        break;
      case InvoicePaidMethod.Cash:
        invoicePaidMethod = 'cach';
        break;
      case InvoicePaidMethod.Check:
        invoicePaidMethod = 'check';
        break;
      default:
      invoicePaidMethod = null;
    }
    return {
      'user_uid': userId,
      'id': id,
      'customer_id': customerId,
      'date': date?.millisecondsSinceEpoch,
      'lines': (lines ?? []).map((e) => e.toJson()).toList(),
      'tva': tva,
      'service': service,
      'total_ht': totalHt,
      'hasBeenPayed': hasBeenPayed,
      'paidMethod': invoicePaidMethod
    };
  }

  Future<Invoice?> openForm(BuildContext context, Customer customer) async {
    final doc = Document(
      invoiceDate: this.date,
      tax: this.tva != null ? this.tva! / 100 : null,
      type: DocumentType.paid,
      paidMethod: this.paidMethod,
      products: (this.lines ?? []).map((e) => DocumentProduct(productName: e.description, price: e.prixHt, quantity: e.qte)).toList()
    );
    final newDoc = await Navigator.push<Document>(context, CupertinoPageRoute(builder: (_) => DocumentForm(title: "Modification facture", customer: customer, document: doc)));
    if (newDoc != null) {
      this.date = newDoc.date;
      this.tva = int.parse((newDoc.tax! * 100).toStringAsFixed(0).toString());
      this.lines = newDoc.convertProductsToLines();
      this.paidMethod = newDoc.paidMethod;
      this.hasBeenPayed = newDoc.paidMethod != null;
      this.totalHt = newDoc.totalHt.toString();
      return this;
    } else return null;
  }

}