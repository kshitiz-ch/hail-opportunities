import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ResourcesSortOption {
  newestFirst,
  // mostViewedFirst,
  oldestFirst,
}

extension ResourcesSortOptionExtension on ResourcesSortOption {
  String get displayName {
    switch (this) {
      case ResourcesSortOption.newestFirst:
        return 'Newest first';
      // case ResourcesSortOption.mostViewedFirst:
      //   return 'Most viewed first';
      case ResourcesSortOption.oldestFirst:
        return 'Oldest first';
    }
  }
}

class ResourcesSortList extends StatelessWidget {
  const ResourcesSortList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GetBuilder<AppResourcesController>(
        builder: (controller) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioButtons(
                    spacing: 30,
                    runSpacing: 0,
                    direction: Axis.vertical,
                    textStyle: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.w400),
                    itemBuilder: (BuildContext context, value, index) {
                      value = value as ResourcesSortOption;
                      return Text(
                        value.displayName,
                        style: context.headlineSmall?.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    },
                    items: ResourcesSortOption.values,
                    selectedValue: controller.tempSortSelected,
                    onTap: (value) {
                      controller.updateTempSorting(value);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
