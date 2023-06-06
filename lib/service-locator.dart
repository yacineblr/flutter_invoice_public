import 'package:flutter_invoice/services/app-service.dart';
import 'package:flutter_invoice/services/customer-service.dart';
import 'package:flutter_invoice/services/invoice-service.dart';
import 'package:flutter_invoice/services/quotation-service.dart';
import 'package:flutter_invoice/services/settings-service.dart';
import 'package:get_it/get_it.dart';


final GetIt locator = GetIt.instance;
bool engine = false;

void setupLocator() {
  if (engine == true) return;
  engine = true;

  locator.registerSingleton<AppService>(AppService(), signalsReady: true);
  locator.registerSingletonWithDependencies<SettingsService>(() => SettingsService(), signalsReady: true, dependsOn: [AppService]);
  locator.registerSingletonWithDependencies<CustomerService>(() => CustomerService(), dependsOn: [SettingsService]);
  locator.registerSingletonWithDependencies<InvoiceService>(() => InvoiceService(), dependsOn: [SettingsService]);
  locator.registerSingletonWithDependencies<QuotationService>(() => QuotationService(), dependsOn: [SettingsService]);


  // locator.registerSingletonAsync<CustomerService>(() async {
  //   final service = CustomerService();
  //   await service.initAsync();
  //   return service;
  // }, signalsReady: false, dependsOn: [SettingsService]);

  // locator.registerSingletonAsync<QuotationService>(() async {
  //   final service = QuotationService();
  //   return service;
  // }, signalsReady: false, dependsOn: [SettingsService]);

  // locator.registerSingletonAsync<InvoiceService>(() async {
  //   final service = InvoiceService();
  //   return service;
  // }, signalsReady: false, dependsOn: [SettingsService]);

}