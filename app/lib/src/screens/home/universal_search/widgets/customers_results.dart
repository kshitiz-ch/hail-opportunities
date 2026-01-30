import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/common/models/universal_search_model.dart';
import 'package:flutter/material.dart';

class CustomersResults extends StatelessWidget {
  const CustomersResults({
    Key? key,
    required this.clientResult,
  }) : super(key: key);

  final UniversalSearchDataModel clientResult;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            clientResult.meta?.displayName ?? 'Clients',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 16),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            itemCount: clientResult.data!.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return SizedBox(height: 20);
              // return Padding(
              //   padding: EdgeInsets.symmetric(vertical: 14),
              //   child: Divider(color: ColorConstants.borderColor),
              // );
            },
            itemBuilder: (context, index) {
              Client client = clientResult.data![index];

              return InkWell(
                onTap: () {
                  AutoRouter.of(context).push(
                    ClientDetailRoute(clientId: client.id),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: getRandomBgColor(index % 7),
                      child: Center(
                        child: Text(
                          client.name!.initials,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .displayMedium!
                              .copyWith(
                                color: getRandomTextColor(index % 7),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                        ),
                      ),
                      radius: 16,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 12, right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (client.name ?? '-').toTitleCase(),
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(fontWeight: FontWeight.w400),
                            ),
                            if (client.crn.isNotNullOrEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      'CRN ${(client.crn ?? '-').toUpperCase()}',
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .titleLarge!
                                          .copyWith(
                                              color:
                                                  ColorConstants.tertiaryBlack),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (client.panUsageType.isNotNullOrEmpty)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: ColorConstants.borderColor,
                          ),
                        ),
                        child: Text(
                          getPanUsageDescription(client.panUsageType!),
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(color: ColorConstants.tertiaryBlack),
                        ),
                      )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    // return Padding(
    //   padding: const EdgeInsets.only(bottom: 20.0),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(
    //         clientResult.meta?.displayName ?? 'Clients',
    //         style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
    //               fontWeight: FontWeight.w600,
    //             ),
    //       ),
    //       SizedBox(height: 16),
    //       Container(
    //         height: 100,
    //         padding: EdgeInsets.only(bottom: 16),
    //         // height: 100,
    //         child: OverflowBox(
    //           alignment: Alignment.topLeft,
    //           minHeight: 100,
    //           maxHeight: 120,
    //           child: ListView.builder(
    //             scrollDirection: Axis.horizontal,
    //             shrinkWrap: true,
    //             // viewportFraction: 0.5,
    //             itemCount: clientResult.data!.length,
    //             itemBuilder: (context, index) {
    //               Client client = clientResult.data![index];

    //               return Container(
    //                 margin: EdgeInsets.only(right: 20),
    //                 constraints: BoxConstraints(maxWidth: 80),
    //                 // padding: const EdgeInsets.symmetric(horizontal: 6.5),
    //                 // decoration: BoxDecoration(
    //                 //     borderRadius: BorderRadius.circular(21),
    //                 //     color: ColorConstants.primaryCardColor),
    //                 child: InkWell(
    //                   onTap: () {
    //                     AutoRouter.of(context).push(
    //                       ClientDetailRoute(clientId: client.id),
    //                     );
    //                   },
    //                   child: Column(
    //                     children: [
    //                       CircleAvatar(
    //                         backgroundColor: getRandomBgColor(index % 7),
    //                         child: Center(
    //                           child: Text(
    //                             client.name!.initials,
    //                             style: Theme.of(context)
    //                                 .primaryTextTheme
    //                                 .displayMedium!
    //                                 .copyWith(
    //                                   color: getRandomTextColor(index % 7),
    //                                   fontSize: 20,
    //                                   fontWeight: FontWeight.w500,
    //                                   height: 1.4,
    //                                 ),
    //                           ),
    //                         ),
    //                         radius: 20,
    //                       ),
    //                       SizedBox(height: 8),
    //                       Container(
    //                         constraints: BoxConstraints(maxHeight: 60),
    //                         child: Text.rich(
    //                           TextSpan(
    //                             text: (client.name ?? '-').toTitleCase(),
    //                             style: Theme.of(context)
    //                                 .primaryTextTheme
    //                                 .headlineSmall!
    //                                 .copyWith(
    //                                   overflow: TextOverflow.ellipsis,
    //                                 ),
    //                           ),
    //                           textAlign: TextAlign.center,
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               );
    //             },
    //           ),
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }
}
