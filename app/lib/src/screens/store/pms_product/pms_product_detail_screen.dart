import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/store/pms/pms_product_controller.dart';
import 'package:app/src/screens/store/pms_product/pms_portfolio_section.dart';
import 'package:app/src/screens/store/pms_product/pms_product_overview.dart';
import 'package:app/src/screens/store/pms_product/pms_strategy_return_chart.dart';
import 'package:app/src/screens/store/pms_product/pms_tabs.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/store/models/pms_product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class PmsProductDetailScreen extends StatelessWidget {
  final PMSVariantModel? product;
  final bool isNew;
  final bool fromSearch;

  PmsProductDetailScreen({
    Key? key,
    this.product,
    this.isNew = false,
    this.fromSearch = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      // App Bar
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: product!.title,
        subtitleText: '${product?.productType} | ${product?.categoryText}',
      ),
      body: GetBuilder<PMSProductController>(
        id: 'navigation',
        builder: (controller) {
          return CustomScrollView(
            physics: ClampingScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30)
                      .copyWith(bottom: 24),
                  child: PmsProductOverview(product: product),
                ),
              ),
              SliverAppBar(
                primary: false,
                automaticallyImplyLeading: false,
                backgroundColor: ColorConstants.white,
                pinned: true,
                title: PmsTabs(),
                toolbarHeight: 45,
                elevation: 0,
                titleSpacing: 0,
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    PmsStrategyReturnChart(
                      product: product!,
                      key: controller
                          .navigationKeys[PMSNavigationTab.Strategy.name],
                    ),
                    PmsPortfolioSection(
                      product: product!,
                      key: controller
                          .navigationKeys[PMSNavigationTab.Portfolio.name],
                    ),
                    SizedBox(height: 50),
                    _buildFooterSection(context),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30)
                          .copyWith(top: 30, bottom: 50),
                      child: _buildOptionsInfoSection(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOptionsInfoSection(BuildContext context) {
    final titleStyle = context.titleLarge?.copyWith(
      color: ColorConstants.tertiaryBlack,
      fontWeight: FontWeight.w500,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Date section
        CommonUI.buildColumnTextInfo(
          title: 'Date as on',
          subtitle: getFormattedDate(product?.dataAsOnDate),
          titleStyle: titleStyle,
          subtitleStyle: titleStyle?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        // SIP Option section
        CommonUI.buildColumnTextInfo(
          title: 'SIP Option',
          subtitle: product?.sipOption == true ? 'Yes' : 'No',
          titleStyle: titleStyle,
          subtitleStyle: titleStyle?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),

        // STP Option section
        CommonUI.buildColumnTextInfo(
          title: 'STP Option',
          subtitle: product?.stpOption == true ? 'Yes' : 'No',
          titleStyle: titleStyle,
          subtitleStyle: titleStyle?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    final style = context.headlineSmall?.copyWith(
      color: Colors.black,
      fontWeight: FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildClickableTextRow(
            context: context,
            prefix: 'For more info ',
            clickableText: 'Click here',
            style: style,
            onTap: () {
              launch(product?.reportUrl ?? product?.productUrl ?? '-');
            },
          ),
          const SizedBox(height: 12),
          _buildClickableTextRow(
            context: context,
            prefix: 'Click here for ',
            clickableText: 'Terms & Conditions',
            style: style,
            onTap: () => AutoRouter.of(context).push(PmsTncRoute()),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableTextRow({
    required BuildContext context,
    required String prefix,
    required String clickableText,
    required TextStyle? style,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prefix,
            style: style?.copyWith(color: ColorConstants.tertiaryBlack)),
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: ColorConstants.black,
                  width: 1.0,
                ),
              ),
            ),
            child: Text(
              clickableText,
              style: style?.copyWith(
                color: ColorConstants.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
