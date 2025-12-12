import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../services/supabase_service.dart';

class RTOServicesPage extends StatefulWidget {
  const RTOServicesPage({super.key});

  @override
  State<RTOServicesPage> createState() => _RTOServicesPageState();
}

class _RTOServicesPageState extends State<RTOServicesPage> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _services = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final services = await _supabaseService.getRTOServices();
      if (mounted) {
        setState(() {
          _services = services;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading services: $e')),
        );
      }
    }
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'person_add': return Icons.person_add_alt_1_rounded;
      case 'drive_eta': return Icons.directions_car_filled_rounded;
      case 'directions_car': return IconlyBold.category; 
      case 'compare_arrows': return IconlyBold.swap;
      case 'refresh': return IconlyBold.time_circle;
      case 'content_copy': return IconlyBold.document; 
      default: return IconlyBold.info_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: Text(
          'RTO Services & Info',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? Center(child: Text('No information available', style: TextStyle(color: isDarkMode ? Colors.grey : Colors.grey[600])))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                      elevation: 2, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ExpansionTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF253D79).withOpacity(0.3) : const Color(0xFF253D79).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIcon(service['icon_name']),
                            color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                          ),
                        ),
                        title: Text(
                          service['title'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                          ),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        children: [
                          Divider(color: isDarkMode ? Colors.white12 : Colors.grey[200]),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              service['content'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
