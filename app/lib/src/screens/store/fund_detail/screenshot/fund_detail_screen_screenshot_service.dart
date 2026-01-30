import 'dart:io';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_detail_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_score_controller.dart';
import 'package:app/src/screens/store/fund_detail/screenshot/fund_return_screenshot.dart';
import 'package:app/src/screens/store/fund_detail/screenshot/historical_graph_screenshot.dart';
import 'package:app/src/screens/store/fund_detail/screenshot/holding_analysis_screenshot.dart';
import 'package:app/src/screens/store/fund_detail/screenshot/remaining_screenshots.dart';
import 'package:app/src/screens/store/fund_detail/screenshot/return_rating_screenshot.dart';
import 'package:app/src/screens/store/fund_detail/screenshot/risk_meter_screenshot.dart';
import 'package:app/src/screens/store/fund_detail/screenshot/top_holdings_screenshot.dart';
import 'package:app/src/screens/store/fund_detail/screenshot/wealthy_score_screenshot.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:app/src/widgets/text/grid_data.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/instance_manager.dart';
import 'package:intl/intl.dart' as intl;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:screenshot/screenshot.dart';

class FundDetailScreenScreenshotService {
  final screenShotController = ScreenshotController();
  final fundDetailcontroller = Get.find<FundDetailController>();

  Future<void> captureScreenshot(BuildContext context) async {
    try {
      MixPanelAnalytics.trackWithAgentId(
        'CTA_Clicked',
        properties: {
          'CTA_Name': 'Fund Snapshot',
          'Source': 'Scheme Page',
          'Scheme_Name': fundDetailcontroller.fund?.displayName ?? '',
        },
      );

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ColorConstants.primaryAppColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Preparing a full-page fund snapshot for you…',
                      style: context.headlineSmall?.copyWith(
                        color: ColorConstants.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
      final maxWidth = SizeConfig().screenWidth!;
      final maxHeight = 5800.0;

      // Wait for all data to load
      await _waitForLoadingToComplete();

      // Capture screenshot
      final capturedImage = await screenShotController.captureFromLongWidget(
        InheritedTheme.captureAll(
          context,
          MediaQuery(
            data: MediaQuery.of(context),
            child: Material(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: prepareScreenShotWidget(context),
              ),
            ),
          ),
        ),
        delay: Duration(milliseconds: 1000),
        context: context,
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
      );

      // Save screenshot to file and convert to PDF
      if (capturedImage != null) {
        final directory = await getTemporaryDirectory();
        final screenshotDir = Directory('${directory.path}/screenshot');
        if (!await screenshotDir.exists()) {
          await screenshotDir.create(recursive: true);
        }
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        final imagePath =
            await File('${screenshotDir.path}/$fileName').create();
        print('imagePath: ${imagePath.path}');
        await imagePath.writeAsBytes(capturedImage);

        // Convert image to single-page PDF
        final pdfPath =
            await _convertImageToSinglePagePdf(capturedImage, directory);

        // Close loading indicator
        Navigator.of(context).pop();

        // Share PDF file
        await shareFiles(
          pdfPath,
          text: 'Check out this fund details!',
        );
      }
    } catch (error) {
      // Close loading indicator if still open
      Navigator.of(context).pop();

      print(error);
      // Show error message
      showToast(text: 'Fund snapshot error');
    }
  }

