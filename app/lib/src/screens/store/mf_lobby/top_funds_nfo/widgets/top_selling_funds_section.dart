import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/top_funds_nfo_controller.dart';
import 'package:app/src/screens/store/mf_lobby/top_funds_nfo/widgets/top_selling_fund_list.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopSellingFundsSection extends StatelessWidget {
  const TopSellingFundsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: GetBuilder<TopFundsNfoController>(
          id: 'top-selling-funds',
          builder: (controller) {
            if (controller.topSellingFundsResponse.state ==
                NetworkState.loading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.topSellingFundsResponse.state ==
                    NetworkState.loaded &&
                (controller.topSellingFundsList?.screeners.isNotNullOrEmpty ??
                    false)) {
              return ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.topSellingFundsList!.screeners!.length,
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: 40,
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  ScreenerModel screener =
                      controller.topSellingFundsList!.screeners![index];
                  if (screener.uri.isNotNullOrEmpty &&
                      screener.uri!.contains("nfo")) {
                    return SizedBox();
                  }

                  return TopSellingFundsList(screener: screener);
                },
              );
            }

            return RetryWidget(
              'No Funds Found. Please try again',
              onPressed: () {
                controller.getTopSellingFundsNfo();
              },
            );
          },
        ),
      ),
    );
  }
}
