import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../services/supabase_service.dart';

class RTOSearchPage extends StatefulWidget {
  const RTOSearchPage({super.key});

  @override
  State<RTOSearchPage> createState() => _RTOSearchPageState();
}

class _RTOSearchPageState extends State<RTOSearchPage> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _results = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      if (mounted) setState(() => _results = []);
      return;
    }

    if (mounted) setState(() => _isLoading = true);
    
    try {
      final results = await _supabaseService.searchRTOCodes(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching RTO codes: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: Text(
          'Find RTO Location',
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
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: TextStyle(
                    color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter Code (e.g. MH12) or City',
                    hintStyle: TextStyle(
                      color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                    ),
                    prefixIcon: Icon(
                      IconlyLight.search,
                      color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: isDarkMode ? Colors.grey : Colors.grey[600]),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _results = [];
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    // Simple debounce could be added here
                    if (value.length >= 2) {
                      _performSearch(value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Try searching "MH12", "Delhi", "TN01"...',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isEmpty ? Icons.search_rounded : IconlyLight.paper_fail,
                              size: 64,
                              color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty 
                                  ? 'Search for vehicle location' 
                                  : 'No RTO found matching "$_searchQuery"',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final rto = _results[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  rto['code'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber, 
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              title: Text(
                                rto['city'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                                ),
                              ),
                              subtitle: Text(
                                rto['state'] ?? '',
                                style: TextStyle(
                                  color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                                ),
                              ),
                              trailing: Icon(
                                IconlyLight.location,
                                color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                              ),
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
