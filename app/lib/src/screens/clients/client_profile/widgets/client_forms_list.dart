import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';

class ClientFormsList extends StatelessWidget {
  final Client client;
  List<Map<String, dynamic>> forms = [];
  ClientFormsList({Key? key, required this.client}) : super(key: key) {
    forms = [
      {
        "title": "Personal Details",
        "route": ClientPersonalFormRoute(),
      },
      {
        "title": "Family Details",
        "route": ClientFamilyDetailRoute(client: client),
      },
      {
        "title": "Demat Details",
        "route": ClientDematDetailRoute(client: client),
      },
      {
        "title": "User Address",
        "route": ClientAddressRoute(client: client),
      },
      {
        "title": "Bank Account Details",
        "route": ClientBankListRoute(),
      },
      {
        "title": "Nominee Details",
        "route": ClientNomineeListRoute(),
      },
      {
        "title": "Mandate Details",
        "route": ClientMandateListRoute(),
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      padding: EdgeInsets.all(20).copyWith(bottom: 0),
      decoration: BoxDecoration(
        color: ColorConstants.primaryAppv3Color,
        borderRadius: BorderRadius.circular(16),
        // color: Color
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Other Details',
            style: Theme.of(context)
                .primaryTextTheme
                .displayLarge!
                .copyWith(fontSize: 16),
          ),
          SizedBox(height: 10),
          ListView.separated(
            itemCount: forms.length,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return _buildFormTile(
                  context, forms[index]["title"], forms[index]["route"]);
            },
            separatorBuilder: (context, index) {
              return Divider(
                color: ColorConstants.lightPrimaryAppColor.withOpacity(0.2),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildFormTile(
      BuildContext context, String title, PageRouteInfo<dynamic>? route) {
    return InkWell(
      onTap: () {
        MixPanelAnalytics.trackWithAgentId(
          title.toSnakeCase()!,
          screen: 'user_profile_details',
          screenLocation: 'other_details',
        );

        if (route != null) {
          AutoRouter.of(context).push(route);
        } else {
          showToast(text: "This form is not available");
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Image.asset(
              AllImages().clientDefaultFormIcon,
              width: 21,
            ),
            SizedBox(width: 21),
            Text(
              title,
              style: Theme.of(context)
                  .primaryTextTheme
                  .displayMedium!
                  .copyWith(fontSize: 14),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: ColorConstants.black,
              size: 14,
            )
          ],
        ),
      ),
    );
  }
}
