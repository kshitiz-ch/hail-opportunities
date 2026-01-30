import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';

class FundListTileHeader extends StatelessWidget {
  final SchemeMetaModel fund;
  final double avatarRadius;

  const FundListTileHeader({
    Key? key,
    required this.fund,
    this.avatarRadius = 22,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        fund.displayName ?? '',
        style: Theme.of(context)
            .primaryTextTheme
            .titleMedium!
            .copyWith(fontSize: 14.0),
      ),
      subtitle: Text(
        '${fundTypeDescription(fund.fundType)} ${fund.category != null ? "| ${fund.category}" : ""}',
        style: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(
              color: Color(0xFF979797),
              fontSize: 11.0,
            ),
      ),
      leading: CommonUI.buildRoundedFullAMCLogo(
          radius: avatarRadius, amcName: fund.displayName),
      contentPadding: const EdgeInsets.all(0),
      horizontalTitleGap: 12,
      dense: true,
    );
  }
}
