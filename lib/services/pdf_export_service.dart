import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/resume_model.dart';
import '../models/template_model.dart';
import 'package:intl/intl.dart';

/// Renders a Resume into a print-ready, ATS-friendly single-column PDF.
/// Each ResumeTemplateId gets its own layout so what the user sees in the
/// in-app preview matches the exported file exactly.
class PdfExportService {
  final _dateFmt = DateFormat('MMM yyyy');

  Future<File> generatePdf(Resume resume, {bool isLetter = true}) async {
    final doc = pw.Document();
    final accent = resume.customAccentColorHex != null
        ? PdfColor.fromHex(resume.customAccentColorHex!)
        : _accentFor(resume.templateId);

    doc.addPage(
      pw.Page(
        pageFormat: isLetter ? PdfPageFormat.letter : PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (context) => resume.templateId == ResumeTemplateId.modern
            ? _buildModernLayout(resume, accent)
            : _buildStandardLayout(resume, accent),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final safeName = resume.fullName.isEmpty ? 'resume' : resume.fullName.replaceAll(' ', '_');
    final file = File('${dir.path}/${safeName}_resume.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  /// Triggers the system print/save dialog. On Web, this downloads the PDF.
  /// On Mobile, it opens the "Save as PDF" / "Print" interface.
  Future<void> downloadPdf(Resume resume, {bool isLetter = true}) async {
    final doc = pw.Document();
    final accent = resume.customAccentColorHex != null
        ? PdfColor.fromHex(resume.customAccentColorHex!)
        : _accentFor(resume.templateId);

    doc.addPage(
      pw.Page(
        pageFormat: isLetter ? PdfPageFormat.letter : PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (context) => resume.templateId == ResumeTemplateId.modern
            ? _buildModernLayout(resume, accent)
            : _buildStandardLayout(resume, accent),
      ),
    );

    final safeName = resume.fullName.isEmpty ? 'resume' : resume.fullName.replaceAll(' ', '_');
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: '${safeName}_resume.pdf',
    );
  }

  /// Generates the resume and saves it as a high-quality PNG image.
  Future<void> downloadAsImage(Resume resume, {bool isLetter = true}) async {
    final doc = pw.Document();
    final accent = resume.customAccentColorHex != null
        ? PdfColor.fromHex(resume.customAccentColorHex!)
        : _accentFor(resume.templateId);

    doc.addPage(
      pw.Page(
        pageFormat: isLetter ? PdfPageFormat.letter : PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (context) => resume.templateId == ResumeTemplateId.modern
            ? _buildModernLayout(resume, accent)
            : _buildStandardLayout(resume, accent),
      ),
    );

    final safeName = resume.fullName.isEmpty ? 'resume' : resume.fullName.replaceAll(' ', '_');
    
    // Rasterize the first page of the PDF at high resolution (300 DPI)
    await for (var page in Printing.raster(await doc.save(), pages: [0], dpi: 300)) {
      final pngBytes = await page.toPng();
      
      // On Web, Printing.sharePdf works like a download for raw bytes too
      await Printing.sharePdf(
        bytes: pngBytes,
        filename: '${safeName}_resume.png',
      );
    }
  }

  Future<void> shareOrPrint(File file) async {
    await Printing.sharePdf(bytes: await file.readAsBytes(), filename: file.path.split('/').last);
  }

  Future<void> shareViaSystemSheet(File file) async {
    await Share.shareXFiles([XFile(file.path)]);
  }

  PdfColor _accentFor(ResumeTemplateId id) {
    switch (id) {
      case ResumeTemplateId.classic:
        return PdfColor.fromHex('#141A20');
      case ResumeTemplateId.modern:
        return PdfColor.fromHex('#2E6E58');
      case ResumeTemplateId.minimal:
        return PdfColor.fromHex('#4B5560');
    }
  }

  // Classic & Minimal: single column, serif headings.
  pw.Widget _buildStandardLayout(Resume r, PdfColor accent) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(r.fullName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(
          [r.email, r.phone, r.location].where((s) => s.isNotEmpty).join('  ·  '),
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 14),
        if (r.summary.isNotEmpty) ..._section('Summary', accent, [pw.Text(r.summary, style: const pw.TextStyle(fontSize: 10.5))]),
        if (r.experience.isNotEmpty)
          ..._section('Experience', accent, r.experience.map((e) => _experienceBlock(e)).toList()),
        if (r.education.isNotEmpty)
          ..._section('Education', accent, r.education.map((e) => _educationBlock(e)).toList()),
        if (r.skills.isNotEmpty)
          ..._section('Skills', accent, [
            pw.Wrap(
              spacing: 6,
              runSpacing: 6,
              children: r.skills
                  .map((s) => pw.Text('${s.name}   ', style: const pw.TextStyle(fontSize: 10.5)))
                  .toList(),
            )
          ]),
      ],
    );
  }

  // Modern: sidebar with contact/skills, main column with experience.
  pw.Widget _buildModernLayout(Resume r, PdfColor accent) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 150,
          padding: const pw.EdgeInsets.only(right: 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(r.fullName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: accent)),
              pw.SizedBox(height: 8),
              pw.Text(r.email, style: const pw.TextStyle(fontSize: 9)),
              pw.Text(r.phone, style: const pw.TextStyle(fontSize: 9)),
              pw.Text(r.location, style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 14),
              if (r.skills.isNotEmpty) ...[
                pw.Text('SKILLS', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: accent)),
                pw.SizedBox(height: 4),
                ...r.skills.map((s) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 2),
                      child: pw.Text(s.name, style: const pw.TextStyle(fontSize: 9)),
                    )),
              ],
              if (r.education.isNotEmpty) ...[
                pw.SizedBox(height: 14),
                pw.Text('EDUCATION', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: accent)),
                pw.SizedBox(height: 4),
                ...r.education.map((e) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(e.degree, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                          pw.Text(e.institution, style: const pw.TextStyle(fontSize: 8.5)),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (r.summary.isNotEmpty) ..._section('Summary', accent, [pw.Text(r.summary, style: const pw.TextStyle(fontSize: 10.5))]),
              if (r.experience.isNotEmpty)
                ..._section('Experience', accent, r.experience.map((e) => _experienceBlock(e)).toList()),
            ],
          ),
        ),
      ],
    );
  }

  List<pw.Widget> _section(String title, PdfColor accent, List<pw.Widget> children) {
    return [
      pw.Text(title.toUpperCase(),
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: accent, letterSpacing: 1)),
      pw.SizedBox(height: 2),
      pw.Divider(color: accent, thickness: 0.7),
      pw.SizedBox(height: 6),
      ...children,
      pw.SizedBox(height: 12),
    ];
  }

  pw.Widget _experienceBlock(dynamic e) {
    final dateRange =
        '${_dateFmt.format(e.startDate)} – ${e.endDate == null ? 'Present' : _dateFmt.format(e.endDate)}';
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('${e.jobTitle} — ${e.company}',
                  style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold)),
              pw.Text(dateRange, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            ],
          ),
          pw.SizedBox(height: 3),
          for (final bullet in e.bullets)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 2, left: 4),
              child: pw.Text('•  $bullet', style: const pw.TextStyle(fontSize: 9.8)),
            ),
        ],
      ),
    );
  }

  pw.Widget _educationBlock(dynamic e) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('${e.degree} in ${e.fieldOfStudy}',
                  style: pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold)),
              pw.Text(e.institution, style: const pw.TextStyle(fontSize: 9.5)),
            ],
          ),
          pw.Text(_dateFmt.format(e.startDate), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        ],
      ),
    );
  }
}
