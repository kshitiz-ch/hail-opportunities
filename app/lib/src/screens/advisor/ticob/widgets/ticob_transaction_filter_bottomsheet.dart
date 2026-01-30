import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/advisor/ticob_controller.dart';
import 'package:app/src/screens/advisor/ticob/widgets/ticob_transaction_filter_options.dart';
import 'package:app/src/screens/advisor/ticob/widgets/ticob_transaction_filters.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicobTransactionFilterBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TicobController>(
      builder: (controller) {
        if (controller.amcResponse.state == NetworkState.loading) {
          return SizedBox(
            height: 400,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (controller.amcResponse.state == NetworkState.error) {
          return SizedBox(
            height: 400,
            child: Center(
              child: RetryWidget(
                controller.amcResponse.message,
                onPressed: () {
                  controller.getAmcList();
                },
              ),
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Transactions By',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium
                        ?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
                  ),
                  CommonUI.bottomsheetCloseIcon(context)
                ],
              ),
            ),
            ConstrainedBox(
              constraints:
                  BoxConstraints(maxHeight: SizeConfig().screenHeight / 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TicobTransactionFilters(),
                  TicobTransactionFilterOptions(),
                ],
              ),
            ),
            _buildFilterCTA(context, controller),
          ],
        );
      },
    );
  }

  Widget _buildFilterCTA(BuildContext context, TicobController controller) {
    final style = Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: ColorConstants.primaryAppColor,
        );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: ActionButton(
              text: 'Clear All',
              margin: EdgeInsets.zero,
              bgColor: ColorConstants.secondaryButtonColor,
              textStyle: style,
              onPressed: () {
                controller.clearFilter();
                controller.fetchData();
                AutoRouter.of(context).popForced();
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ActionButton(
              margin: EdgeInsets.zero,
              text: 'Apply',
              textStyle: style?.copyWith(color: ColorConstants.white),
              onPressed: () {
                controller.savedTransactionFilter =
                    Map.from(controller.tempTransactionFilter);
                controller.fetchData();
                AutoRouter.of(context).popForced();
              },
            ),
          ),
        ],
      ),
    );
  }
}
