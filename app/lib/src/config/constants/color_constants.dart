import 'package:flutter/material.dart';

Color hexToColor(String hex) {
  assert(RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex),
      'hex color must be #rrggbb or #rrggbbaa');

  return Color(
    int.parse(hex.substring(1), radix: 16) +
        (hex.length == 7 ? 0xff000000 : 0x00000000),
  );
}

List<Color> colorsData = [
  hexToColor('#434cab'),
  hexToColor('#ff8952'),
  hexToColor('#a879cc'),
  hexToColor('#8c96fe'),
  hexToColor('#6a2c7b')
];
Color pickColor(int index) {
  switch (index % 5) {
    case 0:
      return colorsData[0];
    case 1:
      return colorsData[1];
    case 2:
      return colorsData[2];
    case 3:
      return colorsData[3];
    case 4:
      return colorsData[4];
    default:
      return colorsData[3];
  }
}

class ColorConstants {
  static Color lightScaffoldBackgroundColor = hexToColor('#fdf9ff');
  static Color darkScaffoldBackgroundColor = hexToColor('#2F2E2E');
  static Color primaryScaffoldBackgroundColor = hexToColor('#f2f4fc');
  static Color lightBackgroundColor = hexToColor('#ECE9F6');
  static Color lightBackgroundColorV2 = hexToColor('#F6F5F1');

  // Main Colors
  static Color primaryAppColor = hexToColor('#6725F4');
  static Color primaryAppv2Color = hexToColor('#511CC2');
  static Color primaryAppv3Color = hexToColor('#F6F2FF');
  static Color secondaryAppColor = hexToColor('#F8F4FF');
  static Color tertiaryAppColor = hexToColor('#FFF4EF');
  static Color lightPrimaryAppColor = hexToColor("#967DCC");
  static Color lightPrimaryAppv2Color = hexToColor("#A69EBC");

  static Color secondaryButtonColor = hexToColor("#F7F4FF");

  // Black Shades
  static Color black = hexToColor('#1c1c1c');
  static Color lightBlack = hexToColor("#4a4a4a");
  static Color secondaryBlack = hexToColor('#989898');
  static Color darkGrey = hexToColor('#B1B1B1');
  static Color greyBlue = hexToColor("#97A5C5");
  static Color skyBlue = hexToColor("#4a9dd9");
  static Color daylightBlue = hexToColor("#b5d4ff");
  static Color subtitleColor = hexToColor("#767676");
  static Color tertiaryBlack = hexToColor('#7E7E7E');

  static Color darkBlack = Colors.black;
  // White Shades
  static Color white = hexToColor('#ffffff');
  static Color secondaryWhite = hexToColor('#F9F9F9');

  static Color lightGrey = hexToColor('#E9E9E9');
  static Color tertiaryWhite = hexToColor('#FAF9FF');
  static Color secondaryGrey = hexToColor('#F0F0F0');
  static Color tertiaryGrey = hexToColor('#7A7A7A');
  static Color secondaryLightGrey = hexToColor('#ABABAB');
  static Color borderColor = hexToColor('#E3E3E3');
  static Color secondaryBorderColor = hexToColor('#BEC6E4');
  static Color tertiaryBorderColor = hexToColor('#EDF0E9');

  // Accent Colors
  static Color lightBlue = hexToColor('#DEE5FF');
  static Color redAccentColor = hexToColor('#E32323');
  static Color greenAccentColor = hexToColor('#4FC16F');
  static Color salmonTextColor = hexToColor('#FF7272');
  static Color orangeColor = hexToColor("#FFCBA5");
  static Color tangerineColor = hexToColor("#FFA069");
  static Color lightOrangeColor = hexToColor("#FCEFD6");
  static Color lightYellowColor = hexToColor("#FFF6E5");
  static Color yellowAccentColor = hexToColor("#FBB80F");
  static Color yellowColor = hexToColor("#f09855");

  static Color errorTextColor = hexToColor("#FF4E4E");
  static Color secondaryGreenAccentColor = hexToColor('#2EBA56');

  static Color iconBgColor = hexToColor('#5415DC');

  static Color savingBgColor = hexToColor('#EBDEFF');
  static Color termLifeBgColor = hexToColor('#E5FDFF');
  static Color sandColor = hexToColor('#FFF4DE');
  static Color manilaTint = hexToColor('#FFE1A5');
  static Color fourWheelerBgColor = hexToColor('#FFE5D6');
  static Color blondColor = hexToColor("#FFEDBC");
  // #FFF4D6
  static Color lavenderColor = hexToColor('#E5F0FF');

  static Color savingTextColor = hexToColor('#8E71BB');
  static Color termLifeTextColor = hexToColor('#247A86');
  static Color twoWheelerTextColor = hexToColor('#C0A56D');

  static Color secondaryCardColor = hexToColor('#FFF8EA');

  static Color healthTextColor = hexToColor('#244E86');

  static Color separatorColor = hexToColor('#F2F2F2');
  static Color secondarySeparatorColor = hexToColor('#D9D9D9');

  static Color primaryCardColor = hexToColor('#F6F6FB');
  static Color tertiaryCardColor = hexToColor('#F2F8FF');

  static Color errorColor = hexToColor('#FF4E4E');
  static Color lightRedColor = hexToColor('#FFF4F4');
  static Color searchBarBorderColor = hexToColor('#EEE7FF');
  static Color insuranceOfflineColor = hexToColor('#FFF4EF');
  static Color lightGreenBackgroundColor = hexToColor('#E9FFEF');

  static Color borderColor2 = hexToColor('#E6E6E6');

  static Color textFieldBorderColor = hexToColor("#EAEAEA");
  static Color textFieldHintColor = hexToColor("#BEBEBE");

  static Color aliceBlueColor = hexToColor('#F3F9FF');
  static Color lavenderSecondaryColor = hexToColor('#DEE5FF');
  static Color darkCharcoalColor = hexToColor('#343333');
  static Color lotionColor = hexToColor('#FAFAFA');
  static Color platinumColor = hexToColor('#E0E0EA');
  static Color silverSandColor = hexToColor('#C5C5C5');
  static Color paleLavenderColor = hexToColor('#DCD0F8');
  static Color secondaryRedAccentColor = hexToColor('#FF7A2D');

  static Color aiSuggestionBackground = hexToColor('#F6F6FB');
}
