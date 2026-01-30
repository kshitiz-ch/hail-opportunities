import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';

class PayoutCommonUI {
  static Widget buildDetailSection({
    required Iterable<MapEntry<String, String>> data,
    String? title,
    String? emptyDataMessage,
  }) {
    return Builder(
      builder: (context) {
        final headlineStyle =
            Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w400,
                );
        final textStyle =
            Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  fontWeight: FontWeight.w500,
                );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotNullOrEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  title!,
                  style: headlineStyle.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            if (data.isNullOrEmpty)
              EmptyScreen(message: emptyDataMessage ?? 'Data not available')
            else
              ...List<Widget>.generate(
                (data.length / 2).ceil(),
                (row) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      children: List<Widget>.generate(
                        2,
                        (col) {
                          final effectiveIndex = row * 2 + col;
                          Color color = ColorConstants.black;
                          String key = '', value = '';
                          bool showToolTip = false;
                          if (effectiveIndex < data.length) {
                            key = data.elementAt(effectiveIndex).key;
                            value = data.elementAt(effectiveIndex).value;
                            showToolTip = key == 'Amount';
                            if (key == 'Status' &&
                                value == 'Payout Successful') {
                              color = ColorConstants.greenAccentColor;
                            }
                          }

                          return Expanded(
                            child: effectiveIndex < data.length
                                ? CommonUI.buildColumnTextInfo(
                                    title: key,
                                    subtitle: value,
                                    titleStyle: textStyle,
                                    subtitleStyle:
                                        headlineStyle.copyWith(color: color),
                                    titleSuffixIcon: showToolTip
                                        ? CommonUI.buildInfoToolTip(
                                            toolTipMessage:
                                                'Base Payout + GST - TDS')
                                        : null,
                                  )
                                : SizedBox(),
                          );
                        },
                      ),
                    ),
                  );
                },
              )
          ],
        );
      },
    );
  }
}
