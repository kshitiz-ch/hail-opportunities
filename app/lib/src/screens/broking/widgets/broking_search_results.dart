import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/broking/broking_activity_controller.dart';
import 'package:app/src/controllers/broking/broking_controller.dart';
import 'package:app/src/controllers/broking/broking_search_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/list_tile/client_list_tile.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BrokingSearchResults extends StatelessWidget {
  final String type;

  const BrokingSearchResults({Key? key, required this.type}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GetBuilder<BrokingSearchController>(
        builder: (controller) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Client to get $type detail',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: ColorConstants.tertiaryGrey,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
              ),
              Expanded(
                child: _buildSearchResult(controller),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchResult(BrokingSearchController controller) {
    if (controller.clientSearch.state == NetworkState.loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.clientSearch.state == NetworkState.error) {
      return SizedBox(
        height: 200,
        child: RetryWidget(
          controller.clientSearch.message,
          onPressed: () => controller.search(),
        ),
      );
    }

    if (controller.clientSearch.state == NetworkState.loaded) {
      if (controller.clientsResult.clients.isNullOrEmpty) {
        return EmptyScreen(
          imagePath: AllImages().clientSearchEmptyIcon,
          imageSize: 92,
          message: 'No Clients Found!',
        );
      }
      return ListView.separated(
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: controller.clientsResult.clients!.length,
        itemBuilder: (context, index) {
          return ClientListTile(
            onTap: () {
              controller.updateSelectedClient(
                  controller.clientsResult.clients![index]);
              if (type == 'brokerage') {
                Get.find<BrokingActivityController>().getBrokingActivityData(
                  selectedClientId: controller.selectedClientId,
                );
              } else {
                Get.find<BrokingController>().getBrokingOnboardingData(
                  selectedClientId: controller.selectedClientId,
                );
              }
            },
            effectiveIndex: index % 7,
            client: controller.clientsResult.clients![index],
          );
        },
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Divider(
            thickness: 0.3,
            color: ColorConstants.darkGrey,
          ),
        ),
      );
    }
    return SizedBox();
  }
}
