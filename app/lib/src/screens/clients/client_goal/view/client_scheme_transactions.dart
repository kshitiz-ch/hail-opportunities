import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';

import '../widgets/goal_scheme_orders_list.dart';

@RoutePage()
class ClientSchemeTransactionsScreen extends StatelessWidget {
  const ClientSchemeTransactionsScreen({Key? key, required this.scheme})
      : super(key: key);

  final SchemeMetaModel scheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        maxLine: 2,
        titleText: scheme.displayName ?? 'Transactions',
        subtitleText:
            '${fundTypeDescription(scheme.fundType)} ${scheme.fundCategory != null ? "| ${scheme.fundCategory}" : ""}',
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 40),
        child: GoalSchemeOrdersList(wschemecode: scheme.wschemecode ?? ''),
      ),
    );
  }
}
