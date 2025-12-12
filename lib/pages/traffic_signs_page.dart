import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../services/supabase_service.dart';

class TrafficSignsPage extends StatefulWidget {
  const TrafficSignsPage({super.key});

  @override
  State<TrafficSignsPage> createState() => _TrafficSignsPageState();
}

class _TrafficSignsPageState extends State<TrafficSignsPage> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _signs = [];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadSigns();
  }

  Future<void> _loadSigns() async {
    setState(() => _isLoading = true);
    try {
      final signs = await _supabaseService.getTrafficSigns();
      if (mounted) {
        setState(() {
          _signs = signs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading signs: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Filter logic
    final filteredSigns = _selectedCategory == 'All' 
        ? _signs 
        : _signs.where((s) => s['category'] == _selectedCategory).toList();

    // Get unique categories
    final categories = ['All', ..._signs.map((s) => s['category'] as String).toSet()];

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: Text(
          'Traffic Signs',
          style: TextStyle(
            color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0,
        leading: BackButton(
          color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
        ),
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (c, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  backgroundColor: isDarkMode ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                  selectedColor: const Color(0xFF253D79),
                  labelStyle: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : (isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF4B5563)),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              },
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredSigns.isEmpty
                    ? Center(child: Text('No signs found', style: TextStyle(color: isDarkMode ? Colors.grey : Colors.grey[700])))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: filteredSigns.length,
                        itemBuilder: (context, index) {
                          final sign = filteredSigns[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    child: Image.network(
                                      sign['image_url'] ?? '',
                                      errorBuilder: (c, e, s) => Icon(
                                        IconlyBold.danger,
                                        size: 48,
                                        color: isDarkMode ? Colors.grey : Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? const Color(0xFF374151).withOpacity(0.5) : const Color(0xFFF3F4F6),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          sign['name'] ?? '',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          sign['category'] ?? '',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
