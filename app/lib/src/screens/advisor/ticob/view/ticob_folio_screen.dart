import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/advisor/ticob_controller.dart';
import 'package:app/src/screens/advisor/ticob/widgets/ticob_client_card.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/advisor/models/ticob_folio_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class TicobFolioScreen extends StatelessWidget {
  TextStyle? style;

  @override
  Widget build(BuildContext context) {
    style = Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
          color: ColorConstants.black,
          fontWeight: FontWeight.w500,
        );
    return GetBuilder<TicobController>(
      initState: (_) {
        final controller = Get.find<TicobController>();
        controller.folioBasket = [];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.getTicobFolioList();
        });
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: 'Choose Folios',
            subtitleText: 'Choose folios to generate change of broker form',
          ),
          body: _buildUI(controller),
          bottomNavigationBar: _buildCTA(context, controller),
        );
      },
    );
  }

  Widget _buildUI(TicobController controller) {
    if (controller.ticobFolioResponse.state == NetworkState.loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (controller.ticobFolioResponse.state == NetworkState.error) {
      return Center(
        child: RetryWidget(
          controller.ticobFolioResponse.message,
          onPressed: () {
            controller.getTicobFolioList();
          },
        ),
      );
    }
    if (controller.ticobFolioResponse.state == NetworkState.loaded) {
      if (controller.ticobFolios!.totalFolios.isNullOrZero) {
        return Center(
          child: EmptyScreen(message: 'No folios available'),
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(30).copyWith(top: 12),
            child: TicobClientCard(
              selectedClient: controller.selectedClient!,
              panModel: controller.selectedPan,
            ),
          ),
          _buildHeader(),
          _buildAllSector(controller),
          Expanded(
            child: _buildFolioListing(controller),
          ),
          _buildNote(),
        ],
      );
    }
    return SizedBox();
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(color: ColorConstants.secondaryWhite),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // aligning header with listing
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Folio Number & AMC',
              style: style?.copyWith(color: ColorConstants.tertiaryBlack),
            ),
          ),
          // aligning header with listing
          SizedBox(width: 38),
          Expanded(
            child: Text(
              'Amount',
              style: style?.copyWith(color: ColorConstants.tertiaryBlack),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllSector(TicobController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffFDFCFF),
        border: Border(
          top: BorderSide(color: ColorConstants.borderColor),
          bottom: BorderSide(color: ColorConstants.borderColor),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      child: Row(
        children: [
          CommonUI.buildCheckbox(
            value: controller.includeAllInBasket,
            onChanged: (value) {
              if (value == true) {
                controller.folioBasket =
                    List.from(controller.ticobFolios!.ticobRegularFolioList);
              } else {
                controller.folioBasket = [];
              }
              controller.update();
            },
          ),
          SizedBox(width: 10),
          Text(
            'Select All Regular Folios',
            style: style?.copyWith(color: ColorConstants.tertiaryBlack),
          )
        ],
      ),
    );
  }

  Widget _buildFolioListing(TicobController controller) {
    return ListView.builder(
      itemCount: controller.ticobFolios!.totalFolios,
      padding: EdgeInsets.zero,
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        late TicobFolioModel model;
        if (controller.ticobFolios!.ticobRegularFolioList.length > index) {
          model = controller.ticobFolios!.ticobRegularFolioList[index];
        } else {
          model = controller.ticobFolios!.ticobNonRegularFolioList[
              index - controller.ticobFolios!.ticobRegularFolioList.length];
        }
        final isSelected = controller.folioBasket.contains(model);
        return Opacity(
          opacity: model.isDisabled ? 0.5 : 1,
          child: Container(
            color: index % 2 == 0 ? Color(0xffFAFBFD) : ColorConstants.white,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            child: Row(
              children: [
                CommonUI.buildCheckbox(
                  onChanged: (value) {
                    if (model.isDisabled) return;
                    if (value == true) {
                      controller.folioBasket.add(model);
                    } else {
                      controller.folioBasket.remove(model);
                    }
                    controller.update();
                  },
                  value: isSelected,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildFolioDetail(
                    context,
                    model,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFolioDetail(
    BuildContext context,
    TicobFolioModel ticobFolioModel,
  ) {
    final style = Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
          color: ColorConstants.black,
          fontWeight: FontWeight.w500,
        );
    return Row(
      children: [
        Expanded(
          child: CommonUI.buildColumnTextInfo(
            title: ticobFolioModel.folioNumber ?? '-',
            subtitle: ticobFolioModel.amc ?? '-',
            subtitleStyle: style?.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w400,
            ),
            titleStyle: style,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            WealthyAmount.currencyFormat(ticobFolioModel.currentValue, 0),
            style: style,
          ),
        )
      ],
    );
  }

  Widget _buildCTA(BuildContext context, TicobController controller) {
    final basketData = controller.folioBasket;
    final amount = basketData.fold<double>(
      0,
      (value, element) => value + (element.currentValue ?? 0),
    );
    final titleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w400,
            );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: ColorConstants.darkBlack.withOpacity(0.1),
            blurRadius: 10.0,
            offset: Offset(0, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              title: 'Amount',
              subtitle: WealthyAmount.currencyFormat(amount, 0),
              titleStyle: titleStyle,
              subtitleStyle: subtitleStyle,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: ActionButton(
              isDisabled: amount.isNullOrZero,
              text: 'Proceed',
              margin: EdgeInsets.zero,
              showProgressIndicator:
                  controller.ticobFormResponse.state == NetworkState.loading,
              onPressed: () async {
                await controller.generateTicobForm(fromFolioScreen: true);
                if (controller.ticobFormResponse.state == NetworkState.error) {
                  showToast(text: controller.ticobFormResponse.message);
                }
                if (controller.ticobFormResponse.state == NetworkState.loaded) {
                  AutoRouter.of(context).push(GenerateCobSuccessfulRoute());
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNote() {
    return Container(
      width: SizeConfig().screenWidth,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      decoration: BoxDecoration(
        color: ColorConstants.lightScaffoldBackgroundColor,
        border: Border.all(
          color: ColorConstants.tertiaryBlack,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 14),
      child: Text(
        "** Some Funds are disabled for broker change because they are direct funds",
        style: style?.copyWith(
          color: ColorConstants.tertiaryBlack,
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
