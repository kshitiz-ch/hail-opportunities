import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:flutter/material.dart';

/// Specialized data table for SIP+SWP calculator with grouped column headers
class SipSwpDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Color? headerColor;
  final Color? evenRowColor;
  final Color? oddRowColor;

  const SipSwpDataTable({
    Key? key,
    required this.data,
    this.headerColor,
    this.evenRowColor,
    this.oddRowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: context.titleMedium?.copyWith(color: Colors.grey),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // First header row with grouped headers
              _buildGroupedHeaderRow(context),
              // Second header row with individual column headers
              _buildDetailHeaderRow(context),
              // Data rows
              ..._buildDataRows(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedHeaderRow(BuildContext context) {
    return Container(
      color: headerColor ?? Colors.grey[50],
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Age column (spans 2 rows)
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.center,
              child: Text(
                '',
                style: context.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            // Year Beginning Corpus column (spans 2 rows)
            Container(
              width: 160,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.center,
              child: Text(
                '',
                style: context.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            // SIP Amount grouped header
            Container(
              width: 240,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey[300]!, width: 1),
                  right: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Text(
                'SIP Amount',
                style: context.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            // Withdrawal grouped header (spans Monthly, Yearly, and Year End Corpus)
            Container(
              width: 400,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Text(
                'Withdrawal',
                style: context.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailHeaderRow(BuildContext context) {
    return Container(
      color: headerColor ?? Colors.grey[50],
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildHeaderCell(context, 'Age', 80, isFirst: true),
            _buildHeaderCell(context, 'Year Beginning\nCorpus', 160),
            _buildHeaderCell(context, 'Monthly', 120, hasBorder: true),
            _buildHeaderCell(context, 'Yearly', 120, hasBorder: false),
            _buildHeaderCell(context, 'Monthly', 120, hasBorder: true),
            _buildHeaderCell(context, 'Yearly', 120, hasBorder: false),
            _buildHeaderCell(context, 'Year End Corpus', 160, hasBorder: false),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(
    BuildContext context,
    String label,
    double width, {
    bool isFirst = false,
    bool hasBorder = false,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1),
          left: hasBorder
              ? BorderSide(color: Colors.grey[300]!, width: 0.5)
              : BorderSide.none,
        ),
      ),
      child: Text(
        label,
        style: context.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<Widget> _buildDataRows(BuildContext context) {
    return List.generate(data.length, (index) {
      final rowData = data[index];
      final isEven = index.isEven;
      final bgColor = isEven
          ? (evenRowColor ?? Colors.white)
          : (oddRowColor ?? ColorConstants.borderColor.withOpacity(0.2));

      return Container(
        color: bgColor,
        child: IntrinsicHeight(
          child: Row(
            children: [
              _buildDataCell(
                context,
                rowData['year_label']?.toString() ?? '',
                80,
                isBold: true,
              ),
              _buildDataCell(
                context,
                WealthyAmount.currencyFormat(
                    rowData['year_start_corpus'] ?? 0, 0),
                160,
              ),
              _buildDataCell(
                context,
                WealthyAmount.currencyFormat(rowData['monthly_sip'] ?? 0, 0),
                120,
                hasBorder: true,
              ),
              _buildDataCell(
                context,
                WealthyAmount.currencyFormat(rowData['yearly_sip'] ?? 0, 0),
                120,
              ),
              _buildDataCell(
                context,
                WealthyAmount.currencyFormat(
                    rowData['monthly_withdrawal'] ?? 0, 0),
                120,
                hasBorder: true,
              ),
              _buildDataCell(
                context,
                WealthyAmount.currencyFormat(
                    rowData['yearly_withdrawal'] ?? 0, 0),
                120,
              ),
              _buildDataCell(
                context,
                WealthyAmount.currencyFormat(rowData['corpus'] ?? 0, 0),
                160,
                isBold: true,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDataCell(
    BuildContext context,
    String value,
    double width, {
    bool isBold = false,
    bool hasBorder = false,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 0.5),
          left: hasBorder
              ? BorderSide(color: Colors.grey[300]!, width: 0.5)
              : BorderSide.none,
        ),
      ),
      child: Text(
        value,
        style: context.titleLarge?.copyWith(
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          color: isBold ? Colors.black : Colors.black87,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }
}
