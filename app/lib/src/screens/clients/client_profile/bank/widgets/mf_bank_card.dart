import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:flutter/material.dart';

class MfBankCard extends StatelessWidget {
  const MfBankCard({
    Key? key,
    required this.bankAccount,
    this.isMf = true,
  }) : super(key: key);

  final BankAccountModel bankAccount;
  final bool isMf;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: ColorConstants.primaryAppv3Color,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBankNameLogo(context),
          _buildBankBottomData(context),
          _buildPrimaryAccountLabel(context)
        ],
      ),
    );
  }

  Widget _buildBankNameLogo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
      child: Row(
        children: [
          SizedBox(
            height: 38,
            width: 38,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: CachedNetworkImage(
                imageUrl: getBankLogo(bankAccount.bank),
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              bankAccount.bank ?? '-',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineSmall!
                  .copyWith(fontSize: 18),
            ),
          ),
          if (bankAccount.bankVerifiedStatus == 5) _buildVerifiedText(context)
        ],
      ),
    );
  }

  Widget _buildVerifiedText(BuildContext context) {
    return Row(
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
          padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 15),
          child: Row(
            children: [
              Expanded(
                child: CommonUI.buildColumnTextInfo(
                    title: 'Account Number',
                    subtitle: bankAccount.number ?? '-',
                    titleStyle: labelStyle,
                    subtitleStyle: titleStyle),
              ),
              Expanded(
                child: CommonUI.buildColumnTextInfo(
                    title: 'IFSC Code',
                    subtitle: bankAccount.ifsc ?? '-',
                    titleStyle: labelStyle,
                    subtitleStyle: titleStyle),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 15),
          child: Row(
            children: [
              // Expanded(
              //   child: CommonUI.buildColumnTextInfo(
              //       title: 'Mandate Status',
              //       subtitle: bankAccount.isMandateCompleted
              //           ? 'Approved'
              //           : 'Not Approved',
              //       titleStyle: labelStyle,
              //       subtitleStyle: titleStyle),
              // ),
              Expanded(
                child: CommonUI.buildColumnTextInfo(
                    title: 'Primary Setup',
                    subtitle: isMf ? 'Mutual Funds' : 'Trading',
                    titleStyle: labelStyle,
                    subtitleStyle: titleStyle),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildPrimaryAccountLabel(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: ColorConstants.lightPrimaryAppv2Color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorConstants.white,
            ),
          ),
          Text(
            'Primary Account for',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(fontSize: 10, color: ColorConstants.white, height: 1),
          ),
          Text(
            isMf ? 'Mutual Fund' : 'Trading',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                fontSize: 10,
                color: ColorConstants.white,
                fontWeight: FontWeight.w600,
                height: 1),
          )
        ],
      ),
    );
  }
}
