import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/card/proposal_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:flutter/material.dart';

class SimilarProposalsList extends StatefulWidget {
  final onClickHandler;
  final Client? client;
  final List<ProposalModel>? similarProposalList;
  final Widget? submitButtonWidget;

  SimilarProposalsList(
      {this.onClickHandler,
      this.client,
      this.similarProposalList,
      this.submitButtonWidget});

  @override
  _SimilarProposalsListState createState() => _SimilarProposalsListState();
}

class _SimilarProposalsListState extends State<SimilarProposalsList> {
  ScrollController openScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 50, bottom: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 30,
            ),
            child: Text(
              'Similar Proposals',
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30).copyWith(top: 25.0),
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: ColorConstants.lightRedColor),
            child: Text(
              'You have shared similar proposals with ${widget.client!.name ?? ""} in the past, to avoid unintended debits please considering resharing those',
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: ColorConstants.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            constraints: BoxConstraints(
              maxHeight: widget.similarProposalList!.length > 1
                  ? MediaQuery.of(context).size.height / 2.1
                  : 250,
            ),
            color: ColorConstants.white,
            child: ListView.builder(
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              scrollDirection: Axis.vertical,
              itemCount: widget.similarProposalList!.length,
              itemBuilder: (_, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ProposalCard(
                    proposal: widget.similarProposalList![index],
                    index: index,
                    showProposalActions: false,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ActionButton(
                    text: 'Cancel',
                    onPressed: () {
                      AutoRouter.of(context).popForced();
                    },
                    bgColor: ColorConstants.secondaryAppColor,
                    borderRadius: 51,
                    margin: EdgeInsets.zero,
                    textStyle: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.primaryAppColor,
                          fontSize: 16,
                        ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: widget.submitButtonWidget != null
                      ? widget.submitButtonWidget!
                      : SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
