import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/input/radio_buttons.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SelectFolioBottomSheet extends StatefulWidget {
  final Function()? onAddNewFolio;
  final Function(FolioModel)? onSelectFolio;
  final List<FolioModel> folioOverviews;
  final String? defaultFolioNumber;

  const SelectFolioBottomSheet({
    Key? key,
    this.onAddNewFolio,
    this.onSelectFolio,
    required this.folioOverviews,
    this.defaultFolioNumber,
  }) : super(key: key);

  @override
  State<SelectFolioBottomSheet> createState() => _SelectFolioBottomSheetState();
}

class _SelectFolioBottomSheetState extends State<SelectFolioBottomSheet> {
  String? selectedFolioNumber;

  @override
  void initState() {
    super.initState();
    //* initialize appsflyer SDK

    if (widget.defaultFolioNumber != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedFolioNumber = widget.defaultFolioNumber;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: context.height - 100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Folio',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Choose #Folio for this investment',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.tertiaryBlack,
                          ),
                    ),
                  ],
                ),
                CommonUI.bottomsheetCloseIcon(context)
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: RadioButtons(
                  items:
                      widget.folioOverviews.map((x) => x.folioNumber).toList(),
                  direction: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  selectedValue: selectedFolioNumber,
                  spacing: 30,
                  runSpacing: 30,
                  itemBuilder: (context, value, index) {
                    FolioModel folio = widget.folioOverviews[index];
                    bool isLastItem = index == widget.folioOverviews.length - 1;
                    return Container(
                      padding:
                          const EdgeInsets.only(left: 10, bottom: 25, top: 0),
                      width: context.width - 80,
                      decoration: BoxDecoration(
                        border: !isLastItem
                            ? Border(
                                bottom: BorderSide(
                                    color: ColorConstants.borderColor),
                              )
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Folio #${folio.folioNumber}",
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                "${folio.units} Units",
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: ColorConstants.tertiaryGrey,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                width: 1,
                                color: ColorConstants.borderColor,
                                height: 15,
                              ),
                              Text(
                                "${WealthyAmount.currencyFormat(folio.currentValue, 2)}",
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: ColorConstants.tertiaryGrey,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                  onTap: (value) {
                    setState(() {
                      selectedFolioNumber = value;
                    });
                    // controller.updateAdditionMethod(value);
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ActionButton(
                    textStyle: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.primaryAppColor,
                        ),
                    text: '+ Add New',
                    margin: EdgeInsets.zero,
                    bgColor: ColorConstants.primaryAppv3Color,
                    onPressed: widget.onAddNewFolio,
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: ActionButton(
                    text: 'Proceed',
                    isDisabled: selectedFolioNumber == null,
                    margin: EdgeInsets.zero,
                    onPressed: () {
                      FolioModel? selectedFolio;
                      for (FolioModel folio in widget.folioOverviews) {
                        if (folio.folioNumber == selectedFolioNumber) {
                          selectedFolio = folio;
                          break;
                        }
                      }

                      if (widget.onSelectFolio != null &&
                          selectedFolio != null) {
                        widget.onSelectFolio!(selectedFolio);
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
