import 'dart:math';
import 'package:core/modules/opportunities/serviecs/pdf_generation_service.dart';
import 'package:flutter/material.dart';

class SipSimulatorSheet extends StatefulWidget {
  final String clientName;
  final String userId;
  final double currentSipAmount;
  final String? schemeName;

  const SipSimulatorSheet({
    Key? key,
    required this.clientName,
    required this.userId,
    this.currentSipAmount = 10000,
    this.schemeName,
  }) : super(key: key);

  static void show(BuildContext context, {
    required String clientName,
    required String userId,
    double currentSipAmount = 10000,
    String? schemeName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SipSimulatorSheet(
        clientName: clientName,
        userId: userId,
        currentSipAmount: currentSipAmount,
        schemeName: schemeName,
      ),
    );
  }

  @override
  State<SipSimulatorSheet> createState() => _SipSimulatorSheetState();
}

class _SipSimulatorSheetState extends State<SipSimulatorSheet> {
  double _stepUpPercent = 10;
  int _selectedDuration = 15;
  bool _isGenerating = false;

  // Assumed annual return
  static const double _annualReturn = 0.12;

  // Calculate future value with step-up
  double _calculateStepUpCorpus() {
    double corpus = 0;
    double monthlyAmount = widget.currentSipAmount;
    final monthlyReturn = _annualReturn / 12;
    final totalMonths = _selectedDuration * 12;

    for (int month = 1; month <= totalMonths; month++) {
      // Add monthly SIP with compounding
      corpus = (corpus + monthlyAmount) * (1 + monthlyReturn);

      // Increase SIP annually
      if (month % 12 == 0 && month < totalMonths) {
        monthlyAmount *= (1 + _stepUpPercent / 100);
      }
    }
    return corpus;
  }

  // Calculate future value without step-up (flat SIP)
  double _calculateFlatCorpus() {
    double corpus = 0;
    final monthlyAmount = widget.currentSipAmount;
    final monthlyReturn = _annualReturn / 12;
    final totalMonths = _selectedDuration * 12;

    for (int month = 1; month <= totalMonths; month++) {
      corpus = (corpus + monthlyAmount) * (1 + monthlyReturn);
    }
    return corpus;
  }

  String _formatCurrency(double value) {
    if (value >= 10000000) {
      return 'Rs. ${(value / 10000000).toStringAsFixed(2)}Cr';
    } else if (value >= 100000) {
      return 'Rs. ${(value / 100000).toStringAsFixed(2)}L';
    } else if (value >= 1000) {
      return 'Rs. ${(value / 1000).toStringAsFixed(1)}K';
    }
    return 'Rs. ${value.toStringAsFixed(0)}';
  }

  Future<void> _generatePdf() async {
    setState(() => _isGenerating = true);

    try {
      // FIX: Parameters matched to PdfGeneratorService signature
      await PdfGeneratorService.generateSipProposal(
        clientName: widget.clientName,
        currentSip: widget.currentSipAmount, // Renamed from currentSipAmount
        stepUpPercent: _stepUpPercent,       // Renamed from suggestedStepUp
        isRevival: false,
        durationYears: _selectedDuration,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Step-up proposal generated!'),
            backgroundColor: Color(0xFF16A34A),
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
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flatCorpus = _calculateFlatCorpus();
    final stepUpCorpus = _calculateStepUpCorpus();
    final extraWealth = stepUpCorpus - flatCorpus;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 0.9,
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
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'SIP Step-up Simulator',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.close, size: 18, color: Color(0xFF6B7280)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'For ${widget.clientName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Hero Section: Extra Wealth Created
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Extra Wealth Created',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF166534),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _formatCurrency(extraWealth),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Comparison Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Flat SIP Corpus',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatCurrency(flatCorpus),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: const Color(0xFFBBF7D0),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Step-up Corpus',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatCurrency(stepUpCorpus),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF16A34A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Step-up Slider
                    const Text(
                      'Annual Step-up %',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFF6725F4),
                              inactiveTrackColor: const Color(0xFFE5E7EB),
                              thumbColor: const Color(0xFF6725F4),
                              overlayColor: const Color(0xFF6725F4).withOpacity(0.2),
                              trackHeight: 6,
                            ),
                            child: Slider(
                              value: _stepUpPercent,
                              min: 5,
                              max: 30,
                              divisions: 25,
                              onChanged: (value) {
                                setState(() => _stepUpPercent = value);
                              },
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_stepUpPercent.toInt()}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6725F4),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Duration Chips
                    const Text(
                      'Investment Duration',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [10, 15, 20].map((years) {
                        final isSelected = _selectedDuration == years;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedDuration = years),
                            child: Container(
                              margin: EdgeInsets.only(right: years < 20 ? 12 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF6725F4)
                                    : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF6725F4)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${years}Y',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),

                    // Generate PDF Button
                    GestureDetector(
                      onTap: _isGenerating ? null : _generatePdf,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _isGenerating
                              ? const Color(0xFFE5E7EB)
                              : const Color(0xFF6725F4),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: _isGenerating
                              ? []
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF6725F4).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isGenerating)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF6B7280),
                                ),
                              )
                            else
                              const Icon(
                                Icons.picture_as_pdf_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            const SizedBox(width: 10),
                            Text(
                              _isGenerating ? 'Generating...' : 'Generate Proposal PDF',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _isGenerating
                                    ? const Color(0xFF6B7280)
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Disclaimer
                    Text(
                      'Assumed 12% annual returns. Actual returns may vary.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}