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
  final TopFocusClient client;

  const ClientCard({Key? key, required this.client}) : super(key: key);

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  Color _getTagBgColor(String tag) {
    final lower = tag.toLowerCase();
    if (lower.contains('risk') || lower.contains('stopped')) {
      return const Color(0xFFFEE2E2);
    } else if (lower.contains('opp') || lower.contains('insurance')) {
      return const Color(0xFFEDE9FE);
    } else if (lower.contains('growth') || lower.contains('stagnant')) {
      return const Color(0xFFFED7AA);
    } else if (lower.contains('portfolio') || lower.contains('underperform')) {
      return const Color(0xFFE5E7EB);
    }
    return const Color(0xFFE5E7EB);
  }

  Color _getTagTextColor(String tag) {
    final lower = tag.toLowerCase();
    if (lower.contains('risk') || lower.contains('stopped')) {
      return const Color(0xFFDC2626);
    } else if (lower.contains('opp') || lower.contains('insurance')) {
      return const Color(0xFF7C3AED);
    } else if (lower.contains('growth') || lower.contains('stagnant')) {
      return const Color(0xFFEA580C);
    } else if (lower.contains('portfolio') || lower.contains('underperform')) {
      return const Color(0xFF6B7280);
    }
    return const Color(0xFF6B7280);
  }

  IconData _getTagIcon(String tag) {
    final lower = tag.toLowerCase();
    if (lower.contains('risk') || lower.contains('stopped')) {
      return Icons.warning_amber_rounded;
    } else if (lower.contains('opp') || lower.contains('insurance')) {
      return Icons.lightbulb_outline;
    } else if (lower.contains('growth') || lower.contains('stagnant')) {
      return Icons.trending_up;
    } else if (lower.contains('portfolio') || lower.contains('underperform')) {
      return Icons.bar_chart;
    }
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(client.clientName);
    final tags = client.tags;

    return InkWell(
      onTap: () {
        // Show Drill-Down Bottom Sheet
        FocusClientBottomSheet.show(context, client);
      },
      borderRadius: BorderRadius.circular(16),
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
                        client.formattedImpactValue,
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
                final bgColor = _getTagBgColor(tag);
                final textColor = _getTagTextColor(tag);
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
            const SizedBox(height: 12),
            // Pitch Hook (Tip Box Style)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      client.pitchHook,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF166534),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
