import 'package:app/src/config/utils/context_extension.dart';
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color statusColor;

  const StatusChip({
    super.key,
    required this.label,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: context.titleLarge?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
