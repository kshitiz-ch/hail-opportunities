import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_tracker_switch_controller.dart';
import 'package:app/src/screens/clients/client_tracker/widgets/folio_detail.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/input/simple_text_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrackerFundSwitchBottomSheet extends StatelessWidget {
  // for Edit basket
  final bool isEdit;
  final int? basketIndex;

  late SchemeMetaModel switchOutFund;
  late SchemeMetaModel switchInFund;

  TrackerFundSwitchBottomSheet({
    Key? key,
    this.isEdit = false,
    this.basketIndex,
  }) : super(key: key) {
    final controller = Get.find<ClientTrackerSwitchController>();
    if (isEdit) {
      switchOutFund = controller.switchBasket[basketIndex!]['switch_out'];
      switchInFund = controller.switchBasket[basketIndex!]['switch_in'];
    } else {
      switchOutFund = controller
          .clientTrackerHoldings[controller.selectedTrackerFundIndex]
          .schemeMetaModel!;
      switchInFund =
          controller.availableSwitchFunds[controller.selectedSwitchFundIndex];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientTrackerSwitchController>(
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.all(30).copyWith(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: isEdit
                  ? controller.switchFundFormKey
                  : controller.editSwitchFundFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        AutoRouter.of(context).popForced();
                      },
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: ColorConstants.black,
                      ),
                    ),
                  ),
                  _buildFundTile(switchOutFund, context),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: _buildSeparator(),
                  ),
                  _buildFundTile(
                    switchInFund,
                    context,
                    showFolioDetails: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 60, bottom: 40),
                    child: _buildSwitchOption(context, controller),
                  ),
                  _buildBottomView(
                    selectedSwitchMethod: isEdit
                        ? controller.editFundSwitchMethod
                        : controller.selectedFundSwitchMethod,
                    context: context,
                    controller: controller,
                  ),
                  if (controller.lastSyncedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: _buildUnitNote(context, controller.lastSyncedAt!),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomView({
    required FundSwitchMethod selectedSwitchMethod,
    required BuildContext context,
    required ClientTrackerSwitchController controller,
  }) {
    return selectedSwitchMethod == FundSwitchMethod.Full
        ? _buildUpdateBasket(controller, context)
        : Row(
            children: [
              Expanded(
                child: _buildInputField(context, controller),
              ),
              SizedBox(width: 40),
              Expanded(
                child: _buildUpdateBasket(controller, context),
              )
            ],
          );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 2,
              color: ColorConstants.secondarySeparatorColor,
            ),
          ),
          Container(
            height: 34,
            width: 34,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorConstants.white,
              border: Border.all(color: ColorConstants.secondarySeparatorColor),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              AllImages().trackerSwitchIcon,
              fit: BoxFit.fill,
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              color: ColorConstants.secondarySeparatorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundTile(
    SchemeMetaModel fund,
    BuildContext context, {
    bool showFolioDetails = true,
  }) {
    final headerStyle = context.headlineSmall!.copyWith(
      color: ColorConstants.black,
      fontWeight: FontWeight.w500,
    );
    final subtitleStyle = context.titleLarge!.copyWith(
      color: ColorConstants.tertiaryBlack,
      fontWeight: FontWeight.w500,
      overflow: TextOverflow.ellipsis,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ColorConstants.white,
              border: Border.all(color: ColorConstants.secondarySeparatorColor),
              shape: BoxShape.circle,
            ),
            child: CommonUI.buildRoundedFullAMCLogo(
              radius: 18,
              amcName: fund.displayName,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fund.displayName ?? '-',
                    style: headerStyle,
                  ),
                  SizedBox(height: 4),
                  if (showFolioDetails)
                    FolioDetail(fund: fund)
                  else
                    Text(
                      '${fundTypeDescription(fund.fundType)} ${fund.fundCategory != null ? "| ${fund.fundCategory}" : ""}',
                      style: subtitleStyle,
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
      BuildContext context, ClientTrackerSwitchController controller) {
    final selectedSwitchMethod = isEdit
        ? controller.editFundSwitchMethod
        : controller.selectedFundSwitchMethod;
    final hintStyle =
        Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w500,
              height: 0.7,
            );
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            );
    final textController = isEdit
        ? controller.editSwitchFundFieldController
        : controller.fundSwitchInputFieldController;
    return SimpleTextFormField(
      contentPadding: EdgeInsets.only(bottom: 8),
      enabled: true,
      prefixIconSize: Size(20, 30),
      controller: textController,
      prefixIcon: selectedSwitchMethod == FundSwitchMethod.Amount
          ? Align(
              alignment: Alignment.bottomLeft,
              child: Text("\₹ "),
            )
          : null,
      label: 'Enter ${selectedSwitchMethod.name}',
      style: textStyle,
      useLabelAsHint: true,
      labelStyle: hintStyle,
      hintStyle: hintStyle,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [NoLeadingSpaceFormatter()],
      maxLength: 10,
      hideCounterText: true,
      suffixIcon: (textController.text.isNullOrEmpty)
          ? null
          : IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.clear,
                size: 20.0,
                color: ColorConstants.black,
              ),
              onPressed: () {
                if (isEdit) {
                  controller.clearEditSwitchInputField();
                } else {
                  controller.clearSwitchInputField();
                }
              },
            ),
      onChanged: (val) {
        val = val.replaceAll(',', '');
        if (isEdit) {
          controller.updateEditSwitchInputField(val);
        } else {
          controller.updateSwitchInputField(val);
        }
      },
      borderColor: ColorConstants.borderColor,
      validator: (value) {
        return validateInputField(value, controller);
      },
    );
  }

  String? validateInputField(
      String? value, ClientTrackerSwitchController controller) {
    final selectedSwitchMethod = isEdit
        ? controller.editFundSwitchMethod
        : controller.selectedFundSwitchMethod;
    final textController = isEdit
        ? controller.editSwitchFundFieldController
        : controller.fundSwitchInputFieldController;
    if (value.isNullOrEmpty) {
      return '${selectedSwitchMethod.name} is required.';
    }
    if (selectedSwitchMethod == FundSwitchMethod.Amount) {
      final amountEntered = controller.getTextFieldAmount(textController);
      if (switchInFund.minDepositAmt != null &&
          amountEntered < switchInFund.minDepositAmt!) {
        return 'Minimum entered amount is ₹ ${switchInFund.minDepositAmt}';
      }
      final maxAmount = switchOutFund.folioOverview?.withdrawalAmountAvailable;
      if (maxAmount != null && amountEntered > maxAmount) {
        return 'Maximum allowed amount is ${WealthyAmount.currencyFormat(maxAmount, 2)}';
      }
    }
    if (selectedSwitchMethod == FundSwitchMethod.Unit) {
      final unitEntered = controller.getTextFieldAmount(textController);
      if (unitEntered == 0) {
        return 'Minimum entered unit should be greater than zero';
      }
      final maxUnits = switchOutFund.folioOverview?.withdrawalUnitsAvailable;
      if (maxUnits != null && unitEntered > maxUnits) {
        return 'Maximum allowed unit is ${maxUnits.toStringAsFixed(2)}';
      }
    }

    return null;
  }

  Widget _buildSwitchOption(
      BuildContext context, ClientTrackerSwitchController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Input Option ',
          style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w400,
                color: ColorConstants.tertiaryBlack,
                overflow: TextOverflow.ellipsis,
              ),
        ),
        SizedBox(height: 10),
        RadioButtons(
          onTap: (value) {
            if (isEdit) {
              controller.updateEditSwitchMethod(value);
            } else {
              controller.updateSelectedSwitchMethod(value);
            }
          },
          itemBuilder: (BuildContext context, dynamic value, int index) {
            return Text(
              (value as FundSwitchMethod).name,
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.black,
                  ),
            );
          },
          items: FundSwitchMethod.values,
          selectedValue: isEdit
              ? controller.editFundSwitchMethod
              : controller.selectedFundSwitchMethod,
        ),
      ],
    );
  }

  Widget _buildUpdateBasket(
      ClientTrackerSwitchController controller, BuildContext context) {
    final selectedSwitchMethod = isEdit
        ? controller.editFundSwitchMethod
        : controller.selectedFundSwitchMethod;
    final formKey = isEdit
        ? controller.switchFundFormKey
        : controller.editSwitchFundFormKey;

    return ActionButton(
      text: isEdit ? 'Edit basket' : 'Add to basket',
      onPressed: () {
        final isValid = selectedSwitchMethod == FundSwitchMethod.Full ||
            (formKey.currentState?.validate() ?? false);
        if (isValid) {
          if (isEdit) {
            controller.editSwitchFundBasket(basketIndex ?? 0);
            showToast(text: 'Switch Fund edited successfully in basket');
            AutoRouter.of(context).popForced();
          } else {
            controller.addSwitchFundToBasket();
            showToast(text: 'Fund added successfully to basket');
            AutoRouter.of(context).popForced();
            Future.delayed(Duration(seconds: 1), () {
              controller.resetLocalState();
            });
          }
        }
      },
      margin: EdgeInsets.only(bottom: 30),
    );
  }

  Widget _buildUnitNote(BuildContext context, DateTime lastSyncDate) {
    final msg = 'Units As On: ${getFormattedDate(lastSyncDate)}';
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: ColorConstants.lightScaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 14),
      child: Text(
        '** $msg',
        style: context.headlineSmall!.copyWith(
          color: ColorConstants.tertiaryBlack,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
