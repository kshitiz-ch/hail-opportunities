import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/advisor/models/soa_folio_model.dart';
import 'package:flutter/material.dart';

class FolioCard extends StatelessWidget {
  final SoaFolioModel soaFolioModel;
  final String? selectedFolio;
  final Function onSelect;

  TextStyle? textStyle;
  late bool allowSoaDownload;

  FolioCard({
    required this.soaFolioModel,
    required this.selectedFolio,
    required this.onSelect,
  }) {
    allowSoaDownload = soaFolioModel.soaDownloadAllowed == true;
  }

  @override
  Widget build(BuildContext context) {
    textStyle = Theme.of(context)
        .primaryTextTheme
        .headlineSmall
        ?.copyWith(color: ColorConstants.tertiaryBlack);
    return Row(
      children: [
        SizedBox(
          height: 15,
          width: 15,
          child: Radio(
              activeColor: ColorConstants.primaryAppColor,
              value: allowSoaDownload ? soaFolioModel.folioNumber : '',
              groupValue: allowSoaDownload ? selectedFolio : '',
              onChanged: allowSoaDownload ? (dynamic value) => onTap() : null),
        ),
        SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              onTap();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: ColorConstants.borderColor,
                ),
                color: allowSoaDownload
                    ? ColorConstants.primaryCardColor
                    : ColorConstants.lightGrey.withOpacity(0.7),
              ),
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CommonUI.buildColumnTextInfo(
                          title: 'AMC',
                          gap: 5,
                          subtitleMaxLength: 2,
                          subtitle: soaFolioModel.amc ?? '-',
                          titleStyle: textStyle,
                          subtitleStyle: allowSoaDownload
                              ? textStyle?.copyWith(color: ColorConstants.black)
                              : textStyle,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: CommonUI.buildColumnTextInfo(
                          title: 'Folio No',
                          gap: 5,
                          subtitleMaxLength: 2,
                          subtitle: soaFolioModel.folioNumber ?? '-',
                          titleStyle: textStyle,
                          subtitleStyle: allowSoaDownload
                              ? textStyle?.copyWith(color: ColorConstants.black)
                              : textStyle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CommonUI.buildColumnTextInfo(
                          title: 'Invested Value',
                          gap: 5,
                          subtitle: WealthyAmount.currencyFormat(
                              soaFolioModel.totalAmount, 2),
                          titleStyle: textStyle,
                          subtitleStyle: allowSoaDownload
                              ? textStyle?.copyWith(color: ColorConstants.black)
                              : textStyle,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: CommonUI.buildColumnTextInfo(
                          title: 'Current Value',
                          gap: 5,
                          subtitle: WealthyAmount.currencyFormat(
                              soaFolioModel.totalCurrentValue, 2),
                          titleStyle: textStyle,
                          subtitleStyle: allowSoaDownload
                              ? textStyle?.copyWith(color: ColorConstants.black)
                              : textStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void onTap() {
    if (allowSoaDownload) {
      onSelect();
    } else {
      showToast(
        text:
            "Statement of Account (SOA) download for folios of AMC’s registered with CAMS is currently unavailable",
      );
    }
  }
}
