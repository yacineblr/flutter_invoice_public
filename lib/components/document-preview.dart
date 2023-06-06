import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_invoice/models/customer.dart';
import 'package:flutter_invoice/models/document.dart';
import 'package:flutter_invoice/models/invoice.dart';
import 'package:flutter_invoice/models/line.dart';
import 'package:flutter_invoice/models/quotation.dart';
import 'package:flutter_invoice/models/setting.dart';
import 'package:flutter_invoice/service-locator.dart';
import 'package:flutter_invoice/services/settings-service.dart';
import 'package:intl/intl.dart';

import 'dart:io';
import 'package:flutter_invoice/document-pdf-viewer.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

enum DocumentPreviewMenuChoice {
  pdf,
  modify,
  convertToInvoice,
  delete
}

class DocumentPreview extends StatefulWidget {
  const DocumentPreview({Key? key,
    required this.setting,
    required this.customer,
    required this.onQuotationToInvoice,
    required this.onRemoveQuotation,
    required this.onRemoveInvoice,
    required this.onUpdateQuotation,
    required this.onUpdateInvoice,
    this.quotation,
    this.invoice
  }) : super(key: key);

  final Setting setting;
  final Customer customer;
  final Function(Quotation quotation) onQuotationToInvoice;
  final Function(Quotation quotation) onRemoveQuotation;
  final Function(Invoice invoice) onRemoveInvoice;
  final Function(Quotation quotation) onUpdateQuotation;
  final Function(Invoice invoice) onUpdateInvoice;
  final Quotation? quotation;
  final Invoice? invoice;

  @override
  _DocumentPreviewState createState() => _DocumentPreviewState();
}

class _DocumentPreviewState extends State<DocumentPreview> {
  final SettingsService _settingService = locator<SettingsService>();

  Quotation? _quotation;
  Invoice? _invoice;

