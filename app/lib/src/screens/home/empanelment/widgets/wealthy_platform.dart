import 'package:app/src/config/constants/image_constants.dart';
import 'package:flutter/material.dart';

class WealthyPlatform extends StatelessWidget {
  const WealthyPlatform({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wealthy Platform',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineMedium!
              .copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 18),
        Row(
          children: [
            _buildPlatformTile(
              context,
              'Access to\nMobile App',
              AllImages().mobileOutline,
              imageWidth: 15,
            ),
            SizedBox(width: 16),
            _buildPlatformTile(
              context,
              'Relationship\nManager',
              AllImages().rmOutline,
              imageWidth: 23,
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            _buildPlatformTile(
              context,
              'Marketing\nSupport',
              AllImages().finProductOutline,
              imageWidth: 27,
            ),
            SizedBox(width: 16),
            _buildPlatformTile(
              context,
              'Research\nSupport',
              AllImages().researchSupportOutline,
              imageWidth: 25,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlatformTile(BuildContext context, String title, String image,
      {required double imageWidth}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 15)
            .copyWith(right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset(
              image,
              width: imageWidth,
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .primaryTextTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.w600, height: 1.5),
              ),
            )
          ],
        ),
      ),
    );
  }
}
