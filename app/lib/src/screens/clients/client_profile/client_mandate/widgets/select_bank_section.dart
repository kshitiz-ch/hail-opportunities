import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/client_mandate_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:core/modules/clients/models/client_mandate_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class SelectBankSection extends StatelessWidget {
  const SelectBankSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: GetBuilder<ClientMandateController>(
            id: GetxId.bank,
            builder: (controller) {
              if (controller.bankAccountsResponse.state ==
                  NetworkState.loading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.bankAccountsResponse.state == NetworkState.error) {
                return RetryWidget(
                  'Something went wrong. Please try again',
                  onPressed: () {
                    controller.getClientBankAccounts();
                  },
                );
              }

              if (controller.bankAccountsResponse.state ==
                      NetworkState.loaded &&
                  controller.userBankAccounts.isEmpty) {
                return EmptyScreen(
                  message: 'No Banks Found',
                  actionButtonText: 'Add Bank',
                  onClick: () {
                    _navigateToBankForm(context, controller);
                  },
                );
              }

              if (controller.bankAccountsResponse.state ==
                      NetworkState.loaded &&
                  controller.userBankAccounts.isNotEmpty) {
                return _buildBankList(context, controller);
              }

              return SizedBox();
            },
          ),
        ),
        GetBuilder<ClientMandateController>(
          id: GetxId.bank,
          builder: (controller) {
            if (controller.bankAccountsResponse.state == NetworkState.loaded &&
                controller.userBankAccounts.isNotEmpty) {
              return _buildActionButtons(context);
            }

            return SizedBox();
          },
        )
      ],
    );
  }

  Widget _buildBankList(
      BuildContext context, ClientMandateController controller) {
    return Scrollbar(
      thumbVisibility: true,
      radius: Radius.circular(8),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: controller.userBankAccounts.length,
        separatorBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(color: ColorConstants.borderColor),
          );
        },
        itemBuilder: (context, index) {
          BankAccountModel bank = controller.userBankAccounts[index];
          return _buildBankCard(context, bank);
        },
      ),
    );
  }

  Widget _buildBankCard(BuildContext context, BankAccountModel bank) {
    return GetBuilder<ClientMandateController>(
      id: GetxId.proposal,
      builder: (controller) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 5, left: 5),
              height: 15,
              width: 15,
              child: Radio(
                activeColor: ColorConstants.primaryAppColor,
                value: bank,
                groupValue: controller.selectedBank,
                onChanged: (dynamic value) {
                  controller.updateSelectedBank(bank);
                },
              ),
            ),
            SizedBox(width: 8),
            CommonClientUI.mandateBankTile(
              context,
              bank,
              onTap: () {
                controller.updateSelectedBank(bank);
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(context) {
    return GetBuilder<ClientMandateController>(
      id: GetxId.proposal,
      builder: (controller) {
        return Padding(
          padding: EdgeInsets.only(top: 40, bottom: 30),
          child: Row(
            children: [
              Expanded(
                child: ActionButton(
                  text: '+ New Bank',
                  bgColor: ColorConstants.secondaryAppColor,
                  textStyle: Theme.of(context)
                      .primaryTextTheme
                      .labelLarge!
                      .copyWith(
                          color: ColorConstants.primaryAppColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700),
                  margin: EdgeInsets.zero,
                  onPressed: () {
                    _navigateToBankForm(context, controller);
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ActionButton(
                  text: 'Proceed',
                  isDisabled: controller.selectedBank == null,
                  margin: EdgeInsets.zero,
                  onPressed: () {
                    controller.updateProposalFormView(ProposalFormView.Amount);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _navigateToBankForm(
      BuildContext context, ClientMandateController controller) {
    AutoRouter.of(context).push(
      ClientBankFormRoute(
        client: controller.client,
        onBankAdded: (BankAccountModel? bank) {
          AutoRouter.of(context).popForced();
          controller.getClientBankAccounts();
        },
      ),
    );
  }
}
