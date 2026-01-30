import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/pms/pms_product_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/card/pms_provider_card.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class PmsProviderListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PMSProductController>(
      init: PMSProductController(),
      id: GetxId.pmsProducts,
      builder: (controller) {
        String countText = '';
        if (controller.getPMSProductDataState == NetworkState.loaded &&
            controller.pmsProductModel != null &&
            controller.pmsProductModel!.products.isNotNullOrEmpty) {
          countText =
              '${controller.pmsProductModel!.products!.length} PMS${controller.pmsProductModel!.products!.length > 1 ? 's' : ''}';
        }
        return Scaffold(
          backgroundColor: ColorConstants.white,
          // App Bar
          appBar: CustomAppBar(
            showBackButton: true,
            titleText: 'Portfolio Management Services',
            subtitleText: countText,
          ),

          // Body
          body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 30),
              physics: ClampingScrollPhysics(),
              child: controller.getPMSProductDataState == NetworkState.loading
                  ? SizedBox(
                      height: SizeConfig().screenHeight * 0.8,
                      child: Center(child: CircularProgressIndicator()))
                  : controller.getPMSProductDataState == NetworkState.error
                      ? SizedBox(
                          height: SizeConfig().screenHeight * 0.8,
                          child: Center(
                            child: RetryWidget(
                              controller.getPMSProductDataErrorMessage ??
                                  genericErrorMessage,
                              onPressed: () => controller.getPMSProductData(),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            ...controller.pmsProductModel!.products!
                                .map(
                                  (product) => Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ).copyWith(bottom: 16),
                                    child: PMSProviderCard(
                                      iconUrl: product.iconSvg,
                                      description: product.productDescription ??
                                          notAvailableText,
                                      productCount: product.variants!.length,
                                      title: product.productManufacturer ??
                                          notAvailableText,
                                      onPressed: () {
                                        AutoRouter.of(context)
                                            .push(PmsProductListRoute(
                                          pmsProduct: product,
                                        ));
                                      },
                                    ),
                                  ),
                                )
                                .toList(),

                            // If result is empty
                            if (controller.pmsProductModel!.products == null ||
                                controller.pmsProductModel!.products!.isEmpty)
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                child: Center(
                                  child: Text(
                                    "Products coming soon!",
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .headlineSmall,
                                  ),
                                ),
                              )
                          ],
                        )),
        );
      },
    );
  }
}
