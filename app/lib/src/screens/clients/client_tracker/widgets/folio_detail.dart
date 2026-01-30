// Extracted widget for folio details to avoid duplication.
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';

class FolioDetail extends StatelessWidget {
  final SchemeMetaModel fund;

  const FolioDetail({
    Key? key,
    required this.fund,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = context.titleLarge!.copyWith(
      color: ColorConstants.tertiaryBlack,
      fontWeight: FontWeight.w500,
      overflow: TextOverflow.ellipsis,
    );

    final folioNumber = fund.folioOverview?.folioNumber;
    final withdrawableAmount = fund.folioOverview?.withdrawalAmountAvailable;
    final availableUnits = fund.folioOverview?.withdrawalUnitsAvailable;

    String arnText = '';
    final arn = fund.folioOverview?.advisorArn;

    if (arn.isNotNullOrEmpty) {
      final isArnInternal = ["ARN-106846", "WEALTHYON"].contains(arn);
      final arnSource = isArnInternal ? 'wealthy/internal' : 'external';

      if (arn!.toLowerCase().startsWith("arn")) {
        arnText += '$arn (${arnSource})';
      } else {
        arnText += 'ARN $arn (${arnSource})';
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Amount: ${WealthyAmount.currencyFormat(withdrawableAmount, 2)},',
          style: style,
        ),
        SizedBox(height: 4),
        Text(
          'Available Units: ${availableUnits?.toStringAsFixed(2)}',
          style: style,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            folioNumber != null ? 'Folio #${folioNumber}' : 'Folio N/A',
            style: style,
          ),
        ),
        Text(arnText, style: style),
      ],
    );
  }
}
