import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../services/supabase_service.dart';

class TrafficFinesPage extends StatefulWidget {
  const TrafficFinesPage({super.key});

  @override
  State<TrafficFinesPage> createState() => _TrafficFinesPageState();
}

class _TrafficFinesPageState extends State<TrafficFinesPage> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _fines = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFines();
  }

  Future<void> _loadFines() async {
    setState(() => _isLoading = true);
    try {
      final fines = await _supabaseService.getRTOFines(searchQuery: _searchQuery);
      if (mounted) {
        setState(() {
          _fines = fines;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading fines: $e')),
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
          'Traffic Fines & Penalties',
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
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
              ),
              decoration: InputDecoration(
                hintText: 'Search offenses (e.g., helmet, speed)...',
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
                // Simple debounce could be added here
                _loadFines();
              },
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _fines.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              IconlyLight.paper,
                              size: 64,
                              color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No fines found',
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
                        itemCount: _fines.length,
                        itemBuilder: (context, index) {
                          final fine = _fines[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          fine['offense'] ?? '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                                          ),
                                        ),
                                      ),
                                      if (fine['category'] != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isDarkMode ? const Color(0xFF253D79).withOpacity(0.3) : const Color(0xFF253D79).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            fine['category'],
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (fine['section'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        'Section: ${fine['section']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                                        ),
                                      ),
                                    ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            fine['penalty'] ?? '',
                                            style: TextStyle(
                                              color: Colors.red[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
