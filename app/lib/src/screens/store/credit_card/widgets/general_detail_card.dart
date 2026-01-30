import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/credit_card/credit_cards_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/store/models/credit_card_product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class GeneralDetailCard extends StatelessWidget {
  final ApplicationStatusUpdateData? data;
  final bool canProceed;
  final String externalID;
  final int? applicationStatus;

  final cardTitle = 'General Details';
  late Map<String, String> detailData;
  late Map<String, String> resumeData;

  GeneralDetailCard({
    Key? key,
    required this.data,
    required this.canProceed,
    required this.externalID,
    required this.applicationStatus,
  }) : super(key: key) {
    detailData = <String, String>{
      'Status': data?.status == null
          ? getCredilioStatusText(applicationStatus)
          : getFormattedText(data?.status),
      'Sub-Status': getFormattedText(data?.subStatus),
    };
    resumeData = <String, String>{
      'Remarks': getFormattedText(data?.remarks),
      'Next Step': getFormattedText(data?.nextActionDescription),
    };
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 32).copyWith(bottom: 12),
          child: Text(
            cardTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
        ),
        Container(
          // fixed ipad issue
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
          padding: EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ColorConstants.borderColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[]
              ..addAll(
                List<Widget>.generate(
                  detailData.entries.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20)
                        .copyWith(bottom: 16),
                    child: CommonUI.buildColumnTextInfo(
                      title: detailData.entries.elementAt(index).key,
                      subtitle: detailData.entries.elementAt(index).value,
                      titleStyle: titleTextStyle,
                      subtitleStyle: subtitleTextStyle,
                      subtitleMaxLength: 2,
                      gap: 5,
                    ),
                  ),
                ),
              )
              ..add(
                _buildResumeCard(
                  context,
                  titleTextStyle,
                  subtitleTextStyle,
                ),
              ),
          ),
        ),
      ],
    );
  }

  Widget _buildResumeCard(
    BuildContext context,
    TextStyle titleTextStyle,
    TextStyle subtitleTextStyle,
  ) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.secondaryCardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color(0xffFFBF00),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[]..addAll(
            List<Widget>.generate(
              resumeData.entries.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CommonUI.buildColumnTextInfo(
                  title: resumeData.entries.elementAt(index).key,
                  subtitle: resumeData.entries.elementAt(index).value,
                  titleStyle: titleTextStyle,
                  subtitleStyle: subtitleTextStyle,
                  subtitleMaxLength: 2,
                  gap: 5,
                ),
              ),
            )..add(
                canProceed
                    ? SizedBox(
                        width: 150,
                        child: GetBuilder<CreditCardsController>(
                          builder: (controller) {
                            return ActionButton(
                              onPressed: () {
                                resumeToCredilio(context, controller);
                              },
                              height: 44,
                              margin: EdgeInsets.zero,
                              text: 'Resume ',
                              textStyle: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: ColorConstants.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                              prefixWidget: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Image.asset(
                                  AllImages().resumeIcon,
                                  height: 16,
                                  width: 16,
                                  // color: ColorConstants.primaryAppColor,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : SizedBox(),
              ),
          ),
      ),
    );
  }

  Future<void> resumeToCredilio(
      BuildContext context, CreditCardsController creditCardsController) async {
    await creditCardsController.getCreditCardResumeURL(externalID, context);

    if (creditCardsController.creditCardResumeState == NetworkState.loaded) {
      AutoRouter.of(context).push(
        CreditCardWebViewRoute(
          url: creditCardsController.creditCardResumeUrl,
          callback: () {},
          onNavigationRequest: (
            InAppWebViewController controller,
            NavigationAction action,
          ) async {
            final navigationUrl = action.request.url.toString();

            if (redirectToCreditCardHome(navigationUrl)) {
              // go to credit card home page
              if (isRouteNameInStack(context, CreditCardHomeRoute.name)) {
                AutoRouter.of(context).popUntil(
                  ModalRoute.withName(CreditCardHomeRoute.name),
                );
              } else {
                AutoRouter.of(context).popForced();
              }
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
          },
          onWebViewExit: () {
            AutoRouter.of(context).popForced();
          },
        ),
      );
    }
  }
}
