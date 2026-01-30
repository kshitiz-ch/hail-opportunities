import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/pre_ipo/pre_ipo_controller.dart';
import 'package:app/src/screens/store/pre_ipo_detail/widgets/download_report_card.dart';
import 'package:app/src/screens/store/pre_ipo_detail/widgets/overview_section.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:core/modules/store/models/unlisted_stocks_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

@RoutePage()
class PreIpoDetailScreen extends StatelessWidget {
  // Fields
  final UnlistedProductModel? product;
  final Client? client;

  final bool fromSearch;

  // Constructor
  const PreIpoDetailScreen({
    Key? key,
    required this.product,
    this.client,
    this.fromSearch = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      PreIPOController(product: product, selectedClient: client),
    );

    return Scaffold(
      backgroundColor: ColorConstants.white,
      // AppBar
      appBar: CustomAppBar(
        showBackButton: true,
        customTitleWidget: _buildCustomTitle(context, controller),
      ),

      // Body
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: OverviewSection(product: controller.product),
            ),

            Divider(
              color: ColorConstants.lightGrey,
            ),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0)
                  .copyWith(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About ${controller.product!.title}',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .displaySmall!
                        .copyWith(
                            fontSize: 16, color: ColorConstants.tertiaryBlack),
                  ),
                  SizedBox(height: 12),
                  Text(
                    controller.product!.description!,
                    textAlign: TextAlign.justify,
                    style:
                        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                              color: ColorConstants.tertiaryBlack,
                            ),
                  ),
                ],
              ),
            ),

            // Download Report Card
            if (controller.product!.reportUrl != null)
              Padding(
                padding:
                    const EdgeInsets.only(top: 24.0, left: 20.0, right: 20.0),
                child: DownloadReportCard(product: controller.product),
              ),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: GetBuilder<PreIPOController>(
        initState: (_) {},
        dispose: (_) {
          Get.delete<PreIPOController>();
        },
        builder: (controller) {
          return ActionButton(
            heroTag: kDefaultHeroTag,
            text: client != null ? 'Continue' : 'Select Client',
            onPressed: () {
              if (client != null) {
                AutoRouter.of(context).push(DematsRoute(
                  productName: controller.product!.title,
                  productOverview: OverviewSection(product: controller.product),
                  client: client,
                  onProceed: () {
                    AutoRouter.of(context).push(PreIpoFormRoute(
                      client: client,
                      product: controller.product,
                    ));
                  },
                ));
              } else {
                AutoRouter.of(context).push(SelectClientRoute(
                  onClientSelected: (Client? client, bool? isClientNew) async {
                    if (client == null) {
                      return showToast(text: 'This client cannot be selected');
                    }

                    controller.setSelectedClient(client);

                    if (isClientNew ?? false) {
                      AutoRouter.of(context).popForced();
                    }

                    if (client.isSourceContacts) {
                      AutoRouter.of(context).push(PreIpoFormRoute(
                        client: client,
                        product: controller.product,
                      ));
                    } else {
                      AutoRouter.of(context).push(DematsRoute(
                        productName: controller.product!.title,
                        productOverview:
                            OverviewSection(product: controller.product),
                        client: client,
                        onProceed: () {
                          AutoRouter.of(context).push(PreIpoFormRoute(
                            client: client,
                            product: controller.product,
                          ));
                        },
                      ));
                    }
                  },
                ));
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildCustomTitle(BuildContext context, PreIPOController controller) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              border: Border.all(color: ColorConstants.lightGrey),
              borderRadius: BorderRadius.circular(50)),
          height: 36,
          width: 36,
          child: Center(
            child: product!.iconSvg != null && product!.iconSvg!.endsWith("svg")
                ? SvgPicture.network(
                    product!.iconSvg!,
                  )
                : Image.network(product!.iconSvg!),
          ),
        ),
        SizedBox(
          width: 12,
        ),
        Expanded(
          child: Text(
            controller.product!.title!,
            maxLines: 2,
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.black,
                  overflow: TextOverflow.ellipsis,
                ),
          ),
        ),
      ],
    );
  }
}
