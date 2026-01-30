import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/store/debenture/debentures_controller.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/card/product_card.dart';
import 'package:app/src/widgets/card/product_card_new.dart';
import 'package:app/src/widgets/misc/get_product_bottom_data.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/store/models/debenture_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

@RoutePage()
class DebentureListScreen extends StatelessWidget {
  final List<DebentureModel>? products;
  final Client? client;

  const DebentureListScreen({
    Key? key,
    this.products,
    this.client,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Initialize DebenturesController
    Get.put(DebenturesController());

    return GetBuilder<DebenturesController>(
      initState: (_) async {
        DebenturesController controller = Get.find<DebenturesController>();

        // If [products] is null or empty, fetch data from API
        // else use [products] to render data
        if (products == null || products!.isEmpty) {
          controller.debenturesResult.products.addAll(List.filled(
            3,
            DebentureModel(),
          ));
        } else {
          controller.debenturesResult.products.addAll(products!);
          controller.debenturesState = NetworkState.loaded;
        }
      },
      dispose: (_) {
        Get.delete<DebenturesController>();
      },
      builder: (controller) {
        final countText = (controller.debenturesState == NetworkState.loaded &&
                controller.debenturesResult.products.isNotEmpty)
            ? '${controller.debenturesResult.products.length} Debentures'
            : '';
        return Scaffold(
          backgroundColor: ColorConstants.white,

          // App Bar
          appBar: CustomAppBar(
            titleText: 'Debentures',
            showBackButton: true,
            subtitleText: countText,
          ),
          body: ListView(
            padding: EdgeInsets.only(top: 30),
            physics: ClampingScrollPhysics(),
            children: [
              if (controller.debenturesState == NetworkState.error)
                SizedBox(
                  height: 500,
                  child: RetryWidget(
                    controller.debenturesErrorMessage,
                    onPressed: () => controller.getDebentures(),
                  ),
                ),

              if (controller.debenturesState != NetworkState.error)
                ...controller.debenturesResult.products
                    .map(
                      (product) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        margin: EdgeInsets.only(bottom: 16),
                        child:
                            controller.debenturesState == NetworkState.loading
                                ? Container(
                                    height: 180,
                                    child: ProductCard().toShimmer(
                                      baseColor:
                                          ColorConstants.lightBackgroundColor,
                                      highlightColor: ColorConstants.white,
                                    ),
                                  )
                                : ProductCardNew(
                                    bgColor: ColorConstants.primaryCardColor,
                                    leadingWidget: Container(
                                      margin: EdgeInsets.only(right: 12),
                                      height: 36,
                                      width: 36,
                                      child: product.iconSvg != null &&
                                              product.iconSvg!.endsWith("svg")
                                          ? SvgPicture.network(
                                              product.iconSvg!,
                                            )
                                          : Image.network(product.iconSvg!),
                                    ),
                                    title: product.title,
                                    description: 'ISIN · ${product.isin}',
                                    onTap: () {
                                      AutoRouter.of(context).push(
                                        DebentureDetailRoute(
                                          client: client,
                                          product: product,
                                        ),
                                      );
                                    },
                                    bottomData: getProductBottomData(product),
                                    // bottomData: [
                                    // BottomData(
                                    //   title: WealthyAmount.currencyFormat(
                                    //     product.sellPrice,
                                    //     0,
                                    //   ),
                                    //   subtitle: "Selling Price",
                                    // ),
                                    // BottomData(
                                    //   title: WealthyAmount.currencyFormat(
                                    //     product.minPurchaseAmount,
                                    //     0,
                                    //   ),
                                    //   subtitle: "Min Purchase Amount",
                                    // ),
                                    // ],
                                  ),
                      ),
                    )
                    .toList(),

              // If result is empty
              if (controller.debenturesResult.products.isEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Text(
                      "Products coming soon!",
                      style: Theme.of(context).primaryTextTheme.headlineSmall,
                    ),
                  ),
                ),

              // Bottom Padding
              SizedBox(
                height: 26.0,
              ),
            ],
          ),
        );
      },
    );
  }
}
