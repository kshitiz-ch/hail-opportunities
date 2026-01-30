import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_demat_controller.dart';
import 'package:app/src/screens/clients/client_profile/client_demat/widgets/empty_external_demat.dart';
import 'package:app/src/screens/clients/client_profile/client_demat/widgets/empty_wealthy_demat.dart';
import 'package:app/src/screens/clients/client_profile/client_demat/widgets/external_demat_section.dart';
import 'package:app/src/screens/clients/client_profile/client_demat/widgets/wealthy_demat_section.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/line_dash.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class ClientDematDetailScreen extends StatelessWidget {
  final Client client;

  const ClientDematDetailScreen({Key? key, required this.client})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Demat Details',
      ),
      body: GetBuilder<ClientDematController>(
        init: ClientDematController(client),
        builder: (controller) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  _buildWealthyDemat(controller),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 12),
                    child: LineDash(
                      width: 2,
                      color: ColorConstants.black.withOpacity(0.2),
                    ),
                  ),
                  _buildExternalDemat(controller),
                  SizedBox(height: 30)
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWealthyDemat(ClientDematController controller) {
    if (controller.wealthyDemat.state == NetworkState.loading) {
      return CommonUI.buildShimmerWidget();
    }
    if (controller.wealthyDemat.state == NetworkState.error) {
      return SizedBox(
        height: 300,
        child: Center(
          child: RetryWidget(
            controller.wealthyDemat.message,
            onPressed: () {
              controller.getWealthyDemat();
            },
          ),
        ),
      );
    }
    if (controller.wealthyDemat.state == NetworkState.loaded) {
      if (controller.wealthyDematModel == null) {
        return EmptyWealthyDemat();
      } else {
        return WealthyDematSection();
      }
    }
    return SizedBox();
  }

  Widget _buildExternalDemat(ClientDematController controller) {
    if (controller.externalDemat.state == NetworkState.loading) {
      return CommonUI.buildShimmerWidget();
    }
    if (controller.externalDemat.state == NetworkState.error) {
      return SizedBox(
        height: 300,
        child: Center(
          child: RetryWidget(
            controller.wealthyDemat.message,
            onPressed: () {
              controller.getExternalDemats();
            },
          ),
        ),
      );
    }
    if (controller.externalDemat.state == NetworkState.loaded) {
      if (controller.externalDematList.isNullOrEmpty) {
        return EmptyExternalDemat();
      } else {
        return ExternalDematSection();
      }
    }
    return SizedBox();
  }
}
