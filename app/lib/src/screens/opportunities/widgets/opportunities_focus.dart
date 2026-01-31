import 'package:app/src/controllers/opportunities_controller.dart';
import 'package:app/src/screens/opportunities/widgets/focus_client_bottom_sheet.dart';
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
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Focus Clients',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${topFocusClients.length} clients',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: Swiper(
                itemCount: topFocusClients.length,
                itemBuilder: (context, index) {
                  return FocusClientCard(client: topFocusClients[index]);
                },
                autoplay: false,
                viewportFraction: 0.92,
                scale: 0.97,
                loop: topFocusClients.length > 1,
              ),
            ),
          ],
        );
      },
    );
  }
}

class FocusClientCard extends StatelessWidget {
  final TopFocusClient client;

  const FocusClientCard({Key? key, required this.client}) : super(key: key);

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  // Determine the accent color based on risk type
  Color _getAccentColor() {
    // Check for risk indicators
    final hasRisk = client.drillDownDetails.portfolioReview.hasIssue ||
        client.drillDownDetails.sipHealth.stoppedSips.isNotEmpty;
    final hasOpportunity = client.drillDownDetails.insurance.hasGap ||
        client.drillDownDetails.sipHealth.stagnantSips.isNotEmpty;

    if (hasRisk) {
      return const Color(0xFFDC2626); // Red for risk
    } else if (hasOpportunity) {
      return const Color(0xFF16A34A); // Green for opportunity
    }
    return const Color(0xFF6725F4); // Purple default
  }

  Color _getTagColor(String tag) {
    final lower = tag.toLowerCase();
    if (lower.contains('risk') || lower.contains('stopped')) {
      return const Color(0xFFDC2626);
    } else if (lower.contains('insurance') || lower.contains('gap')) {
      return const Color(0xFF0D9488);
    } else if (lower.contains('stagnant') || lower.contains('growth')) {
      return const Color(0xFFEA580C);
    } else if (lower.contains('portfolio') || lower.contains('underperform')) {
      return const Color(0xFF6B7280);
    }
    return const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(client.clientName);
    final accentColor = _getAccentColor();
    final tags = client.tags;

    return GestureDetector(
      onTap: () => FocusClientBottomSheet.show(context, client),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Accent Border
            Container(
              width: 4,
              height: double.infinity,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Avatar + Name + Impact Value
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Name
                        Expanded(
                          child: Text(
                            client.clientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Impact Value
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            client.formattedImpactValue,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6725F4),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Pitch Hook (Subtle Container)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Text(
                        client.pitchHook,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4B5563),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const Spacer(),

                    // Tags (Horizontal Scroll)
                    SizedBox(
                      height: 28,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: tags.map((tag) {
                            final tagColor = _getTagColor(tag);
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: tagColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: tagColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Chevron
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.chevron_right,
                color: Color(0xFFD1D5DB),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
