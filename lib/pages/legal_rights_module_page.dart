import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalRightsModulePage extends StatefulWidget {
  const LegalRightsModulePage({super.key});

  @override
  State<LegalRightsModulePage> createState() => _LegalRightsModulePageState();
}

class _LegalRightsModulePageState extends State<LegalRightsModulePage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<Map<String, dynamic>> _rights = [];
  bool _isLoading = true;
  DateTime? _lastUpdated;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': IconlyLight.category, 'color': Colors.blue},
    {'name': 'Fundamental Rights', 'icon': IconlyLight.shield_done, 'color': Colors.purple},
    {'name': 'Consumer Rights', 'icon': IconlyLight.bag, 'color': Colors.green},
    {'name': 'Women Rights', 'icon': IconlyLight.user_1, 'color': Colors.pink},
    {'name': 'Children Rights', 'icon': IconlyLight.heart, 'color': Colors.orange},
    {'name': 'Labour Rights', 'icon': IconlyLight.work, 'color': Colors.teal},
    {'name': 'Senior Citizen Rights', 'icon': IconlyLight.user_1, 'color': Colors.brown},
    {'name': 'Disability Rights', 'icon': IconlyLight.star, 'color': Colors.indigo},
    {'name': 'Property Rights', 'icon': IconlyLight.home, 'color': Colors.amber},
    {'name': 'Civic Rights', 'icon': IconlyLight.document, 'color': Colors.cyan},
    {'name': 'Environmental Rights', 'icon': IconlyLight.discovery, 'color': Colors.lightGreen},
    {'name': 'Social Rights', 'icon': IconlyLight.activity, 'color': Colors.deepPurple},
    {'name': 'Employment Rights', 'icon': IconlyLight.paper, 'color': Colors.blueGrey},
  ];

  @override
  void initState() {
    super.initState();
    _loadRights();
  }

  Future<void> _loadRights() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      
      dynamic query;
      if (_selectedCategory == 'All') {
        query = supabase
            .from('legal_rights')
            .select()
            .order('category', ascending: true);
      } else {
        query = supabase
            .from('legal_rights')
            .select()
            .eq('category', _selectedCategory)
            .order('title', ascending: true);
      }

      final data = await query;
      setState(() {
        _rights = List<Map<String, dynamic>>.from(data);
        _lastUpdated = DateTime.now();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading rights: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredRights {
    if (_searchQuery.isEmpty) return _rights;
    return _rights.where((right) {
      final title = right['title']?.toString().toLowerCase() ?? '';
      final description = right['description']?.toString().toLowerCase() ?? '';
      final sourceLaw = right['source_law']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || description.contains(query) || sourceLaw.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: isDarkMode ? const Color(0xFF1F2937) : const Color(0xFF253D79),
            leading: IconButton(
              icon: const Icon(IconlyLight.arrow_left, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Legal Rights',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? [const Color(0xFF253D79), const Color(0xFF14171E)]
                        : [const Color(0xFF253D79), const Color(0xFF4F6CB0)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 70,
                      child: Icon(
                        IconlyBold.shield_done,
                        size: 60,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (_lastUpdated != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(IconlyLight.time_circle, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            _formatLastUpdated(),
                            style: const TextStyle(fontSize: 11, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(IconlyLight.info_circle, color: Colors.white),
                onPressed: () => _showInfoDialog(context, isDarkMode),
              ),
            ],
          ),
        ],
        body: RefreshIndicator(
          onRefresh: _loadRights,
          color: const Color(0xFFF6B21D),
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
                    hintText: 'Search rights, laws, articles...',
                    hintStyle: TextStyle(
                      color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                    ),
                    prefixIcon: Icon(
                      IconlyLight.search,
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

              // Category Filter (Horizontal scroll)
              Container(
                height: 100,
                color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category['name'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedCategory = category['name'];
                            _loadRights();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 80,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79))
                                : (isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : (isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                category['icon'] as IconData,
                                size: 24,
                                color: isSelected
                                    ? Colors.white
                                    : (category['color'] as Color),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _getCategoryShortName(category['name'] as String),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082)),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Stats bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
                child: Row(
                  children: [
                    Icon(
                      IconlyBold.document,
                      size: 16,
                      color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_filteredRights.length} rights found',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                      ),
                    ),
                    const Spacer(),
                    if (_selectedCategory != 'All')
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = 'All';
                            _loadRights();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                IconlyLight.close_square,
                                size: 14,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Clear filter',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Rights List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFF6B21D)))
                    : _filteredRights.isEmpty
                        ? _buildEmptyState(isDarkMode)
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredRights.length,
                            itemBuilder: (context, index) {
                              final right = _filteredRights[index];
                              return _buildRightCard(right, isDarkMode, index);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconlyLight.shield_fail,
            size: 80,
            color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
          const SizedBox(height: 16),
          Text(
            'No rights found',
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
    );
  }

  Widget _buildRightCard(Map<String, dynamic> right, bool isDarkMode, int index) {
    final title = right['title'] ?? 'Untitled Right';
    final category = right['category'] ?? 'General';
    final articleNumber = right['article_number'];
    final description = right['description'] ?? '';
    final sourceLaw = right['source_law'] ?? '';
    final status = right['status'] ?? 'Active';

    // Get category color
    final categoryData = _categories.firstWhere(
      (c) => c['name'] == category,
      orElse: () => {'color': Colors.blue},
    );
    final categoryColor = categoryData['color'] as Color? ?? Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            _showRightDetails(context, right, isDarkMode);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with category badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getCategoryShortName(category),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                    ),
                    if (articleNumber != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          articleNumber,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'Active'
                            ? Colors.green.withValues(alpha: 0.15)
                            : Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            status == 'Active' ? Icons.check_circle : Icons.info,
                            size: 12,
                            color: status == 'Active' ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: status == 'Active' ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 8),

                // Source Law
                if (sourceLaw.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        IconlyLight.document,
                        size: 14,
                        color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          sourceLaw,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 12),

                // Description preview
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // View details button
                Row(
                  children: [
                    Icon(
                      IconlyLight.info_circle,
                      size: 16,
                      color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                    ),
                    const SizedBox(width: 6),
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
                      IconlyLight.arrow_right_2,
                      size: 16,
                      color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
  }

  void _showRightDetails(BuildContext context, Map<String, dynamic> right, bool isDarkMode) {
    final title = right['title'] ?? 'Untitled Right';
    final category = right['category'] ?? 'General';
    final articleNumber = right['article_number'];
    final description = right['description'] ?? 'No description available';
    final sourceLaw = right['source_law'] ?? '';
    final sourceUrl = right['source_url'];
    final status = right['status'] ?? 'Active';
    final applicableTo = right['applicable_to'] ?? 'All Citizens';
    final remedies = right['remedies'] ?? '';
    
    // Parse JSON fields
    List<String> keyPoints = [];
    List<String> examples = [];
    
    try {
      if (right['key_points'] != null) {
        keyPoints = List<String>.from(right['key_points']);
      }
      if (right['examples'] != null) {
        examples = List<String>.from(right['examples']);
      }
    } catch (e) {
      // Handle parsing errors silently
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    
                    // Metadata chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(category, IconlyLight.category, Colors.purple, isDarkMode),
                        if (articleNumber != null)
                          _buildChip(articleNumber, IconlyLight.document, const Color(0xFF253D79), isDarkMode),
                        _buildChip(applicableTo, IconlyLight.user_1, Colors.blue, isDarkMode),
                        _buildChip(
                          status,
                          status == 'Active' ? Icons.check_circle : Icons.info,
                          status == 'Active' ? Colors.green : Colors.orange,
                          isDarkMode,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Source Law
                    if (sourceLaw.isNotEmpty)
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
                              IconlyBold.document,
                              size: 24,
                              color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Source',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    sourceLaw,
                                    style: TextStyle(
                                      fontSize: 15,
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
                    
                    if (sourceLaw.isNotEmpty) const SizedBox(height: 24),
                    
                    // Description
                    _buildSection('Description', description, IconlyLight.info_circle, isDarkMode),
                    
                    const SizedBox(height: 24),
                    
                    // Key Points
                    if (keyPoints.isNotEmpty) ...[
                      _buildSectionHeader('Key Points', IconlyLight.tick_square, isDarkMode),
                      const SizedBox(height: 12),
                      ...keyPoints.map((point) => _buildBulletPoint(point, isDarkMode)),
                      const SizedBox(height: 24),
                    ],
                    
                    // Examples
                    if (examples.isNotEmpty) ...[
                      _buildSectionHeader('Examples', IconlyLight.star, isDarkMode),
                      const SizedBox(height: 12),
                      ...examples.map((example) => _buildBulletPoint(example, isDarkMode, isExample: true)),
                      const SizedBox(height: 24),
                    ],
                    
                    // Remedies
                    if (remedies.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDarkMode
                                ? [const Color(0xFF253D79).withValues(alpha: 0.3), const Color(0xFF1F2937)]
                                : [const Color(0xFF253D79).withValues(alpha: 0.1), Colors.white],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode ? const Color(0xFF253D79) : const Color(0xFF253D79).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  IconlyBold.shield_done,
                                  size: 20,
                                  color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'How to Seek Remedy',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              remedies,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Source URL button
                    if (sourceUrl != null && sourceUrl.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(sourceUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(IconlyLight.paper_plus),
                        label: const Text('View Official Source'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String text, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, icon, isDarkMode),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            height: 1.7,
            color: isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDarkMode) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text, bool isDarkMode, {bool isExample = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isExample
                  ? const Color(0xFFF6B21D)
                  : (isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              IconlyBold.info_circle,
              color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
            ),
            const SizedBox(width: 12),
            Text(
              'About Legal Rights',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'This module contains comprehensive information about your legal rights as an Indian citizen, sourced from:\n\n'
          '• Constitution of India\n'
          '• Indian Penal Code\n'
          '• Consumer Protection Act\n'
          '• Right to Information Act\n'
          '• And many more...\n\n'
          'Data is regularly updated from official Indian government sources.',
          style: TextStyle(
            color: isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(
                color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryShortName(String category) {
    switch (category) {
      case 'Fundamental Rights':
        return 'Fundamental';
      case 'Consumer Rights':
        return 'Consumer';
      case 'Women Rights':
        return 'Women';
      case 'Children Rights':
        return 'Children';
      case 'Labour Rights':
        return 'Labour';
      case 'Senior Citizen Rights':
        return 'Senior';
      case 'Disability Rights':
        return 'Disability';
      case 'Property Rights':
        return 'Property';
      case 'Civic Rights':
        return 'Civic';
      case 'Environmental Rights':
        return 'Environment';
      case 'Social Rights':
        return 'Social';
      case 'Employment Rights':
        return 'Employment';
      default:
        return category;
    }
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
