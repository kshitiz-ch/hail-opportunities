import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/store/mutual_fund/nfos_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/screener_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/top_funds_nfo_controller.dart';
import 'package:app/src/widgets/loader/screener_table_skelton.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'nfo_list.dart';

class NfoSection extends StatelessWidget {
  const NfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 30),
      child: GetBuilder<TopFundsNfoController>(
        id: 'top-selling-funds',
        builder: (controller) {
          if (controller.topSellingFundsResponse.state ==
              NetworkState.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.topSellingFundsResponse.state == NetworkState.loaded &&
              (controller.nfoScreener != null)) {
            return _buildNfoScreener(context, controller.nfoScreener!);
          }

          return RetryWidget(
            'No Funds Found. Please try again',
            onPressed: () {
              controller.getTopSellingFundsNfo();
            },
          );
        },
      ),
    );
  }

  Widget _buildNfoScreener(BuildContext context, ScreenerModel screener) {
    return GetBuilder<NfosController>(
      init: NfosController(
        screener: screener,
      ),
      autoRemove: false,
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   '${screener.name}',
            //   style: Theme.of(context)
            //       .primaryTextTheme
            //       .headlineLarge!
            //       .copyWith(fontSize: 16),
            // ),
            // SizedBox(height: 20),
            if (!controller.isPaginating &&
                controller.nfoListResponse.state == NetworkState.loading)
              ScreenerTableSkelton()
            else if (controller.nfoListResponse.state == NetworkState.error)
              RetryWidget(
                'Something went wrong. Please try again',
                onPressed: () {
                  controller.getNfos();
                },
              )
            else if (controller.nfos.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Text(
                    'No NFOs Found',
                    style: Theme.of(context).primaryTextTheme.headlineSmall,
                  ),
                ),
              )
            else
              Flexible(
                child: NfoList(controller: controller),
              )
          ],
        );
      },
    );
  }
}
