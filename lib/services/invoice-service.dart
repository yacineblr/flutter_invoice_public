import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_invoice/models/invoice.dart';
import 'package:flutter_invoice/service-locator.dart';
import 'package:flutter_invoice/services/settings-service.dart';

class InvoiceService {
  final SettingsService _settingService = locator<SettingsService>();
  CollectionReference userCollection = FirebaseFirestore.instance.collection('invoices');
  // ignore: close_sinks
  
  getAllByCustomerId(String id) async {
    final document = await userCollection
        .where('customer_id', isEqualTo: id)
        .get();
    print(document.docs.length);
    final invoices = document.docs.map((doc) => Invoice.fromJson(doc.id, doc.data() as Map<String, dynamic>)).toList();
    invoices.sort((a, b) => a.date!.compareTo(b.date!));
    return invoices.reversed.toList();
  }

  getById(String id) async {
    print("InvoiceService - get by id $id");
    final document = await userCollection
        .where('id', isEqualTo: id)
        .get();
    print(document.docs.length);
    return Invoice.fromJson(document.docs.first.id, document.docs.first.data() as Map<String, dynamic>);
  }

  Future<Invoice?> save(Invoice newInvoice) async {
    newInvoice.userId = _settingService.userId;
    try {
      final value = await userCollection.add(newInvoice.toJson());
      newInvoice.id = value.id;
      print("Invoice created - id: ${value.id}");
      return newInvoice;
    } catch (e) {
      print("Failed to create invoice: $e");
      return null;
    }
  }

  Future<bool> update(Invoice invoice) async {
    try {
      await userCollection.doc(invoice.id).update(invoice.toJson());
      return true;
    } catch (e) {
      print("Failed to update invoice: $e");
      return false;
    }
  }

  Future<bool> delete(Invoice invoice) async {
    try {
      await userCollection.doc(invoice.id).delete();
      return true;
    } catch (e) {
      print("Failed to delete invoice: $e");
      return false;
    }
  }
}