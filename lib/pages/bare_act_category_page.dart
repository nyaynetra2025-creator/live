import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../services/supabase_service.dart';

class BareActCategoryPage extends StatefulWidget {
  const BareActCategoryPage({super.key});

  @override
  State<BareActCategoryPage> createState() => _BareActCategoryPageState();
}

class _BareActCategoryPageState extends State<BareActCategoryPage> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _acts = [];
  String _category = '';
  String _jurisdiction = '';
  String? _state;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _category = args['category'] ?? 'All';
    _jurisdiction = args['jurisdiction'] ?? 'Central';
    _state = args['state'];
    final initialQuery = args['searchQuery'] as String?;
    
    if (initialQuery != null) {
      _searchQuery = initialQuery;
      _searchController.text = initialQuery;
    }
    
    _loadActs();
  }

  Future<void> _loadActs() async {
    setState(() => _isLoading = true);
    try {
      final acts = await _supabaseService.getBareActs(
        category: _category == 'All' ? null : _category,
        jurisdiction: _jurisdiction,
        state: _state,
        searchQuery: _searchQuery,
      );
      
      if (!mounted) return;
      setState(() {
        _acts = acts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading acts: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final title = _searchQuery.isNotEmpty 
        ? 'Search Results' 
        : (_category == 'All' ? 'All $_jurisdiction Acts' : '$_category Laws');

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
              ),
            ),
            if (_state != null)
              Text(
                _state!,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
              ),
              decoration: InputDecoration(
                hintText: 'Search within this list...',
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
                // Debounce could be added here
                setState(() => _searchQuery = value);
                _loadActs();
              },
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _acts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              IconlyLight.document,
                              size: 64,
                              color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No acts found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadActs,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _acts.length,
                          itemBuilder: (context, index) {
                            final act = _acts[index];
                            return _buildActCard(act, isDarkMode);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildActCard(Map<String, dynamic> act, bool isDarkMode) {
    final title = act['title'] ?? 'Untitled Act';
    // ignore: unused_local_variable
    final shortTitle = act['short_title'];
    final year = act['year_enacted'];
    final actNumber = act['act_number'];
    final isBookmarked = (act['user_bare_act_bookmarks'] as List?)?.isNotEmpty ?? false;

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
            Navigator.pushNamed(
              context, 
              '/bare-act-detail',
              arguments: {'actId': act['id']},
            ).then((_) => _loadActs()); // Refresh on return to update bookmark status
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF253D79).withOpacity(0.3) : const Color(0xFF253D79).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    IconlyLight.paper,
                    color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                    size: 24,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (year != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$year',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                                ),
                              ),
                            ),
                          // New Badge for recent acts
                          if (year != null && year >= 2023) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.green.withOpacity(0.5)),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                          if (actNumber != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Act No. $actNumber',
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
                if (isBookmarked)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      IconlyBold.bookmark,
                      color: const Color(0xFFF6B21D),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
