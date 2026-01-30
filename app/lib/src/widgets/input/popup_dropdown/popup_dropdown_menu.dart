import 'dart:async';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/widgets/input/search_box.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class PopUpDropdownMenu extends StatefulWidget {
  const PopUpDropdownMenu({
    Key? key,
    this.items,
    this.onChanged,
    this.searchController,
    this.selectedValue,
    this.showSelectedValueSeparately = false,
    this.label,
    this.disableOthers = false,
  }) : super(key: key);

  final List<String?>? items;
  final void Function(String?, {int? index})? onChanged;
  final TextEditingController? searchController;
  final String? selectedValue;
  final String? label;
  final bool showSelectedValueSeparately;
  final bool disableOthers;

  @override
  State<PopUpDropdownMenu> createState() => _PopUpDropdownMenuState();
}

class _PopUpDropdownMenuState extends State<PopUpDropdownMenu> {
  List<String?>? itemsToShow = [];
  Timer? _debounce;
  bool hasSearchInput = false;

  void initState() {
    itemsToShow = widget.items;
    if (widget.searchController != null) {
      hasSearchInput = true;

      widget.searchController!.addListener(
        () {
          if (_debounce?.isActive ?? false) {
            _debounce!.cancel();
          }

          _debounce = Timer(
            const Duration(milliseconds: 500),
            () {
              if (this.mounted) {
                if (widget.searchController!.text.isNotEmpty) {
                  List filteredItems = widget.items!
                      .where((e) => e!.toLowerCase().contains(
                          widget.searchController!.text.toLowerCase()))
                      .toList();
                  if (widget.searchController!.text.isNotEmpty) {
                    if (filteredItems.isEmpty) {
                      setState(() {
                        if (widget.disableOthers) {
                          itemsToShow = [];
                          if (widget.label?.toLowerCase() == 'city') {
                            itemsToShow = [
                              widget.searchController!.text.toCapitalized()
                            ];
                          }
                        } else {
                          itemsToShow = ["Others"];
                        }
                      });
                    } else {
                      setState(() {
                        itemsToShow = filteredItems as List<String?>?;
                      });
                    }
                  }
                } else {
                  setState(() {
                    itemsToShow = widget.items;
                  });
                }
              }
            },
          );
        },
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).popForced();
      },
      child: Container(
        color: Colors.black.withOpacity(0.6),
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(vertical: 80, horizontal: 30),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: widget.searchController != null
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              if (widget.searchController != null)
                InkWell(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 12, right: 12, top: 20, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: SearchBox(
                      labelText: "Search your ${widget.label ?? "City"}",
                      textEditingController: widget.searchController,
                      prefixIcon: Icon(
                        Icons.search,
                        color: ColorConstants.tertiaryBlack,
                      ),
                    ),
                  ),
                ),
              if (widget.showSelectedValueSeparately) _buildSelectedItem(),
              if (itemsToShow != null && itemsToShow!.length > 0)
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: widget.searchController != null
                          ? BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            )
                          : BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: itemsToShow!.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (widget.showSelectedValueSeparately &&
                            itemsToShow![index] == widget.selectedValue) {
                          return SizedBox();
                        }

                        if (itemsToShow![index] == widget.selectedValue) {
                          return _buildSelectedItem();
                        }

                        return InkWell(
                          onTap: () {
                            final effectiveIndex = widget.items?.indexWhere(
                                (element) =>
                                    element?.toLowerCase() ==
                                    itemsToShow![index]?.toLowerCase());
                            widget.onChanged!(
                              itemsToShow![index],
                              index: effectiveIndex,
                            );
                            AutoRouter.of(context).popForced();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 20),
                            child: Text(
                              itemsToShow![index]!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(
                                      color: ColorConstants.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "No options found!",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(color: ColorConstants.black, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedItem() {
    if (widget.selectedValue.isNullOrEmpty) {
      return SizedBox();
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                widget.selectedValue!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Icon(
            Icons.done,
            color: ColorConstants.black,
          )
        ],
      ),
    );
  }
}
