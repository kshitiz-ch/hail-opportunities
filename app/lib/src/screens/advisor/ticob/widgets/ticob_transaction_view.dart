import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/ticob_controller.dart';
import 'package:app/src/screens/advisor/ticob/widgets/ticob_transaction_card.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicobTransactionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TicobController>(
      builder: (controller) {
        if (!controller.isPaginating &&
            controller.ticobTransactionResponse.state == NetworkState.loading) {
          return SkeltonLoaderCard(height: 500);
        }
        if (controller.ticobTransactionResponse.state == NetworkState.error) {
          return Center(
            child: RetryWidget(
              controller.ticobTransactionResponse.message,
              onPressed: () {
                controller.fetchData();
              },
            ),
          );
        }
        if (controller.ticobTransactionResponse.state == NetworkState.loaded &&
            controller.ticobTransactionList.isNullOrEmpty) {
          return Center(
            child: EmptyScreen(message: 'No transaction found'),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.only(bottom: 20),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TicobTransactionCard(
                    ticobTransactionModel:
                        controller.ticobTransactionList[index],
                  ),
                ),
                separatorBuilder: (context, index) => SizedBox(height: 10),
                itemCount: controller.ticobTransactionList.length,
                controller: controller.scrollController,
              ),
            ),
            if (controller.isPaginating) CommonUI.buildInfiniteLoader(),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final style = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          color: ColorConstants.tertiaryBlack,
        );
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
              child: Text(
            'Client Details',
            style: style,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )),
          SizedBox(width: 10),
          Expanded(
              child: Text(
            'AMC & Folio no.',
            style: style,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )),
          SizedBox(width: 10),
          Expanded(
              child: Text(
            'Current & Invested',
            style: style,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )),
          SizedBox(width: 30),
        ],
      ),
    );
  }
}
