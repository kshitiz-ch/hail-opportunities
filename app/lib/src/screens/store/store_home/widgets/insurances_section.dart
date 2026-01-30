import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/store/store_controller.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/card/insurance_card.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/text/section_header.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/store/models/insurance_model.dart';
import 'package:flutter/material.dart';

class InsurancesSection extends StatelessWidget {
  const InsurancesSection({Key? key, required this.controller})
      : super(key: key);

  final StoreController controller;

  String? getProductIcon(InsuranceModel product) {
    switch (product.productVariant!.toLowerCase()) {
      case InsuranceProductVariant.TERM:
        return "https://res.cloudinary.com/dti7rcsxl/image/upload/v1659350653/store_term_ltrtiv.svg";
      case InsuranceProductVariant.HEALTH:
        return "https://res.cloudinary.com/dti7rcsxl/image/upload/v1659350653/store_health_iqzpzm.svg";
      case InsuranceProductVariant.TWO_WHEELER:
        return "https://res.cloudinary.com/dti7rcsxl/image/upload/v1659350653/store_two_wheeler_wloufd.svg";
      // TODO: update the icon for four wheeler
      case InsuranceProductVariant.FOUR_WHEELER:
        return "https://res.cloudinary.com/dti7rcsxl/image/upload/v1664439601/vehicle_insurance_1_aup6x0.svg";
      default:
        return product.iconSvg;
    }
  }

  Color getCardColor(InsuranceModel product) {
    switch (product.productVariant!.toLowerCase()) {
      case InsuranceProductVariant.TERM:
        return ColorConstants.termLifeBgColor;
      case InsuranceProductVariant.HEALTH:
        return ColorConstants.lavenderColor;
      case InsuranceProductVariant.TWO_WHEELER:
        return ColorConstants.sandColor;
      case InsuranceProductVariant.FOUR_WHEELER:
        return ColorConstants.fourWheelerBgColor;
      default:
        return ColorConstants.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<InsuranceModel> products =
        controller.popularProductsResult.insuranceModel.products;

    return (controller.popularProductsState == NetworkState.loaded &&
            products.isEmpty)
        ? SizedBox()
        : Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: [
                SectionHeader(title: 'Explore Insurance Types'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0)
                      .copyWith(top: 16),
                  child: Column(
                    children: [
                      if (controller.popularProductsState ==
                          NetworkState.loading)
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: ColorConstants.lightBackgroundColor,
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                        ).toShimmer(
                          baseColor: ColorConstants.lightBackgroundColor,
                          highlightColor: ColorConstants.white,
                        )
                      else if (controller.popularProductsState ==
                          NetworkState.error)
                        Container(
                          height: 150,
                          child: RetryWidget(
                            controller.popularProductsErrorMessage,
                            onPressed: () =>
                                controller.getPopularProducts(isRetry: true),
                          ),
                        )
                      else
                        _buildInsuranceProductCards(products),
                    ],
                  ),
                )
              ],
            ),
          );
  }

  Widget _buildInsuranceProductCards(List<InsuranceModel> products) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: min(2, products.length),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (BuildContext context, int index) {
        InsuranceModel product = products[index];
        String? productIcon = getProductIcon(product);

        if (product.productVariant == InsuranceProductVariant.FOUR_WHEELER ||
            product.productVariant == InsuranceProductVariant.TWO_WHEELER) {
          return SizedBox();
        }

        return InsuranceCard(
          bgColor: getCardColor(product),
          productIcon: productIcon,
          title: product.title,
          onPressed: () {
            AutoRouter.of(context).push(
              InsuranceDetailRoute(
                  insuranceData: product,
                  selectedClient: controller.selectedClient),
            );
          },
        );
      },
    );
  }
}
