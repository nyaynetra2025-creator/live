import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../services/supabase_service.dart';

class StateLawsPage extends StatefulWidget {
  const StateLawsPage({super.key});

  @override
  State<StateLawsPage> createState() => _StateLawsPageState();
}

class _StateLawsPageState extends State<StateLawsPage> {
  String _stateName = '';
  
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Police & Safety', 'icon': Icons.local_police, 'color': Colors.blueGrey},
    {'name': 'Land & Property', 'icon': Icons.landscape, 'color': Colors.green},
    {'name': 'Local Government', 'icon': Icons.location_city, 'color': Colors.orange},
    {'name': 'Rent & Housing', 'icon': Icons.home, 'color': Colors.teal},
    {'name': 'Farming', 'icon': Icons.grass, 'color': Colors.lightGreen},
    {'name': 'Alcohol & Tax', 'icon': Icons.local_drink, 'color': Colors.purple},
    {'name': 'Education', 'icon': Icons.school, 'color': Colors.amber},
    {'name': 'Employment', 'icon': Icons.engineering, 'color': Colors.brown},
    {'name': 'Societies', 'icon': Icons.groups, 'color': Colors.indigo},
    {'name': 'Transport', 'icon': Icons.directions_bus, 'color': Colors.red},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _stateName = args['stateName'];
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
          '$_stateName Laws',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(isDarkMode),
            const SizedBox(height: 20),
            Text(
              'Browse by Category',
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
                );
              },
            ),
          ],
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
          hintText: 'Search $_stateName acts...',
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
                'jurisdiction': 'State',
                'state': _stateName,
              }
            );
          }
        },
      ),
    );
  }

  Widget _buildCategoryCard(String name, IconData icon, Color color, bool isDarkMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/bare-acts-category',
            arguments: {
              'category': name,
              'jurisdiction': 'State',
              'state': _stateName,
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
