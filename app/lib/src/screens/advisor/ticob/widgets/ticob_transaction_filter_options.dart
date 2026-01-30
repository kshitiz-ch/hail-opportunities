import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/ticob_controller.dart';
import 'package:app/src/screens/advisor/ticob/widgets/amc_search_field.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicobTransactionFilterOptions extends StatelessWidget {
  final controller = Get.find<TicobController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
        ),
      ),
      child: _buildFilterOptions(context),
    );
  }

  Widget _buildFilterOptions(BuildContext context) {
    final isAmcFilterSelected = controller.selectedFilterType == 'AMC';
    late List? currentFilterOptions;
    if (isAmcFilterSelected) {
      currentFilterOptions =
          controller.filteredAmcList.map((e) => e.amc.toTitleCase()).toList();
    } else {
      currentFilterOptions = controller
          .allTransactionFilter[controller.selectedFilterType]?.keys
          .toList();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isAmcFilterSelected)
          Padding(
            padding: const EdgeInsets.all(10.0).copyWith(top: 0),
            child: AmcSearchField(),
          ),
        if (currentFilterOptions.isNullOrEmpty)
          EmptyScreen(message: 'No filter options available')
        else
          Expanded(
            child: ListView.builder(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: currentFilterOptions!.length,
              itemBuilder: (BuildContext context, int index) {
                final filteredValues = controller
                    .tempTransactionFilter[controller.selectedFilterType];
                bool isSelected = false;
                if (filteredValues.isNotNullOrEmpty) {
                  isSelected =
                      filteredValues?.contains(currentFilterOptions![index]) ??
                          false;
                }

                return InkWell(
                  onTap: () {
                    controller.updateFilterValues(
                      currentFilterOptions![index],
                      !isSelected,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 30.0,
                      right: 30.0,
                      bottom: 12,
                      top: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.done,
                          color:
                              isSelected ? ColorConstants.black : Colors.white,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Text(
                            currentFilterOptions![index],
                            maxLines: 2,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall!
                                .copyWith(
                                  // overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? ColorConstants.black
                                      : ColorConstants.tertiaryBlack,
                                ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
