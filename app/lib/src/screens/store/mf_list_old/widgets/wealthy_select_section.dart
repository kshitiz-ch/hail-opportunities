import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/funds_controller.dart';
import 'package:app/src/screens/store/fund_list/widgets/basket_bottom_bar.dart';
import 'package:app/src/screens/store/mf_list_old/widgets/mf_product_card.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/card/product_card.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'filter_buttons.dart';
import 'search_bar.dart';

class WealthySelectSection extends StatelessWidget {
  const WealthySelectSection({
    Key? key,
    this.tag,
    this.basketController,
  }) : super(key: key);

  final String? tag;
  final BasketController? basketController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child:
                      SearchBarSection(tag: tag, hint: 'Search from 50+ funds'),
                  flex: 3,
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: FilterButtons(
                    tag: tag,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: GetBuilder<FundsController>(
              tag: tag,
              initState: (_) {
                FundsController fundsController =
                    Get.find<FundsController>(tag: tag);

                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  if (fundsController.fundsState != NetworkState.loaded) {
                    fundsController.getMutualFunds();
                  }
                });
              },
              id: 'funds',
              global: true,
              builder: (controller) {
                return Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Builder(
                          builder: (context) {
                            if (controller.fundsResult!.length == 0 &&
                                controller.fundsState == NetworkState.loaded) {
                              return _buildEmptyState(context, controller);
                            }

                            if (controller.fundsState == NetworkState.error) {
                              return _buildRetryWidget(controller);
                            }

                            if (controller.fundsState == NetworkState.loading &&
                                !controller.isPaginating) {
                              return _buildShimmerCards(context, controller);
                            }

                            if (controller.fundsState == NetworkState.loaded) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: controller.fundsResult!.length,
                                      physics: ClampingScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      controller: controller.scrollController,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 12),
                                          child: AnimatedSwitcher(
                                            duration:
                                                Duration(milliseconds: 500),
                                            child: MfProductCard(
                                                index: index,
                                                fund: controller
                                                    .fundsResult![index],
                                                basketController:
                                                    basketController),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                ],
                              );
                            }

                            return SizedBox();
                          },
                        ),
                      ),
                    ),
                    _buildInfiniteLoader(),
                    KeyboardVisibilityBuilder(
                        builder: (context, isKeyboardVisible) {
                      if (isKeyboardVisible) {
                        return SizedBox();
                      }
                      return GetBuilder<BasketController>(
                        id: 'basket',
                        global: true,
                        init: Get.find<BasketController>(),
                        builder: (basketController) {
                          return basketController.basket.isEmpty
                              ? SizedBox()
                              : BasketBottomBar(
                                  controller: basketController,
                                  fund: null,
                                );
                        },
                      );
                    })
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(context, FundsController controller) {
    if (controller.searchText.isEmpty) {
      return SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AllImages().fundSearchIcon,
                width: 104,
              ),
              SizedBox(height: 24),
              Text(
                'Sorry! No funds found',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineMedium!
                    .copyWith(
                        color: ColorConstants.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                'start searching for your favourite funds',
                textAlign: TextAlign.center,
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          fontSize: 13,
                          color: ColorConstants.tertiaryBlack,
                        ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AllImages().fundSearchIcon,
                width: 104,
              ),
              Text(
                'Sorry! No result found',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineMedium!
                    .copyWith(
                        color: ColorConstants.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                'we couldn\'t find any match for that',
                textAlign: TextAlign.center,
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          fontSize: 13,
                          color: ColorConstants.tertiaryBlack,
                        ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildInfiniteLoader() {
    return GetBuilder<FundsController>(
      tag: tag,
      id: 'pagination-loader',
      global: true,
      builder: (controller) {
        if (controller.isPaginating) {
          return Container(
            height: 30,
            margin: EdgeInsets.only(bottom: 10, top: 10),
            alignment: Alignment.center,
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }

        return SizedBox();
      },
    );
  }

  Widget _buildShimmerCards(context, FundsController controller) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 260,
          child: ProductCard().toShimmer(
            baseColor: ColorConstants.lightBackgroundColor,
            highlightColor: ColorConstants.white,
          ),
        );
      },
    );
  }

  Widget _buildRetryWidget(FundsController controller) {
    return SizedBox(
      height: 500,
      child: RetryWidget(
        controller.fundsErrorMessage.isNotNullOrEmpty
            ? controller.fundsErrorMessage
            : 'Something went wrong. Please try again',
        onPressed: () => controller.getMutualFunds(),
      ),
    );
  }
}
