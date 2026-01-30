import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/credit_card/credit_cards_controller.dart';
import 'package:app/src/screens/store/credit_card/widgets/common_detail_card.dart';
import 'package:app/src/screens/store/credit_card/widgets/general_detail_card.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class CreditCardProposalDetailScreen extends StatelessWidget {
  late CreditCardsController creditCardsController;
  final String externalID;
  final bool canProceed;
  CreditCardProposalDetailScreen(
      {required this.externalID, required this.canProceed}) {
    creditCardsController = Get.isRegistered<CreditCardsController>()
        ? Get.find<CreditCardsController>()
        : Get.put<CreditCardsController>(CreditCardsController());
    creditCardsController.getCreditCardApplicationDetail(externalID);
  }
  @override
  Widget build(BuildContext context) {
    final titleTextStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w400,
              overflow: TextOverflow.ellipsis,
            );
    final subtitleTextStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            );

    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: 'Credit Card Application',
        showBackButton: true,
      ),
      body: GetBuilder<CreditCardsController>(
        builder: (CreditCardsController controller) {
          if (controller.creditCardApplicationDetailState ==
              NetworkState.loading) {
            return Center(child: CircularProgressIndicator());
          }
          if (controller.creditCardApplicationDetailState ==
              NetworkState.error) {
            return Center(
              child: RetryWidget(
                controller.creditCardApplicationDetailErrorMessage,
                onPressed: () {
                  controller.getCreditCardApplicationDetail(externalID);
                },
              ),
            );
          }
          if (controller.creditCardApplicationDetailState ==
              NetworkState.loaded) {
            final leadCreationData = controller.selectedCreditCardDetail
                ?.callBack?.leadCreationModel?.leadCreationData;
            final applicationSubmissionData = controller
                .selectedCreditCardDetail
                ?.callBack
                ?.applicationSubmissionModel
                ?.applicationSubmissionData;
            final applicationStatusUpdateData = controller
                .selectedCreditCardDetail
                ?.callBack
                ?.applicationStatusUpdateModel
                ?.applicationStatusUpdateData;
            final cardSelected =
                applicationSubmissionData?.customerProfile?.productSelected ??
                    applicationStatusUpdateData?.cardSelected;
            final lenderBank =
                applicationSubmissionData?.customerProfile?.lenderSelected ??
                    applicationStatusUpdateData?.selectedLender ??
                    'Card not selected';

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 26),
                    child: Row(
                      children: [
                        _buildBankIcon(
                            controller.selectedCreditCardDetail?.callBack?.logo,
                            lenderBank),
                        SizedBox(width: 8),
                        Text(
                          getFormattedText(lenderBank),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: ColorConstants.black,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 32),
                    child: buildGridInfoData(
                      titleTextStyle: titleTextStyle,
                      subtitleTextStyle: subtitleTextStyle,
                      data: <String, String>{
                        'Lead Created on': getFormattedDate(
                            controller.selectedCreditCardDetail?.createdAt),
                        'Last Updated On': getFormattedDate(
                            controller.selectedCreditCardDetail?.updatedAt),
                      },
                    ),
                  ),

                  // Lead ID
                  _buildLeadId(
                    controller.selectedCreditCardDetail?.thirdPartyReferenceId,
                    titleTextStyle: titleTextStyle,
                    subtitleTextStyle: subtitleTextStyle,
                  ),

                  GeneralDetailCard(
                    applicationStatus:
                        controller.selectedCreditCardDetail?.status,
                    data: applicationStatusUpdateData,
                    canProceed: canProceed,
                    externalID: externalID,
                  ),
                  CommonDetailCard(
                    cardTitle: 'Personal Details',
                    data: <String, String>{
                      'Name': getFormattedText(leadCreationData?.name),
                      // 'DOB': notAvailableText,
                      // 'Gender': notAvailableText,
                      'Mobile': leadCreationData!.primaryMobile.isNotNullOrEmpty
                          ? '+91-${leadCreationData.primaryMobile}'
                          : notAvailableText,
                      'City/Status': getFormattedText(
                          leadCreationData.city ?? notAvailableText),
                      // 'PIN Code': '700045',
                    },
                  ),
                  SizedBox(height: 20),
                  CommonDetailCard(
                    cardTitle: 'Credit & Employment Information',
                    data: <String, String>{
                      'Bureau Score': getFormattedText(
                          leadCreationData.bureauProfile?.toCapitalized()),
                      // 'Employment Type': notAvailableText,
                      // 'Monthly Income': notAvailableText,
                      'PAN': getFormattedText(leadCreationData.pan),
                      'Company Name': getFormattedText(applicationSubmissionData
                          ?.customerProfile?.companyName),
                    },
                  ),
                  SizedBox(height: 20),
                  CommonDetailCard(
                    cardTitle: 'Application Details',
                    data: <String, String>{
                      'Bank': getFormattedText(lenderBank),
                      'Card': getFormattedText(cardSelected),
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          }
          return SizedBox();
        },
      ),
    );
  }
}

Widget _buildBankIcon(String? logoUrl, String? lenderBank) {
  try {
    return CircleAvatar(
      radius: 18,
      backgroundImage: (logoUrl.isNotNullOrEmpty
              ? CachedNetworkImageProvider(logoUrl!)
              : AssetImage(getCreditCardBankIcon(lenderBank)))
          as ImageProvider<Object>?,
    );
  } catch (error) {
    return CircleAvatar(
      radius: 18,
      backgroundImage: AssetImage(getCreditCardBankIcon(lenderBank)),
    );
  }
}

Widget _buildLeadId(
  String? thirdPartyReferenceId, {
  required TextStyle titleTextStyle,
  required TextStyle subtitleTextStyle,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32).copyWith(bottom: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Lead ID',
          style: titleTextStyle,
        ),
        SizedBox(height: 5),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: thirdPartyReferenceId.isNotNullOrEmpty
                    ? thirdPartyReferenceId
                    : 'NA',
                style: subtitleTextStyle,
              ),
              if (thirdPartyReferenceId.isNotNullOrEmpty)
                WidgetSpan(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4)
                        .copyWith(bottom: 3, top: 2),
                    child: InkWell(
                      onTap: () {
                        copyData(data: thirdPartyReferenceId);
                      },
                      child: Icon(
                        Icons.copy,
                        size: 13,
                        color: ColorConstants.primaryAppColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // maxLines: 2,
          // textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget buildGridInfoData({
  required TextStyle titleTextStyle,
  required TextStyle subtitleTextStyle,
  required Map<String, String> data,
}) {
  Widget getRowChild(int index, List<String> keyList) {
    return Expanded(
      child: (index) < keyList.length
          ? CommonUI.buildColumnTextInfo(
              title: keyList[index],
              subtitle: data[keyList[index]] ?? '',
              titleStyle: titleTextStyle,
              subtitleStyle: subtitleTextStyle,
              subtitleMaxLength: 2,
              gap: 5,
            )
          : SizedBox(),
    );
  }

  List<Widget> children = <Widget>[];
  final keyList = data.keys.toList();
  for (int index = 0; index < keyList.length; index += 2) {
    children.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Row(
          children: [
            getRowChild(index, keyList),
            SizedBox(width: 10),
            getRowChild(index + 1, keyList),
          ],
        ),
      ),
    );
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  );
}
