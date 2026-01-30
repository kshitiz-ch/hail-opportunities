import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/client/client_tracker_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:flutter/material.dart';

class AllocationLineChart extends StatelessWidget {
  final Map<AllocationCategory, dynamic> allocationMapping;

  const AllocationLineChart({Key? key, required this.allocationMapping})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final categoryList = allocationMapping.keys.toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // line chart
        Container(
          margin: EdgeInsets.symmetric(horizontal: 30)
              .copyWith(top: 24, bottom: 10),
          height: 5,
          child: Row(
            children: categoryList
                .map<Widget>(
                  (category) => Container(
                    color: allocationMapping[category]['color'],
                    width: (SizeConfig().screenWidth! - 60) *
                        allocationMapping[category]['weight'],
                  ),
                )
                .toList(),
          ),
        ),
      ]..addAll(
          // Label Grid
          List<Widget>.generate(
            (categoryList.length / 2.0).floor(),
            (index) {
              final index1 = index * 2;
              final index2 = index1 + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30)
                    .copyWith(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel(categoryList[index1], context),
                    _buildLabel(categoryList[index2], context),
                  ],
                ),
              );
            },
          ),
        ),
    );
  }

  Widget _buildLabel(AllocationCategory category, BuildContext context) {
    final weightageText =
        '${((allocationMapping[category]['weight'] * 100.0) as double).toStringAsFixed(1)} %';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 12,
          width: 12,
          color: allocationMapping[category]['color'],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            weightageText,
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  color: ColorConstants.black,
                ),
          ),
        ),
        Text(
          category.name,
          style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                color: ColorConstants.black,
              ),
        )
      ],
    );
  }
}
