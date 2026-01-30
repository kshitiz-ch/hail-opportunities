import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/reassign_client_controller.dart';
import 'package:app/src/screens/clients/client_list/widgets/choose_employee_bottomsheet.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/new_search_bar.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReassignClientsBottomsheet extends StatelessWidget {
  final PartnerOfficeModel? partnerOfficeModel;

  const ReassignClientsBottomsheet(
      {super.key, required this.partnerOfficeModel});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: SizeConfig().screenHeight * 0.8),
      child: GetBuilder<ReassignClientController>(
        init: ReassignClientController(partnerOfficeModel: partnerOfficeModel),
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
                      'Choose Clients to Reassign',
                      style: context.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                      ),
                    ),
                    CommonUI.bottomsheetCloseIcon(context),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: NewSearchBar(
                    searchController: controller.clientSearchController,
                    hintText: 'Search for Clients',
                    onClear: () {
                      controller.clearClientSearchBar();
                    },
                    onChanged: (value) {
                      controller.searchClientList(value);
                    },
                  ),
                ),
                if (controller.clientList.isNotNullOrEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildSelectAll(context, controller),
                  ),
                Expanded(child: _buildClientlist(context, controller)),
                if (controller.getClientsResponse.state ==
                        NetworkState.loading &&
                    controller.isPaginating)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                _buildContinueCTA(context, controller),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectAll(
      BuildContext context, ReassignClientController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Select All Client(s)',
          style: context.headlineSmall?.copyWith(
            color: ColorConstants.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        buildCheckbox(
          value: controller.selectAllClient,
          onChanged: (value) {
            if (value == true) {
              final entries = controller.clientList.map(
                (client) {
                  final clientName =
                      client.name.isNotNullOrEmpty ? client.name : 'N/A';
                  return MapEntry(client.customerId!, clientName.toTitleCase());
                },
              ).toList();
              controller.reassignClientMap = {};
              controller.reassignClientMap.addEntries(entries);
            } else {
              controller.reassignClientMap = {};
            }
            controller.update(['query-client']);
          },
        ),
      ],
    );
  }

  Widget _buildClientlist(
      BuildContext context, ReassignClientController controller) {
    if (controller.getClientsResponse.state == NetworkState.loading &&
        !controller.isPaginating) {
      return Center(child: CircularProgressIndicator());
    }
    if (controller.getClientsResponse.state == NetworkState.error &&
        !controller.isPaginating) {
      return Center(
        child: RetryWidget(
          'Error getting client list',
          onPressed: () {
            controller.queryClientList();
          },
        ),
      );
    }
    if (controller.clientList.isNullOrEmpty) {
      return EmptyScreen(
        imagePath: AllImages().clientSearchEmptyIcon,
        imageSize: 92,
        message: 'No Clients Found!',
      );
    }
    return ListView.separated(
      controller: controller.scrollController,
      itemCount: controller.clientList.length,
      itemBuilder: (context, index) {
        return _buildClientTile(
          controller: controller,
          context: context,
          index: index,
        );
      },
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
    final checkboxValue =
        controller.reassignClientMap.containsKey(client.customerId);

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
                  padding: const EdgeInsets.only(top: 2, bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CRN ${client.crn ?? '-'}',
                        style: context.titleLarge
                            ?.copyWith(color: ColorConstants.tertiaryBlack),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: CommonUI.buildProfileDataSeperator(
                          color: Color(0xffDDDDDD),
                          height: 10,
                          width: 1,
                        ),
                      ),
                      Text(
                        'Current Value ${WealthyAmount.currencyFormat(client.totalCurrentValue, 2)}',
                        style: context.titleLarge
                            ?.copyWith(color: ColorConstants.tertiaryBlack),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        buildCheckbox(
          value: checkboxValue,
          onChanged: (value) {
            if (value == true) {
              controller.reassignClientMap[client.customerId!] =
                  clientName.toTitleCase();
            } else if (value == false) {
              controller.reassignClientMap.remove(client.customerId!);
            }
            controller.update(['query-client']);
          },
        )
      ],
    );
  }

  Widget _buildContinueCTA(
      BuildContext context, ReassignClientController controller) {
    return ActionButton(
      margin: EdgeInsets.only(top: 16),
      text: 'Continue',
      isDisabled: controller.reassignClientMap.isEmpty,
      onPressed: () {
        controller.getEmployees();
        CommonUI.showBottomSheet(
          context,
          child: ChooseEmployeeBottomsheet(),
        );
      },
    );
  }

  Widget buildCheckbox({
    required bool? value,
    required Function(bool?)? onChanged,
  }) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CommonUI.buildCheckbox(
        value: value,
        unselectedBorderColor: ColorConstants.darkGrey,
        onChanged: onChanged,
      ),
    );
  }
}
