import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_invoice/components/document-preview.dart';
import 'package:flutter_invoice/document-form.dart';
import 'package:flutter_invoice/models/customer.dart';
import 'package:flutter_invoice/models/document.dart';
import 'package:flutter_invoice/models/invoice.dart';
import 'package:flutter_invoice/models/quotation.dart';
import 'package:flutter_invoice/models/setting.dart';
import 'package:flutter_invoice/service-locator.dart';
import 'package:flutter_invoice/services/quotation-service.dart';
import 'package:flutter_invoice/services/invoice-service.dart';
import 'package:flutter_invoice/views/customer/customer-form.dart';
import 'package:rxdart/subjects.dart';

class CustomerDetail extends StatefulWidget {
  final Customer customer;
  final Setting setting;
  const CustomerDetail({ Key? key, required this.customer, required this.setting }) : super(key: key);

  @override
  _CustomerDetailState createState() => _CustomerDetailState();
}

class _CustomerDetailState extends State<CustomerDetail> {
  final QuotationService _quotationService = locator<QuotationService>();
  final InvoiceService _invoiceService = locator<InvoiceService>();
  late final Customer _customer;

  final BehaviorSubject<List<Quotation>> _streamQuotations = BehaviorSubject.seeded([]);
  final BehaviorSubject<List<Invoice>> _streamInvoices = BehaviorSubject.seeded([]);

  @override
  void initState() {
    _customer = widget.customer;
    initAsync();
    super.initState();
  }

  initAsync() async {
    _streamQuotations.add(await _quotationService.getAllByCustomerId(_customer.id!));
    _streamInvoices.add(await _invoiceService.getAllByCustomerId(_customer.id!));
  }
    
