import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:flutter/material.dart';

class GraphTableTabs extends StatelessWidget {
  final int selectedGraphTableTabIndex;
  final Function(int) onTabSelected;

  const GraphTableTabs({
    Key? key,
    required this.onTabSelected,
    required this.selectedGraphTableTabIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorConstants.primaryAppv3Color, // Light purple background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              label: 'Graph',
              isSelected: selectedGraphTableTabIndex == 0,
              onTap: () => onTabSelected(0),
              context: context,
            ),
          ),
          Expanded(
            child: _buildTab(
              label: 'Table',
              isSelected: selectedGraphTableTabIndex == 1,
              onTap: () => onTabSelected(1),
              context: context,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: context.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? ColorConstants.primaryAppColor
                  : ColorConstants.tertiaryBlack,
            ),
          ),
        ),
      ),
    );
  }
}
