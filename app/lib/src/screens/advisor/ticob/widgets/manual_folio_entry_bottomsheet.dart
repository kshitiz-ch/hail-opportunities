import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/advisor/ticob_controller.dart';
import 'package:app/src/screens/advisor/ticob/widgets/amc_selector.dart';
import 'package:app/src/screens/advisor/ticob/widgets/ticob_client_card.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/bordered_text_form_field.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/advisor/models/ticob_folio_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManualFolioEntryBottomSheet extends StatelessWidget {
  final Client selectedClient;

  const ManualFolioEntryBottomSheet({Key? key, required this.selectedClient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TicobController>(
      initState: (_) {
        final controller = Get.find<TicobController>();
        controller.selectedClient = selectedClient;
        controller.folioBasket = [];
      },
      builder: (controller) {
        return ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: SizeConfig().screenHeight * 0.8),
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add AMC and Folio Name',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium
                          ?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.black,
                          ),
                    ),
                    CommonUI.bottomsheetCloseIcon(context),
                  ],
                ),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: TicobClientCard(
                          selectedClient: controller.selectedClient!,
                        ),
                      ),
                      if (controller.folioBasket.isNotNullOrEmpty)
                        _buildFolioBasket(controller),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: _buildFolioInput(context, controller),
                      ),
                      AmcSelector(),
                      _buildAddCTA(context, controller),
                    ],
                  ),
                ),
                _buildGenerateCTA(context, controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFolioBasket(TicobController controller) {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 20),
      itemCount: controller.folioBasket.length,
      separatorBuilder: (context, index) => SizedBox(height: 10),
      itemBuilder: (context, index) {
        final titleStyle =
            Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w400,
                );
        final subtitleStyle =
            Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                );
        final amcName = controller.folioBasket[index].amc;
        final folioNumber = controller.folioBasket[index].folioNumber;

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: ColorConstants.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: CommonUI.buildColumnTextInfo(
                  title: 'AMC Name',
                  subtitle: amcName ?? '-',
                  titleStyle: titleStyle,
                  subtitleStyle: subtitleStyle,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: CommonUI.buildColumnTextInfo(
                  title: 'Folio Number',
                  subtitle: folioNumber ?? '-',
                  titleStyle: titleStyle,
                  subtitleStyle: subtitleStyle,
                ),
              ),
              SizedBox(width: 20),
              InkWell(
                onTap: () {
                  controller.folioBasket.removeAt(index);
                  controller.update();
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 119, 119, 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Image.asset(
                    AllImages().deleteIcon,
                    height: 12,
                    width: 10,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFolioInput(BuildContext context, TicobController controller) {
    final style = Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
          color: ColorConstants.tertiaryBlack,
          height: 0.7,
        );
    return BorderedTextFormField(
      borderRadius: BorderRadius.circular(8),
      useLabelAsHint: true,
      enabled: true,
      controller: controller.folioInputController,
      label: 'Enter Folio Number',
      hintText: 'Enter Folio Number',
      style: style.copyWith(
        color: ColorConstants.black,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      labelStyle: style,
      hintStyle: style,
      inputFormatters: [
        NoLeadingSpaceFormatter(),
      ],
      suffixIcon: controller.folioInputController.text.isNullOrEmpty
          ? null
          : IconButton(
              icon: Icon(
                Icons.clear,
                size: 21.0,
                color: ColorConstants.darkGrey,
              ),
              onPressed: () {
                controller.folioInputController.clear();
                controller.update();
              },
            ),
      onChanged: (val) {
        controller.update();
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildAddCTA(BuildContext context, TicobController controller) {
    final isAddDisabled = controller.folioInputController.text.isNullOrEmpty ||
        (controller.selectedAmc == null);
    return Center(
      child: ClickableText(
        padding: EdgeInsets.symmetric(vertical: 20),
        fontSize: 16,
        fontWeight: FontWeight.w700,
        text: controller.folioBasket.isNullOrEmpty
            ? 'Add Folio'
            : '+ Add more Folio',
        textColor: isAddDisabled
            ? ColorConstants.tertiaryBlack
            : ColorConstants.primaryAppColor,
        onClick: isAddDisabled
            ? null
            : () {
                controller.folioBasket.add(
                  TicobFolioModel(
                    amc: (controller.selectedAmc?.amc ?? '').toTitleCase(),
                    folioNumber:
                        controller.folioInputController.text.toTitleCase(),
                    amcCode: controller.selectedAmc?.amcCode?.toString() ?? '',
                    // for manual
                    currentValue: 0,
                  ),
                );
                controller.selectedAmc = null;
                controller.folioInputController.text = '';
                controller.update();
                showToast(
                  text:
                      '${controller.folioBasket.length} folio(s) added successfully',
                );
              },
      ),
    );
  }

  Widget _buildGenerateCTA(BuildContext context, TicobController controller) {
    final isGenerateDisabled = controller.folioBasket.isNullOrEmpty;

    return ActionButton(
      isDisabled: isGenerateDisabled,
      margin: EdgeInsets.only(top: 20),
      text: 'Generate Form',
      showProgressIndicator:
          controller.ticobFormResponse.state == NetworkState.loading,
      onPressed: () async {
        await controller.generateTicobForm();
        if (controller.ticobFormResponse.state == NetworkState.error) {
          showToast(text: controller.ticobFormResponse.message);
        }
        if (controller.ticobFormResponse.state == NetworkState.loaded) {
          AutoRouter.of(context).push(GenerateCobSuccessfulRoute());
        }
      },
    );
  }
}
