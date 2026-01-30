import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:flutter/material.dart';

class FrequencySelector extends StatelessWidget {
  final String selectedValue;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const FrequencySelector({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequency',
            style: context.headlineSmall?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: options.map((option) {
              final bool isSelected = option == selectedValue;
              final text = option == '1Y' ? '1 year' : '6 months';
              return Flexible(
                child: _FrequencyOptionChip(
                  text: text,
                  isSelected: isSelected,
                  onTap: () => onChanged(option),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FrequencyOptionChip extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _FrequencyOptionChip({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = ColorConstants.primaryAppColor;
    final Color unselectedBorderColor = ColorConstants.secondaryWhite;
    final Color unselectedTextColor = ColorConstants.tertiaryBlack;
    final Color unselectedIconBorderColor = ColorConstants.borderColor;
    final Color chipBackgroundColor =
        isSelected ? ColorConstants.white : ColorConstants.secondaryWhite;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            color: chipBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? selectedColor : unselectedBorderColor,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected ? selectedColor : unselectedIconBorderColor,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedColor,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: context.headlineSmall?.copyWith(
                  color:
                      isSelected ? ColorConstants.black : unselectedTextColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
