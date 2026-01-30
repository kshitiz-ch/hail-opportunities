import 'package:app/src/controllers/client/client_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/common/ai_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/screens/clients/client_list/widgets/client_card_new.dart';
import 'package:app/src/screens/commons/ai/widgets/ai_initial_content.dart';
import 'package:core/modules/ai/models/ai_profile_model.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class ClientAIWidget extends StatelessWidget {
  final AIController controller;
  final WealthyAIScreenParameters parameters;

  const ClientAIWidget({
    Key? key,
    required this.controller,
    required this.parameters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.aiResponse.state == NetworkState.loading) {
      return _buildLoadingIndicator(context);
    } else if (controller.aiResponse.state == NetworkState.loaded) {
      return _buildClientList(context, controller); 
    } else {
      return AIInitialContent(
        controller: controller,
        quickActions: parameters.quickActions,
      );
    }
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Processing Your Request',
                style: context.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  color: ColorConstants.tertiaryBlack,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Finding relevant clients...',
                style: TextStyle(
                  fontSize: 16,
                  color: ColorConstants.tertiaryBlack,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 40),
        Center(
          child: Lottie.asset(
            AllImages().wealthyAiLoadingAnimation,
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildClientList(BuildContext context, AIController controller) {
    return GetBuilder<ClientListController>(
      tag: 'ai_client_list_controller',
      builder: (clientListController) {
        if (clientListController.clientResponse.state == NetworkState.loading &&
            !clientListController.isPaginating) {
          return _buildLoadingIndicator(context);
        }

        if (clientListController.clientResponse.state == NetworkState.error) {
          return Center(
            child: RetryWidget(
              clientListController.clientResponse.message,
              onPressed: () {
                clientListController.queryClientList();
              },
            ),
          );
        }

        int totalCount =
            clientListController.clientListMetaData.totalCount ?? 0;

        String resultDescription = '';
        if (controller.resultSummary != null &&
            controller.resultSummary!.isNotEmpty) {
          resultDescription = 'with ${controller.resultSummary!}';
        }

        Widget resultHeader = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  clientListController.clientList.isEmpty
                      ? 'No Results Found'
                      : 'Results Found!',
                  style: context.headlineLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: ColorConstants.black,
                  ),
                ),
                if (!clientListController.clientList.isEmpty) ...[
                  SizedBox(width: 8),
                  Text(
                    '$totalCount Clients Found',
                    style: context.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: ColorConstants.tertiaryBlack,
                    ),
                  ),
                ],
              ],
            ),
            if (resultDescription.isNotEmpty)
              Text(
                resultDescription.toLowerCase(),
                style: context.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: ColorConstants.tertiaryBlack,
                ),
              ),
            SizedBox(height: 16),
          ],
        );

        if (clientListController.clientList.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              resultHeader,
              SizedBox(height: 20),
              Center(
                child: EmptyScreen(
                  imagePath: AllImages().clientSearchEmptyIcon,
                  imageSize: 92,
                  message: 'No Clients Found!',
                ),
              ),
            ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              resultHeader,
            Flexible(
              child: ListView.separated(
                  controller: clientListController.scrollController,
                shrinkWrap: true,
                  itemCount: clientListController.clientList.length,
              itemBuilder: (context, index) {
                    final client = clientListController.clientList[index];
                return ClientCard(
                  client: client,
                  effectiveIndex: index % 7,
                );
              },
                separatorBuilder: (_, __) => SizedBox(height: 10),
              ),
            ),
              if (clientListController.isPaginating)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        );
      },
    );
  }
}
