import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LawsInfoPage extends StatefulWidget {
  const LawsInfoPage({super.key});

  @override
  State<LawsInfoPage> createState() => _LawsInfoPageState();
}

class _LawsInfoPageState extends State<LawsInfoPage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<Map<String, dynamic>> _laws = [];
  bool _isLoading = true;
  DateTime? _lastUpdated;

  final List<String> _categories = [
    'All',
    'Constitutional',
    'Criminal',
    'Civil',
    'Tax',
    'Labor',
    'Corporate',
    'Property',
    'Family',
    'Cyber'
  ];

  @override
  void initState() {
    super.initState();
    _loadLaws();
  }

  Future<void> _loadLaws() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      
      // Build query based on category selection
      final query = _selectedCategory == 'All'
          ? supabase
              .from('laws')
              .select()
              .order('year_enacted', ascending: false)
          : supabase
              .from('laws')
              .select()
              .eq('category', _selectedCategory)
              .order('year_enacted', ascending: false);

      final data = await query;
      setState(() {
        _laws = List<Map<String, dynamic>>.from(data);
        _lastUpdated = DateTime.now();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading laws: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredLaws {
    if (_searchQuery.isEmpty) return _laws;
    return _laws.where((law) {
      final title = law['title']?.toString().toLowerCase() ?? '';
      final description = law['description']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || description.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Laws & Acts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
          ),
        ),
        actions: [
          if (_lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  'Updated ${_formatLastUpdated()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadLaws,
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
              child: TextField(
                style: TextStyle(
                  color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                ),
                decoration: InputDecoration(
                  hintText: 'Search laws...',
                  hintStyle: TextStyle(
                    color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),

            // Category Filter
            Container(
              height: 50,
              color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                          _loadLaws();
                        });
                      },
                      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
                      selectedColor: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082)),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Laws List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredLaws.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.gavel_outlined,
                                size: 80,
                                color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No laws found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try a different search or category',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredLaws.length,
                          itemBuilder: (context, index) {
                            final law = _filteredLaws[index];
                            return _buildLawCard(law, isDarkMode, index);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLawCard(Map<String, dynamic> law, bool isDarkMode, int index) {
    final title = law['title'] ?? 'Untitled Law';
    final category = law['category'] ?? 'General';
    final yearEnacted = law['year_enacted'];
    final description = law['description'] ?? '';
    final status = law['status'] ?? 'Active';
    // officialUrl available in law['official_url'] if needed

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _showLawDetails(context, law, isDarkMode);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'Active'
                            ? (isDarkMode ? Colors.green.withOpacity(0.2) : Colors.green.withOpacity(0.1))
                            : (isDarkMode ? Colors.orange.withOpacity(0.2) : Colors.orange.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: status == 'Active' ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Category and Year
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF253D79).withOpacity(0.3)
                            : const Color(0xFF253D79).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                        ),
                      ),
                    ),
                    if (yearEnacted != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        yearEnacted.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                        ),
                      ),
                    ],
                  ],
                ),

                // Description
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Details Button
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to view full details',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms);
  }

  void _showLawDetails(BuildContext context, Map<String, dynamic> law, bool isDarkMode) {
    final title = law['title'] ?? 'Untitled Law';
    final category = law['category'] ?? 'General';
    final yearEnacted = law['year_enacted'];
    final description = law['description'] ?? 'No description available';
    final status = law['status'] ?? 'Active';
    // officialUrl available in law['official_url'] if needed
    final lastAmended = law['last_amended_date'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Metadata Row
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Category
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF253D79).withOpacity(0.3)
                                : const Color(0xFF253D79).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 16,
                                color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                category.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Year
                        if (yearEnacted != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Enacted: $yearEnacted',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Status
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: status == 'Active'
                                ? (isDarkMode ? Colors.green.withOpacity(0.2) : Colors.green.withOpacity(0.1))
                                : (isDarkMode ? Colors.orange.withOpacity(0.2) : Colors.orange.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                status == 'Active' ? Icons.check_circle : Icons.info,
                                size: 16,
                                color: status == 'Active' ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: status == 'Active' ? Colors.green : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Description Section
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                      ),
                    ),
                    
                    // Last Amended
                    if (lastAmended != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.update,
                              size: 20,
                              color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Last Amended',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    lastAmended.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // No external links - all data shown above
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLastUpdated() {
    if (_lastUpdated == null) return 'Never';
    final diff = DateTime.now().difference(_lastUpdated!);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
