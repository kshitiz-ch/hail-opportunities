import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_list_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/input/simple_dropdown_form_field.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/clients/models/client_filter_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const textFieldHeight = 90.0;

class FilterList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientListController>(
      id: 'filter',
      builder: (controller) {
        if (controller.clientFilterResponse.state == NetworkState.loading) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.clientFilterResponse.state == NetworkState.error) {
          return Center(
            child: RetryWidget(
              'Error fetching filter list',
              onPressed: () {
                controller.getFilterMapping();
              },
            ),
          );
        }
        if (controller.filterListMap.isEmpty) {
          return Center(child: EmptyScreen(message: 'No Filters available'));
        }

        final tempFilterKeys = controller.tempFilterListMap.keys.toList();
        return Expanded(
          child: Form(
            key: controller.filterFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildFilterList(context, controller)),
                Expanded(
                  flex: 2,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: List.generate(
                      tempFilterKeys.length,
                      (index) {
                        return _buildFilterInputSection(
                          context,
                          controller,
                          tempFilterKeys[index],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterList(
      BuildContext context, ClientListController controller) {
    final filterKeys = controller.filterListMap.keys.toList();
    return ListView.separated(
      itemCount: filterKeys.length,
      padding: EdgeInsets.symmetric(horizontal: 24),
      itemBuilder: (context, index) {
        final filterKey = filterKeys[index];
        final isSelected = controller.tempFilterListMap.containsKey(filterKey);
        final filter = controller.filterListMap[filterKey];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CommonUI.buildCheckbox(
                value: isSelected,
                unselectedBorderColor: ColorConstants.darkGrey,
                onChanged: (bool? value) {
                  if (value == true) {
                    controller.tempFilterListMap[filterKey] =
                        ClientFilterModel.clone(filter!);
                    // Prefill applied filter input value
                    final selectedFilter =
                        controller.selectedFilterListMap[filterKey];
                    if (selectedFilter != null &&
                        selectedFilter.inputValue.isNotEmpty) {
                      controller.tempFilterListMap[filterKey]?.inputValue =
                          selectedFilter.inputValue;
                    }
                  } else if (value == false) {
                    controller.tempFilterListMap.remove(filterKey);
                  }
                  controller.update(['filter']);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                filter?.displayName ?? '',
                style: context.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? ColorConstants.black
                      : ColorConstants.tertiaryBlack,
                ),
              ),
            )
          ],
        );
      },
      separatorBuilder: (_, __) => SizedBox(height: 24),
    );
  }

  Widget _buildFilterInputSection(
    BuildContext context,
    ClientListController controller,
    String tempFilterKey,
  ) {
    final tempFilterItem = controller.tempFilterListMap[tempFilterKey];
    final show2Input = tempFilterItem?.selectedOperator.toLowerCase() == 'bt';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: ColorConstants.borderColor)),
      ),
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tempFilterItem?.displayName ?? '',
            style: context.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorConstants.black,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    height: textFieldHeight,
                    child: _buildOperatorDropdownField(
                      context: context,
                      tempFilterItem: tempFilterItem!,
                      onChanged: (val) {
                        if (val != null) {
                          controller.tempFilterListMap[tempFilterKey]
                              ?.selectedOperator = val;
                          controller.update(['filter']);
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Input 1
                      SizedBox(
                        height: textFieldHeight,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _buildInputField(
                            context: context,
                            dataType: tempFilterItem.dataType?.toLowerCase(),
                            inputValue: tempFilterItem.inputValue,
                            hintText:
                                '${tempFilterItem.displayName} ${show2Input ? '1' : ''}',
                            onChanged: (value) {
                              onChangeInput(
                                value: value,
                                controller: controller,
                                tempfilterKey: tempFilterKey,
                              );
                            },
                          ),
                        ),
                      ),
                      // Input 2
                      if (show2Input)
                        SizedBox(
                          height: textFieldHeight,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: _buildInputField(
                              context: context,
                              dataType: tempFilterItem.dataType?.toLowerCase(),
                              inputValue: tempFilterItem.inputValue2,
                              hintText:
                                  '${tempFilterItem.displayName} ${show2Input ? '2' : ''}',
                              onChanged: (value) {
                                onChangeInput(
                                  value: value,
                                  controller: controller,
                                  useInput1: false,
                                  tempfilterKey: tempFilterKey,
                                );
                              },
                            ),
                          ),
                        )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorDropdownField({
    required BuildContext context,
    required ClientFilterModel tempFilterItem,
    required void Function(String?)? onChanged,
  }) {
    final style = context.headlineSmall?.copyWith(
      color: ColorConstants.tertiaryBlack,
      fontWeight: FontWeight.w500,
    );
    final operatorMap = {
      'eq': 'Equal to',
      'lte': 'Less than or equal to',
      'gte': 'Greater than or equal to',
      'bt': 'Between',
      'lt': 'Less than',
      'gt': 'Greater than',
    };

    return SimpleDropdownFormField<String>(
      alignment: AlignmentDirectional.center,
      showBorder: true,
      maxWidth: (SizeConfig().screenWidth! - 60) / 2,
      maxButtonHeight: 50,
      removePadding: true,
      dropdownTextStyle: style,
      selectedTextStyle: style?.copyWith(
        color: ColorConstants.primaryAppColor,
        fontWeight: FontWeight.w600,
      ),
      hintText: 'Operator',
      items: tempFilterItem.operators ?? [],
      customText: (value) {
        return operatorMap.containsKey(value) ? operatorMap[value] : 'Equal to';
      },
      value: tempFilterItem.selectedOperator,
      // contentPadding: EdgeInsets.only(bottom: 8),
      borderColor: ColorConstants.lightGrey,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: ColorConstants.primaryAppColor,
        size: 24,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required String? dataType,
    required String? inputValue,
    required String? hintText,
    required void Function(dynamic) onChanged,
  }) {
    if (dataType == 'boolean') {
      return Switch(
        value: inputValue == '1',
        activeColor: ColorConstants.primaryAppColor,
        onChanged: (val) {
          onChanged(val);
        },
      );
    }

    final inputController = TextEditingController();

    if (dataType == 'datetime') {
      final unixDateTimeStamp = WealthyCast.toInt(inputValue);
      final dateText = unixDateTimeStamp != null
          ? getFormattedDate(
              DateTime.fromMillisecondsSinceEpoch(unixDateTimeStamp * 1000))
          : '';
      inputController.value = inputController.value.copyWith(
        text: dateText,
        selection: TextSelection.collapsed(offset: dateText.length),
      );

      return InkWell(
        onTap: () async {
          final pickedDate = await showDatePicker(
            initialDatePickerMode: DatePickerMode.year,
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now().subtract(
              Duration(days: 365 * 110),
            ),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: ColorConstants.primaryAppColor,
                    onPrimary: ColorConstants.white,
                  ),
                ),
                child: child!,
              );
            },
          );

          if (pickedDate != null) {
            // unixDateTimeStamp
            onChanged(pickedDate);
          }
        },
        child: IgnorePointer(
          ignoring: true,
          child: CommonClientUI.borderTextFormField(
            context,
            contentPadding: EdgeInsets.all(8),
            hintText: hintText ?? 'Enter Value',
            controller: inputController,
            prefixIcon: Icon(Icons.calendar_month),
          ),
        ),
      );
    }

    final isAmountInput = dataType == 'float';
    final valueText = isAmountInput && inputValue.isNotNullOrEmpty
        ? "\₹ ${WealthyAmount.formatNumber(inputValue ?? '')}"
        : inputValue;
    inputController.value = inputController.value.copyWith(
      text: valueText,
      selection: TextSelection.collapsed(offset: valueText?.length ?? 0),
    );

    return CommonClientUI.borderTextFormField(
      context,
      hintText: hintText ?? 'Enter Value',
      enabled: true,
      controller: inputController,
      contentPadding: EdgeInsets.all(8),
      keyboardType: isAmountInput ? TextInputType.number : TextInputType.text,
      onChanged: (value) {
        onChanged(value);
      },
      validator: (String? value) {
        if (value.isNullOrEmpty) {
          return '$hintText is required.';
        }

        return null;
      },
    );
  }

  void onChangeInput({
    required dynamic value,
    required ClientListController controller,
    bool useInput1 = true,
    required String tempfilterKey,
  }) {
    final dataType =
        controller.tempFilterListMap[tempfilterKey]?.dataType?.toLowerCase();
    String inputValue = '';
    if (dataType == 'boolean') {
      // value is bool
      inputValue = value ? '1' : '0';
    } else if (dataType == 'datetime') {
      // value is datetime
      // unixDateTimeStamp
      inputValue = (value.millisecondsSinceEpoch / 1000).toStringAsFixed(0);
    } else {
      // final isAmountInput = dataType == 'float';
      inputValue = value.replaceAll(",", "").replaceAll("\₹", "").trim();
    }

    if (useInput1) {
      controller.tempFilterListMap[tempfilterKey]?.inputValue = inputValue;
    } else {
      controller.tempFilterListMap[tempfilterKey]?.inputValue2 = inputValue;
    }
    controller.update(['filter']);
  }
}
