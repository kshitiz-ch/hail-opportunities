import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';

class SchemeFolioCard extends StatelessWidget {
  const SchemeFolioCard(
      {Key? key,
      required this.displayName,
      required this.folioNumber,
      this.minAmount,
      this.isSameGoal = false})
      : super(key: key);

  final String? displayName;
  final String? folioNumber;
  final double? minAmount;
  final bool isSameGoal;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFundLogo(context, displayName),
            _buildFundName(context, displayName, folioNumber),
          ],
        ),
      ],
    );
  }

  Widget _buildFundLogo(context, String? displayName) {
    return CommonUI.buildRoundedFullAMCLogo(
      radius: 18,
      amcName: displayName,
    );
  }

  Widget _buildFundName(context, String? displayName, String? folioNumber) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName ?? '',
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: ColorConstants.black,
                  ),
            ),
            SizedBox(height: 5),
            if (folioNumber != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Folio #${folioNumber}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                    ),
                  ),
                ],
              )
            else if (minAmount != null)
              Text(
                'Min Amount ${WealthyAmount.currencyFormat(minAmount, 0)}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                      color: ColorConstants.tertiaryBlack,
                    ),
              )
            else
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ColorConstants.lightGreenBackgroundColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'New',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            color: ColorConstants.greenAccentColor,
                            fontSize: 11,
                          ),
                    ),
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}
