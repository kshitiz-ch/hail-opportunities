import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/client/bank_controller.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/screens/clients/client_profile/bank/widgets/bank_card.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/mf_bank_card.dart';

@RoutePage()
class ClientBankListScreen extends StatelessWidget {
  const ClientBankListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Client? client;

    if (Get.isRegistered<ClientDetailController>()) {
      client = Get.find<ClientDetailController>().client;
    }

    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: 'Bank Account Details',
      ),
      body: GetBuilder<ClientBankController>(
        init: ClientBankController(client),
        builder: (controller) {
          if (controller.bankAccountsResponse.state == NetworkState.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.bankAccountsResponse.state == NetworkState.error) {
            return Center(
              child: RetryWidget(
                'Something went wrong',
                onPressed: () {
                  controller.getClientBankAccounts();
                },
              ),
            );
          }

          if (controller.bankAccountsResponse.state == NetworkState.loaded &&
              controller.userBankAccounts.isEmpty) {
            return Center(
              child: EmptyScreen(
                message: 'Bank Accounts not found',
                actionButtonText: 'Add Bank Account',
                onClick: () {
                  AutoRouter.of(context).push(ClientBankFormRoute());
                },
              ),
            );
          }

          return Container(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.mfBankAccount != null)
                    _buildMfBankAccount(context, controller),
                  if (controller.userBrokingBankAccount != null)
                    _buildBrokingBankAccounts(context, controller),
                  if (controller.userBankAccounts.isNotEmpty)
                    _buildUserBankAccounts(context, controller)
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildAddBankButton(context),
    );
  }

  Widget _buildUserBankAccounts(
      BuildContext context, ClientBankController controller) {
    ClientMfProfileModel? clientMfProfile;
    if (Get.isRegistered<ClientDetailController>()) {
      clientMfProfile = Get.find<ClientDetailController>().clientMfProfile;
    }
    return Padding(
      padding: EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Saved Bank Accounts',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineLarge!
                  .copyWith(fontSize: 16),
            ),
          ),
          SizedBox(height: 15),
          ListView.separated(
            padding: EdgeInsets.only(bottom: 100),
            itemCount: controller.userBankAccounts.length,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (context, index) => SizedBox(height: 24),
            itemBuilder: (context, index) {
              BankAccountModel bank = controller.userBankAccounts[index];
              return BankCard(
                  bank: bank,
                  canSetAsPrimary:
                      bank.externalId != controller.mfBankAccount?.externalId &&
                          clientMfProfile != null);
            },
          )
        ],
      ),
    );
  }

  Widget _buildMfBankAccount(
      BuildContext context, ClientBankController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bank Account for Mutual Fund',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineLarge!
                      .copyWith(fontSize: 16),
                ),
                // ClickableText(
                //   text: 'Edit',
                //   onClick: () {},
                // )
              ],
            ),
          ),
          MfBankCard(bankAccount: controller.mfBankAccount!)
        ],
      ),
    );
  }

  Widget _buildBrokingBankAccounts(
      BuildContext context, ClientBankController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bank Account for Trading',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineLarge!
                    .copyWith(fontSize: 16),
              ),
              // ClickableText(
              //   text: 'Edit',
              //   onClick: () {},
              // )
            ],
          ),
        ),
        // if (controller.userBrokingBankAccounts.length == 1)
        MfBankCard(
          bankAccount: controller.userBrokingBankAccount!,
          isMf: false,
        )
      ],
    );
  }

  Widget _buildAddBankButton(context) {
    return GetBuilder<ClientBankController>(
      builder: (controller) {
        if (controller.bankAccountsResponse.state != NetworkState.loaded ||
            controller.userBankAccounts.isEmpty) {
          return SizedBox();
        }

        return ActionButton(
          onPressed: () {
            AutoRouter.of(context).push(ClientBankFormRoute());
          },
          text: 'Add Bank Account',
          bgColor: ColorConstants.secondaryButtonColor,
          textStyle: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
              color: ColorConstants.primaryAppColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w700),
        );
      },
    );
  }
}
