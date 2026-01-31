import 'dart:io';
import 'package:core/modules/opportunities/models/insurance_opportunity_model.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGeneratorService {
  // ===========================================================================
  // CURRENCY FORMATTING - "Rs. 1,50,000" (No Symbols)
  // ===========================================================================
  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,##,###', 'en_IN');
    if (amount >= 10000000) {
      // 1 Cr+
      return 'Rs. ${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      // 1 Lakh+
      return 'Rs. ${(amount / 100000).toStringAsFixed(2)} L';
    }
    return 'Rs. ${formatter.format(amount.round())}';
  }

  static String formatCurrencyFull(double amount) {
    final formatter = NumberFormat('#,##,###', 'en_IN');
    return 'Rs. ${formatter.format(amount.round())}';
  }

  // ===========================================================================
  // SAVE AND OPEN PDF HELPER
  // ===========================================================================
  static Future<void> _saveAndOpenPdf(pw.Document pdf, String filename) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$filename');
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
  }

  // ===========================================================================
  // SIP STEP-UP PROPOSAL
  // ===========================================================================
  static Future<void> generateSipProposal({
    required String clientName,
    required double currentSip,
    required double stepUpPercent,
  }) async {
    final pdf = pw.Document();

    // Calculate corpus projections over 10 years (12% annual returns)
    const double annualReturn = 12.0;
    const int years = 10;

    final List<Map<String, dynamic>> projectionData = [];
    for (int year = 1; year <= years; year++) {
      final flatCorpus = _calculateSipCorpus(currentSip, annualReturn, year);
      final steppedCorpus = _calculateSteppedSipCorpus(
          currentSip, stepUpPercent, annualReturn, year);

      projectionData.add({
        'year': year,
        'flatSip': flatCorpus,
        'steppedSip': steppedCorpus,
        'extraWealth': steppedCorpus - flatCorpus,
      });
    }

    final extraWealth = projectionData.last['extraWealth'] as double;
    final finalFlat = projectionData.last['flatSip'] as double;
    final finalStepped = projectionData.last['steppedSip'] as double;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#6725F4'),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'WEALTH GROWTH PROPOSAL',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  clientName,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Current SIP Info Row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoCard(
                  'Current Monthly SIP', formatCurrencyFull(currentSip)),
              _buildInfoCard('Proposed Step-up',
                  '${stepUpPercent.toStringAsFixed(0)}% / Year'),
              _buildInfoCard('Projection Period', '$years Years'),
            ],
          ),
          pw.SizedBox(height: 24),

          // Main Value Proposition
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F0FDF4'),
              border:
                  pw.Border.all(color: PdfColor.fromHex('#22C55E'), width: 2),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'EXTRA WEALTH YOU COULD CREATE',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColor.fromHex('#166534'),
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  formatCurrency(extraWealth),
                  style: pw.TextStyle(
                    fontSize: 42,
                    color: PdfColor.fromHex('#166534'),
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'By increasing your SIP by just ${stepUpPercent.toStringAsFixed(0)}% annually',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColor.fromHex('#166534'),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Comparison Summary
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F9FAFB'),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text('Without Step-up',
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        formatCurrency(finalFlat),
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#ECFDF5'),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                          'With ${stepUpPercent.toStringAsFixed(0)}% Step-up',
                          style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColor.fromHex('#059669'))),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        formatCurrency(finalStepped),
                        style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#059669')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),

          // Projection Table
          pw.Text(
            'Year-wise Projection (Assuming 12% p.a. returns)',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration:
                pw.BoxDecoration(color: PdfColor.fromHex('#F3F4F6')),
            cellAlignment: pw.Alignment.centerRight,
            headerAlignment: pw.Alignment.center,
            headers: [
              'Year',
              'Flat SIP Value',
              'Step-up Value',
              'Extra Wealth'
            ],
            data: projectionData.map((row) {
              return [
                'Year ${row['year']}',
                formatCurrencyFull(row['flatSip']),
                formatCurrencyFull(row['steppedSip']),
                formatCurrencyFull(row['extraWealth']),
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 24),

          // Motivational Hook
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#FFFBEB'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              '"Small changes today = Massive wealth tomorrow."',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#B45309'),
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 16),

          // Disclaimer
          pw.Text(
            '* Projections assume 12% annual returns. Actual returns may vary. Past performance is not indicative of future results.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    final safeName = clientName.replaceAll(' ', '_');
    await _saveAndOpenPdf(pdf, 'SIP_Proposal_$safeName.pdf');
  }

  // ===========================================================================
  // INSURANCE PROTECTION PROPOSAL
  // ===========================================================================
  static Future<void> generateInsuranceProposal(
      InsuranceOpportunity client) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header - RED for Risk
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#DC2626'),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'ASSET PROTECTION PLAN',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    client.userName,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 32),

            // The Big Stat - Wealth at Risk
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(28),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FEF2F2'),
                border:
                    pw.Border.all(color: PdfColor.fromHex('#FCA5A5'), width: 2),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'WEALTH AT RISK',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#991B1B'),
                      letterSpacing: 1,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    formatCurrency(client.mfCurrentValue),
                    style: pw.TextStyle(
                      fontSize: 48,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#DC2626'),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Current Mutual Fund Value',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColor.fromHex('#991B1B'),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Narrative
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F9FAFB'),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Why This Matters',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'At age ${client.age}, liquidating your mutual fund investments for medical emergencies or unforeseen events would destroy years of compounding growth.',
                    style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.6),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'A Term Insurance Plan protects your family AND preserves your investment portfolio.',
                    style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        lineSpacing: 1.6),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Cost to Protect - GREEN
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F0FDF4'),
                border:
                    pw.Border.all(color: PdfColor.fromHex('#22C55E'), width: 2),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'COST TO PROTECT',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#166534'),
                          letterSpacing: 1,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Recommended Term Plan Premium',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                  pw.Text(
                    '${formatCurrencyFull(client.expectedPremium)}/year',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#166534'),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Client Details Summary
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard('Client Age', '${client.age} years'),
                _buildInfoCard('Current Status', client.insuranceStatus),
              ],
            ),

            pw.Spacer(),

            // Footer
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FEF3C7'),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                'This is an indicative proposal. Actual premium may vary based on health assessment and chosen sum assured.',
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
              ),
            ),
          ],
        ),
      ),
    );

    final safeName = client.userName.replaceAll(' ', '_');
    await _saveAndOpenPdf(pdf, 'Insurance_Proposal_$safeName.pdf');
  }

  // ===========================================================================
  // HELPER WIDGETS
  // ===========================================================================
  static pw.Widget _buildInfoCard(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.symmetric(horizontal: 4),
        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#F3F4F6'),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey600,
                letterSpacing: 0.5,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SIP CALCULATION HELPERS
  // ===========================================================================
  static double _calculateSipCorpus(
      double monthlySip, double annualReturn, int years) {
    final monthlyRate = annualReturn / 12 / 100;
    final months = years * 12;
    // FV = P * [((1 + r)^n - 1) / r] * (1 + r)
    final fv = monthlySip *
        (((_pow(1 + monthlyRate, months) - 1) / monthlyRate) *
            (1 + monthlyRate));
    return fv;
  }

  static double _calculateSteppedSipCorpus(
      double initialSip, double stepUpPercent, double annualReturn, int years) {
    double totalCorpus = 0;
    double currentSip = initialSip;
    final monthlyRate = annualReturn / 12 / 100;

    for (int year = 1; year <= years; year++) {
      final remainingMonths = (years - year + 1) * 12;
      for (int month = 1; month <= 12; month++) {
        final monthsRemaining = remainingMonths - month + 1;
        totalCorpus += currentSip * _pow(1 + monthlyRate, monthsRemaining);
      }
      currentSip = currentSip * (1 + stepUpPercent / 100);
    }
    return totalCorpus;
  }

  static double _pow(double base, int exponent) {
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}