  Future<String> _convertImageToSinglePagePdf(
      Uint8List imageBytes, Directory tempDirectory) async {
    final pdf = pw.Document();

    // Create a PDF image from the screenshot bytes
    final image = pw.MemoryImage(imageBytes);

    // Add a page to the PDF (use pageFormat to fit the long image)
    // We calculate the custom page size based on the image dimensions to avoid white borders
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.undefined, // Let the content define the size
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
      ),
    );

    final fundName = fundDetailcontroller.fund?.schemeName ??
        fundDetailcontroller.fund?.displayName ??
        'fund';
    // Use day + short month format for filenames (e.g. 26Jan)
    final date = intl.DateFormat('ddMMM').format(DateTime.now());

    // Save the PDF to a temporary file
    final pdfFile =
        File('${tempDirectory.path}/Snapshot_${fundName}_${date}.pdf');
    await pdfFile.writeAsBytes(await pdf.save());

    return pdfFile.path;
  }

  Widget prepareScreenShotWidget(BuildContext context) {
    final fund = fundDetailcontroller.fund!;

    return ColoredBox(
      color: ColorConstants.white,
      child: Column(
        children: [
          SizedBox(height: 40),
          // _buildFundTitleAndCategory
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fund.displayName ?? '',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, right: 30, top: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${fundTypeDescription(fund.fundType)} ${fund.fundCategory != null ? "- ${fund.fundCategory}" : ""}',
                            maxLines: 2,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleSmall!
                                .copyWith(
                                  color: ColorConstants.tertiaryBlack,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ),
                        ),
                      ),
                      Text(
                        ' |  ',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleSmall!
                            .copyWith(color: ColorConstants.tertiaryBlack),
                      ),
                      CommonMfUI.buildMfRating(context, fund!)
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          fundOverviewSection(context, fund),
          getFundPerformanceScreenshotWidget(context),
          getFundScoreScreenshotWidget(context),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              children: [
                CommonMfUI.buildDisclaimerText(context),
                SizedBox(height: 10),
                Text(
                  'Investors are advised to consult their Legal /Tax advisors in regard to tax/legal implications relating to their investments in the scheme',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(
                          color: ColorConstants.tertiaryBlack,
                          fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 20),
              ],
            ),
          )
        ],
      ),
    );
    // Logic to prepare the widget for screenshot
  }

  Widget fundOverviewSection(BuildContext context, SchemeMetaModel fund) {
    final titleStyle = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          color: ColorConstants.tertiaryBlack,
        );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorConstants.black,
            );
    String navDisplay = '';
    if ((fund?.nav ?? 0) == 0) {
      navDisplay = "0";
    } else {
      navDisplay = (fund?.nav ?? 0).toStringAsFixed(4);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30.0,
      ).copyWith(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GridData(
                  title: "Latest NAV",
                  subtitle: fund.nav != null ? navDisplay : '-',
                  titleStyle: titleStyle,
                  subtitleStyle: subtitleStyle,
                ),
              ),
              Expanded(
                child: GridData(
                  subtitle: "${WealthyAmount.currencyFormat(
                    (fund?.folioOverview?.exists ?? false)
                        ? fund!.minAddDepositAmt
                        : fund!.minDepositAmt,
                    0,
                    showSuffix: false,
                  )}",
                  title: "Min Investment", titleStyle: titleStyle,
                  subtitleStyle: subtitleStyle,
                  // subtitle: "Min ${isTopUpPortfolio ? 'Addl ' : ''}Investment",
                ),
              ),
              Expanded(
                child: GridData(
                  subtitle: fund?.minSipDepositAmt != null
                      ? "${WealthyAmount.currencyFormat(
                          fund!.minSipDepositAmt,
                          0,
                          showSuffix: false,
                        )}"
                      : '-',
                  title: "Min Sip Amount",
                  titleStyle: titleStyle,
                  subtitleStyle: subtitleStyle,
                  // subtitle: "Min ${isTopUpPortfolio ? 'Addl ' : ''}Investment",
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GridData(
                  subtitle: fund?.expenseRatio != null
                      ? "${fund!.expenseRatio!.toStringAsFixed(2)}%"
                      : '-',
                  title: "Expense Ratio",
                  titleStyle: titleStyle,
                  subtitleStyle: subtitleStyle,
                ),
              ),
              Expanded(
                child: GridData(
                  title: "Exit Load",
                  subtitle: (fund.exitLoadPercentage?.isNotNullOrZero ?? false)
                      ? "${fund!.exitLoadPercentage!.toStringAsFixed(2)}%"
                      : "-",
                  titleStyle: titleStyle,
                  subtitleStyle: subtitleStyle,
                ),
              ),
              Expanded(
                child: GridData(
                  subtitle: fund?.aum != null
                      ? '${WealthyAmount.currencyFormat(fund?.aum, 2)} Cr'
                      : '-',
                  title: "Fund Size",
                  titleStyle: titleStyle,
                  subtitleStyle: subtitleStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getFundPerformanceScreenshotWidget(BuildContext context) {
    final selectedView = fundDetailcontroller.selectedGraphView;
    final fund = fundDetailcontroller.fund!;
    return Container(
      color: ColorConstants.secondaryWhite,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 350),
        // switchInCurve: Curves.ease,
        // switchOutCurve: Curves.ease,
        child: selectedView == FundGraphView.Historical
            ? Padding(
                padding: const EdgeInsets.only(top: 20),
                child: HistoricalGraphScreenshot()
                    .getHistoricalGraphScreenshotWidget(context),
              )
            : FundReturnCalculatorScreenshot()
                .getFundReturnCalculatorScreenshotWidget(context),
      ),
    );
  }

  Widget getFundScoreScreenshotWidget(BuildContext context) {
    final fundScoreController = Get.find<FundScoreController>();
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 30),
      child: Column(
        children: [
          // Return and Ratings
          ReturnRatingScreenshot()
              .getReturnRatingWidget(context, fundScoreController),
          SizedBox(height: 12),

          // Wealthy Score
          WealthyScoreScreenshot().getWealthyScoreWidget(
            context,
            fundScoreController,
          ),
          SizedBox(height: 12),

          // // Holding Analysis
          HoldingAnalysisScreenshot().getHoldingAnalysisWidget(
            context,
            fundScoreController,
          ),
          SizedBox(height: 12),

          // Top Holdings
          TopHoldingsScreenshot().getTopHoldingScreenshotWidget(
            context,
            fundScoreController,
          ),
          SizedBox(height: 12),

          // // Top Category Funds
          TopCategoryFundsScreenshot().getTopCategoryFundsWidget(
            context,
            fundScoreController,
          ),
          SizedBox(height: 12),

          // Benchmark Comparison
          if (fundScoreController.schemeData?.benchmarkTpid.isNotNullOrEmpty ??
              false)
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child:
                  PeerComparisonScreenshot().getPeerComparisonScreenshotWidget(
                context,
                fundScoreController,
              ),
            ),

          // // // Investment Objective
          InvestmentObjectiveScreenshot()
              .getInvestmentObjectiveScreenshotWidget(
            context,
            fundScoreController,
          ),
          SizedBox(height: 12),

          // Fund Manager Details
          if (fundScoreController.schemeData?.fundManager != null)
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: FundManagerDetailsScreenshot()
                  .getFundManagerDetailsScreenshotWidget(
                context,
                fundScoreController,
              ),
            ),

          // RiskMeter
          RiskMeterScreenshot().getRiskMeterScreenshotWidget(
            context,
            fundScoreController,
          ),

          // Tax Implication Details
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: TaxImplicationScreenshot().getTaxImplicationScreenshotWidget(
              context,
              fundScoreController,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _waitForLoadingToComplete() async {
    try {
      final controller = Get.find<FundScoreController>();

      int attempts = 0;
      // Wait for max 10 seconds (100 * 100ms)
      while (attempts < 100) {
        bool isAnyLoading =
            controller.fetchSchemeDataState == NetworkState.loading ||
                controller.fetchHoldingAnalysisState == NetworkState.loading ||
                controller.fetchStockHoldingState == NetworkState.loading ||
                controller.fetchTopCategoryFundState == NetworkState.loading ||
                controller.fetchBenchmarkReturnState == NetworkState.loading;

        if (!isAnyLoading) {
          return;
        }

        await Future.delayed(Duration(milliseconds: 100));
        attempts++;
      }
    } catch (e) {
      print("Error waiting for loading to complete: $e");
    }
  }
}
