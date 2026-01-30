import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/nominee_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_nominee_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_utils/get_utils.dart';

class NomineeBreakdownCard extends StatelessWidget {
  const NomineeBreakdownCard(
      {Key? key, required this.nomineesList, required this.nomineeType})
      : super(key: key);

  final List<ClientNomineeModel> nomineesList;
  final NomineeType nomineeType;

  @override
  Widget build(BuildContext context) {
    if (nomineesList.isNullOrEmpty) {
      return SizedBox();
    }

    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ColorConstants.primaryAppv3Color,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nomineeType == NomineeType.MF ? 'Mutual Funds' : 'Trading',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .displayMedium!
                      .copyWith(fontSize: 17),
                ),
                if (nomineeType == NomineeType.MF)
                  ClickableText(
                    text: 'Edit',
                    fontSize: 14,
                    fontHeight: 1,
                    onClick: () {
                      AutoRouter.of(context).push(
                        ClientNomineeBreakdownRoute(nomineeType: nomineeType),
                      );
                    },
                  )
              ],
            ),
          ),
          Divider(
            color: ColorConstants.borderColor,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: nomineesList.length,
              separatorBuilder: (context, index) => SizedBox(height: 25),
              itemBuilder: (context, index) {
                ClientNomineeModel nominee = nomineesList[index];
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nominee.name ?? 'NA',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineLarge!
                                .copyWith(fontSize: 12),
                          ),
                          Text(
                            getRelationshipStatus(nominee.relationship) ?? 'NA',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleMedium!
                                .copyWith(color: ColorConstants.tertiaryBlack),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "${nominee.percentage ?? '0'}%",
                        style: Theme.of(context).primaryTextTheme.bodyMedium,
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          if (nomineeType == NomineeType.MF)
            InkWell(
              onTap: () {
                AutoRouter.of(context).push(
                  ClientNomineeBreakdownRoute(
                    nomineeType: nomineeType,
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(AllImages().plusRoundedIcon),
                    SizedBox(width: 9),
                    Text(
                      'Add Nominee',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                              fontSize: 12,
                              color: ColorConstants.primaryAppColor),
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
