import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/card/product_card_new.dart';
import 'package:app/src/widgets/misc/get_product_bottom_data.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/store/models/pms_product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

@RoutePage()
class PmsProductListScreen extends StatelessWidget {
  final PMSModel pmsProduct;
  PmsProductListScreen({
    Key? key,
    required this.pmsProduct,
  }) : super(key: key) {}

  void navigateToDetailScreen(context, productVariant) {
    AutoRouter.of(context).push(PmsProductDetailRoute(
      product: productVariant,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      // App Bar
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: pmsProduct.productManufacturer,
        trailingWidgets: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${pmsProduct.variants!.length} Product${pmsProduct.variants!.length > 1 ? 's' : ''}',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
          ),
        ],
      ),

      // Body
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: []..addAll(
              pmsProduct.variants!.map(
                (productVariant) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20)
                      .copyWith(bottom: 16.0),
                  child: ProductCardNew(
                    title: productVariant.title,
                    description: productVariant.description!,
                    descriptionMaxLines: 10,
                    showSeparator: false,
                    bgColor: ColorConstants.primaryCardColor,
                    borderRadius: 16,
                    leadingWidget: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 18,
                      child: productVariant.iconSvg != null &&
                              productVariant.iconSvg!.endsWith("svg")
                          ? SvgPicture.network(productVariant.iconSvg!)
                          : Image.network(productVariant.iconSvg!),
                    ),
                    titleStyle: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.black,
                        ),
                    descriptionStyle:
                        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.w400,
                              color: ColorConstants.tertiaryBlack,
                            ),
                    onTap: () {
                      navigateToDetailScreen(context, productVariant);
                    },
                    bottomData: getProductBottomData(
                      productVariant,
                      titleStyle: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.black,
                          ),
                      subtitleStyle: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            fontWeight: FontWeight.w400,
                            color: ColorConstants.tertiaryBlack,
                          ),
                    ),
                  ),
                ),
              ),
            ),
        ),
      ),
    );
  }
}