  @override
  void initState() {
    _quotation = widget.quotation;
    _invoice = widget.invoice;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Column(
        children: [
          info(),
          SizedBox(height: 10),
          generateLines(_quotation?.lines ?? widget.invoice?.lines ?? [])
        ],
      ),
    );
  }

  generateLines(List<Line> lines) {
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: (_, i) {
        final line = lines[i];
        return Container(
          decoration: BoxDecoration(
            border: Border.all()
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 70,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(line.description, style: TextStyle(fontSize: 11.5)),
                  )
                ),
                Expanded(
                  flex: 10,
                  child: Container(
                    width: 30,
                    decoration: BoxDecoration(
                      border: Border.symmetric(vertical: BorderSide())
                    ),
                    alignment: Alignment.center,
                    child: Text(line.qte, style: TextStyle(fontSize: 11.5)),
                  ),
                ),
                Expanded(
                  flex: 20,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Text(line.prixHt, style: TextStyle(fontSize: 11.5)), alignment: Alignment.centerRight
                  )
                )
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, i) => Container(),
      itemCount: lines.length
    );
  }
  
  Widget _popupMenuButton() {
    if (_quotation != null) {
      return PopupMenuButton(
        icon: Icon(Icons.more_vert_outlined, size: 18),
        onSelected: (DocumentPreviewMenuChoice choice) async {
          switch (choice) {
            case DocumentPreviewMenuChoice.modify:
              final newQuotation = await _quotation!.openForm(context, widget.customer);
              if (newQuotation != null) {
                widget.onUpdateQuotation(newQuotation);
                setState(() {});
              }
              break;
            case DocumentPreviewMenuChoice.convertToInvoice:
              widget.onQuotationToInvoice(_quotation!);
              break;
            case DocumentPreviewMenuChoice.pdf:
              _viewPdf();
              break;
            case DocumentPreviewMenuChoice.delete:
              widget.onRemoveQuotation(_quotation!);
              break;
            default:
          }
        },
        itemBuilder: (_) {
          return [
            PopupMenuItem(
              value: DocumentPreviewMenuChoice.pdf,
              child: Text('PDF'),
            ),
            PopupMenuItem(
              value: DocumentPreviewMenuChoice.convertToInvoice,
              child: Text('Convertir en facture'),
            ),
            PopupMenuItem(
              value: DocumentPreviewMenuChoice.modify,
              child: Text('Modifier'),
            ),
            PopupMenuItem(
              value: DocumentPreviewMenuChoice.delete,
              child: Text('Supprimer'),
            ),
          ];
        },
      );
    } else if (_invoice != null) {
      return PopupMenuButton(
        icon: Icon(Icons.more_vert_outlined, size: 18),
        onSelected: (DocumentPreviewMenuChoice choice) async {
          switch (choice) {
            case DocumentPreviewMenuChoice.modify:
              final newInvoice = await _invoice!.openForm(context, widget.customer);
              widget.onUpdateInvoice(newInvoice!);
              break;
            case DocumentPreviewMenuChoice.pdf:
              _viewPdf();
              break;
            case DocumentPreviewMenuChoice.delete:
              widget.onRemoveInvoice(_invoice!);
              break;
            default:
          }
        },
        itemBuilder: (_) {
          return [
            PopupMenuItem(
              value: DocumentPreviewMenuChoice.pdf,
              child: Text('PDF'),
            ),
            PopupMenuItem(
              value: DocumentPreviewMenuChoice.modify,
              child: Text('Modifier'),
            ),
            PopupMenuItem(
              value: DocumentPreviewMenuChoice.delete,
              child: Text('Supprimer'),
            ),
          ];
        },
      );
    } return Container();
  }

  info() {
    final id = _quotation?.id ?? _invoice?.id;
    final tva = _quotation?.tva ?? _invoice?.tva;
    final date = _quotation?.date ?? _invoice?.date;
    final totalHt = _quotation?.totalHt ?? _invoice?.totalHt;
    final totalTtc = _quotation?.totalTtc ?? _invoice?.totalTtc;
    final textStyle = TextStyle(fontSize: 11);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: $id', style: textStyle),
                    Row(
                      children: [
                        Text("TVA: $tva", style: textStyle),
                        SizedBox(width: 10),
                        if (date != null) Text('Date: ${DateFormat('dd/MM/yyyy').format(date)}', style: textStyle)
                      ],
                    )
                ],
              ),
              _popupMenuButton()
            ],
          ),
          Row(
            children: [
              Text("Total HT: $totalHt", style: textStyle),
              Expanded(child: SizedBox(width: 1)),
              Text("Total TTC: $totalTtc", style: textStyle),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _saveAsFile(
    BuildContext context,
    LayoutCallback build,
    PdfPageFormat pageFormat,
  ) async {
    final bytes = await build(pageFormat);
    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    final file = File(appDocPath + '/' + _getFileName());
    print('Save as file ${file.path} ...');
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }

  String _getFileName() {
    final type = _quotation != null ? "devis" : "facture";
    final reference = _quotation != null ? _quotation!.id : widget.invoice!.id;
    final date = _quotation != null ? _quotation!.date : widget.invoice!.date;
    return "$type-$reference-$date.pdf";
  }

  _viewPdf() {
    bool isQuote = _quotation != null;
    final actions = <PdfPreviewAction>[
      if (!kIsWeb)PdfPreviewAction(icon: const Icon(Icons.save), onPressed: _saveAsFile),
      PdfPreviewAction(
        icon: const Icon(Icons.close),
        onPressed: (context, fun, pdfPageFormat) => Navigator.pop(context),
      )
    ];
    InvoicePaidMethod? paidWith;
    if (widget.invoice != null && widget.invoice!.paidMethod != null) {
      paidWith = widget.invoice!.paidMethod!;
    } 
    final pdfWidget = PdfPreview(
      maxPageWidth: 700,
      pdfFileName: _getFileName(),
      build: (pageFormat) async {
        final invoice = DocumentPdfViewer(
          type: isQuote == true
              ? DocumentType.quotes
              : DocumentType.paid,
          paidWith: paidWith,
          companyName: widget.setting.companyName ?? '',
          companyLogoBase64: widget.setting.logo ?? '',
          companyAddress: widget.setting.address ?? '',
          companyCity: widget.setting.city ?? '',
          companyPostalCode: widget.setting.zip ?? '',
          companySiren: widget.setting.siren ?? '',
          companyEmail: widget.setting.email ?? '',
          companyPhone: widget.setting.phone ?? '',
          customerPostalCode: widget.customer.zip ?? '',
          customerCity: widget.customer.city ?? '',
          customerCountry: 'France',
          invoiceReference: _quotation != null ? _quotation!.id! : widget.invoice!.id!,
          invoiceDate: _quotation != null ? _quotation!.getDateFormated() : widget.invoice!.getDateFormated(),
          products: _quotation != null
            ? _quotation!.convertLinesToProducts()
            : widget.invoice!.convertLinesToProducts(),
          customerName:
              "${widget.customer.lastname} ${widget.customer.firstname}",
          customerEmail: widget.customer.email ?? '',
          customerPhone: widget.customer.phone ?? '',
          customerAddress: widget.customer.address ?? '',
          tax: (_quotation != null ? _quotation!.tva : widget.invoice!.tva)! / 100,
        );

        return await invoice.buildPdf(pageFormat);
      },
      canChangeOrientation: false,
      canChangePageFormat: false,
      actions: actions,
      onPrinted: (BuildContext context) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document printed successfully'),
          ),
        );
      },
      onShared: (BuildContext context) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document shared successfully'),
          ),
        );
      },
    );
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => pdfWidget));
  }
}