import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/advisor/sip_book_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/card/sip_book_card_new.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/sip_user_data_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GoalSips extends StatelessWidget {
  const GoalSips({
    Key? key,
    required this.client,
    required this.goalId,
    required this.anyFundWschemecode,
  }) : super(key: key);

  final Client client;
  final String goalId;
  final String? anyFundWschemecode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: GetBuilder<SipBookController>(
        init: SipBookController(
          selectedClient: client,
          goalId: goalId,
          wschemecode: anyFundWschemecode,
          fromSipBookScreen: false,
        ),
        autoRemove: false,
        builder: (controller) {
          if (!controller.isPaginating &&
              controller.onlineSipResponse.state == NetworkState.loading) {
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

          if (controller.onlineSipResponse.state == NetworkState.error) {
            return RetryWidget(
              controller.onlineSipResponse.message,
              onPressed: () {
                controller.getSipUserData();
              },
            );
          }

          if (controller.onlineSipResponse.state == NetworkState.loaded &&
              controller.sipUserData.isEmpty) {
            return EmptyScreen(
              message: 'No SIP Found',
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  controller: controller.scrollController,
                  itemCount: controller.sipUserData.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return CommonUI.buildProfileDataSeperator(
                      color: ColorConstants.secondarySeparatorColor,
                    );
                  },
                  itemBuilder: (BuildContext context, int index) {
                    SipUserDataModel sipUserData =
                        controller.sipUserData[index];
                    return SipBookCardNew(
                      sipData: sipUserData,
                      onClientView: true,
                      client: client,
                    );
                  },
                ),
              ),
              if (controller.isPaginating) _buildInfiniteLoader()
            ],
          );
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
