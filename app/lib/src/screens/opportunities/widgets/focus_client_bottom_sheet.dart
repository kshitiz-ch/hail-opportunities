import 'package:app/src/screens/opportunities/widgets/sip_simulator_sheet.dart';
import 'package:core/modules/opportunities/models/insurance_opportunity_model.dart';
import 'package:core/modules/opportunities/models/opportunities_overview_model.dart';
import 'package:core/modules/opportunities/serviecs/pdf_generation_service.dart';
import 'package:flutter/material.dart';

class FocusClientBottomSheet extends StatefulWidget {
  final TopFocusClient client;

  const FocusClientBottomSheet({Key? key, required this.client})
      : super(key: key);

  static void show(BuildContext context, TopFocusClient client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FocusClientBottomSheet(client: client),
    );
  }

  @override
  State<FocusClientBottomSheet> createState() => _FocusClientBottomSheetState();
}

class _FocusClientBottomSheetState extends State<FocusClientBottomSheet> {
  bool _isGeneratingInsurance = false;

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return 'Rs. ${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return 'Rs. ${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return 'Rs. ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return 'Rs. ${amount.toStringAsFixed(0)}';
  }

  Future<void> _generateInsurancePdf() async {
    setState(() => _isGeneratingInsurance = true);

    try {
      // Create a temporary InsuranceOpportunity from FocusClient data
      final gapAmount = widget.client.drillDownDetails.insurance.gapAmount;
      
      // Heuristic: Estimate premium as ~2% of sum assured (conservative term plan estimate)
      final estimatedPremium = (gapAmount * 0.02).roundToDouble();
      
      final tempOpportunity = InsuranceOpportunity(
        userId: widget.client.userId,
        userName: widget.client.clientName,
        age: 40, // Default age since FocusClient doesn't have it
        mfCurrentValue: gapAmount,
        insuranceStatus: 'Coverage Gap',
        agentExternalId: '',
        agentName: '',
        totalPremium: estimatedPremium,
        expectedPremium: estimatedPremium,
        premiumOpportunityValue: estimatedPremium,
        coveragePercentage: 0,
      );

      await PdfGeneratorService.generateInsuranceProposal(tempOpportunity);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insurance proposal generated!'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingInsurance = false);
    }
  }

  void _openSipSimulator() {
    Navigator.pop(context); // Close this sheet first
    
    // Get SIP amount from first stopped SIP if available, otherwise default
    double sipAmount = 10000;
    final stoppedSips = widget.client.drillDownDetails.sipHealth.stoppedSips;
    // Note: StagnantSip model in overview may not have amount field, so we default to 10000
    
    if (stoppedSips.isNotEmpty) {
      sipAmount = stoppedSips.first.amount;
    } 

    SipSimulatorSheet.show(
      context,
      clientName: widget.client.clientName,
      userId: widget.client.userId,
      currentSipAmount: sipAmount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final drillDown = widget.client.drillDownDetails;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.client.clientName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E8FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.client.formattedImpactValue,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF6725F4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.close,
                                size: 20, color: Color(0xFF6B7280)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // AI Insight Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline,
                              color: Color(0xFF16A34A), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('AI Insight',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF166534))),
                                const SizedBox(height: 4),
                                Text(
                                  widget.client.pitchHook,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF15803D),
                                      height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // --- SECTION 1: Portfolio Review ---
                    if (drillDown.portfolioReview.hasIssue) ...[
                      _buildSectionHeader(
                          '📉 Portfolio Underperformance', const Color(0xFFDC2626)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Column(
                          children: drillDown.portfolioReview.schemes.map((s) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text(s.name,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF1F2937)))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDC2626),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('${s.xirrLag}% Lag',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // --- SECTION 2: Insurance Gap ---
                    if (drillDown.insurance.hasGap) ...[
                      _buildSectionHeader(
                          '🛡️ Insurance Gap', const Color(0xFF0D9488)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF99F6E4)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Protection Gap',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF0F766E))),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatCurrency(drillDown.insurance.gapAmount),
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0D9488)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // CTA: Pitch Term Plan
                            GestureDetector(
                              onTap: _isGeneratingInsurance ? null : _generateInsurancePdf,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: _isGeneratingInsurance
                                      ? const Color(0xFFE5E7EB)
                                      : const Color(0xFF0D9488),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isGeneratingInsurance)
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF6B7280),
                                        ),
                                      )
                                    else
                                      const Icon(Icons.picture_as_pdf_outlined,
                                          color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isGeneratingInsurance
                                          ? 'Generating...'
                                          : 'Pitch Term Plan',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _isGeneratingInsurance
                                            ? const Color(0xFF6B7280)
                                            : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // --- SECTION 3: SIP Issues ---
                    if (drillDown.sipHealth.stoppedSips.isNotEmpty ||
                        drillDown.sipHealth.stagnantSips.isNotEmpty) ...[
                      _buildSectionHeader(
                          '⚠️ SIP Health Issues', const Color(0xFFEA580C)),
                      const SizedBox(height: 12),

                      // List Stopped SIPs
                      ...drillDown.sipHealth.stoppedSips.map((sip) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFED7AA)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEA580C).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.pause_circle_outline,
                                    color: Color(0xFFEA580C), size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(sip.scheme,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1F2937)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    Text(
                                        'Stopped ${sip.daysStopped} days • ${_formatCurrency(sip.amount)}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFC2410C))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      // List Stagnant SIPs
                      ...drillDown.sipHealth.stagnantSips.map((sip) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF5FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE9D5FF)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6725F4).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.trending_flat,
                                    color: Color(0xFF6725F4), size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(sip.scheme,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1F2937)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    Text(
                                        'No step-up for ${sip.yearsRunning} years',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF7C3AED))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 8),

                      // CTA: Simulate Step-up
                      GestureDetector(
                        onTap: _openSipSimulator,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6725F4),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6725F4).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calculate_outlined,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Simulate Step-up',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(color: color.withOpacity(0.2), thickness: 1),
        ),
      ],
    );
  }
}