import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/screens/store/common_new/widgets/step_up_sip_form_section.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class ActivateStepUpSip extends StatefulWidget {
  String selectedStepUpPeriod;
  int stepUpPercentage;
  final Function(String, int) onUpdateStepUpPeriod;
  final TextEditingController stepUpPercentageController;
  final double sipAmount;

  ActivateStepUpSip({
    Key? key,
    required this.selectedStepUpPeriod,
    required this.onUpdateStepUpPeriod,
    required this.stepUpPercentageController,
    required this.sipAmount,
    required this.stepUpPercentage,
  }) : super(key: key);

  @override
  State<ActivateStepUpSip> createState() => _ActivateStepUpSipState();
}

class _ActivateStepUpSipState extends State<ActivateStepUpSip> {
  final GlobalKey<FormState> activateSipFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30)
                .copyWith(
                    bottom:
                        isKeyboardVisible ? (context.insetsBottom + 20) : 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step-up SIP',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: ColorConstants.black,
                              ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Choose Period & Percentage',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w400,
                                color: ColorConstants.tertiaryBlack,
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                      alignment: Alignment.topRight,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        AutoRouter.of(context).popForced();
                      },
                      icon: Icon(
                        Icons.close,
                        size: 24,
                        color: ColorConstants.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                StepUpSipFormSection(
                  activateSipFormKey: activateSipFormKey,
                  onUpdateStepUpPercentage: (data) {
                    if (mounted) {
                      setState(() {
                        widget.stepUpPercentage = data;
                      });
                    }
                  },
                  onUpdateStepUpPeriod: (data) {
                    if (mounted) {
                      setState(() {
                        widget.selectedStepUpPeriod = data;
                      });
                    }
                  },
                  stepUpPercentageController: widget.stepUpPercentageController,
                  selectedStepUpPeriod: widget.selectedStepUpPeriod,
                ),
                SizedBox(height: 20),
                _buildStepUpOverviewSection(
                  context: context,
                  currentSip: widget.sipAmount,
                  stepUpPeriod: widget.selectedStepUpPeriod,
                ),
                _buildActivateSIPButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepUpOverviewSection({
    required BuildContext context,
    required double currentSip,
    required String stepUpPeriod,
  }) {
    final updatedSip = currentSip * 1.0 * (1.0 + widget.stepUpPercentage / 100);
    final titleStyle = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          color: ColorConstants.tertiaryBlack,
        );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w600,
            );
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.secondaryWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        children: [
          CommonUI.buildColumnTextInfo(
            title: 'Current SIP',
            titleStyle: titleStyle,
            subtitleStyle: subtitleStyle,
            subtitle: WealthyAmount.currencyFormat(currentSip, 0),
            gap: 6,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Image.asset(
                      AllImages().longArrowIcon,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: ColorConstants.greenAccentColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Text(
                            '+${widget.stepUpPercentage}%',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .copyWith(
                                  color: ColorConstants.white,
                                  fontSize: 11,
                                ),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          stepUpPeriod,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                color: ColorConstants.tertiaryBlack,
                              ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          CommonUI.buildColumnTextInfo(
            title: 'Your Updated SIP',
            titleStyle: titleStyle,
            subtitleStyle: subtitleStyle,
            subtitle: WealthyAmount.currencyFormat(updatedSip, 0),
            gap: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildActivateSIPButton() {
    return ActionButton(
      text: 'Activate  Step-up',
      margin: EdgeInsets.only(top: 40),
      onPressed: () {
        final isValid = (activateSipFormKey.currentState?.mounted ?? false) &&
            (activateSipFormKey.currentState?.validate() ?? false);
        if (isValid) {
          widget.onUpdateStepUpPeriod(
            widget.selectedStepUpPeriod,
            widget.stepUpPercentage,
          );
        }
      },
    );
  }
}
