import 'package:flutter/material.dart';
import 'package:flutter_invoice/models/invoice.dart';
import 'package:flutter_invoice/models/line.dart';

enum DocumentType { quotes, paid }

class Document {
  final DocumentType? type;
  final InvoicePaidMethod? paidMethod;
  final double? tax;
  late List<DocumentProduct>? products;
  late DateTime? date;
  Document({
    this.type = DocumentType.quotes,
    this.paidMethod = InvoicePaidMethod.CB,
    this.tax = .20,
    List<DocumentProduct>? products,
    DateTime? invoiceDate,
  }) {
    this.products = products ?? [DocumentProduct(
      productName: '', 
      price: '0', 
      quantity: '1'
    )];
    this.date = invoiceDate ?? DateTime.now();
  }

  double get totalHt => products!.map((e) => e.total ?? 0).reduce((p, n) => p + n);

  List<Line> convertProductsToLines() {
    return this.products!.map((e) => Line(
      description: e.productName,
      prixHt: e.price.toString(),
      qte: e.quantity.toString()
    )).toList();
  }
}


class DocumentProduct {
  late final TextEditingController ctrlProductName;
  late final TextEditingController ctrlQuantity;
  late final TextEditingController ctrlPrice;

  DocumentProduct({
    String? productName,
    String? price,
    String? quantity,
  }) {
    this.ctrlProductName = TextEditingController(text: productName ?? "");
    this.ctrlQuantity = TextEditingController(text: quantity?.toString() ?? "1");
    this.ctrlPrice = TextEditingController(text: price?.toString() ?? "0");
  }
  String get productName => ctrlProductName.value.text;
  int get quantity {
    try {
      final val = int.tryParse(
          ctrlQuantity.value.text.length > 0 ? ctrlQuantity.value.text : '0');
      return val ?? 0;
    } catch (e) {
      return 0;
    }
  }

  double get price {
    try {
      final text = ctrlPrice.value.text.replaceAll(",", ".");
      final val = double.tryParse(text.length > 0 ? text : '0');
      return val ?? 0;
    } catch (e) {
      return 0;
    }
  }

  double? get total => double.tryParse((price * quantity).toStringAsFixed(2));

  String getIndex(int index) {
    switch (index) {
      case 0:
        return productName;
      case 1:
        return quantity.toString();
      case 2:
        return price.toStringAsFixed(2);
      case 3:
        return formatCurrency(total ?? 0);
    }
    return '';
  }

  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)}';
  }
}
