import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:flutter/material.dart';

class ClientBankCard extends StatelessWidget {
  const ClientBankCard({Key? key, required this.bank}) : super(key: key);

  final BankAccountModel bank;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bank Details',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                border: Border.all(color: ColorConstants.borderColor),
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                _buildBankNameLogo(context),
                SizedBox(height: 20),
                _buildBankBottomData(context),
              ],
            ),
          ),
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
              (bank.bank ?? '-'),
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
      ],
    );
  }
}
