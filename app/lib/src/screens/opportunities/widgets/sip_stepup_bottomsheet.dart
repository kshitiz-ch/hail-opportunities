import 'package:app/src/widgets/button/action_button.dart';
import 'package:core/modules/opportunities/models/sip_opportunity_model.dart';
import 'package:core/modules/opportunities/serviecs/pdf_generation_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SipStepUpBottomSheet extends StatefulWidget {
  final StagnantSipOpportunity opportunity;

  const SipStepUpBottomSheet({
    Key? key,
    required this.opportunity,
  }) : super(key: key);

  static void show(BuildContext context, StagnantSipOpportunity opportunity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SipStepUpBottomSheet(opportunity: opportunity),
    );
  }

  @override
  State<SipStepUpBottomSheet> createState() => _SipStepUpBottomSheetState();
}

class _SipStepUpBottomSheetState extends State<SipStepUpBottomSheet> {
  final TextEditingController stepUpController =
      TextEditingController(text: '10');
  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    stepUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SIP Step-Up Proposal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Client Information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Client: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.opportunity.userName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Current SIP: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          _currencyFormat.format(widget.opportunity.currentSip),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Step-up Input
              TextField(
                controller: stepUpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Yearly Step-up %',
                  border: OutlineInputBorder(),
                  suffixText: '%',
                  hintText: 'Enter step-up percentage',
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: const BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ActionButton(
                      margin: EdgeInsets.zero,
                      onPressed: () {
                        // Navigator.pop(context);
                        final stepUp =
                            double.tryParse(stepUpController.text) ?? 10;
                        PdfGeneratorService.generateSipProposal(
                          clientName: widget.opportunity.userName,
                          currentSip: widget.opportunity.currentSip,
                          stepUpPercent: stepUp,
                        );
                      },
                      text: 'Generate PDF',
                    ),
                    // child: FilledButton(
                    //   onPressed: () {
                    //     Navigator.pop(context);
                    //     final stepUp =
                    //         double.tryParse(stepUpController.text) ?? 10;
                    //     PdfGeneratorService.generateSipProposal(
                    //       clientName: widget.opportunity.userName,
                    //       currentSip: widget.opportunity.currentSip,
                    //       stepUpPercent: stepUp,
                    //     );
                    //   },
                    //   style: FilledButton.styleFrom(
                    //     padding: const EdgeInsets.symmetric(vertical: 14),
                    //     backgroundColor: const Color(0xFF6725F4),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //   ),
                    //   child: const Text(
                    //     'Generate PDF',
                    //     style: TextStyle(
                    //       fontSize: 16,
                    //       fontWeight: FontWeight.w600,
                    //     ),
                    //   ),
                    // ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
