import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/opportunities_controller.dart';
import 'package:app/src/screens/opportunities/widgets/portfolio_review_bottomsheet.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/new_client_model.dart';
import 'package:core/modules/clients/models/sip_user_data_model.dart';
import 'package:core/modules/opportunities/models/opportunities_overview_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:get/get.dart';

class OpportunitiesFocus extends StatelessWidget {
  const OpportunitiesFocus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OpportunitiesController>(
      builder: (controller) {
        final topFocusClients =
            controller.opportunitiesOverview?.topFocusClients ?? [];

        if (topFocusClients.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Focus Clients',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    '${topFocusClients.length} clients',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 240,
              child: Swiper(
                itemCount: topFocusClients.length,
                itemBuilder: (context, index) {
                  return ClientCard(client: topFocusClients[index]);
                },
                autoplay: false,
                viewportFraction: 0.9,
                scale: 0.95,
                loop: topFocusClients.length > 1,
              ),
            ),
          ],
        );
      },
    );
  }
}

class ClientCard extends StatelessWidget {
  final TopFocusClient client; // TopFocusClient from API

  const ClientCard({Key? key, required this.client}) : super(key: key);

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  Color _getTagColor(String tag, bool isBackground) {
    if (tag.toLowerCase().contains('risk') ||
        tag.toLowerCase().contains('stopped')) {
      return isBackground ? const Color(0xFFFEE2E2) : const Color(0xFFDC2626);
    } else if (tag.toLowerCase().contains('opp') ||
        tag.toLowerCase().contains('insurance')) {
      return isBackground ? const Color(0xFFEDE9FE) : const Color(0xFF7C3AED);
    } else if (tag.toLowerCase().contains('growth') ||
        tag.toLowerCase().contains('stagnant')) {
      return isBackground ? const Color(0xFFFED7AA) : const Color(0xFFEA580C);
    } else if (tag.toLowerCase().contains('portfolio') ||
        tag.toLowerCase().contains('underperform')) {
      return isBackground ? const Color(0xFFE5E7EB) : const Color(0xFF6B7280);
    }
    return isBackground ? const Color(0xFFE5E7EB) : const Color(0xFF6B7280);
  }

  IconData _getTagIcon(String tag) {
    if (tag.toLowerCase().contains('risk') ||
        tag.toLowerCase().contains('stopped')) {
      return Icons.warning_amber_rounded;
    } else if (tag.toLowerCase().contains('opp') ||
        tag.toLowerCase().contains('insurance')) {
      return Icons.lightbulb_outline;
    } else if (tag.toLowerCase().contains('growth') ||
        tag.toLowerCase().contains('stagnant')) {
      return Icons.trending_up;
    } else if (tag.toLowerCase().contains('portfolio') ||
        tag.toLowerCase().contains('underperform')) {
      return Icons.bar_chart;
    }
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(client.clientName);
    final tags = client.tags as List<String>? ?? [];

    // Determine opportunity type based on drillDownDetails
    final hasPortfolioIssue = client.drillDownDetails.portfolioReview.hasIssue;
    final hasStoppedSips =
        client.drillDownDetails.sipHealth.stoppedSips.isNotEmpty;
    final hasStagnantSips =
        client.drillDownDetails.sipHealth.stagnantSips.isNotEmpty;
    final hasInsurance = client.drillDownDetails.insurance.hasGap;

    return InkWell(
      onTap: () {
        // Create client model
        final clientModel = NewClientModel.fromJson({
          'user_id': client.userId,
          'name': client.clientName,
        });

        // Navigate based on priority: Portfolio > SIP > Insurance
        if (hasPortfolioIssue) {
          // PortfolioReviewBottomSheet.show(context, portfolioClient);
        } else if (hasStoppedSips || hasStagnantSips) {
          // Navigate to SIP detail screen
          Client clientModel = Client.fromJson({
            'user_id': client.userId,
            'name': client.clientName,
          });
          AutoRouter.of(context).push(
            SipDetailRoute(
                client: clientModel,
                sipUserData: SipUserDataModel.fromJson({})),
          );
        } else if (hasInsurance) {
          // Navigate to insurance quotes
          AutoRouter.of(context).push(InsuranceGenerateQuotesRoute(
            productVariant: InsuranceProductVariant.HEALTH,
            insuranceData: null,
            selectedClient: null,
          ));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9D5FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name and Amount
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.clientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        client.totalImpactValue,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow icon
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9CA3AF),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                final bgColor = _getTagColor(tag, true);
                final textColor = _getTagColor(tag, false);
                final icon = _getTagIcon(tag);

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: textColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Pitch Hook (Alert message)
            Text(
              '💡 ${client.pitchHook}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
