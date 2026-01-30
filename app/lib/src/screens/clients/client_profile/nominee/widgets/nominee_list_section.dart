import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_nominee_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NomineeListSection extends StatelessWidget {
  const NomineeListSection({Key? key, required this.nomineesList})
      : super(key: key);

  final List<ClientNomineeModel> nomineesList;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Nominee Details',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineLarge!
                .copyWith(fontSize: 14),
          ),
          SizedBox(height: 15),
          ListView.separated(
            padding: EdgeInsets.only(bottom: 100),
            itemCount: nomineesList.length,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (context, index) => SizedBox(height: 16),
            itemBuilder: (context, index) {
              ClientNomineeModel nominee = nomineesList[index];
              return _buildNomineeCard(context, nominee);
            },
          )
        ],
      ),
    );
  }

  Widget _buildNomineeCard(BuildContext context, ClientNomineeModel nominee) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstants.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nominee.name ?? 'NA',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineLarge!
                      .copyWith(fontSize: 14),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: ColorConstants.borderColor,
                  ),
                ),
                child: Text(
                  getRelationshipStatus(nominee.relationship) ?? 'NA',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(color: ColorConstants.tertiaryBlack),
                ),
              )
            ],
          ),
          SizedBox(height: 17),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (nominee.dob != null)
                Expanded(
                  child: CommonUI.buildColumnTextInfo(
                      title: 'Date of Birth',
                      titleStyle: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                              color: ColorConstants.tertiaryBlack,
                              fontSize: 12),
                      subtitle: DateFormat('dd MMM yyyy').format(nominee.dob!),
                      subtitleStyle: Theme.of(context)
                          .primaryTextTheme
                          .headlineLarge!
                          .copyWith(fontSize: 12)),
                ),
              Expanded(
                child: _buildIdInfo(context, nominee),
              ),
              TextButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                  alignment: Alignment.bottomRight,
                ),
                child: Text('Edit'),
                onPressed: () {
                  AutoRouter.of(context).push(
                    ClientNomineeFormRoute(nominee: nominee),
                  );
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildIdInfo(BuildContext context, ClientNomineeModel nominee) {
    String title = 'ID';
    String subtitle = 'NA';

    switch (nominee.nomineeIdType?.toLowerCase()) {
      case 'pan':
        title = 'PAN';
        subtitle = nominee.panNumber ?? 'NA';
        break;
      case 'aadhaar':
        title = 'Aadhaar';
        subtitle = nominee.aadhaarNumber != null
            ? 'XXXXXXXX${nominee.aadhaarNumber}'
            : 'NA';
        break;
      case 'passport':
        title = 'Passport';
        subtitle = nominee.passportNumber ?? 'NA';
        break;
      default:
        if (nominee.panNumber?.isNotEmpty ?? false) {
          title = 'PAN';
          subtitle = nominee.panNumber!;
        } else if (nominee.aadhaarNumber?.isNotEmpty ?? false) {
          title = 'Aadhaar';
          subtitle = 'XXXXXXXX${nominee.aadhaarNumber}';
        } else if (nominee.passportNumber?.isNotEmpty ?? false) {
          title = 'Passport';
          subtitle = nominee.passportNumber!;
        }
        break;
    }

    return CommonUI.buildColumnTextInfo(
        title: title,
        titleStyle: Theme.of(context)
            .primaryTextTheme
            .headlineSmall!
            .copyWith(color: ColorConstants.tertiaryBlack, fontSize: 12),
        subtitle: subtitle,
        subtitleStyle: context.headlineLarge!.copyWith(fontSize: 12));
  }
}
