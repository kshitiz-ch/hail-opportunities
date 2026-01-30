import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/debenture/debenture_controller.dart';
import 'package:app/src/screens/store/debenture_detail/widgets/bottom_action_button.dart';
import 'package:app/src/screens/store/debenture_detail/widgets/overview_section.dart';
import 'package:app/src/screens/store/debenture_detail/widgets/trade_date_passed.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/store/models/debenture_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class DebentureDetailScreen extends StatelessWidget {
  const DebentureDetailScreen({
    Key? key,
    this.product,
    this.client,
    this.fromSearch = false,
  }) : super(key: key);

  final DebentureModel? product;
  final Client? client;
  final bool fromSearch;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DebentureController>(
      init: DebentureController(
        product: product,
        selectedClient: client,
      ),
      builder: (controller) {
        final isTradeDatePassed =
            DateTime.parse(product!.tradeDate!).isBefore(DateTime.now());
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            showBackButton: true,
            titleText: controller.product!.title.isNotNullOrEmpty
                ? controller.product!.title
                : null,
            subtitleText: controller.product!.description.isNotNullOrEmpty
                ? controller.product!.description
                : null,
          ),
          body: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100, top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'Overview',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .displaySmall!
                              .copyWith(
                                fontSize: 16,
                                color: ColorConstants.tertiaryBlack,
                              ),
                        ),
                      ),
                      OverviewSection(
                        product: controller.product,
                        controller: controller,
                      ),
                      if (controller.isConfirmationDateNotElapsed)
                        Text(
                          '*A pre-booking amount of ${WealthyAmount.currencyFormat(product!.confirmationAmount, 0)} per unit to be paid by ${controller.confirmationDateFormatted} if proposed today.',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color:
                                    ColorConstants.darkScaffoldBackgroundColor,
                              ),
                        ),
                      if (isTradeDatePassed)
                        TradeDatePassed()
                      else if (product!.lotCheckEnabled! &&
                          (product!.lotAvailable! <= 0 ||
                              product!.lotAvailable! <
                                  controller.minimumSecurities))
                        _buildNoUnitsText(context)
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomActionButton(),
        );
      },
    );
  }

  Widget _buildNoUnitsText(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: ColorConstants.secondaryCardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sufficient Units not Available',
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              'There are no sufficient units available to purchase this debenture',
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    height: 18 / 12,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
