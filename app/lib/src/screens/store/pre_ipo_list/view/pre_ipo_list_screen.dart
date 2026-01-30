import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/store/pre_ipo/pre_ipos_controller.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/card/product_card.dart';
import 'package:app/src/widgets/card/product_card_new.dart';
import 'package:app/src/widgets/card/product_video_card.dart';
import 'package:app/src/widgets/misc/get_product_bottom_data.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/store/models/unlisted_stocks_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

@RoutePage()
class PreIpoListScreen extends StatelessWidget {
  // Fields
  final List<UnlistedProductModel>? products;
  final Client? client;

  // Constructor
  const PreIpoListScreen({
    Key? key,
    this.products,
    this.client,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize PreIPOsController
    Get.put(PreIPOsController());

    return GetBuilder<PreIPOsController>(
      initState: (_) async {
        PreIPOsController controller = Get.find<PreIPOsController>();

        // If [products] is null or empty, fetch data from API
        // else use [products] to render data
        if (products == null || products!.isEmpty) {
          controller.preIPOsResult.products = List.filled(
            3,
            UnlistedProductModel(),
          );

          await controller.onReady();
          // await controller.getPreIPOs();
        } else {
          controller.preIPOsResult.products = products;
          controller.preIPOsState = NetworkState.loaded;
        }
      },
      dispose: (_) {
        Get.delete<PreIPOsController>();
      },
      builder: (controller) {
        final countText = (controller.preIPOsState == NetworkState.loaded &&
                controller.preIPOsResult.products!.isNotEmpty)
            ? '${controller.preIPOsResult.products!.length} Pre-IPOs'
            : '';
        return Scaffold(
          backgroundColor: Colors.white,

          // AppBar
          appBar: CustomAppBar(
            titleText: 'Pre-IPOs',
            showBackButton: true,
            subtitleText: countText,
          ),
          body: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: GetBuilder<PreIPOsController>(
                    id: 'product-video',
                    builder: (controller) {
                      if (controller.productVideoState == NetworkState.loaded &&
                          controller.productVideo != null) {
                        return ProductVideoCard(
                          title:
                              'Watch the video below to learn more about Pre-IPOs',
                          productType: ProductVideosType.PRE_IPO,
                          isProductVideoViewed: controller.isProductVideoViewed,
                          video: controller.productVideo,
                          currentRoute: PreIpoListRoute.name,
                        );
                      }
                      return SizedBox();
                    },
                  ),
                ),

                SizedBox(
                  height: 24,
                ),

                if (controller.preIPOsState == NetworkState.error)
                  SizedBox(
                    height: 500,
                    child: RetryWidget(
                      controller.preIPOsErrorMessage,
                      onPressed: () => controller.getPreIPOs(),
                    ),
                  ),

                if (controller.preIPOsState != NetworkState.error)
                  ...controller.preIPOsResult.products!
                      .map(
                        (product) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          margin: EdgeInsets.only(bottom: 16),
                          child: controller.preIPOsState == NetworkState.loading
                              ? Container(
                                  height: 180,
                                  child: ProductCard().toShimmer(
                                    baseColor:
                                        ColorConstants.lightBackgroundColor,
                                    highlightColor: ColorConstants.white,
                                  ),
                                )
                              : ProductCardNew(
                                  bgColor: ColorConstants.secondaryWhite,
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
                                    AutoRouter.of(context)
                                        .push(PreIpoDetailRoute(
                                      client: client,
                                      product: product,
                                    ));
                                  },
                                  bottomData: getProductBottomData(product),
                                ),
                        ),
                      )
                      .toList(),

                // Bottom Padding
                SizedBox(
                  height: 26.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
