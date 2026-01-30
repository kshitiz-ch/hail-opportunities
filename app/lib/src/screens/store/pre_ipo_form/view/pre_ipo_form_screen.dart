import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/pre_ipo/pre_ipo_controller.dart';
import 'package:app/src/screens/store/pre_ipo_form/widgets/form_section.dart';
import 'package:app/src/utils/fixed_center_docked_fab_location.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/client_store_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/store/models/unlisted_stocks_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

@RoutePage()
class PreIpoFormScreen extends StatelessWidget {
  // Fields
  final Client? client;
  final UnlistedProductModel? product;

  // Constructor
  const PreIpoFormScreen({
    Key? key,
    required this.client,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      // AppBar
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: 'Set Price & Quantity',
      ),

      // body
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        padding:
            const EdgeInsets.only(bottom: 100, left: 30, right: 30, top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client Details Section
            ClientStoreCard(
              client: client,
              padding: EdgeInsets.zero,
            ),

            SizedBox(
              height: 44,
            ),

            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      border: Border.all(color: ColorConstants.lightGrey),
                      borderRadius: BorderRadius.circular(50)),
                  height: 36,
                  width: 36,
                  child: Center(
                    child: product!.iconSvg != null &&
                            product!.iconSvg!.endsWith("svg")
                        ? SvgPicture.network(
                            product!.iconSvg!,
                          )
                        : Image.network(product!.iconSvg!),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Text(
                    product!.title!,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineLarge!
                        .copyWith(
                          fontSize: 16.0,
                        ),
                  ),
                ),
              ],
            ),

            // Form Section
            FormSection(
              product: product,
            ),
          ],
        ),
      ),

      floatingActionButtonLocation: FixedCenterDockedFabLocation(),

      floatingActionButton: GetBuilder<PreIPOController>(
        id: 'total-amt',
        builder: (controller) {
          return KeyboardVisibilityBuilder(
            builder: (context, isKeyboardVisible) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Total Investment',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall!
                                .copyWith(color: ColorConstants.tertiaryBlack),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${WealthyAmount.currencyFormatWithoutTrailingZero(
                              (controller.sharePrice ?? 0) *
                                  (controller.shares ?? 0),
                              2,
                            )}',
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
                        margin: EdgeInsets.zero,
                        heroTag: kDefaultHeroTag,
                        isDisabled: product!.lotCheckEnabled! &&
                            (product!.lotAvailable! <= 0),
                        text: 'Continue',
                        onPressed: () {
                          if (controller.formKey.currentState!.validate()) {
                            double totalAmount =
                                controller.sharePrice! * controller.shares!;
                            if (totalAmount < product!.minPurchaseAmount!) {
                              return showToast(
                                context: context,
                                text:
                                    'Min purchase Amount is ${WealthyAmount.currencyFormat(product!.minPurchaseAmount, 1)}',
                              );
                            } else {
                              if (client == null || product == null) {
                                return showToast(
                                    text:
                                        'Something went wrong again. Please try again');
                              }

                              AutoRouter.of(context).push(
                                PreIpoReviewProposalRoute(
                                  client: client!,
                                  product: product!,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
