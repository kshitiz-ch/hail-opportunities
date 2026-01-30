import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InsuranceProductSection extends StatelessWidget {
  final Client? selectedClient;

  const InsuranceProductSection({Key? key, this.selectedClient})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          decoration: BoxDecoration(
            color: ColorConstants.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTile(
                context: context,
                image: AllImages().insuranceHomeTermIcon,
                title: 'Term Insurance',
                subtitle: 'Stay covered for life',
                productVariant: InsuranceProductVariant.TERM,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: _buildTile(
                  context: context,
                  image: AllImages().insuranceHomeSavingIcon,
                  title: 'Savings',
                  subtitle: 'Enjoy guaranteed returns',
                  productVariant: InsuranceProductVariant.SAVINGS,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: _buildTile(
                  context: context,
                  image: AllImages().quoteGeneration,
                  title: 'Quote Generation Links',
                  subtitle: 'Wealthy Quote Generation Links for Life Insurance',
                  productVariant: InsuranceProductVariant.QUOTE,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: _buildTile(
                  context: context,
                  image: AllImages().insuranceCalculatorIcon,
                  title: 'Insurance Calculators',
                  subtitle: 'Insurance Business Opportunity Calculators',
                  onPressed: () {
                    AutoRouter.of(context).push(
                      InsuranceWebViewRoute(
                        url: "https://insurance.wealthyinsurance.in/calculator",
                        shouldHandleAppBar: false,
                        onNavigationRequest: (
                          InAppWebViewController controller,
                          NavigationAction action,
                        ) async {
                          final navigationUrl = action.request.url.toString();

                          if (navigationUrl
                              .contains("applinks.buildwealth.in")) {
                            AutoRouter.of(context).popForced();
                            return NavigationActionPolicy.CANCEL;
                          } else {
                            return NavigationActionPolicy.ALLOW;
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: _buildTile(
                  context: context,
                  image: AllImages().insuranceHomeHealthIcon,
                  title: 'Health Insurance',
                  subtitle: 'Your health, our promise!',
                  productVariant: InsuranceProductVariant.HEALTH,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTile({
    required String image,
    required String title,
    required String subtitle,
    String? productVariant,
    Function()? onPressed,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: () {
        if (onPressed != null) {
          onPressed();
        } else {
          MixPanelAnalytics.trackWithAgentId(
            "Insurance_banner",
            screen: 'Insurance',
            screenLocation: 'Insurance',
            properties: {"product": productVariant},
          );
          AutoRouter.of(context).push(
            InsuranceDetailRoute(productVariant: productVariant),
          );
        }
      },
      child: Row(
        children: [
          Image.asset(
            image,
            height: 36,
            width: 36,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: CommonUI.buildColumnTextInfo(
                title: title,
                subtitle: subtitle,
                subtitleMaxLength: 3,
                titleStyle:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          color: ColorConstants.black,
                          overflow: TextOverflow.ellipsis,
                        ),
                subtitleStyle:
                    Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                          color: ColorConstants.tertiaryBlack,
                          overflow: TextOverflow.ellipsis,
                        ),
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_right,
            size: 24,
            color: ColorConstants.tertiaryBlack,
          ),
        ],
      ),
    );
  }
}
