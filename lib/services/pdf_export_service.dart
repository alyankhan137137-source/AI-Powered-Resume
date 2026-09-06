import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/resume_model.dart';
import '../models/template_model.dart';
import 'package:intl/intl.dart';

/// Renders a Resume into a print-ready, ATS-friendly PDF.
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
        build: (context) => _buildLayout(resume, accent),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final safeName = resume.fullName.isEmpty ? 'resume' : resume.fullName.replaceAll(' ', '_');
    final file = File('${dir.path}/${safeName}_resume.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  Future<void> downloadPdf(Resume resume, {bool isLetter = true}) async {
    final doc = pw.Document();
    final accent = resume.customAccentColorHex != null
        ? PdfColor.fromHex(resume.customAccentColorHex!)
        : _accentFor(resume.templateId);

    doc.addPage(
      pw.Page(
        pageFormat: isLetter ? PdfPageFormat.letter : PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (context) => _buildLayout(resume, accent),
      ),
    );

    final safeName = resume.fullName.isEmpty ? 'resume' : resume.fullName.replaceAll(' ', '_');
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: '${safeName}_resume.pdf',
    );
  }

  Future<void> downloadAsImage(Resume resume, {bool isLetter = true}) async {
    final doc = pw.Document();
    final accent = resume.customAccentColorHex != null
        ? PdfColor.fromHex(resume.customAccentColorHex!)
        : _accentFor(resume.templateId);

    doc.addPage(
      pw.Page(
        pageFormat: isLetter ? PdfPageFormat.letter : PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (context) => _buildLayout(resume, accent),
      ),
    );

    final safeName = resume.fullName.isEmpty ? 'resume' : resume.fullName.replaceAll(' ', '_');
    await for (var page in Printing.raster(await doc.save(), pages: [0], dpi: 300)) {
      final pngBytes = await page.toPng();
      await Printing.sharePdf(bytes: pngBytes, filename: '${safeName}_resume.png');
    }
  }

  Future<void> shareOrPrint(File file) async {
    await Printing.sharePdf(bytes: await file.readAsBytes(), filename: file.path.split('/').last);
  }

  Future<void> shareViaSystemSheet(File file) async {
    await Share.shareXFiles([XFile(file.path)]);
  }

  PdfColor _accentFor(ResumeTemplateId id) {
    final template = ResumeTemplate.all.firstWhere((t) => t.id == id);
    return PdfColor.fromHex(template.accentColorHex);
  }

  pw.Widget _buildLayout(Resume r, PdfColor accent) {
    switch (r.templateId) {
      case ResumeTemplateId.classic:
      case ResumeTemplateId.minimal:
      case ResumeTemplateId.academic:
        return _buildStandardLayout(r, accent);
      case ResumeTemplateId.modern:
      case ResumeTemplateId.creative:
        return _buildModernLayout(r, accent);
      case ResumeTemplateId.executive:
      case ResumeTemplateId.professionalBold:
        return _buildBoldLayout(r, accent);
      case ResumeTemplateId.techClean:
        return _buildTechLayout(r, accent);
      case ResumeTemplateId.compact:
        return _buildCompactLayout(r, accent);
      case ResumeTemplateId.elegant:
        return _buildElegantLayout(r, accent);
    }
  }

  // Grouped Layouts to keep code clean while providing variety
  pw.Widget _buildStandardLayout(Resume r, PdfColor accent) {
    final isAcademic = r.templateId == ResumeTemplateId.academic;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(r.fullName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: isAcademic ? accent : PdfColors.black)),
        pw.SizedBox(height: 4),
        pw.Text(
          [r.email, r.phone, r.location, r.linkedinUrl].where((s) => s != null && s.isNotEmpty).join('  ·  '),
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 14),
        if (r.summary.isNotEmpty) ..._section('Summary', accent, [pw.Text(r.summary, style: pw.TextStyle(fontSize: 10))]),
        if (r.experience.isNotEmpty) ..._section('Experience', accent, r.experience.map((e) => _experienceBlock(e)).toList()),
        if (r.education.isNotEmpty) ..._section('Education', accent, r.education.map((e) => _educationBlock(e)).toList()),
        if (r.skills.isNotEmpty)
          ..._section('Skills', accent, [
            pw.Wrap(
              spacing: 6,
              runSpacing: 6,
              children: r.skills.map((s) => pw.Text('${s.name}   ', style: pw.TextStyle(fontSize: 10))).toList(),
            )
          ]),
      ],
    );
  }

  pw.Widget _buildModernLayout(Resume r, PdfColor accent) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 160,
          padding: const pw.EdgeInsets.only(right: 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(r.fullName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: accent)),
              pw.SizedBox(height: 8),
              pw.Text(r.email, style: pw.TextStyle(fontSize: 8.5)),
              pw.Text(r.phone, style: pw.TextStyle(fontSize: 8.5)),
              pw.Text(r.location, style: pw.TextStyle(fontSize: 8.5)),
              pw.SizedBox(height: 20),
              if (r.skills.isNotEmpty) ...[
                pw.Text('SKILLS', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: accent)),
                pw.SizedBox(height: 6),
                ...r.skills.map((s) => pw.Padding(padding: const pw.EdgeInsets.only(bottom: 3), child: pw.Text(s.name, style: pw.TextStyle(fontSize: 9)))),
              ],
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (r.summary.isNotEmpty) ..._section('About Me', accent, [pw.Text(r.summary, style: pw.TextStyle(fontSize: 10))]),
              if (r.experience.isNotEmpty) ..._section('Work History', accent, r.experience.map((e) => _experienceBlock(e)).toList()),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildBoldLayout(Resume r, PdfColor accent) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          color: accent,
          width: double.infinity,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(r.fullName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
              pw.Text(r.targetJobTitle, style: pw.TextStyle(fontSize: 14, color: PdfColors.white)),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (r.summary.isNotEmpty) ..._section('Objective', accent, [pw.Text(r.summary, style: pw.TextStyle(fontSize: 10))]),
              if (r.experience.isNotEmpty) ..._section('Professional Experience', accent, r.experience.map((e) => _experienceBlock(e)).toList()),
              if (r.skills.isNotEmpty)
                ..._section('Core Competencies', accent, [
                  pw.Wrap(spacing: 12, runSpacing: 6, children: r.skills.map((s) => pw.Text(s.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))).toList())
                ]),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTechLayout(Resume r, PdfColor accent) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(r.fullName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: accent)),
                pw.Text(r.targetJobTitle, style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(r.email, style: pw.TextStyle(fontSize: 9)),
                pw.Text(r.linkedinUrl ?? '', style: pw.TextStyle(fontSize: 9)),
              ],
            ),
          ],
        ),
        pw.Divider(color: accent, thickness: 2),
        if (r.experience.isNotEmpty) ..._section('Projects & Experience', accent, r.experience.map((e) => _experienceBlock(e)).toList()),
        if (r.skills.isNotEmpty)
          ..._section('Technical Stack', accent, [
            pw.Wrap(spacing: 8, runSpacing: 8, children: r.skills.map((s) => pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: accent, width: 1), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4))),
              child: pw.Text(s.name, style: pw.TextStyle(fontSize: 8)),
            )).toList())
          ]),
      ],
    );
  }

  pw.Widget _buildCompactLayout(Resume r, PdfColor accent) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(r.fullName.toUpperCase(), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text('${r.email} | ${r.phone} | ${r.location}', style: pw.TextStyle(fontSize: 8)),
        pw.Divider(thickness: 0.5),
        if (r.experience.isNotEmpty) ..._section('Experience', accent, r.experience.map((e) => _experienceBlock(e, compact: true)).toList()),
        if (r.education.isNotEmpty) ..._section('Education', accent, r.education.map((e) => _educationBlock(e, compact: true)).toList()),
      ],
    );
  }

  pw.Widget _buildElegantLayout(Resume r, PdfColor accent) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(r.fullName, style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: accent)),
        pw.SizedBox(height: 4),
        pw.Text(r.targetJobTitle.toUpperCase(), style: pw.TextStyle(fontSize: 10, letterSpacing: 2)),
        pw.SizedBox(height: 8),
        pw.Text('${r.email}  •  ${r.phone}  •  ${r.location}', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 20),
        if (r.summary.isNotEmpty) pw.Text(r.summary, textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
        pw.SizedBox(height: 20),
        if (r.experience.isNotEmpty) ..._section('Professional Career', accent, r.experience.map((e) => _experienceBlock(e)).toList()),
      ],
    );
  }

  List<pw.Widget> _section(String title, PdfColor accent, List<pw.Widget> children) {
    return [
      pw.SizedBox(height: 12),
      pw.Text(title.toUpperCase(), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: accent, letterSpacing: 1)),
      pw.Divider(color: accent, thickness: 1),
      pw.SizedBox(height: 4),
      ...children,
    ];
  }

  pw.Widget _experienceBlock(dynamic e, {bool compact = false}) {
    final dateRange = '${_dateFmt.format(e.startDate)} – ${e.endDate == null ? 'Present' : _dateFmt.format(e.endDate)}';
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: compact ? 6 : 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('${e.jobTitle} @ ${e.company}', style: pw.TextStyle(fontSize: compact ? 9 : 10.5, fontWeight: pw.FontWeight.bold)),
              pw.Text(dateRange, style: pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
            ],
          ),
          for (final bullet in e.bullets)
            pw.Padding(padding: const pw.EdgeInsets.only(left: 8, top: 2), child: pw.Text('• $bullet', style: pw.TextStyle(fontSize: compact ? 8.5 : 9.5))),
        ],
      ),
    );
  }

  pw.Widget _educationBlock(dynamic e, {bool compact = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: compact ? 4 : 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('${e.degree} in ${e.fieldOfStudy}, ${e.institution}', style: pw.TextStyle(fontSize: compact ? 8.5 : 10)),
          pw.Text(_dateFmt.format(e.startDate), style: pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }
}
