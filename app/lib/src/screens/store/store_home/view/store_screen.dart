import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/controllers/store/store_controller.dart';
import 'package:app/src/screens/store/fund_list/widgets/basket_bottom_bar.dart';
import 'package:app/src/screens/store/store_home/widgets/insurances_section.dart';
import 'package:app/src/screens/store/store_home/widgets/popular_funds_section.dart';
import 'package:app/src/screens/store/store_home/widgets/popular_portfolios_section.dart';
import 'package:app/src/screens/store/store_home/widgets/quick_nav_buttons_section.dart';
import 'package:app/src/screens/store/store_home/widgets/wealthy_product_section.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const storeSearchControllerTag = 'store_product_search';

@RoutePage()
class StoreScreen extends StatefulWidget {
  // Constructor
  StoreScreen({
    Key? key,
    this.client,
    this.showBackButton = false,
  }) : super(key: key);

  final Client? client;
  final bool showBackButton;

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  @override
  void initState() {
    // final showCaseController = Get.find<ShowCaseController>();
    // if (showCaseController.activeShowCaseIndex == 1) {
    //   bool isSwitchedToStoreShowCase =
    //       showCaseController.currentActiveList.isNotEmpty &&
    //           showCaseController.currentActiveList[0]['id'] ==
    //               showCaseIds.StoreSearchBar.id;

    //   if (!isSwitchedToStoreShowCase) {
    //     showCaseController.switchToStoreShowCaseList();
    //   }
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize Basket
    Get.isRegistered<BasketController>()
        ? Get.find<BasketController>()
        : Get.put(BasketController(), permanent: true);

    return Scaffold(
      backgroundColor: ColorConstants.white,
      // App Bar
      appBar: CustomAppBar(
        showBackButton: widget.showBackButton,
        leadingLeftPadding: 20,
        titleText: 'Store',
      ),

      // Body
      body: GetBuilder<StoreController>(
        init: StoreController(selectedClient: widget.client),
        initState: (_) {},
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 12.0),
              //   child: SearchBarSection(
              //     tag: storeSearchControllerTag,
              //   ),
              // ),
              SizedBox(height: 20),
              Expanded(
                child: _buildStoreScreenBody(controller),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: GetBuilder<BasketController>(
        id: 'basket',
        dispose: (_) {
          if (Get.isRegistered<BasketController>()) {
            BasketController basketController = Get.find<BasketController>();
            basketController.selectedClient = null;
            basketController.fromClientScreen = false;
          }
        },
        initState: (_) {
          if (widget.client != null && Get.isRegistered<BasketController>()) {
            BasketController basketController = Get.find<BasketController>();
            basketController.selectedClient = widget.client;
            basketController.fromClientScreen = true;
          }
        },
        builder: (controller) {
          return AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,
            child: controller.basket.isEmpty
                ? SizedBox()
                : BasketBottomBar(
                    controller: controller,
                    tag: null,
                    fund: null,
                  ),

            // BasketBottomAppBar(
            //     fundsCount: controller.itemCount,
            //     total: controller.totalAmount,
            //   ),
          );
        },
      ),
    );
  }

  Widget _buildStoreScreenBody(StoreController controller) {
    return ListView(
      physics: ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 50),
      children: [
        GetBuilder<StoreController>(
          id: 'popular-products',
          builder: (_) {
            return Column(
              children: [
                QuickNavButtonsSection(storeController: controller),
                // products carousel
                ...controller.productSectionOrder.map((value) {
                  // Temp Hide
                  if (false && value == StoreProductSections.MF_PORTFOLIOS) {
                    return PopularPortfoliosSection(controller: controller);
                  } else if (false && value == StoreProductSections.MF_FUNDS) {
                    return PopularFundsSection(controller: controller);
                  } else if (value == StoreProductSections.WEALTHY_PRODUCTS) {
                    return WealthyProductSection(controller: controller);
                  } else if (value == StoreProductSections.INSURANCE) {
                    return InsurancesSection(controller: controller);
                  } else {
                    return SizedBox();
                  }
                }).toList(),
              ],
            );
          },
        )
      ],
    );
  }
}
