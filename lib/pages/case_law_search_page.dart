import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class CaseLawSearchPage extends StatefulWidget {
  const CaseLawSearchPage({super.key});

  @override
  State<CaseLawSearchPage> createState() => _CaseLawSearchPageState();
}

class _CaseLawSearchPageState extends State<CaseLawSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  void _search() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _supabaseService.searchLaws(_searchController.text.trim());
      setState(() {
        _results = results;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _search(); // Load initial data
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF253D79);
    final accentColor = const Color(0xFFF6B21D);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF14171E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF121317),
        elevation: 0,
        title: const Text('Case Law Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for laws, cases...',
                prefixIcon: Icon(Icons.search, color: primaryColor),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _search,
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _search(),
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
                            Icon(Icons.library_books, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No laws found',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _results.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final law = _results[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: isDarkMode ? Colors.grey[900] : Colors.white,
                            child: ListTile(
                              title: Text(
                                law['title'] ?? 'Untitled',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                law['description'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              trailing: Icon(Icons.chevron_right, color: accentColor),
                              onTap: () {
                                // Show details
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => Container(
                                    height: MediaQuery.of(context).size.height * 0.8,
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? const Color(0xFF14171E) : Colors.white,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Container(
                                            width: 40,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          law['title'] ?? 'Untitled',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode ? Colors.white : primaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Text(
                                              law['description'] ?? 'No description available.',
                                              style: TextStyle(
                                                fontSize: 16,
                                                height: 1.6,
                                                color: isDarkMode ? Colors.grey[300] : Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
