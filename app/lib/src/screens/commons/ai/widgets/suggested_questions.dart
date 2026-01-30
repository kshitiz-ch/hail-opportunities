import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';

class SuggestedQuestions extends StatelessWidget {
  final List<String> questions;
  final void Function(String) onQuestionTap;

  const SuggestedQuestions({
    Key? key,
    required this.questions,
    required this.onQuestionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: 24),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Suggested Questions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ColorConstants.darkGrey,
              ),
            ),
          ),
          SizedBox(
            height: 60,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: questions.map((question) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _SuggestedQuestionItem(
                      question: question,
                      onTap: () => onQuestionTap(question),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedQuestionItem extends StatelessWidget {
  final String question;
  final VoidCallback onTap;

  const _SuggestedQuestionItem({
    Key? key,
    required this.question,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 230),
      decoration: BoxDecoration(
        color: ColorConstants.aiSuggestionBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorConstants.borderColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AllImages().aiAssistantIconLight,
                  width: 16,
                  height: 16,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorConstants.black,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
