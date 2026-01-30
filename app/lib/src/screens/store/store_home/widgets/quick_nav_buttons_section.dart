import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/store/store_controller.dart';
import 'package:app/src/screens/store/store_home/widgets/quick_nav_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuickNavButtonsSection extends StatelessWidget {
  const QuickNavButtonsSection({Key? key, this.storeController})
      : super(key: key);

  final StoreController? storeController;

  @override
  Widget build(BuildContext context) {
    if (storeController!.popularProductsState != NetworkState.loaded) {
      return SizedBox();
    }

    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20.0,
        12.0,
        10.0,
        0.0,
      ),
      child: GridView.count(
        crossAxisCount: 3,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        primary: false,
        crossAxisSpacing: 0,
        mainAxisSpacing: 1,
        childAspectRatio: 1.5,
        padding: EdgeInsets.zero,
        children: [
          QuickNavButton(
            'Mutual Funds',
            icon: AllImages().storeMfIcon,
            onPressed: () {
              AutoRouter.of(context)
                  .push(MfLobbyRoute(client: storeController?.selectedClient));

              MixPanelAnalytics.trackWithAgentId(
                "mutual_funds",
                screen: 'store',
                screenLocation: 'store',
              );
            },
          ),
          // QuickNavButton(
          //   'Wealthy Portfolio',
          //   icon: AllImages().storeWealthyPortfolioIcon,
          //   onPressed: () {
          //     AutoRouter.of(context).push(MFPortfolioListRoute(
          //       client: storeController?.selectedClient,
          //     ));
          //   },
          // ),
          QuickNavButton(
            'Pre IPOs',
            icon: AllImages().storePreIpoIcon,
            onPressed: () {
              AutoRouter.of(context).push(PreIpoListRoute(
                client: storeController?.selectedClient,
              ));

              MixPanelAnalytics.trackWithAgentId(
                "pre_ipo",
                screen: 'store',
                screenLocation: 'store',
              );
            },
          ),
          QuickNavButton(
            'SIFs',
            showNewBadge: true,
            icon: AllImages().storeSifIcon,
            onPressed: () {
              MixPanelAnalytics.trackWithAgentId(
                "SIFs",
                screen: 'store',
                screenLocation: 'store',
              );
              AutoRouter.of(context).push(SifListRoute());
            },
          ),
          QuickNavButton(
            'Wealthcase',
            icon: AllImages().storeWealthcaseIcon,
            showNewBadge: true,
            onPressed: () {
              AutoRouter.of(context).push(WealthcaseListRoute());

              MixPanelAnalytics.trackWithAgentId(
                "wealthcase",
                screen: 'store',
                screenLocation: 'store',
              );
            },
          ),
          QuickNavButton(
            'Debentures',
            icon: AllImages().storeDebentureIcon,
            onPressed: () {
              AutoRouter.of(context).push(DebentureListRoute(
                client: storeController?.selectedClient,
              ));

              MixPanelAnalytics.trackWithAgentId(
                "debentures",
                screen: 'store',
                screenLocation: 'store',
              );
            },
          ),
          QuickNavButton(
            'PMS',
            icon: AllImages().storePmsIcon,
            onPressed: () {
              AutoRouter.of(context).push(
                PmsProviderListRoute(),
              );

              MixPanelAnalytics.trackWithAgentId(
                "pms",
                screen: 'store',
                screenLocation: 'store',
              );
            },
          ),
          QuickNavButton(
            'Insurance',
            icon: AllImages().storeInsuranceIcon,
            onPressed: () {
              AutoRouter.of(context).push(InsuranceHomeRoute());

              MixPanelAnalytics.trackWithAgentId(
                "insurance",
                screen: 'store',
                screenLocation: 'store',
              );
            },
          ),
          QuickNavButton(
            'Fixed Deposits',
            icon: AllImages().storeFdIcon,
            onPressed: () {
              AutoRouter.of(context).push(FixedDepositListRoute(
                client: storeController?.selectedClient,
              ));

              MixPanelAnalytics.trackWithAgentId(
                "fd",
                screen: 'store',
                screenLocation: 'store',
              );
            },
          ),
          // QuickNavButton(
          //   'Credit Cards',
          //   icon: AllImages().storeCreditCard,
          //   onPressed: () {
          //     AutoRouter.of(context).push(
          //       CreditCardHomeRoute(),
          //     );
          //   },
          // ),

          // // remove demat product for employee
          // if (!isEmployeeLoggedIn())
          QuickNavButton(
            'Demat',
            icon: AllImages().storeDematIcon,
            onPressed: () {
              openDematStoreScreen(
                context: context,
                selectedClient: storeController?.selectedClient,
              );

              MixPanelAnalytics.trackWithAgentId(
                "demat",
                screen: 'store',
                screenLocation: 'store',
              );
            },
          ),
          if (Get.isRegistered<HomeController>() &&
              Get.find<HomeController>().isSgbAvailable)
            QuickNavButton(
              'SGB',
              icon: AllImages().storeDebentureIcon,
              onPressed: () {
                AutoRouter.of(context).push(
                  SgbRoute(),
                );
              },
            ),
        ],
      ),
    );
  }
}
