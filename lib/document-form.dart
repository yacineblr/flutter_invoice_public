import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_invoice/models/customer.dart';
import 'package:flutter_invoice/models/document.dart';
import 'package:flutter_invoice/models/invoice.dart';

import 'package:pdf/widgets.dart' as pw;

import 'package:intl/intl.dart';


class DocumentForm extends StatefulWidget {
  final String title;
  final Document? document;
  final Customer? customer;

  DocumentForm({Key? key, required this.title, this.customer, this.document}): super(key: key);

  @override
  DocumentFormState createState() {
    return DocumentFormState();
  }
}

class DocumentFormState extends State<DocumentForm> with SingleTickerProviderStateMixin {

  late final bool _isQuote;
  late final TextEditingController _referenceTextEditing;
  late bool _hasBeenPaid;
  late InvoicePaidMethod _invoicePaidMethod;
  late double _tva;
  late DateTime _dateTime;
  late TextEditingController _dateTextEditing;
  

 late final List<DocumentProduct> _products;

  @override
  void initState() {
    final document = widget.document ?? new Document();
    _isQuote = document.type == DocumentType.quotes ? true : false;
    _hasBeenPaid = document.paidMethod != null ? true : false;
    _invoicePaidMethod = document.paidMethod != null ? document.paidMethod! : InvoicePaidMethod.Other;
    _referenceTextEditing = TextEditingController(text: "");
    _tva = document.tax != null ? document.tax! : .20;
    _dateTime = document.date!;
    _dateTextEditing = TextEditingController(text: DateFormat.yMMMd('fr').format(document.date!));
    _products = document.products != null ? document.products! : [DocumentProduct(productName: '', price: '0', quantity: '1')];
    super.initState();
  }

  void _addItem() {
    _products.add(DocumentProduct(productName: '', price: '0', quantity: '1'));
    setState(() {});
  }

  void _removeItem(int index) {
    _products.removeAt(index);
    setState(() {});
  }

  double _getTotalHt() {
    return _products.map((e) => e.total ?? 0).reduce((p, n) => p + n);
  }

  double _getTotalTTC() {
    final totalHT = _getTotalHt();
    return totalHT + (_tva * totalHT);
  }


