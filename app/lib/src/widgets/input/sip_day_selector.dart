import 'package:app/src/widgets/button/debit_day_button.dart';
import 'package:flutter/material.dart';

class SipDaySelector extends StatelessWidget {
  // Fields
  final int? selectedSipDay;
  final List<int> sipDays;
  final Function(int)? onChanged;

  // Constructor
  const SipDaySelector({
    Key? key,
    required this.selectedSipDay,
    required this.sipDays,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        // alignment: MainAxisAlignment.start,
        children: [
          ...sipDays
              .map(
                (day) => Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: DayButton(
                    day: day,
                    isSelected: day == selectedSipDay,
                    onPressed: () {
                      onChanged!(day);
                    },
                  ),
                ),
              )
              .toList()
        ],
      ),
    );
  }
}
