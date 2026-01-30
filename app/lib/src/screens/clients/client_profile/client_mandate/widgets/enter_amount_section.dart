import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/client_mandate_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/amount_textfield.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EnterAmountSection extends StatelessWidget {
  const EnterAmountSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientMandateController>(
      builder: (controller) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSelectedBankDetails(context, controller),
                _buildInputLabel(context),
                _buildAmountInput(context, controller),
                _buildSuggestedAmounts(context, controller),
                _buildSendProposalButton(context, controller)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSendProposalButton(
      BuildContext context, ClientMandateController controller) {
    return Padding(
      padding: EdgeInsets.only(top: 40, bottom: 30),
      child: ActionButton(
        text: 'Send to Client',
        showProgressIndicator:
            controller.proposalResponse.state == NetworkState.loading,
        margin: EdgeInsets.zero,
        onPressed: () async {
          if (controller.formKey.currentState!.validate()) {
            await controller.createProposal();

            if (controller.proposalResponse.state == NetworkState.error) {
              return showToast(
                context: context,
                text: controller.proposalResponse.message,
              );
            }

            if (controller.proposalResponse.state == NetworkState.loaded) {
              AutoRouter.of(context).push(DematProposalSuccessRoute());
            }
          }
        },
      ),
    );
  }

  Widget _buildInputLabel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 24.0, 0.0, 0.0),
      child: Text(
        "Enter Mandate Amount",
        style: Theme.of(context)
            .primaryTextTheme
            .titleLarge!
            .copyWith(color: ColorConstants.primaryAppColor),
      ),
    );
  }

  Widget _buildSelectedBankDetails(
      BuildContext context, ClientMandateController controller) {
    return Row(
      children: [
        // Expanded(
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         controller.selectedBank?.paymentBankName ?? '-',
        //         style: Theme.of(context)
        //             .primaryTextTheme
        //             .headlineMedium!
        //             .copyWith(fontWeight: FontWeight.w600),
        //       ),
        //       SizedBox(width: 4),
        //       Text(
        //         WealthyCast.toStr(
        //             controller.selectedBank?.paymentBankAccountNumber)!,
        //         style: Theme.of(context)
        //             .primaryTextTheme
        //             .headlineSmall!
        //             .copyWith(color: ColorConstants.tertiaryBlack),
        //       ),
        //     ],
        //   ),
        // ),
        CommonClientUI.mandateBankTile(context, controller.selectedBank!),
        SizedBox(width: 10),
        TextButton(
          onPressed: () {
            controller.updateProposalFormView(ProposalFormView.SelectBank);
          },
          child: Text('Change'),
        )
      ],
    );
  }

  Widget _buildAmountInput(
      BuildContext context, ClientMandateController controller) {
    int minAmount = controller.mandateOptionModel?.minAmount ?? 50000;
    return Form(
      key: controller.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: AmountTextField(
        validator: (val) {
          if (val.isNullOrEmpty) {
            return 'This field is required';
          }

          double amountEntered = double.tryParse(val.replaceAll(',', '')) ?? 0;
          if (amountEntered < minAmount) {
            return 'Min Amount should be ₹${minAmount.toStringAsFixed(0)}';
          }

          return null;
        },
        showAmountLabel: false,
        controller: controller.amountController,
        minAmountLabel: 'Minimum Mandate Amount ',
        minAmount: minAmount.toDouble(),
        labelStyle: Theme.of(context)
            .primaryTextTheme
            .headlineSmall!
            .copyWith(fontSize: 12, color: ColorConstants.primaryAppColor),
        scrollPadding: const EdgeInsets.only(bottom: 100),
        onChanged: (_) {
          controller.update([GetxId.proposal]);
        },
      ),
    );
  }

  Widget _buildSuggestedAmounts(
    BuildContext context,
    ClientMandateController controller,
  ) {
    if (controller.mandateOptionResponse.state == NetworkState.loading) {
      return SkeltonLoaderCard(height: 100);
    }

    List<int> suggestedAmountsList =
        controller.mandateOptionModel?.paymentAmounts ?? [];

    if (suggestedAmountsList.isNullOrEmpty) {
      return SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Suggested Amounts",
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
          SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              return ButtonBar(
                mainAxisSize: MainAxisSize.min,
                alignment: MainAxisAlignment.start,
                buttonPadding: EdgeInsets.zero,
                children: suggestedAmountsList
                    .map(
                      (amount) => SizedBox(
                        width: constraints.maxWidth / 4,
                        child: ActionButton(
                          bgColor: ColorConstants.secondaryWhite,
                          text: WealthyAmount.currencyFormat(amount, 1,
                              showSuffix: true),
                          textStyle: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                fontSize: 12.0,
                                height: 1.4,
                                color: ColorConstants.tertiaryBlack,
                                fontWeight: FontWeight.w400,
                              ),
                          height: 36,
                          margin: EdgeInsets.only(right: 10),
                          borderRadius: 8.0,
                          onPressed: () {
                            controller.amountController.value =
                                controller.amountController.value.copyWith(
                              text: '${amount}',
                              selection: TextSelection.collapsed(
                                  offset: amount.toString().length),
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
