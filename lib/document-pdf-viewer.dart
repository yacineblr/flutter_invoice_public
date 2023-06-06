import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_invoice/models/document.dart';
import 'package:flutter_invoice/models/invoice.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class DocumentPdfViewer {
  DocumentPdfViewer({
    required this.type,
    required this.paidWith,
    required this.products,
    required this.companyName,
    required this.companyLogoBase64,
    required this.companyAddress,
    required this.companyCity,
    required this.companyPostalCode,
    required this.companySiren,
    required this.companyEmail,
    required this.companyPhone,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerPostalCode,
    required this.customerCity,
    required this.customerCountry,
    required this.invoiceReference,
    required this.invoiceDate,
    required this.tax
  });

  final DocumentType type;
  final InvoicePaidMethod? paidWith;
  final List<DocumentProduct> products;
  final String companyName;
  final String companyLogoBase64;
  final String companyAddress;
  final String companyCity;
  final String companyPostalCode;
  final String companySiren;
  final String companyEmail;
  final String companyPhone;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerAddress;
  final String customerPostalCode;
  final String customerCity;
  final String customerCountry;
  final String invoiceReference;
  final String invoiceDate;
  final double tax;
  final PdfColor baseColor = PdfColor.fromHex("4D95D7");
  final PdfColor accentColor = PdfColors.blueGrey900;

  static const _darkColor = PdfColors.blueGrey800;
  static const _lightColor = PdfColors.white;

  PdfColor get _baseTextColor =>
      baseColor.luminance < 0.5 ? _lightColor : _darkColor;

  PdfColor get _accentTextColor =>
      baseColor.luminance < 0.5 ? _lightColor : _darkColor;

  double get _total =>
      products.map<double>((p) => p.total!).reduce((a, b) => a + b);

  double get _grandTotal => _total * (1 + tax);

  late final pw.ImageProvider _logo;

  late final String _bgShape;

  Future<Uint8List> buildPdf(PdfPageFormat pageFormat) async {
    // Create a PDF document.
    final doc = pw.Document();

    final font1 = await rootBundle.load('assets/roboto1.ttf');
    final font2 = await rootBundle.load('assets/roboto2.ttf');
    final font3 = await rootBundle.load('assets/roboto3.ttf');

    _logo = await imageFromAssetBundle('assets/mde-logo.png');
    _bgShape = await rootBundle.loadString('assets/invoice.svg');

    // Add page to the PDF
    doc.addPage(
      pw.MultiPage(
        pageTheme: _buildTheme(
          pageFormat,
          pw.Font.ttf(font1),
          pw.Font.ttf(font2),
          pw.Font.ttf(font3),
        ),
        header: _buildHeader,
        footer: _buildFooter,
        build: (context) => [
          _contentHeader(context),
          _contentTable(context),
          pw.SizedBox(height: 20),
          _contentFooter(context),
          pw.SizedBox(height: 20),
          // _termsAndConditions(context),
        ],
      ),
    );

    // Return the PDF file content
    return doc.save();
  }

  pw.Widget _buildHeader(pw.Context context) {
    var title;
    switch (type) {
      case DocumentType.quotes:
        title = "devis";
        break;
      case DocumentType.paid:
        title = paidWith != null ? "facture acquittée" : "facture";
        break;
      default:
        title = "Type non défini";
    }
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  
                  pw.Row(children: [
                    pw.Expanded(
                      child: pw.Text('$companyName',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Expanded(
                      child: pw.Container(
                        alignment: pw.Alignment.center,
                        padding: const pw.EdgeInsets.all(8),
                        height: 72,
                        child: _logo != null
                            ? pw.Image(
                                pw.MemoryImage(base64Decode(
                                    companyLogoBase64.split(',').last)),
                                height: 72,
                                fit: pw.BoxFit.contain
                              )
                            : pw.PdfLogo(),
                      )
                    )
                  ]),
                  pw.Row(children: [
                    pw.Expanded(
                      child: pw.Text('$companyAddress $companyPostalCode $companyCity',
                          style: pw.TextStyle(fontSize: 9)),
                    )
                  ]),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Container(
                            child: pw.Text("tel: $companyPhone ",
                                style: pw.TextStyle(fontSize: 9))),
                        pw.SizedBox(width: 1.5),
                        pw.Container(
                            child: pw.Text(companyEmail,
                                style: pw.TextStyle(fontSize: 9))),
                        pw.SizedBox(width: 1.5),
                        pw.Container(
                            child: pw.Text("RCS " + companySiren,
                                style: pw.TextStyle(fontSize: 9))),
                      ]),
                  pw.SizedBox(height: 10)
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 90,
                    // color: PdfColors.pink,
                    padding: const pw.EdgeInsets.only(left: 20),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      title.toUpperCase(),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        color: baseColor,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        if (context.pageNumber > 1) pw.SizedBox(height: 20)
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Container(
          height: 20,
          width: 100,
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.pdf417(),
            data: 'référence $invoiceReference',
          ),
        ),
        pw.Text(
          'Page ${context.pageNumber}/${context.pagesCount}',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.white,
          ),
        ),
      ],
    );
  }

  pw.PageTheme _buildTheme(
      PdfPageFormat pageFormat, pw.Font base, pw.Font bold, pw.Font italic) {
    return pw.PageTheme(
      pageFormat: pageFormat,
      theme: pw.ThemeData.withFont(
        base: base,
        bold: bold,
        italic: italic,
      ),
      buildBackground: (context) => pw.FullPage(
        ignoreMargins: true,
        child: pw.SvgImage(svg: _bgShape),
      ),
    );
  }

  pw.Widget _contentHeader(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Container(
            decoration: pw.BoxDecoration(
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
              color: accentColor,
            ),
            padding: const pw.EdgeInsets.only(
                left: 10, top: 10, bottom: 10, right: 10),
            alignment: pw.Alignment.centerLeft,
            height: 50,
            child: pw.DefaultTextStyle(
              style: pw.TextStyle(
                color: _accentTextColor,
                fontSize: 11,
              ),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Référence : $invoiceReference'),
                  // pw.Text(invoiceReference, style: pw.TextStyle(fontSize: 10)),
                  pw.Text('Date : $invoiceDate'),
                  // pw.Text(invoiceDate),
                ],
              ),
            ),
          ),
        ),
        pw.SizedBox(width: 50),
        pw.Expanded(
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Container(
                  height: 70,
                  child: pw.RichText(
                      text: pw.TextSpan(
                          text: '$customerName\n',
                          style: pw.TextStyle(
                              color: _darkColor,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12),
                          children: [
                        pw.TextSpan(
                          text: '\n',
                          style: pw.TextStyle(
                            fontSize: 5,
                          ),
                        ),
                        pw.TextSpan(
                          text: "$customerAddress\n",
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 10),
                        ),
                        pw.TextSpan(
                          text:
                              "$customerPostalCode $customerCity - $customerCountry\n",
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 10),
                        ),
                        pw.TextSpan(
                          text: (customerPhone != null &&
                                      customerPhone.length > 1
                                  ? "$customerPhone "
                                  : "") +
                              (customerEmail != null && customerEmail.length > 1
                                  ? "$customerEmail "
                                  : ""),
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal, fontSize: 10),
                        ),
                      ])),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _contentFooter(pw.Context context) {
    String paidWithLabel = "payer";
    if (paidWith != null) {
      if (paidWith == InvoicePaidMethod.CB) {
        paidWithLabel = "payé par CB";
      }
      if (paidWith == InvoicePaidMethod.Cash) {
        paidWithLabel = "payé par espèces";
      }
      if (paidWith == InvoicePaidMethod.Check) {
        paidWithLabel = "payé par chèques";
      }
      if (paidWith == InvoicePaidMethod.Check) {
        paidWithLabel = "payé par chèques";
      }
    }
    String billingLabel;
    switch (type) {
      case DocumentType.quotes:
        billingLabel = "total";
        break;
      case DocumentType.paid:
        billingLabel= paidWith != null ? "$paidWithLabel" : 'à payer';
        break;
      default:
        billingLabel = "Type non défini";
    }
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(flex: 11, child: pw.Container()),
        pw.Expanded(
          flex: 9,
          child: pw.DefaultTextStyle(
            style: const pw.TextStyle(
              fontSize: 10,
              color: _darkColor,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL H.T :'),
                    pw.Text(DocumentProduct.formatCurrency(_total)),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TVA :'),
                    pw.Text('${(tax * 100)}%'),
                  ],
                ),
                pw.Divider(color: accentColor),
                pw.DefaultTextStyle(
                  style: pw.TextStyle(
                    color: baseColor,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          '${billingLabel.toUpperCase()} ',
                        ),
                      ),
                      pw.Text(DocumentProduct.formatCurrency(_grandTotal)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Transform(
                  transform: pw.Transform.rotate(angle: 0.100).transform,
                  child: pw.Container(
                    child: pw.Column(
                      children: [
                        pw.Text(companyName),
                        pw.Text(companyAddress),
                        pw.Text('$companyPostalCode $companyCity'),
                        pw.Text(companyPhone),
                        pw.Text('SIRET $companySiren')
                      ]
                    )
                  )
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _termsAndConditions(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: accentColor)),
                ),
                padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
                child: pw.Text(
                  'Terms & Conditions',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: baseColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Text(
                pw.LoremText().paragraph(40),
                textAlign: pw.TextAlign.justify,
                style: const pw.TextStyle(
                  fontSize: 6,
                  lineSpacing: 2,
                  color: _darkColor,
                ),
              ),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.SizedBox(),
        ),
      ],
    );
  }

  pw.Widget _contentTable(pw.Context context) {
    const tableHeaders = [
      'Désignation',
      'Quantité',
      'P.U H.T',
    ];

    return pw.Table.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
        color: baseColor,
      ),
      headerHeight: 25,
      cellHeight: 40,
      columnWidths: {
        0: pw.IntrinsicColumnWidth(flex: 13),
        1: pw.IntrinsicColumnWidth(flex: 2),
        2: pw.IntrinsicColumnWidth(flex: 2),
      },
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
      },
      headerStyle: pw.TextStyle(
        color: _baseTextColor,
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(
        color: _darkColor,
        fontSize: 10,
      ),
      rowDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: accentColor,
            width: .5,
          ),
        ),
      ),
      headers: List<String>.generate(
        tableHeaders.length,
        (col) => tableHeaders[col],
      ),
      data: List<List<String>>.generate(
        products.length,
        (row) => List<String>.generate(
          tableHeaders.length,
          (col) => products[row].getIndex(col),
        ),
      ),
    );
  }
}