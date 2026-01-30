import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_additional_detail_controller.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/home/report_controller.dart';
import 'package:app/src/controllers/proposal/proposal_controller.dart';
import 'package:app/src/controllers/transaction/transaction_controller.dart';
import 'package:app/src/screens/clients/client_detail/widgets/client_status_detail.dart';
import 'package:app/src/screens/clients/client_detail/widgets/header_section.dart';
import 'package:app/src/screens/clients/client_detail/widgets/investments_section.dart';
import 'package:app/src/screens/clients/client_detail/widgets/profiles_family_section/profiles_family_section.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const String clientProposalControllerTag = 'client-detail-proposal';

@RoutePage()
class ClientDetailScreen extends StatelessWidget {
  // Fields
  Client? client;
  String? clientId;

  ClientDetailScreen({
    Key? key,
    this.client,
    @pathParam this.clientId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize ClientDetailController
    if (client == null) {
      client = Client.fromJson({"id": clientId});
    }
    Get.put(ClientDetailController(client));
    

    return GetBuilder<ClientDetailController>(
      id: 'client-details',
      dispose: (_) {
        Get.delete<ClientDetailController>();
        Get.delete<TransactionController>();
        Get.delete<ReportController>();
        Get.delete<ProposalsController>(tag: clientProposalControllerTag);
      },
      builder: (controller) {
        if (controller.clientDetailResponse.state == NetworkState.loading ||
            controller.clientDetailResponse.state == NetworkState.error) {
          return Scaffold(
            appBar: CustomAppBar(showBackButton: true),
            backgroundColor: ColorConstants.white,
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 32),
              height: MediaQuery.of(context).size.height,
              child:
                  controller.clientDetailResponse.state == NetworkState.loading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Center(
                          child: Text(
                            'We cannot find the client. Please make sure the client is assigned to your account',
                            textAlign: TextAlign.center,
                          ),
                        ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Visibility(
              visible: false,
              child: ActionButton(
                text: '',
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            showBackButton: true,
            customTitleWidget: controller.client != null
                ? _buildClientNameCrn(context, controller.client)
                : SizedBox(),
          ),

          // Body
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80.0),
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                HeaderSection(),
                ClientStatusDetail(),
                ProfilesFamilySection(),
                InvestmentsSection(),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: ActionButton(
            margin: EdgeInsets.symmetric(
              horizontal: 30,
            ).copyWith(bottom: 24),
            heroTag: kDefaultHeroTag,
            suffixWidget: Image.asset(
              AllImages().triangleRightArrowIcon,
              width: 24,
            ),
            text: 'Create Proposal',
            onPressed: () {
              final controller =
                  Get.isRegistered<ClientAdditionalDetailController>()
                      ? Get.find<ClientAdditionalDetailController>()
                      : null;
              if (controller != null) {
                _openCreateProposalBottomSheet(context, controller);
                
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildClientNameCrn(BuildContext context, Client? client) {
    TextStyle textStyle = Theme.of(context)
        .primaryTextTheme
        .titleLarge!
        .copyWith(color: ColorConstants.black);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MarqueeWidget(
          child: Text(
            client?.name?.toTitleCase() ?? '',
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.black,
                ),
          ),
        ),
        SizedBox(height: 6),
        Row(
          children: [
            CommonClientUI.buildRowTextInfo(
              title: 'CRN',
              subtitle: client?.crn ?? '-',
              titleStyle:
                  textStyle.copyWith(color: ColorConstants.tertiaryBlack),
              subtitleStyle: textStyle,
              onTap: () async {
                MixPanelAnalytics.trackWithAgentId(
                  "crn_copy",
                  screen: 'user_profile',
                  screenLocation: 'user_profile',
                );
                await copyData(data: client!.crn);
                showToast(text: 'CRN copied');
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CommonUI.buildProfileDataSeperator(
                height: 16,
                width: 1,
                color: ColorConstants.tertiaryBlack,
              ),
            ),
            CommonClientUI.buildRowTextInfo(
              title: 'Account Type',
              subtitle: AccountType.getTaxStatusAccountType(
                panUsageSubtype: client?.panUsageSubtype ?? '',
                panUsagetype: client?.panUsageType ?? '',
                accountType: true,
                taxStatus: false,
              ),
              titleStyle:
                  textStyle.copyWith(color: ColorConstants.tertiaryBlack),
              subtitleStyle: textStyle,
            ),
          ],
        )
      ],
    );
  }

  _openCreateProposalBottomSheet(
      BuildContext context, ClientAdditionalDetailController controller) {
    CommonUI.showBottomSheet(
      context,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 32.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose Type of product',
                  style:
                      Theme.of(context).primaryTextTheme.displayLarge!.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: ColorConstants.black,
                          ),
                ),
                IconButton(
                  onPressed: () {
                    AutoRouter.of(context).popForced();
                  },
                  icon: Icon(
                    Icons.close,
                    color: ColorConstants.black,
                  ),
                )
              ],
            ),
            SizedBox(height: 40),
            _buildNewProposalType(
              context,
              text: 'New Product',
              onClick: () {
                
                AutoRouter.of(context).push(StoreRoute(
                  client: controller.client,
                  showBackButton: true,
                ));
              },
            ),
            GetBuilder<ClientAdditionalDetailController>(
              id: 'investments',
              builder: (controller) {
                if (controller.investmentResponse.state ==
                    NetworkState.loading) {
                  return Container(
                    width: 15,
                    height: 15,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                if (controller.investmentResponse.state ==
                    NetworkState.loaded) {
                  return Column(
                    children: [
                      Divider(
                        height: 5,
                        color: Color(0xFFf3ebff),
                      ),
                      _buildNewProposalType(context, text: 'Top up portfolio',
                          onClick: () {
                        

                        AutoRouter.of(context).push(
                          MfInvestmentListRoute(
                            asOn: controller.clientInvestmentsResult?.asOn,
                            portfolioOverview:
                                controller.clientInvestmentsResult?.mf,
                          ),
                        );
                      }),
                    ],
                  );
                }

                return SizedBox();
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNewProposalType(context,
      {required String text, Function? onClick}) {
    return InkWell(
      onTap: () {
        onClick!();
      },
      child: Container(
        padding: EdgeInsets.only(top: 18, bottom: 18, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: ColorConstants.black,
                  ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }
}
