import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:collection/collection.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:flutter/material.dart';

class FilterOptions extends StatelessWidget {
  const FilterOptions({
    Key? key,
    required this.options,
    required this.currentSelectedOptions,
    required this.onOptionSelect,
    required this.apiResponse,
    required this.onRetry,
  }) : super(key: key);

  final List<Choice> options;
  final List<Choice>? currentSelectedOptions;
  final Function(Choice) onOptionSelect;
  final ApiResponse? apiResponse;
  final Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (apiResponse?.state == NetworkState.loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (apiResponse?.state == NetworkState.error) {
      return RetryWidget(
        apiResponse?.message,
        onPressed: onRetry,
      );
    }

    if (apiResponse?.state == NetworkState.loaded && options.isEmpty) {
      return EmptyScreen(
        message: 'No options found',
      );
    }

    return Scrollbar(
      thumbVisibility: true,
      radius: Radius.circular(10),
      child: ListView.builder(
        physics: ClampingScrollPhysics(),
        // controller: controller.categoryOptions.length,
        shrinkWrap: true,
        itemCount: options.length,
        itemBuilder: (BuildContext context, int index) {
          Choice choice = options[index];
          bool isSelected = (currentSelectedOptions ?? []).firstWhereOrNull(
                  (element) => element.value == choice.value) !=
              null;

          if (choice.displayName?.isNullOrEmpty ?? false) {
            return SizedBox();
          }

          return InkWell(
            onTap: () {
              onOptionSelect(choice);
            },
            child: Padding(
              padding: const EdgeInsets.only(
                left: 30.0,
                right: 30.0,
                bottom: 12,
                top: 12,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.done,
                    color: isSelected ? ColorConstants.black : Colors.white,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(
                      choice.displayName ?? '',
                      maxLines: 3,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            fontWeight: FontWeight.w500,
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
        },
      ),
    );
  }
}