  @override
  Widget build(BuildContext context) {
    print('_isQuote: $_isQuote');
    pw.RichText.debug = true;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  if (_isQuote == false)
                    Column(
                      children: [
                        Row(
                          children: [
                            Text("La facture a t-elle été payé ?"),
                            Checkbox(
                              value: _hasBeenPaid,
                              onChanged: (value) => setState(() { _hasBeenPaid = value ?? false; }))
                          ],
                        ),
                        if (_hasBeenPaid) Row(
                          children: [
                            Container(
                                child: Row(children: [
                              Text("CB"),
                              Checkbox(
                                value: _invoicePaidMethod == InvoicePaidMethod.CB,
                                onChanged: (value) => setState(() {
                                  _invoicePaidMethod = InvoicePaidMethod.CB;
                                })
                              )
                            ])),
                            Container(
                                child: Row(children: [
                              Text("Espèces"),
                              Checkbox(
                                value: _invoicePaidMethod == InvoicePaidMethod.Cash,
                                onChanged: (value) => setState(() {
                                  _invoicePaidMethod = InvoicePaidMethod.Cash;
                                })
                              )
                            ])),
                            Container(
                                child: Row(children: [
                              Text("Chèques"),
                              Checkbox(
                                value: _invoicePaidMethod == InvoicePaidMethod.Check,
                                onChanged: (value) => setState(() {
                                  _invoicePaidMethod = InvoicePaidMethod.Check;
                                })
                              )
                            ])),
                            Container(
                                child: Row(children: [
                              Text("Autre"),
                              Checkbox(
                                value: _invoicePaidMethod == InvoicePaidMethod.Other,
                                onChanged: (value) => setState(() {
                                  _invoicePaidMethod = InvoicePaidMethod.Other;
                                })
                              )
                            ]))
                          ],
                        ),
                      ],
                    ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: DropdownButtonFormField<double>(
                          decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              border: UnderlineInputBorder(),
                              labelText: 'TVA'),
                          value: _tva,
                          icon: const Icon(Icons.arrow_downward),
                          onChanged: (double? newValue) {
                            setState(() {
                              _tva = newValue ?? .0;
                            });
                          },
                          items: <double>[.0, .10, .20].map<DropdownMenuItem<double>>((double value) {
                            return DropdownMenuItem<double>(
                              value: value,
                              child: Text((value * 100).toString()),
                            );
                          }).toList(),
                        ),
                      )),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                            decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                border: UnderlineInputBorder(),
                                labelText: 'Date '),
                            controller: _dateTextEditing,
                            onTap: () async {
                              FocusScope.of(context).requestFocus(new FocusNode());
                              final modal = kIsWeb ? showDatePicker(
                                  context: context,
                                  initialDate: _dateTime,
                                  firstDate: DateTime(2015, 8),
                                  lastDate: DateTime(2101)
                                ) : showCupertinoModalPopup(
                                context: context,
                                builder: (context) {
                                  var datetime = _dateTime;
                                  return Material(
                                    child: Container(
                                      color: Colors.white,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 5, right: 10),
                                            child: ElevatedButton(
                                              onPressed: () => Navigator.pop(context, datetime),
                                              child: Text("Valider"),
                                            ),
                                          ),
                                          Container(
                                            height: 260,
                                            child: CupertinoDatePicker(
                                              use24hFormat: true,
                                              mode: CupertinoDatePickerMode.date,
                                              initialDateTime: datetime,
                                              onDateTimeChanged: (onDateTimeChanged) {
                                                datetime = onDateTimeChanged;
                                              }
                                            ),
                                          ),
                                        ],
                                      )
                                    ),
                                  );
                                });
                              
                              DateTime date = await modal;
                              _dateTime = date;
                              _dateTextEditing.text = DateFormat.yMMMd('fr').format(date);
                            }),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  SizedBox(height: 40),
                  ..._products
                      .asMap()
                      .map((key, item) {
                        final value = Row(
                          children: [
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.done,
                                maxLines: null,
                                controller: item.ctrlProductName,
                                decoration: InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: 'Description ${key + 1}',
                                ),
                              ),
                            ),
                            Container(
                              width: 60,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                controller: item.ctrlQuantity,
                                decoration: InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: 'Quantity',
                                ),
                                onChanged: (v) => setState(() {}),
                              ),
                            ),
                            Container(
                              width: 60,
                              child: TextField(
                                keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
                                controller: item.ctrlPrice,
                                decoration: InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: 'PU.H.T',
                                ),
                                onChanged: (v) => setState(() {}),
                              ),
                            ),
                            if (_products.length > 1)
                              Container(
                                width: 20,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _removeItem(key),
                                  icon: Icon(Icons.close),
                                ),
                              )
                          ],
                        );
                        return MapEntry(key, value);
                      })
                      .values
                      .toList(),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon( label: Text("Ajouter"), onPressed: () => _addItem(), icon: Icon(Icons.add)),
                      Container(
                          width: 175,
                          child: DefaultTextStyle(
                            style: TextStyle(fontSize: 19, color: Colors.black),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Total HT :"),
                                      Text(_getTotalHt().toStringAsFixed(2))
                                    ]),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("TVA :"),
                                      Text((_tva * 100).toStringAsFixed(2) + "%")
                                    ]),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Total TTC : "),
                                      Text(_getTotalTTC().toStringAsFixed(2))
                                    ])
                              ],
                            ),
                          )),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _save(),
                    child: Text("Enregistrer ")
                  )
                ],
              ),
            ),
          ),
        )
      )
    );
  }

  _save() {
    final document = new Document(
      invoiceDate: _dateTime,
      paidMethod: _hasBeenPaid == true ? _invoicePaidMethod : null,
      products: this._products,
      tax: this._tva,
      type: this._isQuote == true ? DocumentType.quotes : DocumentType.paid
    );
    Navigator.pop(context, document);
  }
}
