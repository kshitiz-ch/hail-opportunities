import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/controllers/advisor/newsletter_controller.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewsletterYearDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewsLetterController>(
      builder: (controller) {
        return Align(
          child: InkWell(
            onTap: () {
              CommonUI.showBottomSheet(
                context,
                child: NewsletterYearDropdownBottomSheet(),
                isScrollControlled: false,
              );
            },
            child: Container(
              height: 35,
              constraints: BoxConstraints(maxWidth: 150),
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorConstants.primaryAppColor,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: MarqueeWidget(
                      child: Text(
                        'Year : ${controller.selectedYear}',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(color: ColorConstants.primaryAppColor),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: ColorConstants.primaryAppColor,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class NewsletterYearDropdownBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewsLetterController>(
      builder: (controller) {
        if (controller.newsLetterYearsReponse.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height - 100),
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose year of newsletter',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(fontSize: 18),
              ),
              SizedBox(height: 40),
              Flexible(
                child: _buildYearList(controller, context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildYearList(
    NewsLetterController controller,
    BuildContext context,
  ) {
    List<int> yearOptions =
        controller.newsletterYears[controller.selectedTab] ?? [];

    if (yearOptions.isEmpty) {
      final startYear = controller.selectedTab == 'Money Order' ? 2019 : 2024;
      final endYear = DateTime.now().year;
      yearOptions = List<int>.generate(
          endYear - startYear + 1, (index) => endYear - index).toList();
    }

    return ListView(
      shrinkWrap: true,
      children: yearOptions
          .map(
            (year) => _buildYearTile(
              context,
              displayName: year.toString(),
              isSelected: year == controller.selectedYear,
              onSelect: () {
                controller.selectedYear = year;
                controller.getNewsletters();
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildYearTile(
    BuildContext context, {
    required String displayName,
    required bool isSelected,
    required void Function() onSelect,
  }) {
    return InkWell(
      onTap: () {
        onSelect();
        AutoRouter.of(context).popForced();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(right: 8),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorConstants.primaryAppColor
                    : ColorConstants.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? ColorConstants.primaryAppColor
                      : ColorConstants.lightGrey,
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.done,
                  size: 10,
                  color: ColorConstants.white,
                ),
              ),
            ),
            Expanded(
              child: Text(
                displayName,
                style:
                    Theme.of(context).primaryTextTheme.displayMedium!.copyWith(
                          fontSize: 16,
                          color: isSelected
                              ? ColorConstants.black
                              : ColorConstants.tertiaryBlack,
                        ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
