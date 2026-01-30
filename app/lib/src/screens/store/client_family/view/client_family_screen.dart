import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/common/select_client_controller.dart';
import 'package:app/src/screens/store/select_client/widgets/select_clients_list.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/card/select_client_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class ClientFamilyScreen extends StatelessWidget {
  final Function(Client?, bool)? onClientSelected;
  final Client? lastSelectedClient;
  final bool shouldPopAfterSelect;

  const ClientFamilyScreen({
    Key? key,
    required this.onClientSelected,
    this.lastSelectedClient,
    this.shouldPopAfterSelect = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SelectClientController>(
      id: GetxId.searchClient,
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          // AppBar
          appBar: CustomAppBar(
            showBackButton: true,
            titleText: 'Select Family Member',
          ),

          // Body
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                ).copyWith(bottom: 12),
                child: Text(
                  'Client',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        color: ColorConstants.tertiaryBlack,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SelectClientCard(
                    client: controller.activeClient, effectiveIndex: 0),
              ),
              SizedBox(height: 32),
              _buildFamilyList(context, controller),
              SizedBox(height: 100),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,

          floatingActionButton: _buildActionButton(context, controller),
        );
      },
    );
  }

  Widget _buildFamilyList(
      BuildContext context, SelectClientController controller) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0)
                .copyWith(bottom: 12),
            child: Text(
              'Family Members',
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        color: ColorConstants.tertiaryBlack,
                        fontWeight: FontWeight.w600,
                      ),
            ),
          ),
          Expanded(
            child: SelectClientsList(
              clients: controller.familyMembers,
              isFamily: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    SelectClientController controller,
  ) {
    if (controller.selectedClient == null) {
      return SizedBox.shrink();
    }

    return ActionButton(
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      heroTag: kDefaultHeroTag,
      showProgressIndicator:
          controller.fetchFamilyState == NetworkState.loading,
      text: 'Continue',
      onPressed: () async {
        await onClientSelected!(controller.selectedClient, false);
      },
    );
  }
}
