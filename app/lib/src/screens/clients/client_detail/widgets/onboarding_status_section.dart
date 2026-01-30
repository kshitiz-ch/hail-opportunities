import 'package:app/flavors.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:core/modules/clients/models/profile_prefill_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class OnboardingStatusSection extends StatefulWidget {
  const OnboardingStatusSection({super.key});

  @override
  State<OnboardingStatusSection> createState() =>
      _OnboardingStatusSectionState();
}

class _OnboardingStatusSectionState extends State<OnboardingStatusSection> {
  bool showProgress = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientDetailController>(
      id: 'client-onboarding',
      builder: (controller) {
        if (controller.clientOnboardingResponse.isLoading) {
          return Center(child: SkeltonLoaderCard(height: 100));
        }
        if (controller.clientOnboardingResponse.isError) {
          return Container(
            height: 100,
            alignment: Alignment.center,
            child: RetryWidget(
              controller.clientOnboardingResponse.message,
              onPressed: () {
                controller.getClientOnboardingDetails();
              },
            ),
          );
        }

        final summary = controller.clientOnboardingSummary;
        final currentOnboarding = summary.currentOnboarding;
        final isShowProgress = summary.isShowProgress;
        final onboardingText = summary.onboardingText;

        if (isShowProgress == false) {
          return const SizedBox.shrink();
        }

        if (currentOnboarding == null || currentOnboarding.isInvestmentReady) {
          return SizedBox();
        }

        if (this.mounted &&
            (currentOnboarding.isUnderProcess ||
                currentOnboarding.onboardingPercent >= 50) &&
            showProgress) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients &&
                _scrollController.position.hasContentDimensions) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            }
          });
        }

        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Row 1: Onboarding % and Buttons ---
              _buildOnboardingOverview(
                context: context,
                brokingTypeText: onboardingText,
                kycUrl: getKycLink(currentOnboarding.isBrokingKyc),
                onboardingPercent: currentOnboarding.onboardingPercent,
              ),

              // --- Row 2: Current Status ---
              if (showProgress)
                _buildCurrentStatus(
                  context,
                  currentOnboarding.nextStep,
                ),

              // --- Row 3: Stepper ---
              if (showProgress)
                _buildOnboardingTimeline(
                  context,
                  currentOnboarding,
                ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOnboardingOverview({
    required BuildContext context,
    required String brokingTypeText,
    required String kycUrl,
    required int onboardingPercent,
  }) {
    return Row(
      children: [
        Text.rich(
          TextSpan(
            text: '$brokingTypeText',
            style: context.titleLarge
                ?.copyWith(color: ColorConstants.tertiaryBlack),
            children: [
              TextSpan(
                text: ' : $onboardingPercent%',
                style: context.titleLarge?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: _buildCTA(
            context: context,
            onPress: () {
              setState(() {
                showProgress = !showProgress;
              });
            },
            icon: showProgress
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            labelText: 'View Progress',
          ),
        ),
        if (kycUrl.isNotNullOrEmpty)
          _buildCTA(
            context: context,
            onPress: () {
              copyData(data: kycUrl);
            },
            icon: Icons.copy,
            labelText: 'KYC Link',
          ),
      ],
    );
  }

  Widget _buildCurrentStatus(
    BuildContext context,
    String nextStep,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Text(
            'Current Status : ',
            style: context.titleLarge?.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            nextStep,
            style: context.titleLarge?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingTimeline(
      BuildContext context, ProfilePrefillModel clientOnboardingModel) {
    // Process Sequence :
    // Contact details (10) --> Pan details (30) -->  Personal Details (50)
    // --> Bank Proof (70)  -->  Submitted (Under Verification )(100)

    return SingleChildScrollView(
      controller: _scrollController,
      // Allow horizontal scrolling if steps overflow
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          _buildStep(
              title: 'Contact details',
              isCompleted: clientOnboardingModel.isContactDetailsCompleted &&
                  clientOnboardingModel.onboardingPercent >= 10,
              isFirst: true,
              context: context,
              isUnderProcess: clientOnboardingModel.isUnderProcess),
          _buildStep(
              title: 'Pan details',
              isCompleted: clientOnboardingModel.isPanDetailsCompleted &&
                  clientOnboardingModel.onboardingPercent >= 30,
              context: context,
              isUnderProcess: clientOnboardingModel.isUnderProcess),
          _buildStep(
              title: 'Personal Details',
              isCompleted: clientOnboardingModel.isPersonalDetailsCompleted &&
                  clientOnboardingModel.onboardingPercent >= 50,
              context: context,
              isUnderProcess: clientOnboardingModel.isUnderProcess),
          _buildStep(
              title: 'Bank Proof',
              isCompleted: clientOnboardingModel.isBankDetailsCompleted &&
                  clientOnboardingModel.onboardingPercent >= 70,
              context: context,
              isUnderProcess: clientOnboardingModel.isUnderProcess),
          _buildStep(
            title: 'Submitted',
            isCompleted: clientOnboardingModel.isUnderProcess
                ? false
                : clientOnboardingModel.onboardingPercent == 100,
            context: context,
            isUnderProcess: clientOnboardingModel.isUnderProcess,
          ),
          // Add more steps as needed
        ],
      ),
    );
  }

  Widget _buildCTA({
    required BuildContext context,
    required Function onPress,
    required IconData icon,
    required String labelText,
  }) {
    return InkWell(
      onTap: () {
        onPress();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ColorConstants.secondarySeparatorColor),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          children: [
            Text(
              labelText,
              style: context.titleLarge?.copyWith(
                color: ColorConstants.primaryAppColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 5),
            Icon(
              icon,
              color: ColorConstants.primaryAppColor,
              size: 16,
            )
          ],
        ),
      ),
    );
  }

  // Helper method to build each step
  Widget _buildStep({
    required String title,
    required bool isCompleted,
    bool isFirst = false,
    bool isUnderProcess = false,
    required BuildContext context,
  }) {
    final completedColor = ColorConstants.greenAccentColor;
    final completedBgColor = ColorConstants.greenAccentColor.withOpacity(0.1);

    final pendingColor = Color(0xffDBDBDB);
    final pendingBgColor = Color(0xffF8F8F8);

    final verificationBgColor =
        ColorConstants.yellowAccentColor.withOpacity(0.1);
    final verificationColor = ColorConstants.yellowAccentColor;

    bool underVerification = isCompleted ? false : isUnderProcess;
    if (underVerification) {
      title += ' (Under Verification)';
    }

    return IntrinsicWidth(
      // Make the container wrap its content width
      child: Row(
        children: [
          // Connector line (skip for first item)
          if (!isFirst)
            Container(
              width: 10,
              height: 2,
              color: isCompleted ? completedColor : pendingColor,
            ),
          // Step bubble
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted
                  ? completedBgColor
                  : underVerification
                      ? verificationBgColor
                      : pendingBgColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Row takes minimum space needed
              children: [
                Container(
                  height: 16,
                  width: 16,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? completedColor
                        : underVerification
                            ? verificationColor
                            : ColorConstants.white,
                    shape: BoxShape.circle,
                    border:
                        isCompleted ? null : Border.all(color: pendingColor),
                  ),
                  child: isCompleted || underVerification
                      ? Icon(
                          Icons.check,
                          color: ColorConstants.white,
                          size: 12,
                        )
                      : SizedBox(),
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: context.titleLarge?.copyWith(
                    color: ColorConstants.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getKycLink(bool isBrokingKyc) {
    final baseUrl = F.appFlavor == Flavor.PROD
        ? 'https://www.wealthy.in'
        : 'https://www.wealthydev.in';
    final path = isBrokingKyc ? 'client/broking/profile' : 'client/profile';
    return '$baseUrl/$path';
  }
}
