import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/client/sip/client_sip_detail_controller.dart';
import 'package:app/src/screens/clients/sip_details/widget/sip_detail_view.dart';
import 'package:app/src/screens/clients/sip_details/widget/sip_summary_card.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/sip_user_data_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class SipDetailScreen extends StatelessWidget {
  final SipUserDataModel sipUserData;
  final Client client;

  SipDetailScreen({Key? key, required this.sipUserData, required this.client})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: getSIPDisplayNameNew(sipUserData),
        maxLine: 2,
        trailingWidgets: [
          Align(
            alignment: Alignment.centerRight,
            child: ClickableText(
              text: 'Edit SIP',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              onClick: () {
                AutoRouter.of(context).push(
                  EditSipFormRoute(
                    client: client,
                    selectedSip: sipUserData,
                  ),
                );
              },
            ),
          )
        ],
      ),
      body: GetBuilder<ClientSipDetailController>(
        init:
            ClientSipDetailController(client: client, selectedSip: sipUserData),
        builder: (controller) {
          if (controller.sipDetailResponse.state == NetworkState.loading &&
              !controller.isPaginating) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (controller.sipDetailResponse.state == NetworkState.error) {
            return Center(
              child: RetryWidget(
                controller.sipDetailResponse.message,
                onPressed: () {
                  controller.getClientSIPDetails();
                },
              ),
            );
          }
          if (controller.sipDetailResponse.state == NetworkState.loaded ||
              controller.isPaginating) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SIPSummaryCard(),
                Expanded(
                  child: SIPDetailView(),
                ),
                if (controller.isPaginating) _buildInfiniteLoader()
              ],
            );
          }
          return SizedBox();
        },
      ),
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
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