  @override
  Widget build(BuildContext context) {
    print("CUSTOMER ID: ${_customer.id}");
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text("Client"),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ID: ${_customer.id}"),
                      Text("Nom: ${_customer.lastname}"),
                      Text("Prénom: ${_customer.firstname}"),
                      Text("Email: ${_customer.email}"),
                      Text("Tel: ${_customer.phone}"),
                      Text("Adresse: ${_customer.address} ${_customer.city} ${_customer.zip}"),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final customerEdited = await showDialog<Customer>(
                                barrierDismissible: true,
                                context: context,
                                builder: (_) => CustomerForm(setting: widget.setting, customer: _customer)
                              );
                              if (customerEdited != null) {
                                _customer = customerEdited;
                                setState(() {});
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              color: Colors.blue[300],
                              child: Center(child: Text('Modifier')),
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () async {
                              final newDoc = await Navigator.push<Document>(context, CupertinoPageRoute(builder: (_) => DocumentForm(title: "Nouveau devis", customer: _customer, document: new Document())));
                              if (newDoc != null) {
                                Quotation quotation = new Quotation(
                                  customerId: _customer.id,
                                  date: newDoc.date,
                                  lines: newDoc.convertProductsToLines(),
                                  totalHt: newDoc.totalHt.toString(),
                                  tva: int.parse((newDoc.tax! * 100).toStringAsFixed(0))
                                );
                                final newQuotation = await _quotationService.save(quotation);
                                if (newQuotation != null) {
                                  final list = _streamQuotations.value;
                                  list.insert(0, newQuotation);
                                  _streamQuotations.add(list);
                                }
                              } else return null;
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              color: Colors.blue[300],
                              child: Center(child: Text('Créer un devis')),
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              final newDoc = await Navigator.push<Document>(context, CupertinoPageRoute(builder: (_) => DocumentForm(title: "Nouvelle facture", customer: _customer, document: new Document(type: DocumentType.paid))));
                              if (newDoc != null) {
                                Invoice invoice = new Invoice(
                                  customerId: _customer.id,
                                  date: newDoc.date,
                                  lines: newDoc.convertProductsToLines(),
                                  totalHt: newDoc.totalHt.toString(),
                                  tva: int.parse((newDoc.tax! * 100).toStringAsFixed(0))
                                );
                                final newInvoice = await _invoiceService.save(invoice);
                                if (newInvoice != null) {
                                  final list = _streamInvoices.value;
                                  list.insert(0, newInvoice);
                                  _streamInvoices.add(list);
                                }
                              } else return null;
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              color: Colors.blue[300],
                              child: Center(child: Text('Créer une facture')),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text('Devis :'),
                  padding: EdgeInsets.only(left: 20),
                ),
                StreamBuilder<List<Quotation>>(
                  stream: _streamQuotations,
                  initialData: [],
                  builder: (context, snapshot) {
                    if (snapshot.hasData == false) return Center(child: CircularProgressIndicator());
                    if (snapshot.data!.isEmpty) return Container(
                      constraints: BoxConstraints(minHeight: 100),
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: Text("Aucun devis")
                    );
                    final quotations = snapshot.data!;
                    return Container(
                      height: 350,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.separated(
                        padding: EdgeInsets.all(20),
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (_, index) {
                          return Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(blurRadius: 10, color: Colors.black12)
                              ]
                            ),
                            child: DocumentPreview(
                              setting: widget.setting,
                              customer: _customer,
                              quotation: quotations[index],
                              onQuotationToInvoice: (q) async {
                                Invoice invoice = new Invoice(
                                  customerId: widget.customer.id,
                                  date: q.date,
                                  lines: q.lines,
                                  totalHt: q.totalHt.toString(),
                                  tva: q.tva
                                );
                                final invoiceSaved = await _invoiceService.save(invoice);
                                if (invoiceSaved != null) {
                                  invoice = invoiceSaved;
                                  final list = _streamInvoices.value;
                                  list.insert(0, invoice);
                                  _streamInvoices.add(list);
                                }
                              },
                              onRemoveQuotation: (quotation) async {
                                final removed = await _quotationService.delete(quotation);
                                if (removed == true) {
                                  final list = _streamQuotations.value;
                                  list.removeAt(index);
                                  _streamQuotations.add(list);
                                }
                              },
                              onUpdateQuotation: (quotation) {
                                final list = _streamQuotations.value;
                                list[index] = quotation;
                                _streamQuotations.add(list);
                              },
                              onUpdateInvoice: (invoice) {},
                              onRemoveInvoice: (invoice) {}
                            )
                          );
                        },
                        itemCount: quotations.length,
                        separatorBuilder: (_, i) => SizedBox(width: 10),
                      ),
                    );
                  }
                ),
                SizedBox(height: 20),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text('Factures :'),
                  padding: EdgeInsets.only(bottom: 10, left: 20),
                ),
                StreamBuilder<List<Invoice>>(
                  stream: _streamInvoices,
                  builder: (context, snapshot) {
                    if (snapshot.hasData == false) return Center(child: CircularProgressIndicator());
                    if (snapshot.data!.isEmpty) return Container(
                      constraints: BoxConstraints(minHeight: 100),
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: Text("Aucune facture")
                    );
                    final invoices = snapshot.data;
                    return Container(
                      height: 350,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (_, index) {
                          return Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(blurRadius: 10, color: Colors.black12)
                              ]
                            ),
                            child: DocumentPreview(
                              setting: widget.setting,
                              customer: _customer,
                              invoice: invoices[index],
                              onQuotationToInvoice: (q) {},
                              onRemoveInvoice: (invoice) async {
                                final removed = await _invoiceService.delete(invoice);
                                if (removed == true) {
                                  final list = _streamInvoices.value;
                                  list.removeAt(index);
                                  _streamInvoices.add(list);
                                }
                              },
                              onRemoveQuotation: (q) {},
                              onUpdateQuotation: (q) {},
                              onUpdateInvoice: (invoice) async {
                                final updated = await _invoiceService.update(invoice);
                                if (updated == true) {
                                  final list = _streamInvoices.value;
                                  list[index] = invoice;
                                  _streamInvoices.add(list);
                                }
                              },
                            )
                          );
                        },
                        itemCount: invoices!.length,
                        separatorBuilder: (_, i) => SizedBox(width: 10),
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}