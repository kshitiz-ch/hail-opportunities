import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/goal/stp_detail_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/card/scheme_folio_card.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SchemeData extends StatelessWidget {
  const SchemeData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fund Details',
            style: Theme.of(context).primaryTextTheme.headlineMedium,
          ),
          SizedBox(height: 15),
          GetBuilder<StpDetailController>(
            id: GetxId.schemeData,
            builder: (controller) {
              if (controller.switchInSchemeDataState == NetworkState.loading) {
                return SkeltonLoaderCard(height: 100);
              }

              // if (controller.switchInSchemeDataState == NetworkState.error) {
              //   return RetryWidget(
              //     'Failed to load. Please try again',
              //     onPressed: () {
              //       controller.getSchemeData();
              //     },
              //   );
              // }

              // if (controller.switchInSchemeDataState == NetworkState.loaded &&
              //     controller.switch) {
              // }
              if (controller.stp.switchFunds.isNotNullOrEmpty) {
                return _buildSchemeDetails(context, controller);
              }

              return Center(
                child: Text(
                  'No Data Found',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(color: ColorConstants.tertiaryBlack),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeDetails(
      BuildContext context, StpDetailController controller) {
    return Column(
      children: [
        SchemeFolioCard(
          displayName: controller.stp.switchFunds!.first.switchinSchemeName,
          folioNumber: controller.stp.switchFunds!.first.folioNumber,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Image.asset(AllImages().switchFundIcon, width: 30),
        ),
        SchemeFolioCard(
          displayName: controller.stp.switchFunds!.first.switchoutSchemeName,
          folioNumber: null,
        ),
      ],
    );
  }
}
