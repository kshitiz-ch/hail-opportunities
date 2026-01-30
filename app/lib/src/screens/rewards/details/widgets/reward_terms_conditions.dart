import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:core/modules/rewards/models/reward_model.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;

class RewardTermsConditions extends StatelessWidget {
  final RewardModel? rewardDetails;

  const RewardTermsConditions({Key? key, this.rewardDetails}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final bulletListText = getBulletListText(rewardDetails?.conditions);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 30).copyWith(bottom: 14),
          child: Text(
            'Terms & Conditions ',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ColorConstants.black,
                ),
          ),
        ),
      ]..addAll(
          bulletListText
              .map<Widget>(
                (text) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22)
                      .copyWith(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$bulletPointUnicode  ',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
                              fontWeight: FontWeight.w400,
                              color: ColorConstants.tertiaryBlack,
                              height: 18 / 12,
                            ),
                      ),
                      Expanded(
                        child: Text(
                          '${text}',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                fontWeight: FontWeight.w400,
                                color: ColorConstants.tertiaryBlack,
                                height: 18 / 12,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
    );
  }

  List<String> getBulletListText(String? html) {
    final document = parse(html);
    final liNodeList = document.querySelectorAll('li');
    return liNodeList.map<String>((liNode) => liNode.text).toList();
  }
}
