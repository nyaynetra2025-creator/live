import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'pages/chat_detail_page.dart';

class LawyerDirectoryPage extends StatefulWidget {
  const LawyerDirectoryPage({super.key});

  @override
  State<LawyerDirectoryPage> createState() => _LawyerDirectoryPageState();
}

class _LawyerDirectoryPageState extends State<LawyerDirectoryPage> {
  String _selectedSpecialization = 'All';
  
  final List<String> _specializations = [
    'All',
    'Criminal Law',
    'Civil Law',
    'Corporate Law',
    'Family Law',
    'Tax Law',
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
        title: const Text('Lawyers Directory'),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            height: 60,
            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _specializations.length,
              itemBuilder: (context, index) {
                final spec = _specializations[index];
                final isSelected = spec == _selectedSpecialization;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(spec),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedSpecialization = spec);
                    },
                    selectedColor: isDarkMode ? const Color(0xFF253D79) : const Color(0xFF253D79).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected 
                          ? (isDarkMode ? Colors.white : const Color(0xFF253D79))
                          : (isDarkMode ? Colors.grey : Colors.grey[700]),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Lawyers list
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: SupabaseService().getAdvocates(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No advocates found.'));
                }

                final lawyers = snapshot.data!;
                final filteredLawyers = _selectedSpecialization == 'All'
                    ? lawyers
                    : lawyers.where((l) => 
                        (l['specialization'] ?? '').toString().contains(_selectedSpecialization)
                      ).toList();

                if (filteredLawyers.isEmpty) {
                  return const Center(child: Text('No advocates found for this category.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredLawyers.length,
                  itemBuilder: (context, index) {
                    final lawyer = filteredLawyers[index];
                    return _buildLawyerCard(lawyer, isDarkMode);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLawyerCard(Map<String, dynamic> lawyer, bool isDarkMode) {
    final name = lawyer['full_name'] ?? 'Unknown Advocate';
    final specialization = (lawyer['languages'] as List?)?.join(', ') ?? 'General'; // Using languages as placeholder if specialization missing
    final location = lawyer['location'] ?? 'Unknown Location';
    final experience = '5+ years'; // Placeholder as experience might not be in DB yet
    final cases = '50+'; // Placeholder

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: isDarkMode ? const Color(0xFF253D79) : const Color(0xFF253D79),
                child: Text(
                  name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF121317),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialization,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                      ),
                    ),
                  ],
                ),
              ),
              // Rating placeholder
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      '4.8',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(Icons.work_outline, experience, isDarkMode),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.location_on_outlined, location, isDarkMode),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.cases_outlined, '$cases cases', isDarkMode),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to chat
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailPage(
                      otherUserId: lawyer['id'],
                      otherUserName: name,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat, size: 18),
              label: const Text('Chat with Advocate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? const Color(0xFF253D79) : const Color(0xFF253D79),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDarkMode ? Colors.grey : Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
