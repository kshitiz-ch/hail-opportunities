import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/demat/demats_controller.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/client_store_card.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_profile_model.dart';
import 'package:core/modules/store/models/demat_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class DematsScreen extends StatelessWidget {
  // Fields
  final Client? client;
  final VoidCallback? onProceed;
  final String? productName;
  final Widget? productOverview;

  // Constructor
  const DematsScreen({
    Key? key,
    this.productName,
    this.productOverview,
    required this.client,
    required this.onProceed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      // AppBar
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: productName,
      ),
      // Body
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: GetBuilder<DematsController>(
          init: DematsController(client: client),
          initState: (_) {},
          builder: (controller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Card
                if (productOverview != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30)
                        .copyWith(bottom: 20),
                    child: productOverview,
                  ),

                // Client Details Section
                ClientStoreCard(client: client),

                if (controller.dematsState == NetworkState.error)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 36.0,
                    ),
                    child: SizedBox(
                      height: 240,
                      child: RetryWidget(
                        controller.dematsErrorMessage,
                        onPressed: () {
                          controller.getDematAccounts(
                            client!,
                            isRetry: true,
                          );
                        },
                      ),
                    ),
                  )
                else if (controller.dematsState == NetworkState.loading)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: ColorConstants.lightBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    height: 100,
                  ).toShimmer(
                    baseColor: ColorConstants.lightBackgroundColor,
                    highlightColor: ColorConstants.white,
                  )
                else if (controller.demats.isEmpty)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 20)
                        .copyWith(bottom: 40),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: ColorConstants.lightRedColor,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demat Account',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: ColorConstants.tertiaryBlack,
                              ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          'No Demat Accounts added yet',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.w500,
                                color: ColorConstants.salmonTextColor,
                              ),
                        )
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryCardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20)
                              .copyWith(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Demat Accounts',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: ColorConstants.tertiaryBlack,
                                    ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ListView.separated(
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return SizedBox(height: 16);
                                },
                                itemCount: controller.demats.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext context, int index) {
                                  DematModel demat = controller.demats[index];
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'DP ID',
                                              style: Theme.of(context)
                                                  .primaryTextTheme
                                                  .headlineSmall!
                                                  .copyWith(
                                                      color: ColorConstants
                                                          .tertiaryBlack,
                                                      fontSize: 12),
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              demat.dpid!,
                                              style: Theme.of(context)
                                                  .primaryTextTheme
                                                  .headlineSmall,
                                            )
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Client ID',
                                              style: Theme.of(context)
                                                  .primaryTextTheme
                                                  .headlineSmall!
                                                  .copyWith(
                                                      color: ColorConstants
                                                          .tertiaryBlack,
                                                      fontSize: 12),
                                            ),
                                            SizedBox(height: 6),
                                            Text(
                                              demat.boid!,
                                              style: Theme.of(context)
                                                  .primaryTextTheme
                                                  .headlineSmall,
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: ColorConstants.lightGrey,
                        ),
                        InkWell(
                          onTap: () {
                            AutoRouter.of(context).push(
                              AddDematRoute(
                                client: client,
                                navigateTo: () async {
                                  AutoRouter.of(context).popForced();
                                  await controller.getDematAccounts(
                                    client!,
                                    isRetry: true,
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                              padding: EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add,
                                      color: ColorConstants.primaryAppColor),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Add another DEMAT Account',
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .headlineSmall!
                                        .copyWith(
                                            color:
                                                ColorConstants.primaryAppColor,
                                            fontWeight: FontWeight.w600),
                                  )
                                ],
                              )),
                        )
                      ],
                    ),
                  )
                // AnimatedSwitcher(
                //   duration: Duration(milliseconds: 500),
                //   child: controller.dematsState == NetworkState.loading
                //       ? ClientDetailsCard(client: client).toShimmer(
                //           baseColor: ColorConstants.lightBackgroundColor,
                //           highlightColor: ColorConstants.white,
                //         )
                //       : controller.dematsState == NetworkState.error
                //           ? Padding(
                //               padding: const EdgeInsets.symmetric(
                //                 horizontal: 8.0,
                //                 vertical: 36.0,
                //               ),
                //               child: SizedBox(
                //                 height: 240,
                //                 child: RetryWidget(
                //                   controller.dematsErrorMessage,
                //                   onPressed: () {
                //                     controller.getDematAccounts(
                //                       client,
                //                       isRetry: true,
                //                     );
                //                   },
                //                 ),
                //               ),
                //             )
                //           : ClientDetailsCard(
                //               client: client,
                //               demats: controller.demats,
                //             ),
                // ),
              ],
            );
          },
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      floatingActionButton: GetBuilder<DematsController>(
        builder: (controller) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ActionButton(
                heroTag: kDefaultHeroTag,
                isDisabled: controller.dematsState != NetworkState.loaded,
                showProgressIndicator: controller.bankDetailsResponse.state ==
                    NetworkState.loading,
                text: !controller.isDematAccountExists
                    ? 'Add DEMAT Account'
                    : 'Continue',
                margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
                onPressed: () async {
                  if (!controller.isDematAccountExists) {
                    AutoRouter.of(context).push(
                      AddDematRoute(
                        client: client,
                        navigateTo: () async {
                          AutoRouter.of(context).popForced();
                          await controller.getDematAccounts(
                            client!,
                            isRetry: true,
                          );
                        },
                      ),
                    );
                  } else if (controller.isBankAccountExists) {
                    onProceed!();
                  } else {
                    ClientAccountModel accountDetails = ClientAccountModel();
                    accountDetails.bankAccounts = controller.userBankAccounts;

                    _navigateToAddBankForm(context, controller);

                    // AutoRouter.of(context).push(BankDetailsFormRoute(
                    //   client: client,
                    //   accountDetails: accountDetails,
                    //   onProceed: () async {
                    //     onProceed!();
                    //     await controller.getClientankAccounts(client!);
                    //   },
                    // ));
                  }
                },
              ),
              if (controller.demats.isEmpty)
                Container(
                  margin: EdgeInsets.only(top: 8),
                  height: 40,
                  child: TextButton(
                    child: Text(
                      'Add Account Later',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .labelLarge!
                          .copyWith(
                            color: ColorConstants.primaryAppColor,
                          ),
                    ),
                    onPressed: () {
                      if (controller.isBankAccountExists) {
                        onProceed!();
                      } else {
                        ClientAccountModel accountDetails =
                            ClientAccountModel();
                        accountDetails.bankAccounts =
                            controller.userBankAccounts;
                        _navigateToAddBankForm(context, controller);
                      }
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToAddBankForm(
      BuildContext context, DematsController controller) {
    AutoRouter.of(context).push(
      ClientBankFormRoute(
        client: client,
        onBankAdded: (BankAccountModel? bank) async {
          if (bank != null) {
            controller.userBankAccounts.insert(0, bank);
          }

          AutoRouter.of(context).popForced();

          onProceed!();
          await controller.getClientankAccounts(client!);
        },
      ),
    );
  }
}
