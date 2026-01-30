import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/client/client_address_controller.dart';
import 'package:app/src/screens/clients/client_profile/client_address/widgets/delete_address_bottomsheet.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class ClientAddressScreen extends StatelessWidget {
  final Client client;

  ClientAddressScreen({Key? key, required this.client}) : super(key: key) {
    Get.put<ClientAddressController>(
      ClientAddressController(client),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        titleText: 'User Address',
      ),
      body: GetBuilder<ClientAddressController>(
        dispose: (_) {
          Get.delete<ClientAddressController>();
        },
        builder: (ClientAddressController controller) {
          if (controller.fetchAddress.state == NetworkState.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (controller.fetchAddress.state == NetworkState.error) {
            return Center(
              child: RetryWidget(
                controller.fetchAddress.message,
                onPressed: () {
                  controller.getClientAddressDetail();
                },
              ),
            );
          }
          if (controller.fetchAddress.state == NetworkState.loaded) {
            if (controller.clientAddressModelList.isNullOrEmpty) {
              return Center(
                child: EmptyScreen(
                  message: 'No Address available',
                ),
              );
            }
            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List<Widget>.generate(
                    controller.clientAddressModelList.length, (index) {
                  return _buildAddressUI(
                    title: controller.clientAddressModelList[index].title ?? '',
                    addressText:
                        controller.clientAddressModelList[index].address ?? '',
                    context: context,
                    onDelete: () {
                      CommonUI.showBottomSheet(
                        context,
                        child: DeleteAddressBottomSheet(
                          index: index,
                        ),
                      );
                    },
                    onEdit: () {
                      controller.initInputController(editIndex: index);
                      AutoRouter.of(context).push(
                        AddEditClientAddressRoute(editIndex: index),
                      );
                    },
                  );
                }),
              ),
            );
          }
          return SizedBox();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildAddAddressButton(context),
    );
  }

  Widget _buildAddressUI({
    required BuildContext context,
    required String addressText,
    required String title,
    required Function onEdit,
    required Function onDelete,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotNullOrEmpty)
          Text(
            title,
            style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w600,
                ),
          ),
        SizedBox(height: 2),
        Text(
          addressText,
          style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                color: Colors.black,
              ),
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {
                onEdit();
              },
              child: Text(
                'Edit',
                style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                      color: ColorConstants.lightPrimaryAppColor,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CommonUI.buildProfileDataSeperator(
                height: 15,
                width: 1,
                color: ColorConstants.lightPrimaryAppColor,
              ),
            ),
            InkWell(
              onTap: () {
                onDelete();
              },
              child: Text(
                'Delete',
                style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                      color: ColorConstants.errorTextColor,
                    ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: CommonUI.buildProfileDataSeperator(
            height: 1,
            width: double.infinity,
            color: Colors.black.withOpacity(0.1),
          ),
        )
      ],
    );
  }

  Widget _buildAddAddressButton(BuildContext context) {
    final controller = Get.find<ClientAddressController>();

    return ActionButton(
      textStyle: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: ColorConstants.primaryAppColor,
          ),
      text: '+ Add Address',
      bgColor: ColorConstants.primaryAppv3Color,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      onPressed: () {
        controller.initInputController();
        AutoRouter.of(context).push(
          AddEditClientAddressRoute(),
        );
      },
    );
  }
}
