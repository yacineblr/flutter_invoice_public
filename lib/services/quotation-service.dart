import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_invoice/models/quotation.dart';
import 'package:flutter_invoice/service-locator.dart';
import 'package:flutter_invoice/services/settings-service.dart';

class QuotationService {
  final SettingsService _settingService = locator<SettingsService>();
  CollectionReference collection = FirebaseFirestore.instance.collection('quotations');
  // ignore: close_sinks
  
  getAllByCustomerId(String id) async {
    final document = await collection
        .where('customer_id', isEqualTo: id)
        .get();
    final quotations = document.docs.map((doc) => Quotation.fromJson(doc.id, doc.data() as Map<String, dynamic>)).toList();
    quotations.sort((a, b) => a.date!.compareTo(b.date!));
    return quotations.reversed.toList();
  }

  getById(String id) async {
    print("QuotationService - get by id $id");
    final document = await collection
        .where('id', isEqualTo: id)
        .get();
    print(document.docs.length);
    return Quotation.fromJson(document.docs.first.id, document.docs.first.data() as Map<String, dynamic>);
  }

  Future<Quotation?> save(Quotation newQuotation) async {
    newQuotation.userId = _settingService.userId;
    try {
      final value = await collection.add(newQuotation.toJson());
      newQuotation.id = value.id;
      print("Quotation created - id: ${value.id}");
      return newQuotation;
    } catch (e) {
      print("Failed to create quotation: $e");
      return null;
    }
  }

  Future<bool> update(Quotation quotation) async {
    try {
      await collection.doc(quotation.id).update(quotation.toJson());
      return true;
    } catch (e) {
      print("Failed to update quotation: $e");
      return false;
    }
  }

  Future<bool> delete(Quotation quotation) async {
    try {
      await collection.doc(quotation.id).delete();
      return true;
    } catch (e) {
      print("Failed to delete quotation: $e");
      return false;
    }
  }
}