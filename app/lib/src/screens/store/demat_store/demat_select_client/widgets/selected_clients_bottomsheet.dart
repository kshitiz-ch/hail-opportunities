import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/common/demat_select_client_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/card/client_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectedClientsBottomSheet extends StatelessWidget {
  const SelectedClientsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DematSelectClientController>(
      builder: (controller) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeadingAndCloseIcon(context),

              // Selected Clients List
              if (controller.selectedClients.isNotEmpty)
                _buildClientsList(context, controller)
              else
                _buildEmptyText(context),

              SizedBox(height: 50),

              if (controller.selectedClients.isNotEmpty)
                _buildActionButtons(context, controller)
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeadingAndCloseIcon(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Text(
              'Selected Clients',
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
            ),
          ),
          InkWell(
            onTap: () {
              AutoRouter.of(context).popForced();
            },
            child: Icon(
              Icons.close,
              color: ColorConstants.tertiaryBlack,
              size: 18,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildClientsList(
      BuildContext context, DematSelectClientController controller) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height / 2,
      ),
      color: ColorConstants.white,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 32),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: controller.selectedClients.length,
        itemBuilder: (BuildContext context, int index) {
          final client = controller.selectedClients[index];
          return ClientCard(
            client: client,
            effectiveIndex: index % 7,
            suffixWidget: _buildRemoveButton(context, client, controller),
          );
        },
      ),
    );
  }

  Widget _buildEmptyText(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'No Clients Selected',
        textAlign: TextAlign.center,
        style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              fontSize: 16,
              color: ColorConstants.tertiaryBlack,
            ),
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context, Client client,
      DematSelectClientController controller) {
    return InkWell(
      onTap: () {
        controller.updateSelectedClients(
            client, SelectedClientsUpdateType.Remove);
      },
      child: Text(
        'Remove',
        style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
              color: ColorConstants.primaryAppColor,
            ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, DematSelectClientController controller) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ActionButton(
            responsiveButtonMaxWidthRatio: 0.4,
            bgColor: ColorConstants.secondaryAppColor,
            textStyle: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                  color: ColorConstants.primaryAppColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
            text: 'Cancel',
            onPressed: () {
              AutoRouter.of(context).popForced();
            },
            margin: EdgeInsets.zero,
          ),
          SizedBox(
            width: 12,
          ),
          ActionButton(
            responsiveButtonMaxWidthRatio: 0.4,
            text: 'Proceed',
            margin: EdgeInsets.zero,
            onPressed: () async {
              AutoRouter.of(context).push(DematOverviewRoute(
                  selectedClients: controller.selectedClients));
            },
          )
        ],
      ),
    );
  }
}
