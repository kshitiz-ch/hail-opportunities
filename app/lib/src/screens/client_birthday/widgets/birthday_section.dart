import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BirthdaySection extends StatelessWidget {
  final String title;
  final List<Client> clients;
  final bool showDate;
  final bool enableWishButton;

  const BirthdaySection({
    Key? key,
    required this.title,
    required this.clients,
    this.showDate = false,
    this.enableWishButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: ColorConstants.tertiaryBlack,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ColorConstants.borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(0),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: clients.length,
            separatorBuilder: (context, index) =>
                Divider(color: ColorConstants.borderColor),
            itemBuilder: (context, index) {
              final client = clients[index];
              return BirthdayCardWidget(
                client: client,
                showDate: showDate,
                enableWishButton: enableWishButton,
              );
            },
          ),
        ),
      ],
    );
  }
}

class BirthdayCardWidget extends StatelessWidget {
  final Client client;
  final bool showDate;
  final bool enableWishButton;

  const BirthdayCardWidget({
    Key? key,
    required this.client,
    required this.showDate,
    this.enableWishButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String subtitle = '';
    if (showDate) {
      subtitle = _formatBirthdayDate(client.dob);
    } else {
      subtitle = '${_calculateAge(client.dob)} Years Old';
    }
    // wealthyCurrentValue commented as it has outdated information
    // subtitle +=
    //     ' | ${WealthyAmount.currencyFormat(client.wealthyCurrentValue, 2)}';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: CommonUI.buildColumnTextInfo(
              subtitle: subtitle,
              title: (client.name ?? 'Unknown Client').toTitleCase(),
              titleStyle: context.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorConstants.black,
              ),
              gap: 4,
              subtitleStyle: context.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorConstants.tertiaryBlack,
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (enableWishButton)
            GestureDetector(
              onTap: () {
                // Handle wish button press
                AutoRouter.of(context).push(BirthdayWishRoute(client: client));
              },
              child: _buildWishButton(context),
            ),
        ],
      ),
    );
  }

  Widget _buildWishButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ColorConstants.primaryAppv3Color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AllImages().birthdayWishIcon,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 4),
          Text(
            'Wish Now',
            style: context.titleLarge?.copyWith(
              color: ColorConstants.primaryAppColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatBirthdayDate(DateTime? birthDate) {
    try {
      if (birthDate == null) return 'N/A';
      final now = DateTime.now();
      final thisYearBirthday =
          DateTime(now.year, birthDate.month, birthDate.day);
      return DateFormat('MMM dd').format(thisYearBirthday);
    } catch (e) {
      return '';
    }
  }

  String _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return '0';
    try {
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return '0';
    }
  }
}
