import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../services/supabase_service.dart';
import '../services/language_service.dart';

class BareActsPage extends StatefulWidget {
  const BareActsPage({super.key});

  @override
  State<BareActsPage> createState() => _BareActsPageState();
}

class _BareActsPageState extends State<BareActsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseService _supabaseService = SupabaseService();
  
  String _selectedState = 'Maharashtra';
  final List<String> _states = [
    'Maharashtra', 'Delhi', 'Karnataka', 'Tamil Nadu', 'Uttar Pradesh', 
    'Gujarat', 'West Bengal', 'Rajasthan', 'Telangana', 'Kerala'
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Constitutional', 'icon': Icons.account_balance, 'color': Colors.blue},
    {'name': 'Criminal', 'icon': Icons.gavel, 'color': Colors.red},
    {'name': 'Civil', 'icon': Icons.balance, 'color': Colors.green},
    {'name': 'Family', 'icon': Icons.family_restroom, 'color': Colors.pink},
    {'name': 'Corporate', 'icon': Icons.business, 'color': Colors.indigo},
    {'name': 'Tax', 'icon': Icons.currency_rupee, 'color': Colors.orange},
    {'name': 'Labor', 'icon': Icons.engineering, 'color': Colors.brown},
    {'name': 'Property', 'icon': Icons.home_work, 'color': Colors.teal},
    {'name': 'Cyber', 'icon': Icons.computer, 'color': Colors.purple},
    {'name': 'Environmental', 'icon': Icons.eco, 'color': Colors.lightGreen},
    {'name': 'Banking', 'icon': Icons.account_balance_wallet, 'color': Colors.cyan},
    {'name': 'Education', 'icon': Icons.school, 'color': Colors.amber},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Bare Acts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
          unselectedLabelColor: isDarkMode ? Colors.grey : Colors.grey[600],
          indicatorColor: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
          tabs: const [
            Tab(text: 'Central Acts'),
            Tab(text: 'State Acts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCentralActsTab(isDarkMode),
          _buildStateActsTab(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildCentralActsTab(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(isDarkMode),
          const SizedBox(height: 20),
          Text(
            'Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _buildCategoryCard(
                category['name'],
                category['icon'],
                category['color'],
                isDarkMode,
                'Central',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStateActsTab(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select State',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
            ),
            itemCount: _states.length,
            itemBuilder: (context, index) {
              final state = _states[index];
              return _buildStateCard(state, isDarkMode);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStateCard(String stateName, bool isDarkMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/state-laws',
            arguments: {'stateName': stateName},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79)).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  size: 18,
                  color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  stateName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: TextField(
        style: TextStyle(
          color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
        ),
        decoration: InputDecoration(
          hintText: 'Search for acts...',
          hintStyle: TextStyle(
            color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
          ),
          border: InputBorder.none,
          icon: Icon(
            IconlyLight.search,
            color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
          ),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Navigator.pushNamed(
              context, 
              '/bare-acts-category',
              arguments: {
                'category': 'All', 
                'searchQuery': value,
                'jurisdiction': _tabController.index == 0 ? 'Central' : 'State',
                'state': _tabController.index == 1 ? _selectedState : null,
              }
            );
          }
        },
      ),
    );
  }

  Widget _buildCategoryCard(String name, IconData icon, Color color, bool isDarkMode, String jurisdiction) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/bare-acts-category',
            arguments: {
              'category': name,
              'jurisdiction': jurisdiction,
              'state': jurisdiction == 'State' ? _selectedState : null,
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
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
