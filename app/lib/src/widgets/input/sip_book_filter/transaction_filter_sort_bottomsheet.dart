import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/transaction/transaction_controller.dart';
import 'package:app/src/screens/transactions/common/transaction_common.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionFilterSortBottomSheet extends StatefulWidget {
  @override
  State<TransactionFilterSortBottomSheet> createState() =>
      _TransactionFilterSortBottomSheetState();
}

class _TransactionFilterSortBottomSheetState
    extends State<TransactionFilterSortBottomSheet> {
  FilterMode filterMode = FilterMode.filter;

  final controller = Get.find<TransactionController>();

  String selectedOption = '';
  List<String> options = [];

  @override
  void initState() {
    super.initState();
    if (filterMode == FilterMode.filter) {
      options = controller.timeOptions;
      selectedOption = controller.selectedTimeOption;
    } else {
      options = controller.sortOptions;
      selectedOption = controller.selectedSortOption;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter and Sort tabs
          _buildFilterSortTabs(context),
          SizedBox(height: 20),
          // Filter or Sort content
          Flexible(
            child: _buildTabBarView(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSortTabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 10),
      child: Row(
        children: [
          _buildHeaderTab(
            context,
            fundFilterMode: FilterMode.filter,
            isActive: filterMode == FilterMode.filter,
          ),
          _buildHeaderTab(
            context,
            fundFilterMode: FilterMode.sort,
            isActive: filterMode == FilterMode.sort,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTab(
    BuildContext context, {
    required FilterMode fundFilterMode,
    required bool isActive,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (!isActive) {
            onTabChange(fundFilterMode);
          }
        },
        child: Container(
          padding: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive
                    ? ColorConstants.primaryAppColor
                    : Colors.transparent,
              ),
            ),
          ),
          child: Text(
            fundFilterMode == FilterMode.filter ? 'Filter' : 'Sort',
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  color: isActive
                      ? ColorConstants.black
                      : ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    final label =
        filterMode == FilterMode.filter ? 'View Transactions by' : 'Sort by';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: ColorConstants.black,
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: RadioButtons(
            runSpacing: 24,
            spacing: 24,
            direction: Axis.vertical,
            selectedValue: selectedOption,
            items: options,
            itemBuilder: (context, val, index) {
              return Text(
                val,
                style: context.headlineSmall?.copyWith(
                  color: selectedOption == val
                      ? ColorConstants.black
                      : ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
            onTap: (val) {
              setState(() {
                selectedOption = val.toString();
              });
            },
          ),
        ),
        ActionButton(
          text: 'Confirm',
          margin: EdgeInsets.symmetric(vertical: 30),
          onPressed: () async {
            if (filterMode == FilterMode.filter) {
              await TransactionCommon.onTimeOptionSelect(
                selectedOption,
                context,
                controller,
              );
            } else {
              TransactionCommon.onSortOptionSelect(
                selectedOption,
                context,
                controller,
              );
            }
          },
        )
      ],
    );
  }

  void onTabChange(FilterMode fundFilterMode) {
    setState(() {
      filterMode = fundFilterMode;
      if (filterMode == FilterMode.filter) {
        options = controller.timeOptions;
        selectedOption = controller.selectedTimeOption;
      } else {
        options = controller.sortOptions;
        selectedOption = controller.selectedSortOption;
      }
    });
  }
}
