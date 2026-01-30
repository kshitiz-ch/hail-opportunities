import 'package:app/src/config/utils/context_extension.dart';
import 'package:flutter/material.dart';

class CalculatorSummaryItem {
  final String label;
  final String value;
  final bool isHighlighted;

  CalculatorSummaryItem({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });
}

class CalculatorSummarySection extends StatelessWidget {
  final List<CalculatorSummaryItem> items;

  const CalculatorSummarySection({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Color(0xffFBFBFB),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          // First item is highlighted if isHighlighted is true
          if (items.isNotEmpty && items.first.isHighlighted)
            Container(
              decoration: BoxDecoration(color: Color(0xffF6F2FF)),
              padding: EdgeInsets.all(12),
              child: _buildSummaryRow(
                context,
                items.first.label,
                items.first.value,
              ),
            ),
          if (items.isNotEmpty && items.first.isHighlighted)
            const SizedBox(height: 12),
          // Remaining items
          ...items
              .asMap()
              .entries
              .where((entry) => !entry.value.isHighlighted || entry.key != 0)
              .map((entry) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildSummaryRow(
                    context,
                    entry.value.label,
                    entry.value.value,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: context.titleLarge?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: context.headlineSmall?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
