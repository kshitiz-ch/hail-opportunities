import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:flutter/material.dart';

/// Configuration for a data table column
class DataTableColumnConfig {
  final String key;
  final String label;
  final bool isCurrency;
  final bool isBold;
  final int? decimalPlaces;
  final String Function(dynamic value)? customFormatter;

  const DataTableColumnConfig({
    required this.key,
    required this.label,
    this.isCurrency = false,
    this.isBold = false,
    this.decimalPlaces,
    this.customFormatter,
  });
}

class InvestmentDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<DataTableColumnConfig> columns;
  final Color? headerColor;
  final Color? evenRowColor;
  final Color? oddRowColor;
  final bool stripedRows;
  final double? columnSpacing;
  final double? horizontalMargin;
  final double? headingRowHeight;
  final double? dataRowHeight;

  const InvestmentDataTable({
    Key? key,
    required this.data,
    required this.columns,
    this.headerColor,
    this.evenRowColor,
    this.oddRowColor,
    this.stripedRows = true,
    this.columnSpacing = 24,
    this.horizontalMargin = 12,
    this.headingRowHeight = 56,
    this.dataRowHeight = 56,
  }) : super(key: key);

  /// Factory constructor for investment/SIP table with monthly or yearly data
  factory InvestmentDataTable.investment({
    required List<Map<String, dynamic>> data,
    bool showMonthly = false,
    Color? headerColor,
    Color? evenRowColor,
    Color? oddRowColor,
  }) {
    return InvestmentDataTable(
      data: data,
      columns: [
        DataTableColumnConfig(
          key: showMonthly ? 'month' : 'year',
          label: showMonthly ? 'Month' : 'Year',
          isBold: true,
          customFormatter: (value) {
            final number = (value as num?)?.toInt() ?? 0;
            return showMonthly ? 'Month $number' : 'Year $number';
          },
        ),
        DataTableColumnConfig(
          key: 'investment',
          label: 'Total Investment',
          isCurrency: true,
          decimalPlaces: 0,
        ),
        DataTableColumnConfig(
          key: 'gain',
          label: 'Gains',
          isCurrency: true,
          decimalPlaces: 0,
          customFormatter: (value) {
            final gain = (value as num?) ?? 0.0;
            return WealthyAmount.currencyFormat(gain < 0 ? 0 : gain, 0);
          },
        ),
        DataTableColumnConfig(
          key: 'total_value',
          label: 'Total Value',
          isCurrency: true,
          isBold: true,
          decimalPlaces: 0,
        ),
      ],
      headerColor: headerColor,
      evenRowColor: evenRowColor,
      oddRowColor: oddRowColor,
    );
  }

  /// Factory constructor for goal planning table
  factory InvestmentDataTable.goalPlanning({
    required List<Map<String, dynamic>> data,
    Color? headerColor,
    Color? evenRowColor,
    Color? oddRowColor,
  }) {
    return InvestmentDataTable(
      data: data,
      columns: [
        DataTableColumnConfig(
          key: 'year',
          label: 'Year',
          isBold: true,
          customFormatter: (value) {
            final number = (value as num?)?.toInt() ?? 0;
            return 'Year $number';
          },
        ),
        DataTableColumnConfig(
          key: 'total_invested',
          label: 'Total Investment',
          isCurrency: true,
          decimalPlaces: 0,
        ),
        DataTableColumnConfig(
          key: 'total_gain',
          label: 'Gain',
          isCurrency: true,
          decimalPlaces: 0,
          customFormatter: (value) {
            final gain = (value as num?) ?? 0.0;
            return WealthyAmount.currencyFormat(gain < 0 ? 0 : gain, 0);
          },
        ),
        DataTableColumnConfig(
          key: 'total_amount',
          label: 'Year End Wealth',
          isCurrency: true,
          isBold: true,
          decimalPlaces: 0,
        ),
      ],
      headerColor: headerColor,
      evenRowColor: evenRowColor,
      oddRowColor: oddRowColor,
    );
  }

  /// Factory constructor for SWP (Systematic Withdrawal Plan) table
  factory InvestmentDataTable.swp({
    required List<Map<String, dynamic>> data,
    Color? headerColor,
    Color? evenRowColor,
    Color? oddRowColor,
  }) {
    return InvestmentDataTable(
      data: data,
      columns: [
        DataTableColumnConfig(
          key: 'year',
          label: 'Age',
          isBold: true,
          customFormatter: (value) {
            final age = (value as num?)?.toInt() ?? 0;
            return '$age';
          },
        ),
        DataTableColumnConfig(
          key: 'monthly',
          label: 'Monthly Withdrawal',
          isCurrency: true,
          decimalPlaces: 0,
        ),
        DataTableColumnConfig(
          key: 'yearly',
          label: 'Yearly Withdrawal',
          isCurrency: true,
          decimalPlaces: 0,
        ),
        DataTableColumnConfig(
          key: 'year_end_corpus',
          label: 'Year End Corpus',
          isCurrency: true,
          isBold: true,
          decimalPlaces: 0,
        ),
      ],
      headerColor: headerColor,
      evenRowColor: evenRowColor,
      oddRowColor: oddRowColor,
    );
  }

  String _formatValue(DataTableColumnConfig column, dynamic value) {
    if (column.customFormatter != null) {
      return column.customFormatter!(value);
    }

    if (column.isCurrency) {
      final numValue = (value as num?) ?? 0.0;
      return WealthyAmount.currencyFormat(
        numValue,
        column.decimalPlaces ?? 0,
      );
    }

    return value?.toString() ?? '';
  }

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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width -
                  32, // Full width minus padding
            ),
            child: DataTable(
              columnSpacing: columnSpacing ?? 24,
              horizontalMargin: horizontalMargin ?? 12,
              headingRowColor: MaterialStateProperty.all(
                headerColor ?? Colors.grey[50],
              ),
              headingRowHeight: headingRowHeight ?? 56,
              dataRowHeight: dataRowHeight ?? 56,
              dividerThickness: 0,
              headingTextStyle: context.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              dataTextStyle: context.titleLarge?.copyWith(
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
              columns: columns.map((column) {
                return DataColumn(
                  label: Text(column.label),
                );
              }).toList(),
              rows: List.generate(
                data.length,
                (index) {
                  final rowData = data[index];

                  return DataRow(
                    color: MaterialStateProperty.all(
                      stripedRows
                          ? (index.isEven
                              ? (evenRowColor ?? Colors.white)
                              : (oddRowColor ??
                                  ColorConstants.borderColor.withOpacity(0.2)))
                          : Colors.white,
                    ),
                    cells: columns.map(
                      (column) {
                        final value = rowData[column.key];
                        final formattedValue = _formatValue(column, value);

                        return DataCell(
                          Text(
                            formattedValue,
                            style: context.titleLarge?.copyWith(
                              fontWeight: column.isBold
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color:
                                  column.isBold ? Colors.black : Colors.black87,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
