import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/client/reassign_client_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/new_search_bar.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddFamilyClientSearchBottomsheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: SizeConfig().screenHeight * 0.7),
      child: GetBuilder<ReassignClientController>(
        init: ReassignClientController(),
        tag: 'add-family-client-search',
        id: 'query-client',
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Family Member ',
                      style: context.headlineMedium?.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 20),
                    CommonUI.bottomsheetCloseIcon(context)
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  'Select Client to add Family Member ',
                  style: context.titleLarge?.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Image.asset(
                          AllImages().trust,
                          width: 50,
                          height: 50,
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'We never contact your clients to solicit any business, wealthy promise',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                color: ColorConstants.tertiaryBlack,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                NewSearchBar(
                  searchController: controller.clientSearchController,
                  hintText: 'Search for Clients',
                  onClear: () {
                    controller.clearClientSearchBar();
                  },
                  onChanged: (value) {
                    controller.searchClientList(value);
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: _buildClientlist(context, controller),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClientlist(
      BuildContext context, ReassignClientController controller) {
    if (controller.getClientsResponse.state == NetworkState.loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (controller.getClientsResponse.state == NetworkState.error) {
      return Center(
        child: RetryWidget(
          genericErrorMessage,
          onPressed: () {
            controller.queryClientList();
          },
        ),
      );
    }
    if (controller.getClientsResponse.state == NetworkState.loaded &&
        controller.clientList.isNullOrEmpty) {
      return EmptyScreen(
        imagePath: AllImages().clientSearchEmptyIcon,
        imageSize: 92,
        message: 'No Clients Found!',
      );
    }
    return ListView.separated(
      itemCount: controller.clientList.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            final client = controller.clientList[index].getHydraClientModel();

            Get.put(ClientDetailController(client));
            AutoRouter.of(context).push(
              ClientFamilyDetailRoute(client: client),
            );
          },
          child: _buildClientTile(
            controller: controller,
            context: context,
            index: index,
          ),
        );
      },
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: CommonUI.buildProfileDataSeperator(
          width: double.infinity,
          height: 2,
          color: ColorConstants.borderColor,
        ),
      ),
    );
  }

  Widget _buildClientTile({
    required ReassignClientController controller,
    required BuildContext context,
    required int index,
  }) {
    final client = controller.clientList[index];
    final effectiveIndex = index % 7;

    final clientName = client.name.isNotNullOrEmpty ? client.name : 'N/A';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Client Logo
        CircleAvatar(
          backgroundColor: getRandomBgColor(effectiveIndex),
          child: Center(
            child: Text(
              client.name!.initials,
              style: context.displayMedium!.copyWith(
                color: getRandomTextColor(effectiveIndex),
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          radius: 21,
        ),
        // Client Details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: clientName.toTitleCase(),
                    style: context.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: ColorConstants.black,
                    ),
                  ),
                  maxLines: 2,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'CRN ${client.crn ?? '-'}',
                    style: context.titleLarge
                        ?.copyWith(color: ColorConstants.tertiaryBlack),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
