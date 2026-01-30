import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/onboarding/onboarding_question_controller.dart';
import 'package:core/modules/authentication/models/onboarding_question_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class CityQuestion extends StatelessWidget {
  const CityQuestion({
    Key? key,
    required this.cityQuestion,
    required this.controller,
    required this.isNotFirstQuestion,
  }) : super(key: key);

  final OnboardingQuestionModel cityQuestion;
  final OnboardingQuestionController controller;
  final bool isNotFirstQuestion;

  @override
  Widget build(BuildContext context) {
    InputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        width: 1,
        color: Color(0xFFEAEAEA)..withOpacity(0.5),
      ),
    );

    TextStyle textStyle = Theme.of(context).primaryTextTheme.headlineSmall!;

    return TypeAheadField(
      debounceDuration: Duration(milliseconds: 500),
      controller: controller.citySearchController,
      suggestionsController: controller.citySuggestionController,
      builder: (context, searchController, focusNode) {
        return TextField(
          autofocus: false,
          controller: searchController,
          focusNode: focusNode,
          style: textStyle,
          decoration: InputDecoration(
            hintText: 'Enter your City',
            contentPadding: EdgeInsets.symmetric(horizontal: 18.0),
            hintStyle: textStyle.copyWith(color: ColorConstants.secondaryBlack),
            border: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
          onChanged: (value) {
            controller.updateCustomAnswer(cityQuestion, value);
          },
        );
      },
      emptyBuilder: (value) {
        return SizedBox();
      },
      // transitionBuilder: (context, suggestionsBox, controller) {
      //   return suggestionsBox;
      // },
      decorationBuilder: (context, child) {
        return Material(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          shadowColor: ColorConstants.darkBlack.withOpacity(0.6),
          elevation: 2.0,
          child: child,
        );
      },
      suggestionsCallback: (pattern) async {
        if (pattern.isNotNullOrEmpty) {
          return controller.searchCity(pattern);
        }
        return [];
      },
      itemBuilder: (context, suggestion) {
        String? city = suggestion as String?;

        if (suggestion.isNullOrEmpty) {
          return SizedBox();
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 12.0),
          color: Colors.white,
          child: Text(
            city!,
            style: textStyle.copyWith(color: ColorConstants.tertiaryBlack),
          ),
        );
      },
      // onSuggestionsBoxToggle: (isVisible) {
      //   if (isNotFirstQuestion) {
      //     controller.onCityQuestionFocus(isVisible);
      //   }
      // },
      onSelected: (suggestion) {
        String citySelected = suggestion as String;
        controller.citySearchController.text = citySelected;
        controller.updateCustomAnswer(cityQuestion, citySelected);
      },
    );
  }
}
