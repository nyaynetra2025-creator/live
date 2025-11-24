import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_lib;
import '../services/supabase_service.dart';

class LawyerDashboardPage extends StatefulWidget {
  const LawyerDashboardPage({super.key});

  @override
  State<LawyerDashboardPage> createState() => _LawyerDashboardPageState();
}

class _LawyerDashboardPageState extends State<LawyerDashboardPage> {
  String _advocateName = 'Advocate';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = supabase_lib.Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profile = await SupabaseService().getProfile(user.id);
        if (profile != null && mounted) {
          setState(() {
            _advocateName = profile['full_name'] ?? 'Advocate';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Colors
  Color get primary => const Color(0xFF252579);
  Color get amber => const Color(0xFFF6B21D);
  Color get royalBlue => const Color(0xFF2D52A8);
  Color get bgLight => const Color(0xFFF6F6F8);
  Color get bgDark => const Color(0xFF14141E);
  Color get textPrimary => const Color(0xFF1F1F38);
  Color get textSecondary => const Color(0xFF6A6A8A);
  Color get borderColor => const Color(0xFFE0E0E6);

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark ? bgDark : bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              decoration: BoxDecoration(
                color: dark ? bgDark : bgLight,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome,",
                        style: TextStyle(
                          fontSize: 14,
                          color: dark ? Colors.white70 : textSecondary,
                        ),
                      ),
                      Text(
                        _isLoading ? "..." : _advocateName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: dark ? Colors.white : textPrimary,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: primary.withOpacity(0.1),
                    child: Icon(Icons.person, color: primary),
                  ),
                ],
              ),
            ),

            // MAIN SCROLL SECTION
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    // ACTION CARDS GRID
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      child: Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          dashboardCard(
                            title: "Client Requests",
                            subtitle: "View new requests",
                            icon: Icons.handshake,
                            dark: dark,
                            onTap: () {
                              Navigator.pushNamed(context, '/client_requests');
                            },
                          ),
                          dashboardCard(
                            title: "Chats",
                            subtitle: "Check messages",
                            icon: Icons.chat_bubble,
                            dark: dark,
                            onTap: () {
                              Navigator.pushNamed(context, '/lawyer_chats');
                            },
                          ),
                          dashboardCard(
                            title: "Case Management",
                            subtitle: "View active cases",
                            icon: Icons.gavel,
                            dark: dark,
                            onTap: () {
                              Navigator.pushNamed(context, '/lawyer_cases');
                            },
                          ),
                          dashboardCard(
                            title: "Availability",
                            subtitle: "Manage schedule",
                            icon: Icons.calendar_month,
                            dark: dark,
                            onTap: () {
                              Navigator.pushNamed(context, '/lawyer_availability');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // BOTTOM NAV BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 6),
        decoration: BoxDecoration(
          color: dark ? bgDark.withOpacity(0.9) : Colors.white.withOpacity(0.9),
          border: Border(
            top: BorderSide(
              color: dark ? Colors.white12 : borderColor,
            ),
          ),
        ),
        child: Row(
          children: [
            navItem(
              icon: Icons.home,
              label: "Home",
              active: true,
              dark: dark,
              onTap: () {},
            ),
            navItem(
              icon: Icons.chat_bubble,
              label: "Chats",
              active: false,
              dark: dark,
              onTap: () {
                Navigator.pushNamed(context, '/lawyer_chats');
              },
            ),
            navItem(
              icon: Icons.gavel,
              label: "Cases",
              active: false,
              dark: dark,
              onTap: () {
                Navigator.pushNamed(context, '/lawyer_cases');
              },
            ),
            navItem(
              icon: Icons.person,
              label: "Profile",
              active: false,
              dark: dark,
              onTap: () {
                Navigator.pushNamed(context, '/lawyer_profile');
              },
            ),
          ],
        ),
      ),
    );
  }

  // ======= COMPONENTS =======

  Widget dashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    String? notification,
    required bool dark,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 158,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dark ? bgDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dark ? Colors.white10 : borderColor),
          boxShadow: [
            BoxShadow(
              color: dark
                  ? Colors.black.withOpacity(0.25)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
            )
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 30, color: royalBlue),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: dark ? Colors.white : textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: dark ? Colors.white60 : textSecondary,
                  ),
                ),
              ],
            ),
            // Notification Bubble
            if (notification != null)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  height: 22,
                  width: 22,
                  decoration: BoxDecoration(
                    color: amber,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    notification,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget navItem({
    required IconData icon,
    required String label,
    required bool active,
    required bool dark,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: active
                  ? primary
                  : (dark ? Colors.white54 : Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active
                    ? primary
                    : (dark ? Colors.white54 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
