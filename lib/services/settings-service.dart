// ignore_for_file: close_sinks, invalid_return_type_for_catch_error

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_invoice/models/setting.dart';
import 'package:flutter_invoice/service-locator.dart';
import 'package:flutter_invoice/services/app-service.dart';
import 'package:rxdart/rxdart.dart';

class SettingsService {
  final appService = locator.get<AppService>();
  final String userId = '9lVX973Q9tdksE650bIQ0HoArs83';
  final CollectionReference _settingCollection = FirebaseFirestore.instance.collection('settings');
  
  final BehaviorSubject<List<Setting>> settingsStream = BehaviorSubject.seeded([]);

  SettingsService() {
    initAsync();
  }

  Future<SettingsService> initAsync() async {
    final document = await _settingCollection
        .where('user_uid', isEqualTo: userId)
        .get();
    print(document.docs.first["company_name"]);
    final settings = document.docs.map((doc) => Setting.fromJson(doc.id, doc.data() as Map<String, dynamic>)).toList();
    settingsStream.add(settings);
    // final setting = Setting.fromJson(document.docs.first);
    // settingStream.add(setting);
    locator.signalReady(this);
    return this;
  }

  Future<void> add(Setting newSetting) async {
    newSetting.userId = userId;
    await _settingCollection.add(newSetting.toJson())
    .then((value) {
      newSetting.id = value.id;
      final settings = settingsStream.value;
      settings!.add(newSetting);
      settingsStream.add(settings);
      print("Setting Created - id: ${value.id}");
    })
    .catchError((error) => print("Failed to create setting: $error"));
  }

  Future<void> update(Setting setting) async {
    await _settingCollection.doc(setting.id).update(setting.toJson())
    .then((value) {
      final settings = settingsStream.value;
      final index = settings!.indexWhere((element) => element.id == setting.id);
      settings[index] = setting;
      settingsStream.add(settings);
      print("Setting Updated - id: ${setting.id}");
    })
    .catchError((error) => print("Failed to update setting: $error"));
  }

  delete(String id) async {
    await _settingCollection.doc(id).delete();
    final settings = settingsStream.value;
    final index = settings.indexWhere((element) => element.id == id);
    settings.removeAt(index);
    settingsStream.add(settings);
  }
}