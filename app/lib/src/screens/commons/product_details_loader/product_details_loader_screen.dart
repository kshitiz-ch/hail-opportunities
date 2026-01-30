import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/controllers/store/store_search_controller.dart';
import 'package:app/src/screens/store/fund_list/widgets/basket_bottom_bar.dart';
import 'package:app/src/widgets/loader/cards_list_loader.dart';
import 'package:app/src/widgets/loader/fund_detail_loader.dart';
import 'package:app/src/widgets/loader/mf_detail_loader.dart';
import 'package:app/src/widgets/loader/preipo_detail_loader.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/debenture_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:core/modules/store/models/pms_product_model.dart';
import 'package:core/modules/store/models/unlisted_stocks_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class ProductDetailsLoaderScreen extends StatefulWidget {
  ProductDetailsLoaderScreen({
    Key? key,
    this.category,
    this.productType,
    this.productVariant,
    this.selectedClient,
    this.tag,
  }) : super(key: key);
  final Client? selectedClient;
  final String? category;
  final String? productType;
  final String? productVariant;
  final String? tag;

  @override
  State<ProductDetailsLoaderScreen> createState() =>
      _ProductDetailsLoaderScreenState();
}

class _ProductDetailsLoaderScreenState
    extends State<ProductDetailsLoaderScreen> {
  late StoreSearchController storeSearchController;
  late String productType;

  @override
  void initState() {
    productType = (widget.productType ?? '').toLowerCase();
    storeSearchController = Get.find<StoreSearchController>();

    bool isInsurance = widget.category == ProductCategoryType.INSURANCE;

    if (productType == ProductType.MF_FUND) {
      storeSearchController.getStoreFund(widget.productVariant!);
    } else if (!isInsurance) {
      storeSearchController.getStoreProduct(
          widget.category!, productType, widget.productVariant!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreSearchController>(
      id: GetxId.storeProductDetail,
      init: Get.find<StoreSearchController>(),
      builder: (storeController) {
        bool isProductDetailLoaded = false;
        bool isProductDetailError = false;

        if (productType == ProductType.MF_FUND) {
          isProductDetailLoaded =
              storeController.storeFundState == NetworkState.loaded;
          isProductDetailError =
              storeController.storeFundState == NetworkState.error;
        } else {
          isProductDetailLoaded =
              storeController.storeProductState == NetworkState.loaded;
          isProductDetailError =
              storeController.storeProductState == NetworkState.error;
        }

        if (isProductDetailLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToProductDetailScreen();
          });
        }

        Widget productLoaderWidget;

        switch (productType) {
          case ProductType.MF:
            productLoaderWidget = MfDetailLoader();
            break;
          case ProductType.MF_FUND:
            productLoaderWidget = FundDetailLoader();
            break;
          case ProductType.UNLISTED_STOCK:
            productLoaderWidget = PreIPODetailLoader(
              overviewItemCount: 6,
            );
            break;
          case ProductType.DEBENTURE:
            productLoaderWidget = PreIPODetailLoader();
            break;
          case ProductType.FIXED_DEPOSIT:
            productLoaderWidget = PreIPODetailLoader(
              overviewItemCount: 2,
            );
            break;
          case ProductType.PMS:
            productLoaderWidget = CardsListLoader(
              itemCount: 2,
              appBarText: 'PMS',
            );
            break;
          default:
            productLoaderWidget = Center(
              child: Text('This product is currently unavailable'),
            );
            break;
        }

        return Scaffold(
          body: Material(
            child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: isProductDetailError
                    ? Center(
                        child: Text('This product is currently unavailable'),
                      )
                    : productLoaderWidget),
          ),
        );
      },
    );
  }

  _navigateToProductDetailScreen() async {
    late PageRouteInfo screenToNavigate;

    switch (productType) {
      case ProductType.MF:
        final product =
            MFProductModel.fromJson(storeSearchController.storeProductResult);
        screenToNavigate = MfPortfolioDetailRoute(
            portfolio: product.goalSubtypes!.first,
            client: widget.selectedClient,
            fromSearch: true,
            isSmartSwitch: product.goalSubtypes!.first.isSmartSwitch);
        break;
      case ProductType.MF_FUND:
        final SchemeMetaModel? fund =
            storeSearchController.storeFundResult?.schemeMetas?.first;
        BasketController basketController = Get.isRegistered<BasketController>()
            ? Get.find<BasketController>()
            : Get.put<BasketController>(BasketController());
        if (widget.selectedClient != null) {
          basketController.selectedClient = widget.selectedClient;
          basketController.fromClientScreen = true;
        }

        if (fund?.isNfoFund == true) {
          screenToNavigate = NfoDetailRoute(wschemecode: fund?.wschemecode);
        } else {
          screenToNavigate = FundDetailRoute(
            isTopUpPortfolio: false,
            fund: fund,
            fromSearch: true,
            basketBottomBar: BasketBottomBar(
              controller: basketController,
              fund: fund,
            ),
          );
        }

        break;
      case ProductType.UNLISTED_STOCK:
        final product = UnlistedProductModel.fromJson(
            storeSearchController.storeProductResult);
        screenToNavigate = PreIpoDetailRoute(
          client: widget.selectedClient,
          product: product,
          fromSearch: true,
        );
        break;
      case ProductType.DEBENTURE:
        final product =
            DebentureModel.fromJson(storeSearchController.storeProductResult);
        screenToNavigate = DebentureDetailRoute(
          product: product,
          client: widget.selectedClient,
          fromSearch: true,
        );
        break;
      case ProductType.FIXED_DEPOSIT:
        // final product = FixedDepositModel.fromJson(
        //     storeSearchController.storeProductResult);
        screenToNavigate = FixedDepositListRoute(
          // product: product,
          client: widget.selectedClient,
          // fromSearch: true,
        );
        break;
      case ProductType.PMS:
        final product =
            PMSModel.fromJson(storeSearchController.storeProductResult);
        screenToNavigate = PmsProductListRoute(pmsProduct: product);
        break;
    }

    AutoRouter.of(context).replace(screenToNavigate);
  }
}
