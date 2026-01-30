import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/screens/store/demat_store/widgets/referral_term_condition_text.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class ReferralTermConditionBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                AutoRouter.of(context).popForced();
              },
              color: ColorConstants.black,
              iconSize: 24,
              icon: Icon(Icons.close),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleText(tcTitle, context),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: _buildDescriptionText(tcDescription, context),
                  ),
                  ..._buildBulletList(tcBulletPoints, context),
                  _buildDescriptionText(tcConfirmation, context),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: _buildTitleText(dosDontsTitle, context),
                  ),
                  _buildTitleText("Do's", context),
                  SizedBox(height: 12),
                  ..._buildBulletList(dosBulletPoints, context),
                  _buildTitleText("Don'ts:", context),
                  SizedBox(height: 12),
                  ..._buildBulletList(dontBulletPoints, context),
                  _buildDescriptionText(dosDontsConfirmation, context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionText(String description, BuildContext context) {
    return Text(
      description,
      style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
            color: ColorConstants.black,
            fontWeight: FontWeight.w500,
          ),
    );
  }

  Widget _buildTitleText(String title, BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
            color: ColorConstants.black,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  List<Widget> _buildBulletList(List<String> bulletList, BuildContext context) {
    return bulletList
        .map<Widget>(
          (text) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$bulletPointUnicode  ',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        fontWeight: FontWeight.w400,
                        color: ColorConstants.black,
                        height: 18 / 12,
                      ),
                ),
                Expanded(
                  child: Text(
                    '${text}',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.tertiaryBlack,
                        ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
