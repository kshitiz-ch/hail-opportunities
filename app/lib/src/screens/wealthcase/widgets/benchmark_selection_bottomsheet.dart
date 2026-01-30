import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/wealthcase/wealthcase_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/wealthcase/models/wealthcase_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BenchmarkSelectionBottomSheet extends StatelessWidget {
  final WealthcaseModel wealthcaseModel;

  const BenchmarkSelectionBottomSheet({Key? key, required this.wealthcaseModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WealthcaseController>(
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: ColorConstants.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 24),
                decoration: BoxDecoration(
                  color: ColorConstants.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
                width: 40,
                height: 4,
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Select a benchmark to compare with',
                  style: context.headlineMedium?.copyWith(
                    color: ColorConstants.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Benchmark options
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: wealthcaseModel.benchmarks?.length ?? 0,
                  itemBuilder: (context, index) {
                    final benchmark = wealthcaseModel.benchmarks![index];
                    final isSelected =
                        controller.selectedBenchmark?.name == benchmark.name;

                    return GestureDetector(
                      onTap: () {
                        controller.setSelectedBenchmark(benchmark);
                        AutoRouter.of(context).pop();
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Radio button
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? ColorConstants.primaryAppColor
                                      : ColorConstants.borderColor,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: ColorConstants.primaryAppColor,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),

                            SizedBox(width: 16),

                            // Benchmark info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Benchmark name
                                  Text(
                                    (benchmark.name ?? 'Unknown Benchmark')
                                        .toTitleCase(),
                                    style: context.headlineSmall?.copyWith(
                                      color: ColorConstants.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
