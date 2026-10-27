import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'sick_leave_api.dart';

String certificateDate(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

/// Saves a read-only copy of the certificate.
///
/// The PDF uses a basic Latin font. If a name cannot be drawn, a text file
/// is saved instead so the same words can still be downloaded.
Future<void> downloadCertificate(SickLeaveCertificate certificate) async {
  final name = certificate.certificateNumber;
  Uint8List bytes;
  var filename = '$name.pdf';
  var mime = 'application/pdf';
  try {
    bytes = await _pdf(certificate);
  } catch (_) {
    bytes = Uint8List.fromList(utf8.encode(_plain(certificate)));
    filename = '$name.txt';
    mime = 'text/plain';
  }
  final location = await getSaveLocation(suggestedName: filename);
  if (location == null) {
    return;
  }
  final file = XFile.fromData(bytes, mimeType: mime, name: filename);
  await file.saveTo(location.path);
}

Future<Uint8List> _pdf(SickLeaveCertificate certificate) async {
  final document = pw.Document();
  document.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Digital Platform for Telemedicine',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 24),
            pw.Center(
              child: pw.Text(
                'SICK CERTIFICATION',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Center(child: pw.Text('Reference No. ${certificate.certificateNumber}')),
            pw.SizedBox(height: 20),
            pw.Text('To whom it may concern:'),
            pw.SizedBox(height: 16),
            _line('I,', certificate.doctor.fullName),
            _line('Hereby certify that', certificate.patient.fullName),
            _line('Patient address', certificate.patientAddress),
            _line('Is unfit for', certificate.unfitFor),
            _line('From', certificateDate(certificate.validFrom)),
            _line('Until', certificateDate(certificate.validTo)),
            _line('Number of days', '${certificate.dayCount}'),
            _line('Sickness', certificate.summary),
            pw.SizedBox(height: 24),
            _line('Date of issue', certificateDate(certificate.issuedOn)),
            _line("Doctor's signature", certificate.signature),
            _line('Licence no.', certificate.doctor.licenseNumber),
          ],
        );
      },
    ),
  );
  return document.save();
}

pw.Widget _line(String label, String value) {
  final shown = value.trim().isEmpty ? '-' : value.trim();
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.TextSpan(text: shown),
        ],
      ),
    ),
  );
}

String _plain(SickLeaveCertificate certificate) {
  return [
    'Digital Platform for Telemedicine',
    'SICK CERTIFICATION',
    'Reference No. ${certificate.certificateNumber}',
    'To whom it may concern:',
    'I, ${certificate.doctor.fullName}',
    'Hereby certify that ${certificate.patient.fullName}',
    'Patient address ${certificate.patientAddress}',
    'Is unfit for ${certificate.unfitFor}',
    'From ${certificateDate(certificate.validFrom)}',
    'Until ${certificateDate(certificate.validTo)}',
    'Number of days ${certificate.dayCount}',
    'Sickness ${certificate.summary}',
    'Date of issue ${certificateDate(certificate.issuedOn)}',
    "Doctor's signature ${certificate.signature}",
    'Licence no. ${certificate.doctor.licenseNumber}',
  ].join('\n');
}
