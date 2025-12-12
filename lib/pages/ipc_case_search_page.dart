import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '../services/ai_service.dart';

class IPCCaseSearchPage extends StatefulWidget {
  const IPCCaseSearchPage({super.key});

  @override
  State<IPCCaseSearchPage> createState() => _IPCCaseSearchPageState();
}

class _IPCCaseSearchPageState extends State<IPCCaseSearchPage> with TickerProviderStateMixin {
  final TextEditingController _sectionController = TextEditingController();
  final AiService _aiService = AiService();
  List<Map<String, dynamic>> _cases = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _currentSection = '';
  String _selectedCategory = 'All';
  
  // Category definitions with their IPC sections
  final Map<String, List<String>> _categories = {
    'All': [],
    'Criminal': ['302', '307', '304', '324', '326', '323'],
    'Property': ['378', '379', '380', '381', '382', '383', '406', '411'],
    'Personal': ['354', '376', '375', '498A', '304B', '306'],
    'Financial': ['420', '406', '408', '409', '467', '468', '471'],
    'Cyber': ['66', '67', '43', '65', '70'],
    'Traffic': ['279', '304A', '337', '338'],
  };
  
  // Animation controllers
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  
  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _searchCases(String section) async {
    if (section.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an IPC section number')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _currentSection = section;
    });

