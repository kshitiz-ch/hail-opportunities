import 'dart:async';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/store/insurance/insurances_controller.dart';
import 'package:app/src/screens/store/insurance_list/widgets/coming_soon_insurance_card.dart';
import 'package:app/src/screens/store/insurance_list/widgets/insurance_card.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/card/product_card.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/annotations.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/store/models/insurance_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class InsuranceListScreen extends StatefulWidget {
  final List<InsuranceModel>? products;
  final Client? client;
  final String category;

  InsuranceListScreen({
    Key? key,
    this.products,
    @queryParam this.category = '',
    this.client,
  }) : super(key: key);

  @override
  State<InsuranceListScreen> createState() => _InsuranceListScreenState();
}

class _InsuranceListScreenState extends State<InsuranceListScreen> {
  Timer? timer;
  int activeLottieIndex = 0;

  _updateActiveLottieIndex(InsurancesController controller) {
    // ulips and retirement
    int totalInsurancesCount = 2;

    // For life category, we have term and savings insurance
    if (widget.category.isNotNullOrEmpty) {
      totalInsurancesCount += 2;
    } else {
      totalInsurancesCount += controller.insurancesResult.products!.length;
    }

    if (activeLottieIndex == totalInsurancesCount) {
      activeLottieIndex = 0;
    } else {
      activeLottieIndex++;
    }

    setState(() {});
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize InsurancesController
    Get.put(InsurancesController());
    final headerTextList = _buildHeaderText();

    return Scaffold(
      backgroundColor: ColorConstants.primaryScaffoldBackgroundColor,
      // App Bar
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: headerTextList.first,
        subtitleText: headerTextList.last,
      ),
      body: GetBuilder<InsurancesController>(
        initState: (_) async {
          // no need to get all insurances list data
          // if category is passed

          InsurancesController controller = Get.find<InsurancesController>();

          // If [products] is null or empty, fetch data from API
          // else use [products] to render data
          if (widget.products == null || widget.products!.isEmpty) {
            controller.insurancesResult.products = List.filled(
              3,
              InsuranceModel(),
            );

            await controller.onReady();
            await controller.getInsurances();
          } else {
            controller.insurancesResult.products = widget.products;
            controller.insurancesState = NetworkState.loaded;
          }
        },
        dispose: (_) {
          Get.delete<InsurancesController>();
        },
        builder: (controller) {
          int totalOnlineInsuranceCount = 0;
          if (controller.insurancesState == NetworkState.loaded) {
            if (widget.category.isNotNullOrEmpty) {
              totalOnlineInsuranceCount += 2;
            } else {
              totalOnlineInsuranceCount =
                  controller.insurancesResult.products!.length;
            }
          }

          if (controller.insurancesState == NetworkState.loaded &&
              timer == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              timer = Timer.periodic(Duration(seconds: 1, milliseconds: 250),
                  (Timer t) => _updateActiveLottieIndex(controller));
            });
          }
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            physics: ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.insurancesState == NetworkState.error)
                  SizedBox(
                    height: 500,
                    child: RetryWidget(
                      controller.insurancesErrorMessage,
                      onPressed: () => controller.getInsurances(),
                    ),
                  ),
                if (controller.insurancesState != NetworkState.error)
                  ...controller.insurancesResult.products!
                      .mapIndexed(
                        (product, index) => controller.insurancesState ==
                                NetworkState.loading
                            ? Container(
                                height: 180,
                                child: ProductCard().toShimmer(
                                  baseColor:
                                      ColorConstants.lightBackgroundColor,
                                  highlightColor: ColorConstants.white,
                                ),
                              )
                            : widget.category.isNotNullOrEmpty
                                ? widget.category ==
                                        insuranceSectionData[
                                            product.productVariant]!['category']
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16.0),
                                        child: InsuranceCard(
                                          product: product,
                                          client: widget.client,
                                          showGenerateQuoteButton: true,
                                          showLottieAnimation:
                                              index == activeLottieIndex,
                                        ),
                                      )
                                    : SizedBox()
                                : Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: InsuranceCard(
                                        product: product,
                                        client: widget.client,
                                        showLottieAnimation:
                                            index == activeLottieIndex),
                                  ),
                      )
                      .toList(),
                ...[
                  InsuranceProductVariant.PENSION,
                  InsuranceProductVariant.ULIP
                ]
                    .mapIndexed(
                      (variant, index) => controller.insurancesState ==
                              NetworkState.loading
                          ? Container(
                              height: 180,
                              child: ProductCard().toShimmer(
                                baseColor: ColorConstants.lightBackgroundColor,
                                highlightColor: ColorConstants.white,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: ComingSoonInsuranceCard(
                                productVariant: variant,
                                showLottieAnimation:
                                    index + (totalOnlineInsuranceCount) ==
                                        activeLottieIndex,
                              ),
                            ),
                    )
                    .toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  List<String> _buildHeaderText() {
    String titleText = '';
    String subtitleText = '';

    if (widget.category.isNotNullOrEmpty) {
      if (widget.category == 'life') {
        titleText = 'Life Insurance';
        subtitleText = 'Explore all Life Insurance products from Wealthy';
      }
    } else {
      titleText = 'All Products';
      subtitleText = 'Explore Insurance products from Wealthy';
    }
    return <String>[titleText, subtitleText];
  }
}
