import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/client/bank_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SetBankPrimaryBottomSheet extends StatelessWidget {
  const SetBankPrimaryBottomSheet({
    Key? key,
    required this.bank,
  }) : super(key: key);

  final BankAccountModel bank;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientBankController>(
      id: 'set-bank-primary',
      builder: (controller) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Text(
                'Set as Primary Account?',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .displaySmall!
                    .copyWith(fontSize: 18),
              ),
              SizedBox(height: 6),
              Text(
                'Are you sure you want to make "${bank.bank}(${bank.number})" your primary account for Mutual Fund?',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(color: ColorConstants.tertiaryBlack),
              ),
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ActionButton(
                      responsiveButtonMaxWidthRatio: 0.4,
                      text: 'Cancel',
                      textStyle: Theme.of(context)
                          .primaryTextTheme
                          .labelLarge!
                          .copyWith(
                            color: ColorConstants.primaryAppColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                      margin: EdgeInsets.zero,
                      bgColor: ColorConstants.secondaryAppColor,
                      onPressed: () async {
                        AutoRouter.of(context).popForced();
                      },
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: ActionButton(
                        text: 'Set as Primary',
                        margin: EdgeInsets.zero,
                        showProgressIndicator:
                            controller.setBankPrimaryResponse.state ==
                                NetworkState.loading,
                        onPressed: () async {
                          await controller
                              .setDefaultBankAccount(bank.externalId ?? '');

                          if (controller.setBankPrimaryResponse.state ==
                              NetworkState.loaded) {
                            showToast(
                              text:
                                  'Successfully set the Bank Account as primary',
                            );

                            // Show Above Toast for 1 sec
                            await Future.delayed(Duration(seconds: 1));

                            AutoRouter.of(context).popUntilRouteWithName(
                              ClientBankListRoute.name,
                            );

                            // Refetch Bank Accounts
                            if (Get.isRegistered<ClientBankController>()) {
                              Get.find<ClientBankController>()
                                  .getClientBankAccounts();
                            }
                          } else {
                            showToast(
                                text:
                                    controller.setBankPrimaryResponse.message);
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
