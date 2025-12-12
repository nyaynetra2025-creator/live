import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../services/supabase_service.dart';

class RTOLawsPage extends StatefulWidget {
  const RTOLawsPage({super.key});

  @override
  State<RTOLawsPage> createState() => _RTOLawsPageState();
}

class _RTOLawsPageState extends State<RTOLawsPage> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoadingMVAct = false;

  Future<void> _openMVAct() async {
    setState(() => _isLoadingMVAct = true);
    try {
      final act = await _supabaseService.getMotorVehiclesAct();
      if (!mounted) return;
      
      setState(() => _isLoadingMVAct = false);
      
      if (act != null) {
        Navigator.pushNamed(
          context, 
          '/bare-act-detail',
          arguments: {'actId': act['id']},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Motor Vehicles Act data not found')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMVAct = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
          'Vehicle & RTO Laws',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image or Banner could go here
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode 
                      ? [const Color(0xFF253D79), const Color(0xFF1E3A8A)]
                      : [const Color(0xFF253D79), const Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF253D79).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Indian Road Safety',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Know your rights, fines, and responsibilities as a driver in India.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
              ),
            ),
            const SizedBox(height: 16),
            
            // Grid of options
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _buildMenuCard(
                  context,
                  title: 'Traffic Fines',
                  subtitle: 'Challan Rates',
                  icon: IconlyBold.ticket,
                  color: Colors.red,
                  onTap: () => Navigator.pushNamed(context, '/traffic-fines'),
                  isDarkMode: isDarkMode,
                ),
                _buildMenuCard(
                  context,
                  title: 'Traffic Signs',
                  subtitle: 'Road Safety',
                  icon: Icons.traffic_rounded,
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, '/traffic-signs'),
                  isDarkMode: isDarkMode,
                ),
                _buildMenuCard(
                  context,
                  title: 'MV Act 1988',
                  subtitle: 'Full Legislation',
                  icon: IconlyBold.document,
                  color: Colors.blue,
                  onTap: _openMVAct,
                  isDarkMode: isDarkMode,
                  isLoading: _isLoadingMVAct,
                ),
                _buildMenuCard(
                  context,
                  title: 'Search RTO',
                  subtitle: 'By Code/City',
                  icon: IconlyBold.search,
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, '/rto-search'),
                  isDarkMode: isDarkMode,
                ),
                _buildMenuCard(
                  context,
                  title: 'RTO Services',
                  subtitle: 'Info & Help',
                  icon: IconlyBold.info_circle,
                  color: Colors.teal,
                  onTap: () => Navigator.pushNamed(context, '/rto-services'),
                  isDarkMode: isDarkMode,
                ),
                _buildMenuCard(
                  context,
                  title: 'Practice Test',
                  subtitle: 'LL Quiz',
                  icon: Icons.quiz_outlined,
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, '/ll-quiz'),
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.circular(16),
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
          child: isLoading 
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
