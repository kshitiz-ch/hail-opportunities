import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';

class HomeErrorSection extends StatelessWidget {
  final Function onRefresh;
  final Function onLogout;
  final Function onSupport;

  const HomeErrorSection({
    super.key,
    required this.onRefresh,
    required this.onLogout,
    required this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0).copyWith(top: 84),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Icon
            Image.asset(
              AllImages().homeErrorIcon,
              height: 100,
              width: 100,
              alignment: Alignment.center,
            ),

            // Title
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                'Something went wrong',
                style: context.headlineMedium?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Subtitle
            Text(
              'Please try again.',
              style: context.headlineSmall?.copyWith(
                color: ColorConstants.tertiaryBlack,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            // Refresh Button
            ActionButton(
              margin: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 32),
              prefixWidget: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              text: 'Refresh',
              onPressed: () {
                onRefresh();
              },
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 32, top: 84),
              child: CommonUI.buildProfileDataSeperator(),
            ),

            // Troubleshooting Title
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Try these troubleshooting steps:',
                style: context.headlineMedium?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Troubleshooting Steps
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: _buildTroubleshootingItem(
                  context: context,
                  icon: Icons.logout,
                  type: 'logout',
                  onTap: () {
                    onLogout();
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: _buildTroubleshootingItem(
                context: context,
                icon: Icons.settings,
                type: 'uninstall',
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.topLeft,
              child: _buildTroubleshootingItem(
                context: context,
                icon: Icons.help_outline,
                type: 'support',
                onTap: () {
                  onSupport();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingItem({
    required IconData icon,
    VoidCallback? onTap,
    required BuildContext context,
    required String type,
  }) {
    return InkWell(
      // Makes the row tappable
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align items to the start
        mainAxisSize: MainAxisSize.min, // Use minimum space
        children: <Widget>[
          Icon(icon, color: ColorConstants.primaryAppColor, size: 24),
          const SizedBox(width: 16),
          _getTextWidget(type, context),
        ],
      ),
    );
  }

  Widget _getTextWidget(
    String type,
    BuildContext context,
  ) {
    // Base style for non-underlined parts
    final baseStyle = context.headlineSmall?.copyWith(
      color: ColorConstants.black,
      fontWeight: FontWeight.w400,
    );

    // Style for the text inside the underlined container (no decoration needed here)
    final underlinedTextStyle = baseStyle?.copyWith(
      fontWeight: FontWeight.w600,
    );

    // Helper to create the underlined container widget
    Widget buildUnderlinedContainer(String text) {
      return Container(
        padding: EdgeInsets.only(bottom: 0), // Adjust gap size here
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: ColorConstants.black, // Underline color
          width: 1.0, // Underline thickness
        ))),
        child: Text(text, style: underlinedTextStyle),
      );
    }

    if (type == 'logout') {
      return Text.rich(
        TextSpan(
          style: baseStyle, // Default style for the span
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: buildUnderlinedContainer('Log out'),
            ),
            TextSpan(text: ' and log in again'), // Non-underlined part
          ],
        ),
      );
    }

    if (type == 'support') {
      return Text.rich(
        TextSpan(
          style: baseStyle, // Default style for the span
          children: [
            TextSpan(text: 'Reach out to '), // Non-underlined part
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: buildUnderlinedContainer('support'),
            ),
          ],
        ),
      );
    }
    // Keep original style for the 'uninstall' case
    return Text('Uninstall and reinstall the app', style: baseStyle);
  }
}
