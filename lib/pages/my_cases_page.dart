import 'package:flutter/material.dart';

class MyCasesPage extends StatelessWidget {
  const MyCasesPage({super.key});

  final List<Map<String, dynamic>> _cases = const [
    {
      'caseNumber': 'CRL/2024/001',
      'title': 'Property Dispute - Sector 15',
      'status': 'Hearing Scheduled',
      'nextDate': '15 Dec 2024',
      'court': 'Delhi High Court',
      'progress': 0.6,
      'updates': [
        {'date': '10 Nov 2024', 'event': 'Case filed'},
        {'date': '25 Nov 2024', 'event': 'First hearing completed'},
        {'date': '15 Dec 2024', 'event': 'Next hearing scheduled'},
      ],
    },
    {
      'caseNumber': 'CIV/2024/045',
      'title': 'Lease Agreement Review',
      'status': 'Under Review',
      'nextDate': '20 Dec 2024',
      'court': 'District Court',
      'progress': 0.3,
      'updates': [
        {'date': '05 Dec 2024', 'event': 'Documents submitted'},
        {'date': '20 Dec 2024', 'event': 'Review pending'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF14171E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF121317),
        elevation: 0,
        title: const Text('My Cases'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add new case coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _cases.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
               Icon(
                    Icons.cases_outlined,
                    size: 80,
                    color: isDarkMode ? Colors.grey : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No cases yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.grey : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cases.length,
              itemBuilder: (context, index) {
                final caseData = _cases[index];
                return _buildCaseCard(caseData, isDarkMode, context);
              },
            ),
    );
  }

  Widget _buildCaseCard(Map<String, dynamic> caseData, bool isDarkMode, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(caseData['status']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        caseData['status'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(caseData['status']),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      caseData['caseNumber'],
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  caseData['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF121317),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.account_balance,
                      size: 16,
                      color: isDarkMode ? Colors.grey : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      caseData['court'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Color(0xFFF6B21D)),
                    const SizedBox(width: 8),
                    Text(
                      'Next: ${caseData['nextDate']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF6B21D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey : Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${(caseData['progress'] * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : const Color(0xFF121317),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: caseData['progress'],
                        backgroundColor: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF253D79)),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          InkWell(
            onTap: () => _showTimeline(context, caseData, isDarkMode),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timeline,
                    size: 16,
                    color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'View Timeline',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Hearing Scheduled':
        return Colors.blue;
      case 'Under Review':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showTimeline(BuildContext context, Map<String, dynamic> caseData, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Case Timeline',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF121317),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              (caseData['updates'] as List).length,
              (index) {
                final update = (caseData['updates'] as List)[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF253D79),
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (index < (caseData['updates'] as List).length - 1)
                            Container(
                              width: 2,
                              height: 40,
                              color: const Color(0xFF253D79).withOpacity(0.3),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              update['event'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : const Color(0xFF121317),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              update['date'],
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.grey : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
