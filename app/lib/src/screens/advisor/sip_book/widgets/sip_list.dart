import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/sip_book_controller.dart';
import 'package:app/src/controllers/transaction/transaction_controller.dart';
import 'package:app/src/screens/advisor/sip_book/widgets/sip_listing_tab_section.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/transactions/transaction_home/widgets/transaction_list.dart';
import 'package:app/src/widgets/card/offline_sip_book_card.dart';
import 'package:app/src/widgets/card/sip_book_card_new.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'search_bar.dart';

class SipList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GetBuilder<SipBookController>(
        builder: (controller) {
          final isTransactionTab =
              controller.selectedSipBookTab == SipBookTabType.Transactions;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20)
                    .copyWith(bottom: 10),
                child: SipListingTabSection(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SearchBarSection(),
              ),
              if (controller.selectedClient != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSelectedClient(context, controller),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: isTransactionTab
                      ? _buildSipTransaction(controller)
                      : _buildSipList(controller),
                ),
              ),
              if (controller.isPaginating) _buildInfiniteLoader(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedClient(
    BuildContext context,
    SipBookController controller,
  ) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ColorConstants.primaryAppColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConstants.primaryAppColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            (controller.selectedClient?.name ?? '-').toTitleCase(),
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(color: ColorConstants.primaryAppColor, height: 1),
          ),
          InkWell(
            onTap: () {
              controller.resetSelectClient();
            },
            child: Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(
                Icons.close,
                color: ColorConstants.primaryAppColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSipList(SipBookController controller) {
    if (!controller.isPaginating &&
        controller.currentResponse.state == NetworkState.loading) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: 3,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return SkeltonLoaderCard(
            height: 200,
            margin: EdgeInsets.only(bottom: 20),
          );
        },
      );
    }
    if (controller.currentResponse.state == NetworkState.error) {
      return RetryWidget(
        controller.currentResponse.message,
        onPressed: () {
          controller.fetchSipListing();
        },
      );
    }
    final data = getListingData(controller);

    if (controller.currentResponse.state == NetworkState.loaded &&
        data.isNullOrEmpty) {
      return EmptyScreen(message: 'No Data Found');
    }
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      controller: controller.scrollController,
      itemCount: data.length,
      separatorBuilder: (BuildContext context, int index) {
        if (controller.selectedSipBookTab == SipBookTabType.Transactions) {
          return SizedBox(height: 20);
        }
        return CommonUI.buildProfileDataSeperator(
          color: ColorConstants.secondarySeparatorColor,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        final sipData = data[index];
        if (controller.selectedSipBookTab == SipBookTabType.Online) {
          return SipBookCardNew(
            sipData: sipData,
            client: controller.selectedClient,
          );
        }
        if (controller.selectedSipBookTab == SipBookTabType.Offline) {
          return OfflineSipBookCard(sipData: sipData);
        }
        // if (controller.selectedSipBookTab == SipBookTabType.Transactions) {
        //   return Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 20),
        //     child: MfTransactionCard(transaction: sipData),
        //   );
        // }
      },
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
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  List getListingData(SipBookController controller) {
    if (controller.selectedSipBookTab == SipBookTabType.Online) {
      return controller.sipUserData;
    }
    if (controller.selectedSipBookTab == SipBookTabType.Offline) {
      return controller.offlineSipData;
    }

    return [];
  }

  Widget _buildSipTransaction(SipBookController controller) {
    return GetBuilder<TransactionController>(
      init: TransactionController(
        screenContext: TransactionScreenContext.sipBook,
        partnerOfficeModel: controller.partnerOfficeModel,
      ),
      autoRemove: false,
      builder: (controller) {
        return TransactionList();
      },
    );
  }
}
