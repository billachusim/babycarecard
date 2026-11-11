import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../features/care_card/presentation/care_card_providers.dart';

class PdfService {
  static Future<void> generateAndPrint(ChildDetails details) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('BABY CARE CARD: ${details.child.name.toUpperCase()}'),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Age group: ${details.child.ageGroup}'),
              pw.Text('Allergies: ${details.child.allergies ?? "None noted"}'),
              pw.SizedBox(height: 20),
              if (details.child.personality != null) pw.Text('Personality: ${details.child.personality}'),
              if (details.child.importantNotes != null) pw.Text('Important: ${details.child.importantNotes}'),
              pw.SizedBox(height: 20),
              pw.Header(level: 1, child: pw.Text('Feeding')),
              ...details.feeding.map((f) => pw.Bullet(text: '${f.name}: ${f.time} - ${f.amount}')),
              pw.SizedBox(height: 20),
              pw.Header(level: 1, child: pw.Text('Routine')),
              ...details.routines.map((r) => pw.Bullet(text: '${r.title}: ${r.instructions}')),
              pw.SizedBox(height: 20),
              if (details.medications.isNotEmpty) ...[
                pw.Header(level: 1, child: pw.Text('Medications (check doses against the label)')),
                ...details.medications.map((m) => pw.Bullet(
                    text: [m.name, m.instructions, m.time, m.frequency, m.notes]
                        .where((s) => s != null && s.isNotEmpty)
                        .join(' - '))),
                pw.SizedBox(height: 20),
              ],
              if (details.pediatricians.isNotEmpty) ...[
                pw.Header(level: 1, child: pw.Text('Pediatrician')),
                ...details.pediatricians.map((d) => pw.Bullet(
                    text: [d.name, d.clinic, d.phone, d.address]
                        .where((s) => s != null && s.isNotEmpty)
                        .join(' - '))),
                pw.SizedBox(height: 20),
              ],
              pw.Header(level: 1, child: pw.Text('Emergency')),
              ...details.emergencyContacts.map((c) => pw.Bullet(text: '${c.name}: ${c.phone}')),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
