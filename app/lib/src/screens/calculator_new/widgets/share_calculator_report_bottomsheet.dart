import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/advisor/calculator_controller_new.dart';
import 'package:app/src/controllers/client/client_list_controller.dart';
import 'package:app/src/screens/clients/reports/widgets/downloaded_report_bottomsheet.dart';
import 'package:app/src/utils/events_tracker/event_tracker.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/clients/models/new_client_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:open_file_plus/open_file_plus.dart';

class ShareCalculatorReportBottomSheet extends StatefulWidget {
  const ShareCalculatorReportBottomSheet({Key? key}) : super(key: key);

  @override
  State<ShareCalculatorReportBottomSheet> createState() =>
      _ShareCalculatorReportBottomSheetState();
}

class _ShareCalculatorReportBottomSheetState
    extends State<ShareCalculatorReportBottomSheet> {
  NewClientModel? selectedClient;
  bool includeTableInReport = true;

  final SuggestionsController<NewClientModel> clientSuggestionController =
      SuggestionsController<NewClientModel>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Share Report',
                      style: context.headlineLarge!.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Select Client Label
                    Text(
                      'Select Client (Optional)',
                      style: context.titleMedium!.copyWith(
                        color: ColorConstants.tertiaryGrey,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Client Search TypeAhead Field
                    _buildClientTypeAheadField(),
                    const SizedBox(height: 50),

                    // Selected Client Info Card
                    if (selectedClient != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ColorConstants.paleLavenderColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: getRandomBgColor(0),
                              child: Text(
                                selectedClient!.name?.initials ?? '',
                                style: context.headlineMedium!.copyWith(
                                  color: getRandomTextColor(0),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Client Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedClient!.name ?? '',
                                    style: context.headlineSmall!.copyWith(
                                      color: ColorConstants.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'CRN: ${selectedClient!.crn ?? '-'}',
                                    style: context.headlineSmall?.copyWith(
                                      color: ColorConstants.tertiaryGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Include table checkbox
                    InkWell(
                      onTap: () {
                        setState(() {
                          includeTableInReport = !includeTableInReport;
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: includeTableInReport
                                    ? ColorConstants.primaryAppColor
                                    : ColorConstants.tertiaryGrey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: includeTableInReport
                                ? Icon(
                                    Icons.check,
                                    color: ColorConstants.primaryAppColor,
                                    size: 16,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Include table in Report',
                            style: context.headlineSmall?.copyWith(
                              color: ColorConstants.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ActionButton(
                            bgColor: ColorConstants.primaryAppv3Color,
                            textStyle: context.headlineMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ColorConstants.primaryAppColor,
                              fontSize: 16,
                            ),
                            text: 'Cancel',
                            margin: EdgeInsets.zero,
                            onPressed: () {
                              AutoRouter.of(context).pop();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GetBuilder<CalculatorController>(
                            id: 'report-pdf',
                            builder: (controller) {
                              return ActionButton(
                                text: 'Download',
                                showProgressIndicator:
                                    controller.reportPdfResponse.isLoading,
                                margin: EdgeInsets.zero,
                                onPressed: () async {
                                  onDownloadReport(controller);
                                },
                                textStyle: context.headlineMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.white,
                                  fontSize: 16,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onDownloadReport(CalculatorController controller) async {
    await controller.downloadCalculatorReportPdf(
      isIncludeTable: includeTableInReport,
      selectedClient: selectedClient,
    );

    if (controller.reportPdfResponse.isLoaded && controller.pdfFile != null) {
      final calculatorName =
          controller.currentCalculatorType.value.calculatorName;
      final selectedCRN = selectedClient?.crn;

      String fileName = calculatorName;
      if (selectedCRN.isNotNullOrEmpty) {
        fileName = '$calculatorName - $selectedCRN';
      }

      EventTracker.trackReportDownloaded(
        context: context,
        reportName: calculatorName,
        clientCRN: selectedCRN ?? 'NA',
        pageName: calculatorName,
      );

      await CommonUI.showBottomSheet(
        context,
        child: DownloadedReportBottomSheet(
          onShare: () async {
            try {
              await shareFiles(controller.pdfFile!.path);
            } catch (error) {
              showToast(text: "Failed to share. Please try after some time");
            }
          },
          onView: () async {
            await OpenFile.open(controller.pdfFile!.path);
          },
          reportName: fileName,
        ),
      );
    } else {
      showToast(text: "Failed to download report. Please try after some time");
    }
  }

  Widget _buildClientTypeAheadField() {
    return GetBuilder<ClientListController>(
      init: ClientListController(),
      tag: 'select-client-calculator',
      builder: (controller) {
        // Refresh suggestions whenever the GetBuilder rebuilds (when controller.update() is called)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          clientSuggestionController.refresh();
        });

        return TypeAheadField<NewClientModel>(
          controller: controller.searchController,
          suggestionsController: clientSuggestionController,
          builder: (context, searchController, focusNode) {
            return TextField(
              controller: searchController,
              focusNode: focusNode,
              onChanged: (value) {
                // Use controller's search functionality
                controller.searchClientList(value);
              },
              style: context.headlineSmall!.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Select Client',
                hintStyle: context.headlineSmall?.copyWith(
                  color: ColorConstants.tertiaryGrey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ColorConstants.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ColorConstants.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ColorConstants.primaryAppColor),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down,
                  color: ColorConstants.primaryAppColor,
                ),
              ),
            );
          },
          decorationBuilder: (context, child) {
            return Material(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              elevation: 4.0,
              shadowColor: Colors.black.withOpacity(0.2),
              child: child,
            );
          },
          loadingBuilder: (context) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: ColorConstants.primaryAppColor,
                ),
              ),
            );
          },
          errorBuilder: (context, error) {
            return _buildRetryWidget(
              controller: controller,
              context: context,
            );
          },
          emptyBuilder: (context) {
            // Show loading state
            if (controller.clientResponse.isLoading) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: ColorConstants.primaryAppColor,
                  ),
                ),
              );
            }

            // Show error state
            if (controller.clientResponse.isError) {
              return _buildRetryWidget(
                controller: controller,
                context: context,
              );
            }

            // Show empty state when no clients found
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No clients found',
                style: context.headlineSmall?.copyWith(
                  color: ColorConstants.tertiaryGrey,
                ),
              ),
            );
          },
          suggestionsCallback: (pattern) async {
            // Return empty list if still loading or error
            if (controller.clientResponse.isLoading) {
              return [];
            }

            if (controller.clientResponse.isError) {
              return [];
            }

            // Use controller's client list (already filtered by controller's search)
            return controller.clientList;
          },
          itemBuilder: (context, client) {
            // Use client's hash code to get consistent color index
            final colorIndex =
                (client.crn?.hashCode ?? client.name?.hashCode ?? 0).abs() % 7;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: ColorConstants.borderColor,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: getRandomBgColor(colorIndex),
                    child: Text(
                      client.name?.initials ?? '',
                      style: context.headlineMedium!.copyWith(
                        color: getRandomTextColor(colorIndex),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name ?? '',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .bodyMedium!
                              .copyWith(
                                color: ColorConstants.black,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        if (client.crn != null && client.crn != '-')
                          Text(
                            'CRN: ${client.crn}',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall!
                                .copyWith(
                                  color: ColorConstants.tertiaryGrey,
                                  fontSize: 12,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          onSelected: (client) {
            setState(() {
              selectedClient = client;
              controller.searchController.text = client.name ?? '';
            });
          },
        );
      },
    );
  }

  Widget _buildRetryWidget({
    required ClientListController controller,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RetryWidget(
        controller.clientResponse.message.isNotEmpty
            ? controller.clientResponse.message
            : 'Failed to load clients',
        onPressed: () {
          controller.queryClientList();
        },
      ),
    );
  }
}
