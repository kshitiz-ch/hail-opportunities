import 'package:flutter/material.dart';

class OpportunitiesSip extends StatefulWidget {
  const OpportunitiesSip({Key? key}) : super(key: key);

  @override
  State<OpportunitiesSip> createState() => _OpportunitiesSipState();
}

class _OpportunitiesSipState extends State<OpportunitiesSip> {
  String selectedTab = 'Stagnant';

  @override
  Widget build(BuildContext context) {
    // Different data for each tab
    final stagnantData = [
      {
        'name': 'Kiran Sharma',
        'fundName': 'SBI Equity Hybrid',
        'statusText': 'No Step-up: 3 Yrs',
      },
      {
        'name': 'Priya Nair',
        'fundName': 'HDFC Balanced Advantage',
        'statusText': 'No Step-up: 4 Yrs',
      },
      {
        'name': 'Amit Gupta',
        'fundName': 'ICICI Multi-Asset',
        'statusText': 'No Step-up: 2 Yrs',
      },
    ];

    final stoppedData = [
      {
        'name': 'Vikram Shah',
        'fundName': 'Last Paid: Oct 2025',
        'statusText': '65 Days Silent',
      },
      {
        'name': 'Amit Sharma',
        'fundName': 'Last Paid: Nov 2025',
        'statusText': '45 Days Silent',
      },
      {
        'name': 'Priya Menon',
        'fundName': 'Last Paid: Sep 2025',
        'statusText': '90 Days Silent',
      },
    ];

    // Select data based on active tab
    final currentData = selectedTab == 'Stagnant' ? stagnantData : stoppedData;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SIP Health',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle view all action
                },
                child: const Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF6725F4),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFF6725F4),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Divider line
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),

          // Tabs
          Row(
            children: [
              _buildTab('Stagnant', selectedTab == 'Stagnant'),
              const SizedBox(width: 8),
              _buildTab('Stopped', selectedTab == 'Stopped'),
            ],
          ),

          // Divider line
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 16),

          // SIP Items - Dynamic based on selected tab
          ...List.generate(currentData.length, (index) {
            final item = currentData[index];
            return Column(
              children: [
                if (index > 0)
                  const Divider(height: 24, color: Color(0xFFE5E7EB)),
                _buildSipItem(
                  name: item['name']!,
                  fundName: item['fundName']!,
                  statusText: item['statusText']!,
                  isStopped: selectedTab == 'Stopped',
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    final isStopped = title == 'Stopped';

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isStopped ? const Color(0xFFDC2626) : const Color(0xFF6725F4))
              : const Color(0xFFF5F7F8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSipItem({
    required String name,
    required String fundName,
    required String statusText,
    bool isStopped = false,
  }) {
    return Row(
      children: [
        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                fundName,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),

        // Status Badge with Arrow
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isStopped
                    ? const Color(0xFFFFE5E5)
                    : const Color(0xFFF8EEE2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  color: isStopped
                      ? const Color(0xFFDC2626)
                      : const Color(0xFFF98814),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ],
    );
  }
}
