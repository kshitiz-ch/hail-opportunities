import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/store/debenture/debenture_controller.dart';
import 'package:app/src/screens/store/debenture_detail/widgets/overview_section.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomActionButton extends StatelessWidget {
  const BottomActionButton({Key? key}) : super(key: key);

  _navigateToDematScreen(context, DebentureController controller) {
    AutoRouter.of(context).push(DematsRoute(
      client: controller.selectedClient,
      productName: controller.product!.title,
      productOverview:
          OverviewSection(product: controller.product, controller: controller),
      onProceed: () {
        AutoRouter.of(context).push(DebentureReviewRoute(
          client: controller.selectedClient,
          product: controller.product,
        ));
      },
    ));
  }

  _onClickHandler(DebentureController controller, BuildContext context) async {
    if (controller.selectedClient != null) {
      _navigateToDematScreen(context, controller);
    } else {
      await AutoRouter.of(context).push(SelectClientRoute(
        onClientSelected: (Client? client, bool? isClientNew) async {
          controller.setSelectedClient(client);

          if (isClientNew ?? false) {
            AutoRouter.of(context).popForced();
          }
          if (client?.isSourceContacts ?? false) {
            AutoRouter.of(context).push(DebentureReviewRoute(
              client: client,
              product: controller.product,
            ));
          } else {
            _navigateToDematScreen(context, controller);
          }
        },
      ));
      controller.setSelectedClient(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DebentureController>(
      builder: (controller) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (controller.showSecuritiesInput)
              _buildSecurityInput(context, controller),
            _buildBottomAppBar(context, controller),
          ],
        );
      },
    );
  }

  Widget _buildSecurityInput(
      BuildContext context, DebentureController controller) {
    return Container(
      decoration: BoxDecoration(color: ColorConstants.secondaryAppColor),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Price per unit',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(color: ColorConstants.tertiaryBlack),
                ),
                SizedBox(height: 8),
                Text(
                  '${WealthyAmount.currencyFormat(controller.sellingPrice, 0, showSuffix: false)}',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 54,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: ColorConstants.white,
                  borderRadius: BorderRadius.circular(51)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    disabledColor: ColorConstants.lightGrey,
                    color: ColorConstants.primaryAppColor,
                    onPressed: !controller.disableDecrementSecurityButton
                        ? () {
                            controller.updateNoOfSecurities(
                              isIncrement: false,
                            );
                          }
                        : null,
                    icon: Icon(
                      Icons.remove,
                      size: 14,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(
                      controller.noOfSecuritiesController.text.toString(),
                      // '5',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .displayLarge!
                          .copyWith(
                            fontSize: 16,
                          ),
                    ),
                  ),
                  IconButton(
                    disabledColor: ColorConstants.lightGrey,
                    color: ColorConstants.primaryAppColor,
                    onPressed: !controller.disableIncrementSecurityButton
                        ? () {
                            controller.updateNoOfSecurities(isIncrement: true);
                          }
                        : null,
                    icon: Icon(
                      Icons.add,
                      size: 14,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAppBar(
      BuildContext context, DebentureController controller) {
    final isTradeDatePassed =
        DateTime.parse(controller.product!.tradeDate!).isBefore(DateTime.now());
    final bool isUnitsNotAvailable = (controller.product!.lotCheckEnabled! &&
        (controller.product!.lotAvailable! <= 0 ||
            controller.product!.lotAvailable! < controller.minimumSecurities));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  controller.showSecuritiesInput
                      ? 'Total Investment'
                      : 'Price per unit',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(color: ColorConstants.tertiaryBlack),
                ),
                SizedBox(height: 8),
                Text(
                  controller.showSecuritiesInput
                      ? '${WealthyAmount.currencyFormat((controller.totalAmount ?? 0), 0, showSuffix: false)}'
                      : '${WealthyAmount.currencyFormat(controller.sellingPrice, 0, showSuffix: false)}',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Expanded(
            child: ActionButton(
              isDisabled: isTradeDatePassed || isUnitsNotAvailable,
              margin: EdgeInsets.zero,
              heroTag: kDefaultHeroTag,
              text: controller.showSecuritiesInput ? 'Continue' : 'Add',
              onPressed: () {
                if (controller.showSecuritiesInput) {
                  _onClickHandler(controller, context);
                } else {
                  controller.setshowSecuritiesInput();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
