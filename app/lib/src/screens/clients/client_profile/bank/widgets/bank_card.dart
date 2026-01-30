import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/bank_controller.dart';
import 'package:app/src/screens/clients/client_profile/bank/widgets/set_bank_primary_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:flutter/material.dart';

class BankCard extends StatelessWidget {
  const BankCard({
    Key? key,
    required this.bank,
    this.canSetAsPrimary = false,
  }) : super(key: key);

  final BankAccountModel bank;
  final bool canSetAsPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          border: Border.all(color: ColorConstants.borderColor),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          _buildBankNameLogo(context),
          _buildBankBottomData(context),
        ],
      ),
    );
  }

  Widget _buildBankNameLogo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          SizedBox(
            height: 38,
            width: 38,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: CachedNetworkImage(
                imageUrl: getBankLogo(bank.bank),
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              bank.bank ?? '-',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineSmall!
                  .copyWith(fontSize: 18),
            ),
          ),
          if (bank.bankVerifiedStatus == 5)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: ColorConstants.greenAccentColor,
                ),
                SizedBox(width: 2),
                Text(
                  'Verified',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(color: ColorConstants.greenAccentColor),
                )
              ],
            )
        ],
      ),
    );
  }

  Widget _buildBankBottomData(BuildContext context) {
    TextStyle labelStyle = Theme.of(context)
        .primaryTextTheme
        .headlineSmall!
        .copyWith(color: ColorConstants.tertiaryBlack, fontSize: 12);
    TextStyle titleStyle = Theme.of(context)
        .primaryTextTheme
        .headlineSmall!
        .copyWith(fontSize: 12);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Row(
            children: [
              Expanded(
                child: CommonUI.buildColumnTextInfo(
                    title: 'Account Number',
                    subtitle: bank.number ?? '-',
                    titleStyle: labelStyle,
                    subtitleStyle: titleStyle),
              ),
              Expanded(
                child: CommonUI.buildColumnTextInfo(
                    title: 'IFSC Code',
                    subtitle: bank.ifsc ?? '-',
                    titleStyle: labelStyle,
                    subtitleStyle: titleStyle),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Expanded(
              //   child: CommonUI.buildColumnTextInfo(
              //       title: 'Mandate Status',
              //       subtitle:
              //           bank.isMandateCompleted ? 'Approved' : 'Not Approved',
              //       titleStyle: labelStyle,
              //       subtitleStyle: titleStyle),
              // ),
              Expanded(child: SizedBox()),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (canSetAsPrimary)
                        InkWell(
                          onTap: () {
                            CommonUI.showBottomSheet(
                              context,
                              child: SetBankPrimaryBottomSheet(
                                bank: bank,
                              ),
                            );
                          },
                          child: Text(
                            'Set as Primary (MF)',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall!
                                .copyWith(
                                  fontSize: 12,
                                  color: ColorConstants.primaryAppColor,
                                ),
                          ),
                        ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          AutoRouter.of(context).push(
                            ClientBankFormRoute(bankAccount: bank),
                          );
                        },
                        child: Text(
                          'Edit',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                fontSize: 12,
                                color: ColorConstants.errorColor,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
