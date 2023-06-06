import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_invoice/models/customer.dart';
import 'package:flutter_invoice/service-locator.dart';
import 'package:flutter_invoice/services/settings-service.dart';
import 'package:rxdart/rxdart.dart';

class CustomerService {
  final SettingsService _settingService = locator<SettingsService>();
  CollectionReference collection = FirebaseFirestore.instance.collection('customers');
  // ignore: close_sinks
  late final BehaviorSubject<List<Customer>> customersStream = BehaviorSubject.seeded([]);

  Future<void> getCustomers(String settingId) async {
    final document = await collection
        .where('user_uid', isEqualTo: _settingService.userId)
        .where('setting_uid', isEqualTo: settingId)
        .get();
    final customers = document.docs.map((doc) => Customer.fromJson(doc.id, doc.data() as Map<String, dynamic>)).toList();
    customers.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
    customersStream.add(customers.reversed.toList());
  }

  add(String settingId, Customer newCustomer) async {
    newCustomer.userId = _settingService.userId;
    newCustomer.settingId = settingId;
    await collection.add(newCustomer.toJson())
    .then((value) {
      newCustomer.id = value.id;
      final customers = customersStream.value;
      customers.add(newCustomer);
      customers.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
      customersStream.add(customers.reversed.toList());
      print("User Created - id: ${value.id}");
    })
    .catchError((error) => print("Failed to create user: $error"));
  }

  update(Customer customer) async {
    await collection.doc(customer.id).update(customer.toJson())
    .then((value) {
      final customers = customersStream.value;
      final customerIndex = customers.indexWhere((c) => c.id == customer.id);
      customers[customerIndex] = customer;
      customersStream.add(customers);
      print("User Updated");
    })
    .catchError((error) => print("Failed to update user: $error"));
  }

  Future<bool> delete(Customer customer) async {
    try {
      await collection.doc(customer.id).delete();
      final list = customersStream.value;
      final index = list.indexOf(customer);
      list.removeAt(index);
      customersStream.add(list);
      return true;
    } catch (e) {
      print("Failed to delete customer: $e");
      return false;
    }
  }
}