    try {
      final cases = await _aiService.searchIPCCases(section);
      if (mounted) {
        setState(() {
          _cases = cases;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _openCase(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open case')),
        );
      }
    }
  }

  @override
  void dispose() {
    _sectionController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }
  
  Widget _buildAnimatedLoading(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated gavel with rotating ring
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer rotating ring
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF253D79).withOpacity(0.3),
                            width: 3,
                          ),
                          gradient: SweepGradient(
                            colors: [
                              const Color(0xFF253D79),
                              const Color(0xFFF6B21D),
                              const Color(0xFF253D79).withOpacity(0.2),
                              const Color(0xFF253D79),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Middle pulsing circle
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 70 + (_pulseController.value * 10),
                      height: 70 + (_pulseController.value * 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkMode 
                            ? const Color(0xFF253D79).withOpacity(0.2)
                            : const Color(0xFF253D79).withOpacity(0.1),
                      ),
                    );
                  },
                ),
                // Bouncing gavel icon
                AnimatedBuilder(
                  animation: _bounceController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -5 + (_bounceController.value * 10)),
                      child: Transform.rotate(
                        angle: -0.3 + (_bounceController.value * 0.6),
                        child: Icon(
                          Icons.gavel,
                          size: 40,
                          color: isDarkMode 
                              ? const Color(0xFFF6B21D)
                              : const Color(0xFF253D79),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Animated searching text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Searching IPC §$_currentSection',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode 
                      ? const Color(0xFFF5F5F7)
                      : const Color(0xFF253D79),
                ),
              ),
              // Animated dots
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final dots = '.' * ((_pulseController.value * 3).toInt() + 1);
                  return SizedBox(
                    width: 24,
                    child: Text(
                      dots,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode 
                            ? const Color(0xFFF6B21D)
                            : const Color(0xFF253D79),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Floating scales
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, math.sin(_bounceController.value * math.pi) * 8),
                child: Icon(
                  Icons.balance,
                  size: 32,
                  color: isDarkMode 
                      ? const Color(0xFFA0AEC0).withOpacity(0.6)
                      : const Color(0xFF687082).withOpacity(0.6),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing court records...',
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode 
                  ? const Color(0xFFA0AEC0)
                  : const Color(0xFF687082),
            ),
          ),
        ],
      ),
    );
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
          'IPC Case Search',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _sectionController,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter IPC Section (e.g., 302, 420)',
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
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onSubmitted: (_) => _searchCases(_sectionController.text.trim()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _searchCases(_sectionController.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF253D79),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Search',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Category Tabs
          Container(
            height: 90,
            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: _categories.keys.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildCategoryTab(category, isSelected, isDarkMode),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Results Section
          Expanded(
            child: _isLoading
                ? _buildAnimatedLoading(isDarkMode)
                : !_hasSearched
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Popular Sections Header
                            Text(
                              'Popular IPC Sections',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Popular sections grid
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.6,
                              children: [
                                _buildSectionCard('302', 'Murder', 'Punishment: Death or Life', Colors.red, isDarkMode),
                                _buildSectionCard('376', 'Rape', 'Punishment: 10 yrs to Life', Colors.purple, isDarkMode),
                                _buildSectionCard('420', 'Cheating', 'Punishment: Up to 7 yrs', Colors.orange, isDarkMode),
                                _buildSectionCard('498A', 'Cruelty', 'By Husband/Relatives', Colors.pink, isDarkMode),
                                _buildSectionCard('304B', 'Dowry Death', 'Within 7 years of marriage', Colors.deepOrange, isDarkMode),
                                _buildSectionCard('307', 'Attempt Murder', 'Punishment: Up to 10 yrs', Colors.redAccent, isDarkMode),
                                _buildSectionCard('354', 'Assault Woman', 'Outraging modesty', Colors.indigo, isDarkMode),
                                _buildSectionCard('506', 'Intimidation', 'Criminal threat', Colors.teal, isDarkMode),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Info Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDarkMode 
                                    ? const Color(0xFF253D79).withOpacity(0.2)
                                    : const Color(0xFF253D79).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode 
                                      ? const Color(0xFF253D79).withOpacity(0.5)
                                      : const Color(0xFF253D79).withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'About IPC',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF253D79),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'The Indian Penal Code (IPC) is the official criminal code of India. It covers all substantive aspects of criminal law. Search any section number to find related court cases and judgments.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : _cases.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No cases found for IPC Section $_currentSection',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Found ${_cases.length} cases for IPC Section $_currentSection',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _cases.length,
                                  itemBuilder: (context, index) {
                                    final caseItem = _cases[index];
                                    return _buildCaseCard(caseItem, isDarkMode);
                                  },
                                ),
                              ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCard(Map<String, dynamic> caseItem, bool isDarkMode) {
    final title = caseItem['title'] ?? 'Untitled Case';
    final court = caseItem['court'] ?? 'Unknown Court';
    final date = caseItem['date'] ?? '';
    final url = caseItem['url'] ?? '';

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
          onTap: url.isNotEmpty ? () => _openCase(url) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? const Color(0xFF253D79).withOpacity(0.3) 
                            : const Color(0xFF253D79).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.gavel,
                        color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance,
                                size: 14,
                                color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  court,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (date.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      size: 18,
                      color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionCard(String section, String title, String description, Color color, bool isDarkMode) {
    return InkWell(
      onTap: () {
        _sectionController.text = section;
        _searchCases(section);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode 
              ? color.withOpacity(0.15)
              : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '§$section',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? color.withOpacity(0.9) : color,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: color.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryTab(String category, bool isSelected, bool isDarkMode) {
    // Icons for each category
    final categoryIcons = {
      'All': Icons.grid_view_rounded,
      'Criminal': Icons.gavel,
      'Property': Icons.home_work,
      'Personal': Icons.people,
      'Financial': Icons.account_balance_wallet,
      'Cyber': Icons.computer,
      'Traffic': Icons.directions_car,
    };
    
    final categoryColors = {
      'All': const Color(0xFFF6B21D),
      'Criminal': Colors.red,
      'Property': Colors.green,
      'Personal': Colors.purple,
      'Financial': Colors.orange,
      'Cyber': Colors.blue,
      'Traffic': Colors.teal,
    };
    
    final icon = categoryIcons[category] ?? Icons.category;
    final color = categoryColors[category] ?? Colors.grey;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
          _hasSearched = false;
          _cases = [];
        });
        // If a specific category is selected, auto-search with first section
        if (category != 'All' && _categories[category]!.isNotEmpty) {
          _sectionController.text = _categories[category]!.first;
        }
      },
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDarkMode ? color.withOpacity(0.2) : color.withOpacity(0.1))
              : (isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected 
                    ? color.withOpacity(0.2)
                    : (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected 
                    ? color
                    : (isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected 
                    ? (isDarkMode ? Colors.white : color)
                    : (isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
