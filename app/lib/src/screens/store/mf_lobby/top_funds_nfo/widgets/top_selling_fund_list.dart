import 'package:app/src/config/constants/enums.dart';

import 'package:app/src/controllers/store/mutual_fund/screener_controller.dart';
import 'package:app/src/widgets/list/screener_table.dart';
import 'package:app/src/widgets/loader/screener_table_skelton.dart';

import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopSellingFundsList extends StatelessWidget {
  const TopSellingFundsList({
    Key? key,
    required this.screener,
  }) : super(key: key);

  final ScreenerModel screener;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScreenerController>(
      init: ScreenerController(
        screener: screener,
        fromListScreen: false,
      ),
      autoRemove: false,
      tag: screener.wpc,
      global: false,
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${screener.name}',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineLarge!
                  .copyWith(fontSize: 16),
            ),
            SizedBox(height: 20),
            if (controller.screenerResponse.state == NetworkState.loading)
              ScreenerTableSkelton()
            else if (controller.screenerResponse.state == NetworkState.loaded)
              ScreenerTable(controller: controller)
            // _buildSchemeTable(context, controller)
            else if (controller.screenerResponse.state == NetworkState.error)
              _buildRetryWidget(controller)
            else
              SizedBox()
          ],
        );
      },
    );
  }

  Widget _buildRetryWidget(ScreenerController controller) {
    return RetryWidget(
      controller.screenerResponse.message,
      onPressed: () {
        controller.getSchemes();
      },
    );
  }

  // Widget _buildSchemeTable(
  //     BuildContext context, ScreenerController controller) {
  //   return Column(
  //     children: [
  //       Container(
  //         decoration: BoxDecoration(
  //           border: Border.all(color: ColorConstants.borderColor),
  //           borderRadius: BorderRadius.all(Radius.circular(6)),
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             SchemeTableHeader(controller: controller),
  //             if (controller.schemes.isNotEmpty)
  //               SchemeList(controller: controller)
  //             else
  //               Padding(
  //                 padding: EdgeInsets.symmetric(vertical: 16),
  //                 child: Text(
  //                   'No Scheme Found',
  //                   style: Theme.of(context).primaryTextTheme.headlineSmall,
  //                 ),
  //               )
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
