import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:app/src/controllers/proposal/proposal_controller.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolios_controller.dart';
import 'package:app/src/screens/clients/client_detail/view/client_detail_screen.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/card/credit_proposal_card.dart';
import 'package:app/src/widgets/card/proposal_card_new.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProposalList extends StatelessWidget {
  final bool isCurrentTab;
  const ProposalList({Key? key, this.isCurrentTab = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tag = isPageAtTopStack(context, ClientDetailRoute.name)
        ? clientProposalControllerTag
        : null;
    return GetBuilder<ProposalsController>(
      tag: tag,
      builder: (controller) {
        if (controller.isInitialLoading) {
          return _buildShimmerEffect();
        }

        if (!isCurrentTab ||
            (controller.proposalState == NetworkState.loading &&
                !controller.isPaginating)) {
          return _buildScreenLoader();
        }

        if (controller.proposalState == NetworkState.error) {
          return _buildErrorState(context, controller);
        }

        if ((controller.proposalState == NetworkState.loaded &&
                controller.proposals.length > 0) ||
            controller.isPaginating) {
          return _buildProposalList(context, controller);
        }

        return _buildEmptyState(context, controller);
      },
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.only(top: 10),
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 200,
          margin: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ColorConstants.lightBackgroundColor,
          ),
        ).toShimmer(
          baseColor: ColorConstants.lightBackgroundColor,
          highlightColor: ColorConstants.white,
        );
      },
    );
  }

  Widget _buildScreenLoader() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(context, ProposalsController controller) {
    return Center(
      child: SizedBox(
        height: 96,
        child: RetryWidget(
          'Something went wrong. Please try again',
          onPressed: () => controller.getProposals(),
        ),
      ),
    );
  }

  Widget _buildProposalList(
      BuildContext context, ProposalsController controller) {
    if (!Get.isRegistered<MFPortfoliosController>()) {
      Get.put<MFPortfoliosController>(MFPortfoliosController());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            physics: ClampingScrollPhysics(),
            controller: controller.scrollController,
            padding: EdgeInsets.all(20),
            itemCount: controller.proposals.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: controller.proposals[index].productCategory ==
                        controller.productCategoryList.last
                    ? CreditProposalCard(
                        proposal: controller.proposals[index],
                      )
                    : ProposalCardNew(
                        proposal: controller.proposals[index],
                        index: index,
                        isEmployeeFlow: controller.partnerType ==
                                PartnerType.Office ||
                            controller.employeeAgentExternalId.isNotNullOrEmpty,
                      ),
              );
            },
          ),
        ),
        if (controller.isPaginating) _buildInfiniteLoader()
      ],
    );
  }

  Widget _buildInfiniteLoader() {
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

  Widget _buildEmptyState(
      BuildContext context, ProposalsController controller) {
    return EmptyScreen(
      imagePath: AllImages().emptyProposalIcon,
      message: 'No Proposals Found',
      actionButtonText: (controller.partnerType == PartnerType.Office ||
              controller.employeeAgentExternalId.isNotNullOrEmpty)
          ? null
          : 'Explore Products',
      onClick: () {
        AutoRouter.of(context).popUntil(ModalRoute.withName(BaseRoute.name));
        Get.find<NavigationController>()
            .setCurrentScreen(Screens.STORE, fromScreen: 'ProposalAdd');
      },
    );
  }
}
