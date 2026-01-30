import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/common/download_controller.dart';
import 'package:app/src/controllers/store/fixed_deposit/fixed_deposits_controller.dart';
import 'package:app/src/screens/store/fixed_deposit_list/widgets/offline_fd_card.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/store/models/fixed_deposit_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class FixedDepositOfflineListScreen extends StatelessWidget {
  final FixedDepositModel? selectedProduct;

  const FixedDepositOfflineListScreen({Key? key, this.selectedProduct})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.primaryScaffoldBackgroundColor,
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: 'Offline Plans',
      ),
      body: GetBuilder<FixedDepositsController>(
        builder: (controller) {
          if (controller.fdsState == NetworkState.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.fdsState == NetworkState.error) {
            return Center(
              child: RetryWidget(
                genericErrorMessage,
                onPressed: () {
                  controller.getFds();
                },
              ),
            );
          }

          if (controller.fdListModel != null) {
            final List<FixedDepositModel?> offlineProducts = controller
                .fdListModel!.available!
                .where((FixedDepositModel fdModel) => !fdModel.isOnline!)
                .toList();
            // show selected product at top
            if (selectedProduct != null) {
              offlineProducts.removeWhere((element) =>
                  element!.displayName == selectedProduct!.displayName);
              offlineProducts.insert(0, selectedProduct);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeader(context),
                _initialiseDownloadController(),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 0, bottom: 100),
                    itemCount: offlineProducts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return OfflineFDCard(
                        product: offlineProducts[index],
                      );
                    },
                  ),
                )
              ],
            );
          }
          return SizedBox();
        },
      ),
    );
  }

  Widget _initialiseDownloadController() {
    return GetBuilder<DownloadController>(
      init: DownloadController(),
      tag: 'fd',
      builder: (controller) {
        return SizedBox();
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
            child: Text(
              'Please download the forms and share\nwith your clients',
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
